# Changelog

All notable changes to Smart Farm Mobile App will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-11-15

### Added
- 🎉 Initial release of Smart Farm Mobile App
- 📱 Flutter app with Material Design 3
- 🔌 WebSocket real-time connection to Node.js server
- 📊 Real-time sensor data display (Temperature, Humidity, Soil Moisture, Light)
- 📈 Live charts for sensor data (3 line charts with 20 data points)
- 🎛️ Device control UI (Fan, Pump, Light, Mist)
- 🔄 3 control modes: Manual, Auto, Schedule
- 🟢 Online/Offline status indicator
- 💾 Models for SensorData and DeviceState
- 🧩 WebSocketService with callback architecture
- 📝 Comprehensive documentation (README, SETUP_GUIDE, QUICKSTART)
- 🌍 Support for localhost, LAN, and Internet (Ngrok) connections
- 🎨 Beautiful sensor cards with status evaluation (Good/Dry/Wet/Hot)
- 🔐 Android permissions configured
- 🏗️ Clean architecture with models, services, screens separation

### Technical
- Flutter 3.24.5
- Dependencies:
  - web_socket_channel: ^2.4.0
  - provider: ^6.1.1
  - fl_chart: ^0.65.0
  - intl: ^0.18.1

### Features Detail

#### Sensor Monitoring
- Display 4 sensor types with emoji icons
- Status evaluation (Cold/Good/Warm/Hot for temperature, etc.)
- Real-time updates via WebSocket
- Timestamp for each reading

#### Charts
- Temperature chart (orange)
- Humidity chart (blue)
- Soil moisture chart (brown)
- Smooth curved lines with gradient fill
- Auto-scaling based on min/max values
- Fixed interval calculation to avoid division by zero

#### Device Control
- Switch UI with animations
- Disabled when not in Manual mode
- Visual feedback (green dot for ON, grey for OFF)
- Send commands via WebSocket

#### WebSocket
- Auto-reconnect capability
- Handle multiple message formats:
  - `initial_data`
  - `sensor_update`
  - `device_states`
- Error handling with callbacks
- Debug logging

### Fixed
- ✅ Chart interval = 0 error when all values are the same
- ✅ Empty data array handling in chart calculations
- ✅ WebSocket message format compatibility with server
- ✅ SensorData parsing for nested JSON structures
- ✅ DeviceState parsing for different message types

### Documentation
- README.md with full feature list
- SETUP_GUIDE.md with step-by-step instructions
- QUICKSTART.md for rapid deployment
- HuongdansetupFlutter.md in Vietnamese
- CHANGELOG.md (this file)

### Platforms
- ✅ Web (Chrome)
- ✅ Android (tested)
- ⚠️ iOS (not tested, should work)
- ⚠️ Windows (not tested)
- ⚠️ macOS (not tested)
- ⚠️ Linux (not tested)

## [Unreleased]

### Planned Features
- [ ] User authentication (Firebase Auth)
- [ ] Local data persistence (SQLite)
- [ ] Push notifications for alerts
- [ ] Historical data view (7/30 days)
- [ ] Export data to CSV
- [ ] Dark mode theme
- [ ] Multiple language support
- [ ] Schedule configuration UI
- [ ] Sensor threshold configuration
- [ ] More chart types (bar, pie)

### Known Issues
- None at this time

## Development Notes

### Version Naming
- Major: Significant new features or breaking changes
- Minor: New features, non-breaking changes
- Patch: Bug fixes, documentation updates

### Release Process
1. Update version in `pubspec.yaml`
2. Update CHANGELOG.md
3. Commit changes
4. Create git tag
5. Build APK/IPA
6. Push to GitHub

---

**Project:** Smart Farm Mobile App  
**Repository:** https://github.com/MinhThuongTMT/Train_AI_DATN  
**License:** MIT
