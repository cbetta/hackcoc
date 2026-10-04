#!/usr/bin/env bash
# Builds the image from this checkout and boots it with no network and a
# read-only filesystem, as jiji runs it, then waits for the Dockerfile's
# HEALTHCHECK and asks nginx for a few paths. CI and deps-factory both run
# this.
set -euo pipefail
cd "$(dirname "$0")/.."

name="hackcoc-smoke-$$"
image="hackcoc-smoke:$$"

cleanup() {
  docker rm -f "$name" > /dev/null 2>&1 || true
  docker image rm "$image" > /dev/null 2>&1 || true
}
trap cleanup EXIT

fail() {
  echo "smoke: $1" >&2
  docker logs --tail 50 "$name" >&2 || true
  exit 1
}

docker build -t "$image" .

# The Dockerfile probes every 60s; every 2s here, so a good boot shows at once.
docker run -d --name "$name" --network none --read-only --tmpfs /tmp \
  --health-interval 2s "$image" > /dev/null

state=""
for _ in $(seq 60); do
  state="$(docker inspect -f '{{.State.Status}} {{.State.Health.Status}}' "$name")"
  case "$state" in
    "running healthy") break ;;
    "running starting") sleep 1 ;;
    *) fail "nginx did not come up ($state)." ;;
  esac
done
[ "$state" = "running healthy" ] || fail "nginx was not healthy after 60s."

# The status line nginx answers with, asked from inside the container (it has
# no network). busybox wget follows redirects, so this uses nc.
status() {
  docker exec "$name" sh -c "printf 'GET $1 HTTP/1.0\r\nHost: hackcodeofconduct.org\r\n\r\n' | nc 127.0.0.1 8080 | head -1 | tr -d '\r'"
}
expect() {
  local got
  got="$(status "$1")"
  [ "$got" = "HTTP/1.1 $2" ] || fail "GET $1 answered '$got', not '$2'."
}

expect / "200 OK"
expect /index.html "200 OK"
expect /robots.txt "200 OK"
expect "/assets/$(cd assets && ls application.debug-*.css)" "200 OK"
expect /nope "404 Not Found"
docker exec "$name" wget -q -O - http://127.0.0.1:8080/ | grep "Hack Code of Conduct" > /dev/null \
  || fail "/ is not the Code of Conduct."

echo "hackcoc is healthy."
