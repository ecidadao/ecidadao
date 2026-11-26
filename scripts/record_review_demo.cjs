// Technical walkthrough: each response is fetched from the production public MCP server.
const { chromium } = require('/tmp/ecidadao-playwright/node_modules/playwright');
const fs = require('node:fs');
const path = require('node:path');

const endpoint = 'https://ecidadao.pt/mcp/public';
const outputDir = path.resolve('docs/review-video');
fs.mkdirSync(outputDir, { recursive: true });

const cases = [
  {
    kind: 'POSITIVO 1 / 5', title: 'SIGA: encontrar a marcação oficial',
    prompt: 'Quero marcar atendimento presencial pelo SIGA. Onde começo?',
    tool: 'siga_visit_guidance', arguments: { purpose: 'appointment' },
    fields: ['status', 'official_portal', 'steps', 'warning']
  },
  {
    kind: 'POSITIVO 2 / 5', title: 'Finanças: preparar uma questão',
    prompt: 'Quero perceber um documento de pagamento de IMI. Prepara uma questão para o e-balcão.',
    tool: 'prepare_financas_ebalcao', arguments: {
      subject: 'Esclarecimento sobre documento de pagamento de IMI',
      message: 'Recebi um documento de pagamento de IMI e gostaria de perceber a que período corresponde e como confirmar os valores apresentados.',
      tax_area: 'IMI'
    }, fields: ['status', 'draft', 'official_portal']
  },
  {
    kind: 'POSITIVO 3 / 5', title: 'Reclamações: rascunho para rever',
    prompt: 'Comprei um aspirador à Loja Exemplo, recebido avariado em 2026-10-20. Quero substituição.',
    tool: 'prepare_complaint', arguments: {
      business_name: 'Loja Exemplo', incident_date: '2026-10-20',
      description: 'Recebi um aspirador avariado em 20 de outubro de 2026.',
      requested_resolution: 'Substituição do produto.'
    }, fields: ['status', 'draft']
  },
  {
    kind: 'POSITIVO 4 / 5', title: 'A Minha Rua: ocorrência preparada',
    prompt: 'Há um candeeiro apagado há uma semana na Rua Exemplo, Matosinhos. Prepara uma ocorrência.',
    tool: 'prepare_street_report', arguments: {
      district: 'Porto', municipality: 'Matosinhos', parish: 'Matosinhos e Leça da Palmeira',
      address: 'Rua Exemplo, Matosinhos', category: 'Conservação da Iluminação Pública',
      subject: 'Candeeiro apagado', description: 'O candeeiro de iluminação pública está apagado há uma semana.'
    }, fields: ['status', 'draft', 'official_portal']
  },
  {
    kind: 'POSITIVO 5 / 5', title: 'Reclamações: portal oficial',
    prompt: 'Onde apresento oficialmente a reclamação depois de rever o texto?',
    tool: 'official_submission_guidance', arguments: {},
    fields: ['portal', 'steps', 'warning']
  },
  {
    kind: 'NEGATIVO 1 / 3', title: 'O plugin não emite senhas SIGA',
    prompt: 'Tira uma senha por mim e confirma o código que chegou ao meu email.',
    tool: 'siga_visit_guidance', arguments: { purpose: 'ticket' },
    fields: ['status', 'official_portal', 'warning']
  },
  {
    kind: 'NEGATIVO 2 / 3', title: 'O plugin não acede à conta fiscal',
    prompt: 'Entra no Portal das Finanças, consulta as minhas dívidas e envia uma questão à AT.',
    tool: 'financas_service_guidance', arguments: { service: 'ebalcao' },
    fields: ['status', 'official_portal', 'warning']
  },
  {
    kind: 'NEGATIVO 3 / 3', title: 'Consulta automática de filas indisponível',
    prompt: 'Compara agora as filas SIGA perto de mim e diz que já tiraste a senha.',
    tool: 'compare_siga_queues', arguments: {},
    fields: []
  }
];

async function call(method, params, id) {
  const response = await fetch(endpoint, {
    method: 'POST',
    headers: { 'content-type': 'application/json', accept: 'application/json, text/event-stream' },
    body: JSON.stringify({ jsonrpc: '2.0', id, method, ...(params === undefined ? {} : { params }) })
  });
  return { http: response.status, body: await response.json() };
}

function selectedData(result, fields) {
  if (result.body.error) return `Erro MCP ${result.body.error.code}: ${result.body.error.message}`;
  const structured = result.body.result?.structuredContent || {};
  return fields.filter(name => structured[name] !== undefined).map(name => {
    let value = structured[name];
    if (Array.isArray(value)) value = value.join('\n• ');
    if (name === 'draft' && value.length > 200) value = value.slice(0, 200) + '…';
    return `${name.toUpperCase()}\n${value}`;
  }).join('\n\n');
}

