# PHÂN TÍCH CHUYÊN SÂU & CHI TIẾT CÁC MODULE CỐT LÕI (VEOFLOW PRO MAX)

Tài liệu này cung cấp kết quả phân tích kỹ thuật chi tiết, bóc tách cấu trúc mã nguồn và cơ chế hoạt động bên trong của các bộ module:
- `main.py` (Entry point ứng dụng)
- `build_validation.py` (Hệ thống kiểm tra tính toàn vẹn bản dựng)
- `license/` (Xác thực bản quyền, vân tay phần cứng, mã hóa cache)
- `update/` (Tự động cập nhật, resume download, atomic swap)
- `utils/` (Mã hóa DPAPI/Fernet, quản lý tiến trình, crash dump, telemetry)
- `qml_app/` (Cầu nối điều khiển QML, view models, controllers)

---

## 1. ENTRY POINT: `main.py`

### 1.1. Luồng khởi động (Startup Flow)
1. **Khởi tạo môi trường & Crash Handler**:
   - Kích hoạt `faulthandler` ghi log vào `%APPDATA%\VEO3_Generator_Pro\logs\faulthandler.log`.
   - Bật hệ thống chẩn đoán: `minidump: True`, `crash_logger: True`, `breadcrumbs: True`.
   - Thiết lập cấu hình đồ họa: `4x MSAA` qua backend Qt auto-select (D3D11 với WARP fallback).
   - Thiết lập SSL qua `truststore` (sử dụng Windows Certificate Store hệ thống).
2. **Quản lý Process con (Job Object & Popen Sandbox)**:
   - Khởi tạo Windows Job Object: `VeoFlow_Job_<PID>` — đảm bảo mọi process con (Chromium, FFmpeg, Deno) sẽ tự động bị tiêu diệt ngay lập tức khi ứng dụng chính tắt.
   - Patch `subprocess.Popen` với flag `CREATE_NO_WINDOW + DEVNULL` (trừ Playwright browser).
3. **Kiểm tra Single Instance (`_check_single_instance`)**:
   - Sử dụng Mutex / Named Lock trên Windows để ngăn chặn chạy nhiều instance xung đột. Đăng ký `atexit.register(cleanup_instance_lock)`.
4. **Nạp đường dẫn nhị phân (`_add_resources_bin_to_path`)**:
   - Tự động gắn `resources/bin` (nơi chứa FFmpeg, FFprobe, Deno) vào biến môi trường `PATH`.
5. **Nạp License Cache từ máy (`_load_qml_license_info`)**:
   - Đọc dữ liệu từ `JSONLicenseCacheManager` để lấy tier (FREE / PRO / PREMIUM) và quota đã lưu trước đó.
6. **Khởi tạo Nhân ứng dụng (`_init_core`)**:
   - Nạp trạng thái tài khoản `AccountManager`.
   - Cài đặt `SmartDispatcherPort` (phục vụ điều phối tác vụ render video `SmartJobDispatcher`).
   - Cài đặt `Core-backed headless job store adapter`.
7. **Tác vụ nền sau khởi động (`_post_init_background`)**:
   - Kích hoạt `SessionKeeper` (delay 1.5s, lặp lại mỗi 1800s / 30 phút) để tự động làm mới token và cookie Google/Veo.
8. **Khởi chạy giao diện QML (`_run_qml_mode`)**:
   - Nạp `qml_app.main`, khởi tạo `QGuiApplication` và `QQmlApplicationEngine`.
   - Đăng ký toàn bộ controller tree vào QML context.

---

## 2. KIỂM SOÁT TOÀN VẸN: `build_validation.py`

File này chịu trách nhiệm kiểm tra sức khỏe của bản cài đặt và quá trình đóng gói:
- **Kiểm tra file nhị phân (Binaries Check)**:
  - Bắt buộc: `ffmpeg.exe`, `ffprobe.exe`, `deno.exe`, `updater.exe`.
- **Kiểm tra Driver Playwright**:
  - Xác nhận toàn bộ node / browser bundle trong `playwright/driver/`.
- **Kiểm tra Runtime PyArmor**:
  - Tìm kiếm và xác thực file `pyarmor_runtime_*/pyarmor_runtime.pyd`.
- **Kiểm tra Tài nguyên Động**:
  - Đọc `resources/runtime_resources.json` để xác minh mã tool và version của ffmpeg, deno, browser.
