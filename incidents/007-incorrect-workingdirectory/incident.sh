#!/bin/bash

SERVICE_FILE="/etc/systemd/system/fastapi.service"

if ! grep -q -- "WorkingDirectory=/opt/incident-lab/app" "$SERVICE_FILE"; then
    echo "ERROR: Injection failed. Expected WorkingDirectory not found."
    exit 1
fi

sed --follow-symlinks -i \
's|WorkingDirectory=/opt/incident-lab/app|WorkingDirectory=/opt/incident-lab|' \
"$SERVICE_FILE"

if grep -q -- "WorkingDirectory=/opt/incident-lab/app" "$SERVICE_FILE"; then
    echo "ERROR: WorkingDirectory replacement failed."
    exit 1
fi

systemctl daemon-reload

INJECTION_TIME=$(date --iso-8601=seconds)

systemctl restart fastapi >/dev/null 2>&1 || true

for i in {1..20}; do
    if journalctl -u fastapi --since "$INJECTION_TIME" --no-pager | grep -q 'Could not import module "main"'; then
        exit 0
    fi

    sleep 0.25
done

echo "ERROR: Incident injection failed. Expected import error not found in recent logs."
exit 1
