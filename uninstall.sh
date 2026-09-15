#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$ROOT_DIR/lib/common.sh"

AVAILABLE_DIRS=()
TOOL_NAMES=()
TOOL_TYPES=()
TOOL_DESCRIPTIONS=()
while IFS= read -r dir; do
  [[ -f "$dir/tool.yaml" ]] || continue
  name="$(yaml_value "$dir/tool.yaml" name)"
  is_installed "$name" || continue
  type="$(yaml_value "$dir/tool.yaml" type)"
  desc="$(yaml_value "$dir/tool.yaml" description)"
  AVAILABLE_DIRS+=("$dir")
  TOOL_NAMES+=("$name")
  TOOL_TYPES+=("$type")
  TOOL_DESCRIPTIONS+=("$desc")
done < <(find_tool_dirs)

if [[ ${#TOOL_NAMES[@]} -eq 0 ]]; then
  echo "No installed tools to uninstall."
  exit 0
fi

echo
echo "Select tools to uninstall:"
echo

for index in "${!TOOL_NAMES[@]}"; do
  printf "  %d) %-28s (%-10s) %s\n" "$((index + 1))" "${TOOL_NAMES[$index]}" "${TOOL_TYPES[$index]}" "${TOOL_DESCRIPTIONS[$index]}"
done

echo
printf "Enter tool numbers separated by spaces or commas, 'a' for all, or 'q' to cancel: "
read -r choices

if [[ "$choices" == "q" || "$choices" == "Q" ]]; then
  echo "Uninstall cancelled."
  exit 0
fi

SELECTED=()
if [[ "$choices" == "a" || "$choices" == "A" ]]; then
  SELECTED=("${AVAILABLE_DIRS[@]}")
else
  choices="${choices//,/ }"
  for choice in $choices; do
    if [[ ! "$choice" =~ ^[0-9]+$ ]] || (( choice < 1 || choice > ${#TOOL_NAMES[@]} )); then
      echo "Invalid selection: $choice" >&2
      exit 1
    fi
    SELECTED+=("${AVAILABLE_DIRS[$((choice - 1))]}")
  done
fi

if [[ ${#SELECTED[@]} -eq 0 ]]; then
  echo "No tools selected."
  exit 0
fi
echo

for dir in "${SELECTED[@]}"; do
  uninstall_tool "$dir" || true
done

echo
echo "✓ Uninstall complete."
