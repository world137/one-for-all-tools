#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="/usr/local/bin/pdftopng"

command -v go >/dev/null 2>&1 || {
  echo "Error: 'go' was not found on PATH." >&2
  echo "Install Go (https://go.dev/doc/install) and run install.sh again." >&2
  exit 1
}

if ! command -v pdftoppm >/dev/null 2>&1; then
  echo "Warning: 'pdftoppm' (poppler) was not found on PATH." >&2
  echo "pdftopng will build, but conversions will fail until it's installed:" >&2
  echo "  macOS:         brew install poppler" >&2
  echo "  Debian/Ubuntu: sudo apt install poppler-utils" >&2
fi

BUILD_DIR="$(mktemp -d)"
trap 'rm -rf "$BUILD_DIR"' EXIT

(cd "$SCRIPT_DIR" && go build -o "$BUILD_DIR/pdftopng" .)

if [[ ! -w "/usr/local/bin" ]]; then
  sudo install -m 755 "$BUILD_DIR/pdftopng" "$TARGET"
else
  install -m 755 "$BUILD_DIR/pdftopng" "$TARGET"
fi

echo "Installed: $TARGET"
