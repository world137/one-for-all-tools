#!/usr/bin/env bash

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STATE_FILE="${DEV_TOOLS_STATE_FILE:-$HOME/.config/dev-tools/installed}"

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

is_installed() {
  local name="$1"
  [[ -f "$STATE_FILE" ]] && grep -qxF "$name" "$STATE_FILE"
}

mark_installed() {
  local name="$1"
  mkdir -p "$(dirname "$STATE_FILE")"
  touch "$STATE_FILE"
  is_installed "$name" || echo "$name" >> "$STATE_FILE"
}

unmark_installed() {
  local name="$1"
  [[ -f "$STATE_FILE" ]] || return 0
  grep -vxF "$name" "$STATE_FILE" > "$STATE_FILE.tmp" || true
  mv "$STATE_FILE.tmp" "$STATE_FILE"
}

list_installed_tools() {
  local dir name type desc any=0
  echo
  echo "Installed tools:"
  echo
  for dir in $(find_tool_dirs); do
    [[ -f "$dir/tool.yaml" ]] || continue
    name="$(yaml_value "$dir/tool.yaml" name)"
    is_installed "$name" || continue
    type="$(yaml_value "$dir/tool.yaml" type)"
    desc="$(yaml_value "$dir/tool.yaml" description)"
    printf "  %-28s %-12s %s\n" "$name" "$type" "$desc"
    any=1
  done
  if [[ "$any" -eq 0 ]]; then
    echo "  (none yet — run './tools install' or './tools install-all')"
  fi
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
  mark_installed "$name"
  echo "✓ $name installed"
  echo
}

install_all_tools() {
  local dir
  for dir in $(find_tool_dirs); do
    [[ -f "$dir/tool.yaml" ]] || continue
    install_tool "$dir"
  done
  echo "✓ Installation complete."
}

uninstall_tool() {
  local dir="$1"
  [[ -f "$dir/uninstall.sh" ]] || return 0

  local name
  name="$(yaml_value "$dir/tool.yaml" name)"
  echo "→ Uninstalling $name"
  chmod +x "$dir/uninstall.sh"
  "$dir/uninstall.sh"
  unmark_installed "$name"
  echo "✓ $name uninstalled"
}

link_tools_cli() {
  local root_dir="$1"

  # /usr/local/bin is on PATH by default for every shell (macOS wires it in
  # via /etc/paths through path_helper, independent of ~/.zshrc / ~/.bashrc,
  # and most Linux distros ship it on PATH too), so prefer it over a
  # per-user directory that would require editing a shell profile.
  if [[ -d /usr/local/bin && -w /usr/local/bin ]]; then
    ln -sf "$root_dir/tools" "/usr/local/bin/tools"
    echo "✓ Linked /usr/local/bin/tools -> $root_dir/tools"
    echo "You can now run 'tools' from any directory."
    return
  fi

  if [[ -d /usr/local/bin && -t 0 ]] && command -v sudo >/dev/null 2>&1; then
    echo "/usr/local/bin needs elevated permission to write to."
    if sudo ln -sf "$root_dir/tools" "/usr/local/bin/tools"; then
      echo "✓ Linked /usr/local/bin/tools -> $root_dir/tools"
      echo "You can now run 'tools' from any directory."
      return
    fi
    echo "⚠ Could not write to /usr/local/bin, falling back to ~/.local/bin."
  fi

  mkdir -p "$HOME/.local/bin"
  ln -sf "$root_dir/tools" "$HOME/.local/bin/tools"
  echo "✓ Linked $HOME/.local/bin/tools -> $root_dir/tools"

  case ":$PATH:" in
    *":$HOME/.local/bin:"*) ;;
    *)
      echo "⚠ $HOME/.local/bin is not on your PATH. Add it to your shell's"
      echo "  profile (e.g. ~/.zshrc, ~/.bashrc, ~/.profile) or move the"
      echo "  symlink into a directory already on PATH:"
      echo "    export PATH=\"$HOME/.local/bin:\$PATH\""
      ;;
  esac

  echo "You can now run 'tools' from any directory."
}

unlink_tools_cli() {
  local candidate removed=0

  for candidate in /usr/local/bin "$HOME/.local/bin"; do
    if [[ -L "$candidate/tools" ]]; then
      rm -f "$candidate/tools"
      echo "✓ Removed $candidate/tools"
      removed=1
    fi
  done

  [[ "$removed" -eq 1 ]] || echo "No 'tools' symlink found on PATH."
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
