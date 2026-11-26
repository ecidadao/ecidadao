#!/usr/bin/env bash
# Root-owned forced SSH command. Accepts only a commit SHA, never arbitrary shell.
set -Eeuo pipefail
umask 027
if [[ $# != 1 || ! $1 =~ ^(deploy|rollback)\ ([0-9a-f]{40})$ ]]; then
  echo 'Expected: deploy|rollback <40-character commit SHA>' >&2
  exit 2
fi
mode=${BASH_REMATCH[1]}
revision=${BASH_REMATCH[2]}
base=/opt/ecidadao
exec 9>"$base/deploy.lock"
flock -w 900 9
image="ecidadao-release:$revision"
compose="$base/deploy/compose.production.yaml"
previous_image=$(docker inspect ecidadao-app-1 --format '{{.Image}}')
previous_revision=$(cat "$base/deploy/revision" 2>/dev/null || echo legacy)
switch_started=0
candidate="ecidadao-candidate-${revision:0:12}"
work=$(mktemp -d "$base/releases/build-XXXXXX")
cleanup() {
  docker rm -f "$candidate" >/dev/null 2>&1 || true
  rm -rf "$work"
}
rollback_on_error() {
  local status=${1:-$?}
  trap - ERR
  if [[ $switch_started == 1 ]]; then
    echo "Deployment failed; restoring $previous_revision" >&2
    ECIDADAO_IMAGE="$previous_image" RELEASE_SHA="$previous_revision" \
      docker compose -p ecidadao -f "$compose" up -d --no-build --pull never
    for attempt in $(seq 1 30); do
      if python3 "$base/deploy/smoke.py" http://127.0.0.1:8091 --revision "$previous_revision"; then
        echo 'Previous version restored' >&2
        exit "$status"
      fi
      sleep 2
    done
    echo 'CRITICAL: previous version did not pass health checks' >&2
  fi
  exit "$status"
}
trap cleanup EXIT
trap rollback_on_error ERR
if [[ $mode == deploy ]]; then
  curl --fail --silent --show-error --location --retry 3 \
    "https://codeload.github.com/ecidadao/ecidadao/tar.gz/$revision" -o "$work/source.tar.gz"
  mkdir "$work/source"
  tar -xzf "$work/source.tar.gz" --strip-components=1 -C "$work/source"
  docker build --label "org.opencontainers.image.revision=$revision" \
    --label org.opencontainers.image.source=https://github.com/ecidadao/ecidadao \
    -t "$image" "$work/source"
else
  docker image inspect "$image" >/dev/null
fi
# Exercise the candidate on a private port before replacing the public service.
docker run -d --name "$candidate" --log-driver none \
  --env-file "$base/shared/.env" -e PORT=4000 -e "RELEASE_SHA=$revision" \
  -p 127.0.0.1:8092:4000 "$image" >/dev/null
ready=0
for attempt in $(seq 1 30); do
  if python3 "$base/deploy/smoke.py" http://127.0.0.1:8092 --revision "$revision"; then
    ready=1
    break
  fi
  sleep 2
done
if [[ $ready != 1 ]]; then
  rollback_on_error 1
fi
docker rm -f "$candidate" >/dev/null
switch_started=1
ECIDADAO_IMAGE="$image" RELEASE_SHA="$revision" \
  docker compose -p ecidadao -f "$compose" up -d --no-build --pull never
ready=0
for attempt in $(seq 1 30); do
  if python3 "$base/deploy/smoke.py" http://127.0.0.1:8091 --revision "$revision" && \
     python3 "$base/deploy/smoke.py" https://ecidadao.pt --revision "$revision"; then
    ready=1
    break
  fi
  sleep 2
done
if [[ $ready != 1 ]]; then
  rollback_on_error 1
fi
printf '%s\n' "$previous_revision" > "$base/deploy/previous-revision"
printf '%s\n' "$revision" > "$base/deploy/revision"
switch_started=0
echo "Deployed $revision to https://ecidadao.pt"
