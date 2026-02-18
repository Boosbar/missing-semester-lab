#!/usr/bin/env bash
set -euo pipefail
mkdir -p ms-05-command-line-env/work
for f in ms-05-command-line-env/scripts/task*.sh; do
  bash "$f"
done
