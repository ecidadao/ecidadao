#!/usr/bin/env python3
"""Build the small runtime catalogue from the reviewed, offline discovery snapshot.

No network access. Maia category parents and action-query variants are omitted;
Gondomar leaf actions and Ponte procedure queries deliberately stay distinct.
"""
import hashlib
import html
import json
from pathlib import Path
from urllib.parse import urlsplit, urlunsplit

ROOT = Path(__file__).resolve().parents[1]
probes = json.loads((ROOT / "docs/municipal-discovery-2026-11-27.json").read_text())["probes"]
DATE = "2026-11-27"
HOSTS = {"servicosonline.cm-gondomar.pt", "www.cm-gondomar.pt", "diretorio.cm-maia.pt", "www.cm-pontedelima.pt"}


def safe_url(url):
    # Decode HTML ampersands only; never unquote an entire URL or a procedure ID.
    url = html.unescape(url)
    parts = urlsplit(url)
    assert parts.scheme == "https" and parts.hostname in HOSTS
    assert not parts.username and not parts.password and parts.port in (None, 443)
    assert not any(c.isspace() for c in url)
    return urlunsplit(parts._replace(fragment=""))


entries = []
sources = {}


def add(municipality, key, title, url, source, category=None, authentication="unknown"):
    entry = dict(id=f"{municipality}-{key}", municipality=municipality, title=title,
                 official_url=safe_url(url), authentication=authentication,
                 source=source, verified_on=DATE)
    if category:
        entry["category"] = category
    entries.append(entry)


g = probes["gondomar_menu"]
sources["gondomar"] = safe_url(g["source"])
for node in g["nodes"]:
    if node["is_leaf"]:
        add("gondomar", node["id"], node["title"], node["url"], sources["gondomar"],
            " / ".join(node["path"][:-1]),
            "required" if node["authentication_flag"] else "unknown")

# This additional public service is documented in municipal-integrations.md.
add("gondomar", "monos", "Recolha de monos",
    "https://www.cm-gondomar.pt/atividade-municipal/ambiente/monos/",
    "https://www.cm-gondomar.pt/atividade-municipal/ambiente/monos/", "Ambiente")

m = probes["maia_catalogue"]
sources["maia"] = safe_url(m["source"])
paths = {urlsplit(safe_url(n["url"])).path: n["title"] for n in m["links"]}
# These are navigation/topic pages even when they have no indexed children.
category_only = {"diretorio-de-servicos", "dinamizacao-territorial-e-turismo",
                 "europe-direct", "festas-da-maia", "objetivos-de-desenvolvimento-sustentavel",
                 "responsabilidade-civil", "servicos-online", "formularios-disponiveis-para-download"}
seen = set()
for path, title in sorted(paths.items(), key=lambda pair: (len(pair[0]), pair[0])):
    if any(other.startswith(path + "/") for other in paths):
        continue
    if path.rsplit("/", 1)[-1] in category_only or title.casefold() in seen:
        continue
    seen.add(title.casefold())
    parent = path.rsplit("/", 1)[0]
    key = hashlib.sha256(path.encode()).hexdigest()[:16]
    add("maia", key, title, "https://diretorio.cm-maia.pt" + path,
        sources["maia"], paths.get(parent))

p = probes["ponte_lima_forms"]
sources["ponte_de_lima"] = safe_url(p["source"])
for node in p["links"]:
    url = safe_url(node["url"])
    key = hashlib.sha256(url.encode()).hexdigest()[:16]
    add("ponte_de_lima", key, node["title"], url, sources["ponte_de_lima"])

assert len({e["id"] for e in entries}) == len(entries)
assert len({e["official_url"] for e in entries}) == len(entries)
output = dict(verified_on=DATE, sources=sources, services=sorted(entries, key=lambda e: e["id"]))
(ROOT / "priv/municipal_services.json").write_text(json.dumps(output, ensure_ascii=False, indent=2) + "\n")
print({m: sum(e["municipality"] == m for e in entries) for m in sources})
