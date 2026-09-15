#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="/usr/local/bin/git-diff"

if [[ ! -w "/usr/local/bin" ]]; then
  sudo install -m 755 "$SCRIPT_DIR/diff-file.sh" "$TARGET"
else
  install -m 755 "$SCRIPT_DIR/diff-file.sh" "$TARGET"
fi

echo "Installed: $TARGET"
