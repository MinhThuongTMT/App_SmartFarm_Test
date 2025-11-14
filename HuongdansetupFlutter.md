# 📱 Hướng Dẫn Setup Flutter App - Smart Farm

## ✅ Đã Hoàn Thành

Flutter app đã được tạo sẵn với đầy đủ tính năng:

### 🎯 Tính Năng Đã Có
- ✅ Kết nối WebSocket real-time
- ✅ Hiển thị dữ liệu cảm biến (Nhiệt độ, Độ ẩm, Độ ẩm đất, Ánh sáng)
- ✅ Điều khiển thiết bị (Fan, Pump, Light, Mist)
- ✅ Vẽ biểu đồ thời gian thực (Line charts)
- ✅ Hiển thị trạng thái Online/Offline
- ✅ Chuyển đổi chế độ (Manual/Auto/Schedule)
- ✅ UI đẹp với Material Design 3

## 📁 Cấu Trúc Project

```
smart_farm_mobile/
├── lib/
│   ├── main.dart                           # Entry point ✅
│   ├── models/
│   │   ├── sensor_data.dart                # Model dữ liệu cảm biến ✅
│   │   └── device_state.dart               # Model trạng thái thiết bị ✅
│   ├── services/
│   │   └── websocket_service.dart          # WebSocket service ✅
│   └── screens/
│       └── home_screen.dart                # Màn hình chính ✅
├── pubspec.yaml                            # Dependencies ✅
└── README.md
```

## 🚀 Cách Chạy App

### Bước 1: Đảm bảo Server đang chạy

```powershell
# Terminal 1: Start Node.js server
cd "d:\DO AN TOT NGHIEP\CODE\Server"
node server.js

# Terminal 2: Start ngrok (để test trên thiết bị thật)
ngrok http 3000 --authtoken=YOUR_TOKEN
```

### Bước 2: Cấu hình URL

**Cách 1: Test trên Emulator (cùng máy với server)**

File: `lib/screens/home_screen.dart` (dòng 27)
```dart
final String _serverUrl = 'ws://localhost:3000';
```

**Cách 2: Test trên thiết bị thật (qua WiFi)**

```dart
// Thay YOUR_IP bằng IP máy tính (chạy ipconfig để xem)
final String _serverUrl = 'ws://YOUR_IP:3000';
```

**Cách 3: Test qua Internet (Ngrok)**

```dart
// Thay YOUR_NGROK_URL bằng URL từ ngrok
final String _serverUrl = 'wss://abc-xyz.ngrok-free.app';
```

### Bước 3: Chạy App

```powershell
# Di chuyển đến thư mục project
cd "d:\DO AN TOT NGHIEP\CODE\smart_farm_mobile"

# Kiểm tra devices
flutter devices

# Chạy app
flutter run

# Hoặc chạy trên device cụ thể
flutter run -d <device-id>

# Hoặc chạy trên Chrome (web)
flutter run -d chrome
```

## 📊 Tính Năng Chi Tiết

### 1. 📡 Hiển thị Trạng thái Kết nối

- **Icon Online/Offline** ở góc phải appbar
- Màu xanh = Online ✅
- Màu đỏ = Offline ❌

### 2. 📊 Hiển thị Dữ Liệu Cảm Biến

4 cards hiển thị real-time:
- 🌡️ **Nhiệt độ (°C)** - Có đánh giá: Lạnh/Tốt/Ấm/Nóng
- 💧 **Độ ẩm (%)** - Có đánh giá: Khô/Tốt/Ẩm
- 🌱 **Độ ẩm đất (%)** - Có đánh giá: Khô/Tốt/Ướt
- ☀️ **Ánh sáng (lux)** - Có đánh giá: Tối/Tốt/Sáng

### 3. 📈 Biểu Đồ Thời Gian Thực

3 biểu đồ line chart:
- **Nhiệt độ** - Màu cam
- **Độ ẩm** - Màu xanh dương
- **Độ ẩm đất** - Màu nâu

