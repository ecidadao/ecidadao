# Municipal coverage map assets

Leaflet **1.9.4**, vendored from the official release:
https://github.com/Leaflet/Leaflet/releases/tag/v1.9.4
https://github.com/Leaflet/Leaflet/releases/download/v1.9.4/leaflet.zip

`leaflet.js`, `leaflet.css` and `images/` are unchanged release files. The BSD-2-Clause
license is in `LEAFLET-LICENSE.txt`, from the official v1.9.4 source LICENSE.
The page pins JS/CSS through SHA-256 Subresource Integrity:

* JS: `85d455b4522415f6badc42a0e7d17c919d100347d6b8958bd0dc738fdecd6d50`
* CSS: `a7837102824184820dfa198d1ebcd109ff6d0ff9a2672a074b9a1b4d147d04c6`

Serve `/map-assets` from `priv/static/map`, allowing `leaflet.js`, `leaflet.css`,
`municipal-map.js`, `municipal-map.css`, `images`, and `LEAFLET-LICENSE.txt`.
No CDN scripts, keys, tracking, or third-party fonts are used by this feature.

OSM policy reviewed 2026-11-27:
https://operations.osmfoundation.org/policies/tiles/

The visible map uses `https://tile.openstreetmap.org/{z}/{x}/{y}.png`. Keep browser
HTTP caching and Referer defaults. Attribution remains visible on the map and
in surrounding content. No tile proxy, prefetch, offline download or cache-busting
is implemented. Only tiles required by the current view load, with keepBuffer 0
and updateWhenIdle. OSM is best effort; the accessible list remains usable when
tiles fail. The tile provider sees normal browser/IP/referrer and viewport tile
requests; this is not analytics. Review hosting capacity before substantial use.

Geolocation is requested only by its button. Coordinates remain in a JS closure,
are never stored or transmitted, and only compute straight-line distance to the
approximate municipal centre. They do not recenter/zoom the map or request tiles
for the user's location. No geolocation marker is added. Pagehide clears the
position. All browser tests mock tiles and coverage; no live source query is made.

Integration: `EcidadaoWeb.MunicipalMapPage.render(locale)` uses
`EcidadaoWeb.Page.civic_layout(body, locale)`. Register GET `/mapa` and GET
`/api/municipal/coverage?lang=pt|en`; the latter returns the agreed flat contract
from `Ecidadao.MunicipalCoverage.snapshot(locale)`. `generated_at` describes the
coverage response, `verified_on` the source catalogue date; neither represents
appointment availability. No new MCP tool is required.
