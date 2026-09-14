#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="/usr/local/bin/sort-files"

if [[ ! -w "/usr/local/bin" ]]; then
  sudo install -m 755 "$SCRIPT_DIR/sort-files.sh" "$TARGET"
else
  install -m 755 "$SCRIPT_DIR/sort-files.sh" "$TARGET"
fi

echo "Installed: $TARGET"
