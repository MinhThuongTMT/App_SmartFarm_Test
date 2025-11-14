# 🚀 Quick Start Guide - Smart Farm Mobile

## ⚡ Chạy Nhanh (5 phút)

### 1. Clone & Install
```bash
cd smart_farm_mobile
flutter pub get
```

### 2. Cấu Hình URL
Mở `lib/screens/home_screen.dart`, line 27:
```dart
final String _serverUrl = 'ws://localhost:3000';  // Đổi URL này
```

### 3. Start Server
```bash
cd ../Server
node server.js
```

### 4. Run App
```bash
cd ../smart_farm_mobile
flutter run -d chrome
```

## 📊 Kết Quả

App sẽ hiển thị:
- ✅ 4 sensor cards (Nhiệt độ, Độ ẩm, Độ ẩm đất, Ánh sáng)
- ✅ 3 biểu đồ real-time
- ✅ 4 device controls (Fan, Pump, Light, Mist)
- ✅ 3 control modes (Manual, Auto, Schedule)
- ✅ Online/Offline status

## 🔧 URLs Khác Nhau

### Emulator (cùng máy)
```dart
'ws://localhost:3000'
```

### Thiết bị thật (WiFi)
```dart
'ws://192.168.1.100:3000'  // Thay IP của bạn
```

### Internet (Ngrok)
```dart
'wss://abc-xyz.ngrok-free.app'  // Thay ngrok URL
```

## 📱 Build APK

```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

## 📚 Chi Tiết

Xem [SETUP_GUIDE.md](SETUP_GUIDE.md) để biết chi tiết đầy đủ về:
- Cài đặt Flutter SDK
- Hiểu code architecture
- Troubleshooting
- Advanced features

## ⚠️ Lưu Ý

1. **Server phải chạy trước** khi start app
2. **ESP32 phải kết nối** để có dữ liệu
3. **Đổi URL** nếu test trên thiết bị thật
4. **Manual mode** để điều khiển thiết bị

## 🆘 Gặp Lỗi?

### Không kết nối được
```bash
# Check server
cd Server
node server.js

# Check URL đúng chưa
cat lib/screens/home_screen.dart | grep serverUrl
```

### Không hiển thị dữ liệu
```bash
# Check ESP32 Serial Monitor
# Phải thấy: "Sensor data sent"

# Check Flutter console
# Phải thấy: "📨 Received: sensor_update"
```

### Build failed
```bash
flutter clean
flutter pub get
flutter run
```

---

**Xem chi tiết:** [SETUP_GUIDE.md](SETUP_GUIDE.md) | [HuongdansetupFlutter.md](HuongdansetupFlutter.md)