**Tính năng:**
- Hiển thị 20 điểm dữ liệu gần nhất
- Tự động scale theo min/max
- Gradient fill dưới line
- Smooth curved lines

### 4. 🎛️ Điều Khiển Thiết Bị

4 thiết bị điều khiển được:
- 🌀 **Quạt (Fan)**
- 💦 **Máy bơm (Pump)**
- 💡 **Đèn (Light)**
- 🌫️ **Phun sương (Mist)**

**Đặc điểm:**
- Switch on/off đẹp
- Hiển thị trạng thái "Đang BẬT" / "Đang TẮT"
- Chỉ bật được ở **Manual Mode**
- Có warning khi ở Auto/Schedule mode

### 5. 🔄 Chuyển Đổi Chế Độ

3 chế độ:
- **Manual** ✋ - Điều khiển thủ công
- **Auto** 🤖 - Tự động theo cảm biến
- **Schedule** ⏰ - Theo lịch trình

## 🎨 Giao Diện App

```
┌─────────────────────────────────────────┐
│ Smart Farm          🟢 Online           │
├─────────────────────────────────────────┤
│                                         │
│ ⚙️ Chế Độ Điều Khiển                   │
│ ┌─────────────────────────────────────┐ │
│ │ [Manual] [Auto] [Schedule]          │ │
│ │ ✋ Điều khiển thủ công các thiết bị  │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ 📊 Dữ Liệu Cảm Biến                    │
│ ┌──────────┐  ┌──────────┐             │
│ │    🌡️    │  │    💧    │             │
│ │ Nhiệt Độ │  │ Độ Ẩm    │             │
│ │  28.5°C  │  │  65.2%   │             │
│ │  [ Tốt ] │  │  [ Tốt ] │             │
│ └──────────┘  └──────────┘             │
│ ┌──────────┐  ┌──────────┐             │
│ │    🌱    │  │    ☀️    │             │
│ │Độ Ẩm Đất │  │Ánh Sáng  │             │
│ │   45%    │  │   1200   │             │
│ │  [ Tốt ] │  │  [ Tốt ] │             │
│ └──────────┘  └──────────┘             │
│                                         │
│ 📈 Biểu Đồ Thời Gian Thực               │
│ ┌─────────────────────────────────────┐ │
│ │ Nhiệt Độ (°C)                       │ │
│ │      /\    /\                       │ │
│ │     /  \  /  \                      │ │
│ │    /    \/    \                     │ │
│ └─────────────────────────────────────┘ │
│ ┌─────────────────────────────────────┐ │
│ │ Độ Ẩm (%)                           │ │
│ │    /\/\  /\/\                       │ │
│ │   /    \/    \                      │ │
│ └─────────────────────────────────────┘ │
│ ┌─────────────────────────────────────┐ │
│ │ Độ Ẩm Đất (%)                       │ │
│ │  /\      /\                         │ │
│ │ /  \____/  \___                     │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ 🎛️ Điều Khiển Thiết Bị                 │
│ ┌─────────────────────────────────────┐ │
│ │ [🌀]  Quạt          ●────○  [ON]    │ │
│ │       ● Đang BẬT                    │ │
│ └─────────────────────────────────────┘ │
│ ┌─────────────────────────────────────┐ │
│ │ [💦]  Máy Bơm       ○────○  [OFF]   │ │
│ │       ○ Đang TẮT                    │ │
│ └─────────────────────────────────────┘ │
│ ┌─────────────────────────────────────┐ │
│ │ [💡]  Đèn           ●────○  [ON]    │ │
│ │       ● Đang BẬT                    │ │
│ └─────────────────────────────────────┘ │
│ ┌─────────────────────────────────────┐ │
│ │ [🌫️]  Phun Sương    ○────○  [OFF]   │ │
│ │       ○ Đang TẮT                    │ │
│ └─────────────────────────────────────┘ │
│                                         │
└─────────────────────────────────────────┘
```

