class SensorData {
  final double temperature;
  final double humidity;
  final double soilMoisture;
  final int lightLevel;
  final DateTime timestamp;

  SensorData({
    required this.temperature,
    required this.humidity,
    required this.soilMoisture,
    required this.lightLevel,
    required this.timestamp,
  });

  factory SensorData.fromJson(Map<String, dynamic> json) {
    // Handle different message formats from server
    Map<String, dynamic> sensorData;

    if (json.containsKey('data')) {
      // sensor_update format: {type: 'sensor_update', data: {...}}
      if (json['data'] is Map && json['data'].containsKey('sensors')) {
        // initial_data format: {type: 'initial_data', data: {sensors: {...}, devices: {...}}}
        sensorData = json['data']['sensors'] as Map<String, dynamic>;
      } else {
        // sensor_update format
        sensorData = json['data'] as Map<String, dynamic>;
      }
    } else {
      // Direct format: {temperature: ..., humidity: ...}
      sensorData = json;
    }

    return SensorData(
      temperature: (sensorData['temperature'] ?? 0).toDouble(),
      humidity: (sensorData['humidity'] ?? 0).toDouble(),
      soilMoisture: (sensorData['soilMoisture'] ?? 0).toDouble(),
      lightLevel: (sensorData['lightLevel'] ?? 0).toInt(),
      timestamp: sensorData['timestamp'] != null
          ? DateTime.fromMillisecondsSinceEpoch(sensorData['timestamp'] as int)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'temperature': temperature,
      'humidity': humidity,
      'soilMoisture': soilMoisture,
      'lightLevel': lightLevel,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  SensorData copyWith({
    double? temperature,
    double? humidity,
    double? soilMoisture,
    int? lightLevel,
    DateTime? timestamp,
  }) {
    return SensorData(
      temperature: temperature ?? this.temperature,
      humidity: humidity ?? this.humidity,
      soilMoisture: soilMoisture ?? this.soilMoisture,
      lightLevel: lightLevel ?? this.lightLevel,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
