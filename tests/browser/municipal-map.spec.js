const { test, expect } = require('./fixtures');
const api = '**/api/municipal/coverage?*';
const tile = 'https://tile.openstreetmap.org/**';
const png = Buffer.from('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+jRZkAAAAASUVORK5CYII=', 'base64');
function coverage(language = 'pt') {
  return { language, generated_at: '2026-11-27T15:00:00Z', verified_on: '2026-11-27', revision: 'fixture', municipality_count: 3, total_service_count: 320,
    municipalities: [
      ['gondomar', 'Gondomar', 41.102349, -8.478341, 165],
      ['maia', 'Maia', 41.2375, -8.604624, 97],
      ['ponte_de_lima', 'Ponte de Lima', 41.767, -8.58, 58],
    ].map(([id, name, latitude, longitude, service_count]) => ({id, name, latitude, longitude, service_count, code: 'fixture',
      availability_lookup: id === 'ponte_de_lima', tools: ['municipal_service_search', ...(id === 'ponte_de_lima' ? ['municipal_appointment_availability'] : [])],
      coverage: language === 'pt' ? 'Catálogo municipal integrado' : 'Municipal catalogue integrated',
      limitations: [language === 'pt' ? 'Não indica vagas atuais.' : 'Does not indicate current slots.'],
      links: [{label: language === 'pt' ? 'Pesquisar serviços' : 'Search services', url: '/municipios?lang=' + language}, ...(id === 'gondomar' ? [{label: 'Apoios', url: '/apoios'}] : [])],
      sources: [{label: 'Fonte oficial', url: 'https://www.cm-pontedelima.pt/'}]})),
    national_capabilities: [{id: 'financas', title: 'Finanças', description: language === 'pt' ? 'Orientação sem acesso a contas pessoais.' : 'Guidance without access to personal accounts.', tools: ['financas_guidance'], url: '/financas'}],
    notice: language === 'pt' ? 'A ausência de cobertura não significa ausência de serviços.' : 'Missing coverage does not mean missing services.'};
}
test.beforeEach(async ({ page }) => {
  await page.route(tile, route => route.fulfill({contentType: 'image/png', body: png}));
  await page.route(api, route => route.fulfill({json: coverage(new URL(route.request().url()).searchParams.get('lang'))}));
});

for (const language of ['pt', 'en']) {
  test(`map ${language}: coverage, markers, selection, pan/zoom, mobile and dark`, async ({ page }) => {
    await page.addInitScript(() => { window.geoCalls = 0; Object.defineProperty(navigator, 'geolocation', {value: {getCurrentPosition() { window.geoCalls++; }}}); });
    await page.setViewportSize({width: 390, height: 844});
    await page.emulateMedia({colorScheme: 'dark'});
    expect((await page.goto('/mapa?lang=' + language)).status()).toBe(200);
    await expect(page.getByRole('heading', {level: 1})).toHaveText(language === 'en' ? 'See where eCidadão can help.' : 'Veja onde o eCidadão pode ajudar.');
    await expect(page.locator('#coverage-status')).toContainText('3 ');
    await expect(page.locator('#coverage-status')).toContainText('320');
    await expect(page.locator('#coverage-list button')).toHaveCount(3);
    await expect(page.locator('.coverage-marker')).toHaveCount(3);
    await expect(page.locator('.coverage-marker-availability')).toHaveCount(1);
    expect((await page.locator('#coverage-map').boundingBox()).y).toBeLessThan(844);
    expect(await page.evaluate(() => window.geoCalls)).toBe(0);
    await page.locator('#coverage-list button[data-id="ponte_de_lima"]').click();
    await expect(page.locator('#coverage-selected')).toHaveText('Ponte de Lima');
    await expect(page.locator('#coverage-detail')).toContainText('58');
    await expect(page.locator('#coverage-detail')).toContainText('municipal_appointment_availability');
    await expect(page.locator('#coverage-detail a.official')).toHaveAttribute('href', '/vagas');
    await expect(page.locator('#coverage-metadata')).toContainText('2026-11-27T15:00:00Z');
    await expect(page.locator('#coverage-metadata')).toContainText(language === 'en' ? 'not a live check' : 'não uma consulta em tempo real');
    await expect(page.locator('#coverage-national')).toContainText('Finanças');
    await expect(page.locator('.leaflet-control-attribution')).toContainText('OpenStreetMap');
    await page.locator('.leaflet-control-zoom-in').click();
    const map = page.locator('#coverage-map'); await map.scrollIntoViewIfNeeded();
    const box = await map.boundingBox();
    await page.mouse.move(box.x + 160, box.y + 150); await page.mouse.down(); await page.mouse.move(box.x + 190, box.y + 180, {steps: 4}); await page.mouse.up();
    await page.locator('#coverage-portugal').click();
    await expect(map).toHaveClass(/leaflet-container/);
    expect(await page.evaluate(() => document.documentElement.scrollWidth <= innerWidth)).toBe(true);
    if (process.env.MUNICIPAL_MAP_SCREENSHOTS) await page.screenshot({path: `/tmp/municipal-map-${language}-mobile.png`, fullPage: true});
    const dark = await page.locator('html').evaluate(n => getComputedStyle(n).backgroundColor);
    await page.emulateMedia({colorScheme: 'light'});
    await expect.poll(() => page.locator('html').evaluate(n => getComputedStyle(n).backgroundColor)).not.toBe(dark);
  });
}

