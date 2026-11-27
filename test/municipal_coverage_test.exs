defmodule Ecidadao.MunicipalCoverageTest do
  use ExUnit.Case, async: true
  alias Ecidadao.{MunicipalCoverage, MunicipalDirectory, PublicSupport}

  test "agreed flattened frontend contract matches the detailed metadata in both languages" do
    for locale <- ["pt", "en"] do
      coverage = MunicipalCoverage.snapshot(locale)
      assert coverage.municipality_count == coverage.totals.municipality_count
      assert coverage.total_service_count == coverage.totals.service_count

      for entry <- coverage.municipalities do
        assert entry.code == entry.administrative_code
        assert entry.latitude == entry.center.latitude
        assert entry.longitude == entry.center.longitude
        assert entry.availability_lookup == (entry.id == "ponte_de_lima")
        assert is_binary(entry.coverage)
        assert length(entry.limitations) > 0
        assert entry.links == Enum.map(entry.capabilities, &%{label: &1.label, url: &1.path})

        for source <- entry.sources do
          assert is_binary(source.label)
          uri = URI.parse(source.url)
          assert uri.scheme == "https"

          assert uri.host in ~w(servicosonline.cm-gondomar.pt diretorio.cm-maia.pt www.cm-pontedelima.pt ogcapi.dgterritorio.gov.pt)

          assert uri.userinfo == nil
        end
      end

      assert length(coverage.national_capabilities) == 4

      for {capability, detail} <-
            Enum.zip(coverage.national_capabilities, coverage.national_services) do
        assert capability.id == detail.scope
        assert capability.title == detail.label
        assert capability.tools == [detail.tool]
        assert capability.url == detail.path
        assert is_binary(capability.description)
      end
    end
  end

  test "coverage and counts track the actual catalogue without national inflation" do
    coverage = MunicipalCoverage.snapshot()
    assert Enum.map(coverage.municipalities, & &1.id) == ~w(gondomar maia ponte_de_lima)

    for entry <- coverage.municipalities do
      {:ok, catalogue} = MunicipalDirectory.search(%{"municipality" => entry.id, "limit" => 1})
      assert entry.service_count == catalogue.total
      assert entry.verified_on == catalogue.verified_on
      assert entry.source == catalogue.sources[entry.id]
      assert "municipal_service_search" in entry.tools
      assert entry.tools == Enum.map(entry.capabilities, & &1.tool)
    end

    assert coverage.totals.municipality_count == 3

    assert coverage.totals.service_count ==
             Enum.sum(Enum.map(coverage.municipalities, & &1.service_count))

    {:ok, all} = MunicipalDirectory.search(%{})
    assert coverage.totals.service_count == all.total

    national_support =
      Enum.find(coverage.national_services, &(&1.tool == "public_support_guidance"))

    assert national_support.services == PublicSupport.services() -- ["gondomar_housing"]
    assert Enum.all?(coverage.national_services, &(&1.status == "guidance"))

    {:reply, response} =
      Ecidadao.MCP.public_handle(%{"jsonrpc" => "2.0", "method" => "tools/list", "id" => 1})

    public_tools = Enum.map(response.result.tools, & &1.name)

    capabilities =
      coverage.national_services ++ Enum.flat_map(coverage.municipalities, & &1.capabilities)

    assert Enum.all?(capabilities, &(&1.tool in public_tools))
  end

  test "only Ponte has live lookup capability and there are no current slot or booking claims" do
    coverage = MunicipalCoverage.snapshot()

    live =
      Enum.filter(
        coverage.municipalities,
        &Enum.any?(&1.capabilities, fn c -> c.status == "live_lookup" end)
      )

    assert Enum.map(live, & &1.id) == ["ponte_de_lima"]
    assert coverage.totals.live_lookup_municipality_count == 1
    refute coverage.availability_checked
    refute coverage.submitted

    for entry <- coverage.municipalities do
      refute entry.availability_checked
      assert entry.status == "catalogue"
      refute Map.has_key?(entry, :slots)
      refute Map.has_key?(entry, :reserved)
      assert "municipal_appointment_availability" in entry.tools == (entry.id == "ponte_de_lima")
      assert entry.paths.appointments != nil == (entry.id == "ponte_de_lima")
      assert entry.paths.support != nil == (entry.id == "gondomar")
    end

    gondomar = hd(coverage.municipalities)

    assert Enum.find(gondomar.capabilities, &(&1.tool == "public_support_guidance")).service ==
             "gondomar_housing"
  end

  test "localized copy and paths, stable revision and distinct generation dates serialize as JSON" do
    pt = MunicipalCoverage.snapshot("pt")
    en = MunicipalCoverage.snapshot("en")
    assert pt.language == "pt"
    assert en.language == "en"
    refute pt.labels == en.labels
    refute pt.notice == en.notice
    assert en.notice =~ "Missing coverage does not mean"
    assert pt.revision == en.revision
    assert {:ok, _, 0} = DateTime.from_iso8601(pt.generated_at)
    assert {:ok, _} = Date.from_iso8601(pt.verified_on)
    assert pt.reviewed_on == "2026-11-27"
    assert Jason.decode!(Jason.encode!(en))["totals"]["service_count"] == en.totals.service_count
    assert MunicipalCoverage.snapshot("invalid").language == "pt"

    for {snapshot, locale} <- [{pt, "pt"}, {en, "en"}],
        cap <-
          snapshot.national_services ++ Enum.flat_map(snapshot.municipalities, & &1.capabilities) do
      assert cap.path =~ "?lang=#{locale}"
      assert URI.parse(cap.path).path in ~w(/municipios /vagas /apoios /saude /financas /siga)
    end
  end

  test "public map centres have official provenance and administrative codes" do
    coverage = MunicipalCoverage.snapshot()
    assert Enum.map(coverage.municipalities, & &1.administrative_code) == ~w(1304 1306 1607)

    for entry <- coverage.municipalities do
      [west, south, east, north] = entry.coordinate_bbox
      assert_in_delta entry.center.latitude, (south + north) / 2, 0.000001
      assert_in_delta entry.center.longitude, (west + east) / 2, 0.000001
      assert entry.coordinate_method == "caop_geometry_bbox_midpoint"
      assert entry.coordinate_attribution == "Direção-Geral do Território"
      assert entry.coordinate_reviewed_on == "2026-11-27"

      for url <- [entry.source, entry.coordinate_source, entry.coordinate_license] do
        uri = URI.parse(url)
        assert uri.scheme == "https"

        assert uri.host in ~w(servicosonline.cm-gondomar.pt diretorio.cm-maia.pt www.cm-pontedelima.pt ogcapi.dgterritorio.gov.pt creativecommons.org)

        assert uri.userinfo == nil
        assert uri.port == 443
      end
    end

    refute Map.has_key?(coverage, :position)
    refute Map.has_key?(coverage, :user_location)
    refute Map.has_key?(coverage, :latitude)
  end
end
