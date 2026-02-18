#!/usr/bin/env bash
set -euo pipefail
mkdir -p ms-05-command-line-env/work

{
  echo "SHELL=$SHELL"
  echo "argv0=$0"
  echo "SHLVL=${SHLVL:-}"
  echo "TMUX=${TMUX:-}"
  echo
  echo "login_shell?"
  shopt -q login_shell && echo "yes" || echo "no"
  echo
  echo "jobs -l:"
  jobs -l || true
} > ms-05-command-line-env/work/task02_shell_diag.out

echo "OK -> work/task02_shell_diag.out"
