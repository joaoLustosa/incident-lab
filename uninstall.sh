#!/bin/bash

set -e

echo "[1/6] Validating privileges..."

if [ "$EUID" -ne 0 ]; then
    echo "ERROR: Run as root."
    exit 1
fi

echo "[2/6] Stopping services..."

systemctl stop fastapi 2>/dev/null || true

echo "[3/6] Removing systemd service..."

systemctl disable fastapi 2>/dev/null || true

rm -f /etc/systemd/system/fastapi.service

systemctl daemon-reload

echo "[4/6] Removing nginx configuration..."

rm -f /etc/nginx/sites-enabled/incident-lab.conf

rm -f /etc/nginx/sites-available/incident-lab.conf

systemctl reload nginx 2>/dev/null || true

echo "[5/6] Removing runtime files..."

rm -rf /opt/incident-lab

echo "[6/6] Removing service account..."

userdel incident-lab 2>/dev/null || true

echo
echo "Incident Lab removal complete."
