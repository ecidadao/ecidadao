"""Read-only canaries for website integrations; save counts, never report bodies."""
import argparse
from datetime import datetime, timezone
import json
from pathlib import Path
import sys
import urllib.request

parser = argparse.ArgumentParser()
parser.add_argument("integration", choices=["siga", "street"])
parser.add_argument("--base", default="https://ecidadao.pt")
parser.add_argument("--report", default="integration-report.json")
args = parser.parse_args()
report = {"integration": args.integration, "checked_at": datetime.now(timezone.utc).isoformat(), "passed": False}
try:
    if args.integration == "street":
        path, payload = "/api/street-reports/recent", None
    else:
        path = "/api/siga/queues/compare"
        payload = {"district": "Porto", "entity": "Autoridade Tributária", "ticket_type": "Atendimento Geral", "latitude": 41.15, "longitude": -8.61, "radius_km": 40}
    request = urllib.request.Request(args.base + path, data=json.dumps(payload).encode() if payload else None, headers={"Content-Type": "application/json", "Accept": "application/json"})
    with urllib.request.urlopen(request, timeout=60) as response:
        data = json.load(response)
    if args.integration == "street":
        assert data["reports"] and data["fetched_at"] and data["source"]
        report["count"] = len(data["reports"])
    else:
        assert data["status"] == "consulta_publica_nao_reserva"
        assert isinstance(data["locations"], list) and data["observed_at"]
        report["count"] = len(data["locations"])
    report["passed"] = True
except Exception as error:
    report["error_type"] = type(error).__name__
    print(f"{args.integration}: {type(error).__name__}", file=sys.stderr)
finally:
    Path(args.report).write_text(json.dumps(report, indent=2) + "\n")
print(json.dumps(report))
sys.exit(0 if report["passed"] else 1)
