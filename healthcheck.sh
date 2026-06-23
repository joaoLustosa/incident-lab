#!/bin/bash

if [ "$EUID" -ne 0 ]; then
    echo "ERROR: Run as root."
    exit 1
fi

LAB_ROOT="/opt/incident-lab"

source "$LAB_ROOT/config/lab.conf"

set -e

echo "Checking FastAPI service..."

if systemctl is-active --quiet fastapi; then
    echo "PASS"
else
    echo "FAIL"
    exit 1
fi

echo "Checking Nginx service..."

if systemctl is-active --quiet nginx; then
    echo "PASS"
else
    echo "FAIL"
    exit 1
fi

echo "Validating Nginx configuration..."

if /usr/sbin/nginx -t >/dev/null 2>&1; then
    echo "PASS"
else
    echo "FAIL"
    exit 1
fi

echo "Performing HTTP health check..."

if curl --fail --silent "$HEALTHCHECK_URL" >/dev/null; then
    echo "PASS"
else
    echo "FAIL"
    exit 1
fi

echo
echo "Environment healthy."
