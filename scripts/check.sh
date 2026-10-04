#!/usr/bin/env bash
# What "green" means for the site: it has no packages to install, so it is
# every local link and asset resolving the way nginx serves them. CI
# (.github/workflows/ci.yml) and deps-factory both run this.
set -euo pipefail
cd "$(dirname "$0")/.."

python3 scripts/check-links.py . --known scripts/known-broken-links.txt \
  hackcodeofconduct.org www.hackcodeofconduct.org
