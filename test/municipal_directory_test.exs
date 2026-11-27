defmodule Ecidadao.MunicipalDirectoryTest do
  use ExUnit.Case, async: true
  alias Ecidadao.MunicipalDirectory

  @data "priv/municipal_services.json" |> File.read!() |> Jason.decode!()

  defp search(args) do
    assert {:ok, response} = MunicipalDirectory.search(args)
    response
  end

  test "defaults, bounds, municipality filtering and deterministic ordering" do
    default = search(%{})
    assert default.total == 320
    assert length(default.results) == 12
    assert default == search(%{})
    assert default.status == "catalogue_only"
    refute default.submitted
    refute default.availability_checked
    refute Map.has_key?(default, :query)
    assert default.verified_on == "2026-11-27"

    for {municipality, count} <- [{"gondomar", 136}, {"maia", 126}, {"ponte_de_lima", 58}],
        limit <- [1, 12, 30] do
      response = search(%{"municipality" => municipality, "limit" => limit})
      assert response.total == count
      assert length(response.results) == limit
      assert Enum.all?(response.results, &(&1["municipality"] == municipality))
      assert Map.keys(response.sources) == [municipality]
    end
  end

  test "case and accent insensitive search, exact matches first, no substring noise" do
    assert search(%{"query" => "HABITAÇÃO"}) == search(%{"query" => "habitacao"})
    assert hd(search(%{"query" => "Recolha de monos"}).results)["title"] == "Recolha de monos"
    assert search(%{"query" => "cert"}).total == 0
    assert search(%{"query" => "unfindableword"}).results == []
  end

  test "natural English and Portuguese needs resolve to relevant services" do
    for {query, title} <- [
          {"I need a parking permit", "Estacionamento"},
          {"quero renovar cartao de estacionamento", "Estacionamento"},
          {"housing", "Habitação"},
          {"water tariff", "Tarif"},
          {"bulky waste collection", "monos"},
          {"recolha de moveis", "monos"},
          {"certificate", "Certidão"},
          {"preciso de uma certidao", "Certidão"},
          {"school transport", "Transport"},
          {"transportes escolares", "Transport"}
        ] do
      response = search(%{"query" => query, "limit" => 30})
      assert response.total > 0, query
      assert Enum.any?(response.results, &String.contains?(&1["title"], title)), query
    end
  end

  test "invalid arguments never echo unknown keys or values" do
    for args <- [
          nil,
          [],
          "secret",
          %{query: "secret"},
          %{"secret" => "secret"},
          %{"municipality" => "porto"},
          %{"municipality" => nil},
          %{"query" => 3},
          %{"query" => <<255>>},
          %{"query" => String.duplicate("a", 161)},
          %{"limit" => 0},
          %{"limit" => 31},
          %{"limit" => 1.0},
          %{"limit" => "12"},
          %{"language" => "fr"}
        ] do
      assert {:error, error} = MunicipalDirectory.search(args)
      assert error.error == "invalid_arguments"
      refute Jason.encode!(error) =~ "secret"
    end

    assert {:ok, _} = MunicipalDirectory.search(%{"query" => String.duplicate("á", 160)})
  end

  test "only official HTTPS destinations; stable distinct IDs and safe queries" do
    entries = @data["services"]
    assert length(Enum.uniq_by(entries, & &1["id"])) == length(entries)
    assert length(Enum.uniq_by(entries, & &1["official_url"])) == length(entries)

    for item <- entries, url <- [item["official_url"], item["source"]] do
      uri = URI.parse(url)
      assert uri.scheme == "https"

      assert uri.host in [
               "servicosonline.cm-gondomar.pt",
               "www.cm-gondomar.pt",
               "diretorio.cm-maia.pt",
               "www.cm-pontedelima.pt"
             ]

      assert uri.userinfo == nil
      assert uri.fragment == nil
      refute url =~ "&amp;"
      assert item["authentication"] in ["required", "unknown"]
    end

    ponte = Enum.filter(entries, &(&1["municipality"] == "ponte_de_lima"))

    ids =
      Enum.map(
        ponte,
        &(URI.parse(&1["official_url"]).query |> URI.decode_query() |> Map.fetch!("procedure_id"))
      )

    assert length(Enum.uniq(ids)) == 58
  end

  test "category pages and Maia action variants are excluded; follow-ups stay distinct" do
    entries = @data["services"]
    maia = Enum.filter(entries, &(&1["municipality"] == "maia"))

    refute Enum.any?(
             maia,
             &(&1["title"] in [
                 "Urbanismo",
                 "Ação Social",
                 "Diretório de Serviços",
                 "Trânsito e Estacionamento"
               ])
           )

    assert length(Enum.uniq_by(maia, & &1["title"])) == length(maia)
    assert Enum.all?(maia, &(URI.parse(&1["official_url"]).query == nil))
    gondomar = Enum.filter(entries, &(&1["municipality"] == "gondomar"))

    for id <- ["gondomar-10748", "gondomar-10750", "gondomar-10747"] do
      assert Enum.any?(gondomar, &(&1["id"] == id))
    end
  end

  test "localized guidance keeps the original official titles and explains limitations" do
    pt = search(%{"query" => "water tariff"})
    en = search(%{"query" => "water tariff", "language" => "en"})
    assert pt.results == en.results
    assert pt.steps != en.steps
    assert en.notice =~ "Portuguese"
    assert en.notice =~ "availability is not checked"
  end
end
