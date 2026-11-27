defmodule Ecidadao.PublicSupportTest do
  use ExUnit.Case, async: true
  alias Ecidadao.PublicSupport

  @today ~D[2026-11-27]
  @ids ~w(porta65_young porta65_plus gondomar_housing environmental_fund vale_efficiency elar green_mobility)

  test "seven complete localized snapshots with official links and no financial decisions" do
    assert PublicSupport.services() == @ids
    assert length(PublicSupport.all()) == 7

    for language <- ["pt", "en"], service <- @ids do
      assert {:ok, result} =
               PublicSupport.guide(%{"service" => service, "language" => language}, @today)

      assert result == Enum.find(PublicSupport.all(language, @today), &(&1.id == service))
      assert result.status == "guidance_only"
      refute result.submitted
      assert result.remaining_budget == nil
      assert result.verified_on == "2026-11-27"
      assert result.as_of == "2026-11-27"
      assert result.language == language
      assert result.source in result.sources
      assert result.application_url in result.sources
      assert length(result.checklist) >= 2

      for key <- [:title, :audience, :purpose, :requirements, :navigation, :example] do
        assert is_binary(result[key]) and String.length(result[key]) > 0
      end

      for source <- result.sources do
        uri = URI.parse(source)
        assert uri.scheme == "https"

        assert uri.host in [
                 "www.portaldahabitacao.pt",
                 "www.fundoambiental.pt",
                 "www.cm-gondomar.pt",
                 "servicosonline.cm-gondomar.pt",
                 "efundos.fundoambiental.pt"
               ]

        assert result.steps =~ source
      end

      refute result.steps =~ ~r/€|\beuros?\b|\bEUR\b/i
      refute Map.has_key?(result, :approved)
      refute Map.has_key?(result, :eligible)
      refute Map.has_key?(result, :amount)

      assert result.confirmation =~
               if(language == "en", do: "not guaranteed", else: "Não há garantia")

      assert result.confirmation =~
               if(language == "en", do: "No personal data", else: "dados pessoais")
    end

    for id <- @ids do
      {:ok, pt} = PublicSupport.guide(%{"service" => id}, @today)
      {:ok, en} = PublicSupport.guide(%{"service" => id, "language" => "en"}, @today)
      assert pt.language == "pt"
      refute pt.purpose == en.purpose
      refute pt.requirements == en.requirements
    end
  end

  test "strict inputs reject personal data and internal date injection without echoing" do
    for args <- [
          nil,
          [],
          "private-marker",
          %{},
          %{service: "elar"},
          %{"service" => "private-marker"},
          %{"service" => "elar", "language" => "EN"},
          %{"service" => "elar", "language" => nil},
          %{"service" => "elar", "nif" => "private-marker"},
          %{"service" => "elar", "today" => "2026-01-01"},
          %{"service" => "elar", "channel" => "portal"}
        ] do
      assert {:error, error} = PublicSupport.guide(args)
      refute inspect(error) =~ "private-marker"
    end

    assert {:error, %{input: english}} =
             PublicSupport.guide(%{"service" => "bad", "language" => "en"})

    assert english =~ "Do not send personal data"
  end

  test "published deadlines include the date and expire the following day in both languages" do
    for {service, action, deadline} <- [
          {"gondomar_housing", "new_application", ~D[2026-11-30]},
          {"elar", "supplier_payment_request", ~D[2026-11-30]},
          {"vale_efficiency", "existing_beneficiary_expression_of_interest", ~D[2027-01-25]}
        ],
        language <- ["pt", "en"] do
      args = %{"service" => service, "language" => language}

      for day <- [Date.add(deadline, -1), deadline] do
        {:ok, result} = PublicSupport.guide(args, day)
        assert phase(result, action).status == "within_published_deadline"
      end

      {:ok, expired} = PublicSupport.guide(args, Date.add(deadline, 1))
      assert phase(expired, action).status == "published_deadline_passed"
      assert phase(expired, action).published_deadline == Date.to_iso8601(deadline)

      assert phase(expired, action).guidance =~
               if(language == "en", do: "deadline has passed", else: "prazo publicado terminou")

      refute phase(expired, action).guidance =~ "Within the published deadline"
      refute phase(expired, action).guidance =~ "Dentro do prazo publicado"
    end
  end

  test "new applications are distinct from ongoing beneficiary and supplier actions" do
    {:ok, vale} = PublicSupport.guide(%{"service" => "vale_efficiency"}, @today)
    assert phase(vale, "new_application").status == "closed_to_new_beneficiaries"

    assert phase(vale, "existing_beneficiary_expression_of_interest").status ==
             "within_published_deadline"

    {:ok, elar} = PublicSupport.guide(%{"service" => "elar"}, @today)
    assert phase(elar, "new_application").status == "closed_to_new_applications"
    assert phase(elar, "supplier_payment_request").status == "within_published_deadline"
    {:ok, green} = PublicSupport.guide(%{"service" => "green_mobility"}, @today)
    assert phase(green, "new_application").status == "published_deadline_passed"

    assert phase(green, "existing_application_follow_up").status ==
             "official_portal_check_required"
  end

  test "snapshot cannot assert availability before its evidence" do
    {:ok, result} = PublicSupport.guide(%{"service" => "gondomar_housing"}, ~D[2026-11-02])
    assert phase(result, "new_application").status == "unknown_before_evidence"
    assert phase(result, "new_application").evidence_on == "2026-11-03"
  end

  test "important programme distinctions survive localization" do
    {:ok, young} =
      PublicSupport.guide(%{"service" => "porta65_young", "language" => "en"}, @today)

    assert young.navigation =~ "Applying without a contract"
    assert young.navigation =~ "payment"
    {:ok, plus} = PublicSupport.guide(%{"service" => "porta65_plus", "language" => "en"}, @today)
    assert plus.audience =~ "greater than 20%"
    assert plus.audience =~ "regardless of age"

    {:ok, gondomar} =
      PublicSupport.guide(%{"service" => "gondomar_housing", "language" => "en"}, @today)

    assert gondomar.navigation =~ "separate from the municipal rental housing"

    {:ok, fund} =
      PublicSupport.guide(%{"service" => "environmental_fund", "language" => "en"}, @today)

    assert fund.navigation =~ "does not mean all funds are closed"
    assert fund.requirements =~ "stale information"
  end

  defp phase(result, action), do: Enum.find(result.application_phases, &(&1.action == action))
end
