#!/usr/bin/env bash

set -e

WORKING_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=========================================="
echo "  1. 確認系統環境與 GatewayIP.txt...     "
echo "=========================================="
sudo mkdir -p /usr/share/texol

if [ -f "$WORKING_DIR/config/GatewayIP.txt" ]; then
    sudo cp -rf "$WORKING_DIR/config/GatewayIP.txt" /usr/share/texol/
    echo "[INFO] 已同步更新 /usr/share/texol/GatewayIP.txt"
fi

echo ""
echo "=========================================="
echo "  2. 拉取新版 Docker 映像檔...           "
echo "=========================================="
docker compose pull

echo ""
echo "=========================================="
echo "  3. 重建並重啟服務...                   "
echo "=========================================="
docker compose up -d --remove-orphans

echo ""
echo "=========================================="
echo "  更新完成！                             "
echo "=========================================="