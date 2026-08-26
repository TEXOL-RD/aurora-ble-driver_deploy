#!/usr/bin/env bash

set -e

WORKING_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=========================================="
echo "  Preparing BLE Driver System Files...    "
echo "=========================================="

sudo mkdir -p /usr/share/texol

if [ -f "$WORKING_DIR/config/GatewayIP.txt" ]; then
    sudo cp -rf "$WORKING_DIR/config/GatewayIP.txt" /usr/share/texol/
    echo "[INFO] Copied GatewayIP.txt to /usr/share/texol/"
else
    echo "192.168.10.1" | sudo tee /usr/share/texol/GatewayIP.txt > /dev/null
    echo "[WARN] config/GatewayIP.txt not found. Created default IP (192.168.10.1)"
fi

echo ""
echo "=========================================="
echo "  Starting Docker Containers...           "
echo "=========================================="
docker compose up -d

echo ""
echo "=========================================="
echo "  Deployment Complete!                    "
echo "=========================================="