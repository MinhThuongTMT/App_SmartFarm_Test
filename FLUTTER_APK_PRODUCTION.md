# 📱 Flutter App APK - Hướng Dẫn Deploy Production

## ❌ VẤN ĐỀ HIỆN TẠI

App đang dùng `ws://localhost:3000` - **KHÔNG hoạt động trên APK thật**!

```dart
// ❌ Chỉ hoạt động trên emulator/web
static const String _serverUrl = 'ws://localhost:3000';
```

## ✅ GIẢI PHÁP - 3 Lựa Chọn

### **OPTION 1: Dùng IP Máy Tính (Test tạm thời)**

**Ưu điểm:**
- Đơn giản, nhanh chóng
- Không cần thay đổi nhiều code

**Nhược điểm:**
- Chỉ hoạt động trong cùng mạng WiFi
- IP có thể thay đổi
- Phải bật server trên máy tính

**Cách làm:**

1. Tìm IP máy tính:
```powershell
ipconfig
# Tìm IPv4 Address, ví dụ: 192.168.1.100
```

2. Update code:
```dart
// lib/services/mqtt_service.dart
static const String _serverUrl = 'ws://192.168.1.100:3000';
```

3. Chạy server:
```bash
cd Server
node server.js
```

4. Build APK và test

---

### **OPTION 2: Dùng Ngrok (Test từ xa)**

**Ưu điểm:**
- Test được từ bất kỳ đâu có internet
- Không cần cùng mạng WiFi
- URL public

**Nhược điểm:**
- URL thay đổi mỗi lần restart
- Free tier có giới hạn
- Phải keep server chạy

**Cách làm:**

1. Chạy server:
```bash
cd Server
node server.js
```

2. Chạy ngrok:
```bash
ngrok http 3000
# Lấy URL: https://abc-xyz.ngrok-free.app
```

3. Update code:
```dart
// lib/services/mqtt_service.dart
static const String _serverUrl = 'wss://abc-xyz.ngrok-free.app';
// ⚠️ Lưu ý: wss (secure) thay vì ws
```

4. Build APK và test

---

### **OPTION 3: Kết nối trực tiếp HiveMQ Cloud MQTT (KHUYẾN NGHỊ) ⭐**

**Ưu điểm:**
- ✅ Không cần server Node.js
- ✅ Hoạt động mọi nơi có internet
- ✅ Stable, production-ready
- ✅ Giống architecture của Website
- ✅ Không phụ thuộc máy tính cá nhân

**Nhược điểm:**
- Cần thêm package mqtt_client
- Phải refactor code

**Cách làm:**

#### Bước 1: Thêm package

```yaml
# pubspec.yaml
dependencies:
  mqtt_client: ^10.2.0
```

```bash
flutter pub get
```

#### Bước 2: Sử dụng HiveMQService

File `lib/services/hivemq_service.dart` đã được tạo sẵn!

#### Bước 3: Cập nhật main.dart

```dart
// lib/main.dart
import 'services/hivemq_service.dart'; // Thay vì mqtt_service.dart

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HiveMQService()), // ✅ Thay đổi
      ],
      child: MaterialApp(
        title: 'Smart Farm',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
```

#### Bước 4: Cập nhật home_screen.dart

```dart
// lib/screens/home_screen.dart
import '../services/hivemq_service.dart'; // Thay vì mqtt_service.dart

class _HomeScreenState extends State<HomeScreen> {
  // ...

  Future<void> _connectToMqtt() async {
    setState(() => _isConnecting = true);
    
    final hivemqService = context.read<HiveMQService>(); // ✅ Thay đổi
    
    // Setup callbacks
    hivemqService.onSensorData = (data) {
      setState(() {
        _latestSensorData = SensorData.fromJson(data);
      });
    };
    
    hivemqService.onDeviceState = (data) {
      setState(() {
        _latestDeviceState = DeviceState.fromJson(data);
      });
    };
    
    // ... rest of callbacks
    
    await hivemqService.connect();
    
    setState(() => _isConnecting = false);
  }
  
  // ...
}
```

#### Bước 5: Build APK

```bash
flutter build apk --release
```

APK sẽ ở: `build/app/outputs/flutter-apk/app-release.apk`

---

## 🏗️ KIẾN TRÚC SAU KHI DÙNG OPTION 3

```
┌─────────────────────────────────────────────────────┐
│                                                     │
│                   HiveMQ Cloud                      │
│           (7680f317994342a28675be77f6455901)       │
│                                                     │
└─────────────────────────────────────────────────────┘
         ▲                    ▲                    ▲
         │                    │                    │
    MQTT TLS:8883        MQTT TLS:8883        WSS:8884
         │                    │                    │
    ┌────┴────┐          ┌────┴────┐          ┌────┴────┐
    │  ESP32  │          │ Flutter │          │ Website │
    │         │          │   APK   │          │ Vercel  │
    └─────────┘          └─────────┘          └─────────┘
```

**Tất cả đều kết nối trực tiếp HiveMQ Cloud - Không cần server trung gian!**

