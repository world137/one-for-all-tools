#!/usr/bin/env bash
set -euo pipefail
if [[ -e /usr/local/bin/git-diff ]]; then
  sudo rm -f /usr/local/bin/git-diff
fi