## 🔌 WebSocket Protocol (Giống Website)

### Flutter → Server

```json
// Điều khiển thiết bị
{
  "type": "device_control",
  "device": "fan",
  "state": true
}

// Thay đổi chế độ
{
  "type": "mode_change",
  "mode": "manual"
}
```

### Server → Flutter

```json
// Dữ liệu cảm biến
{
  "type": "sensor_data",
  "temperature": 28.5,
  "humidity": 65.2,
  "soilMoisture": 45,
  "lightLevel": 1200,
  "timestamp": 1700000000000
}

// Trạng thái thiết bị
{
  "type": "device_state",
  "fan": true,
  "pump": false,
  "light": true,
  "mist": false,
  "timestamp": 1700000000000
}
```

## 🧪 Test Checklist

### Test Kết Nối
- [ ] App hiển thị "Online" khi kết nối thành công
- [ ] App hiển thị "Offline" khi mất kết nối
- [ ] Nút "Kết nối lại" hoạt động

### Test Hiển Thị Dữ Liệu
- [ ] 4 cards cảm biến cập nhật real-time
- [ ] Status (Tốt/Khô/Ẩm...) hiển thị đúng
- [ ] Biểu đồ vẽ được và cập nhật liên tục
- [ ] Biểu đồ hiển thị đúng 20 điểm dữ liệu

### Test Điều Khiển
- [ ] Ở Manual mode, switches bật được
- [ ] Ở Auto/Schedule mode, switches bị disable
- [ ] Khi bật/tắt switch, ESP32 nhận được lệnh
- [ ] Trạng thái thiết bị cập nhật đúng

### Test Chế Độ
- [ ] Chuyển đổi giữa 3 modes hoạt động
- [ ] Warning hiển thị khi không ở Manual mode
- [ ] ESP32 nhận được thông báo thay đổi mode

## 🚨 Troubleshooting

### Lỗi: "Không kết nối được"

**Nguyên nhân:** URL sai hoặc server không chạy

**Giải pháp:**
```powershell
# 1. Check server đang chạy
cd Server
node server.js

# 2. Check IP máy (nếu test trên thiết bị thật)
ipconfig

# 3. Cập nhật URL trong home_screen.dart dòng 27
```

### Lỗi: "Không hiển thị dữ liệu"

**Nguyên nhân:** ESP32 chưa gửi data

**Giải pháp:**
- Kiểm tra Serial Monitor ESP32
- Verify ESP32 đã kết nối WebSocket
- Check sensors đang hoạt động

### Lỗi: "Không điều khiển được thiết bị"

**Nguyên nhân:** Không ở Manual mode

**Giải pháp:**
- Chuyển sang Manual mode
- Kiểm tra ESP32 Serial Monitor xem có nhận lệnh không

### Lỗi: Build failed

**Giải pháp:**
```powershell
# Clean và rebuild
flutter clean
flutter pub get
flutter run
```

## 📦 Dependencies Đã Cài

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  web_socket_channel: ^2.4.0      # WebSocket client
  provider: ^6.1.1                # State management
  fl_chart: ^0.65.0               # Charts
  intl: ^0.18.1                   # Date/Time formatting
  cupertino_icons: ^1.0.6         # Icons
```

## 🎯 Flow Hoạt Động

```
1. App khởi động
   └─> WebSocketService.connect()
       └─> Kết nối đến server
           └─> Đăng ký callbacks

2. Nhận dữ liệu cảm biến
   └─> onSensorData() được gọi
       └─> Parse JSON → SensorData model
           └─> setState() → UI update
               └─> Thêm vào history → Vẽ lại chart

3. Nhận trạng thái thiết bị
   └─> onDeviceState() được gọi
       └─> Parse JSON → DeviceState model
           └─> setState() → UI update

