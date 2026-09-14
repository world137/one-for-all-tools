#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$ROOT_DIR/lib/common.sh"

mapfile -t TOOL_DIRS < <(find_tool_dirs)

if [[ ${#TOOL_DIRS[@]} -eq 0 ]]; then
  echo "No tools found."
  exit 0
fi

echo
echo "╔══════════════════════════════════════════════════╗"
echo "║                 🛠 dev-tools                     ║"
echo "╚══════════════════════════════════════════════════╝"
echo
echo "Select tools to install:"
echo

SELECTED=()
for dir in "${TOOL_DIRS[@]}"; do
  name="$(yaml_value "$dir/tool.yaml" name)"
  type="$(yaml_value "$dir/tool.yaml" type)"
  desc="$(yaml_value "$dir/tool.yaml" description)"
  printf "  [ ] %-28s %-12s %s\n" "$name" "($type)" "$desc"
  SELECTED+=("$dir")
done

echo
echo "This starter installer installs all discovered tools."
echo "For an interactive TUI, install/use a terminal UI such as gum"
echo "or replace lib/ui.sh with your preferred checkbox implementation."
echo

for dir in "${SELECTED[@]}"; do
  install_tool "$dir"
done

echo
echo "✓ Installation complete."