---

## 🧪 TEST APK

### Test trên điện thoại thật:

1. **Enable USB Debugging** trên điện thoại
2. Kết nối USB
3. Run:
```bash
flutter run --release
```

### Hoặc cài APK file:

1. Copy file APK sang điện thoại
2. Cài đặt (cho phép Unknown Sources)
3. Mở app và test

### Checklist:

- [ ] App mở được
- [ ] Kết nối MQTT thành công (check status indicator)
- [ ] Nhận được dữ liệu cảm biến từ ESP32
- [ ] Điều khiển thiết bị hoạt động
- [ ] Chuyển đổi mode hoạt động
- [ ] App hoạt động cả khi không cùng WiFi với ESP32

---

## 📊 SO SÁNH CÁC OPTION

| Tiêu chí | Option 1: Local IP | Option 2: Ngrok | Option 3: MQTT Direct |
|----------|-------------------|-----------------|----------------------|
| **Độ khó** | ⭐ Dễ | ⭐⭐ Trung bình | ⭐⭐⭐ Khó hơn |
| **Stability** | ❌ Không stable | ⚠️ Tạm thời | ✅ Production ready |
| **Cần server** | ✅ Cần | ✅ Cần | ❌ Không cần |
| **Internet** | ❌ Cùng WiFi | ✅ Mọi nơi | ✅ Mọi nơi |
| **Latency** | ⚡ Rất thấp (10ms) | ⚠️ Cao (200ms) | ✅ Thấp (50ms) |
| **Cost** | 🆓 Free | 🆓 Free (limited) | 🆓 Free |
| **Khuyến nghị** | Test local | Test remote | **Production** ⭐ |

---

## 🎯 KHUYẾN NGHỊ

### Cho Development (Test):
- Dùng **Option 1** (IP máy tính) - Đơn giản, nhanh

### Cho Production (Deploy thật):
- Dùng **Option 3** (MQTT Direct) - Stable, không cần maintain server

### Lý do chọn Option 3:
1. ✅ Cùng kiến trúc với Website (đã hoạt động tốt)
2. ✅ Không phụ thuộc server Node.js
3. ✅ ESP32, Website, App đều kết nối chung HiveMQ
4. ✅ Synchronization tốt hơn
5. ✅ Scalable và maintainable

---

## 🔐 BẢO MẬT

**⚠️ LƯU Ý:** Credentials HiveMQ đang hard-coded trong code!

**Khuyến nghị:**
1. Sử dụng Environment Variables
2. Hoặc tạo config file riêng (không commit lên Git)
3. Hoặc dùng Firebase Remote Config

**Ví dụ với .env file:**

```dart
// .env
MQTT_BROKER=7680f317994342a28675be77f6455901.s1.eu.hivemq.cloud
MQTT_USERNAME=hivemq.webclient.1763212764861
MQTT_PASSWORD=>5aU7Db1c$N2T%mGZ,jr
```

Dùng package `flutter_dotenv` để load.

---

## 📱 BUILD APK

### Debug APK (Test):
```bash
flutter build apk --debug
```

### Release APK (Production):
```bash
flutter build apk --release
```

### Split APK by ABI (Nhẹ hơn):
```bash
flutter build apk --split-per-abi
```
Sẽ tạo 3 file:
- `app-armeabi-v7a-release.apk` (ARM 32-bit)
- `app-arm64-v8a-release.apk` (ARM 64-bit) ← Chọn cái này
- `app-x86_64-release.apk` (Intel)

---

## 🚀 PUBLISH LÊN GOOGLE PLAY (Optional)

1. Tạo keystore
2. Config signing trong `android/app/build.gradle`
3. Build App Bundle:
```bash
flutter build appbundle --release
```
4. Upload lên Google Play Console

---

## 💡 TÓM TẮT

### Câu trả lời cho câu hỏi:
> "App flutter xuất ra APK có thể điều khiển và giám sát được không?"

**✅ CÓ - Nhưng cần thay đổi:**

1. **Nếu giữ nguyên code hiện tại:** ❌ KHÔNG hoạt động (localhost:3000)

2. **Nếu dùng Option 1 (IP):** ⚠️ Có - Nhưng chỉ test trong cùng WiFi

3. **Nếu dùng Option 2 (Ngrok):** ⚠️ Có - Nhưng URL thay đổi, cần server

4. **Nếu dùng Option 3 (MQTT Direct):** ✅ CÓ - Production ready! ⭐

**Khuyến nghị:** Dùng **Option 3** để có app production-ready hoạt động mọi nơi!

---

## 📞 SUPPORT

Nếu gặp vấn đề khi build APK:
1. Check Flutter version: `flutter --version`
2. Clean build: `flutter clean && flutter pub get`
3. Check Android SDK đã cài đầy đủ
4. Check logs khi run: `flutter run --verbose`

---

**Status:** 🎯 **Option 3 RECOMMENDED - Production Ready!**

**Last Updated:** November 15, 2025
