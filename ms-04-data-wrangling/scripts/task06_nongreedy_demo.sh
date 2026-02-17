#!/usr/bin/env bash
set -euo pipefail

echo 'something Disconnected from A Disconnected from B. OK finish string' \
  | sed 's/.*Disconnected from //' \
  > ms-04-data-wrangling/work/task06_greedy.out

echo 'something Disconnected from A Disconnected from B. OK finish string' \
  | perl -pe 's/.*?Disconnected from //' \
  > ms-04-data-wrangling/work/task06_nongreedy.out

echo "OK -> work/task06_greedy.out + work/task06_nongreedy.out"
