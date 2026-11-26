defmodule EcidadaoWeb.Page do
  @moduledoc false

  def landing do
    layout("""
    <section class="landing-hero">
      <div class="landing-copy">
        <p class="eyebrow">Serviços úteis · Portugal</p>
        <h1>O próximo passo fica mais simples.</h1>
        <p class="lead">Compare filas, encontre o serviço certo e prepare o que precisa de apresentar. O eCidadão ajuda a chegar ao portal oficial com tudo mais claro.</p>
        <div class="hero-actions"><a class="official" href="#servicos">Explorar serviços ↓</a><a class="official secondary" href="/como-usar">Usar com Claude ou ChatGPT ↗</a></div>
        <p class="hero-disclaimer">Projeto independente e gratuito. Senhas, marcações e pedidos são concluídos nos portais oficiais.</p>
      </div>
      <div class="hero-panel" aria-label="Serviços disponíveis">
        <span class="panel-kicker">O que pode fazer agora</span>
        <div><b>01</b><span>SIGA / IRN</span><small>Filas e marcações</small></div>
        <div><b>02</b><span>Finanças</span><small>Serviços e e-balcão</small></div>
        <div><b>03</b><span>A Minha Rua</span><small>Ocorrências</small></div>
        <div><b>04</b><span>Reclamações</span><small>Rascunhos</small></div>
      </div>
    </section>

    <section id="servicos" class="landing-section" aria-labelledby="servicos-title">
      <div class="landing-section-head"><div><p class="eyebrow">Escolha o seu percurso</p><h2 id="servicos-title">Serviços</h2></div><p>Comece pelo assunto que quer resolver. Cada percurso explica o que pode fazer aqui e onde termina a ação oficial.</p></div>
      <div class="service-grid">
        <article class="service-card service-siga"><div class="service-top"><span class="service-number">01</span><span class="service-status">Consulta pública</span></div><p class="service-label">Atendimento presencial</p><h3>SIGA / IRN</h3><p>Veja filas próximas, compare a espera publicada e encontre o caminho para uma senha ou marcação.</p><ul><li>Distância e espera por balcão</li><li>IRN Registo quando disponível no distrito</li><li>Conclusão no SIGA oficial</li></ul><div class="service-actions"><a class="official" href="/siga">Comparar filas ↗</a><a href="/siga?entidade=IRN%20Registo">Procurar IRN</a></div></article>
        <article class="service-card service-financas"><div class="service-top"><span class="service-number">02</span><span class="service-status">Rascunho</span></div><p class="service-label">Autoridade Tributária</p><h3>Finanças</h3><p>Encontre o ponto de entrada para IRS, IMI, pagamentos ou certidões e prepare uma questão para o e-balcão.</p><ul><li>Orientação para o portal</li><li>Assunto e mensagem para rever</li><li>Envio pela pessoa na AT</li></ul><div class="service-actions"><a class="official" href="/financas">Abrir Finanças ↗</a></div></article>
        <article class="service-card service-rua"><div class="service-top"><span class="service-number">03</span><span class="service-status">Consulta e rascunho</span></div><p class="service-label">Espaço público</p><h3>A Minha Rua</h3><p>Consulte ocorrências públicas recentes e prepare um reporte de problemas na sua rua.</p><ul><li>Entradas recentes do portal ARTE</li><li>Campos organizados para copiar</li><li>Envio e reCAPTCHA no portal oficial</li></ul><div class="service-actions"><a class="official" href="/a-minha-rua">Abrir A Minha Rua ↗</a></div></article>
        <article class="service-card service-reclamacoes"><div class="service-top"><span class="service-number">04</span><span class="service-status">Rascunho</span></div><p class="service-label">Direitos de consumo</p><h3>Reclamações</h3><p>Organize os factos e a solução pretendida antes de apresentar a reclamação no Livro de Reclamações Eletrónico.</p><ul><li>Texto claro e revisto por si</li><li>Sem conta e sem guardar o rascunho</li><li>Comprovativo emitido no portal oficial</li></ul><div class="service-actions"><a class="official" href="/reclamacoes">Preparar reclamação ↗</a></div></article>
      </div>
    </section>

    <section class="landing-section" aria-labelledby="utilitarios-title"><div class="landing-section-head"><div><p class="eyebrow">Mais formas de ajudar</p><h2 id="utilitarios-title">Utilitários</h2></div><p>Ferramentas pequenas para preparar o passo seguinte sem entregar credenciais ao eCidadão.</p></div><div class="utility-grid">
      <a class="utility-card" href="/como-usar"><span class="utility-symbol" aria-hidden="true">⌁</span><h3>MCP no telemóvel</h3><p>Seis ferramentas públicas para usar em conversas Claude ou ChatGPT. Veja passos simples e prints.</p><strong>Ver guia ↗</strong></a>
      <a class="utility-card" href="/a-minha-rua#recent-title"><span class="utility-symbol" aria-hidden="true">◎</span><h3>Ocorrências recentes</h3><p>Veja as últimas entradas públicas de A Minha Rua com ligação à fonte oficial.</p><strong>Consultar ↗</strong></a>
      <a class="utility-card" href="/financas"><span class="utility-symbol" aria-hidden="true">✎</span><h3>Rascunhos para copiar</h3><p>Prepare uma mensagem para o e-balcão, reveja-a e leve-a para o portal oficial.</p><strong>Começar ↗</strong></a>
    </div></section>

    <section id="contribuir" class="open-project" aria-labelledby="open-project-title">
      <div class="open-project-copy"><p class="eyebrow">Código aberto · Apache-2.0</p><h2 id="open-project-title">Um projecto aberto.<br>Com espaço para si.</h2><p>O eCidadão é independente, gratuito e aberto a contribuições. O código do site, do servidor MCP e dos plugins está no GitHub. Pode explorar, adaptar e ajudar a melhorar.</p><p>Encontrou um erro? Tem uma ideia para um serviço, quer melhorar os textos ou contribuir com código? A sua contribuição é bem-vinda.</p><div class="hero-actions"><a class="official" href="https://github.com/ecidadao/ecidadao">Ver código no GitHub ↗</a><a class="official secondary" href="https://github.com/ecidadao/ecidadao/blob/main/CONTRIBUTING.md">Como contribuir ↗</a></div><p class="open-project-links"><a href="https://github.com/ecidadao/ecidadao/issues">Reportar um problema ou sugerir uma ideia ↗</a><a href="https://github.com/ecidadao/plugins">Explorar os plugins ↗</a></p></div>
      <div class="brand-card"><img src="/marca/ecidadao-logo.svg" alt="eCidadão" width="1000" height="256" loading="lazy"><p>Uma identidade para partilhar.</p><a href="/marca/ecidadao-identidade.zip" download>Descarregar logótipo · SVG e PNG ↓</a><p><a href="/marca/ecidadao-github.png" download>Avatar para GitHub · PNG quadrado ↓</a></p></div>
    </section>

    <section class="landing-mcp" aria-labelledby="landing-mcp-title"><div><p class="eyebrow">Para apps e assistentes</p><h2 id="landing-mcp-title">Um MCP para vários serviços.</h2><p>O servidor está disponível em HTTPS. Os plugins para Codex e Claude Code estão disponíveis em GitHub, com código aberto e ligação ao MCP público.</p></div><div><code>https://ecidadao.pt/mcp/public</code><a class="official" href="/como-usar">Ver como ligar ↗</a></div></section>
    """)
  end

  def complaints do
    layout("""
    <section class="hero">
      <p class="eyebrow">Um projeto independente e gratuito</p>
      <h1>Uma reclamação clara começa por um bom rascunho.</h1>
      <p class="lead">Organize os factos, defina a solução pretendida e leve o texto ao Livro de Reclamações Eletrónico.</p>
      <p class="notice"><strong>O eCidadão não é um serviço do Estado.</strong> Preparar aqui um rascunho não apresenta uma reclamação. A submissão acontece apenas no portal oficial.</p>
    </section>
    <section class="card" aria-labelledby="form-title">
      <div class="section-heading"><span>01 / Preparar</span><h2 id="form-title">Conte-nos o que aconteceu</h2></div>
      <form id="complaint-form">
        <div class="grid">
          <label>Empresa ou entidade reclamada <em>*</em><input name="business_name" maxlength="160" required autocomplete="organization" placeholder="Nome da empresa"></label>
          <label>Referência da compra ou contrato<input name="reference" maxlength="100" placeholder="Opcional"></label>
          <label>O seu nome<input name="consumer_name" maxlength="120" autocomplete="name" placeholder="Opcional"></label>
          <label>O seu email<input name="consumer_email" maxlength="254" type="email" autocomplete="email" placeholder="Opcional"></label>
          <label>Data da ocorrência<input name="incident_date" type="date"></label>
        </div>
        <label>O que aconteceu? <em>*</em><textarea name="description" maxlength="5000" required rows="6" placeholder="Descreva os factos por ordem, com datas e valores relevantes."></textarea></label>
        <label>Que solução pretende? <em>*</em><textarea name="requested_resolution" maxlength="1500" required rows="3" placeholder="Por exemplo, reparação, substituição, reembolso ou esclarecimento."></textarea></label>
        <div class="form-actions"><button type="submit">Preparar rascunho <span aria-hidden="true">↗</span></button><small>Os dados enviados são processados em memória e não são guardados por este serviço.</small></div>
      </form>
      <div id="form-message" role="status" aria-live="polite"></div>
    </section>
    <section id="result" class="card result" hidden aria-labelledby="result-title">
      <div class="section-heading"><span>02 / Rever</span><h2 id="result-title">O seu rascunho</h2></div>
      <p>Reveja o texto. Pode copiá-lo ou descarregá-lo para continuar no portal oficial.</p>
      <pre id="draft"></pre>
      <div class="result-actions"><button type="button" id="copy-button">Copiar texto</button><button type="button" id="download-button" class="secondary">Descarregar .txt</button><a class="official" href="https://www.livroreclamacoes.pt/Inicio/" target="_blank" rel="noopener noreferrer">Abrir portal oficial ↗</a></div>
      <p class="notice">A reclamação só é apresentada depois de concluir os passos no portal oficial e receber o respetivo comprovativo.</p>
    </section>
    <section class="how"><div class="section-heading"><span>Como funciona</span><h2>Três passos, sem conta</h2></div><div class="steps"><article><b>01</b><h3>Descreva</h3><p>Indique a entidade, os factos e o que pretende.</p></article><article><b>02</b><h3>Reveja</h3><p>Receba um rascunho organizado e corrija o que for preciso.</p></article><article><b>03</b><h3>Apresente</h3><p>Copie o texto para o Livro de Reclamações Eletrónico e guarde o comprovativo.</p></article></div></section>
    <section class="card"><div class="section-heading"><span>Mais serviços</span><h2>Também podemos ajudar</h2></div><div class="steps"><article><h3>SIGA / IRN</h3><p>Compare filas públicas próximas e siga para a marcação oficial.</p><a href="/siga">Abrir ↗</a></article><article><h3>Finanças</h3><p>Encontre o serviço certo e prepare uma questão para o e-balcão.</p><a href="/financas">Abrir ↗</a></article><article><h3>A Minha Rua</h3><p>Consulte ocorrências recentes e prepare um reporte.</p><a href="/a-minha-rua">Abrir ↗</a></article></div></section>
    <section class="card"><div class="section-heading"><span>No telemóvel</span><h2>Quer usar no Claude ou ChatGPT?</h2></div><p>Veja três passos simples para ligar o MCP e prints reais do eCidadão no telefone.</p><a class="official" href="/como-usar">Ver passos e prints ↗</a></section>
    <script>
      const form = document.getElementById('complaint-form');
      const result = document.getElementById('result');
      const draft = document.getElementById('draft');
      const message = document.getElementById('form-message');
      form.addEventListener('submit', async (event) => {
        event.preventDefault(); message.textContent = 'A preparar…';
        const data = Object.fromEntries(new FormData(form));
        try {
          const response = await fetch('/api/complaints/prepare', {method:'POST', headers:{'content-type':'application/json'}, body:JSON.stringify(data)});
          const payload = await response.json();
          if (!response.ok) { message.textContent = (payload.errors || []).map(e => e.field + ': ' + e.message).join(' · ') || 'Não foi possível preparar o rascunho.'; return; }
          draft.textContent = payload.draft; result.hidden = false; message.textContent = 'Rascunho preparado.'; result.scrollIntoView({behavior:'smooth'});
        } catch (_) { message.textContent = 'Ocorreu um erro de ligação. Tente novamente.'; }
      });
      document.getElementById('copy-button').addEventListener('click', async () => { await navigator.clipboard.writeText(draft.textContent); message.textContent = 'Texto copiado.'; });
      document.getElementById('download-button').addEventListener('click', () => { const link = document.createElement('a'); link.href = URL.createObjectURL(new Blob([draft.textContent], {type:'text/plain;charset=utf-8'})); link.download = 'reclamacao-rascunho.txt'; link.click(); URL.revokeObjectURL(link.href); });
    </script>
    """)
  end

  def minha_rua do
    options =
      Ecidadao.MinhaRua.categories()
      |> Enum.map_join("", fn category -> "<option value=\"#{category}\">#{category}</option>" end)

    layout("""
    <section class="hero"><p class="eyebrow">A Minha Rua · ARTE</p><h1>Ajude a melhorar o espaço público.</h1><p class="lead">Consulte ocorrências recentes e organize um novo reporte para a autarquia.</p><p class="notice"><strong>O eCidadão é independente.</strong> O rascunho não é enviado. Para apresentar uma ocorrência, preencha o formulário oficial, resolva o reCAPTCHA e confirme o envio no portal A Minha Rua.</p></section>
    <section class="card" aria-labelledby="recent-title"><div class="section-heading"><span>Consulta pública</span><h2 id="recent-title">Ocorrências recentes</h2></div><p>Até dez entradas recentes da <a href="https://servicos.arte.gov.pt/Portal/AMR/situationsList.aspx" target="_blank" rel="noopener noreferrer">lista oficial</a>. Para pesquisar por localidade ou ver o histórico, use o portal.</p><div id="recent-message" role="status">A consultar…</div><ul id="recent-list" class="report-list"></ul></section>
    <section class="card" aria-labelledby="street-title"><div class="section-heading"><span>Preparar</span><h2 id="street-title">Nova ocorrência</h2></div><p>O portal oficial pede distrito, município, freguesia, morada, categoria, assunto e descrição. A morada e a descrição podem ficar públicas; não inclua dados pessoais nesses campos.</p>
      <form id="street-form"><div class="grid">
        <label>Distrito <em>*</em><input name="district" maxlength="100" required placeholder="Ex.: Porto"></label>
        <label>Município <em>*</em><input name="municipality" maxlength="100" required placeholder="Ex.: Matosinhos"></label>
        <label>Freguesia <em>*</em><input name="parish" maxlength="120" required placeholder="Ex.: Matosinhos e Leça da Palmeira"></label>
        <label>Morada da ocorrência <em>*</em><input name="address" maxlength="2000" required placeholder="Rua e referência do local"></label>
      </div>
      <label>Categoria <em>*</em><select name="category" required><option value="">Escolha uma categoria</option>#{options}</select></label>
      <label>Assunto <em>*</em><input name="subject" maxlength="255" required placeholder="Ex.: Candeeiro apagado junto à escola"></label>
      <label>Descrição <em>*</em><textarea name="description" maxlength="5000" required rows="5" placeholder="Descreva o problema, há quanto tempo ocorre e o impacto. Não inclua dados pessoais."></textarea></label>
      <div class="form-actions"><button type="submit">Preparar reporte <span aria-hidden="true">↗</span></button><small>O eCidadão não guarda o conteúdo nem pede nome, email ou telefone. Esses dados são inseridos apenas no portal oficial.</small></div></form><div id="street-message" role="status" aria-live="polite"></div>
    </section>
    <section id="street-result" class="card result" hidden aria-labelledby="street-result-title"><div class="section-heading"><span>Rever</span><h2 id="street-result-title">Campos preparados</h2></div><p>Copie cada campo para o <a href="https://servicos.arte.gov.pt/Portal/AMR/situationReport.aspx" target="_blank" rel="noopener noreferrer">formulário oficial</a>. Confirme que a autarquia está disponível, anexe uma fotografia se quiser, introduza o seu nome e email nesse portal e resolva o reCAPTCHA. Guarde o número do pedido após enviar.</p><dl id="street-fields" class="field-list"></dl><div class="result-actions"><button type="button" id="street-copy">Copiar rascunho completo</button><a class="official" href="https://servicos.arte.gov.pt/Portal/AMR/situationReport.aspx" target="_blank" rel="noopener noreferrer">Abrir formulário oficial ↗</a></div><p class="notice">Este rascunho ainda não foi enviado à autarquia.</p></section>
    <script>
      const recentMessage = document.getElementById('recent-message');
      const recentList = document.getElementById('recent-list');
      fetch('/api/street-reports/recent').then(async response => { if (!response.ok) throw new Error(); return response.json(); }).then(data => {
        recentMessage.textContent = 'Consulta: ' + new Date(data.fetched_at).toLocaleString('pt-PT') + (data.stale ? ' · dados em cache' : '');
        for (const report of data.reports) {
          const li = document.createElement('li'); const a = document.createElement('a'); a.href = report.official_url; a.target = '_blank'; a.rel = 'noopener noreferrer'; a.textContent = '#' + report.id + ' · ' + report.subject;
          const meta = document.createElement('small'); meta.textContent = report.date + ' · ' + report.locality + ' · ' + report.status;
          li.append(a, meta); recentList.append(li);
        }
      }).catch(() => { recentMessage.textContent = 'A lista oficial está temporariamente indisponível. Abra o portal para consultar diretamente.'; });

      const labels = {district:'Distrito', municipality:'Município', parish:'Freguesia', address:'Morada', category:'Categoria', subject:'Assunto', description:'Descrição'};
      const streetForm = document.getElementById('street-form');
      const streetResult = document.getElementById('street-result');
      const streetFields = document.getElementById('street-fields');
      const streetMessage = document.getElementById('street-message');
      let streetDraft = '';
      streetForm.addEventListener('submit', async event => {
        event.preventDefault(); streetMessage.textContent = 'A preparar…';
        try {
          const response = await fetch('/api/street-reports/prepare', {method:'POST', headers:{'content-type':'application/json'}, body:JSON.stringify(Object.fromEntries(new FormData(streetForm)))});
          const data = await response.json();
          if (!response.ok) { streetMessage.textContent = (data.errors || []).map(error => error.field + ': ' + error.message).join(' · ') || 'Não foi possível preparar o reporte.'; return; }
          streetDraft = data.draft; streetFields.replaceChildren();
          for (const [key, label] of Object.entries(labels)) {
            const row = document.createElement('div'); const dt = document.createElement('dt'); const dd = document.createElement('dd'); const copy = document.createElement('button');
            dt.textContent = label; dd.textContent = data.fields[key]; copy.type = 'button'; copy.className = 'secondary'; copy.textContent = 'Copiar';
            copy.addEventListener('click', async () => { await navigator.clipboard.writeText(data.fields[key]); streetMessage.textContent = label + ' copiado.'; });
            row.append(dt, dd, copy); streetFields.append(row);
          }
          streetResult.hidden = false; streetMessage.textContent = 'Reporte preparado. Ainda não foi enviado.'; streetResult.scrollIntoView({behavior:'smooth'});
        } catch (_) { streetMessage.textContent = 'Ocorreu um erro de ligação. Tente novamente.'; }
      });
      document.getElementById('street-copy').addEventListener('click', async () => { await navigator.clipboard.writeText(streetDraft); streetMessage.textContent = 'Rascunho copiado.'; });
    </script>
    """)
  end

  def siga do
    districts =
      Ecidadao.Siga.districts()
      |> Enum.map_join("", fn {name, id} -> "<option value=\"#{id}\">#{name}</option>" end)

    layout("""
    <section class="hero"><p class="eyebrow">SIGA · Consulta pública</p><h1>Compare filas perto de si.</h1><p class="lead">Consulte tempos de espera publicados pelo SIGA para uma entidade e tipo de senha. A distância é em linha reta; confirme a disponibilidade antes de sair.</p><p class="notice"><strong>Serviço independente.</strong> Esta consulta não emite senhas nem cria marcações. O SIGA pode alterar os tempos ou exigir email, autenticação e validação para concluir o atendimento.</p></section>
    <section class="card"><div class="section-heading"><span>Consultar</span><h2>Escolha a fila</h2></div>
      <form id="siga-form"><div class="grid">
        <label>Distrito <em>*</em><select name="district" required><option value="">Selecione</option>#{districts}</select></label>
        <label>Entidade <em>*</em><input name="entity" required maxlength="120" placeholder="Ex.: Autoridade Tributária e Aduaneira"></label>
        <label>Tipo de senha <em>*</em><input name="ticket_type" required maxlength="120" placeholder="Ex.: Atendimento Geral"></label>
        <label>Raio (km)<input name="radius_km" type="number" min="1" max="100" value="40" required></label>
        <label>Latitude <em>*</em><input name="latitude" type="number" step="any" min="-90" max="90" required placeholder="Use o botão de localização"></label>
        <label>Longitude <em>*</em><input name="longitude" type="number" step="any" min="-180" max="180" required placeholder="Use o botão de localização"></label>
      </div><div class="form-actions"><button type="button" id="siga-location" class="secondary">Usar a minha localização</button><button type="submit">Comparar filas ↗</button><small>A posição é usada para calcular a distância neste servidor. O SIGA recebe apenas distrito, entidade e tipo de senha.</small></div></form>
      <div id="siga-message" role="status" aria-live="polite"></div>
    </section>
    <section id="siga-result" class="card" hidden><div class="section-heading"><span>Resultado</span><h2>Filas encontradas</h2></div><p id="siga-summary"></p><ul id="siga-list" class="report-list"></ul><p class="notice">Os tempos são estimativas momentâneas; não incluem deslocação. Pesquise também os distritos vizinhos se o raio ultrapassar o distrito escolhido.</p></section>
    <section class="card"><div class="section-heading"><span>Concluir no portal oficial</span><h2>Precisa de uma senha ou marcação?</h2></div><div class="result-actions"><a class="official" href="https://siga.marcacaodeatendimento.pt/Senhas/TemposEspera" target="_blank" rel="noopener noreferrer">Consultar e tirar senha no SIGA ↗</a><a class="official secondary" href="https://siga.marcacaodeatendimento.pt/Marcacao/MarcacaoInicio" target="_blank" rel="noopener noreferrer">Agendar atendimento ↗</a></div></section>
    <script>
      const sigaForm = document.getElementById('siga-form');
      if (new URLSearchParams(location.search).get('entidade') === 'IRN Registo') sigaForm.elements.entity.value = 'IRN Registo';
      const sigaMessage = document.getElementById('siga-message');
      document.getElementById('siga-location').addEventListener('click', () => {
        if (!navigator.geolocation) { sigaMessage.textContent = 'Geolocalização indisponível. Pode introduzir as coordenadas manualmente.'; return; }
        sigaMessage.textContent = 'A pedir a sua localização…';
        navigator.geolocation.getCurrentPosition(p => { sigaForm.elements.latitude.value = p.coords.latitude; sigaForm.elements.longitude.value = p.coords.longitude; sigaMessage.textContent = 'Localização pronta. Reveja os dados antes de pesquisar.'; }, () => { sigaMessage.textContent = 'Não foi possível obter a localização. Pode introduzir as coordenadas manualmente.'; }, {enableHighAccuracy:false, timeout:10000});
      });
      sigaForm.addEventListener('submit', async event => {
        event.preventDefault(); sigaMessage.textContent = 'A consultar o SIGA…';
        const data = Object.fromEntries(new FormData(sigaForm));
        try {
          const response = await fetch('/api/siga/queues/compare', {method:'POST', headers:{'content-type':'application/json'}, body:JSON.stringify(data)});
          const payload = await response.json();
          if (!response.ok) { sigaMessage.textContent = (payload.errors || []).map(e => e.message + (e.options ? ' Opções: ' + e.options.join(', ') : '')).join(' · ') || 'Consulta indisponível.'; return; }
          const list = document.getElementById('siga-list'); list.replaceChildren();
          for (const place of payload.locations) {
            const li = document.createElement('li'); const title = document.createElement('strong'); title.textContent = place.name;
            const detail = document.createElement('small'); detail.textContent = place.distance_km + ' km · ' + place.state + ' · ' + (place.open && place.wait_minutes !== null ? place.wait_minutes + ' min de espera' : 'tempo não disponível') + ' · ' + place.people_waiting + ' pessoas em espera';
            const address = document.createElement('small'); address.textContent = place.address || '';
            li.append(title, detail, address); list.append(li);
          }
          document.getElementById('siga-summary').textContent = payload.total_in_radius + ' balcões no raio · ' + payload.entity + ' · ' + payload.ticket_type + ' · consultado em ' + new Date(payload.observed_at).toLocaleString('pt-PT');
          document.getElementById('siga-result').hidden = false; sigaMessage.textContent = payload.total_in_radius ? 'Consulta concluída.' : 'Não foram encontrados balcões neste raio para a seleção.';
        } catch (_) { sigaMessage.textContent = 'O SIGA está temporariamente indisponível. Consulte o portal oficial.'; }
      });
    </script>
    """)
  end

  def financas do
    layout("""
    <section class="hero"><p class="eyebrow">Portal das Finanças · Apoio</p><h1>Prepare a sua questão para o e-balcão.</h1><p class="lead">Organize o assunto e os factos antes de entrar no portal oficial da Autoridade Tributária.</p><p class="notice"><strong>O eCidadão é independente.</strong> Não acede à sua área pessoal, não lê dados fiscais nem envia pedidos à AT. Não introduza NIF, passwords, códigos ou documentos aqui.</p></section>
    <section class="card"><div class="section-heading"><span>Encontrar</span><h2>Que serviço procura?</h2></div><div class="steps"><article><h3>IRS e IMI</h3><p>Use a pesquisa do Portal das Finanças para escolher a operação certa.</p><a href="https://www.portaldasfinancas.gov.pt/at/html/index.html" target="_blank" rel="noopener noreferrer">Abrir portal ↗</a></article><article><h3>Pagamentos e certidões</h3><p>Confirme dados, referências e prazos na sua área autenticada.</p><a href="https://www.portaldasfinancas.gov.pt/at/html/index.html" target="_blank" rel="noopener noreferrer">Abrir portal ↗</a></article><article><h3>Dúvida individual</h3><p>Prepare abaixo uma questão e apresente-a no e-balcão.</p><a href="https://sitfiscal.portaldasfinancas.gov.pt/ebalcao/formularioContacto" target="_blank" rel="noopener noreferrer">Abrir e-balcão ↗</a></article></div></section>
    <section class="card"><div class="section-heading"><span>Preparar</span><h2>Rascunho para o e-balcão</h2></div><form id="financas-form"><label>Assunto <em>*</em><input name="subject" required maxlength="200" placeholder="O que precisa de esclarecer?"></label><label>Área fiscal, se souber<input name="tax_area" maxlength="100" placeholder="Ex.: IRS, IMI, IVA"></label><label>Mensagem <em>*</em><textarea name="message" required maxlength="5000" rows="7" placeholder="Descreva os factos e a pergunta, sem dados de identificação ou acesso."></textarea></label><div class="form-actions"><button type="submit">Preparar rascunho ↗</button><small>O texto é processado em memória e não é enviado à AT.</small></div></form><div id="financas-message" role="status" aria-live="polite"></div></section>
    <section id="financas-result" class="card result" hidden><div class="section-heading"><span>Rever</span><h2>Texto preparado</h2></div><pre id="financas-draft"></pre><div class="result-actions"><button type="button" id="financas-copy">Copiar texto</button><a class="official" href="https://sitfiscal.portaldasfinancas.gov.pt/ebalcao/formularioContacto" target="_blank" rel="noopener noreferrer">Abrir e-balcão oficial ↗</a></div><p class="notice">Autentique-se, escolha a categoria correta e registe a questão no portal. Só a AT emite o número do pedido.</p></section>
    <script>
      const financasForm = document.getElementById('financas-form'); const financasMessage = document.getElementById('financas-message'); const financasDraft = document.getElementById('financas-draft');
      financasForm.addEventListener('submit', async event => {
        event.preventDefault(); financasMessage.textContent = 'A preparar…';
        try {
          const response = await fetch('/api/financas/ebalcao/prepare', {method:'POST', headers:{'content-type':'application/json'}, body:JSON.stringify(Object.fromEntries(new FormData(financasForm)))});
          const payload = await response.json();
          if (!response.ok) { financasMessage.textContent = (payload.errors || []).map(e => e.field + ': ' + e.message).join(' · '); return; }
          financasDraft.textContent = payload.draft; document.getElementById('financas-result').hidden = false; financasMessage.textContent = 'Rascunho preparado. Ainda não foi enviado.';
        } catch (_) { financasMessage.textContent = 'Ocorreu um erro de ligação. Tente novamente.'; }
      });
      document.getElementById('financas-copy').addEventListener('click', async () => { await navigator.clipboard.writeText(financasDraft.textContent); financasMessage.textContent = 'Texto copiado.'; });
    </script>
    """)
  end

  def how_to_use do
    layout("""
    <section class="hero"><p class="eyebrow">Guia rápido · Telemóvel</p><h1>Use o eCidadão em poucos passos.</h1><p class="lead">Pode começar já no site. Se quiser conversar com as ferramentas, ligue o MCP ao Claude ou ao ChatGPT.</p><p class="notice"><strong>Estado do plugin:</strong> o MCP está online, mas o plugin eCidadão ainda não foi publicado no diretório do ChatGPT. Para o testar numa app, adicione o servidor MCP à sua conta quando essa opção estiver disponível.</p></section>

    <section class="card" aria-labelledby="mcp-title"><div class="section-heading"><span>01 / Ligar</span><h2 id="mcp-title">Copie o endereço do MCP</h2></div><p>Use este endereço nas opções de conectores ou plugins da sua app:</p><p class="mcp-address"><code>https://ecidadao.pt/mcp/public</code></p><div class="form-actions"><button type="button" id="copy-mcp">Copiar endereço</button><span id="copy-mcp-status" role="status" aria-live="polite"></span></div></section>

    <section class="card" aria-labelledby="claude-title"><div class="section-heading"><span>02 / Escolher app</span><h2 id="claude-title">No Claude</h2></div><ol class="simple-steps"><li>Abra <a href="https://claude.ai" target="_blank" rel="noopener noreferrer">claude.ai</a> e vá a <strong>Customize → Connectors → Add custom connector</strong>.</li><li>Dê o nome <strong>eCidadão</strong>, cole o endereço acima e escolha <strong>No sign in</strong>.</li><li>Na app Claude, abra uma conversa, toque em <strong>+ → Connectors</strong>, ative eCidadão e faça o seu pedido.</li></ol><p class="help-note">Em contas de equipa, um administrador pode ter de adicionar o conector primeiro. <a href="https://support.claude.com/en/articles/11175166-get-started-with-custom-connectors-using-remote-mcp" target="_blank" rel="noopener noreferrer">Instruções oficiais do Claude ↗</a></p></section>

    <section class="card" aria-labelledby="chatgpt-title"><div class="section-heading"><span>02 / Escolher app</span><h2 id="chatgpt-title">No ChatGPT</h2></div><ol class="simple-steps"><li>Abra <a href="https://chatgpt.com/plugins" target="_blank" rel="noopener noreferrer">ChatGPT Plugins</a> e escolha <strong>+ → Add custom MCP server</strong>, se essa opção estiver disponível na sua conta.</li><li>Cole o endereço acima, chame-lhe <strong>eCidadão</strong>, escolha ligação sem login e instale o plugin de teste.</li><li>Na app ChatGPT, abra uma conversa nova em <strong>Chat</strong> ou <strong>Work</strong>, escolha <strong>@eCidadão</strong> e diga o que precisa.</li></ol><p class="help-note">Para usar o eCidadão no telefone, escolha ChatGPT Chat ou Work. A documentação atual coloca os plugins do Codex na app de computador e no CLI. <a href="https://learn.chatgpt.com/docs/plugins" target="_blank" rel="noopener noreferrer">Ver documentação oficial ↗</a></p></section>

    <section class="card" aria-labelledby="examples-title"><div class="section-heading"><span>03 / Experimentar</span><h2 id="examples-title">Dois pedidos para começar</h2></div><div class="steps"><article><h3>Filas SIGA</h3><p>“Compara as filas da Autoridade Tributária num raio de 40 km de mim.” Confirme o local, o distrito e o tipo de senha quando a app pedir.</p></article><article><h3>Finanças</h3><p>“Prepara uma questão sobre IMI para o e-balcão.” Reveja o rascunho e envie-o apenas no portal oficial da AT.</p></article></div></section>

    <section class="card" aria-labelledby="prints-title"><div class="section-heading"><span>Prints reais</span><h2 id="prints-title">O que aparece no site móvel</h2></div><p>Estas capturas são do <strong>eCidadão no navegador do telemóvel</strong>, não das apps Claude ou ChatGPT. Os tempos SIGA são um exemplo capturado em 13 de novembro de 2026 e podem mudar.</p><div class="screenshot-grid">
      <figure><a href="/imagens/siga-passo.png" target="_blank"><img src="/imagens/siga-passo.png" width="342" height="954" alt="Formulário SIGA do eCidadão com distrito, entidade, senha, raio e localização"></a><figcaption>1. Escolha a fila SIGA.</figcaption></figure>
      <figure><a href="/imagens/siga-resultado.png" target="_blank"><img src="/imagens/siga-resultado.png" width="342" height="787" alt="Resultado SIGA com balcões, distância, estado e espera observada"></a><figcaption>2. Compare os balcões e confirme no SIGA.</figcaption></figure>
      <figure><a href="/imagens/financas-passo.png" target="_blank"><img src="/imagens/financas-passo.png" width="342" height="646" alt="Formulário de assunto e mensagem para preparar uma questão de Finanças"></a><figcaption>3. Escreva a questão para o e-balcão.</figcaption></figure>
      <figure><a href="/imagens/financas-rascunho.png" target="_blank"><img src="/imagens/financas-rascunho.png" width="342" height="821" alt="Rascunho não submetido para rever e copiar para o e-balcão oficial"></a><figcaption>4. Reveja, copie e conclua no portal oficial.</figcaption></figure>
    </div></section>
    <script>document.getElementById('copy-mcp').addEventListener('click', async () => { const status = document.getElementById('copy-mcp-status'); try { await navigator.clipboard.writeText('https://ecidadao.pt/mcp/public'); status.textContent = 'Endereço copiado.'; } catch (_) { status.textContent = 'Selecione e copie o endereço acima.'; } });</script>
    """)
  end

  def privacy do
    layout("""
    <section class="document"><p class="eyebrow">Transparência</p><h1>Privacidade</h1>
      <p>Responsável pelo tratamento: Código Inadiável — Programação Informática, Lda., NIF 515500780, Rua Alfredo Cunha 362, 4450-021 Matosinhos, Portugal. Contacto: <a href="mailto:hello@codeperf.io">hello@codeperf.io</a>.</p>
      <h2>Dados e finalidades</h2><p>Quando pede um rascunho de reclamação no site ou no MCP, tratamos os dados que fornecer: entidade reclamada, descrição dos factos, solução pretendida e, se os indicar, nome, email, referência e data. Para preparar uma ocorrência A Minha Rua, tratamos distrito, município, freguesia, morada, categoria, assunto e descrição. Para o e-balcão, tratamos o assunto e a mensagem que escrever. Para comparar filas SIGA, tratamos distrito, entidade, tipo de senha, raio e coordenadas fornecidas ou autorizadas. Usamo-los apenas para gerar a resposta pedida. Não criamos conta nem guardamos estes conteúdos numa base de dados. O navegador conserva o formulário enquanto a página estiver aberta; os ficheiros que descarregar ficam no seu dispositivo.</p>
      <p>Tratamos os dados técnicos necessários à ligação e segurança do serviço, como endereço IP, data, URL e código de resposta. A base do tratamento do pedido é a prestação do serviço solicitado; a segurança e o diagnóstico técnico assentam no nosso interesse legítimo em manter o serviço disponível e protegido. Não usamos os dados da reclamação para publicidade, definição de perfis ou decisões automatizadas.</p>
      <h2>Destinatários e conservação</h2><p>A Cloudflare fornece DNS, proteção e entrega de tráfego. O fornecedor do alojamento processa os pedidos para executar a aplicação. Estes prestadores podem tratar dados técnicos para prestar e proteger o serviço, incluindo em infraestrutura fora do Espaço Económico Europeu, sujeitos às garantias contratuais aplicáveis. Não enviamos rascunhos ao Livro de Reclamações Eletrónico, à ARTE ou às autarquias.</p>
      <p>Ao consultar ocorrências recentes, o nosso servidor lê até dez registos públicos do portal A Minha Rua e guarda essa resposta em memória por dois minutos para limitar pedidos ao portal. A consulta não transmite os seus campos de formulário à ARTE. Os registos públicos podem conter moradas e texto escrito por terceiros; confirme sempre os detalhes no portal oficial.</p>
      <p>Na comparação SIGA, o nosso servidor consulta as filas públicas por distrito, entidade e tipo de senha. Calcula a distância com as coordenadas em memória; não as envia ao SIGA. O e-balcão recebe o texto apenas quando o copiar e registar no portal oficial.</p>
      <p>O conteúdo submetido é processado em memória e eliminado após a resposta. Os registos de acesso mantidos pelo serviço não contêm o corpo dos pedidos e são eliminados no prazo máximo de 7 dias. Se nos escrever por email, conservamos a mensagem enquanto for necessária para responder e cumprir eventuais obrigações legais.</p>
      <h2>ChatGPT e direitos</h2><p>Se usar o eCidadão através do ChatGPT, a conversa também é tratada pela OpenAI segundo as condições e definições da sua conta. O cartão de fotografia pode pedir acesso à câmara e, apenas se tocar em «Usar localização», à posição do dispositivo. Ao continuar, a fotografia e a localização escolhida são partilhadas com a conversa do ChatGPT para preparar uma prévia; o nosso servidor recebe apenas a descrição factual selecionada pelo modelo e, quando disponível, uma indicação aproximada de cidade ou região. Não guardamos a fotografia nem as coordenadas no servidor e não as enviamos a serviços públicos nesta fase.</p><p>Pode evitar partilhar dados pessoais opcionais. Tem direitos de acesso, retificação, apagamento, limitação e oposição nos termos legais; contacte-nos em <a href="mailto:hello@codeperf.io">hello@codeperf.io</a>. Pode reclamar junto da <a href="https://www.cnpd.pt/" target="_blank" rel="noopener noreferrer">CNPD</a>.</p>
      <p>Última atualização: 13 de novembro de 2026.</p>
    </section>
    """)
  end

  def terms do
    layout("""
    <section class="document"><p class="eyebrow">Utilização</p><h1>Termos de utilização</h1>
      <p>O eCidadão é disponibilizado gratuitamente por Código Inadiável — Programação Informática, Lda., NIF 515500780, Rua Alfredo Cunha 362, 4450-021 Matosinhos, Portugal. Contacto: <a href="mailto:hello@codeperf.io">hello@codeperf.io</a>.</p>
      <h2>O que o serviço faz</h2><p>O serviço ajuda a organizar rascunhos de reclamações de consumo, ocorrências sobre espaço público e questões para o e-balcão; consulta ocorrências públicas recentes de A Minha Rua e filas públicas SIGA; e fornece orientação geral. É independente: não representa o Estado, a ARTE, autarquias, a Direção-Geral do Consumidor, a AT, o SIGA ou o Livro de Reclamações Eletrónico. Não apresenta reclamações ou ocorrências, não consulta processos privados, não emite senhas ou comprovativos e não presta aconselhamento jurídico ou fiscal.</p>
      <h2>Responsabilidade do utilizador</h2><p>Reveja e corrija o texto antes de o usar. Envie apenas informação que tenha o direito de partilhar e evite documentos de identificação ou dados de terceiros desnecessários. Para apresentar uma reclamação, siga os passos no <a href="https://www.livroreclamacoes.pt/Inicio/" target="_blank" rel="noopener noreferrer">Livro de Reclamações Eletrónico</a>. Para comunicar uma ocorrência, use o <a href="https://servicos.arte.gov.pt/Portal/AMR/situationReport.aspx" target="_blank" rel="noopener noreferrer">portal A Minha Rua</a>. Guarde o comprovativo ou número emitido pelo portal respetivo.</p>
      <h2>Disponibilidade e contacto</h2><p>Procuramos manter o serviço disponível e correto, mas podem ocorrer interrupções ou erros. Podemos corrigir ou alterar funcionalidades; alterações relevantes destes termos serão publicadas nesta página. Para apoio ou questões sobre o serviço, escreva para <a href="mailto:hello@codeperf.io">hello@codeperf.io</a>.</p>
      <p>Última atualização: 13 de novembro de 2026.</p>
    </section>
    """)
  end

  def support do
    layout("""
    <section class="document"><p class="eyebrow">Estamos aqui</p><h1>Apoio</h1>
      <p>Para dificuldades com o site, o MCP, SIGA, Finanças, uma reclamação ou uma ocorrência A Minha Rua, escreva para <a href="mailto:hello@codeperf.io">hello@codeperf.io</a>. Indique o problema e o momento aproximado em que aconteceu; não envie passwords, códigos de autenticação ou documentos de identificação.</p>
      <p>Para apresentar uma reclamação oficial ou consultar o seu estado, use o <a href="https://www.livroreclamacoes.pt/Inicio/" target="_blank" rel="noopener noreferrer">Livro de Reclamações Eletrónico</a>. O eCidadão não tem acesso aos processos desse portal e não emite comprovativos.</p>
      <p>Para enviar ou consultar uma ocorrência sobre espaço público, use o <a href="https://servicos.arte.gov.pt/Portal/AMR/situationsList.aspx" target="_blank" rel="noopener noreferrer">portal A Minha Rua</a>. O eCidadão só apresenta as entradas públicas recentes; o envio e o acompanhamento oficial acontecem no portal da ARTE.</p>
      <p>Responsável pelo serviço: Código Inadiável — Programação Informática, Lda., Rua Alfredo Cunha 362, 4450-021 Matosinhos, Portugal.</p>
    </section>
    """)
  end

  defp layout(body) do
    """
    <!doctype html><html lang="pt"><head><link rel="icon" href="/marca/ecidadao-simbolo.svg" type="image/svg+xml"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><meta name="robots" content="index,follow"><title>eCidadão — Ajuda com serviços públicos</title><meta name="description" content="Consulte filas SIGA e prepare rascunhos para reclamações, A Minha Rua e e-balcão. Serviço independente e gratuito."><style>
    :root{font-family:Inter,ui-sans-serif,system-ui,-apple-system,BlinkMacSystemFont,"Segoe UI",sans-serif;color:#14392e;background:#f3f6ef}*{box-sizing:border-box}body{margin:0}a{color:#176f54}header{background:#fff;border-bottom:1px solid #dce5d9}header .inner,main,footer .inner{max-width:1120px;margin:auto;padding:0 24px}header .inner{height:82px;display:flex;align-items:center;justify-content:space-between;gap:20px}.brand{font-size:25px;font-weight:800;letter-spacing:-.06em;text-decoration:none;color:#123b2e}.brand span{color:#28a36f}nav{display:flex;gap:22px}nav a{font-size:14px;text-decoration:none;color:#315348}main{padding-top:44px;padding-bottom:80px}.hero{max-width:820px;padding:40px 0 46px}.eyebrow,.section-heading span{text-transform:uppercase;letter-spacing:.12em;color:#238562;font-size:12px;font-weight:800}.hero h1,.document h1{font-size:clamp(42px,6.5vw,76px);line-height:1.05;letter-spacing:-.065em;margin:16px 0 20px}.lead{font-size:21px;line-height:1.5;color:#48645a;max-width:710px}.notice{background:#e8f3e8;border-left:4px solid #268e61;padding:16px 20px;line-height:1.55;border-radius:0 8px 8px 0}.card{background:#fff;border:1px solid #dce5d9;border-radius:18px;padding:clamp(24px,4vw,48px);box-shadow:0 12px 40px #20402b0a;margin-bottom:30px}.section-heading{margin-bottom:26px}.section-heading h2{font-size:30px;letter-spacing:-.04em;margin:8px 0}.grid{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:18px}label{display:block;font-size:14px;font-weight:700;margin-bottom:20px}label em{font-style:normal;color:#c25f32}input,textarea,select{display:block;width:100%;margin-top:8px;border:1px solid #cbd9cf;border-radius:9px;padding:13px 14px;font:inherit;color:#123b2e;background:#fbfcfa}input:focus,textarea:focus,select:focus{outline:2px solid #62b78b;outline-offset:1px}textarea{resize:vertical}button,.official{border:0;border-radius:9px;padding:14px 20px;background:#15734f;color:#fff;font:inherit;font-weight:700;cursor:pointer;text-decoration:none;display:inline-flex;gap:12px;justify-content:center}button:hover,.official:hover{background:#0c593c;color:#fff}.form-actions,.result-actions{display:flex;align-items:center;gap:18px;flex-wrap:wrap}.form-actions small{color:#5a7165;max-width:400px;line-height:1.4}.secondary{background:#e8f3e8;color:#175f45}.secondary:hover{background:#d8ebdd;color:#175f45}.result pre{white-space:pre-wrap;word-wrap:break-word;background:#f5f8f3;padding:22px;border:1px solid #dce5d9;border-radius:9px;line-height:1.55}.result .notice{margin-top:24px}.how{padding:42px 0}.steps{display:grid;grid-template-columns:repeat(3,1fr);gap:18px}.steps article{background:#e8f1e8;border-radius:14px;padding:26px}.steps b{color:#21815d}.steps h3{font-size:22px;margin:22px 0 6px}.steps p{color:#4f665a;line-height:1.5}.document{max-width:790px;min-height:65vh}.document p{font-size:18px;line-height:1.7;color:#425c50}.document h2{margin-top:32px}.report-list{list-style:none;padding:0;margin:24px 0 0}.report-list li{padding:16px 0;border-top:1px solid #dce5d9}.report-list li a{font-weight:700}.report-list small{display:block;margin-top:6px;color:#5a7165}.field-list{margin:24px 0}.field-list>div{display:grid;grid-template-columns:145px 1fr auto;align-items:start;gap:15px;border-top:1px solid #dce5d9;padding:14px 0}.field-list dt{font-weight:700}.field-list dd{margin:0;white-space:pre-wrap;overflow-wrap:anywhere}.field-list button{padding:8px 12px;font-size:13px}.landing-hero{display:grid;grid-template-columns:minmax(0,1.3fr) minmax(300px,.7fr);gap:44px;align-items:center;padding:24px 0 76px}.landing-copy h1{font-size:clamp(48px,6.4vw,82px);line-height:1.03;letter-spacing:-.065em;margin:16px 0 24px;max-width:800px}.landing-copy .lead{max-width:660px}.hero-actions{display:flex;gap:12px;flex-wrap:wrap;margin:30px 0 22px}.hero-disclaimer{color:#5a7165;line-height:1.55;max-width:620px}.hero-panel{background:#123b2e;color:#fff;border-radius:22px;padding:28px;box-shadow:0 20px 50px #123b2e20}.panel-kicker{text-transform:uppercase;letter-spacing:.12em;font-size:12px;font-weight:800;color:#a8d9bb}.hero-panel div{display:grid;grid-template-columns:46px 1fr auto;align-items:center;gap:12px;border-top:1px solid #ffffff36;padding:17px 0}.hero-panel div:first-of-type{margin-top:20px}.hero-panel b{color:#a8d9bb}.hero-panel span:not(.panel-kicker){font-weight:800;font-size:19px}.hero-panel small{color:#c8e2d3}.landing-section{padding:8px 0 72px}.landing-section-head{display:flex;justify-content:space-between;align-items:end;gap:35px;margin-bottom:26px}.landing-section-head h2{font-size:clamp(36px,5vw,58px);letter-spacing:-.06em;margin:9px 0 0}.landing-section-head>p{max-width:420px;line-height:1.55;color:#526b5d;margin:0}.service-grid{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:20px}.service-card{background:#fff;border:1px solid #dce5d9;border-radius:20px;padding:clamp(25px,4vw,38px);display:flex;flex-direction:column;min-height:430px;box-shadow:0 12px 40px #20402b0a}.service-top{display:flex;justify-content:space-between;align-items:center;gap:10px}.service-number{font-size:15px;font-weight:800;color:#238562}.service-status{font-size:12px;font-weight:800;background:#e8f3e8;color:#175f45;padding:7px 10px;border-radius:99px}.service-label{text-transform:uppercase;letter-spacing:.1em;font-size:12px;font-weight:800;color:#238562;margin:34px 0 7px}.service-card h3{font-size:35px;letter-spacing:-.05em;line-height:1.1;margin:0 0 12px}.service-card>p:not(.service-label){color:#48645a;line-height:1.55;font-size:17px;margin:0}.service-card ul{padding-left:20px;color:#48645a;line-height:1.75;margin:20px 0 28px}.service-actions{display:flex;align-items:center;gap:18px;flex-wrap:wrap;margin-top:auto}.service-actions>a:not(.official){font-weight:700}.service-siga{background:#f8fbf5}.service-financas{background:#f8fbfa}.service-rua{background:#fcfbf5}.service-reclamacoes{background:#fbf8f6}.utility-grid{display:grid;grid-template-columns:repeat(3,minmax(0,1fr));gap:18px}.utility-card{display:block;background:#fff;border:1px solid #dce5d9;border-radius:18px;padding:28px;text-decoration:none;color:#14392e;min-height:250px}.utility-card:hover{border-color:#74b995;box-shadow:0 12px 30px #20402b10}.utility-symbol{font-size:29px;color:#238562}.utility-card h3{font-size:23px;letter-spacing:-.03em;margin:17px 0 8px}.utility-card p{line-height:1.55;color:#526b5d}.utility-card strong{color:#176f54}.landing-mcp{display:grid;grid-template-columns:1.5fr 1fr;gap:32px;align-items:center;background:#e8f1e8;border-radius:20px;padding:clamp(26px,5vw,45px);margin-bottom:40px}.landing-mcp h2{font-size:32px;letter-spacing:-.04em;margin:8px 0}.landing-mcp p{color:#48645a;line-height:1.6}.landing-mcp code{display:block;overflow-wrap:anywhere;padding:15px;background:#fff;border-radius:9px;margin-bottom:16px;font-size:16px}.footer-links{display:flex;gap:18px;flex-wrap:wrap}.footer-links a{text-decoration:none}.simple-steps{padding-left:25px;line-height:1.7}.simple-steps li{margin-bottom:14px;font-size:17px}.mcp-address{background:#f5f8f3;border:1px solid #dce5d9;border-radius:9px;padding:17px;overflow-wrap:anywhere;font-size:18px}.help-note{color:#48645a;line-height:1.6}.screenshot-grid{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:22px}.screenshot-grid figure{margin:0;background:#f5f8f3;border:1px solid #dce5d9;border-radius:12px;padding:16px;text-align:center}.screenshot-grid img{display:block;width:100%;max-width:342px;height:auto;margin:0 auto;border-radius:9px;border:1px solid #dce5d9}.screenshot-grid figcaption{margin-top:12px;font-weight:700}footer{border-top:1px solid #dce5d9;background:#fff;color:#526b5d}footer .inner{padding-top:30px;padding-bottom:30px;display:flex;justify-content:space-between;gap:20px;font-size:13px}@media(max-width:700px){.landing-hero{grid-template-columns:1fr;padding-top:8px;gap:28px}.landing-copy h1{font-size:52px}.hero-panel div{grid-template-columns:38px 1fr}.hero-panel small{grid-column:2}.landing-section-head{display:block}.landing-section-head>p{margin-top:12px}.service-grid,.utility-grid,.landing-mcp{grid-template-columns:1fr}.service-card{min-height:0}.landing-mcp{margin-bottom:0}.footer-links{gap:12px}header .inner{height:auto;padding-top:18px;padding-bottom:18px;align-items:flex-start;flex-direction:column}nav{flex-wrap:wrap;gap:12px}.grid,.steps,.screenshot-grid{grid-template-columns:1fr}.hero{padding-top:10px}.hero h1{font-size:45px}.field-list>div{grid-template-columns:1fr auto}.field-list dd{grid-column:1 / -1;grid-row:2}}
    .brand{display:flex;align-items:center;flex-shrink:0}.brand img{display:block;width:168px;height:auto}.open-project{display:grid;grid-template-columns:minmax(0,1.6fr) minmax(0,1fr);gap:48px;align-items:center;margin:56px 0;padding:44px;background:#e8f3e8;border:1px solid #cbded0;border-radius:22px}.open-project h2{font-size:clamp(32px,4vw,46px);line-height:1.1;letter-spacing:-.045em;margin:12px 0 20px}.open-project-copy>p:not(.eyebrow){line-height:1.65;color:#315348}.open-project-links{display:flex;flex-direction:column;gap:10px;font-size:14px;margin:22px 0 0}.brand-card{background:#fff;border:1px solid #dce5d9;border-radius:16px;padding:32px 24px;text-align:center}.brand-card img{width:100%;height:auto}.brand-card p{font-size:14px;color:#48645a;margin-top:24px}.brand-card a{font-size:14px;font-weight:700}@media(max-width:760px){.open-project{grid-template-columns:1fr;gap:28px;padding:28px 22px}.brand img{width:145px}}
    </style></head><body><header><div class="inner"><a class="brand" href="/" aria-label="eCidadão — início"><img src="/marca/ecidadao-logo.svg" alt="eCidadão" width="1000" height="256"></a><nav><a href="/siga">SIGA / IRN</a><a href="/financas">Finanças</a><a href="/a-minha-rua">A Minha Rua</a><a href="/reclamacoes">Reclamações</a><a href="/como-usar">Como usar</a></nav></div></header><main>#{body}</main><footer><div class="inner"><span>eCidadão · Projeto independente e gratuito</span><div class="footer-links"><a href="https://github.com/ecidadao/ecidadao">Código aberto</a><a href="https://github.com/ecidadao/plugins">Plugins</a><a href="https://github.com/ecidadao/ecidadao/blob/main/CONTRIBUTING.md">Contribuir</a><a href="/apoio">Apoio</a><a href="/privacidade">Privacidade</a><a href="/termos">Termos</a></div></div></footer></body></html>
    """
  end
end
