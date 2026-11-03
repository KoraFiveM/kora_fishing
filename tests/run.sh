#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
lua tests/catches.lua "${1:-client/fishing.lua}"
lua tests/breakdown.lua
lua tests/sales.lua
lua tests/shops.lua
