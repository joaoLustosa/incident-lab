#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

cd "$SCRIPT_DIR"

echo "[1/10] Validating privileges..."

if [ "$EUID" -ne 0 ]; then
    echo "ERROR: Run as root."
    exit 1
fi

echo "[2/10] Validating operating system..."

source /etc/os-release

if [ "$ID" != "debian" ]; then
    echo "ERROR: Incident Lab currently supports Debian only."
    exit 1
fi

echo "[3/10] Installing packages..."

apt update

apt install -y \
    nginx \
    python3 \
    python3-venv \
    curl

echo "[4/10] Creating service account..."

if ! id incident-lab >/dev/null 2>&1; then
    useradd \
        --system \
        --home /opt/incident-lab \
        --shell /usr/sbin/nologin \
        incident-lab
fi

echo "[5/10] Creating runtime directories..."

mkdir -p \
    /opt/incident-lab/app \
    /opt/incident-lab/baseline \
    /opt/incident-lab/config \
    /opt/incident-lab/incidents \
    /opt/incident-lab/incident-state \
    /opt/incident-lab/logs

chown -R incident-lab:incident-lab /opt/incident-lab

echo "[6/10] Creating Python environment..."

if [ ! -d /opt/incident-lab/venv ]; then
    runuser -u incident-lab -- \
        python3 -m venv /opt/incident-lab/venv
fi

runuser -u incident-lab -- \
    /opt/incident-lab/venv/bin/pip install \
    fastapi \
    uvicorn

echo "[7/10] Deploying application..."

cp assets/app/main.py \
    /opt/incident-lab/app/main.py

chown incident-lab:incident-lab \
    /opt/incident-lab/app/main.py

echo "[8/10] Deploying systemd service..."

cp assets/systemd/fastapi.service \
    /etc/systemd/system/fastapi.service

systemctl daemon-reload

systemctl enable fastapi

echo "[9/10] Deploying nginx configuration..."

cp assets/nginx/incident-lab.conf \
    /etc/nginx/sites-available/incident-lab.conf

rm -f /etc/nginx/sites-enabled/default

ln -sf \
    /etc/nginx/sites-available/incident-lab.conf \
    /etc/nginx/sites-enabled/incident-lab.conf

/usr/sbin/nginx -t

echo "[10/10] Starting services..."

systemctl restart fastapi
systemctl restart nginx

echo "Waiting for services..."

sleep 3

echo "Running health checks..."

./healthcheck.sh

echo
echo "Incident Lab installation complete."
