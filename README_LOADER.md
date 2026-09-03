# 🚀 HƯỚNG DẪN SỬ DỤNG VEOFLOW PRO MAX (PATCHED LOADER)

Tài liệu hướng dẫn khởi động và sử dụng ứng dụng **VeoFlow Pro Max (VEO3PROTOOL)** với bản vá bản quyền vĩnh viễn (PREMIUM LIFETIME).

---

## 📌 BƯỚC 1: Chuẩn bị môi trường Python

- Ứng dụng và toàn bộ bytecode `.pyc` được biên dịch tương thích tối ưu với **Python 3.12**.
- Nếu máy bạn chưa có Python, bạn có thể cài đặt nhanh qua một trong hai cách:
  - **Cách 1 (Khuyên dùng - Cực nhanh):** Dùng trình quản lý `uv`:
    ```powershell
    powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
    uv python install 3.12
    ```
  - **Cách 2:** Tải bộ cài chính thức từ trang chủ [python.org/downloads](https://www.python.org/downloads/) (chọn bản **Python 3.12.x** và nhớ tích chọn `Add python.exe to PATH`).

---

## 📌 BƯỚC 2: Khởi động ứng dụng

Bạn có thể chạy ứng dụng theo một trong các cách sau:

### Cách 1: Bấm đúp chuột vào file `.bat` (Tiện lợi nhất)
- Tìm file **`start.bat`** tại thư mục `H:\veo-tool\start.bat`.
- Bấm đúp (Double-click) vào file `start.bat`.

### Cách 2: Chạy qua Terminal / Command Prompt
Mở CMD hoặc PowerShell tại thư mục `H:\veo-tool` và gõ lệnh:
```bash
python loader.py
```
*(Hoặc dùng uv nếu muốn chỉ định phiên bản: `uv run --python 3.12 loader.py`)*

---

## 🎯 LƯU Ý VỀ BẢN QUYỀN (LICENSE)

1. **Trạng thái kích hoạt**:
   - Ứng dụng sẽ tự động nạp với license **PREMIUM vĩnh viễn (LIFETIME)** mà không cần kết nối mạng đến server bản quyền.
   - Hạn sử dụng: **2099-12-31**.
   - Hạn mức (Quota): **999,999 lượt** (vô hạn, tự reset).
   - Tất cả tính năng cao cấp (`render_4k`, `master_ai`, `deep_prompt`, voice clone, batch prompt, v.v.) đều đã được mở khóa 100%.

2. **Cách kiểm tra trên giao diện**:
   - Sau khi giao diện mở lên, bạn vào tab **"Cài đặt" / "Bản quyền"** (License / Account Settings).
   - Thông tin hiển thị sẽ là:
     - **Gói:** `PREMIUM`
     - **Trạng thái:** `Đang hoạt động (Active)`
     - **Ngày hết hạn:** `2099-12-31`

---

## 🛠️ XỬ LÝ SỰ CỐ THƯỜNG GẶP (TROUBLESHOOTING)

- **Lỗi `bad magic number` khi chạy bằng Python khác**:
  - Nguyên nhân: Máy tính của bạn đang dùng mặc định Python 3.13 hoặc 3.11 trong PATH.
  - Giải pháp: File `loader.py` đã tích hợp sẵn tính năng tự động chuyển tiếp sang Python 3.12 trong máy. Nếu vẫn gặp lỗi, hãy chạy bằng:
    ```bash
    uv run --python 3.12 loader.py
    ```
- **Lỗi thiếu file hoặc thư mục**:
  - Đảm bảo giữ nguyên cấu trúc thư mục:
    - `H:\veo-tool\loader.py`
    - `H:\veo-tool\start.bat`
    - `H:\veo-tool\unpack-veotool\VEOFLOWPROMAX.exe_extracted`
    - `H:\veo-tool\decompiled\app_source`
- **Mã nguồn và cập nhật mới nhất**:
  - Toàn bộ commit và lịch sử patch được lưu tại repository:
    👉 **[https://github.com/DarkTutemi/veo-tool-decomplied](https://github.com/DarkTutemi/veo-tool-decomplied)**
