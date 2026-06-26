#!/bin/bash

cat > /opt/incident-lab/app/main.py <<'EOF'
from fastapi import FastAPI

app = FastAPI()

@app.get("/")
def root(
    return {"status": "ok"}
EOF

systemctl restart fastapi >/dev/null 2>&1 || true

for i in {1..20}; do
    if ! systemctl is-active --quiet fastapi; then
        exit 0
    fi
    sleep 0.25
done

echo "ERROR: Incident injection failed. FastAPI remained active."
exit 1
