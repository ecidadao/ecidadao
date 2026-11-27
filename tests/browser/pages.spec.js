const { test, expect } = require('./fixtures');

const pages = [
  ['/', 'Veja onde o eCidadão pode ajudar.', 'See where eCidadão can help.'],
  ['/sobre', 'O próximo passo fica mais simples.', 'Your next step, made simpler.'],
  ['/reclamacoes', 'Uma reclamação clara começa por um bom rascunho.', 'A clear complaint starts with a good draft.'],
  ['/livro-amarelo', 'Ajude a melhorar os serviços públicos.', 'Help improve public services.'],
  ['/a-minha-rua', 'Ajude a melhorar o espaço público.', 'Help improve public spaces.'],
  ['/siga', 'Compare filas perto de si.', 'Compare queues near you.'],
  ['/financas', 'Prepare a sua questão para o e-balcão.', 'Prepare your question for e-balcão.'],
  ['/como-usar', 'Use o eCidadão em poucos passos.', 'Use eCidadão in a few steps.'],
  ['/privacidade', 'Privacidade', 'Privacy'],
  ['/termos', 'Termos de utilização', 'Terms of use'],
  ['/apoio', 'Apoio', 'Support'],
];

for (const [path, pt, en] of pages) {
  for (const [locale, heading] of [['pt', pt], ['en', en]]) {
    test(`${path} ${locale}: heading and mobile layout`, async ({ page }) => {
      await page.setViewportSize({ width: 390, height: 844 });
      const response = await page.goto(`${path}?lang=${locale}`);
      expect(response.status()).toBe(200);
      await expect(page.locator('html')).toHaveAttribute('lang', locale);
      await expect(page.getByRole('heading', { level: 1 })).toHaveText(heading);
      expect(await page.evaluate(() => document.documentElement.scrollWidth <= innerWidth)).toBe(true);
    });
  }
}

test('explicit language survives navigation and reload', async ({ page }) => {
  await page.goto('/?lang=pt');
  await page.getByRole('link', { name: 'EN', exact: true }).click();
  await page.locator('nav').getByRole('link', { name: 'Livro Amarelo' }).click();
  await page.reload();
  await expect(page.locator('html')).toHaveAttribute('lang', 'en');
  await expect(page.getByRole('heading', { level: 1 })).toHaveText('Help improve public services.');
  await page.getByRole('link', { name: 'PT', exact: true }).click();
  await page.goto('/financas');
  await expect(page.locator('html')).toHaveAttribute('lang', 'pt');
});

for (const locale of ['en-GB', 'pt-PT']) {
  test.describe(`browser language ${locale}`, () => {
    test.use({ locale });
    test('is detected without a saved choice', async ({ page }) => {
      await page.goto('/');
      await expect(page.locator('html')).toHaveAttribute('lang', locale.slice(0, 2));
    });
  });
}

test('system theme changes while the page stays open', async ({ page }) => {
  await page.emulateMedia({ colorScheme: 'light' });
  await page.goto('/');
  const background = () => page.locator('html').evaluate(el => getComputedStyle(el).backgroundColor);
  const light = await background();
  await page.emulateMedia({ colorScheme: 'dark' });
  await expect.poll(background).not.toBe(light);
  await page.emulateMedia({ colorScheme: 'light' });
  await expect.poll(background).toBe(light);
});

test('internal navigation resolves and official links use intended hosts', async ({ page, baseURL }) => {
  const internal = new Set();
  const hosts = new Set(['www.gov.pt', 'www.livroreclamacoes.pt', 'servicos.arte.gov.pt',
    'siga.marcacaodeatendimento.pt', 'www.portaldasfinancas.gov.pt', 'sitfiscal.portaldasfinancas.gov.pt',
    'github.com']); // The project source CTA shares the .official button style.
  for (const [path] of pages) {
    await page.goto(`${path}?lang=pt`);
    for (const href of await page.locator('a[href]').evaluateAll(links => links.map(a => a.href))) {
      const url = new URL(href);
      if (url.origin === baseURL && !url.pathname.startsWith('/marca/')) internal.add(url.pathname + url.search);
    }
    for (const href of await page.locator('a.official[href^="https:"]').evaluateAll(links => links.map(a => a.href))) {
      const url = new URL(href);
      expect(hosts.has(url.hostname), href).toBe(true);
      expect(url.username + url.password).toBe('');
    }
  }
  for (const path of internal) {
    const response = await page.goto(path);
    expect(response.status(), path).toBe(200);
    if (response.headers()['content-type']?.includes('text/html')) {
      await expect(page.getByRole('heading', { level: 1 }), path).toBeVisible();
    }
  }
});

test('recent street reports render the isolated fixture', async ({ page }) => {
  await page.goto('/a-minha-rua?lang=pt');
  await expect(page.locator('#recent-list')).toContainText('Candeeiro de exemplo');
});

test('SIGA renders queue results without requesting or booking a ticket', async ({ page }) => {
  await page.goto('/siga?lang=pt');
  await page.getByLabel('Distrito').selectOption({ label: 'Porto' });
  await page.getByLabel('Entidade', { exact: false }).fill('IRN Registo');
  await page.getByLabel('Tipo de senha').fill('Atendimento Geral');
  await page.getByLabel('Latitude').fill('41.15');
  await page.getByLabel('Longitude').fill('-8.61');
  await page.getByRole('button', { name: 'Comparar filas' }).click();
  await expect(page.locator('#siga-result')).toContainText('Balcão de exemplo');
  await expect(page.locator('#siga-list')).toContainText('12 min de espera');
});
