defmodule EcidadaoWeb.MunicipalMapPage do
  @moduledoc false

  def render(locale) do
    locale = if locale == "en", do: "en", else: "pt"
    c = copy(locale)

    EcidadaoWeb.Page.civic_layout(
      """
      <link rel="stylesheet" href="/map-assets/leaflet.css" integrity="sha256-p4NxAoJBhIIN+hmNHrzRCf9tD/miZyoHS5obTRR9BMY=">
      <link rel="stylesheet" href="/map-assets/municipal-map.css">
      <section class="hero coverage-hero">
        <p class="eyebrow">#{c.eyebrow}</p><h1>#{c.title}</h1>
        <p class="lead">#{c.intro}</p>
      </section>
      <section id="coverage" aria-labelledby="coverage-heading">
        <h2 id="coverage-heading">#{c.heading}</h2>
        <div class="form-actions"><button type="button" id="coverage-refresh">#{c.refresh}</button>
          <button type="button" id="coverage-locate" class="secondary">#{c.locate}</button>
          <button type="button" id="coverage-portugal" class="secondary">#{c.portugal}</button></div>
        <p id="coverage-status" role="status" aria-live="polite">#{c.loading}</p>
        <p id="coverage-error" role="alert" hidden></p>
        <p id="coverage-location" role="status" aria-live="polite"></p>
        <div class="coverage-layout">
          <div><div id="coverage-map" aria-label="#{c.mapLabel}"></div>
            <p id="coverage-map-error" role="status" hidden>#{c.mapError}</p>
            <ul class="coverage-legend" aria-label="#{c.legend}">
              <li><span class="coverage-dot" aria-hidden="true"></span>#{c.catalogue}</li>
              <li><span class="coverage-dot coverage-dot-availability" aria-hidden="true"></span>#{c.availability}</li>
            </ul><p class="help-note">#{c.centres}</p>
            <p class="help-note">#{c.tiles} <a href="https://www.openstreetmap.org/copyright">© OpenStreetMap contributors</a> · <a href="https://www.openstreetmap.org/fixthemap">#{c.mapIssue}</a></p>
          </div>
          <div><h3>#{c.list}</h3><ul id="coverage-list" class="coverage-list">
              <li><a href="/municipios">Gondomar — #{c.catalogue}</a></li>
              <li><a href="/municipios">Maia — #{c.catalogue}</a></li>
              <li><a href="/municipios">Ponte de Lima — #{c.catalogue}</a> · <a href="/vagas">#{c.appointment}</a></li>
            </ul>
            <article id="coverage-detail" class="card" hidden aria-labelledby="coverage-selected"></article></div>
        </div>
        <p class="notice">#{c.scope}</p>
        <p class="help-note">#{c.privacy}</p>
        <p id="coverage-metadata" hidden></p><p id="coverage-notice"></p>
        <noscript><p>#{c.nojs} <a href="/municipios">#{c.catalogue}</a> · <a href="/vagas">#{c.availability}</a> · <a href="/apoios">#{c.support}</a></p></noscript>
      </section>
      <section class="card" aria-labelledby="coverage-national-title"><h2 id="coverage-national-title">#{c.national}</h2>
        <p>#{c.nationalNote}</p><ul id="coverage-national" class="report-list"></ul></section>
      <script type="application/json" id="coverage-copy">#{Jason.encode!(Map.put(c, :language, locale))}</script>
      <script src="/map-assets/leaflet.js" integrity="sha256-hdRVtFIkFfa63EKg59F8kZ0QA0fWuJWL0Nxzj97NbVA=" defer></script>
      <script src="/map-assets/municipal-map.js" defer></script>
      """,
      locale
    )
  end

  defp copy("en") do
    %{
      eyebrow: "Municipal coverage",
      title: "See where eCidadão can help.",
      intro:
        "Choose a municipality to find services, appointment options and support programmes.",
      scope: "Only the listed municipalities are covered. Complete requests on official portals.",
      heading: "Current coverage",
      refresh: "Refresh coverage",
      locate: "Use my location",
      portugal: "View Portugal and islands",
      privacy:
        "Location is optional and stays in this page, without storage or transmission. It only calculates the nearest covered municipality; the map does not move to your position.",
      loading: "Loading coverage…",
      mapLabel: "Interactive map of municipal coverage",
      mapError: "The background map is unavailable. You can still use the municipality list.",
      legend: "Map legend",
      catalogue: "Service catalogue",
      availability: "Catalogue + appointment availability lookup",
      centres:
        "Markers indicate approximate municipal centres, not service counters. Pan or use +/− to zoom; the list provides the same choices.",
      tiles: "Map background supplied by",
      mapIssue: "Report a map issue",
      list: "Covered municipalities",
      nojs: "Enable JavaScript to view the map, or explore:",
      support: "Support programmes",
      national: "National capabilities",
      nationalNote:
        "These are separate from municipal coverage. Guidance does not provide access to personal accounts.",
      error: "Coverage could not be updated. Try refreshing again.",
      stale: "The previous coverage remains visible; it has not been refreshed.",
      count: "municipalities covered",
      services: "catalogue entries",
      tools: "Available MCP tools",
      limits: "Coverage and limits",
      sources: "Official sources",
      generated: "Coverage generated",
      verified: "Catalogue sources verified",
      snapshotNote: "This is the coverage snapshot, not a live check of appointment times.",
      appointment: "Check appointment times in Ponte de Lima ↗",
      locating: "Finding the nearest covered municipality…",
      unsupported: "This browser does not support location. Use the municipality list.",
      denied: "Location was not allowed. You can still use the map and list.",
      geoError: "Location could not be obtained in time. Try again or use the list.",
      nearest: "Nearest covered municipality",
      distance: "km in a straight line to the approximate municipal centre; not travel distance.",
      localOnly: "Your position has not been sent or saved.",
      pending: "Location obtained locally. Distance will appear when coverage is available.",
      select: "View services"
    }
  end

  defp copy(_) do
    %{
      eyebrow: "Cobertura municipal",
      title: "Veja onde o eCidadão pode ajudar.",
      intro: "Escolha um município para encontrar serviços, opções de atendimento e apoios.",
      scope: "Apenas os municípios listados têm cobertura. Conclua pedidos nos portais oficiais.",
      heading: "Cobertura atual",
      refresh: "Atualizar cobertura",
      locate: "Usar minha localização",
      portugal: "Ver Portugal e ilhas",
      privacy:
        "A localização é opcional e fica nesta página, sem ser guardada ou enviada. Serve apenas para calcular o município coberto mais próximo; o mapa não se desloca para a sua posição.",
      loading: "A carregar cobertura…",
      mapLabel: "Mapa interativo da cobertura municipal",
      mapError: "O mapa de fundo está indisponível. Pode continuar a usar a lista de municípios.",
      legend: "Legenda do mapa",
      catalogue: "Catálogo de serviços",
      availability: "Catálogo + consulta de vagas de atendimento",
      centres:
        "Os marcadores indicam centros municipais aproximados, não balcões de atendimento. Arraste ou use +/− para ampliar; a lista oferece as mesmas escolhas.",
      tiles: "Mapa de fundo fornecido por",
      mapIssue: "Reportar problema no mapa",
      list: "Municípios cobertos",
      nojs: "Ative o JavaScript para ver o mapa ou explore:",
      support: "Apoios",
      national: "Capacidades nacionais",
      nationalNote:
        "São independentes da cobertura municipal. A orientação não dá acesso a contas pessoais.",
      error: "Não foi possível atualizar a cobertura. Tente atualizar novamente.",
      stale: "A cobertura anterior continua visível; não foi atualizada.",
      count: "municípios cobertos",
      services: "entradas de catálogo",
      tools: "Ferramentas MCP disponíveis",
      limits: "Cobertura e limites",
      sources: "Fontes oficiais",
      generated: "Cobertura gerada em",
      verified: "Fontes do catálogo verificadas em",
      snapshotNote:
        "Esta é a cobertura dos serviços, não uma consulta em tempo real dos horários disponíveis.",
      appointment: "Consultar horários em Ponte de Lima ↗",
      locating: "A procurar o município coberto mais próximo…",
      unsupported: "Este navegador não suporta localização. Utilize a lista de municípios.",
      denied: "A localização não foi permitida. Pode continuar a usar o mapa e a lista.",
      geoError:
        "Não foi possível obter a localização a tempo. Tente novamente ou utilize a lista.",
      nearest: "Município coberto mais próximo",
      distance: "km em linha reta até ao centro municipal aproximado; não é distância de viagem.",
      localOnly: "A sua posição não foi enviada nem guardada.",
      pending:
        "Localização obtida neste dispositivo. A distância aparece quando a cobertura estiver disponível.",
      select: "Ver serviços"
    }
  end
end
