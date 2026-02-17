#!/usr/bin/env bash
set -euo pipefail

# 不管从哪里执行，都先切到仓库根目录
cd "$(dirname "$0")/.."

mkdir -p ms-04-data-wrangling/work

for f in ms-04-data-wrangling/scripts/task*.sh; do
  echo "==> $f"
  bash "$f"
done

echo
echo "Outputs:"
ls -1 ms-04-data-wrangling/work | sed 's/^/  ms-04-data-wrangling\/work\//'
