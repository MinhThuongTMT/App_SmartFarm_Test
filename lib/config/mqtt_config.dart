// lib/config/mqtt_config.dart

class MqttConfig {
  // HiveMQ Cloud Configuration
  static const String broker =
      '7680f317994342a28675be77f6455901.s1.eu.hivemq.cloud';
  static const int port = 8884; // WebSocket port for web
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
