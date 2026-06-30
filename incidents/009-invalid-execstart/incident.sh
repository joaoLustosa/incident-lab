#!/bin/bash

SERVICE_FILE="/etc/systemd/system/fastapi.service"

if ! grep -q -w "/opt/incident-lab/venv/bin/uvicorn" "$SERVICE_FILE"; then
    echo "ERROR: Injection failed. Expected ExecStart binary (uvicorn) not found."
    exit 1
fi

sed --follow-symlinks -i \
's|/opt/incident-lab/venv/bin/uvicorn|/opt/incident-lab/venv/bin/uvicornx|' \
"$SERVICE_FILE"

if ! grep -q "/opt/incident-lab/venv/bin/uvicornx" "$SERVICE_FILE"; then
    echo "ERROR: Injection failed. ExecStart replacement failed."
    exit 1
fi

systemctl daemon-reload

INJECTION_TIME=$(date '+%Y-%m-%d %H:%M:%S')

systemctl restart fastapi >/dev/null 2>&1 || true

for i in {1..20}; do
    if journalctl -u fastapi --since "$INJECTION_TIME" --no-pager \
        | grep -q -E "Failed to locate executable|Failed at step EXEC"; then
        exit 0
    fi

    sleep 0.25
done

echo "ERROR: Incident injection failed. Expected executable error not found in recent logs."
exit 1
