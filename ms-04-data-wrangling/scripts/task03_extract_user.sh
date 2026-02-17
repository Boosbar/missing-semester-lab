#!/usr/bin/env bash
set -euo pipefail
# 只输出匹配成功的行：-n 关闭默认打印；最后的 p 表示替换成功才打印
# -E 启用扩展正则（可以直接用 () ? | + 这些）
sed -nE 's/.*Disconnected from (authenticating |invalid )?user ([^ ]+) [0-9.]+ port [0-9]+( \[preauth\])?/\2/p' \
  ms-04-data-wrangling/data/ssh.log \
  > ms-04-data-wrangling/work/task03_users.out

echo "OK ->  ms-04-data-wrangling/work/task03_users.out"
