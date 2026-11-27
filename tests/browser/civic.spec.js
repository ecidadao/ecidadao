const { test, expect } = require('./fixtures');

for (const locale of ['pt', 'en']) {
  test(`municipal search ${locale}: initial results, safe success, empty and retry`, async ({ page }) => {
    await page.goto(`/municipios?lang=${locale}`);
    await expect(page.locator('#municipal-results article')).toHaveCount(12);
    await expect(page.locator('html')).toHaveAttribute('lang', locale);
    await expect(page.locator('a[href="/vagas?lang=' + locale + '"]')).toBeVisible();
    const url = page.url();
    let mode = 'success';
    await page.route('**/api/municipal/services', async route => {
      // Keep initial cards visible long enough to exercise asynchronous replacement.
      await new Promise(resolve => setTimeout(resolve, 100));
      expect(route.request().method()).toBe('POST');
      expect(route.request().postDataJSON()).toEqual({ municipality: 'maia', query: 'parking', limit: 30, language: locale });
      if (mode === 'error') return route.fulfill({ status: 503, json: {} });
      return route.fulfill({ json: { total: mode === 'empty' ? 0 : 1, results: mode === 'empty' ? [] : [{
        id: 'maia-example', municipality: 'maia', title: '<img src=x onerror=alert(1)>', category: 'Trânsito',
        official_url: mode === 'unsafe' ? 'javascript:alert(1)' : 'https://diretorio.cm-maia.pt/example',
        source: 'https://diretorio.cm-maia.pt/todos-os-servicos-de-a-a-z', verified_on: '2026-11-27'
      }] } });
    });
    await page.locator('#municipality').selectOption('maia');
    await page.locator('#municipal-query').fill('parking');
    const submit = page.locator('#municipal-form button');
    await submit.click();
    await expect(page.locator('#municipal-results h2')).toHaveCount(1);
    await expect(page.locator('#municipal-results h2')).toHaveText('<img src=x onerror=alert(1)>');
    await expect(page.locator('#municipal-results img')).toHaveCount(0);
    await expect(page.locator('#municipal-results a').first()).toHaveAttribute('href', 'https://diretorio.cm-maia.pt/example');
    await expect(page.locator('#municipal-status')).toContainText('1');
    for (mode of ['empty', 'error', 'unsafe']) {
      await submit.click();
      await expect(page.locator('#municipal-status')).toContainText(mode === 'empty'
        ? (locale === 'pt' ? 'Não encontrámos' : 'No services found')
        : (locale === 'pt' ? 'Não foi possível' : 'Search could not'));
      await expect(page.locator('#municipal-results article')).toHaveCount(0);
      await expect(submit).toBeEnabled();
      await expect(page.locator('#municipal-results')).toHaveAttribute('aria-busy', 'false');
    }
    mode = 'success';
    await submit.click();
    await expect(page.locator('#municipal-results article')).toHaveCount(1);
    expect(page.url()).toBe(url);
  });

  test(`support ${locale}: seven guides, distinct phases and mobile dark layout`, async ({ page }) => {
    await page.setViewportSize({ width: 390, height: 844 });
    await page.emulateMedia({ colorScheme: 'dark' });
    await page.goto(`/apoios?lang=${locale}`);
    await expect(page.locator('#support-results > article')).toHaveCount(7);
    const elar = page.locator('[data-support-id="elar"]');
    await expect(elar.locator('[data-phase="new_application"]')).toContainText(locale === 'pt' ? 'Encerrado' : 'Closed');
    await expect(elar.locator('[data-phase="supplier_payment_request"]')).toContainText('2026-11-30');
    const vale = page.locator('[data-support-id="vale_efficiency"]');
    await expect(vale.locator('[data-phase="new_application"]')).toContainText('2024-10-31');
    await expect(vale.locator('[data-phase="existing_beneficiary_expression_of_interest"]')).toContainText('2027-01-25');
    await expect(page.locator('#support-results input, #support-results textarea')).toHaveCount(0);
    await elar.locator('summary').click();
    await expect(elar.locator('details')).toContainText('2026-11-27');
    expect(await page.evaluate(() => document.documentElement.scrollWidth <= innerWidth)).toBe(true);
    await page.goto(`/municipios?lang=${locale}`);
    expect(await page.evaluate(() => document.documentElement.scrollWidth <= innerWidth)).toBe(true);
  });
}

test('Gondomar source links open the human portal and retain service destinations', async ({ page }) => {
  await page.goto('/municipios?lang=pt');
  await expect(page.locator('a[href="https://servicosonline.cm-gondomar.pt/"]')).toHaveCount(13);
  await expect(page.locator('a[href*="MyNetMenuExterno"]')).toHaveCount(0);
  const destination = 'https://servicosonline.cm-gondomar.pt/MyNetFormBD.asp?intmenu=10748&formato=SPO_menu_10748';
  await page.route('**/api/municipal/services', route => route.fulfill({ json: {
    total: 1, results: [{ id: 'gondomar-10748', municipality: 'gondomar', title: 'Candidatura ao Eixo + Habitação',
      official_url: destination, source: 'https://servicosonline.cm-gondomar.pt/MyNetMenuExterno.asp?objecto=json', verified_on: '2026-11-27' }]
  } }));
  await page.locator('#municipality').selectOption('gondomar');
  await page.locator('#municipal-form button').click();
  await expect(page.locator('#municipal-results article')).toHaveCount(1);
  await expect(page.locator('#municipal-results a').first()).toHaveAttribute('href', destination);
  await expect(page.locator('#municipal-results a').last()).toHaveAttribute('href', 'https://servicosonline.cm-gondomar.pt/');
});

test.describe('civic pages without JavaScript', () => {
  test.use({ javaScriptEnabled: false });
  test('catalogue links and support checklists remain usable', async ({ page }) => {
    await page.goto('/municipios?lang=pt');
    await expect(page.locator('#municipal-form')).toBeHidden();
    await expect(page.locator('#municipal-results article')).toHaveCount(12);
    await expect(page.locator('#municipal-results a').first()).toBeVisible();
    await page.goto('/apoios?lang=pt');
    await expect(page.locator('#support-results > article')).toHaveCount(7);
    await expect(page.locator('[data-support-id="porta65_young"] li').first()).toBeVisible();
  });
});
