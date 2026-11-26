defmodule EcidadaoWeb.Page do
  @moduledoc false
  import EcidadaoWeb.Locale, only: [t: 2, tj: 2]

  def landing(locale \\ "pt") do
    layout(
      """
      <section class="landing-hero">
        <div class="landing-copy">
          <p class="eyebrow">#{t("Serviços úteis · Portugal", locale)}</p>
          <h1>#{t("O próximo passo fica mais simples.", locale)}</h1>
          <p class="lead">#{t("Compare filas, encontre o serviço certo e prepare o que precisa de apresentar. O eCidadão ajuda a chegar ao portal oficial com tudo mais claro.", locale)}</p>
          <div class="hero-actions"><a class="official" href="#servicos">#{t("Explorar serviços ↓", locale)}</a><a class="official secondary" href="/como-usar">#{t("Usar com Claude ou ChatGPT ↗", locale)}</a></div>
          <p class="hero-disclaimer">#{t("Projeto independente e gratuito. Senhas, marcações e pedidos são concluídos nos portais oficiais.", locale)}</p>
        </div>
        <div class="hero-panel" aria-label="#{t("Serviços disponíveis", locale)}">
          <span class="panel-kicker">#{t("O que pode fazer agora", locale)}</span>
          <div><b>01</b><span>SIGA / IRN</span><small>#{t("Filas e marcações", locale)}</small></div>
          <div><b>02</b><span>#{t("Finanças", locale)}</span><small>#{t("Serviços e e-balcão", locale)}</small></div>
          <div><b>03</b><span>A Minha Rua</span><small>#{t("Ocorrências", locale)}</small></div>
          <div><b>04</b><span>#{t("Reclamações", locale)}</span><small>#{t("Rascunhos", locale)}</small></div>
        </div>
      </section>

      <section id="servicos" class="landing-section" aria-labelledby="servicos-title">
        <div class="landing-section-head"><div><p class="eyebrow">#{t("Escolha o seu percurso", locale)}</p><h2 id="servicos-title">#{t("Serviços", locale)}</h2></div><p>#{t("Comece pelo assunto que quer resolver. Cada percurso explica o que pode fazer aqui e onde termina a ação oficial.", locale)}</p></div>
        <div class="service-grid">
          <article class="service-card service-siga"><div class="service-top"><span class="service-number">01</span><span class="service-status">#{t("Consulta pública", locale)}</span></div><p class="service-label">#{t("Atendimento presencial", locale)}</p><h3>SIGA / IRN</h3><p>#{t("Veja filas próximas, compare a espera publicada e encontre o caminho para uma senha ou marcação.", locale)}</p><ul><li>#{t("Distância e espera por balcão", locale)}</li><li>#{t("IRN Registo quando disponível no distrito", locale)}</li><li>#{t("Conclusão no SIGA oficial", locale)}</li></ul><div class="service-actions"><a class="official" href="/siga">#{t("Comparar filas ↗", locale)}</a><a href="/siga?entidade=IRN%20Registo">#{t("Procurar IRN", locale)}</a></div></article>
          <article class="service-card service-financas"><div class="service-top"><span class="service-number">02</span><span class="service-status">#{t("Rascunho", locale)}</span></div><p class="service-label">#{t("Autoridade Tributária", locale)}</p><h3>#{t("Finanças", locale)}</h3><p>#{t("Encontre o ponto de entrada para IRS, IMI, pagamentos ou certidões e prepare uma questão para o e-balcão.", locale)}</p><ul><li>#{t("Orientação para o portal", locale)}</li><li>#{t("Assunto e mensagem para rever", locale)}</li><li>#{t("Envio pela pessoa na AT", locale)}</li></ul><div class="service-actions"><a class="official" href="/financas">#{t("Abrir Finanças ↗", locale)}</a></div></article>
          <article class="service-card service-rua"><div class="service-top"><span class="service-number">03</span><span class="service-status">#{t("Consulta e rascunho", locale)}</span></div><p class="service-label">#{t("Espaço público", locale)}</p><h3>A Minha Rua</h3><p>#{t("Consulte ocorrências públicas recentes e prepare um reporte de problemas na sua rua.", locale)}</p><ul><li>#{t("Entradas recentes do portal ARTE", locale)}</li><li>#{t("Campos organizados para copiar", locale)}</li><li>#{t("Envio e reCAPTCHA no portal oficial", locale)}</li></ul><div class="service-actions"><a class="official" href="/a-minha-rua">#{t("Abrir A Minha Rua ↗", locale)}</a></div></article>
          <article class="service-card service-reclamacoes"><div class="service-top"><span class="service-number">04</span><span class="service-status">#{t("Rascunho", locale)}</span></div><p class="service-label">#{t("Direitos de consumo", locale)}</p><h3>#{t("Reclamações", locale)}</h3><p>#{t("Organize os factos e a solução pretendida antes de apresentar a reclamação no Livro de Reclamações Eletrónico.", locale)}</p><ul><li>#{t("Texto claro e revisto por si", locale)}</li><li>#{t("Sem conta e sem guardar o rascunho", locale)}</li><li>#{t("Comprovativo emitido no portal oficial", locale)}</li></ul><div class="service-actions"><a class="official" href="/reclamacoes">#{t("Preparar reclamação ↗", locale)}</a></div></article>
        </div>
      </section>

      <section class="landing-section" aria-labelledby="utilitarios-title"><div class="landing-section-head"><div><p class="eyebrow">#{t("Mais formas de ajudar", locale)}</p><h2 id="utilitarios-title">#{t("Utilitários", locale)}</h2></div><p>#{t("Ferramentas pequenas para preparar o passo seguinte sem entregar credenciais ao eCidadão.", locale)}</p></div><div class="utility-grid">
        <a class="utility-card" href="/como-usar"><span class="utility-symbol" aria-hidden="true">⌁</span><h3>#{t("MCP no telemóvel", locale)}</h3><p>#{t("Seis ferramentas públicas para usar em conversas Claude ou ChatGPT. Veja passos simples e prints.", locale)}</p><strong>#{t("Ver guia ↗", locale)}</strong></a>
        <a class="utility-card" href="/a-minha-rua#recent-title"><span class="utility-symbol" aria-hidden="true">◎</span><h3>#{t("Ocorrências recentes", locale)}</h3><p>#{t("Veja as últimas entradas públicas de A Minha Rua com ligação à fonte oficial.", locale)}</p><strong>#{t("Consultar ↗", locale)}</strong></a>
        <a class="utility-card" href="/financas"><span class="utility-symbol" aria-hidden="true">✎</span><h3>#{t("Rascunhos para copiar", locale)}</h3><p>#{t("Prepare uma mensagem para o e-balcão, reveja-a e leve-a para o portal oficial.", locale)}</p><strong>#{t("Começar ↗", locale)}</strong></a>
      </div></section>

      <section id="contribuir" class="open-project" aria-labelledby="open-project-title">
        <div class="open-project-copy"><p class="eyebrow">#{t("Código aberto · Apache-2.0", locale)}</p><h2 id="open-project-title">#{t("Um projecto aberto.", locale)}<br>#{t("Com espaço para si.", locale)}</h2><p>#{t("O eCidadão é independente, gratuito e aberto a contribuições. O código do site, do servidor MCP e dos plugins está no GitHub. Pode explorar, adaptar e ajudar a melhorar.", locale)}</p><p>#{t("Encontrou um erro? Tem uma ideia para um serviço, quer melhorar os textos ou contribuir com código? A sua contribuição é bem-vinda.", locale)}</p><div class="hero-actions"><a class="official" href="https://github.com/ecidadao/ecidadao">#{t("Ver código no GitHub ↗", locale)}</a><a class="official secondary" href="https://github.com/ecidadao/ecidadao/blob/main/CONTRIBUTING.md">#{t("Como contribuir ↗", locale)}</a></div><p class="open-project-links"><a href="https://github.com/ecidadao/ecidadao/issues">#{t("Reportar um problema ou sugerir uma ideia ↗", locale)}</a><a href="https://github.com/ecidadao/plugins">#{t("Explorar os plugins ↗", locale)}</a></p></div>
        <div class="brand-card"><img src="/marca/ecidadao-logo.svg" alt="eCidadão" width="1000" height="256" loading="lazy"><p>#{t("Uma identidade para partilhar.", locale)}</p><a href="/marca/ecidadao-identidade.zip" download>#{t("Descarregar logótipo · SVG e PNG ↓", locale)}</a><p><a href="/marca/ecidadao-github.png" download>#{t("Avatar para GitHub · PNG quadrado ↓", locale)}</a></p></div>
      </section>

      <section class="landing-mcp" aria-labelledby="landing-mcp-title"><div><p class="eyebrow">#{t("Para apps e assistentes", locale)}</p><h2 id="landing-mcp-title">#{t("Um MCP para vários serviços.", locale)}</h2><p>#{t("O servidor está disponível em HTTPS. Os plugins para Codex e Claude Code estão disponíveis em GitHub, com código aberto e ligação ao MCP público.", locale)}</p></div><div><code>https://ecidadao.pt/mcp/public</code><a class="official" href="/como-usar">#{t("Ver como ligar ↗", locale)}</a></div></section>
      """,
      locale
    )
  end

  def complaints(locale \\ "pt") do
    layout(
      """
      <section class="hero">
        <p class="eyebrow">#{t("Um projeto independente e gratuito", locale)}</p>
        <h1>#{t("Uma reclamação clara começa por um bom rascunho.", locale)}</h1>
        <p class="lead">#{t("Organize os factos, defina a solução pretendida e leve o texto ao Livro de Reclamações Eletrónico.", locale)}</p>
        <p class="notice"><strong>#{t("O eCidadão não é um serviço do Estado.", locale)}</strong> #{t("Preparar aqui um rascunho não apresenta uma reclamação. A submissão acontece apenas no portal oficial.", locale)}</p>
      </section>
      <section class="card" aria-labelledby="form-title">
        <div class="section-heading"><span>#{t("01 / Preparar", locale)}</span><h2 id="form-title">#{t("Conte-nos o que aconteceu", locale)}</h2></div>
        <form id="complaint-form">
          <div class="grid">
            <label>#{t("Empresa ou entidade reclamada", locale)} <em>*</em><input name="business_name" maxlength="160" required autocomplete="organization" placeholder="#{t("Nome da empresa", locale)}"></label>
            <label>#{t("Referência da compra ou contrato", locale)}<input name="reference" maxlength="100" placeholder="#{t("Opcional", locale)}"></label>
            <label>#{t("O seu nome", locale)}<input name="consumer_name" maxlength="120" autocomplete="name" placeholder="#{t("Opcional", locale)}"></label>
            <label>#{t("O seu email", locale)}<input name="consumer_email" maxlength="254" type="email" autocomplete="email" placeholder="#{t("Opcional", locale)}"></label>
            <label>#{t("Data da ocorrência", locale)}<input name="incident_date" type="date"></label>
          </div>
          <label>#{t("O que aconteceu?", locale)} <em>*</em><textarea name="description" maxlength="5000" required rows="6" placeholder="#{t("Descreva os factos por ordem, com datas e valores relevantes.", locale)}"></textarea></label>
          <label>#{t("Que solução pretende?", locale)} <em>*</em><textarea name="requested_resolution" maxlength="1500" required rows="3" placeholder="#{t("Por exemplo, reparação, substituição, reembolso ou esclarecimento.", locale)}"></textarea></label>
          <div class="form-actions"><button type="submit">#{t("Preparar rascunho", locale)} <span aria-hidden="true">↗</span></button><small>#{t("Os dados enviados são processados em memória e não são guardados por este serviço.", locale)}</small></div>
        </form>
        <div id="form-message" role="status" aria-live="polite"></div>
      </section>
      <section id="result" class="card result" hidden aria-labelledby="result-title">
        <div class="section-heading"><span>#{t("02 / Rever", locale)}</span><h2 id="result-title">#{t("O seu rascunho", locale)}</h2></div>
        <p>#{t("Reveja o texto. Pode copiá-lo ou descarregá-lo para continuar no portal oficial.", locale)}</p>
        <p class="help-note">#{t("Os modelos de rascunho mantêm os cabeçalhos em português para os portais oficiais; o texto que escrever não é traduzido.", locale)}</p><pre id="draft"></pre>
        <div class="result-actions"><button type="button" id="copy-button">#{t("Copiar texto", locale)}</button><button type="button" id="download-button" class="secondary">#{t("Descarregar .txt", locale)}</button><a class="official" href="https://www.livroreclamacoes.pt/Inicio/" target="_blank" rel="noopener noreferrer">#{t("Abrir portal oficial ↗", locale)}</a></div>
        <p class="notice">#{t("A reclamação só é apresentada depois de concluir os passos no portal oficial e receber o respetivo comprovativo.", locale)}</p>
      </section>
      <section class="how"><div class="section-heading"><span>#{t("Como funciona", locale)}</span><h2>#{t("Três passos, sem conta", locale)}</h2></div><div class="steps"><article><b>01</b><h3>#{t("Descreva", locale)}</h3><p>#{t("Indique a entidade, os factos e o que pretende.", locale)}</p></article><article><b>02</b><h3>#{t("Reveja", locale)}</h3><p>#{t("Receba um rascunho organizado e corrija o que for preciso.", locale)}</p></article><article><b>03</b><h3>#{t("Apresente", locale)}</h3><p>#{t("Copie o texto para o Livro de Reclamações Eletrónico e guarde o comprovativo.", locale)}</p></article></div></section>
      <section class="card"><div class="section-heading"><span>#{t("Mais serviços", locale)}</span><h2>#{t("Também podemos ajudar", locale)}</h2></div><div class="steps"><article><h3>SIGA / IRN</h3><p>#{t("Compare filas públicas próximas e siga para a marcação oficial.", locale)}</p><a href="/siga">#{t("Abrir ↗", locale)}</a></article><article><h3>#{t("Finanças", locale)}</h3><p>#{t("Encontre o serviço certo e prepare uma questão para o e-balcão.", locale)}</p><a href="/financas">#{t("Abrir ↗", locale)}</a></article><article><h3>A Minha Rua</h3><p>#{t("Consulte ocorrências recentes e prepare um reporte.", locale)}</p><a href="/a-minha-rua">#{t("Abrir ↗", locale)}</a></article></div></section>
      <section class="card"><div class="section-heading"><span>#{t("No telemóvel", locale)}</span><h2>#{t("Quer usar no Claude ou ChatGPT?", locale)}</h2></div><p>#{t("Veja três passos simples para ligar o MCP e prints reais do eCidadão no telefone.", locale)}</p><a class="official" href="/como-usar">#{t("Ver passos e prints ↗", locale)}</a></section>
      <script>
        const form = document.getElementById('complaint-form');
        const result = document.getElementById('result');
        const draft = document.getElementById('draft');
        const message = document.getElementById('form-message');
        form.addEventListener('submit', async (event) => {
          event.preventDefault(); message.textContent = #{tj("A preparar…", locale)};
          const data = Object.fromEntries(new FormData(form));
          try {
            const response = await fetch('/api/complaints/prepare', {method:'POST', headers:{'content-type':'application/json'}, body:JSON.stringify(data)});
            const payload = await response.json();
            if (!response.ok) { message.textContent = (payload.errors || []).map(e => ui(e.field) + ': ' + ui(e.message)).join(' · ') || #{tj("Não foi possível preparar o rascunho.", locale)}; return; }
            draft.textContent = payload.draft; result.hidden = false; message.textContent = #{tj("Rascunho preparado.", locale)}; result.scrollIntoView({behavior:'smooth'});
          } catch (_) { message.textContent = #{tj("Ocorreu um erro de ligação. Tente novamente.", locale)}; }
        });
        document.getElementById('copy-button').addEventListener('click', async () => { await navigator.clipboard.writeText(draft.textContent); message.textContent = #{tj("Texto copiado.", locale)}; });
        document.getElementById('download-button').addEventListener('click', () => { const link = document.createElement('a'); link.href = URL.createObjectURL(new Blob([draft.textContent], {type:'text/plain;charset=utf-8'})); link.download = 'reclamacao-rascunho.txt'; link.click(); URL.revokeObjectURL(link.href); });
      </script>
      """,
      locale
    )
  end

  def minha_rua(locale \\ "pt") do
    options =
      Ecidadao.MinhaRua.categories()
      |> Enum.map_join("", fn category ->
        "<option value=\"#{category}\">#{t(category, locale)}</option>"
      end)

    layout(
      """
      <section class="hero"><p class="eyebrow">A Minha Rua · ARTE</p><h1>#{t("Ajude a melhorar o espaço público.", locale)}</h1><p class="lead">#{t("Consulte ocorrências recentes e organize um novo reporte para a autarquia.", locale)}</p><p class="notice"><strong>#{t("O eCidadão é independente.", locale)}</strong> #{t("O rascunho não é enviado. Para apresentar uma ocorrência, preencha o formulário oficial, resolva o reCAPTCHA e confirme o envio no portal A Minha Rua.", locale)}</p></section>
      <section class="card" aria-labelledby="recent-title"><div class="section-heading"><span>#{t("Consulta pública", locale)}</span><h2 id="recent-title">#{t("Ocorrências recentes", locale)}</h2></div><p>#{t("Até dez entradas recentes da", locale)} <a href="https://servicos.arte.gov.pt/Portal/AMR/situationsList.aspx" target="_blank" rel="noopener noreferrer">#{t("lista oficial", locale)}</a>#{t(". Para pesquisar por localidade ou ver o histórico, use o portal.", locale)}</p><div id="recent-message" role="status">#{t("A consultar…", locale)}</div><ul id="recent-list" class="report-list"></ul></section>
      <section class="card" aria-labelledby="street-title"><div class="section-heading"><span>#{t("Preparar", locale)}</span><h2 id="street-title">#{t("Nova ocorrência", locale)}</h2></div><p>#{t("O portal oficial pede distrito, município, freguesia, morada, categoria, assunto e descrição. A morada e a descrição podem ficar públicas; não inclua dados pessoais nesses campos.", locale)}</p>
        <form id="street-form"><div class="grid">
          <label>#{t("Distrito", locale)} <em>*</em><input name="district" maxlength="100" required placeholder="#{t("Ex.: Porto", locale)}"></label>
          <label>#{t("Município", locale)} <em>*</em><input name="municipality" maxlength="100" required placeholder="#{t("Ex.: Matosinhos", locale)}"></label>
          <label>#{t("Freguesia", locale)} <em>*</em><input name="parish" maxlength="120" required placeholder="#{t("Ex.: Matosinhos e Leça da Palmeira", locale)}"></label>
          <label>#{t("Morada da ocorrência", locale)} <em>*</em><input name="address" maxlength="2000" required placeholder="#{t("Rua e referência do local", locale)}"></label>
        </div>
        <label>#{t("Categoria", locale)} <em>*</em><select name="category" required><option value="">#{t("Escolha uma categoria", locale)}</option>#{options}</select></label>
        <label>#{t("Assunto", locale)} <em>*</em><input name="subject" maxlength="255" required placeholder="#{t("Ex.: Candeeiro apagado junto à escola", locale)}"></label>
        <label>#{t("Descrição", locale)} <em>*</em><textarea name="description" maxlength="5000" required rows="5" placeholder="#{t("Descreva o problema, há quanto tempo ocorre e o impacto. Não inclua dados pessoais.", locale)}"></textarea></label>
        <div class="form-actions"><button type="submit">#{t("Preparar reporte", locale)} <span aria-hidden="true">↗</span></button><small>#{t("O eCidadão não guarda o conteúdo nem pede nome, email ou telefone. Esses dados são inseridos apenas no portal oficial.", locale)}</small></div></form><div id="street-message" role="status" aria-live="polite"></div>
      </section>
      <section id="street-result" class="card result" hidden aria-labelledby="street-result-title"><div class="section-heading"><span>#{t("Rever", locale)}</span><h2 id="street-result-title">#{t("Campos preparados", locale)}</h2></div><p>#{t("Copie cada campo para o", locale)} <a href="https://servicos.arte.gov.pt/Portal/AMR/situationReport.aspx" target="_blank" rel="noopener noreferrer">#{t("formulário oficial", locale)}</a>#{t(". Confirme que a autarquia está disponível, anexe uma fotografia se quiser, introduza o seu nome e email nesse portal e resolva o reCAPTCHA. Guarde o número do pedido após enviar.", locale)}</p><dl id="street-fields" class="field-list"></dl><div class="result-actions"><button type="button" id="street-copy">#{t("Copiar rascunho completo", locale)}</button><a class="official" href="https://servicos.arte.gov.pt/Portal/AMR/situationReport.aspx" target="_blank" rel="noopener noreferrer">#{t("Abrir formulário oficial ↗", locale)}</a></div><p class="notice">#{t("Este rascunho ainda não foi enviado à autarquia.", locale)}</p></section>
      <script>
        const recentMessage = document.getElementById('recent-message');
        const recentList = document.getElementById('recent-list');
        fetch('/api/street-reports/recent').then(async response => { if (!response.ok) throw new Error(); return response.json(); }).then(data => {
          recentMessage.textContent = #{tj("Consulta: ", locale)} + new Date(data.fetched_at).toLocaleString(#{tj("pt-PT", locale)}) + (data.stale ? #{tj(" · dados em cache", locale)} : '');
          for (const report of data.reports) {
            const li = document.createElement('li'); const a = document.createElement('a'); a.href = report.official_url; a.target = '_blank'; a.rel = 'noopener noreferrer'; a.textContent = '#' + report.id + ' · ' + report.subject;
            const meta = document.createElement('small'); meta.textContent = report.date + ' · ' + report.locality + ' · ' + report.status;
            li.append(a, meta); recentList.append(li);
          }
        }).catch(() => { recentMessage.textContent = #{tj("A lista oficial está temporariamente indisponível. Abra o portal para consultar diretamente.", locale)}; });

        const labels = {district:#{tj("Distrito", locale)}, municipality:#{tj("Município", locale)}, parish:#{tj("Freguesia", locale)}, address:#{tj("Morada", locale)}, category:#{tj("Categoria", locale)}, subject:#{tj("Assunto", locale)}, description:#{tj("Descrição", locale)}};
        const streetForm = document.getElementById('street-form');
        const streetResult = document.getElementById('street-result');
        const streetFields = document.getElementById('street-fields');
        const streetMessage = document.getElementById('street-message');
        let streetDraft = '';
        streetForm.addEventListener('submit', async event => {
          event.preventDefault(); streetMessage.textContent = #{tj("A preparar…", locale)};
          try {
            const response = await fetch('/api/street-reports/prepare', {method:'POST', headers:{'content-type':'application/json'}, body:JSON.stringify(Object.fromEntries(new FormData(streetForm)))});
            const data = await response.json();
            if (!response.ok) { streetMessage.textContent = (data.errors || []).map(error => ui(error.field) + ': ' + ui(error.message)).join(' · ') || #{tj("Não foi possível preparar o reporte.", locale)}; return; }
            streetDraft = data.draft; streetFields.replaceChildren();
            for (const [key, label] of Object.entries(labels)) {
              const row = document.createElement('div'); const dt = document.createElement('dt'); const dd = document.createElement('dd'); const copy = document.createElement('button');
              dt.textContent = label; dd.textContent = data.fields[key]; copy.type = 'button'; copy.className = 'secondary'; copy.textContent = #{tj("Copiar", locale)};
              copy.addEventListener('click', async () => { await navigator.clipboard.writeText(data.fields[key]); streetMessage.textContent = label + #{tj(" copiado.", locale)}; });
              row.append(dt, dd, copy); streetFields.append(row);
            }
            streetResult.hidden = false; streetMessage.textContent = #{tj("Reporte preparado. Ainda não foi enviado.", locale)}; streetResult.scrollIntoView({behavior:'smooth'});
          } catch (_) { streetMessage.textContent = #{tj("Ocorreu um erro de ligação. Tente novamente.", locale)}; }
        });
        document.getElementById('street-copy').addEventListener('click', async () => { await navigator.clipboard.writeText(streetDraft); streetMessage.textContent = #{tj("Rascunho copiado.", locale)}; });
      </script>
      """,
      locale
    )
  end

  def siga(locale \\ "pt") do
    districts =
      Ecidadao.Siga.districts()
      |> Enum.map_join("", fn {name, id} -> "<option value=\"#{id}\">#{name}</option>" end)

    layout(
      """
      <section class="hero"><p class="eyebrow">#{t("SIGA · Consulta pública", locale)}</p><h1>#{t("Compare filas perto de si.", locale)}</h1><p class="lead">#{t("Consulte tempos de espera publicados pelo SIGA para uma entidade e tipo de senha. A distância é em linha reta; confirme a disponibilidade antes de sair.", locale)}</p><p class="notice"><strong>#{t("Serviço independente.", locale)}</strong> #{t("Esta consulta não emite senhas nem cria marcações. O SIGA pode alterar os tempos ou exigir email, autenticação e validação para concluir o atendimento.", locale)}</p></section>
      <section class="card"><div class="section-heading"><span>#{t("Consultar", locale)}</span><h2>#{t("Escolha a fila", locale)}</h2></div>
        <form id="siga-form"><div class="grid">
          <label>#{t("Distrito", locale)} <em>*</em><select name="district" required><option value="">#{t("Selecione", locale)}</option>#{districts}</select></label>
          <label>#{t("Entidade", locale)} <em>*</em><input name="entity" required maxlength="120" placeholder="#{t("Ex.: Autoridade Tributária e Aduaneira", locale)}"></label>
          <label>#{t("Tipo de senha", locale)} <em>*</em><input name="ticket_type" required maxlength="120" placeholder="#{t("Ex.: Atendimento Geral", locale)}"></label>
          <label>#{t("Raio (km)", locale)}<input name="radius_km" type="number" min="1" max="100" value="40" required></label>
          <label>Latitude <em>*</em><input name="latitude" type="number" step="any" min="-90" max="90" required placeholder="#{t("Use o botão de localização", locale)}"></label>
          <label>Longitude <em>*</em><input name="longitude" type="number" step="any" min="-180" max="180" required placeholder="#{t("Use o botão de localização", locale)}"></label>
        </div><div class="form-actions"><button type="button" id="siga-location" class="secondary">#{t("Usar a minha localização", locale)}</button><button type="submit">#{t("Comparar filas ↗", locale)}</button><small>#{t("A posição é usada para calcular a distância neste servidor. O SIGA recebe apenas distrito, entidade e tipo de senha.", locale)}</small></div></form>
        <div id="siga-message" role="status" aria-live="polite"></div>
      </section>
      <section id="siga-result" class="card" hidden><div class="section-heading"><span>#{t("Resultado", locale)}</span><h2>#{t("Filas encontradas", locale)}</h2></div><p id="siga-summary"></p><ul id="siga-list" class="report-list"></ul><p class="notice">#{t("Os tempos são estimativas momentâneas; não incluem deslocação. Pesquise também os distritos vizinhos se o raio ultrapassar o distrito escolhido.", locale)}</p></section>
      <section class="card"><div class="section-heading"><span>#{t("Concluir no portal oficial", locale)}</span><h2>#{t("Precisa de uma senha ou marcação?", locale)}</h2></div><div class="result-actions"><a class="official" href="https://siga.marcacaodeatendimento.pt/Senhas/TemposEspera" target="_blank" rel="noopener noreferrer">#{t("Consultar e tirar senha no SIGA ↗", locale)}</a><a class="official secondary" href="https://siga.marcacaodeatendimento.pt/Marcacao/MarcacaoInicio" target="_blank" rel="noopener noreferrer">#{t("Agendar atendimento ↗", locale)}</a></div></section>
      <script>
        const sigaForm = document.getElementById('siga-form');
        if (new URLSearchParams(location.search).get('entidade') === 'IRN Registo') sigaForm.elements.entity.value = 'IRN Registo';
        const sigaMessage = document.getElementById('siga-message');
        document.getElementById('siga-location').addEventListener('click', () => {
          if (!navigator.geolocation) { sigaMessage.textContent = #{tj("Geolocalização indisponível. Pode introduzir as coordenadas manualmente.", locale)}; return; }
          sigaMessage.textContent = #{tj("A pedir a sua localização…", locale)};
          navigator.geolocation.getCurrentPosition(p => { sigaForm.elements.latitude.value = p.coords.latitude; sigaForm.elements.longitude.value = p.coords.longitude; sigaMessage.textContent = #{tj("Localização pronta. Reveja os dados antes de pesquisar.", locale)}; }, () => { sigaMessage.textContent = #{tj("Não foi possível obter a localização. Pode introduzir as coordenadas manualmente.", locale)}; }, {enableHighAccuracy:false, timeout:10000});
        });
        sigaForm.addEventListener('submit', async event => {
          event.preventDefault(); sigaMessage.textContent = #{tj("A consultar o SIGA…", locale)};
          const data = Object.fromEntries(new FormData(sigaForm));
          try {
            const response = await fetch('/api/siga/queues/compare', {method:'POST', headers:{'content-type':'application/json'}, body:JSON.stringify(data)});
            const payload = await response.json();
            if (!response.ok) { sigaMessage.textContent = (payload.errors || []).map(e => ui(e.message) + (e.options ? #{tj(" Opções: ", locale)} + e.options.join(', ') : '')).join(' · ') || #{tj("Consulta indisponível.", locale)}; return; }
            const list = document.getElementById('siga-list'); list.replaceChildren();
            for (const place of payload.locations) {
              const li = document.createElement('li'); const title = document.createElement('strong'); title.textContent = place.name;
              const detail = document.createElement('small'); detail.textContent = place.distance_km + ' km · ' + ui(place.state) + ' · ' + (place.open && place.wait_minutes !== null ? place.wait_minutes + #{tj(" min de espera", locale)} : #{tj("tempo não disponível", locale)}) + ' · ' + place.people_waiting + #{tj(" pessoas em espera", locale)};
              const address = document.createElement('small'); address.textContent = place.address || '';
              li.append(title, detail, address); list.append(li);
            }
            document.getElementById('siga-summary').textContent = payload.total_in_radius + #{tj(" balcões no raio · ", locale)} + payload.entity + ' · ' + payload.ticket_type + #{tj(" · consultado em ", locale)} + new Date(payload.observed_at).toLocaleString(#{tj("pt-PT", locale)});
            document.getElementById('siga-result').hidden = false; sigaMessage.textContent = payload.total_in_radius ? #{tj("Consulta concluída.", locale)} : #{tj("Não foram encontrados balcões neste raio para a seleção.", locale)};
          } catch (_) { sigaMessage.textContent = #{tj("O SIGA está temporariamente indisponível. Consulte o portal oficial.", locale)}; }
        });
      </script>
      """,
      locale
    )
  end

  def financas(locale \\ "pt") do
    layout(
      """
      <section class="hero"><p class="eyebrow">#{t("Portal das Finanças · Apoio", locale)}</p><h1>#{t("Prepare a sua questão para o e-balcão.", locale)}</h1><p class="lead">#{t("Organize o assunto e os factos antes de entrar no portal oficial da Autoridade Tributária.", locale)}</p><p class="notice"><strong>#{t("O eCidadão é independente.", locale)}</strong> #{t("Não acede à sua área pessoal, não lê dados fiscais nem envia pedidos à AT. Não introduza NIF, passwords, códigos ou documentos aqui.", locale)}</p></section>
      <section class="card"><div class="section-heading"><span>#{t("Encontrar", locale)}</span><h2>#{t("Que serviço procura?", locale)}</h2></div><div class="steps"><article><h3>#{t("IRS e IMI", locale)}</h3><p>#{t("Use a pesquisa do Portal das Finanças para escolher a operação certa.", locale)}</p><a href="https://www.portaldasfinancas.gov.pt/at/html/index.html" target="_blank" rel="noopener noreferrer">#{t("Abrir portal ↗", locale)}</a></article><article><h3>#{t("Pagamentos e certidões", locale)}</h3><p>#{t("Confirme dados, referências e prazos na sua área autenticada.", locale)}</p><a href="https://www.portaldasfinancas.gov.pt/at/html/index.html" target="_blank" rel="noopener noreferrer">#{t("Abrir portal ↗", locale)}</a></article><article><h3>#{t("Dúvida individual", locale)}</h3><p>#{t("Prepare abaixo uma questão e apresente-a no e-balcão.", locale)}</p><a href="https://sitfiscal.portaldasfinancas.gov.pt/ebalcao/formularioContacto" target="_blank" rel="noopener noreferrer">#{t("Abrir e-balcão ↗", locale)}</a></article></div></section>
      <section class="card"><div class="section-heading"><span>#{t("Preparar", locale)}</span><h2>#{t("Rascunho para o e-balcão", locale)}</h2></div><form id="financas-form"><label>#{t("Assunto", locale)} <em>*</em><input name="subject" required maxlength="200" placeholder="#{t("O que precisa de esclarecer?", locale)}"></label><label>#{t("Área fiscal, se souber", locale)}<input name="tax_area" maxlength="100" placeholder="#{t("Ex.: IRS, IMI, IVA", locale)}"></label><label>#{t("Mensagem", locale)} <em>*</em><textarea name="message" required maxlength="5000" rows="7" placeholder="#{t("Descreva os factos e a pergunta, sem dados de identificação ou acesso.", locale)}"></textarea></label><div class="form-actions"><button type="submit">#{t("Preparar rascunho ↗", locale)}</button><small>#{t("O texto é processado em memória e não é enviado à AT.", locale)}</small></div></form><div id="financas-message" role="status" aria-live="polite"></div></section>
      <section id="financas-result" class="card result" hidden><div class="section-heading"><span>#{t("Rever", locale)}</span><h2>#{t("Texto preparado", locale)}</h2></div><p class="help-note">#{t("Os modelos de rascunho mantêm os cabeçalhos em português para os portais oficiais; o texto que escrever não é traduzido.", locale)}</p><pre id="financas-draft"></pre><div class="result-actions"><button type="button" id="financas-copy">#{t("Copiar texto", locale)}</button><a class="official" href="https://sitfiscal.portaldasfinancas.gov.pt/ebalcao/formularioContacto" target="_blank" rel="noopener noreferrer">#{t("Abrir e-balcão oficial ↗", locale)}</a></div><p class="notice">#{t("Autentique-se, escolha a categoria correta e registe a questão no portal. Só a AT emite o número do pedido.", locale)}</p></section>
      <script>
        const financasForm = document.getElementById('financas-form'); const financasMessage = document.getElementById('financas-message'); const financasDraft = document.getElementById('financas-draft');
        financasForm.addEventListener('submit', async event => {
          event.preventDefault(); financasMessage.textContent = #{tj("A preparar…", locale)};
          try {
            const response = await fetch('/api/financas/ebalcao/prepare', {method:'POST', headers:{'content-type':'application/json'}, body:JSON.stringify(Object.fromEntries(new FormData(financasForm)))});
            const payload = await response.json();
            if (!response.ok) { financasMessage.textContent = (payload.errors || []).map(e => ui(e.field) + ': ' + ui(e.message)).join(' · '); return; }
            financasDraft.textContent = payload.draft; document.getElementById('financas-result').hidden = false; financasMessage.textContent = #{tj("Rascunho preparado. Ainda não foi enviado.", locale)};
          } catch (_) { financasMessage.textContent = #{tj("Ocorreu um erro de ligação. Tente novamente.", locale)}; }
        });
        document.getElementById('financas-copy').addEventListener('click', async () => { await navigator.clipboard.writeText(financasDraft.textContent); financasMessage.textContent = #{tj("Texto copiado.", locale)}; });
      </script>
      """,
      locale
    )
  end

  def how_to_use(locale \\ "pt") do
    layout(
      """
      <section class="hero"><p class="eyebrow">#{t("Guia rápido · Telemóvel", locale)}</p><h1>#{t("Use o eCidadão em poucos passos.", locale)}</h1><p class="lead">#{t("Pode começar já no site. Se quiser conversar com as ferramentas, ligue o MCP ao Claude ou ao ChatGPT.", locale)}</p><p class="notice"><strong>#{t("Estado do plugin:", locale)}</strong> #{t("o MCP está online, mas o plugin eCidadão ainda não foi publicado no diretório do ChatGPT. Para o testar numa app, adicione o servidor MCP à sua conta quando essa opção estiver disponível.", locale)}</p></section>

      <section class="card" aria-labelledby="mcp-title"><div class="section-heading"><span>#{t("01 / Ligar", locale)}</span><h2 id="mcp-title">#{t("Copie o endereço do MCP", locale)}</h2></div><p>#{t("Use este endereço nas opções de conectores ou plugins da sua app:", locale)}</p><p class="mcp-address"><code>https://ecidadao.pt/mcp/public</code></p><div class="form-actions"><button type="button" id="copy-mcp">#{t("Copiar endereço", locale)}</button><span id="copy-mcp-status" role="status" aria-live="polite"></span></div></section>

      <section class="card" aria-labelledby="claude-title"><div class="section-heading"><span>#{t("02 / Escolher app", locale)}</span><h2 id="claude-title">#{t("No Claude", locale)}</h2></div><ol class="simple-steps"><li>#{t("Abra", locale)} <a href="https://claude.ai" target="_blank" rel="noopener noreferrer">claude.ai</a> #{t("e vá a", locale)} <strong>Customize → Connectors → Add custom connector</strong>.</li><li>#{t("Dê o nome", locale)} <strong>eCidadão</strong>#{t(", cole o endereço acima e escolha", locale)} <strong>No sign in</strong>.</li><li>#{t("Na app Claude, abra uma conversa, toque em", locale)} <strong>+ → Connectors</strong>#{t(", ative eCidadão e faça o seu pedido.", locale)}</li></ol><p class="help-note">#{t("Em contas de equipa, um administrador pode ter de adicionar o conector primeiro.", locale)} <a href="https://support.claude.com/en/articles/11175166-get-started-with-custom-connectors-using-remote-mcp" target="_blank" rel="noopener noreferrer">#{t("Instruções oficiais do Claude ↗", locale)}</a></p></section>

      <section class="card" aria-labelledby="chatgpt-title"><div class="section-heading"><span>#{t("02 / Escolher app", locale)}</span><h2 id="chatgpt-title">#{t("No ChatGPT", locale)}</h2></div><ol class="simple-steps"><li>#{t("Abra", locale)} <a href="https://chatgpt.com/plugins" target="_blank" rel="noopener noreferrer">ChatGPT Plugins</a> #{t("e escolha", locale)} <strong>+ → Add custom MCP server</strong>#{t(", se essa opção estiver disponível na sua conta.", locale)}</li><li>#{t("Cole o endereço acima, chame-lhe", locale)} <strong>eCidadão</strong>#{t(", escolha ligação sem login e instale o plugin de teste.", locale)}</li><li>#{t("Na app ChatGPT, abra uma conversa nova em", locale)} <strong>Chat</strong> #{t("ou", locale)} <strong>Work</strong>#{t(", escolha", locale)} <strong>@eCidadão</strong> #{t("e diga o que precisa.", locale)}</li></ol><p class="help-note">#{t("Para usar o eCidadão no telefone, escolha ChatGPT Chat ou Work. A documentação atual coloca os plugins do Codex na app de computador e no CLI.", locale)} <a href="https://learn.chatgpt.com/docs/plugins" target="_blank" rel="noopener noreferrer">#{t("Ver documentação oficial ↗", locale)}</a></p></section>

      <section class="card" aria-labelledby="examples-title"><div class="section-heading"><span>#{t("03 / Experimentar", locale)}</span><h2 id="examples-title">#{t("Dois pedidos para começar", locale)}</h2></div><div class="steps"><article><h3>#{t("Filas SIGA", locale)}</h3><p>#{t("“Compara as filas da Autoridade Tributária num raio de 40 km de mim.” Confirme o local, o distrito e o tipo de senha quando a app pedir.", locale)}</p></article><article><h3>#{t("Finanças", locale)}</h3><p>#{t("“Prepara uma questão sobre IMI para o e-balcão.” Reveja o rascunho e envie-o apenas no portal oficial da AT.", locale)}</p></article></div></section>

      <section class="card" aria-labelledby="prints-title"><div class="section-heading"><span>#{t("Prints reais", locale)}</span><h2 id="prints-title">#{t("O que aparece no site móvel", locale)}</h2></div><p>#{t("Estas capturas são do", locale)} <strong>#{t("eCidadão no navegador do telemóvel", locale)}</strong>#{t(", não das apps Claude ou ChatGPT. Os tempos SIGA são um exemplo capturado em 13 de novembro de 2026 e podem mudar.", locale)}</p><div class="screenshot-grid">
        <figure><a href="/imagens/siga-passo.png" target="_blank"><img src="/imagens/siga-passo.png" width="342" height="954" alt="#{t("Formulário SIGA do eCidadão com distrito, entidade, senha, raio e localização", locale)}"></a><figcaption>#{t("1. Escolha a fila SIGA.", locale)}</figcaption></figure>
        <figure><a href="/imagens/siga-resultado.png" target="_blank"><img src="/imagens/siga-resultado.png" width="342" height="787" alt="#{t("Resultado SIGA com balcões, distância, estado e espera observada", locale)}"></a><figcaption>#{t("2. Compare os balcões e confirme no SIGA.", locale)}</figcaption></figure>
        <figure><a href="/imagens/financas-passo.png" target="_blank"><img src="/imagens/financas-passo.png" width="342" height="646" alt="#{t("Formulário de assunto e mensagem para preparar uma questão de Finanças", locale)}"></a><figcaption>#{t("3. Escreva a questão para o e-balcão.", locale)}</figcaption></figure>
        <figure><a href="/imagens/financas-rascunho.png" target="_blank"><img src="/imagens/financas-rascunho.png" width="342" height="821" alt="#{t("Rascunho não submetido para rever e copiar para o e-balcão oficial", locale)}"></a><figcaption>#{t("4. Reveja, copie e conclua no portal oficial.", locale)}</figcaption></figure>
      </div></section>
      <script>document.getElementById('copy-mcp').addEventListener('click', async () => { const status = document.getElementById('copy-mcp-status'); try { await navigator.clipboard.writeText('https://ecidadao.pt/mcp/public'); status.textContent = #{tj("Endereço copiado.", locale)}; } catch (_) { status.textContent = #{tj("Selecione e copie o endereço acima.", locale)}; } });</script>
      """,
      locale
    )
  end

  def privacy(locale \\ "pt") do
    layout(
      """
      <section class="document"><p class="eyebrow">#{t("Transparência", locale)}</p><h1>#{t("Privacidade", locale)}</h1>
        <p>#{t("Responsável pelo tratamento: Código Inadiável — Programação Informática, Lda., NIF 515500780, Rua Alfredo Cunha 362, 4450-021 Matosinhos, Portugal. Contacto:", locale)} <a href="mailto:hello@codeperf.io">hello@codeperf.io</a>.</p>
        <h2>#{t("Dados e finalidades", locale)}</h2><p>#{t("Quando pede um rascunho de reclamação no site ou no MCP, tratamos os dados que fornecer: entidade reclamada, descrição dos factos, solução pretendida e, se os indicar, nome, email, referência e data. Para preparar uma ocorrência A Minha Rua, tratamos distrito, município, freguesia, morada, categoria, assunto e descrição. Para o e-balcão, tratamos o assunto e a mensagem que escrever. Para comparar filas SIGA, tratamos distrito, entidade, tipo de senha, raio e coordenadas fornecidas ou autorizadas. Usamo-los apenas para gerar a resposta pedida. Não criamos conta nem guardamos estes conteúdos numa base de dados. O navegador conserva o formulário enquanto a página estiver aberta; os ficheiros que descarregar ficam no seu dispositivo.", locale)}</p>
        <p>#{t("Tratamos os dados técnicos necessários à ligação e segurança do serviço, como endereço IP, data, URL e código de resposta. A base do tratamento do pedido é a prestação do serviço solicitado; a segurança e o diagnóstico técnico assentam no nosso interesse legítimo em manter o serviço disponível e protegido. Não usamos os dados da reclamação para publicidade, definição de perfis ou decisões automatizadas.", locale)}</p>
        <h2>#{t("Destinatários e conservação", locale)}</h2><p>#{t("A Cloudflare fornece DNS, proteção e entrega de tráfego. O fornecedor do alojamento processa os pedidos para executar a aplicação. Estes prestadores podem tratar dados técnicos para prestar e proteger o serviço, incluindo em infraestrutura fora do Espaço Económico Europeu, sujeitos às garantias contratuais aplicáveis. Não enviamos rascunhos ao Livro de Reclamações Eletrónico, à ARTE ou às autarquias.", locale)}</p>
        <p>#{t("Ao consultar ocorrências recentes, o nosso servidor lê até dez registos públicos do portal A Minha Rua e guarda essa resposta em memória por dois minutos para limitar pedidos ao portal. A consulta não transmite os seus campos de formulário à ARTE. Os registos públicos podem conter moradas e texto escrito por terceiros; confirme sempre os detalhes no portal oficial.", locale)}</p>
        <p>#{t("Na comparação SIGA, o nosso servidor consulta as filas públicas por distrito, entidade e tipo de senha. Calcula a distância com as coordenadas em memória; não as envia ao SIGA. O e-balcão recebe o texto apenas quando o copiar e registar no portal oficial.", locale)}</p>
        <p>#{t("O conteúdo submetido é processado em memória e eliminado após a resposta. Os registos de acesso mantidos pelo serviço não contêm o corpo dos pedidos e são eliminados no prazo máximo de 7 dias. Se nos escrever por email, conservamos a mensagem enquanto for necessária para responder e cumprir eventuais obrigações legais.", locale)}</p>
        <h2>#{t("Idioma e aparência", locale)}</h2><p>#{t("Quando escolhe PT ou EN, guardamos apenas essa preferência num cookie durante um ano. Na primeira visita usamos o idioma do navegador, quando suportado. O tema claro ou escuro segue a preferência do sistema, sem guardar dados adicionais.", locale)}</p><h2>#{t("ChatGPT e direitos", locale)}</h2><p>#{t("Se usar o eCidadão através do ChatGPT, a conversa também é tratada pela OpenAI segundo as condições e definições da sua conta. O cartão de fotografia pode pedir acesso à câmara e, apenas se tocar em «Usar localização», à posição do dispositivo. Ao continuar, a fotografia e a localização escolhida são partilhadas com a conversa do ChatGPT para preparar uma prévia; o nosso servidor recebe apenas a descrição factual selecionada pelo modelo e, quando disponível, uma indicação aproximada de cidade ou região. Não guardamos a fotografia nem as coordenadas no servidor e não as enviamos a serviços públicos nesta fase.", locale)}</p><p>#{t("Pode evitar partilhar dados pessoais opcionais. Tem direitos de acesso, retificação, apagamento, limitação e oposição nos termos legais; contacte-nos em", locale)} <a href="mailto:hello@codeperf.io">hello@codeperf.io</a>#{t(". Pode reclamar junto da", locale)} <a href="https://www.cnpd.pt/" target="_blank" rel="noopener noreferrer">CNPD</a>.</p>
        <p>#{t("Última atualização: 26 de novembro de 2026.", locale)}</p>
      </section>
      """,
      locale
    )
  end

  def terms(locale \\ "pt") do
    layout(
      """
      <section class="document"><p class="eyebrow">#{t("Utilização", locale)}</p><h1>#{t("Termos de utilização", locale)}</h1>
        <p>#{t("O eCidadão é disponibilizado gratuitamente por Código Inadiável — Programação Informática, Lda., NIF 515500780, Rua Alfredo Cunha 362, 4450-021 Matosinhos, Portugal. Contacto:", locale)} <a href="mailto:hello@codeperf.io">hello@codeperf.io</a>.</p>
        <h2>#{t("O que o serviço faz", locale)}</h2><p>#{t("O serviço ajuda a organizar rascunhos de reclamações de consumo, ocorrências sobre espaço público e questões para o e-balcão; consulta ocorrências públicas recentes de A Minha Rua e filas públicas SIGA; e fornece orientação geral. É independente: não representa o Estado, a ARTE, autarquias, a Direção-Geral do Consumidor, a AT, o SIGA ou o Livro de Reclamações Eletrónico. Não apresenta reclamações ou ocorrências, não consulta processos privados, não emite senhas ou comprovativos e não presta aconselhamento jurídico ou fiscal.", locale)}</p>
        <h2>#{t("Responsabilidade do utilizador", locale)}</h2><p>#{t("Reveja e corrija o texto antes de o usar. Envie apenas informação que tenha o direito de partilhar e evite documentos de identificação ou dados de terceiros desnecessários. Para apresentar uma reclamação, siga os passos no", locale)} <a href="https://www.livroreclamacoes.pt/Inicio/" target="_blank" rel="noopener noreferrer">Livro de Reclamações Eletrónico</a>#{t(". Para comunicar uma ocorrência, use o", locale)} <a href="https://servicos.arte.gov.pt/Portal/AMR/situationReport.aspx" target="_blank" rel="noopener noreferrer">#{t("portal A Minha Rua", locale)}</a>#{t(". Guarde o comprovativo ou número emitido pelo portal respetivo.", locale)}</p>
        <h2>#{t("Disponibilidade e contacto", locale)}</h2><p>#{t("Procuramos manter o serviço disponível e correto, mas podem ocorrer interrupções ou erros. Podemos corrigir ou alterar funcionalidades; alterações relevantes destes termos serão publicadas nesta página. Para apoio ou questões sobre o serviço, escreva para", locale)} <a href="mailto:hello@codeperf.io">hello@codeperf.io</a>.</p>
        <p>#{t("Última atualização: 13 de novembro de 2026.", locale)}</p>
      </section>
      """,
      locale
    )
  end

  def support(locale \\ "pt") do
    layout(
      """
      <section class="document"><p class="eyebrow">#{t("Estamos aqui", locale)}</p><h1>#{t("Apoio", locale)}</h1>
        <p>#{t("Para dificuldades com o site, o MCP, SIGA, Finanças, uma reclamação ou uma ocorrência A Minha Rua, escreva para", locale)} <a href="mailto:hello@codeperf.io">hello@codeperf.io</a>#{t(". Indique o problema e o momento aproximado em que aconteceu; não envie passwords, códigos de autenticação ou documentos de identificação.", locale)}</p>
        <p>#{t("Para apresentar uma reclamação oficial ou consultar o seu estado, use o", locale)} <a href="https://www.livroreclamacoes.pt/Inicio/" target="_blank" rel="noopener noreferrer">Livro de Reclamações Eletrónico</a>#{t(". O eCidadão não tem acesso aos processos desse portal e não emite comprovativos.", locale)}</p>
        <p>#{t("Para enviar ou consultar uma ocorrência sobre espaço público, use o", locale)} <a href="https://servicos.arte.gov.pt/Portal/AMR/situationsList.aspx" target="_blank" rel="noopener noreferrer">#{t("portal A Minha Rua", locale)}</a>#{t(". O eCidadão só apresenta as entradas públicas recentes; o envio e o acompanhamento oficial acontecem no portal da ARTE.", locale)}</p>
        <p>#{t("Responsável pelo serviço: Código Inadiável — Programação Informática, Lda., Rua Alfredo Cunha 362, 4450-021 Matosinhos, Portugal.", locale)}</p>
      </section>
      """,
      locale
    )
  end

  defp theme_css do
    """
    :root{color-scheme:light dark}
    .language-switch{display:flex;gap:4px;flex-shrink:0}
    .language-switch a{padding:7px 9px;border-radius:6px;text-decoration:none;font-size:13px;font-weight:700}
    .language-switch a[aria-current=true]{background:#e8f3e8;color:#175f45}
    a:focus-visible,button:focus-visible{outline:2px solid #238562;outline-offset:4px}
    @media(min-width:701px) and (max-width:1050px){header .inner{height:auto;min-height:82px;flex-wrap:wrap;padding-top:16px;padding-bottom:16px}nav{order:3;width:100%;flex-wrap:wrap}}
    @media(max-width:700px){header .inner{position:relative;padding-top:22px}header nav{padding-top:8px}.language-switch{position:absolute;right:24px;top:18px}}
    @media(prefers-color-scheme:dark){
      :root{color:#e4eee8;background:#101b17}
      header,footer{background:#15231d;border-color:#395044}
      a,.utility-card strong{color:#8fdbb5}
      nav a,footer,.lead,.hero-disclaimer,.help-note,.document p,.landing-section-head>p,.service-card>p:not(.service-label),.service-card ul,.utility-card p,.landing-mcp p,.open-project-copy>p:not(.eyebrow),.form-actions small,.report-list small,.steps p{color:#b6cbbf}
      .card,.service-card,.utility-card{background:#1a2b22;border-color:#395044;color:#e4eee8;box-shadow:none}
      .notice,.steps article,.landing-mcp,.open-project{background:#203b2d;border-color:#46795c}
      .eyebrow,.section-heading span,.service-number,.service-label,.utility-symbol,.steps b{color:#8fdbb5}
      .secondary,.service-status,.language-switch a[aria-current=true]{background:#294b39;color:#b0efca}
      .secondary:hover{background:#365f49;color:#dcf7e7}
      input,textarea,select,.result pre,.mcp-address,.landing-mcp code,.screenshot-grid figure{background:#111e18;color:#e4eee8;border-color:#506a5a}
      input::placeholder,textarea::placeholder{color:#a4b9ac;opacity:1}
      label em{color:#ffad8b}
      .report-list li,.field-list>div,.screenshot-grid img{border-color:#395044}
      .brand{background:#fff;padding:5px 9px;border-radius:8px}
      .brand-card{background:#fff;color:#14392e}.brand-card a{color:#176f54}
      button,.official{background:#176d4e;color:#fff}button:hover,.official:hover{background:#1e805d}
      .official.secondary{background:#294b39;color:#b0efca}
      a:focus-visible,button:focus-visible{outline-color:#8fdbb5}
    }
    """
  end

  defp layout(body, locale) do
    """
    <!doctype html><html lang="#{locale}"><head><link rel="icon" href="/marca/ecidadao-simbolo.svg" type="image/svg+xml"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><meta name="robots" content="index,follow"><title>#{t("eCidadão — Ajuda com serviços públicos", locale)}</title><meta name="description" content="#{t("Consulte filas SIGA e prepare rascunhos para reclamações, A Minha Rua e e-balcão. Serviço independente e gratuito.", locale)}"><style>
    :root{font-family:Inter,ui-sans-serif,system-ui,-apple-system,BlinkMacSystemFont,"Segoe UI",sans-serif;color:#14392e;background:#f3f6ef}*{box-sizing:border-box}body{margin:0}a{color:#176f54}header{background:#fff;border-bottom:1px solid #dce5d9}header .inner,main,footer .inner{max-width:1120px;margin:auto;padding:0 24px}header .inner{height:82px;display:flex;align-items:center;justify-content:space-between;gap:20px}.brand{font-size:25px;font-weight:800;letter-spacing:-.06em;text-decoration:none;color:#123b2e}.brand span{color:#28a36f}nav{display:flex;gap:22px}nav a{font-size:14px;text-decoration:none;color:#315348}main{padding-top:44px;padding-bottom:80px}.hero{max-width:820px;padding:40px 0 46px}.eyebrow,.section-heading span{text-transform:uppercase;letter-spacing:.12em;color:#238562;font-size:12px;font-weight:800}.hero h1,.document h1{font-size:clamp(42px,6.5vw,76px);line-height:1.05;letter-spacing:-.065em;margin:16px 0 20px}.lead{font-size:21px;line-height:1.5;color:#48645a;max-width:710px}.notice{background:#e8f3e8;border-left:4px solid #268e61;padding:16px 20px;line-height:1.55;border-radius:0 8px 8px 0}.card{background:#fff;border:1px solid #dce5d9;border-radius:18px;padding:clamp(24px,4vw,48px);box-shadow:0 12px 40px #20402b0a;margin-bottom:30px}.section-heading{margin-bottom:26px}.section-heading h2{font-size:30px;letter-spacing:-.04em;margin:8px 0}.grid{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:18px}label{display:block;font-size:14px;font-weight:700;margin-bottom:20px}label em{font-style:normal;color:#c25f32}input,textarea,select{display:block;width:100%;margin-top:8px;border:1px solid #cbd9cf;border-radius:9px;padding:13px 14px;font:inherit;color:#123b2e;background:#fbfcfa}input:focus,textarea:focus,select:focus{outline:2px solid #62b78b;outline-offset:1px}textarea{resize:vertical}button,.official{border:0;border-radius:9px;padding:14px 20px;background:#15734f;color:#fff;font:inherit;font-weight:700;cursor:pointer;text-decoration:none;display:inline-flex;gap:12px;justify-content:center}button:hover,.official:hover{background:#0c593c;color:#fff}.form-actions,.result-actions{display:flex;align-items:center;gap:18px;flex-wrap:wrap}.form-actions small{color:#5a7165;max-width:400px;line-height:1.4}.secondary{background:#e8f3e8;color:#175f45}.secondary:hover{background:#d8ebdd;color:#175f45}.result pre{white-space:pre-wrap;word-wrap:break-word;background:#f5f8f3;padding:22px;border:1px solid #dce5d9;border-radius:9px;line-height:1.55}.result .notice{margin-top:24px}.how{padding:42px 0}.steps{display:grid;grid-template-columns:repeat(3,1fr);gap:18px}.steps article{background:#e8f1e8;border-radius:14px;padding:26px}.steps b{color:#21815d}.steps h3{font-size:22px;margin:22px 0 6px}.steps p{color:#4f665a;line-height:1.5}.document{max-width:790px;min-height:65vh}.document p{font-size:18px;line-height:1.7;color:#425c50}.document h2{margin-top:32px}.report-list{list-style:none;padding:0;margin:24px 0 0}.report-list li{padding:16px 0;border-top:1px solid #dce5d9}.report-list li a{font-weight:700}.report-list small{display:block;margin-top:6px;color:#5a7165}.field-list{margin:24px 0}.field-list>div{display:grid;grid-template-columns:145px 1fr auto;align-items:start;gap:15px;border-top:1px solid #dce5d9;padding:14px 0}.field-list dt{font-weight:700}.field-list dd{margin:0;white-space:pre-wrap;overflow-wrap:anywhere}.field-list button{padding:8px 12px;font-size:13px}.landing-hero{display:grid;grid-template-columns:minmax(0,1.3fr) minmax(300px,.7fr);gap:44px;align-items:center;padding:24px 0 76px}.landing-copy h1{font-size:clamp(48px,6.4vw,82px);line-height:1.03;letter-spacing:-.065em;margin:16px 0 24px;max-width:800px}.landing-copy .lead{max-width:660px}.hero-actions{display:flex;gap:12px;flex-wrap:wrap;margin:30px 0 22px}.hero-disclaimer{color:#5a7165;line-height:1.55;max-width:620px}.hero-panel{background:#123b2e;color:#fff;border-radius:22px;padding:28px;box-shadow:0 20px 50px #123b2e20}.panel-kicker{text-transform:uppercase;letter-spacing:.12em;font-size:12px;font-weight:800;color:#a8d9bb}.hero-panel div{display:grid;grid-template-columns:46px 1fr auto;align-items:center;gap:12px;border-top:1px solid #ffffff36;padding:17px 0}.hero-panel div:first-of-type{margin-top:20px}.hero-panel b{color:#a8d9bb}.hero-panel span:not(.panel-kicker){font-weight:800;font-size:19px}.hero-panel small{color:#c8e2d3}.landing-section{padding:8px 0 72px}.landing-section-head{display:flex;justify-content:space-between;align-items:end;gap:35px;margin-bottom:26px}.landing-section-head h2{font-size:clamp(36px,5vw,58px);letter-spacing:-.06em;margin:9px 0 0}.landing-section-head>p{max-width:420px;line-height:1.55;color:#526b5d;margin:0}.service-grid{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:20px}.service-card{background:#fff;border:1px solid #dce5d9;border-radius:20px;padding:clamp(25px,4vw,38px);display:flex;flex-direction:column;min-height:430px;box-shadow:0 12px 40px #20402b0a}.service-top{display:flex;justify-content:space-between;align-items:center;gap:10px}.service-number{font-size:15px;font-weight:800;color:#238562}.service-status{font-size:12px;font-weight:800;background:#e8f3e8;color:#175f45;padding:7px 10px;border-radius:99px}.service-label{text-transform:uppercase;letter-spacing:.1em;font-size:12px;font-weight:800;color:#238562;margin:34px 0 7px}.service-card h3{font-size:35px;letter-spacing:-.05em;line-height:1.1;margin:0 0 12px}.service-card>p:not(.service-label){color:#48645a;line-height:1.55;font-size:17px;margin:0}.service-card ul{padding-left:20px;color:#48645a;line-height:1.75;margin:20px 0 28px}.service-actions{display:flex;align-items:center;gap:18px;flex-wrap:wrap;margin-top:auto}.service-actions>a:not(.official){font-weight:700}.service-siga{background:#f8fbf5}.service-financas{background:#f8fbfa}.service-rua{background:#fcfbf5}.service-reclamacoes{background:#fbf8f6}.utility-grid{display:grid;grid-template-columns:repeat(3,minmax(0,1fr));gap:18px}.utility-card{display:block;background:#fff;border:1px solid #dce5d9;border-radius:18px;padding:28px;text-decoration:none;color:#14392e;min-height:250px}.utility-card:hover{border-color:#74b995;box-shadow:0 12px 30px #20402b10}.utility-symbol{font-size:29px;color:#238562}.utility-card h3{font-size:23px;letter-spacing:-.03em;margin:17px 0 8px}.utility-card p{line-height:1.55;color:#526b5d}.utility-card strong{color:#176f54}.landing-mcp{display:grid;grid-template-columns:1.5fr 1fr;gap:32px;align-items:center;background:#e8f1e8;border-radius:20px;padding:clamp(26px,5vw,45px);margin-bottom:40px}.landing-mcp h2{font-size:32px;letter-spacing:-.04em;margin:8px 0}.landing-mcp p{color:#48645a;line-height:1.6}.landing-mcp code{display:block;overflow-wrap:anywhere;padding:15px;background:#fff;border-radius:9px;margin-bottom:16px;font-size:16px}.footer-links{display:flex;gap:18px;flex-wrap:wrap}.footer-links a{text-decoration:none}.simple-steps{padding-left:25px;line-height:1.7}.simple-steps li{margin-bottom:14px;font-size:17px}.mcp-address{background:#f5f8f3;border:1px solid #dce5d9;border-radius:9px;padding:17px;overflow-wrap:anywhere;font-size:18px}.help-note{color:#48645a;line-height:1.6}.screenshot-grid{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:22px}.screenshot-grid figure{margin:0;background:#f5f8f3;border:1px solid #dce5d9;border-radius:12px;padding:16px;text-align:center}.screenshot-grid img{display:block;width:100%;max-width:342px;height:auto;margin:0 auto;border-radius:9px;border:1px solid #dce5d9}.screenshot-grid figcaption{margin-top:12px;font-weight:700}footer{border-top:1px solid #dce5d9;background:#fff;color:#526b5d}footer .inner{padding-top:30px;padding-bottom:30px;display:flex;justify-content:space-between;gap:20px;font-size:13px}@media(max-width:700px){.landing-hero{grid-template-columns:1fr;padding-top:8px;gap:28px}.landing-copy h1{font-size:52px}.hero-panel div{grid-template-columns:38px 1fr}.hero-panel small{grid-column:2}.landing-section-head{display:block}.landing-section-head>p{margin-top:12px}.service-grid,.utility-grid,.landing-mcp{grid-template-columns:1fr}.service-card{min-height:0}.landing-mcp{margin-bottom:0}.footer-links{gap:12px}header .inner{height:auto;padding-top:18px;padding-bottom:18px;align-items:flex-start;flex-direction:column}nav{flex-wrap:wrap;gap:12px}.grid,.steps,.screenshot-grid{grid-template-columns:1fr}.hero{padding-top:10px}.hero h1{font-size:45px}.field-list>div{grid-template-columns:1fr auto}.field-list dd{grid-column:1 / -1;grid-row:2}}
    .brand{display:flex;align-items:center;flex-shrink:0}.brand img{display:block;width:168px;height:auto}.open-project{display:grid;grid-template-columns:minmax(0,1.6fr) minmax(0,1fr);gap:48px;align-items:center;margin:56px 0;padding:44px;background:#e8f3e8;border:1px solid #cbded0;border-radius:22px}.open-project h2{font-size:clamp(32px,4vw,46px);line-height:1.1;letter-spacing:-.045em;margin:12px 0 20px}.open-project-copy>p:not(.eyebrow){line-height:1.65;color:#315348}.open-project-links{display:flex;flex-direction:column;gap:10px;font-size:14px;margin:22px 0 0}.brand-card{background:#fff;border:1px solid #dce5d9;border-radius:16px;padding:32px 24px;text-align:center}.brand-card img{width:100%;height:auto}.brand-card p{font-size:14px;color:#48645a;margin-top:24px}.brand-card a{font-size:14px;font-weight:700}@media(max-width:760px){.open-project{grid-template-columns:1fr;gap:28px;padding:28px 22px}.brand img{width:145px}}
    </style><script>
    const uiMessages = #{EcidadaoWeb.Locale.client_messages(locale)};
    function ui(value) {
      if (typeof value !== 'string') return value;
      if (Object.hasOwn(uiMessages, value)) return uiMessages[value];
      if (document.documentElement.lang === 'en') {
        const limit = value.match(/^Máximo de (\\d+) caracteres\\.$/);
        if (limit) return 'Maximum ' + limit[1] + ' characters.';
        if (value.startsWith('Consulta SIGA indisponível:')) return 'SIGA search is unavailable.';
      }
      return value;
    }
    </script><meta name="color-scheme" content="light dark"><style>#{theme_css()}</style></head><body><header><div class="inner"><a class="brand" href="/" aria-label="#{t("eCidadão — início", locale)}"><img src="/marca/ecidadao-logo.svg" alt="eCidadão" width="1000" height="256"></a><nav><a href="/siga">SIGA / IRN</a><a href="/financas">#{t("Finanças", locale)}</a><a href="/a-minha-rua">A Minha Rua</a><a href="/reclamacoes">#{t("Reclamações", locale)}</a><a href="/como-usar">#{t("Como usar", locale)}</a></nav><div class="language-switch" role="group" aria-label="#{t("Idioma", locale)}"><a href="?lang=pt" lang="pt" hreflang="pt" aria-current="#{if locale == "pt", do: "true", else: "false"}">PT</a><a href="?lang=en" lang="en" hreflang="en" aria-current="#{if locale == "en", do: "true", else: "false"}">EN</a></div></div></header><main>#{body}</main><footer><div class="inner"><span>#{t("eCidadão · Projeto independente e gratuito", locale)}</span><div class="footer-links"><a href="https://github.com/ecidadao/ecidadao">#{t("Código aberto", locale)}</a><a href="https://github.com/ecidadao/plugins">Plugins</a><a href="https://github.com/ecidadao/ecidadao/blob/main/CONTRIBUTING.md">#{t("Contribuir", locale)}</a><a href="/apoio">#{t("Apoio", locale)}</a><a href="/privacidade">#{t("Privacidade", locale)}</a><a href="/termos">#{t("Termos", locale)}</a></div></div></footer><script>
    for (const link of document.querySelectorAll('.language-switch a')) {
      const url = new URL(location.href); url.searchParams.set('lang', link.lang); link.href = url.href;
    }
    </script></body></html>
    """
  end
end
