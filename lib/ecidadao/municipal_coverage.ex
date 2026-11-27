defmodule Ecidadao.MunicipalCoverage do
  @moduledoc """
  Public coverage of existing MCP capabilities, without network reads or user position.
  Map centres are derived from official CAOP geometry, not addresses or property points.
  `live_lookup` describes an available integration, never current appointment slots.
  """
  @coordinates Path.expand("../../priv/municipal_coverage.json", __DIR__)
  @catalogue Path.expand("../../priv/municipal_services.json", __DIR__)
  @support Path.expand("../../priv/public_support.json", __DIR__)
  @external_resource @coordinates
  @external_resource @catalogue
  @external_resource @support
  @municipalities @coordinates |> File.read!() |> Jason.decode!(keys: :atoms)
  @reviewed_on "2026-11-27"
  @revision "coverage-v2-2026-11-27-" <>
              (:crypto.hash(
                 :sha256,
                 File.read!(@coordinates) <> File.read!(@catalogue) <> File.read!(@support)
               )
               |> Base.encode16(case: :lower)
               |> binary_part(0, 12))

  @spec snapshot(String.t()) :: map()
  def snapshot(locale \\ "pt")
  def snapshot(locale) when locale not in ["pt", "en"], do: snapshot("pt")

  def snapshot(locale) do
    municipalities = Enum.map(@municipalities, &municipality(&1, locale))
    total_service_count = Enum.sum(Enum.map(municipalities, & &1.service_count))
    national = national_services(locale)

    %{
      schema_version: 1,
      revision: @revision,
      generated_at: DateTime.utc_now() |> DateTime.truncate(:second) |> DateTime.to_iso8601(),
      reviewed_on: @reviewed_on,
      verified_on: municipalities |> Enum.map(& &1.verified_on) |> Enum.min(),
      language: locale,
      status: "coverage_snapshot",
      availability_checked: false,
      submitted: false,
      municipalities: municipalities,
      municipality_count: length(municipalities),
      total_service_count: total_service_count,
      national_capabilities:
        Enum.map(national, fn capability ->
          %{
            id: capability.scope,
            title: capability.label,
            description:
              text(
                "Orientação nacional; não representa acesso a serviços municipais nem submissão de pedidos.",
                "National guidance; does not represent municipal service access or submission of requests.",
                locale
              ),
            tools: [capability.tool],
            url: capability.path
          }
        end),
      totals: %{
        municipality_count: length(municipalities),
        service_count: total_service_count,
        live_lookup_municipality_count:
          Enum.count(
            municipalities,
            &Enum.any?(&1.capabilities, fn c -> c.status == "live_lookup" end)
          )
      },
      national_services: national,
      labels: %{
        title: text("Cobertura municipal", "Municipal coverage", locale),
        catalogue: text("Catálogo de serviços", "Service catalogue", locale),
        live_lookup:
          text("Consulta de horários disponível", "Appointment lookup supported", locale),
        guidance: text("Orientação", "Guidance", locale),
        national_services: text("Percursos nacionais", "National services", locale)
      },
      notice:
        text(
          "Este mapa mostra as integrações do eCidadão. A ausência de cobertura não significa ausência de serviços no município. Os catálogos são datados; a consulta de horários é uma capacidade, não uma indicação de vagas atuais. Nenhum pedido foi submetido.",
          "This map shows eCidadão integrations. Missing coverage does not mean a municipality has no services. Catalogues are dated; appointment lookup is a capability, not an indication of current slots. Nothing has been submitted.",
          locale
        )
    }
  end

  defp municipality(entry, locale) do
    {:ok, catalogue} =
      Ecidadao.MunicipalDirectory.search(%{
        "municipality" => entry.id,
        "language" => locale,
        "limit" => 1
      })

    search =
      capability(
        "municipal_service_search",
        "catalogue",
        "municipal_catalogue",
        text("Pesquisar serviços municipais", "Search municipal services", locale),
        "/municipios",
        locale
      )

    extra =
      case entry.id do
        "ponte_de_lima" ->
          [
            capability(
              "municipal_appointment_availability",
              "live_lookup",
              "public_in_person_appointments",
              text("Consultar horários de atendimento", "Look up appointment times", locale),
              "/vagas",
              locale
            )
          ]

        "gondomar" ->
          [
            capability(
              "public_support_guidance",
              "guidance",
              "municipal_support",
              text("Orientação +Habitação", "+Habitação guidance", locale),
              "/apoios",
              locale
            )
            |> Map.put(:service, "gondomar_housing")
          ]

        _ ->
          []
      end

    capabilities = [search | extra]

    Map.merge(entry, %{
      code: entry.administrative_code,
      latitude: entry.center.latitude,
      longitude: entry.center.longitude,
      availability_lookup: Enum.any?(capabilities, &(&1.status == "live_lookup")),
      coverage: text("Catálogo municipal integrado", "Municipal catalogue integrated", locale),
      limitations: [
        text(
          "Catálogo datado; não verifica processos nem disponibilidade atual.",
          "Dated catalogue; does not check case status or current availability.",
          locale
        ),
        text(
          "Marcador aproximado calculado a partir dos limites municipais oficiais.",
          "Approximate marker calculated from official municipal boundaries.",
          locale
        )
      ],
      links: Enum.map(capabilities, &%{label: &1.label, url: &1.path}),
      sources: [
        %{
          label: text("Catálogo municipal oficial", "Official municipal catalogue", locale),
          url:
            if(entry.id == "gondomar",
              do: "https://servicosonline.cm-gondomar.pt/",
              else: catalogue.sources[entry.id]
            )
        },
        %{label: "DGT — CAOP2025", url: entry.coordinate_source}
      ],
      service_count: catalogue.total,
      verified_on: catalogue.verified_on,
      reviewed_on: @reviewed_on,
      source: catalogue.sources[entry.id],
      status: "catalogue",
      availability_checked: false,
      capabilities: capabilities,
      tools: Enum.map(capabilities, & &1.tool),
      paths: %{
        catalogue: search.path,
        appointments: path_for(extra, "live_lookup"),
        support: path_for(extra, "guidance")
      }
    })
  end

  defp national_services(locale) do
    [
      capability(
        "public_support_guidance",
        "guidance",
        "national_support",
        text("Apoios nacionais", "National support", locale),
        "/apoios",
        locale
      )
      |> Map.put(
        :services,
        Enum.reject(Ecidadao.PublicSupport.services(), &(&1 == "gondomar_housing"))
      ),
      capability(
        "sns24_service_guidance",
        "guidance",
        "national_health",
        text("Serviços SNS 24", "SNS 24 services", locale),
        "/saude",
        locale
      ),
      capability(
        "financas_service_guidance",
        "guidance",
        "national_tax",
        text("Serviços das Finanças", "Tax services", locale),
        "/financas",
        locale
      ),
      capability(
        "siga_visit_guidance",
        "guidance",
        "national_public_service_visits",
        text("Atendimento SIGA", "SIGA public service visits", locale),
        "/siga",
        locale
      )
    ]
  end

  defp capability(tool, status, scope, label, path, locale),
    do: %{
      tool: tool,
      status: status,
      scope: scope,
      label: label,
      path: path <> "?lang=" <> locale
    }

  defp path_for(capabilities, status) do
    case Enum.find(capabilities, &(&1.status == status)) do
      nil -> nil
      capability -> capability.path
    end
  end

  defp text(_pt, en, "en"), do: en
  defp text(pt, _en, _), do: pt
end
