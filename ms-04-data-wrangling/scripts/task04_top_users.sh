#!/usr/bin/env bash
set -euo pipefail

# 复用 task03 的提取逻辑（不依赖之前输出，保证一键可复现）
sed -nE 's/.*Disconnected from (authenticating |invalid )?user ([^ ]+) [0-9.]+ port [0-9]+( \[preauth\])?/\2/p' \
  ms-04-data-wrangling/data/ssh.log \
| sort \
| uniq -c \
| sort -nr \
| head -n 10 \
> ms-04-data-wrangling/work/task04_top_users.out

echo "OK -> ms-04-data-wrangling/work/task04_top_users.out"
