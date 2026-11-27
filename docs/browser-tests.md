# Browser regression tests

The real Chromium suite is part of the existing `test` job in
`.github/workflows/test.yml`. Deployment requires that job to succeed, including
ExUnit, dependency audit, deployment checks and browser tests. No scheduled runs
or browser dependencies are added to the runtime Docker image.

## Install and run

Use Node 22 and the repository's Elixir/OTP prerequisites:

```sh
mix deps.get
npm ci
npx playwright install --with-deps chromium
npm run test:browser
```

On macOS, `npx playwright install chromium` is sufficient. The exact
`@playwright/test` version (1.65.1) and transitive packages are locked in
`package-lock.json`. The npm registry reported this as the current stable release
on 27 November 2026, with a Node requirement of >=20; CI explicitly uses Node 22.
Sources: [official package metadata](https://registry.npmjs.org/@playwright/test/latest),
[installation requirements](https://playwright.dev/docs/intro),
[webServer lifecycle](https://playwright.dev/docs/test-webserver), and
[CI browser installation](https://playwright.dev/docs/ci).

Playwright starts its own `MIX_ENV=dev mix run --no-halt` process, waits for
`/health` through `webServer`, and shuts down that process afterward. It binds
loopback on port 4118 by default. To run a second suite concurrently:

```sh
ECIDADAO_BROWSER_PORT=4119 npm run test:browser
```

Port 4000 is explicitly rejected. An occupied test port is an error:
`reuseExistingServer` is always false. The suite never kills or reuses an existing
server and has no production/base-URL override. `config/dev.exs` reads
`ECIDADAO_HTTP_PORT`, retaining 4000 as the ordinary development default.

## Coverage and network isolation

The suite checks all public page headings in Portuguese and English, browser
language selection and persisted explicit choice, 390px mobile overflow, theme
changes on an open page, internal navigation, and official link destinations.
Consumer, tax and all three Livro Amarelo drafts use the actual local preparation
API with fictional examples and assert `rascunho_nao_submetido`. Feedback tests
also verify invalidation after editing, clipboard rejection fallback, and exact
UTF-8 download contents. Consumer downloads are checked too.

The common browser fixture intercepts only the external-dependent recent street
reports and SIGA queue comparison endpoints with representative data. This keeps
those requests from reaching the server's third-party clients. Other requests
reach the real local server. Requests to any other origin are blocked and fail
the test. Official links are inspected without following them; no official
submission, ticket booking or email sending takes place. Keep using this fixture
for new browser tests, and explicitly isolate any newly introduced endpoint that
calls third parties. The current server does not fetch these services on startup.

`services.spec.js` enforces the `/servicos` search contract, including Portuguese
and English search, hidden-card filtering, empty/reset behavior, no search network
traffic or URL changes, mobile layout, and the directory with JavaScript disabled.
These tests are enabled in the full CI suite. When validating an older checkout
before the service finder is integrated, the baseline can be run separately:

```sh
npm run test:browser -- --grep-invert 'service finder|service directory'
```

This diagnostic command is not the deployment gate; CI always runs every test.

## Failure evidence

Tests retain traces and screenshots on failure, with an HTML report. CI uploads
`playwright-report/` and `test-results/` as `browser-failure-evidence` for 14 days.
There are no automatic retries to hide intermittent failures.

```sh
npm run test:browser:report
npx playwright show-trace test-results/<failed-test>/trace.zip
```

Generated reports, downloads and installed Node packages are ignored by Git.
