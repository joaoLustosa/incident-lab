#!/bin/bash

sed -i \
's|location / {|location /|' \
/etc/nginx/sites-available/incident-lab.conf

systemctl restart nginx > /dev/null 2>&1 || true
