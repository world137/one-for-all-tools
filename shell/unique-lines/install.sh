#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ ! -w "/usr/local/bin" ]]; then
  sudo install -m 755 "$SCRIPT_DIR/unique-lines.sh" /usr/local/bin/unique-lines
else
  install -m 755 "$SCRIPT_DIR/unique-lines.sh" /usr/local/bin/unique-lines
fi
