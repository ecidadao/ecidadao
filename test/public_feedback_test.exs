defmodule Ecidadao.PublicFeedbackTest do
  use ExUnit.Case, async: true
  import Plug.Test
  import Plug.Conn
  alias Ecidadao.PublicFeedback

  @valid %{
    "type" => "complaint",
    "organisation" => " Câmara Municipal ",
    "subject" => " Atendimento ",
    "description" => " Factos observados. "
  }
  @limits %{
    "organisation" => 200,
    "location" => 200,
    "subject" => 200,
    "description" => 5000,
    "requested_resolution" => 1500
  }

  test "all three types map to distinct official services and accurate draft labels" do
    assert PublicFeedback.types() == ~w(complaint compliment suggestion)

    for {type, label, path, resolution} <- [
          {"complaint", "Reclamação", "fazer-reclamacao-de-um-servico-publico",
           "Resultado pretendido"},
          {"compliment", "Elogio", "fazer-elogio-a-um-servico-publico",
           "Reconhecimento pretendido"},
          {"suggestion", "Sugestão", "fazer-sugestao-a-um-servico-publico", "Melhoria pretendida"}
        ] do
      input =
        Map.merge(@valid, %{
          "type" => type,
          "requested_resolution" => "Proposta",
          "incident_date" => "2024-02-29",
          "location" => "Balcão central"
        })

      assert {:ok, result} = PublicFeedback.prepare(input)
      assert result.type == type
      assert result.official_portal == "https://www.gov.pt/servicos/" <> path
      assert result.status == "rascunho_nao_submetido"
      assert result.authentication_required
      assert result.draft =~ "Tipo: #{label}"
      assert result.draft =~ "#{resolution}: Proposta"
      assert result.draft =~ "Data: 2024-02-29"
      assert result.draft =~ "Local de atendimento: Balcão central"
      assert result.draft =~ "NÃO SUBMETIDO"
      assert result.fields["organisation"] == "Câmara Municipal"
      assert result.next_step =~ "identificação apenas no portal oficial"
      refute Map.has_key?(result, :receipt)
    end
  end

  test "required fields and unsupported feedback types are rejected" do
    for field <- ~w(type organisation subject description), value <- [nil, "", "  "] do
      assert {:error, errors} = PublicFeedback.prepare(Map.put(@valid, field, value))
      assert Enum.any?(errors, &(&1.field == field))
    end

    for type <- ["consumer", "COMPLAINT", "unknown", 1, [], %{}] do
      assert {:error, errors} = PublicFeedback.prepare(Map.put(@valid, "type", type))
      assert Enum.any?(errors, &(&1.field == "type"))
    end
  end

  test "malformed fields including optional fields are never silently accepted" do
    for field <- Map.keys(@limits) ++ ["incident_date"],
        value <- [true, 12, 1.5, [], %{}, <<255>>] do
      assert {:error, errors} = PublicFeedback.prepare(Map.put(@valid, field, value))
      assert Enum.any?(errors, &(&1.field == field))
      assert Jason.encode!(errors)
    end

    for input <- [nil, false, [], "text", 123] do
      assert {:error, [%{field: "input"}]} = PublicFeedback.prepare(input)
    end

    assert {:error, _} = PublicFeedback.prepare(~D[2026-11-26])
  end

  test "text bounds allow the exact limit and reject oversize values without echoing them" do
    for {field, limit} <- @limits do
      assert {:ok, _} =
               PublicFeedback.prepare(Map.put(@valid, field, String.duplicate("á", limit)))

      oversized = String.duplicate("á", limit + 1)
      assert {:error, errors} = PublicFeedback.prepare(Map.put(@valid, field, oversized))
      assert Enum.any?(errors, &(&1.field == field))
      refute Jason.encode!(errors) =~ oversized
    end
  end

  test "dates are optional but nonempty dates must be real and use the exact format" do
    for date <- [nil, "", "  ", "2024-02-29", " 2026-11-26 "] do
      assert {:ok, _} = PublicFeedback.prepare(Map.put(@valid, "incident_date", date))
    end

    for date <- [
          "2026-02-29",
          "2026-02-30",
          "2026-13-01",
          "26/11/2026",
          "2026-1-01",
          "2026-11-26T12:00:00Z",
          "-0001-01-01"
        ] do
      assert {:error, errors} = PublicFeedback.prepare(Map.put(@valid, "incident_date", date))
      assert Enum.any?(errors, &(&1.field == "incident_date"))
    end

    assert {:ok, result} = PublicFeedback.prepare(@valid)
    refute result.draft =~ "Data:"
    refute result.draft =~ "Local de atendimento:"
    refute result.draft =~ "Resultado pretendido:"
  end

  test "unknown identity fields are discarded from successful responses and errors" do
    input =
      Map.merge(@valid, %{
        "nif" => "SECRET-NIF",
        "name" => "SECRET-NAME",
        "credentials" => %{"password" => "SECRET-PASSWORD"},
        "email" => "SECRET-EMAIL"
      })

    assert {:ok, result} = PublicFeedback.prepare(input)

    assert Map.keys(result.fields) |> Enum.sort() ==
             ~w(description incident_date location organisation requested_resolution subject)

    refute Jason.encode!(result) =~ "SECRET"
    assert {:error, errors} = PublicFeedback.prepare(Map.put(input, "subject", ""))
    refute Jason.encode!(errors) =~ "SECRET"
  end

  test "HTTP preparation returns uncached JSON drafts or validation errors" do
    for {input, status} <- [{@valid, 200}, {%{}, 422}, {Map.put(@valid, "location", []), 422}] do
      conn =
        conn(:post, "/api/public-feedback/prepare", Jason.encode!(input))
        |> put_req_header("content-type", "application/json")
        |> EcidadaoWeb.Endpoint.call([])

      assert conn.status == status
      assert get_resp_header(conn, "cache-control") == ["no-store"]
      assert hd(get_resp_header(conn, "content-type")) =~ "application/json"
      body = Jason.decode!(conn.resp_body)

      if status == 200,
        do: assert(body["status"] == "rascunho_nao_submetido"),
        else: assert(is_list(body["errors"]))
    end
  end
end
