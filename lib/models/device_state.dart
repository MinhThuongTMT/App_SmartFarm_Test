class DeviceState {
  final bool fan;
  final bool pump;
  final bool light;
  final bool mist;
  final DateTime timestamp;

  DeviceState({
    required this.fan,
    required this.pump,
    required this.light,
    required this.mist,
    required this.timestamp,
  });

  factory DeviceState.fromJson(Map<String, dynamic> json) {
    // Handle different message formats from server
    Map<String, dynamic> deviceData;

    if (json.containsKey('data')) {
      if (json['data'] is Map && json['data'].containsKey('devices')) {
        // initial_data format: {type: 'initial_data', data: {sensors: {...}, devices: {...}}}
        deviceData = json['data']['devices'] as Map<String, dynamic>;
      } else {
        // Other nested format
        deviceData = json['data'] as Map<String, dynamic>;
      }
    } else {
      // device_states format: {type: 'device_states', fan: true, pump: false, ...}
      deviceData = json;
    }

    return DeviceState(
      fan: deviceData['fan'] ?? false,
      pump: deviceData['pump'] ?? false,
      light: deviceData['light'] ?? false,
      mist: deviceData['mist'] ?? false,
      timestamp: deviceData['timestamp'] != null
          ? DateTime.fromMillisecondsSinceEpoch(deviceData['timestamp'] as int)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fan': fan,
      'pump': pump,
      'light': light,
      'mist': mist,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  DeviceState copyWith({
    bool? fan,
    bool? pump,
    bool? light,
    bool? mist,
    DateTime? timestamp,
  }) {
    return DeviceState(
      fan: fan ?? this.fan,
      pump: pump ?? this.pump,
      light: light ?? this.light,
      mist: mist ?? this.mist,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
