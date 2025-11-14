# smart_farm_mobile

# 📱 Smart Farm Mobile App

Flutter mobile application để giám sát và điều khiển hệ thống Smart Farm qua WebSocket real-time.

## ✨ Tính Năng

### 📊 Giám Sát Real-time
- ✅ Hiển thị dữ liệu 4 cảm biến: Nhiệt độ, Độ ẩm, Độ ẩm đất, Ánh sáng
- ✅ Vẽ biểu đồ thời gian thực cho từng thông số (20 điểm dữ liệu)
- ✅ Đánh giá trạng thái cảm biến thông minh (Tốt/Khô/Ẩm/Nóng...)
- ✅ Cập nhật tức thì khi có dữ liệu mới từ ESP32

### 🎛️ Điều Khiển Thiết Bị
- ✅ Điều khiển 4 thiết bị: 🌀 Quạt, 💦 Máy bơm, 💡 Đèn, 🌫️ Phun sương
- ✅ 3 chế độ hoạt động:
  - **Manual** ✋ - Điều khiển thủ công
  - **Auto** 🤖 - Tự động theo cảm biến
  - **Schedule** ⏰ - Theo lịch trình
- ✅ Xem trạng thái thiết bị real-time (BẬT/TẮT)
- ✅ Switch UI đẹp mắt với animation

### 🌐 Kết Nối
- ✅ WebSocket real-time với Node.js server
- ✅ Hiển thị trạng thái Online/Offline rõ ràng
- ✅ Auto-reconnect khi mất kết nối
- ✅ Hỗ trợ nhiều kết nối: localhost, LAN, Internet (Ngrok)
- ✅ Sync với Website và các client khác

## 🚀 Quick Start

### 📋 Yêu Cầu
- Flutter SDK 3.0+
- Node.js server đang chạy (port 3000)
- ESP32 kết nối và gửi dữ liệu

### ⚡ Chạy Nhanh (3 bước)

```bash
# 1. Cài dependencies
flutter pub get

# 2. Chạy app trên Chrome
flutter run -d chrome

# 3. Hoặc chạy trên Android
flutter run
```

### ⚙️ Cấu Hình Server URL

**File:** `lib/screens/home_screen.dart` (dòng 27)

```dart
// Test trên emulator (cùng máy)
final String _serverUrl = 'ws://localhost:3000';

// Test trên thiết bị qua WiFi
final String _serverUrl = 'ws://192.168.1.100:3000';  // Thay IP của bạn

// Test qua Internet (Ngrok)
final String _serverUrl = 'wss://your-url.ngrok-free.app';
```

## 📱 Screenshots

```
┌─────────────────────────────────────┐
│  Smart Farm          🟢 Online     │
├─────────────────────────────────────┤
│                                     │
│ ⚙️ Chế Độ Điều Khiển               │
│ ┌─────────────────────────────────┐ │
│ │ [Manual] [Auto] [Schedule]      │ │
│ │ ✋ Điều khiển thủ công           │ │
│ └─────────────────────────────────┘ │
│                                     │
│ 📊 Dữ Liệu Cảm Biến                │
│ ┌──────────┐  ┌──────────┐         │
│ │  🌡️      │  │   💧     │         │
│ │ Nhiệt Độ │  │ Độ Ẩm    │         │
│ │ 28.5°C   │  │  65.2%   │         │
│ │ [ Tốt ]  │  │ [ Tốt ]  │         │
│ └──────────┘  └──────────┘         │
│ ┌──────────┐  ┌──────────┐         │
│ │   🌱     │  │   ☀️     │         │
│ │Độ Ẩm Đất │  │Ánh Sáng  │         │
│ │   45%    │  │   1200   │         │
│ │ [ Tốt ]  │  │ [ Tốt ]  │         │
│ └──────────┘  └──────────┘         │
│                                     │
│ 📈 Biểu Đồ Thời Gian Thực          │
│ ┌─────────────────────────────────┐ │
│ │ Nhiệt Độ (°C)                   │ │
│ │      /\    /\                   │ │
│ │     /  \  /  \                  │ │
│ │    /    \/    \                 │ │
│ └─────────────────────────────────┘ │
│ ┌─────────────────────────────────┐ │
│ │ Độ Ẩm (%)                       │ │
│ │    /\/\  /\/\                   │ │
│ │   /    \/    \                  │ │
│ └─────────────────────────────────┘ │
│                                     │
│ 🎛️ Điều Khiển Thiết Bị            │
│ ┌─────────────────────────────────┐ │
│ │ [🌀] Quạt         ●───○  [ON]   │ │
│ │      ● Đang BẬT                 │ │
│ └─────────────────────────────────┘ │
│ ┌─────────────────────────────────┐ │
│ │ [💦] Máy Bơm      ○───○  [OFF]  │ │
│ │      ○ Đang TẮT                 │ │
│ └─────────────────────────────────┘ │
│ ┌─────────────────────────────────┐ │
│ │ [💡] Đèn          ●───○  [ON]   │ │
│ │      ● Đang BẬT                 │ │
│ └─────────────────────────────────┘ │
│ ┌─────────────────────────────────┐ │
│ │ [🌫️] Phun Sương   ○───○  [OFF]  │ │
│ │      ○ Đang TẮT                 │ │
│ └─────────────────────────────────┘ │
│                                     │
└─────────────────────────────────────┘
```

