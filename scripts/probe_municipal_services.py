#!/usr/bin/env python3
"""Read-only discovery; no login, booking, submission or background monitoring.

Run from the repository root. Output is research evidence, not a runtime catalogue.
Only public service metadata is retained; cookies and complete HTML are not saved.
"""

import argparse
import html
import json
from datetime import datetime, timezone
from html.parser import HTMLParser
from pathlib import Path
from urllib.parse import urlencode, urljoin
from urllib.request import Request, urlopen


class Links(HTMLParser):
    def __init__(self):
        super().__init__()
        self.href = None
        self.parts = []
        self.links = []

    def handle_starttag(self, tag, attrs):
        if tag == "a":
            self.href = dict(attrs).get("href")
            self.parts = []

    def handle_data(self, data):
        if self.href:
            self.parts.append(data)

    def handle_endtag(self, tag):
        if tag == "a" and self.href:
            self.links.append((self.href, " ".join(" ".join(self.parts).split())))
            self.href = None


def fetch(url, as_json=True):
    request = Request(url, headers={"User-Agent": "eCidadao-research/0.3.3"})
    with urlopen(request, timeout=25) as response:
        body = response.read(3_000_001)
        if len(body) > 3_000_000:
            raise ValueError("Response exceeds research size limit")
        value = body.decode(response.headers.get_content_charset() or "utf-8")
        return json.loads(value) if as_json else value


def gondomar():
    base = "https://servicosonline.cm-gondomar.pt/"
    source = base + "MyNetMenuExterno.asp?" + urlencode({
        "publico": 1, "objecto": "json", "raiz": "Todos Sercicos Online", "frame": 1
    })
    rows = []

    def walk(nodes, parents=(), parent_auth=False):
        for node in nodes:
            if str(node.get("mostra")) != "1":
                continue
            title = html.unescape(node["nome"])
            raw = html.unescape(html.unescape(node.get("url", "")))
            if "?" not in raw and "&" in raw:
                raw = raw.replace("&", "?", 1)
            required = node.get("requerautenticacao")
            rows.append({
                "id": node["idmenu"], "title": title, "path": [*parents, title],
                "url": urljoin(base, raw), "is_leaf": not bool(node.get("filhos")),
                "authentication_flag": required,
                "ancestor_authentication_flag": parent_auth,
            })
            walk(node.get("filhos", []), (*parents, title), parent_auth or required is True)

    walk(fetch(source)["itens"])
    return {"source": source, "kind": "public_frontend_menu_not_supported_api",
            "coverage": "visible anonymous menu only; leaf is not proof of executable service",
            "nodes": rows}


def public_links(source, path_prefix):
    parser = Links()
    parser.feed(fetch(source, as_json=False))
    rows = {}
    for href, title in parser.links:
        url = urljoin(source, href)
        if path_prefix in url and title:
            rows[url] = {"title": title, "url": url}
    return {"source": source, "kind": "public_html_links", "links": list(rows.values())}


def ponte_lima():
    base = "https://www.cm-pontedelima.pt/api/v1/appointments/"
    area_url = base + "get_avaible_customer_areas?appointment_type=in_person&allowed="
    areas = fetch(area_url)
    area = next(row for row in areas if row[0] == "Consulta de Processo sem Técnico - DOP")
    params = {"customer_service_area_id": area[1], "appointment_type": "in_person", "operator_id": ""}
    dates_url = base + "get_available_dates?" + urlencode(params)
    dates = fetch(dates_url).get("dates", [])
    result = {"source": "https://www.cm-pontedelima.pt/pages/1606",
              "kind": "public_frontend_endpoints_not_supported_api",
              "area_source": area_url, "areas": [{"name": r[0], "id": r[1]} for r in areas],
              "sample_service": area[0], "dates_source": dates_url, "dates": dates,
              "submitted": False, "reserved": False}
    if dates:
        params["start_at_date"] = datetime.strptime(dates[0], "%Y/%m/%d").strftime("%d/%m/%Y")
        slots_url = base + "get_empty?" + urlencode(params)
        slots = fetch(slots_url)
        result.update(slots_source=slots_url, slots=[
            {k: r[k] for k in ("id", "customer_service_area", "start_at")} for r in slots
        ])
    return result


def apa():
    base = "https://sniambgeoogc.apambiente.pt/getogc/rest/services/SNIAmb/Qualidade_do_Ar/MapServer"
    metadata = fetch(base + "?f=pjson")
    count_url = base + "/0/query?" + urlencode({"where": "1=1", "returnCountOnly": "true", "f": "json"})
    count = fetch(count_url)
    return {"source": base, "kind": "public_arcgis_rest",
            "capabilities": metadata.get("capabilities"),
            "layers": [{"id": r["id"], "name": r["name"]} for r in metadata["layers"]],
            "count_source": count_url, "station_count": count["count"],
            "limitation": "station geography; does not establish live air measurements or reuse licence"}


def maia_appointments():
    source = "https://www.cm-maia.pt/institucional/atendimento-e-pedidos/atendimento-municipal/agendamentos/gma-atendimento-municipal"
    body = fetch(source, as_json=False)
    return {"source": source, "kind": "public_html",
            "no_dates_message_present": "Neste momento não existem datas disponíveis para agendamento." in body,
            "limitation": "only GMA page at observation time; not all municipal appointments"}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    result = {"checked_at": datetime.now(timezone.utc).isoformat(), "research_only": True, "probes": {}}
    probes = {
        "gondomar_menu": gondomar,
        "maia_catalogue": lambda: public_links("https://diretorio.cm-maia.pt/todos-os-servicos-de-a-a-z", "/directorio_de_servicos/"),
        "maia_gma": maia_appointments,
        "ponte_lima_forms": lambda: public_links("https://www.cm-pontedelima.pt/servicos/apoio-ao-municipe/servicos-online/formularios", "/detalhe-de-procedimento?"),
        "ponte_lima_appointments": ponte_lima,
        "apa_air_station_layer": apa,
    }
    for name, probe in probes.items():
        try:
            result["probes"][name] = probe()
            print(name + ": OK")
        except Exception as error:
            result["probes"][name] = {"error": type(error).__name__, "detail": str(error)}
            print(name + ": FAILED")
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(result, ensure_ascii=False, indent=2) + "\n")
    return int(any("error" in p for p in result["probes"].values()))


if __name__ == "__main__":
    raise SystemExit(main())
