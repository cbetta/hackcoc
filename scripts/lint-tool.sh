#!/usr/bin/env bash
# Runs a pinned shellcheck, actionlint, ruff or oxlint, so the checks behave
# the same on a laptop, on the CI runners and in deps-factory, none of which
# need it installed. Each archive is downloaded once into the cache; every
# run copies it out, checks its SHA-256 and unpacks it afresh, so nothing in
# the cache is trusted.
#   scripts/lint-tool.sh <shellcheck|actionlint|ruff|oxlint> [args...]
set -euo pipefail

case "$(uname -s)/$(uname -m)" in
  Linux/x86_64) platform=linux-x64 ;;
  Linux/aarch64 | Linux/arm64) platform=linux-arm64 ;;
  Darwin/x86_64) platform=darwin-x64 ;;
  Darwin/arm64) platform=darwin-arm64 ;;
  *) echo "lint-tool: no pinned build for $(uname -s)/$(uname -m)" >&2; exit 1 ;;
esac
# In Actions, the job's own temp folder: the jiji-ci runners share HOME
# between repos.
cache="${RUNNER_TEMP:-${XDG_CACHE_HOME:-$HOME/.cache}}/lint-tools"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

sha256() {
  if command -v sha256sum >/dev/null; then sha256sum "$1" | cut -d' ' -f1; else shasum -a 256 "$1" | cut -d' ' -f1; fi
}

# Sets $bin to the tool, unpacked into $work from an archive checked against
# its SHA-256, downloading the archive first if the cache doesn't have it.
ensure() {
  local tool=$1 version url sha member asset
  case "$tool/$platform" in
    shellcheck/linux-x64) asset=linux.x86_64 sha=8c3be12b05d5c177a04c29e3c78ce89ac86f1595681cab149b65b97c4e227198 ;;
    shellcheck/linux-arm64) asset=linux.aarch64 sha=12b331c1d2db6b9eb13cfca64306b1b157a86eb69db83023e261eaa7e7c14588 ;;
    shellcheck/darwin-x64) asset=darwin.x86_64 sha=3c89db4edcab7cf1c27bff178882e0f6f27f7afdf54e859fa041fca10febe4c6 ;;
    shellcheck/darwin-arm64) asset=darwin.aarch64 sha=56affdd8de5527894dca6dc3d7e0a99a873b0f004d7aabc30ae407d3f48b0a79 ;;
    actionlint/linux-x64) asset=linux_amd64 sha=8aca8db96f1b94770f1b0d72b6dddcb1ebb8123cb3712530b08cc387b349a3d8 ;;
    actionlint/linux-arm64) asset=linux_arm64 sha=325e971b6ba9bfa504672e29be93c24981eeb1c07576d730e9f7c8805afff0c6 ;;
    actionlint/darwin-x64) asset=darwin_amd64 sha=5b44c3bc2255115c9b69e30efc0fecdf498fdb63c5d58e17084fd5f16324c644 ;;
    actionlint/darwin-arm64) asset=darwin_arm64 sha=aba9ced2dee8d27fecca3dc7feb1a7f9a52caefa1eb46f3271ea66b6e0e6953f ;;
    ruff/linux-x64) asset=x86_64-unknown-linux-gnu sha=a293ac937715ae6fb6b64da86761598379e6149f40fbc00fde9ba8a2a562ac65 ;;
    ruff/linux-arm64) asset=aarch64-unknown-linux-gnu sha=d3ead1f0ed779e777a034ccd9286be6bd9bd3cdaba732ff9797f8288a283e9e2 ;;
    ruff/darwin-x64) asset=x86_64-apple-darwin sha=88ee16f88dba9d440e06375f46898ec85baf578042ad086764d5a33558bb6e17 ;;
    ruff/darwin-arm64) asset=aarch64-apple-darwin sha=1c8e6e36538eaa0b996378a20c226403c4ca6369ac24884751b024d3a9530b86 ;;
    oxlint/linux-x64) asset=x86_64-unknown-linux-gnu sha=ce05865b75d9a51a03052c256068e63501ba2d4e6327376b2affbe14bf975b3c ;;
    oxlint/linux-arm64) asset=aarch64-unknown-linux-gnu sha=d15f1941e903795b30f9a02bec2c015ef903eef271f43f408c021599bca7301c ;;
    oxlint/darwin-x64) asset=x86_64-apple-darwin sha=9a591fb3e4837052a4137f8e22738d9cb888f8ab2ddd80c683b7bd68e9b674b2 ;;
    oxlint/darwin-arm64) asset=aarch64-apple-darwin sha=2d42070507d549f064f1fe11220970ddea868eff99da4c0696be728236bc0200 ;;
    *) echo "lint-tool: unknown tool '$tool'" >&2; exit 1 ;;
  esac
  case "$tool" in
    shellcheck)
      version=v0.11.0
      url="https://github.com/koalaman/shellcheck/releases/download/$version/shellcheck-$version.$asset.tar.xz"
      member="shellcheck-$version/shellcheck" ;;
    actionlint)
      version=1.7.12
      url="https://github.com/rhysd/actionlint/releases/download/v$version/actionlint_${version}_$asset.tar.gz"
      member=actionlint ;;
    ruff)
      version=0.17.1
      url="https://github.com/astral-sh/ruff/releases/download/$version/ruff-$asset.tar.gz"
      member="ruff-$asset/ruff" ;;
    oxlint)
      version=1.88.0
      url="https://github.com/oxc-project/oxc/releases/download/oxlint_v$version/oxlint-$asset.tar.gz"
      member="oxlint-$asset" ;;
  esac

  local cached="$cache/$tool-$version-${url##*/}" copy="$work/$tool-archive"
  if [ ! -f "$cached" ] || ! cp "$cached" "$copy" || [ "$(sha256 "$copy")" != "$sha" ]; then
    curl -fsSL --retry 3 -o "$copy" "$url"
    local actual
    actual="$(sha256 "$copy")"
    if [ "$actual" != "$sha" ]; then
      echo "lint-tool: $url has SHA-256 $actual, expected $sha" >&2
      exit 1
    fi
    mkdir -p "$cache" && cp "$copy" "$cached.$$" && mv "$cached.$$" "$cached" || true
  fi
  mkdir "$work/$tool"
  tar -xf "$copy" -C "$work/$tool"
  bin="$work/$tool/$member"
}

tool="${1:?usage: scripts/lint-tool.sh <shellcheck|actionlint|ruff|oxlint> [args...]}"
shift
if [ "$tool" = actionlint ]; then
  # actionlint runs shellcheck over each workflow's run: blocks.
  ensure shellcheck
  shellcheck="$bin"
  ensure actionlint
  "$bin" -shellcheck "$shellcheck" "$@"
else
  ensure "$tool"
  "$bin" "$@"
fi
