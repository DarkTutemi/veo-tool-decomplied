# TỔNG HỢP VÀ CẤU TRÚC TOÀN BỘ TOOL VEOFLOW PRO MAX (MASTERTOOL V3)

Tài liệu này ghi chú chi tiết kết quả giải nén (unpack), decompile và phân tích toàn diện mã nguồn của tool **VEOFLOW PRO MAX** (phiên bản đóng gói installer: **MASTERTOOLV3**).

---

## 1. TỔNG QUAN CÁC THÀNH PHẦN ĐÃ UNPACK

Toàn bộ tool đã được trích xuất, bóc tách và tái tạo thành công vào thư mục `decompiled/`:

```
H:\veo-tool\decompiled\
├── app_source\           # 691 file mã nguồn Python (.py) đã tái tạo toàn bộ module
│   ├── main.py           # Entry point chính của ứng dụng
│   ├── build_validation.py # Script kiểm tra môi trường, manifest, runtime resources
│   ├── api\              # Global APIs (media_api, ...)
│   ├── application\      # Các service tầng ứng dụng (account, batch, api_keys, ...)
│   ├── core\             # Nhân xử lý logic trung tâm, scheduling, task queue (193 files)
│   ├── services\         # Video pipeline, browser automation, AI prompt, audio (333 files)
│   ├── utils\            # Tiện ích: logging, crash minidump, GPU, video merger, DPAPI (44 files)
│   ├── qml_app\          # Bridge liên kết Python với giao diện QML (44 files)
│   ├── update\           # Hệ thống Auto-updater
│   └── license\          # Quản lý license / bản quyền
├── frontend_qml\         # Toàn bộ mã nguồn giao diện QML (100% mã nguồn gốc)
│   ├── App.qml           # Giao diện chính (~115 KB)
│   ├── screens\          # Toàn bộ màn hình chức năng (WorkPanel, Research, MasterPrompt, AccountSettings...)
│   ├── components\       # Các component UI tùy biến
│   ├── dialogs\          # Hộp thoại popup
│   ├── automation_center/# QML cho Automation Center
│   └── theme\            # Theme màu sắc, layout, stylesheet
└── chrome_extension\     # Tiện ích mở rộng trình duyệt (Sidepanel / Web Extension)
    ├── manifest.json     # Extension Manifest V3
    ├── app.js            # Logic frontend extension (Preact, 74 KB)
    ├── app.css           # Giao diện sidepanel
    ├── content_script.js # Script tiêm vào trang web sản phẩm / affiliate
    └── side_panel.js     # Controller cho Chrome side panel
```

---

## 2. CHI TIẾT CÁC TẦNG HỆ THỐNG

### 2.1. Tầng Giao Diện (Frontend)
- **Công nghệ**: Qt Quick / QML (PySide6 6.11.1).
- **Mã nguồn**: 100% rõ ràng (plain text), nằm tại [decompiled/frontend_qml](file:///h:/veo-tool/decompiled/frontend_qml) (và [H:\veo-tool\qml](file:///h:/veo-tool/qml)).
- **Các màn hình chính**:
  - `WorkPanelScreen.qml` (214 KB): Bảng điều khiển tác vụ render/sinh video.
  - `ResearchScreen.qml` (119 KB): Nghiên cứu từ khóa, sản phẩm, xu hướng.
  - `MasterPromptScreen.qml` (110 KB): Bộ tạo và tinh chỉnh prompt AI cho video.
  - `AccountSettingsScreen.qml` (99 KB): Quản lý tài khoản Google/Veo, cookie, proxy xoay vòng.
  - `AudioLibraryScreen.qml` (17 KB): Thư viện âm thanh, nhạc nền, lồng tiếng.
  - `JobPanelStudyScreen.qml` (17 KB): Giám sát tiến trình job, queue.
  - `TimeMachineScreen.qml` (11 KB): Lịch sử và khôi phục tác vụ.

### 2.2. Tiện Ích Trình Duyệt (Chrome Extension)
- Nằm tại [decompiled/chrome_extension](file:///h:/veo-tool/decompiled/chrome_extension).
- Dùng để tích hợp với trình duyệt, trích xuất dữ liệu sản phẩm từ các sàn thương mại điện tử / affiliate và gửi trực tiếp về app VeoFlow.

### 2.3. Tầng Logic & Backend Python
- **Môi trường**: Python 3.12 (64-bit).
- **Trình đóng gói**: PyInstaller (`VEOFLOWPROMAX.exe`).
- **Archive PYZ**: Đã giải nén toàn bộ 4.461 file `.pyc` tại [unpack-veotool/VEOFLOWPROMAX.exe_extracted/PYZ.pyz_extracted](file:///h:/veo-tool/unpack-veotool/VEOFLOWPROMAX.exe_extracted/PYZ.pyz_extracted).
  - 3.744 file là thư viện bên thứ ba (playwright, requests, yt_dlp, fastapi, uvicorn, numpy, fontTools...).
  - 692 file là mã nguồn của tác giả (được bảo vệ bằng **PyArmor 8+ BCC mode**, runtime: `pyarmor_runtime_015154`).
- **Trạng thái decompile**:
  - Đã hook thành công runtime `pyarmor_runtime_015154` với Python 3.12 để giải mã bộ nhớ.
  - Đã tái cấu trúc thành công **691 file mã nguồn `.py`** tại [decompiled/app_source](file:///h:/veo-tool/decompiled/app_source), khôi phục đầy đủ:
    - Tất cả Class, cấu trúc phân cấp kế thừa.
    - Tất cả Method và Function với đầy đủ type annotation, đối số mặc định (`inspect.signature`).
    - Tất cả Docstrings, hằng số toàn cục, đường dẫn database (`veoflow.db`), API contract actions, endpoints.
    - File `build_validation.py` được dịch ngược hoàn chỉnh mã bytecode bằng `pycdc`.

---

## 3. CÁC THƯ MỤC VÀ TÀI NGUYÊN NGUYÊN BẢN

1. **Installer gốc**: Bộ cài Inno Setup (`MASTERTOOLV3`) được cài đặt trực tiếp vào `H:\veo-tool` (ghi nhận 5.662 file trong `uninstall/unins000.dat`).
2. **PyInstaller Raw**: Nằm tại `H:\veo-tool\unpack-veotool\VEOFLOWPROMAX.exe_extracted\`.
3. **Mã nguồn đã giải nén hoàn chỉnh**: Nằm tại `H:\veo-tool\decompiled\`.
