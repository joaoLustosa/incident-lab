#!/bin/bash

sed -i \
's|proxy_pass http://127.0.0.1:8000;|proxy_pass http://127.0.0.1:9000;|' \
/etc/nginx/sites-available/incident-lab.conf

if ! systemctl restart nginx; then
    echo "ERROR: Incident injection failed."
    exit 1
fi
