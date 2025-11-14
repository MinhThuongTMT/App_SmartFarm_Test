import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter/foundation.dart';

class WebSocketService extends ChangeNotifier {
  WebSocketChannel? _channel;
  bool _isConnected = false;

  // Callbacks
  Function(Map<String, dynamic>)? onSensorData;
  Function(Map<String, dynamic>)? onDeviceState;
  Function(String)? onModeChange;
  Function(String)? onError;

  // Getters
  bool get isConnected => _isConnected;

  // Kết nối đến server
  void connect(String serverUrl) {
    try {
      _channel = WebSocketChannel.connect(Uri.parse(serverUrl));

      _channel!.stream.listen(
        _handleMessage,
        onError: (error) {
          debugPrint('❌ WebSocket Error: $error');
          _isConnected = false;
          onError?.call(error.toString());
          notifyListeners();
        },
        onDone: () {
          debugPrint('🔌 WebSocket Disconnected');
          _isConnected = false;
          notifyListeners();
        },
      );

      _isConnected = true;
      debugPrint('✅ WebSocket Connected to $serverUrl');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Connection failed: $e');
      _isConnected = false;
      onError?.call(e.toString());
      notifyListeners();
    }
  }

  // Xử lý message từ server
  void _handleMessage(dynamic message) {
    try {
      final data = jsonDecode(message.toString());
      debugPrint('📨 Received: ${data['type']}');

      switch (data['type']) {
        case 'sensor_data':
        case 'sensor_update':
        case 'initial_data':
          // Xử lý sensor data từ nhiều message types
          onSensorData?.call(data);
          break;
        case 'device_state':
        case 'device_states':
          // Xử lý device state từ nhiều message types
          onDeviceState?.call(data);
          break;
        case 'mode_change':
          onModeChange?.call(data['mode'] as String);
          break;
        case 'error':
          onError?.call(data['message'] as String);
          break;
        default:
          debugPrint('⚠️ Unknown message type: ${data['type']}');
      }

      notifyListeners();
    } catch (e) {
      debugPrint('❌ Parse error: $e');
    }
  }

  // Gửi lệnh điều khiển thiết bị
  void sendDeviceControl(String device, bool state) {
    if (!_isConnected) {
      debugPrint('❌ Not connected');
      return;
    }

    final command = jsonEncode({
      'type': 'device_control',
      'device': device,
      'state': state,
    });

    _channel?.sink.add(command);
    debugPrint('🎛️ Device control sent: $device = $state');
  }

  // Gửi lệnh thay đổi chế độ
  void sendModeChange(String mode) {
    if (!_isConnected) return;

    final command = jsonEncode({
      'type': 'mode_change',
      'mode': mode,
    });

    _channel?.sink.add(command);
    debugPrint('🔄 Mode change sent: $mode');
  }

  // Ngắt kết nối
  void disconnect() {
    _channel?.sink.close();
    _isConnected = false;
    notifyListeners();
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}
