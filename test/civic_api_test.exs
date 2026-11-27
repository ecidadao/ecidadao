defmodule EcidadaoWeb.CivicAPITest do
  use ExUnit.Case, async: true
  import Plug.Test
  import Plug.Conn
  alias EcidadaoWeb.Endpoint

  defp post(path, args) do
    conn(:post, path, Jason.encode!(args))
    |> put_req_header("content-type", "application/json")
    |> put_req_header("accept", "application/json")
    |> Endpoint.call(Endpoint.init([]))
  end

  defp tool(name, args) do
    response =
      post("/mcp/public", %{
        "jsonrpc" => "2.0",
        "id" => 1,
        "method" => "tools/call",
        "params" => %{"name" => name, "arguments" => args}
      })

    assert response.status == 200
    Jason.decode!(response.resp_body)["result"]
  end

  test "municipal HTTP and MCP search return useful official destinations without availability claims" do
    args = %{"municipality" => "gondomar", "query" => "water tariff", "language" => "en"}
    response = post("/api/municipal/services", args)
    assert response.status == 200
    data = Jason.decode!(response.resp_body)
    assert data["total"] > 0
    assert data["submitted"] == false
    assert data["availability_checked"] == false
    assert Enum.all?(data["results"], &String.starts_with?(&1["official_url"], "https://"))
    result = tool("municipal_service_search", args)
    assert result["structuredContent"] == data
    assert hd(result["content"])["text"] =~ hd(data["results"])["official_url"]
  end

  test "all support guides work through public MCP in both languages" do
    for service <- Ecidadao.PublicSupport.services(), language <- ["pt", "en"] do
      result = tool("public_support_guidance", %{"service" => service, "language" => language})
      refute result["isError"]
      assert result["structuredContent"]["status"] == "guidance_only"
      assert result["structuredContent"]["language"] == language
      assert result["structuredContent"]["submitted"] == false
      assert result["structuredContent"]["remaining_budget"] == nil
    end
  end

  test "new public capabilities reject unexpected personal fields without reflection" do
    marker = "private-field-must-not-echo"

    for {name, args} <- [
          {"municipal_service_search", %{"email" => marker}},
          {"municipal_appointment_availability", %{"nif" => marker}},
          {"public_support_guidance", %{"service" => "porta65_young", "income" => marker}}
        ] do
      result = tool(name, args)
      assert result["isError"]
      refute Jason.encode!(result) =~ marker
    end

    response = post("/api/municipal/appointments", %{"municipality" => "maia"})
    assert response.status == 422
    data = Jason.decode!(response.resp_body)
    assert data["status"] == "error"
    assert data["reserved"] == false
    refute data["error"] == "no_availability"
  end

  test "new tool schemas expose read-only limited inputs and external lookup accurately" do
    names =
      ~w(municipal_service_search municipal_appointment_availability public_support_guidance)

    for tool <- Ecidadao.MCP.tools(), tool.name in names do
      assert tool.inputSchema.additionalProperties == false
      assert tool.annotations.readOnlyHint
      assert tool.annotations.destructiveHint == false
      assert tool.annotations.openWorldHint == (tool.name == "municipal_appointment_availability")
    end
  end
end
