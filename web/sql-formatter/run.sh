#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if command -v open >/dev/null 2>&1; then
  open "$SCRIPT_DIR/index.html"
elif command -v xdg-open >/dev/null 2>&1; then
  xdg-open "$SCRIPT_DIR/index.html"
else
  echo "Open: $SCRIPT_DIR/index.html"
fi
