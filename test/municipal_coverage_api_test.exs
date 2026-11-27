defmodule EcidadaoWeb.MunicipalCoverageAPITest do
  use ExUnit.Case, async: true
  import Plug.Test
  alias EcidadaoWeb.Endpoint

  test "coverage API is translated, current and consistent with the catalogue" do
    for locale <- ["pt", "en"] do
      response =
        conn(:get, "/api/municipal/coverage?lang=#{locale}") |> Endpoint.call(Endpoint.init([]))

      assert response.status == 200
      assert Plug.Conn.get_resp_header(response, "cache-control") == ["no-store"]
      data = Jason.decode!(response.resp_body)
      assert data["language"] == locale
      assert data["municipality_count"] == 3

      assert data["total_service_count"] ==
               Enum.sum(Enum.map(data["municipalities"], & &1["service_count"]))

      assert {:ok, _, _} = DateTime.from_iso8601(data["generated_at"])

      assert Enum.filter(data["municipalities"], & &1["availability_lookup"])
             |> Enum.map(& &1["id"]) == ["ponte_de_lima"]
    end
  end

  test "map uses shared locale layout and local library assets" do
    for locale <- ["pt", "en"] do
      page = conn(:get, "/mapa?lang=#{locale}") |> Endpoint.call(Endpoint.init([]))
      home = conn(:get, "/?lang=#{locale}") |> Endpoint.call(Endpoint.init([]))
      assert page.status == 200
      assert home.status == 200
      assert home.resp_body =~ "/map-assets/leaflet.js"
      refute home.resp_body =~ ~s(class="landing-hero")
      assert page.resp_body =~ ~s(<html lang="#{locale}">)
      assert page.resp_body =~ "/map-assets/leaflet.js"
      assert page.resp_body =~ "prefers-color-scheme:dark"
    end
  end
end
