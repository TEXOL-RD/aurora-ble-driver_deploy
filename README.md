# Aurora BLE Driver Standalone Deployment (`aurora-ble-driver_deploy`)

這是專為 **TEXOL BLE 感測器驅動程式 (`texol-ble-driver`)** 設計的獨立輕量化部署專案。
透過 Docker Compose，快速整合 Eclipse Mosquitto (MQTT Broker) 與 BLE 驅動程式，實現藍牙感測器數據的解碼與 MQTT 轉譯發布。

---

## 📁 專案檔案結構 (Directory Structure)

```text
aurora-ble-driver_deploy/
├── config/
│   └── GatewayIP.txt       # 網關 IP 設定檔 (驅動程式啟動必要依賴)
├── docker-compose.yml       # Docker 服務編排設定
├── deploy-ble.sh            # 一鍵自動化部署與路徑配置腳本
└── README.md                # 專案說明文件

⚙️ 服務說明 (Architecture Summary)
texol-broker (eclipse-mosquitto:2.0.15)

MQTT Broker 服務。

提供內部 1883 埠供 texol-ble-driver 連線，並映射 1883-1886 埠至宿主機。

texol-ble-driver (texolaurora/texol-ble-driver:0.5)

藍牙感測器驅動程式本體。

解析 BLE 原始封包，轉換為單軸 (211HM1-B1) 或三軸 (213MM1-B1) 振幅、轉速、時域/頻域特徵與故障預測指標。

依賴要求：啟動時會讀取 /usr/share/texol/GatewayIP.txt。

🚀 快速開始 (Quick Start)
1. 克隆 GitHub 專案 (Clone Repository)
```Bash
git clone [https://github.com/](https://github.com/)<your-username>/aurora-ble-driver_deploy.git
cd aurora-ble-driver_deploy
```

2. 設定 Gateway IP (Optional)
預設 Gateway IP 為 192.168.10.1。若需要修改，請編輯 config/GatewayIP.txt：

```Bash
nano config/GatewayIP.txt
```

3. 一鍵啟動部署 (Run Deployment Script)
賦予腳本執行權限並啟動：

```Bash
chmod +x deploy-ble.sh
./deploy-ble.sh
```

🛠️ 常用管理指令 (Operation Commands)
查看容器狀態：

```Bash
docker compose ps
```

查看 BLE Driver 運作日誌：

```Bash
docker logs -f texol-ble-driver
```

停止服務：

```Bash
docker compose down
```

重啟 BLE Driver 服務：

```Bash
docker compose restart texol-ble-driver
```

📡 MQTT Topic 說明
感測器數據發布：/TEXOL/{ModuleName}/{SensorID}

感測器心跳訊號：/TEXOL/{ModuleName}/{SensorID}/HEARTBEAT