#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$ROOT_DIR/lib/common.sh"

mapfile -t TOOL_DIRS < <(find_tool_dirs)

for dir in "${TOOL_DIRS[@]}"; do
  uninstall_tool "$dir" || true
done

echo
echo "✓ Uninstall complete."
