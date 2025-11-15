# 🚀 QUICK START - Build APK Production

## ✅ Đã hoàn tất Option 3: Kết nối trực tiếp HiveMQ Cloud MQTT

---

## 📱 BUILD APK NGAY (3 bước)

### BƯỚC 1: Test trên Chrome (Optional nhưng khuyến nghị)

```bash
cd "d:\DO AN TOT NGHIEP\CODE\smart_farm_mobile"
flutter run -d chrome
```

**Kiểm tra:**
- App hiển thị "Online" ✅
- Nhận dữ liệu cảm biến ✅
- Điều khiển thiết bị hoạt động ✅

---

### BƯỚC 2: Build APK

#### Option A: Universal APK (1 file cho tất cả máy)
```bash
flutter build apk --release
```
📍 Output: `build\app\outputs\flutter-apk\app-release.apk` (~35 MB)

#### Option B: Split APK (Khuyến nghị - nhẹ hơn)
```bash
flutter build apk --split-per-abi --release
```
📍 Output:
- `app-arm64-v8a-release.apk` ⭐ **Chọn file này** (~20 MB)
- `app-armeabi-v7a-release.apk` (máy cũ)
- `app-x86_64-release.apk` (Intel)

---

### BƯỚC 3: Cài đặt APK

#### Cách 1: USB Debugging
```bash
# Kết nối điện thoại qua USB (bật USB Debugging)
flutter install
```

#### Cách 2: Copy file APK
1. Copy file `app-arm64-v8a-release.apk` sang điện thoại
2. Mở file APK trên điện thoại
3. Cho phép "Install from Unknown Sources"
4. Cài đặt

---

## ✅ CHECKLIST SAU KHI CÀI

- [ ] App mở được
- [ ] Hiển thị "Online" (góc phải màu xanh)
- [ ] Nhận dữ liệu cảm biến real-time
- [ ] Điều khiển thiết bị hoạt động (Fan, Pump, Light, Mist)
- [ ] Chuyển mode hoạt động (Manual, Auto, Schedule)
- [ ] App hoạt động cả khi không cùng WiFi với ESP32

---

## 🐛 Nếu gặp lỗi build

```bash
flutter clean
flutter pub get
flutter build apk --release
```

---

## 📋 Chi tiết đầy đủ

Xem file `OPTION3_COMPLETE.md` hoặc `BUILD_APK_GUIDE.md` để biết thêm chi tiết.

---

## 🎯 Kết quả

APK sẽ:
- ✅ Hoạt động độc lập (không cần server)
- ✅ Kết nối trực tiếp HiveMQ Cloud
- ✅ Giám sát dữ liệu real-time
- ✅ Điều khiển thiết bị từ xa
- ✅ Hoạt động mọi nơi có internet

---

**LỆNH QUAN TRỌNG NHẤT:**

```bash
flutter build apk --split-per-abi --release
```

**File cần cài:** `build\app\outputs\flutter-apk\app-arm64-v8a-release.apk`

---

**Status:** ✅ Production Ready!