test('location stays local and does not request tiles or refresh coverage', async ({ page }) => {
  await page.addInitScript(() => {
    window.geoCalls = 0;
    Object.defineProperty(navigator, 'geolocation', {value: {getCurrentPosition(ok) {window.geoCalls++; ok({coords: {latitude: 41.2375, longitude: -8.604624}});}}});
  });
  await page.goto('/mapa?lang=en');
  await expect(page.locator('#coverage-status')).toContainText('3 municipalities');
  await page.waitForLoadState('networkidle');
  const requests = []; page.on('request', r => requests.push(r.url()));
  const before = await page.evaluate(() => ({local: {...localStorage}, session: {...sessionStorage}}));
  await page.locator('#coverage-locate').click();
  await expect(page.locator('#coverage-location')).toContainText('Maia · 0');
  await expect(page.locator('#coverage-location')).toContainText('straight line');
  expect(await page.evaluate(() => window.geoCalls)).toBe(1);
  expect(await page.evaluate(() => ({local: {...localStorage}, session: {...sessionStorage}}))).toEqual(before);
  expect(requests).toEqual([]);
});

for (const reason of ['denied', 'timeout', 'unavailable', 'unsupported']) {
  test(`location ${reason} preserves coverage usability`, async ({ page }) => {
    await page.addInitScript(reason => {
      Object.defineProperty(navigator, 'geolocation', {value: reason === 'unsupported' ? undefined : {
        getCurrentPosition(_ok, fail) {fail({code: reason === 'denied' ? 1 : reason === 'unavailable' ? 2 : 3});}
      }});
    }, reason);
    await page.goto('/mapa?lang=en');
    await expect(page.locator('#coverage-list button')).toHaveCount(3);
    await page.locator('#coverage-locate').click();
    await expect(page.locator('#coverage-location')).toContainText(reason === 'denied' ? 'not allowed' : reason === 'unsupported' ? 'does not support' : reason === 'unavailable' ? 'could not determine' : 'within 30 seconds');
    await expect(page.locator('#coverage-locate')).toBeEnabled();
    await page.locator('#coverage-list button[data-id="maia"]').click();
    await expect(page.locator('#coverage-selected')).toHaveText('Maia');
  });
}

test('permission wait longer than eleven seconds can still succeed; cancellation ignores old callbacks', async ({ page }) => {
  await page.clock.install();
  await page.addInitScript(() => {
    window.geoCallbacks = [];
    Object.defineProperty(navigator, 'geolocation', {value: {getCurrentPosition(ok, fail, options) {window.geoCallbacks.push({ok, fail, options});}}});
  });
  await page.goto('/mapa?lang=en');
  await expect(page.locator('#coverage-status')).toContainText('3 municipalities');
  await page.locator('#coverage-locate').click();
  await page.clock.fastForward(15000);
  await expect(page.locator('#coverage-location')).toContainText('Waiting');
  expect(await page.evaluate(() => window.geoCallbacks[0].options)).toEqual({enableHighAccuracy: false, timeout: 30000, maximumAge: 300000});
  await page.evaluate(() => window.geoCallbacks[0].ok({coords: {latitude: 41.2375, longitude: -8.604624}}));
  await expect(page.locator('#coverage-location')).toContainText('Maia · 0');
  await page.locator('#coverage-locate').click();
  await page.getByRole('button', {name: 'Cancel location', exact: true}).click();
  await page.locator('#coverage-locate').click();
  await page.evaluate(() => window.geoCallbacks[1].ok({coords: {latitude: 0, longitude: 0}}));
  await expect(page.locator('#coverage-location')).toContainText('Waiting');
  await page.clock.fastForward(90000);
  await expect(page.locator('#coverage-location')).toContainText('permission prompt');
  await expect(page.locator('#coverage-locate')).toHaveText('Use my location');
});

