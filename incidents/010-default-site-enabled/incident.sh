#!/bin/bash

DEFAULT_SITE="/etc/nginx/sites-enabled/default"

if [ -e "$DEFAULT_SITE" ]; then
    echo "ERROR: Injection failed. Default site is already enabled."
    exit 1
fi

ln -s /etc/nginx/sites-available/default "$DEFAULT_SITE"

if [ ! -L "$DEFAULT_SITE" ]; then
    echo "ERROR: Injection failed. Failed to enable default site."
    exit 1
fi

if ! nginx -t >/dev/null 2>&1; then
    echo "ERROR: Injection failed. Nginx configuration became invalid."
    rm -f "$DEFAULT_SITE"
    exit 1
fi

systemctl reload nginx

for i in {1..20}; do
    if curl -s http://localhost | grep -q "Welcome to nginx!"; then
        exit 0
    fi

    sleep 0.25
done

echo "ERROR: Incident injection failed. Default Nginx page not detected."
exit 1
