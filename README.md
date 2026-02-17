# Missing Semester Lab
➡️ MS4 Notes: [ms-04-data-wrangling/notes/ms4.md](ms-04-data-wrangling/notes/ms4.md)


A reproducible learning log for MIT Missing Semester.

## Structure
- `logbook/`: daily progress logs
- `ms-04-data-wrangling/`: lecture reproduction + exercises + scripts

## Quickstart
```bash
bash run.sh

cat > run.sh << 'EOF'
#!/usr/bin/env bash
set -euo pipefail
echo "[L4] running tasks..."
cd ms-04-data-wrangling
mkdir -p work
for f in scripts/task*.sh; do
echo "==> $f"
bash "$f"
done
echo "done."
