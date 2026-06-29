#!/bin/bash

APP_FILE="/opt/incident-lab/app/main.py"

if [ ! -f "$APP_FILE" ]; then
    echo "ERROR: Injection failed. $APP_FILE not found."
    exit 1
fi

rm -f "$APP_FILE"

if [ -f "$APP_FILE" ]; then
    echo "ERROR: Injection failed. Failed to remove $APP_FILE."
    exit 1
fi

INJECTION_TIME=$(date '+%Y-%m-%d %H:%M:%S')

systemctl restart fastapi >/dev/null 2>&1 || true

for i in {1..20}; do
    if journalctl -u fastapi --since "$INJECTION_TIME" --no-pager \
        | grep -q 'Could not import module "main"'; then
        exit 0
    fi

    sleep 0.25
done

echo "ERROR: Incident injection failed. Expected application load failure not found in recent logs."
exit 1