## 🔌 WebSocket API

### Gửi Lệnh Điều Khiển
```json
{
  "type": "device_control",
  "device": "fan",
  "state": true
}
```

### Nhận Dữ Liệu Cảm Biến
```json
{
  "type": "sensor_update",
  "data": {
    "temperature": 28.5,
    "humidity": 65.2,
    "soilMoisture": 45,
    "lightLevel": 1200,
    "timestamp": 1700000000000
  }
}
```

### Nhận Trạng Thái Thiết Bị
```json
{
  "type": "device_states",
  "fan": true,
  "pump": false,
  "light": true,
  "mist": false
}
```

## 📦 Dependencies

```yaml
dependencies:
  web_socket_channel: ^2.4.0   # WebSocket client
  provider: ^6.1.1              # State management
  fl_chart: ^0.65.0             # Biểu đồ đẹp
  intl: ^0.18.1                 # Date/Time formatting
```

## 🏗️ Cấu Trúc Project

```
lib/
├── main.dart                    # Entry point + Provider setup
├── models/
│   ├── sensor_data.dart         # Model cho dữ liệu cảm biến
│   └── device_state.dart        # Model cho trạng thái thiết bị
├── services/
│   └── websocket_service.dart   # WebSocket service với callbacks
└── screens/
    └── home_screen.dart         # Màn hình chính (Dashboard)
```

## 🛠️ Build

### Android APK
```bash
# Debug
flutter build apk --debug

# Release
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web
# Output: build/web/
```

## 🐛 Troubleshooting

### ❌ Không kết nối được?

**Kiểm tra:**
1. Server đang chạy: `node server.js`
2. URL đúng trong `home_screen.dart`
3. Firewall không block port 3000

```bash
# Check server
cd Server
node server.js

# Check port
netstat -an | findstr 3000
```

### ❌ Không hiển thị dữ liệu?

**Kiểm tra:**
1. ESP32 đã kết nối WebSocket
2. ESP32 đang gửi sensor data
3. Flutter console có log "📨 Received: sensor_update"

```bash
# Check ESP32 Serial Monitor
# Phải thấy: "✅ Sensor data sent"

# Check Flutter console
# Phải thấy: "📨 Received: sensor_update"
```

### ❌ Không điều khiển được thiết bị?

**Nguyên nhân:** Không ở Manual Mode

**Giải pháp:**
- Chuyển sang Manual Mode (nút đầu tiên)
- Switches sẽ bật được
- Check ESP32 Serial Monitor xem có nhận lệnh không

### ❌ Build APK failed?

```bash
# Clean và rebuild
flutter clean
flutter pub get
flutter build apk
```

## 📚 Documentation

