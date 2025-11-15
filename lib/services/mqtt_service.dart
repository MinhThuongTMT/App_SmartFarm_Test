// lib/services/mqtt_service.dart
// Direct WebSocket connection to HiveMQ Cloud (same as Website)

import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class MqttService extends ChangeNotifier {
  WebSocketChannel? _channel;
  bool _isConnected = false;
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;

  // WebSocket URL to Node.js server (MQTT Bridge)
  // OPTION 1: Local testing - Replace with your computer IP (run ipconfig to get IP)
  // static const String _serverUrl = 'ws://192.168.1.100:3000'; // Example IP
  
  // OPTION 2: Production - Use Ngrok URL (temporary)
  // static const String _serverUrl = 'wss://your-ngrok-url.ngrok-free.app';
  
  // OPTION 3: Production - Connect directly to HiveMQ Cloud (RECOMMENDED)
  // Requires switching to MQTT package instead of WebSocket
  static const String _serverUrl = 'ws://localhost:3000'; // ⚠️ Only works on emulator/web

  // Callbacks
  Function(Map<String, dynamic>)? onSensorData;
  Function(Map<String, dynamic>)? onDeviceState;
  Function(String)? onModeChange;
  Function(String)? onError;
  Function()? onConnected;
  Function()? onDisconnected;

  // Getters
  bool get isConnected => _isConnected;

  /// Kết nối WebSocket trực tiếp đến HiveMQ Cloud
  Future<void> connect() async {
    try {
      debugPrint('🔌 Connecting to Server...');
      debugPrint('📍 URL: $_serverUrl');

      _channel = WebSocketChannel.connect(Uri.parse(_serverUrl));

      // Lắng nghe messages
      _channel!.stream.listen(
        (message) {
          _handleMessage(message);
        },
        onError: (error) {
          debugPrint('❌ WebSocket Error: $error');
          _isConnected = false;
          notifyListeners();
          onError?.call(error.toString());
          _scheduleReconnect();
        },
        onDone: () {
          debugPrint('🔴 WebSocket Disconnected');
          _isConnected = false;
          notifyListeners();
          onDisconnected?.call();
          _scheduleReconnect();
        },
      );

      _isConnected = true;
      notifyListeners();
      onConnected?.call();

      debugPrint('✅ Connected to Server (MQTT Bridge)!'); // Start heartbeat
      _startHeartbeat();
    } catch (e) {
      debugPrint('❌ Connection Error: $e');
      _isConnected = false;
      notifyListeners();
      onError?.call(e.toString());
      _scheduleReconnect();
    }
  }

  /// Xử lý tin nhắn từ WebSocket
  void _handleMessage(dynamic message) {
    try {
      final data = jsonDecode(message.toString());
      debugPrint('📨 Received: ${data['type']}');

      switch (data['type']) {
        case 'initial_data':
          // Data ban đầu khi connect
          if (data['data']['sensors'] != null) {
            onSensorData?.call(data['data']['sensors']);
          }
          if (data['data']['devices'] != null) {
            onDeviceState?.call(data['data']['devices']);
          }
          break;

        case 'sensor_update':
          onSensorData?.call(data['data']);
          break;

        case 'device_states':
          // Server sends: {type: 'device_states', fan: false, pump: false, ...}
          onDeviceState?.call(data);
          break;

        case 'device_state':
        case 'device_update':
          // Single device update: {type: 'device_update', device: 'fan', state: true}
          onDeviceState?.call(data);
          break;

        case 'mode_change':
        case 'mode_update':
          // Mode change: {type: 'mode_update', mode: {manual: true, auto: false, ...}}
          final modeData = data['mode'];
          if (modeData is Map) {
            // Find which mode is true
            String activeMode = 'manual';
            for (var entry in modeData.entries) {
              if (entry.value == true) {
                activeMode = entry.key.toString();
                break;
              }
            }
            onModeChange?.call(activeMode);
          } else if (modeData is String) {
            onModeChange?.call(modeData);
          }
          break;

        default:
          debugPrint('⚠️ Unknown message type: ${data['type']}');
      }
    } catch (e) {
      debugPrint('❌ Parse error: $e');
    }
  }

  /// Heartbeat để giữ connection
  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_isConnected) {
        try {
          _channel?.sink.add(jsonEncode({'type': 'ping'}));
        } catch (e) {
          debugPrint('❌ Heartbeat error: $e');
        }
      }
    });
  }

  /// Lên lịch reconnect
  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 5), () {
      if (!_isConnected) {
        debugPrint('🔄 Attempting to reconnect...');
        connect();
      }
    });
  }

  /// Gửi lệnh điều khiển thiết bị
  void sendDeviceControl(String device, bool state) {
    if (!_isConnected) {
      debugPrint('❌ Not connected');
      onError?.call('Not connected to server');
      return;
    }

    try {
      final message = jsonEncode({
        'type': 'device_control',
        'data': {
          'device': device,
          'state': state,
        },
      });

      _channel?.sink.add(message);
      debugPrint('📤 Device control sent: $device = $state');
    } catch (e) {
      debugPrint('❌ Send error: $e');
      onError?.call(e.toString());
    }
  }

  /// Gửi lệnh thay đổi chế độ
  void sendModeChange(String mode) {
    if (!_isConnected) {
      debugPrint('❌ Not connected');
      return;
    }

    try {
      final message = jsonEncode({
        'type': 'mode_change',
        'data': {'mode': mode},
      });

      _channel?.sink.add(message);
      debugPrint('📤 Mode change sent: $mode');
    } catch (e) {
      debugPrint('❌ Send error: $e');
    }
  }

  /// Ngắt kết nối
  void disconnect() {
    _heartbeatTimer?.cancel();
    _reconnectTimer?.cancel();
    _channel?.sink.close();
    _isConnected = false;
    notifyListeners();
    debugPrint('📪 Disconnected');
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}
