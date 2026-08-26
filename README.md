# Aurora BLE Driver Standalone Deployment (`aurora-ble-driver_deploy`)

這是專為 **TEXOL BLE 感測器驅動程式 (`texol-ble-driver`)** 設計的獨立輕量化部署專案。
透過 Docker Compose，快速整合 Eclipse Mosquitto (MQTT Broker) 與 BLE 驅動程式，實現藍牙感測器數據的解碼與 MQTT 轉譯發布。

---

## 📁 專案檔案結構 (Directory Structure)

```text
aurora-ble-driver_deploy/
├── config/
│   └── GatewayIP.txt       # 網關 IP 設定檔 (驅動程式啟動依賴)
├── docker-compose.yml       # Docker 服務編排設定
├── install-docker.sh        # Docker & Docker Compose 環境安裝腳本
├── deploy-ble.sh            # 一鍵自動化部署與路徑配置腳本
└── README.md                # 專案說明文件
```

## ⚙️ 服務說明 (Architecture Summary)
1. texol-broker (eclipse-mosquitto:2.0.15)
    - MQTT Broker 服務。      
    - 提供內部 **1883** 埠供 **texol-ble-driver** 連線，並映射 **1883-1886** 埠至宿主機。

2. texol-ble-driver (texolaurora/texol-ble-driver:0.5)

    - 藍牙感測器驅動程式本體。

    - 解析 BLE 原始封包，轉換為單軸 (211HM1-B1) 或三軸 (213MM1-B1) 振幅、轉速、時域/頻域特徵與故障預測指標。

    - 依賴要求：啟動時會讀取 `/usr/share/texol/GatewayIP.txt`。

## 🚀 快速開始 (Quick Start)
1. copy GitHub 專案 (Clone Repository)

2. 設定 Gateway IP (Optional)
預設 Gateway IP 為 **192.168.10.1**。若需要修改，請編輯 `config/GatewayIP.txt`

3. 安裝 Docker 環境 (若伺服器尚未安裝 Docker)
    ```Bash
    cd aurora-ble-driver_deploy
    chmod +x install-docker.sh
    ./install-docker.sh
    ```

> [!IMPORTANT]
> 在進行下一步之前，請於 Docker 安裝後**重新啟動電腦**。

4. 一鍵啟動部署 (Run Deployment Script)
賦予腳本執行權限並啟動：

    ```Bash
    chmod +x deploy-ble.sh
    ./deploy-ble.sh
    ```

## 🛠️ 常用管理指令 (Operation Commands)
  - 查看容器狀態：
  
  ```Bash
  docker compose ps
  ```
  
  - 查看 BLE Driver 運作日誌：
  
  ```Bash
  docker logs -f texol-ble-driver
  ```
  
  - 停止服務：
  
  ```Bash
  docker compose down
  ```
  
  - 重啟 BLE Driver 服務：
  
  ```Bash
  docker compose restart texol-ble-driver
  ```

## 📡 MQTT Topic 說明
- 感測器數據發布：**/TEXOL/{ModuleName}/{SensorID}**

- 感測器心跳訊號：**/TEXOL/{ModuleName}/{SensorID}/HEARTBEAT**

- 所有俺測器 : **/TEXOL/#**


## 🔄 更新流程 (Update Process)

當需要更新 `texol-ble-driver` 或 `texol-broker` 的版本時，請依以下步驟操作：

1. **修改版本號碼**：
   編輯 `docker-compose.yml`，將 `image` 欄位修改為新的版本 Tag：

2. 執行更新腳本：

```Bash
# 賦予該檔案執行權限
chmod +x update.sh
# 執行
./update.sh
```   

提示：update.sh 會自動拉取新版 Image、重新構建容器，並同步載入新的 IP 設定，不會影響已掛載的數據與設定檔。

## 🔧 Changing Gateway IP Address (修改 Gateway IP)

If you need to update the Gateway IP address used by the BLE Driver, follow these steps:

1. **Edit the configuration file**:
   Update the IP address in `config/GatewayIP.txt`:
   
2. Apply the changes:
Run the update script to sync the new IP file to `/usr/share/texol/GatewayIP.txt and restart the service`:  
```Bash
./update.sh
```

3. Verify the change:
Check the driver log to confirm that the new Gateway IP has been loaded:  
```Bash
docker logs texol-ble-driver | grep "Gateway IP"
```

## 📡 Monitoring MQTT Topics (透過 Docker 監聽 MQTT 訊息)

You can monitor incoming raw BLE data and decoded sensor payload directly inside the `texol-broker` container without installing extra tools.

### 1. Monitor Decoded Sensor Data & Heartbeat
To view processed sensor feature values (RPM, OA, FFT features, etc.) and heartbeat signals published by the BLE Driver:

```bash
docker exec -it texol-broker mosquitto_sub -t "/TEXOL/#" -v
```

### 2. Monitor Raw Sensor DataTo check incoming raw data sent from BLE gateways or sensors:  
```Bash
docker exec -it texol-broker mosquitto_sub -t "/SENSOR/#" -v
```

### 3. Monitor All TrafficTo inspect every message passing through the MQTT broker:
```Bash
docker exec -it texol-broker mosquitto_sub -t "#" -v
```

Note:
- The -v (verbose) flag prints both the Topic name and the Payload content.
- Press Ctrl + C to exit the monitoring window.
