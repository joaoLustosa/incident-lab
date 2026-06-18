#!/bin/bash

sed -i \
's|location / {|location /|' \
/etc/nginx/sites-available/default

systemctl restart nginx > /dev/null 2>&1 || true
