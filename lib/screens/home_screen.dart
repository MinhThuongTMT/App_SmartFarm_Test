import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../services/hivemq_service.dart';
import '../models/sensor_data.dart';
import '../models/device_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  SensorData? _sensorData;
  DeviceState? _deviceState;
  String _currentMode = 'manual';

  // Lưu lịch sử dữ liệu cho biểu đồ
  final List<SensorData> _sensorHistory = [];
  final int _maxHistoryLength = 20; // Giữ 20 điểm dữ liệu

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _connectMqtt();
    });
  }

  void _connectMqtt() {
    final mqtt = context.read<HiveMQService>();

    // Đăng ký callbacks
    mqtt.onSensorData = (data) {
      setState(() {
        _sensorData = SensorData.fromJson(data);

        // Thêm vào lịch sử
        _sensorHistory.add(_sensorData!);
        if (_sensorHistory.length > _maxHistoryLength) {
          _sensorHistory.removeAt(0);
        }
      });
    };

    mqtt.onDeviceState = (data) {
      setState(() {
        _deviceState = DeviceState.fromJson(data);
      });
    };

    mqtt.onModeChange = (mode) {
      setState(() {
        _currentMode = mode;
      });
    };

    mqtt.onError = (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: $error'),
          backgroundColor: Colors.red,
        ),
      );
    };

    // Kết nối MQTT
    mqtt.connect();
  }

  @override
  Widget build(BuildContext context) {
    final mqtt = context.watch<HiveMQService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Farm'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        actions: [
          // Connection status indicator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(
                  mqtt.isConnected ? Icons.cloud_done : Icons.cloud_off,
                  color: mqtt.isConnected ? Colors.white : Colors.red[200],
                ),
                const SizedBox(width: 8),
                Text(
                  mqtt.isConnected ? 'Online' : 'Offline',
                  style: TextStyle(
                    color: mqtt.isConnected ? Colors.white : Colors.red[200],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: mqtt.isConnected ? _buildDashboard() : _buildDisconnectedState(),
    );
  }

  Widget _buildDashboard() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mode Selector
          _buildModeSelector(),
          const SizedBox(height: 24),

          // Sensor Data Cards
          const Text(
            '📊 Dữ Liệu Cảm Biến',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildSensorCards(),
          const SizedBox(height: 24),

          // Charts
          const Text(
            '📈 Biểu Đồ Thời Gian Thực',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildCharts(),
          const SizedBox(height: 24),

          // Device Control
          const Text(
            '🎛️ Điều Khiển Thiết Bị',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildDeviceControls(),
        ],
      ),
    );
  }

  Widget _buildModeSelector() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.settings, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Chế Độ Điều Khiển',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SegmentedButton<String>(
              segments: const [
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
                context.read<HiveMQService>().sendModeChange(mode);
              },
            ),
            const SizedBox(height: 8),
            Text(
              _currentMode == 'manual'
                  ? '✋ Điều khiển thủ công các thiết bị'
                  : _currentMode == 'auto'
                      ? '🤖 Hệ thống tự động điều khiển theo cảm biến'
                      : '⏰ Điều khiển theo lịch trình đã thiết lập',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSensorCards() {
    if (_sensorData == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Column(
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Đang chờ dữ liệu cảm biến...'),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildSensorCard(
                '🌡️',
                'Nhiệt Độ',
                '${_sensorData!.temperature.toStringAsFixed(1)}°C',
                Colors.orange,
                _getTemperatureStatus(_sensorData!.temperature),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSensorCard(
                '💧',
                'Độ Ẩm',
                '${_sensorData!.humidity.toStringAsFixed(1)}%',
                Colors.blue,
                _getHumidityStatus(_sensorData!.humidity),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildSensorCard(
                '🌱',
                'Độ Ẩm Đất',
                '${_sensorData!.soilMoisture.toStringAsFixed(0)}%',
                Colors.brown,
                _getSoilMoistureStatus(_sensorData!.soilMoisture),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSensorCard(
                '☀️',
                'Ánh Sáng',
                '${_sensorData!.lightLevel}',
                Colors.yellow[700]!,
                _getLightLevelStatus(_sensorData!.lightLevel),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSensorCard(
    String emoji,
    String title,
    String value,
    Color color,
    String status,
  ) {
    return Card(
      elevation: 3,
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                status,
                style: TextStyle(
                  fontSize: 10,
                  color: color.withOpacity(0.8),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCharts() {
    if (_sensorHistory.length < 2) {
      return Card(
        child: Container(
          height: 200,
          alignment: Alignment.center,
          child: const Text('Đang thu thập dữ liệu để vẽ biểu đồ...'),
        ),
      );
    }

    return Column(
      children: [
        _buildLineChart(
          'Nhiệt Độ (°C)',
          Colors.orange,
          _sensorHistory.map((e) => e.temperature).toList(),
        ),
        const SizedBox(height: 16),
        _buildLineChart(
          'Độ Ẩm (%)',
          Colors.blue,
          _sensorHistory.map((e) => e.humidity).toList(),
        ),
        const SizedBox(height: 16),
        _buildLineChart(
          'Độ Ẩm Đất (%)',
          Colors.brown,
          _sensorHistory.map((e) => e.soilMoisture).toList(),
        ),
      ],
    );
  }

  Widget _buildLineChart(String title, Color color, List<double> data) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 150,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 1,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey[300],
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: _calculateInterval(data),
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toStringAsFixed(0),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
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
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 3,
                            color: color,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: color.withOpacity(0.2),
                      ),
                    ),
                  ],
                  // Handle edge case when min = max
                  clipData: FlClipData.all(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceControls() {
    if (_deviceState == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Column(
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Đang chờ trạng thái thiết bị...'),
            ],
          ),
        ),
      );
    }

    final isManualMode = _currentMode == 'manual';

    return Column(
      children: [
        if (!isManualMode)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange[300]!),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orange),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Chuyển sang Manual Mode để điều khiển thiết bị',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange,
                    ),
                  ),
                ),
              ],
            ),
          ),
        _buildDeviceCard(
          '🌀',
          'Quạt',
          'fan',
          _deviceState!.fan,
          isManualMode,
          Colors.cyan,
        ),
        _buildDeviceCard(
          '💦',
          'Máy Bơm',
          'pump',
          _deviceState!.pump,
          isManualMode,
          Colors.blue,
        ),
        _buildDeviceCard(
          '💡',
          'Đèn',
          'light',
          _deviceState!.light,
          isManualMode,
          Colors.yellow[700]!,
        ),
        _buildDeviceCard(
          '🌫️',
          'Phun Sương',
          'mist',
          _deviceState!.mist,
          isManualMode,
          Colors.grey,
        ),
      ],
    );
  }

  Widget _buildDeviceCard(
    String emoji,
    String name,
    String deviceId,
    bool isOn,
    bool isEnabled,
    Color color,
  ) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: isOn ? color.withOpacity(0.2) : Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              emoji,
              style: const TextStyle(fontSize: 24),
            ),
          ),
        ),
        title: Text(
          name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
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
            const SizedBox(width: 6),
            Text(
              isOn ? 'Đang BẬT' : 'Đang TẮT',
              style: TextStyle(
                color: isOn ? Colors.green : Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        trailing: Switch(
          value: isOn,
          onChanged: isEnabled
              ? (value) {
                  context
                      .read<HiveMQService>()
                      .sendDeviceControl(deviceId, value);
                }
              : null,
          activeColor: color,
        ),
      ),
    );
  }

  Widget _buildDisconnectedState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.cloud_off,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Chưa kết nối đến server',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Kiểm tra server và ngrok',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _connectMqtt,
            icon: const Icon(Icons.refresh),
            label: const Text('Kết nối lại'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[700],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods for status
  String _getTemperatureStatus(double temp) {
    if (temp < 20) return 'Lạnh';
    if (temp < 28) return 'Tốt';
    if (temp < 35) return 'Ấm';
    return 'Nóng';
  }

  String _getHumidityStatus(double humidity) {
    if (humidity < 40) return 'Khô';
    if (humidity < 70) return 'Tốt';
    return 'Ẩm';
  }

  String _getSoilMoistureStatus(double moisture) {
    if (moisture < 30) return 'Khô';
    if (moisture < 70) return 'Tốt';
    return 'Ướt';
  }

  String _getLightLevelStatus(int light) {
    if (light < 300) return 'Tối';
    if (light < 1000) return 'Tốt';
    return 'Sáng';
  }

  // Helper methods for charts
  double _calculateInterval(List<double> data) {
    if (data.isEmpty) return 1.0;

    final max = data.reduce((a, b) => a > b ? a : b);
    final min = data.reduce((a, b) => a < b ? a : b);
    final range = max - min;

    // Tránh chia cho 0 khi tất cả giá trị giống nhau
    if (range == 0) return 1.0;

    final interval = range / 4;
    return interval > 0 ? interval : 1.0;
  }

  double _getMinY(List<double> data) {
    if (data.isEmpty) return 0;

    final min = data.reduce((a, b) => a < b ? a : b);
    return (min - 5).floorToDouble();
  }

  double _getMaxY(List<double> data) {
    if (data.isEmpty) return 100;

    final max = data.reduce((a, b) => a > b ? a : b);
    return (max + 5).ceilToDouble();
  }
}