test('map library or tile failure leaves list usable', async ({ page }) => {
  await page.route('**/map-assets/leaflet.js', route => route.abort());
  await page.goto('/mapa?lang=en');
  await expect(page.locator('#coverage-map-error')).toBeVisible();
  await expect(page.locator('#coverage-list button')).toHaveCount(3);
  await page.locator('#coverage-list button[data-id="gondomar"]').click();
  await expect(page.locator('#coverage-detail a[href="/apoios"]')).toBeVisible();
  await page.unroute('**/map-assets/leaflet.js');
  await page.route(tile, route => route.abort());
  await page.reload();
  await expect(page.locator('#coverage-map-error')).toBeVisible();
  await expect(page.locator('#coverage-list button')).toHaveCount(3);
});

test('all scripts unavailable retains three static municipality choices', async ({ page }) => {
  await page.route('**/map-assets/*.js', route => route.abort());
  await page.goto('/mapa?lang=pt');
  await expect(page.locator('#coverage-list')).toContainText('Gondomar');
  await expect(page.locator('#coverage-list')).toContainText('Maia');
  await expect(page.locator('#coverage-list')).toContainText('Ponte de Lima');
  await expect(page.locator('#coverage-list a[href="/vagas"]')).toBeVisible();
});

test('refresh failure preserves dated snapshot and recovers by explicit retry', async ({ page }) => {
  await page.goto('/mapa?lang=en');
  await expect(page.locator('#coverage-status')).toContainText('3 municipalities');
  await page.route(api, route => route.fulfill({status: 503, json: {error: 'unavailable'}}));
  await page.locator('#coverage-refresh').click();
  await expect(page.locator('#coverage-error')).toBeVisible();
  await expect(page.locator('#coverage-status')).toContainText('has not been refreshed');
  await expect(page.locator('#coverage-metadata')).toContainText('15:00:00Z');
  await expect(page.locator('#coverage-list button')).toHaveCount(3);
  await page.route(api, route => route.fulfill({json: {...coverage('en'), generated_at: '2026-11-27T16:00:00Z'}}));
  await page.locator('#coverage-refresh').click();
  await expect(page.locator('#coverage-metadata')).toContainText('16:00:00Z');
  await expect(page.locator('#coverage-error')).toBeHidden();
});

test('late refresh cannot overwrite newer coverage, untrusted links and names stay safe', async ({ page }) => {
  let count = 0, release, started, finished;
  const gate = new Promise(r => {release = r;}); const waiting = new Promise(r => {started = r;}); const done = new Promise(r => {finished = r;});
  await page.route(api, async route => {
    const n = ++count;
    if (n === 1) { started(); await gate; }
    const data = coverage('en'); data.generated_at = n === 1 ? '2026-11-27T14:00:00Z' : '2026-11-27T16:00:00Z';
    data.municipalities[0].name = '<img src=x onerror=alert(1)>';
    data.municipalities[0].links.push({label: 'unsafe', url: '//evil.example/path'});
    data.municipalities[0].sources.push({label: 'unsafe-source', url: 'javascript:alert(1)'});
    await route.fulfill({json: data}).catch(() => {}); if (n === 1) finished();
  });
  await page.goto('/mapa?lang=en'); await waiting;
  await page.locator('#coverage-refresh').click();
  await expect(page.locator('#coverage-metadata')).toContainText('16:00:00Z');
  release(); await done;
  await expect(page.locator('#coverage-metadata')).not.toContainText('14:00:00Z');
  await expect(page.locator('#coverage-selected')).toHaveText('<img src=x onerror=alert(1)>');
  await expect(page.locator('#coverage-detail img')).toHaveCount(0);
  await expect(page.locator('#coverage-detail a')).not.toContainText(['unsafe']);
});

test('malformed coverage never claims zero municipalities', async ({ page }) => {
  await page.route(api, route => route.fulfill({json: {municipalities: []}}));
  await page.goto('/mapa?lang=en');
  await expect(page.locator('#coverage-error')).toBeVisible();
  await expect(page.locator('#coverage-status')).toBeEmpty();
  await expect(page.locator('#coverage-list')).toContainText('Gondomar');
});

test('updated coverage accepts new IDs and clears a removed selection', async ({ page }) => {
  await page.goto('/mapa?lang=en');
  await expect(page.locator('#coverage-list button')).toHaveCount(3);
  const data = coverage('en');
  data.municipalities = [{...data.municipalities[0], id: 'new_test_municipality', name: 'Synthetic municipality'}];
  data.municipality_count = 1; data.total_service_count = 165;
  await page.route(api, route => route.fulfill({json: data}));
  await page.locator('#coverage-refresh').click();
  await expect(page.locator('#coverage-list button')).toHaveCount(1);
  await expect(page.locator('#coverage-selected')).toHaveText('Synthetic municipality');
  await expect(page.locator('.coverage-marker')).toHaveCount(1);
});
