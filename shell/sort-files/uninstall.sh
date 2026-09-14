#!/usr/bin/env bash
set -euo pipefail
if [[ -e /usr/local/bin/sort-files ]]; then
  sudo rm -f /usr/local/bin/sort-files
fi
