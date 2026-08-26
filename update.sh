#!/usr/bin/env bash

set -e

WORKING_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=========================================="
echo "  1. Checking System Environment...       "
echo "=========================================="
sudo mkdir -p /usr/share/texol

if [ -f "$WORKING_DIR/config/GatewayIP.txt" ]; then
    sudo cp -rf "$WORKING_DIR/config/GatewayIP.txt" /usr/share/texol/
    echo "[INFO] Synced /usr/share/texol/GatewayIP.txt"
fi

echo ""
echo "=========================================="
echo "  2. Pulling Updated Docker Images...     "
echo "=========================================="
docker compose pull

echo ""
echo "=========================================="
echo "  3. Rebuilding & Restarting Services...  "
echo "=========================================="
docker compose up -d --remove-orphans

echo ""
echo "=========================================="
echo "  Update Complete!                        "
echo "=========================================="