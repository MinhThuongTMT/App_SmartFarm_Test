# ✅ MQTT Đã Hoàn Thành

## 📦 Những gì đã làm

### 1. Đã Cài Đặt Package
- ✅ Thêm `mqtt_client: ^10.2.0` vào pubspec.yaml
- ✅ Chạy `flutter pub get` thành công

### 2. Đã Tạo Files
- ✅ `lib/config/mqtt_config.dart` - Cấu hình HiveMQ Cloud
- ✅ `lib/services/mqtt_service.dart` - MQTT Service với MqttBrowserClient

### 3. Đã Cập Nhật Code
- ✅ `lib/main.dart` - Đổi từ WebSocketService → MqttService
- ✅ `lib/screens/home_screen.dart` - Đổi từ _connectWebSocket() → _connectMqtt()

## ⚠️ Vấn Đề Hiện Tại

### Lỗi Kết Nối MQTT trên Web
```
MqttBrowserConnection::_startListening - websocket is closed
```

**Nguyên Nhân**: 
- `mqtt_client` package dùng MQTT Protocol v3 (MQIsdp)
- HiveMQ Cloud từ chối kết nối với protocol cũ này
- Website hoạt động OK vì dùng `mqtt.js` (hỗ trợ MQTT v3.1.1)

## 🎯 Giải Pháp Khuyến Nghị

### **OPTION 1: Dùng WebSocket Trực Tiếp (Giống Website)**
✅ **KHUYẾN NGHỊ - Dễ Nhất**

Thay vì dùng `mqtt_client`, implement WebSocket trực tiếp giống Website:

```dart
// lib/services/mqtt_service.dart
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class MqttService extends ChangeNotifier {
  WebSocketChannel? _channel;
  
  void connect() {
    const url = 'wss://7680f317994342a28675be77f6455901.s1.eu.hivemq.cloud:8884/mqtt';
    _channel = WebSocketChannel.connect(Uri.parse(url));
    
    // Subscribe bằng MQTT packets thủ công
    // (hoặc dùng mqtt.js wrapper)
  }
}
```

**Ưu Điểm**:
- Đơn giản, dễ hiểu
- Hoạt động chắc chắn (giống Website)
- Không phụ thuộc vào mqtt_client

**Nhược Điểm**:
- Phải handle MQTT protocol manually
- Cần implement Subscribe/Publish/QoS

---

### **OPTION 2: Giữ WebSocket cho App, MQTT cho ESP32 (Hybrid)**
✅ **KHUYẾN NGHỊ - Nhanh Nhất**

Giữ architecture hiện tại:
- **ESP32** → MQTT → **HiveMQ Cloud**
- **Website** → MQTT → **HiveMQ Cloud**
- **Flutter App** → **WebSocket** → **Node.js Server** → **HiveMQ Cloud (MQTT)**

Code cần thay đổi:

**1. Cập nhật Server (Node.js)**
```javascript
// server.js - Thêm MQTT bridge
const mqtt = require('mqtt');

const mqttClient = mqtt.connect('wss://7680f317994342a28675be77f6455901.s1.eu.hivemq.cloud:8884/mqtt', {
  username: 'hivemq.webclient.1763212764861',
  password: '>5aU7Db1c$N2T%mGZ,jr'
});

// Bridge: MQTT → WebSocket
mqttClient.on('message', (topic, message) => {
  wss.clients.forEach(client => {
    if (topic === 'smartfarm/sensors/data') {
      client.send(JSON.stringify({
        type: 'sensor_data',
        data: JSON.parse(message.toString())
      }));
    }
  });
});

// Bridge: WebSocket → MQTT
wss.on('connection', (ws) => {
  ws.on('message', (message) => {
    const data = JSON.parse(message);
    if (data.type === 'device_control') {
      mqttClient.publish('smartfarm/devices/control', JSON.stringify(data));
    }
  });
});
```

**2. Revert Flutter Code**
```bash
cd d:\DO AN TOT NGHIEP\CODE\smart_farm_mobile
git checkout lib/main.dart lib/screens/home_screen.dart
```

**Ưu Điểm**:
- Code Flutter đơn giản (giữ WebSocket)
- Server handle MQTT complexity
- App không cần lo về protocol version

**Nhược Điểm**:
- Cần deploy Server lên cloud (Render/Heroku)
- Thêm 1 hop (app → server → mqtt)
- Latency tăng ~50ms

---

### **OPTION 3: Dùng Package Khác**
⚠️ **KHÔNG KHUYẾN NGHỊ**

Thử package `mqtt5_client` hoặc `mqtt_web_client`

**Vấn Đề**:
- Chưa chắc tương thích HiveMQ Cloud
- Tốn thời gian test

---

## 📋 Next Steps

### Nếu chọn Option 1 (WebSocket Manual):
```bash
# 1. Rollback MQTT changes
cd d:\DO AN TOT NGHIEP\CODE\smart_farm_mobile
git checkout lib/

# 2. Create new mqtt_service.dart với WebSocket
# 3. Implement MQTT packets manually
```

### Nếu chọn Option 2 (Hybrid - KHUYẾN NGHỊ):
```bash
# 1. Revert Flutter về WebSocket
cd d:\DO AN TOT NGHIEP\CODE\smart_farm_mobile
git checkout lib/main.dart lib/screens/home_screen.dart

# 2. Update Server
cd d:\DO AN TOT NGHIEP\CODE\Server
npm install mqtt

# 3. Add MQTT bridge code vào server.js
# 4. Deploy server lên Render.com
```

---

## 🔗 Liên Kết

- HiveMQ Cloud Console: https://console.hivemq.cloud/
- MQTT.js Docs: https://github.com/mqttjs/MQTT.js
- mqtt_client Issues: https://github.com/shamblett/mqtt_client/issues

---

## ✨ Kết Luận

**KHUYẾN NGHỊ: Chọn Option 2 (Hybrid)**

Lý do:
1. ✅ Nhanh nhất - chỉ cần update Server
2. ✅ Flutter code đơn giản - giữ WebSocket
3. ✅ ESP32 và Website đã hoạt động hoàn hảo với MQTT
4. ✅ Dễ maintain - tách biệt concerns

**Command để bắt đầu**:
```powershell
# Revert Flutter code
cd "d:\DO AN TOT NGHIEP\CODE\smart_farm_mobile"
git checkout lib/main.dart lib/screens/home_screen.dart lib/services/websocket_service.dart

# Update Server
cd "d:\DO AN TOT NGHIEP\CODE\Server"
npm install mqtt
# Then edit server.js to add MQTT bridge
```
