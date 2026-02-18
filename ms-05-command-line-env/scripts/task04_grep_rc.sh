#!/usr/bin/env bash
set -euo pipefail
mkdir -p ms-05-command-line-env/work

targets=(~/.bashrc ~/.profile ~/.zshrc ~/.tmux.conf /etc/profile /etc/bash.bashrc)
{
  echo "== grep tmux/TMUX/stty/alias in rc files =="
  for f in "${targets[@]}"; do
    [ -f "$f" ] || continue
    echo "--- $f ---"
    grep -nE 'tmux|TMUX|stty -ixon|alias ' "$f" || true
  done
} > ms-05-command-line-env/work/task04_grep_rc.out

echo "OK -> work/task04_grep_rc.out"
