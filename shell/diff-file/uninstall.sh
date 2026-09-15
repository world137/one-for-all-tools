#!/usr/bin/env bash
set -euo pipefail
if [[ -e /usr/local/bin/diff-file ]]; then
  sudo rm -f /usr/local/bin/diff-file
fi
