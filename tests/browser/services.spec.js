const { test, expect } = require('./fixtures');

const ids = ['cc-renewal', 'cc-address', 'cc-address-confirmation', 'siga', 'financas',
  'tax-certificates', 'street-report', 'consumer-complaint', 'public-feedback'];

for (const [locale, query] of [['pt', 'renovar cartao'], ['en', 'renew citizen card']]) {
  test(`service finder ${locale}: local search, empty state and reset`, async ({ page }) => {
    expect((await page.goto(`/servicos?lang=${locale}`)).status()).toBe(200);
    await expect(page.getByRole('heading', { level: 1 })).toHaveText(locale === 'pt' ? 'De que precisa?' : 'What do you need?');
    await expect(page.locator('html')).toHaveAttribute('lang', locale);
    const cards = page.locator('#service-results [data-service-id]');
    for (const id of ids) await expect(page.locator(`[data-service-id="${id}"]`)).toBeVisible();
    const total = await cards.count();
    for (const href of await cards.locator('a[href^="https:"]').evaluateAll(links => links.map(a => a.href))) {
      const target = new URL(href);
      expect(['www.gov.pt', 'www.portaldasfinancas.gov.pt']).toContain(target.hostname);
      expect(target.username + target.password).toBe('');
    }
    const url = page.url();
    const requests = [];
    page.on('request', request => requests.push(request.url()));
    const search = page.locator('#service-search');
    await search.fill(query);
    const renewal = page.locator('[data-service-id="cc-renewal"]');
    await expect(renewal).toBeVisible();
    await expect(renewal.locator('a[href="https://www.gov.pt/servicos/renovar-o-cartao-de-cidadao"]')).toBeVisible();
    await expect.poll(() => page.locator('#service-results [data-service-id][hidden]').count()).toBeGreaterThan(0);
    await expect(page.locator('#service-search-status')).toHaveAttribute('role', 'status');
    await expect(page.locator('#service-search-status')).not.toBeEmpty();
    await search.fill('reclamar');
    await expect(page.locator('#service-results a[href="/reclamacoes"]')).toBeVisible();
    await expect(page.locator('#service-results a[href="/livro-amarelo"]')).toBeVisible();
    await search.fill('zzzinexistentezzz');
    await expect(page.locator('#service-empty')).toBeVisible();
    await expect(page.locator('#service-results [data-service-id]:visible')).toHaveCount(0);
    await search.fill('');
    await expect(page.locator('#service-empty')).toBeHidden();
    await expect(page.locator('#service-results [data-service-id]:visible')).toHaveCount(total);
    expect(page.url()).toBe(url);
    expect(requests).toEqual([]);
    await page.setViewportSize({ width: 390, height: 844 });
    expect(await page.evaluate(() => document.documentElement.scrollWidth <= innerWidth)).toBe(true);
  });
}

test.describe('service directory without JavaScript', () => {
  test.use({ javaScriptEnabled: false });
  test('retains all services and working internal navigation', async ({ page, baseURL }) => {
    expect((await page.goto('/servicos?lang=pt')).status()).toBe(200);
    for (const id of ids) await expect(page.locator(`[data-service-id="${id}"]`)).toBeVisible();
    const internal = await page.locator('#service-results a[href^="/"]').evaluateAll(links => links.map(a => a.href));
    await page.locator('#service-results a[href="/reclamacoes"]').click();
    await expect(page.getByRole('heading', { level: 1 })).toHaveText('Uma reclamação clara começa por um bom rascunho.');
    for (const href of new Set(internal)) {
      expect(new URL(href).origin).toBe(baseURL);
      expect((await page.goto(href)).status()).toBe(200);
      await expect(page.getByRole('heading', { level: 1 })).toBeVisible();
    }
  });
});
