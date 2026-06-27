#!/bin/bash

SERVICE_FILE="/etc/systemd/system/fastapi.service"

if ! grep -q -- "--port 8000" "$SERVICE_FILE"; then
    echo "ERROR: Injection failed. Expected '--port 8000' not found in $SERVICE_FILE."
    exit 1
fi

sed -i 's|--port 8000|--port 9000|' "$SERVICE_FILE"

if grep -q -- "--port 8000" "$SERVICE_FILE"; then
    echo "ERROR: Port replacement failed."
    exit 1
fi

systemctl daemon-reload

systemctl restart fastapi >/dev/null 2>&1 || true

for i in {1..20}; do
    if ss -tln | grep -q ':9000 ' &&
       ! ss -tln | grep -q ':8000 '; then
        exit 0
    fi

    sleep 0.25
done

echo "ERROR: Incident injection failed. FastAPI did not bind to port 9000 in time."
exit 1