4. User bật/tắt thiết bị
   └─> Switch.onChanged
       └─> sendDeviceControl()
           └─> Gửi JSON qua WebSocket
               └─> Server → ESP32
                   └─> ESP32 điều khiển relay
                       └─> ESP32 gửi confirm → Server
                           └─> Server → App
                               └─> UI update

5. User đổi mode
   └─> SegmentedButton.onSelectionChanged
       └─> sendModeChange()
           └─> Gửi JSON qua WebSocket
               └─> Server → ESP32
                   └─> ESP32 thay đổi mode
                       └─> UI update switches state
```

## 🎨 Tùy Chỉnh

### Thay đổi màu theme

File: `lib/main.dart`
```dart
theme: ThemeData(
  primarySwatch: Colors.green,  // Đổi thành Colors.blue, Colors.orange...
  useMaterial3: true,
),
```

### Thay đổi số điểm dữ liệu trong chart

File: `lib/screens/home_screen.dart`
```dart
final int _maxHistoryLength = 20;  // Đổi thành 30, 50...
```

### Thay đổi khoảng nhiệt độ "Tốt"

File: `lib/screens/home_screen.dart`
```dart
String _getTemperatureStatus(double temp) {
  if (temp < 20) return 'Lạnh';
  if (temp < 28) return 'Tốt';    // Đổi thành 30, 25...
  if (temp < 35) return 'Ấm';
  return 'Nóng';
}
```

## 📱 Build APK (Android)

```powershell
# Build APK release
flutter build apk --release

# APK sẽ ở:
# build/app/outputs/flutter-apk/app-release.apk

# Cài lên thiết bị Android
adb install build/app/outputs/flutter-apk/app-release.apk
```

## 🍎 Build IPA (iOS)

```powershell
# Build iOS (cần Mac và Xcode)
flutter build ios --release

# Hoặc run trực tiếp
flutter run -d <ios-device-id>
```

## 🌐 Build Web

```powershell
# Build web
flutter build web

# Files sẽ ở: build/web/

# Test local
cd build/web
python -m http.server 8000
# Mở http://localhost:8000
```

## 📊 Performance Tips

### 1. Giảm tần suất cập nhật chart

Nếu app lag, giảm số lần vẽ lại chart:

```dart
// Chỉ cập nhật chart mỗi 2 giây
DateTime? _lastChartUpdate;

ws.onSensorData = (data) {
  setState(() {
    _sensorData = SensorData.fromJson(data);
    
    final now = DateTime.now();
    if (_lastChartUpdate == null || 
        now.difference(_lastChartUpdate!).inSeconds >= 2) {
      _sensorHistory.add(_sensorData!);
      _lastChartUpdate = now;
    }
  });
};
```

### 2. Limit WebSocket message size

Thêm filter trong server để chỉ gửi data cần thiết.

## 🎓 Học Thêm Flutter

- [Flutter Documentation](https://docs.flutter.dev/)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [Provider Package](https://pub.dev/packages/provider)
- [FL Chart Package](https://pub.dev/packages/fl_chart)

## 🎯 Kết Luận

### ✅ Đã Có
- Flutter app hoàn chỉnh với đầy đủ tính năng
- Kết nối WebSocket real-time
- Hiển thị dữ liệu cảm biến + biểu đồ
- Điều khiển thiết bị
- Hiển thị trạng thái online/offline
- UI đẹp, responsive

### 🚀 Cách Chạy Nhanh
```powershell
# 1. Start server
cd Server
node server.js

# 2. Chạy app (terminal khác)
cd smart_farm_mobile
flutter run
```

### 📝 Lưu Ý
- Nhớ đổi `_serverUrl` trong `home_screen.dart` line 27
- Test trên emulator dùng `ws://localhost:3000`
- Test trên thiết bị thật dùng `ws://YOUR_IP:3000`
- Test qua internet dùng ngrok URL

**Status:** 🎉 **Ready to Use!**

---

**Created:** November 15, 2025  
**Project:** Smart Farm Mobile App  
**Framework:** Flutter 3.x  
**Platform:** Android, iOS, Web
