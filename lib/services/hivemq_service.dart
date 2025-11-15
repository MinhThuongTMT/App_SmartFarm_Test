// lib/services/hivemq_service.dart
// Direct MQTT connection to HiveMQ Cloud (Production Ready)

import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class HiveMQService extends ChangeNotifier {
  MqttServerClient? _client;
  bool _isConnected = false;

  // HiveMQ Cloud Configuration (same as Website)
  static const String _broker =
      '7680f317994342a28675be77f6455901.s1.eu.hivemq.cloud';
  static const int _port = 8883; // MQTT TLS port
  static const String _username = 'hivemq.webclient.1763212764861';
  static const String _password = '>5aU7Db1c\$N2T%mGZ,jr';

  // MQTT Topics
  static const String _topicSensorData = 'smartfarm/sensors/data';
  static const String _topicDeviceState = 'smartfarm/devices/state';
  static const String _topicDeviceControl = 'smartfarm/devices/control';
  static const String _topicModeChange = 'smartfarm/mode/change';

  // Callbacks
  Function(Map<String, dynamic>)? onSensorData;
  Function(Map<String, dynamic>)? onDeviceState;
  Function(String)? onModeChange;
  Function(String)? onError;
  Function()? onConnected;
  Function()? onDisconnected;

  // Getters
  bool get isConnected => _isConnected;

  /// Kết nối trực tiếp đến HiveMQ Cloud qua MQTT TLS
  Future<void> connect() async {
    try {
      debugPrint('🔌 Connecting to HiveMQ Cloud MQTT...');

      // Generate unique client ID
      final clientId = 'FlutterApp_${DateTime.now().millisecondsSinceEpoch}';

      // Initialize MQTT client
      _client = MqttServerClient.withPort(_broker, clientId, _port);
      _client!.logging(on: kDebugMode);
      _client!.keepAlivePeriod = 60;
      _client!.autoReconnect = true;
      _client!.onConnected = _onConnected;
      _client!.onDisconnected = _onDisconnected;
      _client!.onSubscribed = _onSubscribed;

      // Configure SSL/TLS (only for mobile, not web)
      if (!kIsWeb) {
        _client!.secure = true;
        _client!.securityContext = SecurityContext.defaultContext;
      }

      // Set connection message
      final connMessage = MqttConnectMessage()
          .withClientIdentifier(clientId)
          .authenticateAs(_username, _password)
          .withWillQos(MqttQos.atLeastOnce)
          .startClean()
          .withWillRetain();

      _client!.connectionMessage = connMessage;

      // Connect
      await _client!.connect();

      if (_client!.connectionStatus!.state == MqttConnectionState.connected) {
        debugPrint('✅ Connected to HiveMQ Cloud MQTT');
        _isConnected = true;

        // Subscribe to topics
        _subscribeToTopics();

        // Setup message listener
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
    _client!.subscribe(_topicSensorData, MqttQos.atLeastOnce);
    _client!.subscribe(_topicDeviceState, MqttQos.atLeastOnce);
    debugPrint('📥 Subscribed to MQTT topics');
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
        if (topic == _topicSensorData) {
          onSensorData?.call(data);
        } else if (topic == _topicDeviceState) {
          onDeviceState?.call(data);
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
      _topicDeviceControl,
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
      _topicModeChange,
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
