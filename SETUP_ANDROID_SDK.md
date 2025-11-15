# 🔧 Cài đặt Android SDK để Build APK

## ❌ VẤN ĐỀ HIỆN TẠI

```
[!] No Android SDK found. Try setting the ANDROID_HOME environment variable.
```

Flutter không tìm thấy Android SDK → Không thể build APK.

---

## ✅ GIẢI PHÁP - 2 CÁCH

### **CÁCH 1: Cài Android Studio (Khuyến nghị)** ⭐

#### Bước 1: Download Android Studio

1. Truy cập: https://developer.android.com/studio
2. Download Android Studio (khoảng 1GB)
3. Chạy file cài đặt

#### Bước 2: Cài đặt Android Studio

1. **Install Type:** Chọn "Standard"
2. **Theme:** Chọn Light hoặc Dark (tùy thích)
3. **Verify Settings:** Click "Next"
4. **Download Components:** Đợi tải Android SDK (khoảng 3-5GB)

#### Bước 3: Cài Android SDK Command-line Tools

1. Mở Android Studio
2. **More Actions** → **SDK Manager**
3. Tab **SDK Tools**
4. Tích chọn:
   - ✅ Android SDK Command-line Tools
   - ✅ Android SDK Build-Tools
   - ✅ Android SDK Platform-Tools
5. Click **Apply** → **OK**

#### Bước 4: Accept Android Licenses

```powershell
flutter doctor --android-licenses
# Nhấn 'y' để accept tất cả licenses
```

#### Bước 5: Verify

```powershell
flutter doctor -v
```

Kết quả phải có:
```
[√] Android toolchain - develop for Android devices
```

---

### **CÁCH 2: Cài Android SDK riêng (Không cài Android Studio)**

⚠️ **Lưu ý:** Cách này phức tạp hơn, khuyến nghị dùng Cách 1!

#### Bước 1: Download Command Line Tools

1. Truy cập: https://developer.android.com/studio#command-line-tools-only
2. Download "Command line tools only" for Windows
3. Giải nén vào: `C:\Android\cmdline-tools`

#### Bước 2: Cấu trúc thư mục đúng

```
C:\Android\
  └── cmdline-tools\
      └── latest\
          ├── bin\
          ├── lib\
          └── ...
```

#### Bước 3: Set Environment Variables

**PowerShell (Admin):**

```powershell
# Set ANDROID_HOME
[System.Environment]::SetEnvironmentVariable('ANDROID_HOME', 'C:\Android', 'Machine')

# Add to PATH
$currentPath = [System.Environment]::GetEnvironmentVariable('Path', 'Machine')
$newPath = "$currentPath;C:\Android\cmdline-tools\latest\bin;C:\Android\platform-tools"
[System.Environment]::SetEnvironmentVariable('Path', $newPath, 'Machine')

# Restart PowerShell sau khi set
```

#### Bước 4: Install SDK packages

```powershell
# Mở PowerShell mới (sau khi restart)
cd C:\Android\cmdline-tools\latest\bin

# List available packages
.\sdkmanager.bat --list

# Install required packages
.\sdkmanager.bat "platform-tools" "platforms;android-34" "build-tools;34.0.0"
```

#### Bước 5: Configure Flutter

```powershell
flutter config --android-sdk C:\Android
flutter doctor --android-licenses
```

---

## 🚀 SAU KHI CÀI XONG

### 1. Verify Installation

```powershell
flutter doctor -v
```

**Kết quả mong đợi:**

```
[√] Flutter (Channel stable, 3.24.5, ...)
[√] Android toolchain - develop for Android devices (Android SDK version 34.0.0)
    • Android SDK at C:\Users\...\AppData\Local\Android\Sdk
    • Platform android-34, build-tools 34.0.0
    • Java binary at: C:\Program Files\Android\Android Studio\jbdk\bin\java
    • Java version OpenJDK Runtime Environment (build ...)
[√] Chrome - develop for the web
[√] VS Code
```

### 2. Build APK

```bash
cd "d:\DO AN TOT NGHIEP\CODE\smart_farm_mobile"
flutter clean
flutter pub get
flutter build apk --split-per-abi --release
```

### 3. Tìm file APK

```
d:\DO AN TOT NGHIEP\CODE\smart_farm_mobile\build\app\outputs\flutter-apk\
├── app-arm64-v8a-release.apk     ⭐ CÀI CÁI NÀY
├── app-armeabi-v7a-release.apk
└── app-x86_64-release.apk
```

---

## 🐛 XỬ LÝ LỖI

### Lỗi: "cmdline-tools component is missing"

**Giải pháp:** Cài Android SDK Command-line Tools trong Android Studio SDK Manager

---

### Lỗi: "Android license status unknown"

**Giải pháp:**
```powershell
flutter doctor --android-licenses
# Nhấn 'y' cho tất cả
```

---

### Lỗi: "JAVA_HOME not set"

**Giải pháp:** Android Studio đã cài sẵn Java, không cần set thêm.

Nếu vẫn lỗi:
```powershell
# Tìm Java path trong Android Studio
$javaPath = "C:\Program Files\Android\Android Studio\jbdk"
[System.Environment]::SetEnvironmentVariable('JAVA_HOME', $javaPath, 'Machine')
```

---

### Lỗi: Build failed "Gradle error"

**Giải pháp:**
```powershell
cd android
.\gradlew clean
cd ..
flutter clean
flutter pub get
flutter build apk --release
```

---

## 📦 SAU KHI BUILD XONG

### Copy APK sang điện thoại:

1. **Via USB:**
   - Kết nối điện thoại
   - Copy file APK vào Downloads

2. **Via Cloud:**
   - Upload lên Google Drive
   - Download trên điện thoại

3. **Via Email:**
   - Gửi file APK qua email
   - Mở trên điện thoại

### Cài đặt APK:

1. Mở file APK trên điện thoại
2. Settings → Security → **Install Unknown Apps** → Cho phép
3. Install
4. Open → Test app

---

## ⏱️ THỜI GIAN ƯỚC TÍNH

- **Cách 1 (Android Studio):**
  - Download: 10-30 phút (tùy tốc độ mạng)
  - Cài đặt: 5-10 phút
  - **Tổng: ~30-45 phút**

- **Cách 2 (SDK only):**
  - Download: 5-10 phút
  - Setup: 15-20 phút
  - **Tổng: ~25-30 phút**

---

## 💾 DUNG LƯỢNG YÊU CẦU

- **Android Studio:** ~5-7 GB
- **Command-line tools only:** ~2-3 GB

---

## 🎯 KHUYẾN NGHỊ

✅ **Dùng CÁCH 1** (Android Studio):
- Cài đặt dễ dàng hơn
- Có GUI để quản lý SDK
- Có Android Emulator (test trước khi build APK)
- Hỗ trợ đầy đủ Flutter development

---

## 📱 BUILD APK FINAL

Sau khi cài xong Android SDK:

```powershell
# Di chuyển vào project
cd "d:\DO AN TOT NGHIEP\CODE\smart_farm_mobile"

# Clean project
flutter clean

# Get dependencies
flutter pub get

# Build APK split (khuyến nghị)
flutter build apk --split-per-abi --release

# Hoặc build universal APK
flutter build apk --release
```

**File output:** `build\app\outputs\flutter-apk\app-arm64-v8a-release.apk`

**Kích thước:** ~20 MB

---

**Status:** 🔧 **Cần cài Android SDK trước khi build APK**

**Khuyến nghị:** Dùng **Cách 1** (Android Studio) - Đơn giản và đầy đủ nhất!
