# 📱 HƯỚNG DẪN SETUP FLUTTER APP - SMART FARM (CHI TIẾT)

## 📋 Mục Lục
1. [Yêu Cầu Hệ Thống](#yêu-cầu-hệ-thống)
2. [Cài Đặt Flutter SDK](#cài-đặt-flutter-sdk)
3. [Cài Đặt Project](#cài-đặt-project)
4. [Cấu Trúc Project](#cấu-trúc-project)
5. [Kết Nối WebSocket](#kết-nối-websocket)
6. [Hiển Thị Dữ Liệu](#hiển-thị-dữ-liệu)
7. [Điều Khiển Thiết Bị](#điều-khiển-thiết-bị)
8. [Chạy Và Test](#chạy-và-test)
9. [Build APK](#build-apk)
10. [Troubleshooting](#troubleshooting)

---

## 🎯 Yêu Cầu Hệ Thống

### Phần Mềm Cần Thiết
- ✅ **Flutter SDK 3.0+** ([Download](https://docs.flutter.dev/get-started/install))
- ✅ **Git** ([Download](https://git-scm.com/downloads))
- ✅ **VS Code** hoặc Android Studio
- ✅ **Chrome** (để test trên web)
- ⚠️ **Android Studio** (nếu muốn build APK)
- ⚠️ **Xcode** (nếu build iOS - chỉ Mac)

### Backend Đang Chạy
- ✅ Node.js Server (port 3000)
- ✅ ESP32 kết nối và gửi dữ liệu
- ✅ WebSocket đang hoạt động

---

## 📥 Cài Đặt Flutter SDK

### Windows

**Bước 1: Download Flutter**
```powershell
# Tải Flutter từ: https://docs.flutter.dev/get-started/install/windows
# Hoặc dùng Git:
cd C:\
git clone https://github.com/flutter/flutter.git -b stable
```

**Bước 2: Thêm Flutter vào PATH**
```powershell
# Mở Settings → System → Advanced system settings → Environment Variables
# Thêm vào Path: C:\flutter\bin
```

**Bước 3: Kiểm tra cài đặt**
```powershell
flutter doctor
```

### macOS/Linux

```bash
# Download
cd ~/development
git clone https://github.com/flutter/flutter.git -b stable

# Thêm vào PATH (thêm vào ~/.bashrc hoặc ~/.zshrc)
export PATH="$PATH:`pwd`/flutter/bin"

# Reload shell
source ~/.bashrc

# Kiểm tra
flutter doctor
```

---

## 📂 Cài Đặt Project

### Option 1: Clone từ GitHub (Khuyên dùng)

```powershell
# Clone project
git clone https://github.com/YOUR_USERNAME/Train_AI_DATN.git

# Di chuyển vào thư mục Flutter app
cd Train_AI_DATN/smart_farm_mobile

# Cài đặt dependencies
flutter pub get

# Chạy app
flutter run -d chrome
```

### Option 2: Setup từ đầu

**Bước 1: Tạo project mới**
```powershell
# Tạo Flutter project
flutter create smart_farm_mobile

# Di chuyển vào project
cd smart_farm_mobile
```

**Bước 2: Copy các file cần thiết**

Copy các file sau từ project demo:
- `lib/main.dart`
- `lib/models/sensor_data.dart`
- `lib/models/device_state.dart`
- `lib/services/websocket_service.dart`
- `lib/screens/home_screen.dart`
- `pubspec.yaml`

**Bước 3: Cài dependencies**
```powershell
flutter pub get
```

---

## 📁 Cấu Trúc Project

```
smart_farm_mobile/
├── android/                          # Android config
│   └── app/src/main/
│       └── AndroidManifest.xml       # Permissions
├── ios/                              # iOS config
├── lib/                              # Source code chính
│   ├── main.dart                     # Entry point
│   ├── models/                       # Data models
│   │   ├── sensor_data.dart          # Model cho dữ liệu cảm biến
│   │   └── device_state.dart         # Model cho trạng thái thiết bị
│   ├── services/                     # Services
│   │   └── websocket_service.dart    # WebSocket service
│   └── screens/                      # UI screens
│       └── home_screen.dart          # Màn hình chính
├── pubspec.yaml                      # Dependencies
├── README.md                         # Documentation
├── SETUP_GUIDE.md                    # File này
└── HuongdansetupFlutter.md           # Hướng dẫn tiếng Việt
```

---

## 🔌 Kết Nối WebSocket

### 1️⃣ Hiểu Về WebSocket Service

File: `lib/services/websocket_service.dart`

```dart
class WebSocketService extends ChangeNotifier {
  WebSocketChannel? _channel;
  bool _isConnected = false;
  
  // Callbacks để xử lý dữ liệu
  Function(Map<String, dynamic>)? onSensorData;
  Function(Map<String, dynamic>)? onDeviceState;
  Function(String)? onModeChange;
  Function(String)? onError;

  // Kết nối đến server
  void connect(String serverUrl) {
    _channel = WebSocketChannel.connect(Uri.parse(serverUrl));
    
    _channel!.stream.listen(
      _handleMessage,
      onError: (error) {
        _isConnected = false;
        onError?.call(error.toString());
      },
      onDone: () {
        _isConnected = false;
      },
    );

    _isConnected = true;
  }

  // Xử lý message từ server
  void _handleMessage(dynamic message) {
    final data = jsonDecode(message.toString());
    
    switch (data['type']) {
      case 'sensor_data':
      case 'sensor_update':
      case 'initial_data':
        onSensorData?.call(data);
        break;
      case 'device_state':
      case 'device_states':
        onDeviceState?.call(data);
        break;
    }
  }
}
```

### 2️⃣ Cấu Hình URL Server

**File cần sửa:** `lib/screens/home_screen.dart` (dòng 27)

#### Test trên Emulator (Cùng máy với server)
```dart
final String _serverUrl = 'ws://localhost:3000';
```

#### Test trên Thiết Bị Thật (Qua WiFi)
```dart
// Thay YOUR_IP bằng IP máy tính chạy server
final String _serverUrl = 'ws://192.168.1.100:3000';
```

**Cách lấy IP máy tính:**
```powershell
# Windows
ipconfig

# Tìm IPv4 Address trong phần WiFi/Ethernet
# Ví dụ: 192.168.1.100
```

#### Test Qua Internet (Ngrok)
```dart
// Thay YOUR_NGROK_URL bằng URL từ ngrok
final String _serverUrl = 'wss://abc-xyz.ngrok-free.app';
```

**Setup Ngrok:**
```powershell
# Cài ngrok: https://ngrok.com/download

# Start ngrok
cd Server
ngrok http 3000 --authtoken=YOUR_TOKEN

# Copy URL hiển thị:
# Forwarding: https://abc-xyz.ngrok-free.app -> http://localhost:3000
```

### 3️⃣ Khởi Tạo WebSocket Trong App

**File:** `lib/screens/home_screen.dart`

```dart
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _connectWebSocket();
  });
}

void _connectWebSocket() {
  final ws = context.read<WebSocketService>();
  
  // Đăng ký callback nhận dữ liệu cảm biến
  ws.onSensorData = (data) {
    setState(() {
      _sensorData = SensorData.fromJson(data);
      _sensorHistory.add(_sensorData!);
    });
  };

  // Đăng ký callback nhận trạng thái thiết bị
  ws.onDeviceState = (data) {
    setState(() {
      _deviceState = DeviceState.fromJson(data);
    });
  };

  // Kết nối
  ws.connect(_serverUrl);
}
```

---

## 📊 Hiển Thị Dữ Liệu

### 1️⃣ Data Models

#### SensorData Model
**File:** `lib/models/sensor_data.dart`

```dart
class SensorData {
  final double temperature;
  final double humidity;
  final double soilMoisture;
  final int lightLevel;
  final DateTime timestamp;

  // Parse từ JSON (xử lý nhiều format từ server)
  factory SensorData.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> sensorData;
    
    if (json.containsKey('data')) {
      if (json['data'].containsKey('sensors')) {
        // initial_data: {data: {sensors: {...}}}
        sensorData = json['data']['sensors'];
      } else {
        // sensor_update: {data: {...}}
        sensorData = json['data'];
      }
    } else {
      // Direct: {temperature: ..., humidity: ...}
      sensorData = json;
    }
    
    return SensorData(
      temperature: (sensorData['temperature'] ?? 0).toDouble(),
      humidity: (sensorData['humidity'] ?? 0).toDouble(),
      soilMoisture: (sensorData['soilMoisture'] ?? 0).toDouble(),
      lightLevel: (sensorData['lightLevel'] ?? 0).toInt(),
      timestamp: DateTime.now(),
    );
  }
}
```

#### DeviceState Model
**File:** `lib/models/device_state.dart`

```dart
class DeviceState {
  final bool fan;
  final bool pump;
  final bool light;
  final bool mist;

  factory DeviceState.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> deviceData;
    
    if (json.containsKey('data')) {
      if (json['data'].containsKey('devices')) {
        // initial_data: {data: {devices: {...}}}
        deviceData = json['data']['devices'];
      } else {
        deviceData = json['data'];
      }
    } else {
      // device_states: {fan: true, pump: false, ...}
      deviceData = json;
    }
    
    return DeviceState(
      fan: deviceData['fan'] ?? false,
      pump: deviceData['pump'] ?? false,
      light: deviceData['light'] ?? false,
      mist: deviceData['mist'] ?? false,
      timestamp: DateTime.now(),
    );
  }
}
```

### 2️⃣ Hiển Thị Sensor Cards

**File:** `lib/screens/home_screen.dart`

```dart
Widget _buildSensorCards() {
  if (_sensorData == null) {
    return CircularProgressIndicator(); // Loading
  }

  return Column(
    children: [
      Row(
        children: [
          // Card nhiệt độ
          Expanded(
            child: Card(
              color: Colors.orange.withOpacity(0.1),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text('🌡️', style: TextStyle(fontSize: 32)),
                    Text('Nhiệt Độ'),
                    Text(
                      '${_sensorData!.temperature.toStringAsFixed(1)}°C',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    Text(_getTemperatureStatus(_sensorData!.temperature)),
                  ],
                ),
              ),
            ),
          ),
          
          // Card độ ẩm
          Expanded(
            child: Card(
              color: Colors.blue.withOpacity(0.1),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text('💧', style: TextStyle(fontSize: 32)),
                    Text('Độ Ẩm'),
                    Text(
                      '${_sensorData!.humidity.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      // Tương tự cho soilMoisture và lightLevel...
    ],
  );
}

// Helper để đánh giá trạng thái
String _getTemperatureStatus(double temp) {
  if (temp < 20) return 'Lạnh';
  if (temp < 28) return 'Tốt';
  if (temp < 35) return 'Ấm';
  return 'Nóng';
}
```

### 3️⃣ Vẽ Biểu Đồ Real-time

**Dependencies cần thiết:**
```yaml
dependencies:
  fl_chart: ^0.65.0
```

**Code vẽ biểu đồ:**
```dart
Widget _buildLineChart(String title, Color color, List<double> data) {
  return Card(
    child: Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 16),
          SizedBox(
            height: 150,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (data.length - 1).toDouble(),
                minY: _getMinY(data),
                maxY: _getMaxY(data),
                lineBarsData: [
                  LineChartBarData(
                    spots: data
                        .asMap()
                        .entries
                        .map((e) => FlSpot(e.key.toDouble(), e.value))
                        .toList(),
                    isCurved: true,
                    color: color,
                    barWidth: 3,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: color.withOpacity(0.2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

// Lưu lịch sử để vẽ biểu đồ
final List<SensorData> _sensorHistory = [];
final int _maxHistoryLength = 20;

ws.onSensorData = (data) {
  setState(() {
    _sensorData = SensorData.fromJson(data);
    
    // Thêm vào lịch sử
    _sensorHistory.add(_sensorData!);
    if (_sensorHistory.length > _maxHistoryLength) {
      _sensorHistory.removeAt(0);
    }
  });
};
```

### 4️⃣ Hiển Thị Online/Offline Status

```dart
AppBar(
  title: Text('Smart Farm'),
  actions: [
    // Connection indicator
    Row(
      children: [
        Icon(
          ws.isConnected ? Icons.cloud_done : Icons.cloud_off,
          color: ws.isConnected ? Colors.white : Colors.red[200],
        ),
        SizedBox(width: 8),
        Text(
          ws.isConnected ? 'Online' : 'Offline',
          style: TextStyle(
            color: ws.isConnected ? Colors.white : Colors.red[200],
          ),
        ),
        SizedBox(width: 16),
      ],
    ),
  ],
)
```

---

## 🎛️ Điều Khiển Thiết Bị

### 1️⃣ Gửi Lệnh Điều Khiển

**File:** `lib/services/websocket_service.dart`

```dart
// Gửi lệnh điều khiển thiết bị
void sendDeviceControl(String device, bool state) {
  if (!_isConnected) return;

  final command = jsonEncode({
    'type': 'device_control',
    'device': device,  // 'fan', 'pump', 'light', 'mist'
    'state': state,    // true = ON, false = OFF
  });

  _channel?.sink.add(command);
  debugPrint('🎛️ Sent: $command');
}
```

### 2️⃣ UI Switch Điều Khiển

```dart
Widget _buildDeviceCard(
  String emoji,
  String name,
  String deviceId,
  bool isOn,
  bool isEnabled,
) {
  return Card(
    child: ListTile(
      leading: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: isOn ? Colors.green.withOpacity(0.2) : Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(child: Text(emoji, style: TextStyle(fontSize: 24))),
      ),
      title: Text(name),
      subtitle: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isOn ? Colors.green : Colors.grey,
            ),
          ),
          SizedBox(width: 6),
          Text(isOn ? 'Đang BẬT' : 'Đang TẮT'),
        ],
      ),
      trailing: Switch(
        value: isOn,
        onChanged: isEnabled
            ? (value) {
                // Gửi lệnh điều khiển
                context
                    .read<WebSocketService>()
                    .sendDeviceControl(deviceId, value);
              }
            : null,
      ),
    ),
  );
}

// Sử dụng
_buildDeviceCard('🌀', 'Quạt', 'fan', _deviceState!.fan, isManualMode)
_buildDeviceCard('💦', 'Máy Bơm', 'pump', _deviceState!.pump, isManualMode)
_buildDeviceCard('💡', 'Đèn', 'light', _deviceState!.light, isManualMode)
_buildDeviceCard('🌫️', 'Phun Sương', 'mist', _deviceState!.mist, isManualMode)
```

### 3️⃣ Chuyển Đổi Chế Độ

```dart
Widget _buildModeSelector() {
  return Card(
    child: Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Text('Chế Độ Điều Khiển'),
          SizedBox(height: 12),
          SegmentedButton<String>(
            segments: [
              ButtonSegment(
                value: 'manual',
                label: Text('Manual'),
                icon: Icon(Icons.touch_app),
              ),
              ButtonSegment(
                value: 'auto',
                label: Text('Auto'),
                icon: Icon(Icons.auto_mode),
              ),
              ButtonSegment(
                value: 'schedule',
                label: Text('Schedule'),
                icon: Icon(Icons.schedule),
              ),
            ],
            selected: {_currentMode},
            onSelectionChanged: (Set<String> selected) {
              final mode = selected.first;
              context.read<WebSocketService>().sendModeChange(mode);
            },
          ),
        ],
      ),
    ),
  );
}

// Service method
void sendModeChange(String mode) {
  final command = jsonEncode({
    'type': 'mode_change',
    'mode': mode,
  });
  _channel?.sink.add(command);
}
```

### 4️⃣ Flow Điều Khiển

```
User bật switch
    ↓
onChanged callback
    ↓
sendDeviceControl('fan', true)
    ↓
Gửi JSON qua WebSocket
{
  "type": "device_control",
  "device": "fan",
  "state": true
}
    ↓
Server nhận và forward → ESP32
    ↓
ESP32 điều khiển relay
    ↓
ESP32 gửi confirm → Server
    ↓
Server broadcast → All clients
{
  "type": "device_states",
  "fan": true,
  "pump": false,
  ...
}
    ↓
App nhận và update UI
    ↓
Switch hiển thị trạng thái mới
```

---

## 🚀 Chạy Và Test

### 1️⃣ Checklist Trước Khi Chạy

- [ ] Node.js server đang chạy (`node server.js`)
- [ ] ESP32 đã kết nối và gửi dữ liệu
- [ ] Đã cài `flutter pub get`
- [ ] Đã cấu hình `_serverUrl` đúng

### 2️⃣ Chạy Trên Chrome (Đơn giản nhất)

```powershell
# Terminal 1: Start server
cd Server
node server.js

# Terminal 2: Run Flutter app
cd smart_farm_mobile
flutter run -d chrome
```

**Kết quả mong đợi:**
```
✅ WebSocket Connected to ws://localhost:3000
📨 Received: initial_data
📨 Received: sensor_update
📨 Received: device_states
```

### 3️⃣ Chạy Trên Android Emulator

```powershell
# List emulators
flutter emulators

# Launch emulator
flutter emulators --launch <emulator_id>

# Run app
flutter run
```

### 4️⃣ Chạy Trên Thiết Bị Thật

**Setup:**
1. Bật USB Debugging trên điện thoại
2. Kết nối USB với máy tính
3. Đảm bảo điện thoại và máy tính cùng WiFi

```powershell
# Check devices
flutter devices

# Run
flutter run -d <device-id>
```

**Lưu ý:** Phải đổi URL sang IP máy tính:
```dart
final String _serverUrl = 'ws://192.168.1.100:3000';
```

### 5️⃣ Test Checklist

#### Test Kết Nối
- [ ] Icon "Online" hiển thị màu xanh
- [ ] Console log: "✅ WebSocket Connected"
- [ ] Server log: "New client connected"

#### Test Hiển Thị Dữ Liệu
- [ ] 4 sensor cards hiển thị giá trị
- [ ] Giá trị cập nhật real-time
- [ ] Status (Tốt/Khô/Ẩm) hiển thị đúng
- [ ] Biểu đồ vẽ được và cập nhật

#### Test Điều Khiển
- [ ] Ở Manual mode, switch bật được
- [ ] Khi bật switch, ESP32 nhận lệnh
- [ ] Device state cập nhật trên app
- [ ] Multiple clients sync với nhau

#### Test Chế Độ
- [ ] Chuyển đổi giữa 3 modes
- [ ] Ở Auto/Schedule, switches bị disable
- [ ] ESP32 nhận thông báo thay đổi mode

---

## 📦 Build APK

### 1️⃣ Cấu Hình Android

**File:** `android/app/src/main/AndroidManifest.xml`

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Thêm permissions -->
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
    
    <application
        android:label="Smart Farm"
        android:icon="@mipmap/ic_launcher">
        <!-- ... -->
    </application>
</manifest>
```

### 2️⃣ Build Debug APK

```powershell
# Build
flutter build apk --debug

# File output
# build/app/outputs/flutter-apk/app-debug.apk
```

### 3️⃣ Build Release APK

```powershell
# Build release
flutter build apk --release

# File output
# build/app/outputs/flutter-apk/app-release.apk

# Cài lên điện thoại
adb install build/app/outputs/flutter-apk/app-release.apk
```

### 4️⃣ Build App Bundle (Để upload Google Play)

```powershell
flutter build appbundle --release

# File output
# build/app/outputs/bundle/release/app-release.aab
```

---

## 🐛 Troubleshooting

### Lỗi: "WebSocket connection failed"

**Nguyên nhân:** Server không chạy hoặc URL sai

**Giải pháp:**
```powershell
# 1. Check server đang chạy
cd Server
node server.js

# 2. Check port 3000 đang listen
netstat -an | findstr 3000

# 3. Check URL trong code (home_screen.dart line 27)
final String _serverUrl = 'ws://localhost:3000';  # Đúng chưa?
```

### Lỗi: "Cannot connect from device"

**Nguyên nhân:** Thiết bị không cùng mạng hoặc firewall block

**Giải pháp:**
```powershell
# 1. Check IP máy tính
ipconfig

# 2. Update URL với IP thật
final String _serverUrl = 'ws://192.168.1.100:3000';

# 3. Tắt firewall tạm thời (Windows)
# Settings → Windows Security → Firewall → Allow app through firewall

# 4. Test ping từ điện thoại
# Mở terminal app trên điện thoại, ping IP máy tính
```

### Lỗi: "No sensor data"

**Nguyên nhân:** ESP32 chưa gửi data hoặc format sai

**Giải pháp:**
```powershell
# 1. Check ESP32 Serial Monitor
# Phải thấy: "Sensor data sent"

# 2. Check server log
# Phải thấy: "📊 Sensor data updated"

# 3. Check Flutter console
# Phải thấy: "📨 Received: sensor_update"

# 4. Debug JSON format
# Thêm log trong _handleMessage để xem raw data
debugPrint('Raw message: $message');
```

### Lỗi: "Chart interval = 0"

**Đã fix:** Tất cả giá trị cảm biến giống nhau

**Code đã xử lý:**
```dart
double _calculateInterval(List<double> data) {
  if (data.isEmpty) return 1.0;
  final range = max - min;
  if (range == 0) return 1.0;  // ✅ Fix
  return range / 4;
}
```

### Lỗi: "Cannot control device"

**Nguyên nhân:** Không ở Manual mode

**Giải pháp:**
- Chuyển sang Manual mode
- Check isManualMode = true
- Check switch enabled

### Lỗi: Build APK failed

```powershell
# Clean và rebuild
flutter clean
flutter pub get
flutter build apk --debug

# Nếu vẫn lỗi, check:
# - Java version (cần JDK 11+)
# - Android SDK installed
# - Gradle version compatible
```

---

## 📤 Push Lên GitHub

### 1️⃣ Tạo .gitignore

**File:** `.gitignore`

```gitignore
# Flutter
.dart_tool/
.flutter-plugins
.flutter-plugins-dependencies
.packages
.pub-cache/
.pub/
build/

# Android
android/.gradle/
android/local.properties
android/app/debug/
android/app/release/

# iOS
ios/Pods/
ios/.symlinks/
ios/Flutter/App.framework
ios/Flutter/Flutter.framework
ios/Flutter/Generated.xcconfig

# IDE
.idea/
*.iml
.vscode/

# Misc
*.log
*.swp
.DS_Store
```

### 2️⃣ Commit Code

```bash
# Init git (nếu chưa có)
git init

# Add files
git add .

# Commit
git commit -m "Add Flutter mobile app with WebSocket control"

# Add remote
git remote add origin https://github.com/YOUR_USERNAME/Train_AI_DATN.git

# Push
git push -u origin main
```

### 3️⃣ Update README.md

Thêm section về Flutter app vào README chính:

```markdown
## 📱 Smart Farm Mobile App

Flutter application để giám sát và điều khiển Smart Farm.

### Features
- Real-time sensor monitoring
- Device control (Fan, Pump, Light, Mist)
- Live charts
- Multiple control modes

### Setup
See [smart_farm_mobile/SETUP_GUIDE.md](smart_farm_mobile/SETUP_GUIDE.md)

### Quick Start
\`\`\`bash
cd smart_farm_mobile
flutter pub get
flutter run -d chrome
\`\`\`
```

---

## 📚 Tài Liệu Tham Khảo

### Flutter
- [Flutter Documentation](https://docs.flutter.dev/)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [Flutter Samples](https://flutter.github.io/samples/)

### Packages Used
- [web_socket_channel](https://pub.dev/packages/web_socket_channel) - WebSocket client
- [provider](https://pub.dev/packages/provider) - State management
- [fl_chart](https://pub.dev/packages/fl_chart) - Charts
- [intl](https://pub.dev/packages/intl) - Internationalization

### Architecture
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Flutter Architecture Samples](https://github.com/brianegan/flutter_architecture_samples)

---

## 🎯 Next Steps

### Tính Năng Nâng Cao Có Thể Thêm

1. **Authentication**
   - Login/Register
   - Firebase Auth
   - Token-based auth

2. **Data Persistence**
   - SQLite local storage
   - Cache sensor data
   - Offline mode

3. **Notifications**
   - Push notifications
   - Alert khi sensor vượt ngưỡng
   - Firebase Cloud Messaging

4. **History & Analytics**
   - Xem lịch sử 7 ngày / 30 ngày
   - Export data to CSV
   - More chart types

5. **Settings**
   - Cấu hình ngưỡng cảm biến
   - Đổi theme (dark mode)
   - Multiple languages

6. **Schedule**
   - Tạo lịch trình tự động
   - Timer cho thiết bị
   - Recurring schedules

---

## ✅ Checklist Hoàn Thành

### Setup
- [ ] Flutter SDK đã cài
- [ ] Project đã clone/create
- [ ] Dependencies đã cài (`flutter pub get`)
- [ ] Android permissions đã thêm

### Configuration
- [ ] Server URL đã cấu hình
- [ ] WebSocket đã test kết nối
- [ ] Message format đã verify

### Features
- [ ] Hiển thị 4 sensor cards
- [ ] Vẽ 3 biểu đồ real-time
- [ ] Điều khiển 4 thiết bị
- [ ] Chuyển đổi 3 modes
- [ ] Online/Offline indicator

### Testing
- [ ] Test trên Chrome
- [ ] Test trên Emulator (optional)
- [ ] Test trên thiết bị thật (optional)
- [ ] Test multiple clients sync

### Deployment
- [ ] Build debug APK
- [ ] Build release APK (optional)
- [ ] Push code lên GitHub
- [ ] Update README

---

## 🎉 Kết Luận

Bạn đã hoàn thành setup Flutter app để:

✅ Kết nối WebSocket real-time với server  
✅ Hiển thị dữ liệu cảm biến từ ESP32  
✅ Vẽ biểu đồ thời gian thực  
✅ Điều khiển thiết bị qua WebSocket  
✅ Chuyển đổi chế độ Manual/Auto/Schedule  
✅ Hiển thị trạng thái Online/Offline  

**App đã sẵn sàng deploy và sử dụng!** 🚀

---

**Created:** November 15, 2025  
**Author:** Smart Farm Team  
**Version:** 1.0.0  
**License:** MIT