- **Các cờ dòng lệnh CLI**:
  - `--runtime-self-check`: Xuất báo cáo trạng thái hệ thống dạng JSON.
  - `--dist-check`: Kiểm tra bundle xuất bản `dist/VEOFLOWPROMAX`.
  - `--ship-ready-check`: Kiểm tra checksum mã SHA-256 đối chiếu với file `Output/SHIP_READY.json`.

---

## 3. BỘ MODULE BẢN QUYỀN: `license/` (7 files)

### 3.1. Các Server API Bản quyền
- **Main Server URL**: `https://api.veoflow.dev`
- **Fallback URL**: `https://veoflow.dev/backend-api`
- **Tool Code**: `VEO3PROTOOL`
- **Offline Grace Period**: 7 ngày mặc định (tối đa 30 ngày).

### 3.2. Chi tiết từng module
1. **`license_manager.py`**:
   - **`LicenseManager`**: Lớp điều khiển trung tâm (Singleton).
     - Quản lý Quota, Tier (`FREE`, `PRO`, `PREMIUM`).
     - Xác thực online: `verify_license(timeout=15)`.
     - Nạp cấu hình Gemini API: `gemini_api_config()`.
     - Quản lý API Key người dùng: `get_api_keys()`, `save_api_key(provider, api_key)`.
     - Báo cáo lỗi & telemetry: `upload_crash_report()`, `upload_telemetry()`.
     - Mua feature / nạp tiền: `create_credit_topup_order()`, `buy_feature_days()`.
   - **`FeatureGate`**: Kiểm soát quyền truy cập từng tính năng:
     - Các trạng thái feature: `is_free()`, `is_demo()`, `is_maintenance()`, `is_lifetime()`.
     - Khi chưa mua: raise `PermissionError("Feature '<name>' chưa được mua. Truy cập veoflow.dev")`.
2. **`hardware_key_derivation.py`**:
   - Tạo mã định danh máy (`device_id`) và vân tay phần cứng (`fingerprint`):
     - Windows `MachineGuid`: Đọc registry `HKLM\SOFTWARE\Microsoft\Cryptography\MachineGuid`.
     - Windows `ProductId`: Đọc registry `HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProductId`.
     - Windows SID: Đọc SID người dùng (`S-1-5-21-...`).
     - BIOS / Baseboard / Disk Serial / CPU ID: Thu thập qua lệnh PowerShell `Get-CimInstance`.
     - Hash toàn bộ thông tin bằng SHA-256 để tạo thành `device_fingerprint`.
3. **`main_api_client.py` & `main_license_client.py`**:
   - Client HTTP xử lý bắt tay bảo mật, ký HMAC, refresh token, gửi telemetry và xác thực key với máy chủ `api.veoflow.dev`.
4. **`secure_memory.py`**:
   - Cơ chế bảo vệ key và token nhạy cảm trong bộ nhớ RAM, hạn chế bị quét dump bộ nhớ.
5. **`unified_license_client.py`**:
   - Lớp trừu tượng hợp nhất các giao thức gọi API cấp phép.

---

## 4. BỘ MODULE TỰ ĐỘNG CẬP NHẬT: `update/` (2 files)

1. **`auto_updater.py`**:
   - **`UpdateChecker(QThread)`**: Chạy ngầm định kỳ kiểm tra phiên bản mới từ server qua `LicenseManager.check_version()`.
   - **`UnifiedDownloader(QThread)`**:
     - Tải gói update `.zip` theo cơ chế chia nhỏ chunk (`CHUNK_SIZE = 512 KB`).
     - Hỗ trợ HTTP Range-header để tiếp tục tải (resume) khi rớt mạng, lưu tạm tại file đuôi `.part`.
     - Xác thực toàn vẹn bằng SHA-256 trước khi đổi tên file chính thức.
   - **`UpdateStateManager`**: Ghi nhớ trạng thái tải qua các lần khởi động lại app.
   - **`apply_update()`**: Giải nén gói zip và thực thi `updater.exe` để thay thế file binary đang chạy.
2. **`__init__.py`**: Export các hàm điều khiển cập nhật.

---

## 5. BỘ MODULE TIỆN ÍCH HỆ THỐNG: `utils/` (44 files)

### 5.1. Mã hóa & Bảo mật
- **`dpapi_encryption.py`**:
  - Sử dụng thuật toán **Fernet (AES-128-CBC + HMAC-SHA256)**.
  - Secret key gốc: `b'VEO3_LICENSE_CACHE_2026_FERNET_KEY'`.
  - Khóa mã hóa được dẫn xuất từ: `MachineGuid | platform.node() | platform.machine() | VEO3_LICENSE_CACHE_2026_FERNET_KEY`.
