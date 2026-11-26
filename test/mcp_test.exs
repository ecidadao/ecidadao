defmodule Ecidadao.MCPTest do
  use ExUnit.Case, async: true
  alias Ecidadao.MCP

  test "initializes and advertises complaint and street-report tools" do
    assert {:reply, %{result: init}} =
             MCP.handle(%{"jsonrpc" => "2.0", "id" => 1, "method" => "initialize"})

    assert init.protocolVersion == "2025-11-25"

    assert {:reply, %{result: %{tools: tools}}} =
             MCP.handle(%{"jsonrpc" => "2.0", "id" => 2, "method" => "tools/list"})

    assert Enum.map(tools, & &1.name) == [
             "open_report_camera",
             "preview_photo_report",
             "prepare_complaint",
             "official_submission_guidance",
             "prepare_street_report",
             "list_recent_street_reports",
             "siga_visit_guidance",
             "compare_siga_queues",
             "financas_service_guidance",
             "prepare_financas_ebalcao"
           ]
  end

  test "public plugin endpoint advertises only authorized draft and guidance tools" do
    assert {:reply, %{result: %{tools: tools}}} =
             MCP.public_handle(%{"jsonrpc" => "2.0", "id" => 1, "method" => "tools/list"})

    assert Enum.map(tools, & &1.name) == [
             "prepare_complaint",
             "official_submission_guidance",
             "prepare_street_report",
             "siga_visit_guidance",
             "financas_service_guidance",
             "prepare_financas_ebalcao"
           ]

    assert {:reply, %{error: %{code: -32602}}} =
             MCP.public_handle(%{
               "jsonrpc" => "2.0",
               "id" => 2,
               "method" => "tools/call",
               "params" => %{"name" => "compare_siga_queues", "arguments" => %{}}
             })
  end

  test "camera tool exposes a resource that asks for permissions only in the UI" do
    assert {:reply, %{result: %{resources: [resource]}}} =
             MCP.handle(%{"jsonrpc" => "2.0", "id" => 6, "method" => "resources/list"})

    assert resource.uri == "ui://ecidadao/capture.html"

    assert {:reply, %{result: %{contents: [content]}}} =
             MCP.handle(%{
               "jsonrpc" => "2.0",
               "id" => 7,
               "method" => "resources/read",
               "params" => %{"uri" => resource.uri}
             })

    assert content.mimeType == "text/html;profile=mcp-app"
    assert content._meta.ui.permissions == %{camera: %{}, geolocation: %{}}
    assert content.text =~ "Usar localização"
  end

  test "photo-first preview uses only a coarse location hint and requests confirmation" do
    request = %{
      "jsonrpc" => "2.0",
      "id" => 5,
      "method" => "tools/call",
      "params" => %{
        "name" => "preview_photo_report",
        "arguments" => %{
          "observations" => "Candeeiro de iluminação pública apagado.",
          "context_hint" => "street"
        },
        "_meta" => %{
          "openai/userLocation" => %{
            "city" => "Matosinhos",
            "country" => "PT",
            "latitude" => 41.18,
            "longitude" => -8.69
          }
        }
      }
    }

    assert {:reply, %{result: result}} = MCP.handle(request)
    preview = result.structuredContent
    assert preview.suggested_channel == "A Minha Rua"
    assert preview.location_hint == "Matosinhos, PT"
    assert preview.location_confirmed == false
    assert preview.draft =~ "Local exato: por confirmar"
    refute Jason.encode!(preview) =~ "41.18"
  end

  test "returns a draft without claiming submission" do
    request = %{
      "jsonrpc" => "2.0",
      "id" => 3,
      "method" => "tools/call",
      "params" => %{
        "name" => "prepare_complaint",
        "arguments" => %{
          "business_name" => "Loja",
          "description" => "Produto avariado",
          "requested_resolution" => "Troca"
        }
      }
    }

    assert {:reply, %{result: result}} = MCP.handle(request)
    assert result.structuredContent.status == "rascunho_nao_submetido"
    assert result.content |> hd() |> Map.fetch!(:text) =~ "AINDA NÃO SUBMETIDO"
  end

  test "prepares a street report without claiming it was sent" do
    request = %{
      "jsonrpc" => "2.0",
      "id" => 4,
      "method" => "tools/call",
      "params" => %{
        "name" => "prepare_street_report",
        "arguments" => %{
          "district" => "Porto",
          "municipality" => "Matosinhos",
          "parish" => "Matosinhos e Leça da Palmeira",
          "address" => "Rua Exemplo",
          "category" => "Conservação da Iluminação Pública",
          "subject" => "Candeeiro apagado",
          "description" => "O candeeiro junto à escola está apagado há uma semana."
        }
      }
    }

    assert {:reply, %{result: result}} = MCP.handle(request)
    assert result.structuredContent.status == "rascunho_nao_submetido"
    assert result.structuredContent.official_portal =~ "situationReport.aspx"
    assert result.content |> hd() |> Map.fetch!(:text) =~ "NÃO SUBMETIDO"
  end
end
