defmodule EcidadaoWeb.CivicPage do
  @moduledoc false

  def municipalities(locale \\ "pt") do
    {:ok, data} = Ecidadao.MunicipalDirectory.search(%{"language" => locale})

    copy = %{
      language: locale,
      found: c("serviços encontrados", "services found", locale),
      shown: c("apresentados", "shown", locale),
      empty:
        c(
          "Não encontrámos serviços. Experimente outro assunto ou município.",
          "No services found. Try another subject or municipality.",
          locale
        ),
      error:
        c(
          "Não foi possível pesquisar. Tente novamente.",
          "Search could not be completed. Please try again.",
          locale
        ),
      loading: c("A pesquisar…", "Searching…", locale),
      open: c("Abrir serviço oficial ↗", "Open official service ↗", locale),
      source: c("Fonte oficial", "Official source", locale),
      verified: c("Fonte consultada em", "Source checked on", locale)
    }

    body = """
    #{styles()}
    <section class="hero"><p class="eyebrow">Gondomar · Maia · Ponte de Lima</p>
    <h1>#{c("Serviços do seu município", "Services in your municipality", locale)}</h1>
    <p class="lead">#{c("Encontre o serviço e continue no portal municipal.", "Find the service and continue on the municipal portal.", locale)}</p>
    <p class="notice">#{h(data.notice)}</p></section>
    <section class="card" aria-labelledby="municipal-search-title">
    <h2 id="municipal-search-title">#{c("O que precisa de resolver?", "What do you need help with?", locale)}</h2>
    <form id="municipal-form" hidden>
      <div class="grid"><label for="municipality">#{c("Município", "Municipality", locale)}<select id="municipality" name="municipality">
      <option value="all">#{c("Todos", "All", locale)}</option><option value="gondomar">Gondomar</option><option value="maia">Maia</option><option value="ponte_de_lima">Ponte de Lima</option></select></label>
      <label for="municipal-query">#{c("Assunto", "Subject", locale)}<input type="search" id="municipal-query" name="query" maxlength="160" autocomplete="off" aria-describedby="municipal-help" placeholder="#{c("Ex.: estacionamento, habitação, monos", "E.g. parking, housing, bulky waste", locale)}"></label></div>
      <p id="municipal-help">#{c("Escreva apenas o assunto, sem nomes, números de identificação ou outros dados pessoais.", "Enter only the subject, without names, identification numbers or other personal information.", locale)}</p>
      <button type="submit">#{c("Procurar serviços", "Find services", locale)}</button>
    </form>
    <noscript><p>#{c("Ative JavaScript para pesquisar. Pode consultar os serviços e fontes abaixo.", "Enable JavaScript to search. You can browse the services and sources below.", locale)}</p></noscript>
    </section>
    <p id="municipal-status" role="status" aria-live="polite">#{data.total} #{copy.found} · #{length(data.results)} #{copy.shown}</p>
    <div id="municipal-results" class="grid civic-results" aria-busy="false">#{Enum.map_join(data.results, &municipal_card(&1, copy))}</div>
    <section class="card"><h2>#{c("Fontes municipais", "Municipal sources", locale)}</h2>
    <ul>#{Enum.map_join(Enum.sort(data.sources), fn {key, url} -> "<li>#{link(url, municipality_name(key))}</li>" end)}</ul>
    <p>#{copy.verified} <time datetime="#{data.verified_on}">#{data.verified_on}</time></p>
    <p><a href="/vagas?lang=#{locale}">#{c("Consultar horários de atendimento em Ponte de Lima", "Check appointment times in Ponte de Lima", locale)}</a></p></section>
    #{municipal_script(copy)}
    """

    EcidadaoWeb.Page.civic_layout(body, locale)
  end

  def public_support(locale \\ "pt") do
    cards = Enum.map_join(Ecidadao.PublicSupport.all(locale), &support_card(&1, locale))

    EcidadaoWeb.Page.civic_layout(
      """
      #{styles()}
      <section class="hero"><p class="eyebrow">#{c("Habitação · Energia · Mobilidade", "Housing · Energy · Mobility", locale)}</p>
      <h1>#{c("Encontre o percurso para um apoio", "Find your route to public support", locale)}</h1>
      <p class="lead">#{c("Veja a quem se destina, o que preparar e qual a fase do pedido.", "See who it is for, what to prepare and which application phase applies.", locale)}</p>
      <p class="notice">#{c("Orientação com fontes datadas. Confirme regras e disponibilidade no portal oficial. Não garantimos elegibilidade, aprovação ou pagamento. Entregue dados e documentos apenas no canal oficial.", "Guidance based on dated sources. Check current rules and availability on the official portal. Eligibility, approval and payment are not guaranteed. Provide personal information and documents only through official channels.", locale)}</p></section>
      <div id="support-results">#{cards}</div>
      """,
      locale
    )
  end

  defp municipal_card(item, copy) do
    """
    <article class="card civic-card" data-service-id="#{h(item["id"])}">
    <p>#{h(municipality_name(item["municipality"]))}</p><h2>#{h(item["title"])}</h2>
    <p>#{h(item["category"] || "")}</p>
    <p>#{link(item["official_url"], copy.open)}</p>
    <p>#{link(item["source"], copy.source)} · #{copy.verified} <time datetime="#{h(item["verified_on"])}">#{h(item["verified_on"])}</time></p></article>
    """
  end

  defp support_card(service, locale) do
    """
    <article class="card civic-card" data-support-id="#{h(service.id)}" id="#{h(service.id)}">
    <h2>#{h(service.title)}</h2><p>#{h(service.purpose)}</p>
    <h3>#{c("A quem se destina", "Who it is for", locale)}</h3><p>#{h(service.audience)}</p>
    <h3>#{c("Antes de começar", "Before you start", locale)}</h3><p>#{h(service.requirements)}</p>
    <ul>#{Enum.map_join(service.checklist, &"<li>#{h(&1)}</li>")}</ul>
    <h3>#{c("Fases e prazos", "Phases and deadlines", locale)}</h3>
    #{Enum.map_join(service.application_phases, &phase_card(&1, locale))}
    <p>#{h(service.navigation)}</p><p>#{link(service.application_url, c("Continuar no portal oficial ↗", "Continue on the official portal ↗", locale))}</p>
    <details><summary>#{c("Fontes e data de consulta", "Sources and date checked", locale)}</summary>
    <p>#{c("Fontes consultadas em", "Sources checked on", locale)} <time datetime="#{service.verified_on}">#{service.verified_on}</time></p>
    <ul>#{Enum.map_join(service.sources, &"<li>#{link(&1, &1)}</li>")}</ul></details></article>
    """
  end

  defp phase_card(phase, locale) do
    deadline =
      phase.published_deadline || c("Sem prazo confirmado", "No confirmed deadline", locale)

    """
    <section class="notice civic-phase" data-phase="#{h(phase.action)}">
    <h4>#{phase_name(phase.action, locale)}</h4><p><strong>#{phase_status(phase.status, locale)}</strong></p>
    <p>#{h(phase.guidance)}</p><p>#{c("Prazo publicado", "Published deadline", locale)}: #{h(deadline)}</p>
    <p>#{link(phase.source, c("Fonte oficial", "Official source", locale))} · #{c("Observação", "Observation", locale)}: #{h(phase.evidence_on)} · #{c("Estado em", "Status as of", locale)}: #{h(phase.as_of)}</p></section>
    """
  end

  defp phase_name(action, locale) do
    {pt, en} =
      Map.get(
        %{
          "new_application" => {"Nova candidatura", "New application"},
          "existing_beneficiary_expression_of_interest" =>
            {"Manifestação de interesse — beneficiários existentes",
             "Expression of interest — existing beneficiaries"},
          "supplier_payment_request" =>
            {"Pedido de pagamento — fornecedores", "Payment request — suppliers"},
          "existing_application_follow_up" =>
            {"Acompanhamento de candidatura existente", "Follow up an existing application"}
        },
        action,
        {"Fase do pedido", "Application phase"}
      )

    c(pt, en, locale)
  end

  defp phase_status(status, locale) do
    {pt, en} =
      Map.get(
        %{
          "within_published_deadline" =>
            {"Dentro do prazo publicado — confirme disponibilidade",
             "Within the published deadline — confirm availability"},
          "published_deadline_passed" =>
            {"Prazo publicado terminado", "Published deadline passed"},
          "closed_to_new_beneficiaries" =>
            {"Encerrado para novos beneficiários", "Closed to new beneficiaries"},
          "closed_to_new_applications" =>
            {"Encerrado para novas candidaturas", "Closed to new applications"},
          "no_open_forms_observed_in_annual_section" =>
            {"Sem formulários abertos na secção anual consultada",
             "No open forms observed in the annual section"}
        },
        status,
        {"Confirme o estado no portal oficial", "Check current status on the official portal"}
      )

    c(pt, en, locale)
  end

  defp municipal_script(copy) do
    json = copy |> Jason.encode!() |> String.replace("<", "\\u003c")

    """
    <script>(() => {
      const copy = #{json};
      const form = document.getElementById('municipal-form');
      const results = document.getElementById('municipal-results');
      const status = document.getElementById('municipal-status');
      const names = {gondomar: 'Gondomar', maia: 'Maia', ponte_de_lima: 'Ponte de Lima'};
      const hosts = ['servicosonline.cm-gondomar.pt', 'www.cm-gondomar.pt', 'diretorio.cm-maia.pt', 'www.cm-pontedelima.pt'];
      const safeURL = value => {
        try { const url = new URL(value); return url.protocol === 'https:' && hosts.includes(url.hostname) && !url.username && !url.password && (!url.port || url.port === '443') ? url.href : null; }
        catch { return null; }
      };
      const node = (tag, text) => { const el = document.createElement(tag); el.textContent = text || ''; return el; };
      const link = (url, text) => { const el = node('a', text); el.href = url; el.rel = 'noreferrer'; return el; };
      form.hidden = false;
      form.addEventListener('submit', async event => {
        event.preventDefault();
        const button = form.querySelector('button');
        button.disabled = true; results.setAttribute('aria-busy', 'true'); status.textContent = copy.loading;
        const controller = new AbortController();
        const timeout = setTimeout(() => controller.abort(), 15000);
        try {
          const response = await fetch('/api/municipal/services', {method: 'POST', headers: {'Content-Type': 'application/json'}, signal: controller.signal,
            body: JSON.stringify({municipality: form.elements.municipality.value, query: form.elements.query.value, limit: 30, language: copy.language})});
          if (!response.ok) throw new Error();
          const data = await response.json();
          if (!Array.isArray(data.results) || !Number.isInteger(data.total) || data.total < 0) throw new Error();
          const fragment = document.createDocumentFragment();
          for (const item of data.results.slice(0, 30)) {
            const url = safeURL(item.official_url), source = safeURL(item.source);
            if (!url || !source || typeof item.title !== 'string' || !names[item.municipality]) throw new Error();
            const card = node('article'); card.className = 'card civic-card'; card.dataset.serviceId = item.id;
            card.append(node('p', names[item.municipality]), node('h2', item.title), node('p', item.category));
            const action = node('p'); action.append(link(url, copy.open)); card.append(action);
            const evidence = node('p'); evidence.append(link(source, copy.source), document.createTextNode(' · ' + copy.verified + ' ' + (item.verified_on || ''))); card.append(evidence);
            fragment.append(card);
          }
          results.replaceChildren(fragment);
          status.textContent = data.total ? data.total + ' ' + copy.found + ' · ' + results.childElementCount + ' ' + copy.shown : copy.empty;
        } catch {
          results.replaceChildren(); status.textContent = copy.error;
        } finally {
          clearTimeout(timeout); button.disabled = false; results.setAttribute('aria-busy', 'false');
        }
      });
    })();</script>
    """
  end

  defp styles,
    do:
      "<style>.civic-card{min-width:0;overflow-wrap:anywhere}.civic-card h2{font-size:1.5rem}.civic-phase{margin:18px 0}.civic-phase h4{margin-top:0}.civic-card li{line-height:1.6;margin-bottom:8px}.civic-card summary{cursor:pointer;font-weight:700}.civic-results .card{margin-bottom:0}.civic-results{margin-bottom:30px}</style>"

  defp municipality_name("gondomar"), do: "Gondomar"
  defp municipality_name("maia"), do: "Maia"
  defp municipality_name("ponte_de_lima"), do: "Ponte de Lima"
  defp c(_pt, en, "en"), do: en
  defp c(pt, _en, _), do: pt
  defp h(value), do: value |> to_string() |> Plug.HTML.html_escape()
  defp link(url, label), do: "<a href=\"#{h(url)}\" rel=\"noreferrer\">#{h(label)}</a>"
end
