#!/usr/bin/env bash
set -euo pipefail
mkdir -p ms-05-command-line-env/work

{
  echo "== ssh client =="
  command -v ssh && ssh -V || echo "ssh not found"

  echo
  echo "== sshd exists? =="
  command -v sshd && echo "sshd: yes" || echo "sshd: no"

  echo
  echo "== listen ports (sshd) =="
  ss -lntp 2>/dev/null | grep -E '(:22|sshd)' || echo "<no sshd listen found>"
} > ms-05-command-line-env/work/task01_ssh_diag.out

echo "OK -> work/task01_ssh_diag.out"
