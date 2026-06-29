#!/bin/bash

APP_FILE="/opt/incident-lab/app/main.py"

if [ ! -f "$APP_FILE" ]; then
    echo "ERROR: Injection failed. $APP_FILE not found."
    exit 1
fi

if ! chown root:root "$APP_FILE" || ! chmod 600 "$APP_FILE"; then
    echo "ERROR: Injection failed. Failed to change file ownership or permissions."
    exit 1
fi

if [ "$(stat -c '%U:%G' "$APP_FILE")" != "root:root" ] ||
   [ "$(stat -c '%a' "$APP_FILE")" != "600" ]; then
    echo "ERROR: Injection failed. File ownership or permission verification failed."
    exit 1
fi

INJECTION_TIME=$(date '+%Y-%m-%d %H:%M:%S')

systemctl restart fastapi >/dev/null 2>&1 || true

for i in {1..20}; do
    if journalctl -u fastapi --since "$INJECTION_TIME" --no-pager \
        | grep -q -i "permission denied"; then
        echo "SUCCESS: Incident injected successfully."
        exit 0
    fi
    sleep 0.25
done

echo "ERROR: Incident injection failed. Expected permission error not found in recent logs."
exit 1