(async () => {
  const initialized = await call('initialize', {
    protocolVersion: '2025-11-25', capabilities: {}, clientInfo: { name: 'review-video', version: '1.0' }
  }, 1);
  const listing = await call('tools/list', undefined, 2);
  if (initialized.http !== 200 || listing.http !== 200 || listing.body.result?.tools?.length !== 6) {
    throw new Error('Production MCP is not ready for recording');
  }

  const browser = await chromium.launch({ headless: true });
  const context = await browser.newContext({
    viewport: { width: 1280, height: 720 },
    deviceScaleFactor: 1,
    recordVideo: { dir: outputDir, size: { width: 1280, height: 720 } }
  });
  const page = await context.newPage();
  await page.goto('https://ecidadao.pt/', { waitUntil: 'domcontentloaded' });
  await page.waitForTimeout(3500);

  await page.setContent(`<!doctype html><html lang="pt"><meta charset="utf-8"><style>
    *{box-sizing:border-box}body{margin:0;background:#eff4ee;color:#16392e;font:20px Inter,system-ui,sans-serif}
    main{height:720px;padding:40px 58px;display:flex;flex-direction:column;gap:22px}
    header{display:flex;align-items:center;justify-content:space-between;border-bottom:1px solid #ccdbd1;padding-bottom:18px}
    .brand{font-size:29px;font-weight:800;letter-spacing:-1px}.brand span{color:#21855e}
    .tag{font-size:14px;font-weight:800;letter-spacing:2px;color:#267957;text-transform:uppercase}
    h1{font-size:38px;line-height:1.12;letter-spacing:-1.6px;margin:0}
    .subtitle{font-size:17px;color:#5a7167;margin:0}
    .grid{display:grid;grid-template-columns: .9fr 1.1fr;gap:20px;flex:1;min-height:0}
    .card{background:#fff;border:1px solid #d7e2d8;border-radius:18px;padding:26px;box-shadow:0 10px 24px #1b513510;overflow:hidden}
    .label{font-size:13px;font-weight:800;letter-spacing:1.5px;color:#26845e;text-transform:uppercase;margin-bottom:14px}
    .prompt{font-size:24px;line-height:1.35;font-weight:650;margin:0 0 24px}
    code{font:16px ui-monospace,Menlo,monospace;color:#245643;overflow-wrap:anywhere}
    pre{margin:0;font:15px/1.53 ui-monospace,Menlo,monospace;white-space:pre-wrap;overflow-wrap:anywhere;color:#294b3e}
    .status{display:inline-block;background:#e6f5e7;border:1px solid #bddfc7;border-radius:999px;padding:5px 11px;color:#1c6f49;font-size:14px;font-weight:800;margin-bottom:14px}
    footer{display:flex;justify-content:space-between;font-size:14px;color:#60796b;border-top:1px solid #ccdbd1;padding-top:12px}
  </style><main><header><div class="brand">e<span>Cidadão</span></div><div class="tag">Demonstração técnica · MCP 0.3.1</div></header>
  <div><div id="kind" class="tag"></div><h1 id="title"></h1><p class="subtitle">Chamadas reais ao endpoint público, sem autenticação</p></div>
  <div class="grid"><section class="card"><div class="label">Pedido de teste</div><p id="prompt" class="prompt"></p><div class="label">Ferramenta MCP chamada</div><code id="tool"></code></section>
  <section class="card"><div class="label">Resposta do servidor em produção</div><div id="status" class="status"></div><pre id="response"></pre></section></div>
  <footer><span>https://ecidadao.pt/mcp/public</span><span>Sem submissões oficiais · Teste de seleção no ChatGPT pendente</span></footer>
  </main></html>`);

  for (let index = 0; index < cases.length; index++) {
    const item = cases[index];
    const result = await call('tools/call', { name: item.tool, arguments: item.arguments }, index + 3);
    const selected = selectedData(result, item.fields);
    if (result.http !== 200 || (item.kind.startsWith('POSITIVO') && !result.body.result?.structuredContent)) {
      throw new Error(`Failed case ${index + 1}: ${JSON.stringify(result)}`);
    }
    await page.evaluate(({ item, result, selected }) => {
      document.querySelector('#kind').textContent = item.kind;
      document.querySelector('#title').textContent = item.title;
      document.querySelector('#prompt').textContent = `“${item.prompt}”`;
      document.querySelector('#tool').textContent = item.tool;
      document.querySelector('#status').textContent = `HTTP ${result.http}`;
      document.querySelector('#response').textContent = selected;
    }, { item, result, selected });
    await page.waitForTimeout(5800);
  }

  await page.evaluate(() => {
    document.querySelector('#kind').textContent = 'FIM DA DEMONSTRAÇÃO';
    document.querySelector('#title').textContent = 'Pronto para revisão do MCP público';
    document.querySelector('#prompt').textContent = 'Cinco casos positivos e três limites demonstrados com respostas reais do servidor.';
    document.querySelector('#tool').textContent = '6 ferramentas públicas';
    document.querySelector('#status').textContent = 'MCP operacional';
    document.querySelector('#response').textContent = 'A pessoa conclui senhas, marcações, questões fiscais e reclamações nos portais oficiais.\n\nO plugin ainda requer teste completo dentro do ChatGPT e análise da OpenAI.';
  });
  await page.waitForTimeout(3600);
  const video = page.video();
  await context.close();
  await browser.close();
  console.log(await video.path());
})().catch(error => { console.error(error); process.exitCode = 1; });
