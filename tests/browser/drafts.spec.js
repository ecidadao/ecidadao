const fs = require('node:fs/promises');
const { test, expect } = require('./fixtures');

async function prepare(page, endpoint) {
  const responsePromise = page.waitForResponse(response => response.url().endsWith(endpoint) && response.request().method() === 'POST');
  await page.getByRole('button', { name: /Preparar/ }).click();
  const response = await responsePromise;
  expect(response.status()).toBe(200);
  const payload = await response.json();
  expect(payload.status).toBe('rascunho_nao_submetido');
  return payload;
}

test('consumer complaint uses the real local API and downloads its text', async ({ page }) => {
  await page.goto('/reclamacoes?lang=pt');
  await page.getByLabel('Empresa ou entidade reclamada').fill('Loja de exemplo');
  await page.getByLabel('O que aconteceu?').fill('O produto de demonstração chegou danificado.');
  await page.getByLabel('Que solução pretende?').fill('Solicito a substituição do produto de demonstração.');
  const payload = await prepare(page, '/api/complaints/prepare');
  await expect(page.locator('#draft')).toHaveText(payload.draft);
  expect(payload.draft).toContain('Loja de exemplo');
  const downloadPromise = page.waitForEvent('download');
  await page.getByRole('button', { name: 'Descarregar .txt' }).click();
  const download = await downloadPromise;
  expect(download.suggestedFilename()).toBe('reclamacao-rascunho.txt');
  expect(await fs.readFile(await download.path(), 'utf8')).toBe(payload.draft);
});

test('tax draft uses the real API and remains unsubmitted', async ({ page }) => {
  await page.goto('/financas?lang=pt');
  await page.getByLabel('Assunto').fill('Esclarecimento geral sobre IMI');
  await page.getByLabel('Área fiscal').fill('IMI');
  await page.getByLabel('Mensagem').fill('Onde posso consultar informação geral sobre os prazos de pagamento?');
  const payload = await prepare(page, '/api/financas/ebalcao/prepare');
  await expect(page.locator('#financas-draft')).toHaveText(payload.draft);
  await expect(page.locator('#financas-message')).toContainText('Ainda não foi enviado');
  await expect(page.locator('#financas-result a')).toHaveAttribute('href', 'https://sitfiscal.portaldasfinancas.gov.pt/ebalcao/formularioContacto');
});

const types = [
  ['complaint', 'fazer-reclamacao-de-um-servico-publico'],
  ['compliment', 'fazer-elogio-a-um-servico-publico'],
  ['suggestion', 'fazer-sugestao-a-um-servico-publico'],
];

async function feedback(page, type = 'complaint') {
  await page.goto('/livro-amarelo?lang=pt');
  await page.getByLabel('Tipo de participação').selectOption(type);
  await page.getByLabel('Entidade pública').fill('Serviço público de exemplo');
  await page.getByLabel('Assunto', { exact: false }).fill('Atendimento de demonstração');
  await page.getByLabel('Descrição').fill('Exemplo fictício para verificar a preparação local.');
  return prepare(page, '/api/public-feedback/prepare');
}

for (const [type, path] of types) {
  test(`Livro Amarelo ${type} maps to its official service`, async ({ page }) => {
    const payload = await feedback(page, type);
    await expect(page.locator('#feedback-draft')).toHaveText(payload.draft);
    await expect(page.locator('#feedback-message')).toContainText('Ainda não foi enviado');
    await expect(page.locator('#feedback-portal')).toHaveAttribute('href', `https://www.gov.pt/servicos/${path}`);
  });
}

test('editing feedback invalidates its draft and official action until prepared again', async ({ page }) => {
  await feedback(page);
  await page.getByLabel('Descrição').fill('Descrição de exemplo alterada.');
  await expect(page.locator('#feedback-result')).toBeHidden();
  await expect(page.locator('#feedback-draft')).toBeEmpty();
  await expect(page.locator('#feedback-portal')).not.toHaveAttribute('href');
  await expect(page.locator('#feedback-message')).toContainText('Prepare um novo rascunho');
  const updated = await prepare(page, '/api/public-feedback/prepare');
  await expect(page.locator('#feedback-draft')).toHaveText(updated.draft);
  expect(updated.draft).toContain('Descrição de exemplo alterada.');
  await page.getByLabel('Tipo de participação').selectOption('compliment');
  await expect(page.locator('#feedback-result')).toBeHidden();
});

test('clipboard rejection offers a selection fallback and a UTF-8 download', async ({ page }) => {
  await page.addInitScript(() => Object.defineProperty(navigator, 'clipboard', {
    value: { writeText: async () => { throw new DOMException('Test denial', 'NotAllowedError'); } },
  }));
  const payload = await feedback(page);
  await page.getByRole('button', { name: 'Copiar texto' }).click();
  await expect(page.locator('#feedback-message')).toContainText('Não foi possível copiar automaticamente');
  expect(await page.evaluate(() => getSelection().toString())).toBe(payload.draft);
  const downloadPromise = page.waitForEvent('download');
  await page.getByRole('button', { name: 'Descarregar .txt' }).click();
  const download = await downloadPromise;
  expect(download.suggestedFilename()).toBe('livro-amarelo-rascunho.txt');
  expect(await fs.readFile(await download.path(), 'utf8')).toBe(payload.draft);
});
