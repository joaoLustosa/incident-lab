#!/bin/bash

systemctl disable fastapi

if ! systemctl stop fastapi; then
    echo "ERROR: Incident injection failed."
    exit 1
fi
