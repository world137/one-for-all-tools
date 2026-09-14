#!/usr/bin/env bash
set -euo pipefail
command -v code >/dev/null 2>&1 || {
  echo "VS Code 'code' command not found."
  exit 1
}
echo "Replace extension_id in tool.yaml with your real extension ID."
# code --install-extension yourpublisher.unique-extension