- **`env_gate.py` & `production_mode.py`**: Kiểm soát cờ chế độ chạy (Development vs Production).

### 5.2. Chẩn đoán & Giám sát Sự cố (Crash Diagnostics)
- **`crash_logger.py` & `crash_breadcrumbs.py`**: Ghi vết từng thao tác click, chuyển tab, gọi API để tái dựng kịch bản lỗi khi app gặp crash.
- **`crash_minidump.py`**: Tạo file dump hệ thống Windows (`.dmp`) khi gặp lỗi nặng cấp độ C/C++.
- **`forensic_logger.py` & `unified_logger.py`**: Hệ thống logging đa tầng.
- **`telemetry_reporter.py` & `telemetry_uploader.py`**: Đóng gói và gửi số liệu sử dụng, lỗi về máy chủ.

### 5.3. Xử lý Video & Đồ họa
- **`video_merger.py`**: Kết hợp các phân đoạn video bằng FFmpeg.
- **`video_frame_extractor.py`**: Trích xuất khung hình và thumbnail bằng OpenCV / Skia.
- **`opencv_image_io.py`**: Tối ưu hóa đọc ghi ảnh định dạng WebP, PNG, JPG.
- **`gpu_backend.py`**: Tự động phát hiện GPU (NVIDIA / AMD / Intel) để kích hoạt tăng tốc phần cứng Direct3D 11.

### 5.4. Kiểm soát Tiến trình
- **`win_job_object.py`**: Quản lý Windows Job Object để tránh rò rỉ tiến trình orphan.
- **`single_instance_manager.py`**: Đảm bảo an toàn ghi cơ sở dữ liệu SQLite `veoflow.db`.

---

## 6. BỘ MODULE CẦU NỐI GIAO DIỆN: `qml_app/` (44 files)

Đây là lớp kiến trúc Controller - ViewModel kết nối giữa Python và các màn hình QML:

1. **`AccountSettingsController`**:
   - Kết nối màn hình cài đặt tài khoản (`AccountSettingsScreen.qml`).
   - Quản lý danh sách tài khoản Google, proxy (xoay IP, test live/dead), API keys (Gemini, OpenAI, Claude).
2. **`HomeController`**:
   - Kết nối trang chủ (`HomeScreen.qml`), hiển thị thông báo, banner, tài khoản hoạt động và quota hiện tại.
3. **`MasterController` & `MasterOptionsController`**:
   - Điều khiển màn hình `MasterPromptScreen.qml` — tạo kịch bản video, cấu hình khung hình, tỷ lệ, phong cách nghệ thuật.
4. **`WorkPanelController`**:
   - Điều khiển màn hình `WorkPanelScreen.qml` — quản lý hàng đợi sinh video (render queue), danh sách tiến trình, xem trước video.
5. **`ResearchController`**:
   - Điều khiển màn hình `ResearchScreen.qml` — nghiên cứu xu hướng và phân tích từ khóa.
6. **`VoiceController` & `MasterVoiceController`**:
   - Điều khiển chuyển văn bản thành giọng nói (TTS) và thư viện âm thanh (`AudioLibraryScreen.qml`).
7. **`TimemachineController`**:
   - Lịch sử tạo video và khôi phục checkpoint dự án.
8. **`AutomationCenterHost`**:
   - Quản lý các kịch bản tự động hóa hàng loạt.

---

## 7. ĐÁNH GIÁ CƠ CHẾ BẢN QUYỀN & KHẢ NĂNG BYPASS

Dựa trên toàn bộ mã nguồn đã phân tích:
1. **Toàn bộ quyết định cấp quyền đều nằm tại `LicenseManager` và `FeatureGate`**:
   - `FeatureGate.has(code)` kiểm tra danh sách feature codes trả về từ server.
   - Nếu `LicenseManager.verify_license()` trả về `(True, data)` với tier là `'PREMIUM'` và danh sách `feature_codes` chứa toàn bộ tính năng, tool sẽ mở khóa 100% chức năng.
2. **File cache bản quyền**:
   - File cache được lưu cục bộ và mã hóa bằng Fernet với key có thể tính toán trực tiếp từ thông tin máy và secret `VEO3_LICENSE_CACHE_2026_FERNET_KEY`.
3. **Máy chủ cấp phép**:
   - Địa chỉ xác thực: `https://api.veoflow.dev`.
   - Có thể điều hướng domain này về local mock server (Localhost) để trả về payload xác thực hợp lệ cho bất kỳ mã máy nào.
