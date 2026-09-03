"""
Decompiled / Reconstructed Module: core.labs_api.poll
Source PyC: poll.pyc

Docstring:
core/labs_api/poll.py — poll generation status + download finished videos.

`poll_and_download` is the unified poll loop for every generation type (text /
image / extend / multi-asset / upscale): batch-poll pending items until each is
SUCCESSFUL/FAILED, then download the finished videos. `download_video` fetches a
single video URL with proxy/cookies, integrity-checks it, and strips the
watermark.

http_requests (the proxy-aware HTTP wrapper) and VEO3GenerationError still live
in core.api_client / core.exceptions during the additive refactor and are
imported from there.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Callable = typing.Callable
Dict = typing.Dict
List = typing.List
Optional = typing.Optional
_NON_MEDIA_CONTENT_TYPES = ('text/', 'application/json', 'application/xml')
_MAX_CONSECUTIVE_NONE = 3
_DOWNLOAD_RETRIES = 4
_DOWNLOAD_BACKOFF_S = (3, 8, 20)

# --- Top-Level Functions ---
def _safe_log(method: 'str', *args, **kwargs) -> 'None':
    pass

def _record_video_stat() -> 'None':
    pass

def _report_download_auth_failure(account_email: 'str', detail: 'str' = '') -> 'None':
    pass

def _fetch_to_file(video_url: 'str', dest: 'str', account_email: 'Optional[str]', cookies: 'Optional[Dict[str, str]]') -> 'tuple[str, int, int]':
    pass

def _download_incomplete(content_type: 'str', written: 'int', expected: 'int') -> 'str':
    """'' = tải XONG, dùng được. Ngược lại trả LÝ DO (để log).

    CHỈ dùng lời khai của SERVER. KHÔNG mở file ra soi, KHÔNG ffprobe, KHÔNG ngưỡng
    size/duration. Đây là toàn bộ phần "kiểm tra" của trình tải — cố tình nhỏ như vậy,
    vì mọi luật phán đoán nội dung từng đặt ở đây đều có ngày giết oan video thật.

      1. Content-Type — server bảo đây là HTML/JSON → ta nhận được TRANG LỖI, không
         phải media (vd 401 "No session found" trả 200 kèm body JSON).
      2. Content-Length — server bảo sẽ gửi N byte mà ta chỉ nhận M < N → stream ĐỨT.
         `iter_content` không raise khi đứt giữa chừng, nên đây là cách DUY NHẤT biết.
         Server không khai Content-Length (chunked) → không có gì để đối chiếu → NHẬN,
         y như curl/trình duyệt. Không đoán."""
    pass

def _versioned_path(folder: 'str', filename: 'str') -> 'str':
    pass

def download_video(video_url: 'str', filename: 'str', folder: 'str' = 'video', account_email: 'Optional[str]' = None, overwrite: 'bool' = False, watermark_model: 'Optional[str]' = None, watermark_target: 'Optional[str]' = None, fail_reason: 'Optional[list]' = None) -> 'Optional[str]':
    pass

def _retry_download(video_url: 'str', file_path: 'str', account_email: 'Optional[str]', cookies: 'Optional[Dict[str, str]]') -> 'bool':
    pass

def _strip_watermark(file_path: 'str', model: 'Optional[str]', target: 'Optional[str]') -> 'None':
    pass

def download_video_from_base64(video_data: 'str', output_path: 'str') -> 'bool':
    pass

def _normalize_operations(operations: 'List[Dict]', has_media_items: 'bool') -> 'List[Dict]':
    pass

def _poll_once(*, media_items, normalized_ops, pending_indices, account_name, account_email, main_window):
    pass

def _is_empty_response(status_result) -> 'bool':
    pass

def _apply_status(status_result, pending_indices, completed_ops) -> 'None':
    """Record SUCCESSFUL items into completed_ops; raise on FAILED/missing-audio."""
    pass

def poll_and_download(operations: 'List[Dict]', account_name: 'str', output_folder: 'str', filename: 'str', account_email: 'Optional[str]' = None, timeout: 'int' = 300, interval: 'int' = 10, stop_check: 'Optional[Callable[[], bool]]' = None, progress_cb: 'Optional[Callable[[str, int, int], None]]' = None, skip_download: 'bool' = False, main_window=None, media_items: 'Optional[List[Dict]]' = None, on_poll_start: 'Optional[Callable[[], None]]' = None, overwrite: 'bool' = False, heartbeat_cb: 'Optional[Callable[[], None]]' = None, watermark_model: 'Optional[str]' = None, watermark_target: 'Optional[str]' = None, prewarm_thumbnail: 'bool' = True) -> 'Dict[str, Any]':
    """Poll until every item is SUCCESSFUL, then download (unless skip_download).

    Supports both new media[] and legacy operations[] polling. Returns
    {video_paths, media_ids, thumbnail_urls, video_urls, workflow_id}. Raises
    VEO3GenerationError on FAILED status, lost responses, auth expiry, or timeout."""
    pass

def _download_completed(completed_ops, total, filename, output_folder, account_email, skip_download, overwrite, watermark_model, watermark_target, prewarm_thumbnail: 'bool' = True) -> 'Dict[str, Any]':
    pass
