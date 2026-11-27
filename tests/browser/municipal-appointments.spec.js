const { test, expect } = require('./fixtures');

const api = '**/api/municipal/appointments';
const common = { checked_at: '2026-11-27T13:32:10Z', submitted: false, reserved: false };
const areas = { ...common, status: 'areas_listed', areas: [
  { id: 7, name: 'Consulta de Processo sem Técnico - DOP' },
  { id: 9, name: 'Serviços Jurídicos DAG' },
] };
const dates = { ...common, status: 'available_at_check_time', dates: ['2026-12-02', '2026-12-03'] };
const slots = date => ({ ...common, status: 'available_at_check_time', slots: [
  { date, starts_at: '09:30', ends_at: '10:30', timezone: 'Europe/Lisbon' },
] });
async function loadServices(page) {
  await page.locator('#municipal-load').click();
  await expect(page.locator('#municipal-service')).toBeEnabled();
}
async function normal(route) {
  const input = route.request().postDataJSON();
  await route.fulfill({ json: input.date ? slots(input.date) : input.service_id ? dates : areas });
}

for (const language of ['pt', 'en']) {
  test(`municipal availability ${language}: explicit read, complete flow, mobile and night`, async ({ page }) => {
    const requests = [];
    await page.route(api, route => { requests.push(route.request().postDataJSON()); return normal(route); });
    await page.setViewportSize({ width: 390, height: 844 });
    await page.emulateMedia({ colorScheme: 'dark' });
    expect((await page.goto(`/vagas?lang=${language}`)).status()).toBe(200);
    await expect(page.locator('html')).toHaveAttribute('lang', language);
    await expect(page.getByRole('heading', { level: 1 })).toHaveText(language === 'en' ? 'Find municipal appointment availability.' : 'Consulte vagas de atendimento municipal.');
    await expect(page.locator('#municipal-service')).toBeDisabled();
    expect(requests).toEqual([]);
    await loadServices(page);
    await expect(page.locator('#municipal-status')).toContainText(language === 'en' ? 'Choose a service' : 'Escolha um serviço');
    await page.locator('#municipal-service').selectOption('7');
    await expect(page.locator('#municipal-date')).toBeEnabled();
    await page.locator('#municipal-date').selectOption('2026-12-02');
    await expect(page.locator('#municipal-slots')).toContainText('2026-12-02 · 09:30–10:30 · Europe/Lisbon');
    await expect(page.locator('#municipal-checked')).toHaveText(common.checked_at + ' (UTC)');
    await expect(page.locator('#municipal-status')).toContainText(language === 'en' ? 'No appointment has been reserved' : 'Nenhuma marcação foi reservada');
    expect(requests).toEqual([
      { municipality: 'ponte_de_lima', language },
      { municipality: 'ponte_de_lima', language, service_id: 7 },
      { municipality: 'ponte_de_lima', language, service_id: 7, date: '2026-12-02' },
    ]);
    await expect(page.locator('#municipal-availability a.official')).toHaveAttribute('href', 'https://www.cm-pontedelima.pt/pages/1606');
    expect(await page.evaluate(() => document.documentElement.scrollWidth <= innerWidth)).toBe(true);
    const dark = await page.locator('html').evaluate(el => getComputedStyle(el).backgroundColor);
    await page.emulateMedia({ colorScheme: 'light' });
    await expect.poll(() => page.locator('html').evaluate(el => getComputedStyle(el).backgroundColor)).not.toBe(dark);
    await page.locator('#municipal-load').click();
    await expect(page.locator('#municipal-date')).toBeDisabled();
    await expect(page.locator('#municipal-results')).toBeHidden();
    await expect(page.locator('#municipal-service')).toHaveValue('');
  });
}

test('municipal failures never become empty availability and can be retried', async ({ page }) => {
  let failing = true;
  await page.route(api, route => failing ? route.fulfill({ status: 503, json: { error: 'source_unavailable' } }) : normal(route));
  await page.goto('/vagas?lang=en');
  await page.locator('#municipal-load').click();
  await expect(page.locator('#municipal-error')).toContainText('This does not mean there are no appointments');
  await expect(page.locator('#municipal-observation')).toBeHidden();
  await expect(page.locator('#municipal-status')).toBeEmpty();
  failing = false;
  await page.locator('#municipal-retry').click();
  await expect(page.locator('#municipal-service')).toBeEnabled();
  await expect(page.locator('#municipal-error')).toBeHidden();
});

