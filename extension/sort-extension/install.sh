#!/usr/bin/env bash
set -euo pipefail

command -v code >/dev/null 2>&1 || {
  echo "VS Code 'code' command not found."
  echo "Enable the VS Code shell command and run this again."
  exit 1
}

echo "Replace extension_id in tool.yaml with your real extension ID."
# code --install-extension yourpublisher.sort-extension