- **[QUICKSTART.md](QUICKSTART.md)** - Hướng dẫn nhanh 5 phút
- **[SETUP_GUIDE.md](SETUP_GUIDE.md)** - Hướng dẫn chi tiết đầy đủ (setup từ đầu)
- **[HuongdansetupFlutter.md](HuongdansetupFlutter.md)** - Hướng dẫn tiếng Việt chi tiết
- [Flutter Docs](https://docs.flutter.dev/)

## 🎯 Features Roadmap

### ✅ Đã Có
- WebSocket real-time connection
- Sensor data display với cards
- Live charts (fl_chart)
- Device control switches
- Mode selection (Manual/Auto/Schedule)
- Online/Offline status
- Material Design 3 UI

### 🚧 Sắp Có (Optional)
- [ ] Authentication (Firebase Auth)
- [ ] Local data persistence (SQLite)
- [ ] Push notifications
- [ ] Historical data (7/30 days)
- [ ] Export to CSV
- [ ] Dark mode
- [ ] Multiple languages
- [ ] Schedule configuration

## 🧪 Testing

### Test Kết Nối
```bash
flutter run -d chrome
# Phải thấy: ✅ WebSocket Connected to ws://localhost:3000
```

### Test Hiển Thị
- [ ] 4 sensor cards hiển thị giá trị
- [ ] Biểu đồ vẽ được
- [ ] Online icon màu xanh

### Test Điều Khiển
- [ ] Switch Manual mode
- [ ] Bật/tắt thiết bị
- [ ] ESP32 nhận lệnh
- [ ] UI cập nhật trạng thái

## 🤝 Contributing

Project này là phần của đồ án tốt nghiệp Smart Farm.

## 👨‍💻 Authors

- **Smart Farm Team** - Đồ án tốt nghiệp 2025

## 📄 License

MIT License - Free to use

---

## 🎉 Kết Luận

Flutter app hoàn chỉnh với:
- ✅ Real-time WebSocket connection
- ✅ Beautiful Material Design 3 UI
- ✅ Live sensor monitoring & charts
- ✅ Device control via WebSocket
- ✅ Cross-platform (Android, iOS, Web)

**Ready to deploy!** 🚀

---

**Last Updated:** November 15, 2025  
**Version:** 1.0.0  
**Flutter:** 3.24.5

## ✨ Tính Năng

### 📊 Giám Sát
- ✅ Hiển thị dữ liệu cảm biến real-time (Nhiệt độ, Độ ẩm, Độ ẩm đất, Ánh sáng)
- ✅ Vẽ biểu đồ thời gian thực cho từng thông số
- ✅ Đánh giá trạng thái cảm biến (Tốt/Khô/Ẩm/Nóng...)
- ✅ Hiển thị trạng thái kết nối Online/Offline

### 🎛️ Điều Khiển
- ✅ Điều khiển 4 thiết bị: Quạt, Máy bơm, Đèn, Phun sương
- ✅ 3 chế độ: Manual (thủ công), Auto (tự động), Schedule (lịch trình)
- ✅ Bật/tắt thiết bị bằng switch đẹp mắt
- ✅ Xem trạng thái thiết bị real-time

### 🌐 Kết Nối
- ✅ WebSocket real-time
- ✅ Hỗ trợ localhost, LAN, và Internet (qua Ngrok)
- ✅ Auto-reconnect khi mất kết nối

## 🚀 Quick Start

### Prerequisites
- Flutter SDK (3.0+)
- Android Studio / Xcode
- Node.js server đang chạy (từ folder `Server`)

### Cài Đặt

```bash
# Clone project (nếu chưa có)
cd "d:\DO AN TOT NGHIEP\CODE\smart_farm_mobile"

# Cài dependencies
flutter pub get

# Chạy app
flutter run
```

### Cấu Hình Server URL

Mở file `lib/screens/home_screen.dart`, sửa dòng 27:

```dart
// Test trên emulator (cùng máy)
final String _serverUrl = 'ws://localhost:3000';

// Test trên thiết bị qua WiFi
final String _serverUrl = 'ws://192.168.1.100:3000';  // Thay IP của bạn

// Test qua Internet (Ngrok)
final String _serverUrl = 'wss://your-url.ngrok-free.app';
```

## 📱 Screenshots

```
┌─────────────────────────┐
│  Smart Farm  🟢 Online │
├─────────────────────────┤
│ [Manual][Auto][Schedule]│
│                         │
│ 🌡️ 28.5°C  💧 65.2%    │
│ 🌱 45%     ☀️ 1200     │
│                         │
│ 📈 Biểu đồ...          │
│                         │
│ 🎛️ Điều khiển         │
│ 🌀 Quạt        [ON]    │
│ 💦 Máy bơm     [OFF]   │
│ 💡 Đèn         [ON]    │
│ 🌫️ Phun sương  [OFF]   │
└─────────────────────────┘
```

## 🔌 WebSocket API

### Gửi lệnh điều khiển
```json
{
  "type": "device_control",
  "device": "fan",
  "state": true
}
```

### Nhận dữ liệu cảm biến
```json
{
  "type": "sensor_data",
  "temperature": 28.5,
  "humidity": 65.2,
  "soilMoisture": 45,
  "lightLevel": 1200,
  "timestamp": 1700000000000
}
```

Xem chi tiết trong `HuongdansetupFlutter.md`

## 📦 Dependencies

- `web_socket_channel` - WebSocket client
- `provider` - State management
- `fl_chart` - Biểu đồ
- `intl` - Date/Time formatting

## 🏗️ Cấu Trúc Project

```
lib/
├── main.dart                    # Entry point
├── models/
│   ├── sensor_data.dart         # Sensor data model
│   └── device_state.dart        # Device state model
├── services/
│   └── websocket_service.dart   # WebSocket service
└── screens/
    └── home_screen.dart         # Main screen
```

## 🛠️ Build

### Android APK
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web
# Output: build/web/
```

## 🐛 Troubleshooting

### Không kết nối được?
1. Check server đang chạy: `node server.js`
2. Check URL đúng trong `home_screen.dart`
3. Check firewall không block port 3000

### Không điều khiển được thiết bị?
1. Đảm bảo đang ở **Manual Mode**
2. Check ESP32 đã kết nối WebSocket
3. Xem Serial Monitor ESP32

Xem thêm trong `HuongdansetupFlutter.md`

## 📚 Documentation

- [HuongdansetupFlutter.md](HuongdansetupFlutter.md) - Hướng dẫn setup chi tiết
- [Flutter Docs](https://docs.flutter.dev/)

## 👨‍💻 Author

Created for Smart Farm project - 2025

## 📄 License

MIT License

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
