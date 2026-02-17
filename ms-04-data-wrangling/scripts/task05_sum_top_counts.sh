#!/usr/bin/env bash
set -euo pipefail

# 确保 task04 已生成
bash ms-04-data-wrangling/scripts/task04_top_users.sh >/dev/null

# 取第一列计数 -> 拼成加法表达式 -> bc 求值
awk '{print $1}' ms-04-data-wrangling/work/task04_top_users.out \
  | paste -sd+ \
  | bc \
  > ms-04-data-wrangling/work/task05_sum_top_counts.out

echo "OK -> ms-04-data-wrangling/work/task05_sum_top_counts.out"
