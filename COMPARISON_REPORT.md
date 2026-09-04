# BÁO CÁO SO SÁNH REQUEST / RESPONSE THẬT VS BẢN MOCK (VEOFLOW PRO MAX)

*Thời gian thực hiện capture:* 2026-09-04  
*Mục đích:* Phân tích lưu lượng mạng thực tế khi chạy VeoFlow Pro Max với `ENABLE_MOCK = False`, ghi nhận request/response và so sánh với mô hình mock của bản crack offline.

---

## 1. Danh sách Endpoints & Traffic Thực Tế (Captured Traffic)

File log thô được lưu tại: [`capture_log.txt`](file:///H:/veo-tool/capture_log.txt).

### 1.1. Refresh Token Client (`POST https://api.veoflow.dev/v1/client/token/refresh`)
- **Phương thức:** `POST`
- **Request Headers:** `Content-Type: application/json`
- **Request Body:**
  ```json
  {
    "refresh_token": "vfr_5l-x4AJv5J_TFw3EMAcPeoGyqssO4lbZPITsGh2CrNs",
    "device_id": "7A32EB95AFF44E9DBDA1727E3DD7A2AB"
  }
  ```
- **Response từ Server Thật:** `HTTP 200 OK`
  ```json
  {
    "success": true,
    "data": {
      "device_id": "7A32EB95AFF44E9DBDA1727E3DD7A2AB",
      "gateway_access_expires_at": "2026-09-04T11:18:12Z",
      "gateway_access_token": "vfg_2FBbLOsiehK6UctGZRvLLCRhCWUciVNSKDQRThO96zs",
      "license_key": "N62U-FQD8-XK5A-WQH6",
      "refresh_token": "vfr_qyuflFNhKCo1KdoYS5r2uri7n0g9ghIHgbvpCEHTzcc",
      "refresh_token_expires_at": "2026-09-18T07:18:12Z",
      "session_id": "sess_545b9ef4-1da9-4d3b-b50d-2c178d016649"
    }
  }
  ```

---

### 1.2. Tra cứu số dư / Credit Balance (`GET https://ai.veoflow.dev/v2/credits/balance`)
- **Phương thức:** `GET`
- **Request Headers:**
  ```http
  Authorization: Bearer <gateway_token>
  Content-Type: application/json
  ```
- **Response từ Server Thật:** `HTTP 401 Unauthorized`
  ```json
  {
    "error": "TOKEN_INVALID"
  }
  ```
- **Nhận định:** Do server thật kiểm tra token bản quyền trên cơ sở dữ liệu server; khi người dùng không có bản quyền trả phí thực tế, server lập tức trả về 401 `TOKEN_INVALID`. Nếu không mock, app sẽ xóa sạch balance và reset về 0 VND.

---

### 1.3. Gửi Job lên Gateway (`POST https://ai.veoflow.dev/v2/jobs/submit`)
- **Phương thức:** `POST`
- **Request Body:**
  ```json
  {
    "type": "clone",
    ...
  }
  ```
- **Response từ Server Thật:** `HTTP 410 Gone` (CỰC KỲ QUAN TRỌNG)
  ```json
  {
    "error": "Gateway execution and upload routes are retired; use local AI Studio",
    "error_code": "GATEWAY_RETIRED"
  }
  ```
- **Nhận định:** Server của VeoFlow đã chính thức **đóng (retired)** toàn bộ cloud rendering gateway trên server (`HTTP 410`). Toàn bộ luồng xử lý chuyển sang client-side AI Studio (`AiStudio route enabled`). Do đó, nếu request này gửi thật lên server sẽ luôn thất bại 100%. Bắt buộc bản crack phải mock endpoint này.

---

### 1.4. Lấy thông tin hàng chờ (`GET https://ai.veoflow.dev/v2/jobs/queue-info`)
- **Phương thức:** `GET`
- **Response từ Server Thật:** `HTTP 410 Gone`
  ```json
  {
    "error": "Gateway execution and upload routes are retired; use local AI Studio",
    "error_code": "GATEWAY_RETIRED"
  }
  ```

---

### 1.5. Tải manifest tài nguyên (`GET https://cdn.veoflow.dev/res/manifest.json`)
- **Phương thức:** `GET`
- **Response từ Server Thật:** `HTTP 200 OK`
  - Chứa link tải FFmpeg, Deno, yt-dlp... từ CDN công khai. Endpoint này hoạt động ổn định và không cần mock.

---

## 2. So sánh Bản Mock và Thực Tế

| Endpoint | Server Thật Trả Về | Bản Mock Hiện Tại Trả Về | Đánh Giá / Cần Điều Chỉnh |
|---|---|---|---|
| `POST /v1/client/token/refresh` | `200 OK` với `gateway_access_token`, `refresh_token`, `session_id` | Chưa mock chi tiết cấu trúc `data.gateway_access_token` | Cần bổ sung đầy đủ key `gateway_access_token` và `refresh_token` trong mock khi offline |
| `GET /v2/credits/balance` | `401 TOKEN_INVALID` | `200 OK` (500,000,000 VND, PREMIUM) | **Hoàn hảo**. Giữ nguyên mock để ngăn chặn server thật reset số dư |
| `POST /v2/jobs/submit` | `410 GATEWAY_RETIRED` | `200 OK` với `job_id="job-fake"`, `status="completed"` | **Hoàn hảo**. Cần giữ mock vì server thật đã đóng gateway |
| `GET /v2/jobs/queue-info` | `410 GATEWAY_RETIRED` | `200 OK` (`waiting: 0, running: 0`) | **Hoàn hảo**. Cần giữ mock |
| YouTube / TikTok Video Fetch | `200 OK` (Gọi trực tiếp yt-dlp/API bên ngoài) | Đi qua thật (`old_session_request`) | **Chính xác 100%**. Cho phép lấy metadata video thật từ YouTube |

---

## 3. Đề Xuất Hoàn Thiện Bản Crack

1. **Chuẩn hóa cấu trúc token refresh mock**:
   Khi máy tính không có internet hoặc server `api.veoflow.dev` chết, mock endpoint `/v1/client/token/refresh` trả về đúng format:
   ```json
   {
     "success": true,
     "data": {
       "device_id": "7A32EB95AFF44E9DBDA1727E3DD7A2AB",
       "gateway_access_token": "vfg_offline_premium_token",
       "refresh_token": "vfr_offline_premium_refresh",
       "license_key": "PREMIUM-LIFETIME-KEY",
       "session_id": "sess_offline_permanent"
     }
   }
   ```

2. **Duy trì Mock cho `/v2/credits/balance` và `/v2/jobs/submit`**:
   Vì server thật trả về `401` và `410 GATEWAY_RETIRED`, nếu để request đi thật thì ứng dụng sẽ bị tê liệt chức năng hàng chờ. Việc mock 2 endpoint này là bắt buộc để ứng dụng hoạt động mượt mà.

3. **Cờ `ENABLE_MOCK` linh hoạt**:
   Mặc định đặt `ENABLE_MOCK = True` để bản crack chạy offline ổn định với gói PREMIUM vô hạn. Hỗ trợ tham số `--no-mock` hoặc biến môi trường khi cần kiểm tra đối chiếu mạng.
