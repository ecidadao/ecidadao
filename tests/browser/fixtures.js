const { test: base, expect } = require('@playwright/test');

// Only external-dependent reads are fixtures; preparation POSTs reach Plug.
const test = base.extend({
  context: async ({ context, baseURL }, use) => {
    const externalRequests = [];
    await context.route('**/*', async route => {
      const url = new URL(route.request().url());
      // Isolate the homepage basemap; browser tests never fetch public tiles.
      if (url.hostname === 'tile.openstreetmap.org' && /^\/\d+\/\d+\/\d+\.png$/.test(url.pathname)) {
        return route.fulfill({ contentType: 'image/png', body: Buffer.from('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+aS1cAAAAASUVORK5CYII=', 'base64') });
      }
      if (url.origin !== baseURL) {
        externalRequests.push(url.href);
        return route.abort('blockedbyclient');
      }
      if (url.pathname === '/api/street-reports/recent') {
        return route.fulfill({ json: {
          fetched_at: '2026-11-20T12:00:00Z', stale: false,
          reports: [{ id: '123', subject: 'Candeeiro de exemplo', date: '2026-11-20',
            locality: 'Porto', status: 'Em análise',
            official_url: 'https://servicos.arte.gov.pt/Portal/AMR/situationsList.aspx' }],
        } });
      }
      if (url.pathname === '/api/siga/queues/compare') {
        return route.fulfill({ json: {
          total_in_radius: 1, entity: 'IRN Registo', ticket_type: 'Atendimento Geral',
          observed_at: '2026-11-20T12:00:00Z',
          locations: [{ name: 'Balcão de exemplo', distance_km: 2, state: 'Aberto',
            open: true, wait_minutes: 12, people_waiting: 3, address: 'Porto' }],
        } });
      }
      await route.continue();
    });
    await use(context);
    expect(externalRequests, 'No requests to external services').toEqual([]);
  },
});

module.exports = { test, expect };
