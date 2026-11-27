"""Exercise the public contract with the official MCP SDK; no account operations."""
import argparse
import asyncio
from datetime import datetime, timezone, timedelta
import json
from pathlib import Path
import sys

from jsonschema import Draft202012Validator
from mcp import ClientSession
from mcp.client.streamable_http import streamablehttp_client
from mcp.shared.exceptions import McpError

CASES = {
    "siga_visit_guidance": {"purpose": "appointment"},
    "financas_service_guidance": {"service": "imi"},
    "prepare_financas_ebalcao": {"subject": "Teste de integração", "message": "Como consultar o calendário de pagamento do IMI?"},
    "prepare_complaint": {"business_name": "Entidade de teste", "description": "Produto de teste avariado.", "requested_resolution": "Informação sobre troca."},
    "official_submission_guidance": {},
    "prepare_street_report": {"district": "Porto", "municipality": "Matosinhos", "parish": "Matosinhos", "address": "Local de teste", "category": "Conservação da Iluminação Pública", "subject": "Teste de rascunho", "description": "Candeeiro de teste apagado, sem submissão."},
    "sns24_service_guidance": {"service": "appointments", "language": "en"},
    "municipal_service_search": {"municipality": "gondomar", "query": "water tariff", "language": "en"},
    "public_support_guidance": {"service": "porta65_young", "language": "en"},
}
EXPECTED = set(CASES) | {"municipal_appointment_availability"}


async def check(args, report):
    async with streamablehttp_client(args.url, timeout=35, sse_read_timeout=40) as (read, write, _):
        async with ClientSession(read, write, read_timeout_seconds=timedelta(seconds=40)) as session:
            init = await session.initialize()
            report["server_version"] = init.serverInfo.version
            report["protocol"] = init.protocolVersion
            if args.version:
                assert init.serverInfo.version == args.version, "server/package version mismatch"
            await session.send_ping()
            catalogue = await session.list_tools()
            tools = {tool.name: tool for tool in catalogue.tools}
            assert len(catalogue.tools) == len(tools), "duplicate tools"
            assert set(tools) == EXPECTED, "public catalogue drift"
            assert not catalogue.nextCursor, "unexpected pagination"
            for tool in tools.values():
                Draft202012Validator.check_schema(tool.inputSchema)
                assert tool.annotations.readOnlyHint is True, tool.name
                assert tool.annotations.destructiveHint is False, tool.name
            assert not (await session.list_resources()).resources

            async def call(name, inputs, error=False, validate=True):
                if validate:
                    Draft202012Validator(tools[name].inputSchema).validate(inputs)
                result = await session.call_tool(name, inputs)
                assert bool(result.isError) == error, f"unexpected result: {name}"
                assert any(c.type == "text" and c.text.strip() for c in result.content), name
                data = result.structuredContent or {}
                assert data.get("submitted") is not True and data.get("reserved") is not True
                report["checks"].append({"tool": name, "expected_error": error, "passed": True})
                return data, result

            for name, inputs in CASES.items():
                data, _ = await call(name, inputs)
                if name.startswith("prepare_"):
                    assert data["status"] == "rascunho_nao_submetido", name
                if name == "municipal_service_search":
                    assert data["total"] > 0 and data["results"]
                    assert data["availability_checked"] is False
            for language in ("pt", "en"):
                for service in tools["public_support_guidance"].inputSchema["properties"]["service"]["enum"]:
                    data, _ = await call("public_support_guidance", {"service": service, "language": language})
                    assert data["language"] == language and data["status"] == "guidance_only"
                    assert data["remaining_budget"] is None
            for name in ("municipal_service_search", "municipal_appointment_availability", "public_support_guidance"):
                _, result = await call(name, {"unexpected": "ci-marker-never-echo"}, error=True, validate=False)
                assert "ci-marker-never-echo" not in result.model_dump_json()
            await call("municipal_appointment_availability", {"municipality": "maia"}, error=True, validate=False)
            try:
                denied = await session.call_tool("prepare_public_service_feedback", {})
            except McpError as error:
                assert error.error.code == -32602
            else:
                assert denied.isError, "experimental tool exposed publicly"
            if args.live:
                name = "municipal_appointment_availability"
                areas, _ = await call(name, {})
                assert areas["status"] == "areas_listed" and areas["areas"]
                assert areas["checked_at"] and areas["reserved"] is False
                service = areas["areas"][0]["id"]
                await asyncio.sleep(1.2)
                dates, _ = await call(name, {"service_id": service})
                assert dates["status"] in ("available_at_check_time", "no_availability")
                if dates["dates"]:
                    await asyncio.sleep(1.2)
                    slots, _ = await call(name, {"service_id": service, "date": dates["dates"][0]})
                    assert slots["status"] in ("available_at_check_time", "no_availability")
                    assert isinstance(slots["slots"], list) and slots["checked_at"]
                    report["live_slots"] = len(slots["slots"])
                else:
                    report["live_dates"] = 0


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("url")
    parser.add_argument("--version")
    parser.add_argument("--live", action="store_true", help="Read municipal areas/dates/slots; external dependency")
    parser.add_argument("--report", default="mcp-report.json")
    args = parser.parse_args()
    report = {"checked_at": datetime.now(timezone.utc).isoformat(), "url": args.url, "live": args.live, "checks": [], "passed": False}
    try:
        asyncio.run(check(args, report))
        report["passed"] = True
    except Exception as error:
        # Do not persist response bodies or user data from external sources.
        report["error_type"] = type(error).__name__
        def describe(exc):
            children = getattr(exc, "exceptions", [])
            return "; ".join(describe(child) for child in children) if children else f"{type(exc).__name__}: {exc}"
        print(f"MCP check failed: {describe(error)}", file=sys.stderr)
    finally:
        Path(args.report).parent.mkdir(parents=True, exist_ok=True)
        Path(args.report).write_text(json.dumps(report, indent=2) + "\n")
    print(f"MCP contract: {len(report['checks'])} checks, passed={report['passed']}")
    return 0 if report["passed"] else 1


if __name__ == "__main__":
    sys.exit(main())
