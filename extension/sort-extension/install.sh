#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

command -v code >/dev/null 2>&1 || {
  echo "VS Code 'code' command not found."
  echo "Enable the VS Code shell command and run this again."
  exit 1
}

vsix_files=()
while IFS= read -r -d '' file; do
  vsix_files+=("$file")
done < <(find "$SCRIPT_DIR" -maxdepth 1 -type f -name '*.vsix' -print0)

if [[ ${#vsix_files[@]} -eq 0 ]]; then
  echo "No VSIX package found in $SCRIPT_DIR." >&2
  echo "Build or copy a .vsix file there, then run this again." >&2
  exit 1
fi

if [[ ${#vsix_files[@]} -gt 1 ]]; then
  echo "Multiple VSIX packages found in $SCRIPT_DIR; keep only the package to install." >&2
  exit 1
fi

code --install-extension "${vsix_files[0]}" --force
