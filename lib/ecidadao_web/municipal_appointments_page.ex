defmodule EcidadaoWeb.MunicipalAppointmentsPage do
  @moduledoc false

  def render(locale) do
    locale = if locale == "en", do: "en", else: "pt"
    c = copy(locale)

    EcidadaoWeb.Page.civic_layout(
      """
      <section class="hero">
        <p class="eyebrow">Ponte de Lima · #{c.presential}</p>
        <h1>#{c.title}</h1>
        <p class="lead">#{c.intro}</p>
        <p class="notice">#{c.warning}</p>
      </section>
      <section class="card" id="municipal-availability" aria-labelledby="availability-title">
        <h2 id="availability-title">#{c.choose}</h2>
        <p>#{c.names}</p>
        <button type="button" id="municipal-load">#{c.load}</button>
        <div class="grid municipal-fields">
          <div><label for="municipal-service">#{c.service}</label><select id="municipal-service" disabled><option value="">#{c.servicePlaceholder}</option></select></div>
          <div><label for="municipal-date">#{c.date}</label><select id="municipal-date" disabled><option value="">#{c.datePlaceholder}</option></select></div>
        </div>
        <p id="municipal-status" role="status" aria-live="polite">#{c.initial}</p>
        <p id="municipal-error" role="alert" hidden></p>
        <button type="button" id="municipal-retry" class="secondary" hidden>#{c.retry}</button>
        <section id="municipal-results" hidden aria-labelledby="municipal-slots-title">
          <h3 id="municipal-slots-title">#{c.slots}</h3>
          <ul id="municipal-slots" class="report-list"></ul>
        </section>
        <p id="municipal-observation" hidden>#{c.checked} <time id="municipal-checked"></time> · #{c.timezone}</p>
        <p>#{c.source} <a href="https://www.cm-pontedelima.pt/pages/1606">Município de Ponte de Lima</a></p>
        <a class="official" href="https://www.cm-pontedelima.pt/pages/1606">#{c.portal}</a>
        <noscript><p class="notice">#{c.nojs}</p></noscript>
      </section>
      <style>
        #municipal-availability [hidden]{display:none!important}
        .municipal-fields{margin-top:24px;grid-template-columns:repeat(2,minmax(0,1fr))}
        .municipal-fields>div{min-width:0}.municipal-fields select{width:100%;min-width:0;max-width:100%}
        #municipal-availability{overflow-wrap:anywhere}
        #municipal-availability button:disabled{opacity:.65;cursor:wait}
        @media(max-width:700px){.municipal-fields{grid-template-columns:1fr}}
      </style>
      <script>
      (() => {
        const text = #{Jason.encode!(c)};
        const language = #{Jason.encode!(locale)};
        const el = id => document.getElementById('municipal-' + id);
        const service = el('service'), date = el('date'), load = el('load'), retry = el('retry');
        let generation = 0, controller = null, lastQuery = {};
        function resetSelect(select, placeholder) {
          select.replaceChildren(new Option(placeholder, ''));
          select.disabled = true;
        }
        function clearResults() {
          el('slots').replaceChildren();
          el('results').hidden = true;
          el('observation').hidden = true;
          el('checked').textContent = '';
          el('error').hidden = true;
          retry.hidden = true;
        }
        function fail(message) {
          el('status').textContent = '';
          el('error').textContent = message;
          el('error').hidden = false;
          retry.hidden = false;
        }
        function valid(data, kind) {
          if (!data || typeof data.checked_at !== 'string' || !Number.isFinite(Date.parse(data.checked_at))) return false;
          if (kind === 'areas') return data.status === 'areas_listed' && Array.isArray(data.areas) && data.areas.every(a => a && Number.isInteger(a.id) && a.id > 0 && typeof a.name === 'string');
          if (!['available_at_check_time', 'no_availability'].includes(data.status)) return false;
          const items = data[kind];
          if (!Array.isArray(items) || (data.status === 'no_availability') !== (items.length === 0)) return false;
          return kind === 'dates' ? items.every(d => typeof d === 'string' && /^\\d{4}-\\d{2}-\\d{2}$/.test(d)) :
            items.every(s => s && s.date === date.value && s.timezone === 'Europe/Lisbon' && typeof s.starts_at === 'string' && typeof s.ends_at === 'string');
        }
        async function query(args) {
          const current = ++generation;
          if (controller) controller.abort();
          controller = new AbortController();
          const signal = controller.signal;
          const kind = args.date ? 'slots' : args.service_id ? 'dates' : 'areas';
          lastQuery = {...args};
          clearResults();
          if (kind === 'areas') resetSelect(service, text.servicePlaceholder);
          if (kind !== 'slots') resetSelect(date, text.datePlaceholder);
          load.disabled = kind === 'areas';
          el('status').textContent = text.loading;
          el('availability')?.setAttribute('aria-busy', 'true');
          const timeout = setTimeout(() => { if (current === generation) controller.abort(); }, 20000);
          try {
            let response;
            for (let attempt = 0; attempt < 2; attempt++) {
              response = await fetch('/api/municipal/appointments', {method: 'POST', headers: {'Content-Type': 'application/json'},
                body: JSON.stringify({municipality: 'ponte_de_lima', language, ...args}), signal});
              if (current !== generation) return;
              if (response.status !== 429 || attempt === 1) break;
              el('status').textContent = text.wait;
              await new Promise(resolve => setTimeout(resolve, 1100));
              if (current !== generation || signal.aborted) return;
            }
            if (!response.ok) throw new Error(response.status === 429 ? text.rate : text.error);
            const data = await response.json();
            if (current !== generation) return;
            if (!valid(data, kind)) throw new Error(text.error);
            el('checked').dateTime = data.checked_at;
            el('checked').textContent = data.checked_at + ' (UTC)';
            el('observation').hidden = false;
            if (kind === 'areas') {
              data.areas.forEach(a => service.add(new Option(a.name, String(a.id))));
              service.disabled = data.areas.length === 0;
              el('status').textContent = data.areas.length ? text.pickService : text.noAreas;
            } else if (kind === 'dates') {
              data.dates.forEach(d => date.add(new Option(d, d)));
              date.disabled = data.dates.length === 0;
              el('status').textContent = data.dates.length ? text.pickDate : text.noDates;
            } else {
              data.slots.forEach(s => {
                const item = document.createElement('li');
                item.textContent = s.date + ' · ' + s.starts_at + '–' + s.ends_at + ' · Europe/Lisbon';
                el('slots').append(item);
              });
              el('results').hidden = data.slots.length === 0;
              el('status').textContent = data.slots.length ? text.available : text.noSlots;
            }
          } catch (error) {
            if (current === generation) fail(error.message === text.rate ? text.rate : text.error);
          } finally {
            clearTimeout(timeout);
            if (current === generation) {
              load.disabled = false;
              el('availability')?.setAttribute('aria-busy', 'false');
            }
          }
        }
        function cancelSelection() {
          ++generation;
          if (controller) controller.abort();
          clearResults();
          load.disabled = false;
          el('availability')?.setAttribute('aria-busy', 'false');
        }
        load.addEventListener('click', () => query({}));
        service.addEventListener('change', () => {
          cancelSelection();
          resetSelect(date, text.datePlaceholder);
          if (service.value) query({service_id: Number(service.value)});
          else el('status').textContent = text.pickService;
        });
        date.addEventListener('change', () => {
          cancelSelection();
          if (date.value) query({service_id: Number(service.value), date: date.value});
          else el('status').textContent = text.pickDate;
        });
        retry.addEventListener('click', () => query(lastQuery));
        window.addEventListener('pagehide', () => { ++generation; if (controller) controller.abort(); });
      })();
      </script>
      """,
      locale
    )
  end

  defp copy("en") do
    %{
      presential: "In-person appointments",
      title: "Find municipal appointment availability.",
      intro:
        "Check public services, dates and times in Ponte de Lima. Start by loading the services.",
      warning:
        "Availability may change. Nothing is submitted or reserved here. Complete your booking on the official portal.",
      choose: "Choose a service and date",
      names: "Official service names remain in Portuguese to match the municipal portal.",
      load: "Load / refresh services",
      service: "Service",
      date: "Date",
      servicePlaceholder: "Choose a service",
      datePlaceholder: "Choose a date",
      initial: "No availability query has been made yet.",
      retry: "Try again",
      slots: "Available times at check time",
      checked: "Checked:",
      timezone: "Appointment times: Europe/Lisbon",
      source: "Official source:",
      portal: "Complete booking on the official portal ↗",
      nojs: "Enable JavaScript to check availability here, or use the official portal.",
      loading: "Checking the municipal source…",
      wait: "Waiting briefly before one retry…",
      rate: "Too many queries. Please wait a moment and try again.",
      error:
        "The query could not be completed. Try again or check the official portal. This does not mean there are no appointments.",
      pickService: "Choose a service to check its dates.",
      noAreas: "No public in-person services were returned. Check the official portal.",
      pickDate: "Choose a date to check its times.",
      noDates:
        "No available dates were returned within the next 366 days. Check the official portal.",
      available: "Times available when checked. No appointment has been reserved.",
      noSlots: "No times available on this date when checked. Try another date."
    }
  end

  defp copy(_) do
    %{
      presential: "Atendimento presencial",
      title: "Consulte vagas de atendimento municipal.",
      intro:
        "Consulte serviços, datas e horários públicos em Ponte de Lima. Comece por carregar os serviços.",
      warning:
        "A disponibilidade pode mudar. Aqui nada é submetido ou reservado. Conclua a marcação no portal oficial.",
      choose: "Escolha o serviço e a data",
      names: "Os nomes oficiais dos serviços mantêm-se em português, como no portal municipal.",
      load: "Carregar / atualizar serviços",
      service: "Serviço",
      date: "Data",
      servicePlaceholder: "Escolha um serviço",
      datePlaceholder: "Escolha uma data",
      initial: "Ainda não foi feita uma consulta de disponibilidade.",
      retry: "Tentar novamente",
      slots: "Horários disponíveis no momento da consulta",
      checked: "Consultado em:",
      timezone: "Fuso horário dos atendimentos: Europe/Lisbon",
      source: "Fonte oficial:",
      portal: "Concluir marcação no portal oficial ↗",
      nojs: "Ative o JavaScript para consultar vagas aqui ou utilize o portal oficial.",
      loading: "A consultar a fonte municipal…",
      wait: "A aguardar um momento antes de tentar mais uma vez…",
      rate: "Demasiadas consultas. Aguarde um momento e tente novamente.",
      error:
        "Não foi possível concluir a consulta. Tente novamente ou consulte o portal oficial. Isto não significa que não existam vagas.",
      pickService: "Escolha um serviço para consultar as datas.",
      noAreas: "Não foram devolvidos serviços públicos presenciais. Consulte o portal oficial.",
      pickDate: "Escolha uma data para consultar os horários.",
      noDates:
        "Não foram devolvidas datas disponíveis nos próximos 366 dias. Consulte o portal oficial.",
      available: "Horários disponíveis no momento da consulta. Nenhuma marcação foi reservada.",
      noSlots:
        "Sem horários disponíveis nesta data no momento da consulta. Experimente outra data."
    }
  end
end
