#!/usr/bin/env bash

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

die() {
  echo "Error: $*" >&2
  exit 1
}

yaml_value() {
  local file="$1"
  local key="$2"
  awk -F': ' -v k="$key" '$1 == k {print substr($0, index($0,$2)); exit}' "$file" \
    | sed 's/^["'\'']//' | sed 's/["'\'']$//'
}

find_tool_dirs() {
  find "$ROOT_DIR/shell" "$ROOT_DIR/extension" "$ROOT_DIR/web" "$ROOT_DIR/binary" \
    -mindepth 1 -maxdepth 1 -type d 2>/dev/null | sort
}

discover_tools() {
  local dir name type desc
  echo
  echo "Available tools:"
  echo
  for dir in $(find_tool_dirs); do
    [[ -f "$dir/tool.yaml" ]] || continue
    name="$(yaml_value "$dir/tool.yaml" name)"
    type="$(yaml_value "$dir/tool.yaml" type)"
    desc="$(yaml_value "$dir/tool.yaml" description)"
    printf "  %-28s %-12s %s\n" "$name" "$type" "$desc"
  done
  echo
}

install_tool() {
  local dir="$1"
  [[ -f "$dir/install.sh" ]] || {
    echo "⚠ Skipping $(basename "$dir"): no install.sh"
    return
  }

  local name
  name="$(yaml_value "$dir/tool.yaml" name)"
  echo "→ Installing $name"
  chmod +x "$dir/install.sh"
  "$dir/install.sh"
  echo "✓ $name installed"
  echo
}

uninstall_tool() {
  local dir="$1"
  [[ -f "$dir/uninstall.sh" ]] || return 0

  local name
  name="$(yaml_value "$dir/tool.yaml" name)"
  echo "→ Uninstalling $name"
  chmod +x "$dir/uninstall.sh"
  "$dir/uninstall.sh"
  echo "✓ $name uninstalled"
}

run_tool() {
  local requested="$1"
  local dir name

  for dir in $(find_tool_dirs); do
    [[ -f "$dir/tool.yaml" ]] || continue
    name="$(yaml_value "$dir/tool.yaml" name)"
    if [[ "$name" == "$requested" ]]; then
      if [[ -f "$dir/run.sh" ]]; then
        chmod +x "$dir/run.sh"
        exec "$dir/run.sh"
      fi
      if [[ -f "$dir/index.html" ]]; then
        if command -v open >/dev/null 2>&1; then
          open "$dir/index.html"
          exit 0
        elif command -v xdg-open >/dev/null 2>&1; then
          xdg-open "$dir/index.html"
          exit 0
        fi
      fi
      die "Tool '$requested' has no run.sh or index.html"
    fi
  done

  die "Tool '$requested' not found"
}
