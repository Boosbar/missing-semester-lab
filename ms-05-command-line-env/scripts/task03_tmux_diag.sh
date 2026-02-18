#!/usr/bin/env bash
set -euo pipefail
mkdir -p ms-05-command-line-env/work

{
  echo "TMUX=${TMUX:-<empty>}"
  echo
  echo "tmux prefix:"
  tmux show -g prefix 2>/dev/null || echo "<no tmux server>"
  echo
  echo "tmux sessions:"
  tmux ls 2>/dev/null || echo "<no tmux server>"
  echo
  echo "current client:"
  tmux display-message -p '#S:#I.#P' 2>/dev/null || echo "<not inside tmux>"
} > ms-05-command-line-env/work/task03_tmux_diag.out

echo "OK -> work/task03_tmux_diag.out"
