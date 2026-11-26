"""Exercise deployment ordering and rollback without Docker or network access."""
import os
from pathlib import Path
import subprocess
import tarfile
import tempfile
import unittest

SCRIPT = Path(__file__).resolve().parents[1] / "deploy/deploy.sh"
REVISION = "a" * 40
PREVIOUS = "b" * 40

class DeployTest(unittest.TestCase):
    def exercise(self, failure=""):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            base = root / "service"
            for part in ("releases", "deploy", "shared"):
                (base / part).mkdir(parents=True)
            (base / "deploy/revision").write_text(PREVIOUS + "\n")
            script = root / "deploy.sh"
            script.write_text(SCRIPT.read_text().replace("base=/opt/ecidadao", f"base={base}"))
            source = root / "Dockerfile"
            source.write_text("FROM scratch\n")
            with tarfile.open(root / "source.tar.gz", "w:gz") as archive:
                archive.add(source, arcname="source/Dockerfile")
            bin_dir = root / "bin"
            bin_dir.mkdir()
            stubs = {
                "docker": '''#!/bin/sh
printf '%s\\n' "$*" >> "$TEST_ROOT/docker.log"
case "$1" in
  inspect) echo sha256:previous ;;
  build) [ "$TEST_FAILURE" != build ] || exit 1 ;;
esac
''',
                "curl": '''#!/bin/sh
while [ "$#" -gt 0 ]; do
  if [ "$1" = -o ]; then cp "$TEST_ROOT/source.tar.gz" "$2"; exit; fi
  shift
done
exit 1
''',
                "python3": '''#!/bin/sh
if [ "$TEST_FAILURE" = public ] && [ "$2" = https://ecidadao.pt ]; then exit 1; fi
exit 0
''',
                "sleep": "#!/bin/sh\nexit 0\n",
                "flock": "#!/bin/sh\nexit 0\n",
            }
            for name, content in stubs.items():
                file = bin_dir / name
                file.write_text(content)
                file.chmod(0o755)
            env = dict(os.environ, PATH=str(bin_dir) + ":" + os.environ["PATH"],
                       TEST_ROOT=str(root), TEST_FAILURE=failure)
            result = subprocess.run(["bash", str(script), "deploy " + REVISION],
                                    env=env, capture_output=True, text=True)
            self.assertTrue((root / "docker.log").exists(), result.stderr)
            log = (root / "docker.log").read_text()
            return result, log, (base / "deploy/revision").read_text().strip()

    def test_success_records_revision_after_switch(self):
        result, log, revision = self.exercise()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(revision, REVISION)
        self.assertEqual(log.count("compose -p ecidadao"), 1)
        self.assertLess(log.index("run -d"), log.index("compose -p"))

    def test_failed_public_check_restores_previous_service(self):
        result, log, revision = self.exercise("public")
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(revision, PREVIOUS)
        self.assertEqual(log.count("compose -p ecidadao"), 2)
        self.assertIn("Previous version restored", result.stderr)

    def test_build_failure_does_not_replace_service(self):
        result, log, revision = self.exercise("build")
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(revision, PREVIOUS)
        self.assertNotIn("compose -p", log)

if __name__ == "__main__":
    unittest.main()
