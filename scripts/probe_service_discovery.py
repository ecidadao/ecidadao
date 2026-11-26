#!/usr/bin/env python3
"""Bounded, anonymous gov.pt discovery probe; no transactions or credentials.

Four requests: two read-only searches (POST is the site's search transport),
then two public HTML GETs. Prints evidence as JSON; never crawls or paginates.
This is an undocumented frontend contract, not an approved CUSP integration.
"""

import json
import sys
from datetime import datetime, timezone
from html.parser import HTMLParser
from urllib.request import Request, urlopen


BASE = "https://www.gov.pt"
MAX_BYTES = 2_000_000


class NextDataParser(HTMLParser):
    def __init__(self):
        super().__init__()
        self.inside = False
        self.parts = []

    def handle_starttag(self, tag, attrs):
        if tag == "script" and dict(attrs).get("id") == "__NEXT_DATA__":
            self.inside = True

    def handle_endtag(self, tag):
        if tag == "script":
            self.inside = False

    def handle_data(self, data):
        if self.inside:
            self.parts.append(data)


def fetch(path, body=None):
    headers = {"Accept": "application/json" if body else "text/html"}
    data = None
    if body is not None:
        headers["Content-Type"] = "application/json"
        data = json.dumps(body, ensure_ascii=False).encode("utf-8")
    request = Request(BASE + path, data=data, headers=headers)
    with urlopen(request, timeout=30) as response:
        raw = response.read(MAX_BYTES + 1)
        if len(raw) > MAX_BYTES:
            raise ValueError("Response exceeds probe size limit")
        evidence = {
            "method": request.get_method(), "url": request.full_url,
            "body": body, "status": response.status,
            "final_url": response.url, "etag": response.headers.get("ETag"),
        }
    if body is not None:
        result = json.loads(raw)
        if result.get("timed_out") or result.get("_shards", {}).get("failed", 0):
            raise ValueError("Search returned incomplete results")
        if not isinstance(result.get("hits", {}).get("hits"), list):
            raise ValueError("Search response contract changed")
        evidence["response"] = result
    else:
        parser = NextDataParser()
        parser.feed(raw.decode("utf-8"))
        result = json.loads("".join(parser.parts))
        evidence["build_id"] = result["buildId"]
        evidence["page_props"] = result["props"]["pageProps"]
    return evidence


def main():
    common = {"size": "10", "start": "0", "hasThemes": False,
              "hasSubThemes": False}
    searches = [
        ("geral_search_template", {**common, "value": "Cartão de Cidadão",
                                   "category": ""}),
        ("local_search_template", {**common, "value": "Rio Tinto",
                                   "category": "Locais de atendimento",
                                   "sort": "title.sort", "order": "asc",
                                   "filterByGeo": False}),
    ]
    records = []
    for template, params in searches:
        records.append(fetch("/api/post-search-result", {
            "method": "POST", "body": {"id": template, "params": params},
        }))
    for path in ["/locais-de-atendimento/espaco-cidadao-de-rio-tinto",
                 "/servicos/renovar-o-cartao-de-cidadao"]:
        records.append(fetch(path))
    print(json.dumps({"checked_at": datetime.now(timezone.utc).isoformat(),
                      "scope": "Public discovery only; no booking capability established",
                      "records": records}, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    try:
        main()
    except Exception as exc:
        print(f"Discovery probe failed: {exc}", file=sys.stderr)
        sys.exit(1)
