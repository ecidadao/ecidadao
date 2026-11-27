"""Start an isolated local application and exercise its HTTP MCP transport."""
import os
from pathlib import Path
import subprocess
import socket
import sys
import time
import urllib.request

root = Path(__file__).resolve().parents[1]
port = int(os.environ.get("ECIDADAO_CONTRACT_PORT", "4128"))
assert 1024 <= port <= 65535 and port != 4000
env = dict(os.environ, MIX_ENV="dev", ECIDADAO_HTTP_PORT=str(port))
# Fail instead of accidentally testing a different process already on this port.
with socket.socket() as probe:
    probe.bind(("127.0.0.1", port))
with (root / "mcp-server.log").open("w") as log:
    process = subprocess.Popen(["mix", "run", "--no-halt"], cwd=root, env=env, stdout=log, stderr=subprocess.STDOUT)
    try:
        for _ in range(90):
            if process.poll() is not None:
                raise RuntimeError("Local server exited; inspect mcp-server.log")
            try:
                with urllib.request.urlopen(f"http://127.0.0.1:{port}/health", timeout=1) as response:
                    if response.status == 200:
                        break
            except OSError:
                time.sleep(1)
        else:
            raise RuntimeError("Local server readiness timeout")
        subprocess.run([sys.executable, str(root / "scripts/check_mcp.py"), f"http://127.0.0.1:{port}/mcp/public", "--report", "mcp-report.json"], cwd=root, check=True)
    finally:
        process.terminate()
        try:
            process.wait(timeout=10)
        except subprocess.TimeoutExpired:
            process.kill()
            process.wait()
