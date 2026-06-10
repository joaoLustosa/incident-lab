#!/bin/bash

sudo sed -i \
's|location / {|location /|' \
/etc/nginx/sites-available/default

sudo systemctl restart nginx > /dev/null 2>&1 || true
