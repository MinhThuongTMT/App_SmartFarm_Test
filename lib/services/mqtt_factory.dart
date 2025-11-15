// lib/services/mqtt_factory.dart
// Factory to create appropriate MQTT service based on platform

import 'package:flutter/foundation.dart';
import 'mqtt_service.dart';
import 'hivemq_service.dart';

class MqttFactory {
  /// Create appropriate MQTT service based on platform
  /// - Web: Use WebSocket service (MqttService)
  /// - Mobile (Android/iOS): Use MQTT Direct service (HiveMQService)
  static dynamic createMqttService() {
    if (kIsWeb) {
      // Web platform: Use WebSocket to Node.js server
      debugPrint('🌐 Platform: Web - Using WebSocket service');
      return MqttService();
    } else {
      // Mobile platform: Use direct MQTT connection to HiveMQ Cloud
      debugPrint('📱 Platform: Mobile - Using HiveMQ Direct service');
      return HiveMQService();
    }
  }
}
