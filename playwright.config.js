const { defineConfig, devices } = require('@playwright/test');

const port = Number(process.env.ECIDADAO_BROWSER_PORT || 4118);
if (!Number.isInteger(port) || port < 1024 || port > 65535 || port === 4000) {
  throw new Error('ECIDADAO_BROWSER_PORT must be an unprivileged port other than 4000');
}
const baseURL = `http://127.0.0.1:${port}`;

module.exports = defineConfig({
  testDir: './tests/browser',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: 0,
  workers: process.env.CI ? 2 : undefined,
  reporter: [['list'], ['html', { open: 'never' }]],
  use: {
    baseURL,
    locale: 'pt-PT',
    serviceWorkers: 'block',
    trace: 'retain-on-failure',
    screenshot: 'only-on-failure',
  },
  projects: [{ name: 'chromium', use: { ...devices['Desktop Chrome'] } }],
  webServer: {
    command: 'mix run --no-halt',
    env: { MIX_ENV: 'dev', ECIDADAO_HTTP_PORT: String(port) },
    url: `${baseURL}/health`,
    reuseExistingServer: false,
    timeout: 120_000,
    gracefulShutdown: { signal: 'SIGTERM', timeout: 5000 },
  },
});