test('empty dates and slots are distinct successful observations', async ({ page }) => {
  let emptyDates = true;
  await page.route(api, route => {
    const args = route.request().postDataJSON();
    if (args.date) return route.fulfill({ json: { ...common, status: 'no_availability', slots: [] } });
    if (args.service_id && emptyDates) return route.fulfill({ json: { ...common, status: 'no_availability', dates: [] } });
    return normal(route);
  });
  await page.goto('/vagas?lang=en');
  await loadServices(page);
  await page.locator('#municipal-service').selectOption('7');
  await expect(page.locator('#municipal-status')).toContainText('No available dates');
  await expect(page.locator('#municipal-date')).toBeDisabled();
  await expect(page.locator('#municipal-error')).toBeHidden();
  emptyDates = false;
  await page.locator('#municipal-service').selectOption('9');
  await expect(page.locator('#municipal-date')).toBeEnabled();
  await page.locator('#municipal-date').selectOption('2026-12-02');
  await expect(page.locator('#municipal-status')).toContainText('No times available on this date');
  await expect(page.locator('#municipal-observation')).toBeVisible();
  await expect(page.locator('#municipal-results')).toBeHidden();
});

test('rate limiting retries exactly once and only for HTTP 429', async ({ page }) => {
  let count = 0;
  await page.route(api, route => { count++; return route.fulfill({ status: 429, json: { error: 'rate_limited' } }); });
  await page.goto('/vagas?lang=en');
  await page.locator('#municipal-load').click();
  await expect(page.locator('#municipal-status')).toContainText('Waiting briefly');
  await expect(page.locator('#municipal-error')).toContainText('Too many queries');
  expect(count).toBe(2);
  await page.unroute(api);
  await page.route(api, route => { count++; return route.fulfill({ status: 422, json: { error: 'invalid_service_id' } }); });
  await page.locator('#municipal-retry').click();
  await expect(page.locator('#municipal-error')).toContainText('could not be completed');
  expect(count).toBe(3);
});

test('malformed successful responses are errors and names are inserted as text', async ({ page }) => {
  await page.route(api, route => route.fulfill({ json: { ...areas, areas: [{ id: 7, name: '<img src=x onerror=alert(1)>' }] } }));
  await page.goto('/vagas?lang=en');
  await loadServices(page);
  await expect(page.locator('#municipal-service option').last()).toHaveText('<img src=x onerror=alert(1)>');
  await expect(page.locator('#municipal-availability img')).toHaveCount(0);
  await page.unroute(api);
  await page.route(api, route => route.fulfill({ json: { ...common, status: 'no_availability' } }));
  await page.locator('#municipal-service').selectOption('7');
  await expect(page.locator('#municipal-error')).toBeVisible();
  await expect(page.locator('#municipal-observation')).toBeHidden();
});

for (const kind of ['service', 'date']) {
  test(`late ${kind} response cannot restore a stale selection`, async ({ page }) => {
    let release, started;
    const waiting = new Promise(resolve => { started = resolve; });
    const gate = new Promise(resolve => { release = resolve; });
    await page.route(api, async route => {
      const args = route.request().postDataJSON();
      const delay = kind === 'service' ? args.service_id === 7 : args.date === '2026-12-02';
      if (delay) {
        started();
        await gate;
        await route.fulfill({ json: kind === 'service' ? { ...dates, dates: ['2026-12-09'] } : slots(args.date) }).catch(() => {});
      } else await normal(route);
    });
    await page.goto('/vagas?lang=en');
    await loadServices(page);
    await page.locator('#municipal-service').selectOption(kind === 'service' ? '7' : '9');
    if (kind === 'date') {
      await expect(page.locator('#municipal-date')).toBeEnabled();
      await page.locator('#municipal-date').selectOption('2026-12-02');
    }
    await waiting;
    await expect(page.locator('#municipal-status')).toContainText('Checking');
    await expect(page.locator('#municipal-observation')).toBeHidden();
    await page.locator(`#municipal-${kind}`).selectOption(kind === 'service' ? '9' : '2026-12-03');
    await expect(page.locator('#municipal-status')).toContainText(kind === 'service' ? 'Choose a date' : 'Times available');
    release();
    // A sentinel response ensures the old handler has had a chance to finish.
    await page.evaluate(() => new Promise(resolve => requestAnimationFrame(() => requestAnimationFrame(resolve))));
    if (kind === 'service') {
      await expect(page.locator('#municipal-date option')).toHaveCount(3);
      await expect(page.locator('#municipal-date')).not.toContainText('2026-12-09');
      await expect(page.locator('#municipal-service')).toHaveValue('9');
    } else {
      await expect(page.locator('#municipal-slots')).toContainText('2026-12-03');
      await expect(page.locator('#municipal-slots')).not.toContainText('2026-12-02');
    }
  });
}
