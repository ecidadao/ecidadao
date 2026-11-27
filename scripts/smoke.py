"""Check the website, deployed revision, and public MCP without personal data."""
import argparse
import json
import urllib.request

parser = argparse.ArgumentParser()
parser.add_argument("base")
parser.add_argument("--revision")
parser.add_argument("--brand", action="store_true", help="Also check the optional brand assets")
parser.add_argument("--locales", action="store_true", help="Check English pages and automatic colour scheme")
parser.add_argument("--feedback", action="store_true", help="Check Livro Amarelo drafts and official handoff links")
parser.add_argument("--services", action="store_true", help="Check the curated service finder")
parser.add_argument("--sns24", action="store_true", help="Require SNS 24 pages and public guidance")
parser.add_argument("--municipal", action="store_true", help="Require municipal pages and three new public tools")
parser.add_argument("--live-municipal", action="store_true", help="Also query public Ponte de Lima areas (external availability required)")
args = parser.parse_args()

def request(path, payload=None):
    data = json.dumps(payload).encode() if payload else None
    req = urllib.request.Request(args.base.rstrip("/") + path, data=data,
        headers={"Content-Type": "application/json", "Accept": "application/json, text/event-stream"})
    with urllib.request.urlopen(req, timeout=35) as response:
        assert response.status == 200
        return response.read()

health = json.loads(request("/health"))
assert health["status"] == "ok"
if args.revision and args.revision != "legacy":
    assert health["revision"] == args.revision, health
paths = ["/", "/como-usar", "/siga", "/financas", "/a-minha-rua", "/reclamacoes", "/privacidade", "/termos", "/apoio", "/imagens/siga-passo.png"]
if args.feedback:
    paths.append("/livro-amarelo")
if args.services:
    paths.append("/servicos")
if args.brand:
    paths += ["/marca/ecidadao-logo.svg", "/marca/ecidadao-logo.png", "/marca/ecidadao-github.svg", "/marca/ecidadao-github.png", "/marca/ecidadao-identidade.zip"]
for path in paths:
    assert request(path), path
if args.services:
    page = request("/servicos").decode()
    assert 'id="service-search"' in page
    assert 'data-service-id="cc-renewal"' in page
    assert 'href="https://www.gov.pt/servicos/renovar-o-cartao-de-cidadao"' in page
if args.locales:
    for path in paths:
        if "." not in path:
            page = request(path + "?lang=en").decode()
            assert '<html lang="en">' in page, path
            assert 'prefers-color-scheme:dark' in page, path
            assert 'Help with public services' in page, path
    assert 'O próximo passo fica mais simples.' in request("/?lang=pt").decode()
if args.feedback:
    for kind, service in [
        ("complaint", "fazer-reclamacao-de-um-servico-publico"),
        ("compliment", "fazer-elogio-a-um-servico-publico"),
        ("suggestion", "fazer-sugestao-a-um-servico-publico"),
    ]:
        draft = json.loads(request("/api/public-feedback/prepare", {
            "type": kind, "organisation": "Serviço de atendimento",
            "subject": "Informação sobre atendimento",
            "description": "Gostaria de ver o horário de atendimento junto à entrada.",
        }))
        assert draft["status"] == "rascunho_nao_submetido", draft
        assert draft["official_portal"] == "https://www.gov.pt/servicos/" + service, draft
        assert "NÃO SUBMETIDO" in draft["draft"], draft
result = json.loads(request("/mcp/public", {"jsonrpc":"2.0","id":1,"method":"tools/list"}))
public_names = {t["name"] for t in result["result"]["tools"]}
legacy_names = {
    "prepare_complaint", "official_submission_guidance", "prepare_street_report",
    "siga_visit_guidance", "financas_service_guidance", "prepare_financas_ebalcao"}
# Keep the previous release verifiable during rollback; no other tools are allowed.
previous_names = legacy_names | {"sns24_service_guidance"}
civic_names = {"municipal_service_search", "municipal_appointment_availability", "public_support_guidance"}
assert public_names in (legacy_names, previous_names, previous_names | civic_names)
if args.municipal or args.live_municipal:
    assert civic_names <= public_names
if civic_names <= public_names:
    for language in ("pt", "en"):
        for path in ("/municipios", "/apoios", "/vagas"):
            page = request(path + "?lang=" + language).decode()
            assert '<html lang="' + language + '"' in page, path
            assert 'prefers-color-scheme:dark' in page, path
        for tool, arguments in [
            ("municipal_service_search", {"municipality":"gondomar", "query":"water tariff", "language":language}),
            ("public_support_guidance", {"service":"porta65_young", "language":language}),
        ]:
            response = json.loads(request("/mcp/public", {"jsonrpc":"2.0", "id":4,
                "method":"tools/call", "params":{"name":tool,"arguments":arguments}}))
            assert not response["result"].get("isError"), response
            data = response["result"]["structuredContent"]
            assert data["submitted"] is False and data["language"] == language
            if tool == "municipal_service_search":
                assert data["total"] > 0 and data["availability_checked"] is False
    # Validate wiring without making rollout depend on the municipal server.
    response = json.loads(request("/mcp/public", {"jsonrpc":"2.0", "id":5,
        "method":"tools/call", "params":{"name":"municipal_appointment_availability",
        "arguments":{"municipality":"unsupported"}}}))
    assert response["result"].get("isError") is True
if args.live_municipal:
    response = json.loads(request("/mcp/public", {"jsonrpc":"2.0", "id":6,
        "method":"tools/call", "params":{"name":"municipal_appointment_availability","arguments":{}}}))
    assert not response["result"].get("isError"), response
    data = response["result"]["structuredContent"]
    assert data["status"] == "areas_listed" and data["reserved"] is False and data["checked_at"]
if args.sns24:
    assert "sns24_service_guidance" in public_names
if "sns24_service_guidance" in public_names:
    for language in ("pt", "en"):
        page = request("/saude?lang=" + language).decode()
        assert '<html lang="' + language + '"' in page
        assert 'id="exams"' in page
        for service in ("appointments", "exams", "medication", "referrals"):
            response = json.loads(request("/mcp/public", {"jsonrpc":"2.0", "id":3,
                "method":"tools/call", "params":{"name":"sns24_service_guidance",
                "arguments":{"service":service,"language":language,"channel":"app"}}}))
            assert not response["result"].get("isError"), response
            guidance = response["result"]["structuredContent"]
            assert guidance["status"] == "guidance_only" and guidance["submitted"] is False
            assert guidance["language"] == language and guidance["channel"] == "app"
result = json.loads(request("/mcp/public", {"jsonrpc":"2.0","id":2,"method":"tools/call", "params":{"name":"siga_visit_guidance","arguments":{"purpose":"appointment"}}}))
assert "result" in result and not result["result"].get("isError"), result
print("Website and MCP healthy:", health)
