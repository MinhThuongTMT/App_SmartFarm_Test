# 🚀 HƯỚNG DẪN TÍCH HỢP MQTT VÀO FLUTTER APP

## 📋 MỤC LỤC
1. [Cài đặt thư viện](#1-cài-đặt-thư-viện)
2. [Cấu hình MQTT](#2-cấu-hình-mqtt)
3. [Tạo MQTT Service](#3-tạo-mqtt-service)
4. [Tích hợp vào App](#4-tích-hợp-vào-app)
5. [Test & Debug](#5-test--debug)

---

## 1. CÀI ĐẶT THƯ VIỆN

### Bước 1.1: Thêm package mqtt_client vào pubspec.yaml

Mở file `pubspec.yaml` và thêm package sau vào phần `dependencies`:

```yaml
dependencies:
  flutter:
    sdk: flutter

  # MQTT Client for HiveMQ Cloud
  mqtt_client: ^10.2.0
  
  # WebSocket (giữ lại cho backup)
  web_socket_channel: ^2.4.0
  
  # State Management
  provider: ^6.1.1
  
  # Charts
  fl_chart: ^0.65.0
  
  # Date/Time formatting
  intl: ^0.18.1

  cupertino_icons: ^1.0.8
```

### Bước 1.2: Cài đặt package

Chạy lệnh sau trong terminal:

```bash
flutter pub get
```

---

## 2. CẤU HÌNH MQTT

### Bước 2.1: Tạo file config/mqtt_config.dart

Tạo thư mục `lib/config/` (nếu chưa có) và tạo file `mqtt_config.dart`:

```dart
// lib/config/mqtt_config.dart

class MqttConfig {
  // HiveMQ Cloud Configuration
  static const String broker = '7680f317994342a28675be77f6455901.s1.eu.hivemq.cloud';
  static const int port = 8883; // TLS port
  static const String clientId = 'FlutterApp_'; // Will append random string
  static const String username = 'hivemq.webclient.1763212764861';
  static const String password = '>5aU7Db1c\$N2T%mGZ,jr';
  
  // MQTT Topics
  static const String topicSensorData = 'smartfarm/sensors/data';
  static const String topicDeviceState = 'smartfarm/devices/state';
  static const String topicDeviceControl = 'smartfarm/devices/control';
  static const String topicModeChange = 'smartfarm/mode/change';
  
  // Connection Settings
  static const int keepAlivePeriod = 60; // seconds
  static const bool autoReconnect = true;
  static const int reconnectDelay = 5; // seconds
}
```

**⚠️ LƯU Ý BẢO MẬT:**
- Trong production, KHÔNG lưu credentials trực tiếp trong code
- Sử dụng environment variables hoặc secure storage
- Có thể dùng package `flutter_dotenv` để load từ file `.env`

---

## 3. TẠO MQTT SERVICE

### Bước 3.1: Tạo file services/mqtt_service.dart

```dart
// lib/services/mqtt_service.dart

import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import '../config/mqtt_config.dart';

class MqttService extends ChangeNotifier {
  MqttServerClient? _client;
  bool _isConnected = false;
  
  // Callbacks
  Function(Map<String, dynamic>)? onSensorData;
  Function(Map<String, dynamic>)? onDeviceState;
  Function(String)? onModeChange;
  Function(String)? onError;
  Function()? onConnected;
  Function()? onDisconnected;
  
  // Getters
  bool get isConnected => _isConnected;
  
  /// Kết nối đến HiveMQ Cloud MQTT Broker
  Future<void> connect() async {
    try {
      // Tạo client ID duy nhất
      final String clientId = MqttConfig.clientId + 
          Random().nextInt(100000).toString();
      
      debugPrint('🔌 Connecting to MQTT broker...');
      debugPrint('📍 Broker: ${MqttConfig.broker}:${MqttConfig.port}');
      
      // Khởi tạo MQTT client
      _client = MqttServerClient.withPort(
        MqttConfig.broker,
        clientId,
        MqttConfig.port,
      );
      
      // Cấu hình client
      _client!.logging(on: kDebugMode);
      _client!.keepAlivePeriod = MqttConfig.keepAlivePeriod;
      _client!.autoReconnect = MqttConfig.autoReconnect;
      _client!.reconnectPeriod = const Duration(seconds: MqttConfig.reconnectDelay);
      _client!.onConnected = _onConnected;
      _client!.onDisconnected = _onDisconnected;
      _client!.onSubscribed = _onSubscribed;
      
      // Cấu hình SSL/TLS cho HiveMQ Cloud
      _client!.secure = true;
      _client!.securityContext = SecurityContext.defaultContext;
      
      // Tạo connection message
      final connMessage = MqttConnectMessage()
          .withClientIdentifier(clientId)
          .authenticateAs(MqttConfig.username, MqttConfig.password)
          .withWillQos(MqttQos.atLeastOnce)
          .startClean()
          .withWillRetain();
      
      _client!.connectionMessage = connMessage;
      
      // Kết nối
      await _client!.connect();
      
      if (_client!.connectionStatus!.state == MqttConnectionState.connected) {
        debugPrint('✅ MQTT Connected successfully!');
        _isConnected = true;
        
        // Subscribe to topics
        _subscribeToTopics();
        
        // Setup listener cho messages
        _client!.updates!.listen(_onMessage);
        
        notifyListeners();
        onConnected?.call();
      } else {
        debugPrint('❌ Connection failed: ${_client!.connectionStatus}');
        _isConnected = false;
        onError?.call('Connection failed');
      }
      
    } catch (e) {
      debugPrint('❌ MQTT Connection Error: $e');
      _isConnected = false;
      onError?.call(e.toString());
      notifyListeners();
    }
  }
  
  /// Subscribe to all topics
  void _subscribeToTopics() {
    _client!.subscribe(MqttConfig.topicSensorData, MqttQos.atLeastOnce);
    _client!.subscribe(MqttConfig.topicDeviceState, MqttQos.atLeastOnce);
    
    debugPrint('📥 Subscribed to topics');
  }
  
  /// Callback khi connected
  void _onConnected() {
    debugPrint('🟢 MQTT Connected callback');
    _isConnected = true;
    notifyListeners();
    onConnected?.call();
  }
  
  /// Callback khi disconnected
  void _onDisconnected() {
    debugPrint('🔴 MQTT Disconnected callback');
    _isConnected = false;
    notifyListeners();
    onDisconnected?.call();
  }
  
  /// Callback khi subscribed
  void _onSubscribed(String topic) {
    debugPrint('📥 Subscribed to: $topic');
  }
  
  /// Xử lý message từ MQTT
  void _onMessage(List<MqttReceivedMessage<MqttMessage>> messages) {
    for (final message in messages) {
      final topic = message.topic;
      final payload = message.payload as MqttPublishMessage;
      final payloadString = MqttPublishPayload.bytesToStringAsString(
        payload.payload.message,
      );
      
      debugPrint('📨 MQTT [$topic]: $payloadString');
      
      try {
        final data = jsonDecode(payloadString);
        
        // Xử lý theo topic
        switch (topic) {
          case MqttConfig.topicSensorData:
            onSensorData?.call(data);
            break;
          case MqttConfig.topicDeviceState:
            onDeviceState?.call(data);
            break;
          default:
            debugPrint('⚠️ Unknown topic: $topic');
        }
      } catch (e) {
        debugPrint('❌ Parse error: $e');
      }
    }
  }
  
  /// Gửi lệnh điều khiển thiết bị
  void sendDeviceControl(String device, bool state) {
    if (!_isConnected) {
      debugPrint('❌ MQTT not connected');
      onError?.call('Not connected to MQTT');
      return;
    }
    
    final message = jsonEncode({
      'device': device,
      'state': state,
    });
    
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);
    
    _client!.publishMessage(
      MqttConfig.topicDeviceControl,
      MqttQos.atLeastOnce,
      builder.payload!,
    );
    
    debugPrint('📤 Device control sent: $device = $state');
  }
  
  /// Gửi lệnh thay đổi chế độ
  void sendModeChange(String mode) {
    if (!_isConnected) {
      debugPrint('❌ MQTT not connected');
      return;
    }
    
    final message = jsonEncode({
      'mode': mode,
    });
    
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);
    
    _client!.publishMessage(
      MqttConfig.topicModeChange,
      MqttQos.atLeastOnce,
      builder.payload!,
    );
    
    debugPrint('📤 Mode change sent: $mode');
  }
  
  /// Ngắt kết nối
  void disconnect() {
    _client?.disconnect();
    _isConnected = false;
    notifyListeners();
    debugPrint('📪 MQTT Disconnected');
  }
  
  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}
```

---

## 4. TÍCH HỢP VÀO APP

### Bước 4.1: Cập nhật main.dart

Thay thế `WebSocketService` bằng `MqttService` trong `main.dart`:

```dart
// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/mqtt_service.dart';  // ✅ Thay đổi: Import MqttService
// import 'services/websocket_service.dart';  // ❌ Comment hoặc xóa
import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // ✅ Thay đổi: Sử dụng MqttService thay vì WebSocketService
        ChangeNotifierProvider(create: (_) => MqttService()),
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

### Bước 4.2: Cập nhật HomeScreen để sử dụng MqttService

Mở file `lib/screens/home_screen.dart` và cập nhật:

```dart
// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/mqtt_service.dart';  // ✅ Thay đổi
import '../models/sensor_data.dart';
import '../models/device_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  SensorData? _latestSensorData;
  DeviceState? _latestDeviceState;
  bool _isConnecting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _connectToMqtt();  // ✅ Thay đổi: Gọi connect MQTT
    });
  }

  // ✅ Thay đổi: Connect to MQTT instead of WebSocket
  Future<void> _connectToMqtt() async {
    setState(() => _isConnecting = true);
    
    final mqttService = context.read<MqttService>();
    
    // Setup callbacks
    mqttService.onSensorData = (data) {
      setState(() {
        _latestSensorData = SensorData.fromJson(data);
      });
    };
    
    mqttService.onDeviceState = (data) {
      setState(() {
        _latestDeviceState = DeviceState.fromJson(data);
      });
    };
    
    mqttService.onError = (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Lỗi: $error'),
          backgroundColor: Colors.red,
        ),
      );
    };
    
    mqttService.onConnected = () {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Đã kết nối MQTT Server'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    };
    
    mqttService.onDisconnected = () {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚠️ Mất kết nối MQTT'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    };
    
    // Connect
    await mqttService.connect();
    
    setState(() => _isConnecting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Farm'),
        actions: [
          // ✅ Thay đổi: Hiển thị trạng thái kết nối MQTT
          Consumer<MqttService>(
            builder: (context, mqttService, _) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: mqttService.isConnected 
                          ? Colors.green.withOpacity(0.2)
                          : Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          mqttService.isConnected 
                              ? Icons.cloud_done 
                              : Icons.cloud_off,
                          color: mqttService.isConnected 
                              ? Colors.green 
                              : Colors.red,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          mqttService.isConnected ? 'Online' : 'Offline',
                          style: TextStyle(
                            color: mqttService.isConnected 
                                ? Colors.green 
                                : Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: _isConnecting
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Đang kết nối MQTT...'),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Sensor Data Section
                  _buildSensorDataSection(),
                  const SizedBox(height: 24),
                  
                  // Device Control Section
                  _buildDeviceControlSection(),
                ],
              ),
            ),
    );
  }

  Widget _buildSensorDataSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.sensors, color: Colors.green),
                const SizedBox(width: 8),
                const Text(
                  'Dữ Liệu Cảm Biến',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (_latestSensorData != null)
                  Text(
                    'Cập nhật: ${_formatTime(_latestSensorData!.timestamp)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (_latestSensorData == null)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Text('Đang chờ dữ liệu...'),
                ),
              )
            else
              Column(
                children: [
                  _buildSensorItem(
                    Icons.thermostat,
                    'Nhiệt Độ',
                    '${_latestSensorData!.temperature.toStringAsFixed(1)}°C',
                    Colors.red,
                  ),
                  const Divider(),
                  _buildSensorItem(
                    Icons.water_drop,
                    'Độ Ẩm KK',
                    '${_latestSensorData!.humidity.toStringAsFixed(1)}%',
                    Colors.blue,
                  ),
                  const Divider(),
                  _buildSensorItem(
                    Icons.grass,
                    'Độ Ẩm Đất',
                    '${_latestSensorData!.soilMoisture.toStringAsFixed(0)}%',
                    Colors.brown,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSensorItem(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceControlSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.settings, color: Colors.green),
                const SizedBox(width: 8),
                const Text(
                  'Điều Khiển Thiết Bị',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDeviceSwitch(
              'Quạt Thông Gió',
              Icons.air,
              _latestDeviceState?.fan ?? false,
              'fan',
            ),
            _buildDeviceSwitch(
              'Đèn Chiếu Sáng',
              Icons.lightbulb,
              _latestDeviceState?.light ?? false,
              'light',
            ),
            _buildDeviceSwitch(
              'Hệ Thống Tưới',
              Icons.water,
              _latestDeviceState?.pump ?? false,
              'pump',
            ),
            _buildDeviceSwitch(
              'Hệ Thống Phun Sương',
              Icons.cloud,
              _latestDeviceState?.mist ?? false,
              'mist',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceSwitch(
    String label,
    IconData icon,
    bool value,
    String device,
  ) {
    return Consumer<MqttService>(
      builder: (context, mqttService, _) {
        return SwitchListTile(
          secondary: Icon(icon, color: value ? Colors.green : Colors.grey),
          title: Text(label),
          value: value,
          onChanged: mqttService.isConnected
              ? (newValue) {
                  mqttService.sendDeviceControl(device, newValue);
                }
              : null,
          activeColor: Colors.green,
        );
      },
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
           '${time.minute.toString().padLeft(2, '0')}:'
           '${time.second.toString().padLeft(2, '0')}';
  }
}
```

---

## 5. TEST & DEBUG

### Bước 5.1: Chạy app

```bash
flutter run
```

### Bước 5.2: Kiểm tra logs

Trong console, bạn sẽ thấy:

```
🔌 Connecting to MQTT broker...
📍 Broker: 7680f317994342a28675be77f6455901.s1.eu.hivemq.cloud:8883
✅ MQTT Connected successfully!
📥 Subscribed to topics
📥 Subscribed to: smartfarm/sensors/data
📥 Subscribed to: smartfarm/devices/state
📨 MQTT [smartfarm/sensors/data]: {"temperature":25.5,"humidity":65.2,...}
📤 Device control sent: fan = true
```

### Bước 5.3: Test các tính năng

✅ **Kết nối MQTT**
- App hiển thị "Online" khi kết nối thành công
- Hiển thị "Offline" khi mất kết nối

✅ **Nhận dữ liệu cảm biến**
- Nhiệt độ cập nhật realtime
- Độ ẩm không khí cập nhật realtime
- Độ ẩm đất cập nhật realtime

✅ **Điều khiển thiết bị**
- Bật/tắt Quạt → ESP32 nhận lệnh
- Bật/tắt Đèn → ESP32 nhận lệnh
- Bật/tắt Bơm → ESP32 nhận lệnh
- Bật/tắt Phun sương → ESP32 nhận lệnh

✅ **Đồng bộ trạng thái**
- Thay đổi từ Website → App cập nhật
- Thay đổi từ App → Website cập nhật
- Thay đổi từ ESP32 → Cả App và Website cập nhật

### Bước 5.4: Debug nếu có lỗi

**Lỗi: "Connection refused"**
```
✅ Giải pháp:
- Kiểm tra internet connection
- Verify HiveMQ credentials
- Check firewall settings
```

**Lỗi: "Certificate verification failed"**
```
✅ Giải pháp:
- Đảm bảo device có system time chính xác
- Update certificates trên device
- Test trên device thật (không phải emulator)
```

**Không nhận được data**
```
✅ Giải pháp:
- Check ESP32 đang publish data
- Verify topic names khớp nhau
- Check logs để thấy messages
```

---

## 6. SO SÁNH WEBSOCKET VS MQTT

| Tính năng | WebSocket | MQTT |
|-----------|-----------|------|
| **Kết nối** | Point-to-point (1-1) | Pub/Sub (nhiều-nhiều) |
| **Độ trễ** | ~50-100ms | ~10-50ms |
| **Băng thông** | Cao hơn | Thấp hơn (tối ưu) |
| **Reconnect** | Phải code riêng | Tự động built-in |
| **Scalability** | Khó scale | Dễ scale |
| **QoS** | Không có | Có (0, 1, 2) |
| **Deployment** | Cần server riêng | Dùng cloud (HiveMQ) |
| **Mobile friendly** | Ổn | Tốt hơn |

---

## 7. CHECKLIST HOÀN THÀNH

- [ ] Đã cài đặt package `mqtt_client`
- [ ] Đã tạo `lib/config/mqtt_config.dart`
- [ ] Đã tạo `lib/services/mqtt_service.dart`
- [ ] Đã cập nhật `main.dart` để dùng MqttService
- [ ] Đã cập nhật `home_screen.dart` để connect MQTT
- [ ] App connect thành công đến HiveMQ Cloud
- [ ] App nhận được dữ liệu cảm biến realtime
- [ ] App điều khiển được thiết bị
- [ ] Trạng thái đồng bộ giữa App, Website, ESP32
- [ ] Test trên device thật (không chỉ emulator)

---

## 8. TIP & BEST PRACTICES

### 8.1 Performance

```dart
// ✅ Tốt: Chỉ rebuild widget cần thiết
Consumer<MqttService>(
  builder: (context, mqtt, _) => Text(mqtt.isConnected ? 'Online' : 'Offline'),
)

// ❌ Tránh: Rebuild toàn bộ tree
Provider.of<MqttService>(context).isConnected;
```

### 8.2 Error Handling

```dart
// ✅ Tốt: Handle các loại lỗi
try {
  await mqttService.connect();
} on SocketException {
  showError('Không có internet');
} on MqttException {
  showError('Lỗi MQTT connection');
} catch (e) {
  showError('Lỗi không xác định: $e');
}
```

### 8.3 Resource Management

```dart
@override
void dispose() {
  // ✅ Luôn disconnect khi dispose
  context.read<MqttService>().disconnect();
  super.dispose();
}
```

---

## 9. NEXT STEPS

1. ✅ **Thêm charts**: Hiển thị lịch sử dữ liệu
2. ✅ **Thêm notifications**: Push notification khi có cảnh báo
3. ✅ **Offline mode**: Cache data khi mất kết nối
4. ✅ **Authentication**: Thêm login/logout
5. ✅ **Settings**: Cho phép user config MQTT broker

---

## 10. TÀI LIỆU THAM KHẢO

- 📚 [mqtt_client package](https://pub.dev/packages/mqtt_client)
- 📚 [HiveMQ Cloud Docs](https://www.hivemq.com/docs/)
- 📚 [MQTT Protocol](https://mqtt.org/)
- 📚 [Flutter Provider](https://pub.dev/packages/provider)

---

## 🎉 HOÀN THÀNH!

Bây giờ app Flutter của bạn đã tích hợp MQTT và có thể:
- ✅ Nhận dữ liệu cảm biến realtime từ ESP32
- ✅ Điều khiển thiết bị từ app
- ✅ Đồng bộ với Website
- ✅ Hoạt động từ bất kỳ đâu có internet

**Chúc bạn thành công! 🚀**
