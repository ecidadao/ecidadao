"""Check the website, deployed revision, and public MCP without personal data."""
import argparse
import json
import urllib.request

parser = argparse.ArgumentParser()
parser.add_argument("base")
parser.add_argument("--revision")
parser.add_argument("--brand", action="store_true", help="Also check the optional brand assets")
args = parser.parse_args()

def request(path, payload=None):
    data = json.dumps(payload).encode() if payload else None
    req = urllib.request.Request(args.base.rstrip("/") + path, data=data,
        headers={"Content-Type": "application/json", "Accept": "application/json, text/event-stream"})
    with urllib.request.urlopen(req, timeout=10) as response:
        assert response.status == 200
        return response.read()

health = json.loads(request("/health"))
assert health["status"] == "ok"
if args.revision and args.revision != "legacy":
    assert health["revision"] == args.revision, health
paths = ["/", "/como-usar", "/siga", "/financas", "/a-minha-rua", "/reclamacoes", "/privacidade", "/termos", "/apoio", "/imagens/siga-passo.png"]
if args.brand:
    paths += ["/marca/ecidadao-logo.svg", "/marca/ecidadao-logo.png", "/marca/ecidadao-identidade.zip"]
for path in paths:
    assert request(path), path
result = json.loads(request("/mcp/public", {"jsonrpc":"2.0","id":1,"method":"tools/list"}))
assert {t["name"] for t in result["result"]["tools"]} == {
    "prepare_complaint", "official_submission_guidance", "prepare_street_report",
    "siga_visit_guidance", "financas_service_guidance", "prepare_financas_ebalcao"}
result = json.loads(request("/mcp/public", {"jsonrpc":"2.0","id":2,"method":"tools/call", "params":{"name":"siga_visit_guidance","arguments":{"purpose":"appointment"}}}))
assert "result" in result and not result["result"].get("isError"), result
print("Website and MCP healthy:", health)
