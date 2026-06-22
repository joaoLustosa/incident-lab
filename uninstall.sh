#!/bin/bash

set -e

echo "[1/7] Validating privileges..."

if [ "$EUID" -ne 0 ]; then
    echo "ERROR: Run as root."
    exit 1
fi

echo "[2/7] Stopping services..."

systemctl stop fastapi 2>/dev/null || true
systemctl stop nginx 2>/dev/null || true

echo "[3/7] Removing systemd service..."

systemctl disable fastapi 2>/dev/null || true

rm -f /etc/systemd/system/fastapi.service

systemctl daemon-reload

echo "[4/7] Removing nginx configuration..."

rm -f /etc/nginx/sites-enabled/incident-lab.conf

rm -f /etc/nginx/sites-available/incident-lab.conf

systemctl reload nginx 2>/dev/null || true

echo "[5/7] Removing command symlinks..."

rm -f /usr/local/bin/incident-start
rm -f /usr/local/bin/incident-reset
rm -f /usr/local/bin/incident-reveal
rm -f /usr/local/bin/incident-lab-uninstall

echo "[6/7] Removing runtime files..."

rm -rf /opt/incident-lab

echo "[7/7] Removing service account..."

userdel incident-lab 2>/dev/null || true

echo
echo "Incident Lab removal complete."
