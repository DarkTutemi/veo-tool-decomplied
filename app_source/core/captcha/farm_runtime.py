"""
Decompiled / Reconstructed Module: core.captcha.farm_runtime
Source PyC: farm_runtime.pyc

Docstring:
Labs Flow browser farm runtime.

One warm VeoFlowOS worker per account drives Labs token/session/Flow work. AI
Studio and Gemini Web deliberately remain in their dedicated persistent runtime;
live GenerateContent rejected the merged Flow BrowserContext. Engine = VeoFlowOS
stealth fork (headless=new), FORK-ONLY: the Chrome fallback is removed — the
farm never runs vanilla Chrome and no env var may downgrade it (see _resolve_engine_class
/ engine_state). Env knobs use ``VEOFLOW_FARM_*``.

The login-profile browser remains the headed/recovery cookie source. BrowserFarm
consumes its checkpoint but does not own either the login or AI Studio profile.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Awaitable = typing.Awaitable
Callable = typing.Callable
Dict = typing.Dict
Optional = typing.Optional
_MIN_REQUEST_GAP_SECONDS = 0.0
_SUBMIT_POLL_SECONDS = 2.0
_EXEC_STAGE_PREFIXES = ('get_browser', 'space_out_request', 'in_page_fetch', 'post_process', 'flow_ui')
_runtime = None
_lock = <unlocked _thread.lock object at 0x00000264DA5F0200>

# --- Class: BrowserFarm ---
class BrowserFarm:
    def __init__(self) -> 'None':
        pass

    def _on_ip_block_changed(self, blocked: 'bool') -> 'None':
        pass

    def _latch_headed_fallback(self, reason: 'str') -> 'bool':
        pass

    def _headed_presentation_flags(self) -> 'dict':
        pass

    def _latch_headed_desktop1(self, reason: 'str') -> 'bool':
        pass

    def _maybe_latch_desktop1(self, key: 'str', rotation: 'int') -> 'bool':
        pass

    def _reset_headed_desk1_burns(self, key: 'str') -> 'None':
        pass

    def _close_other_browsers_for_presentation_change(self, current_browser) -> 'None':
        """Retire headless siblings before the next headed desktop warmup."""
        pass

    def _drop_all_browsers(self) -> 'int':
        """Farm-loop implementation shared by sync and in-loop callers."""
        pass

    def drop_all_browsers_sync(self, timeout: 'float' = 30.0) -> 'int':
        pass

    def reset_seed_rotations(self) -> 'None':
        pass

    def _run_loop(self) -> 'None':
        pass

    def start_if_needed(self, headless='new') -> 'dict':
        pass

    def is_running(self) -> 'bool':
        pass

    def _submit(self, coro, timeout: 'float', timeout_account_id: 'str' = '', timeout_reason: 'str' = 'runtime_timeout', reset_on_timeout: 'bool' = True, stage_token: 'str' = ''):
        pass

    def _run_off_loop(self, fn, *args):
        pass

    def _resolve_account_off_loop(self, account_id: 'str') -> 'dict':
        pass

    def _get_browser(self, account_id: 'str', reason: 'str' = 'demand') -> 'BrowserAcquireResult':
        pass

    @staticmethod
    def _worker_process_alive(browser: 'BrowserWorkerBase') -> 'bool':
        pass

    def _new_flow_page(self, browser: 'BrowserWorkerBase'):
        pass

    @staticmethod
    def _bind_flow_page(browser: 'BrowserWorkerBase') -> 'None':
        pass

    def _ensure_flow_page(self, browser: 'BrowserWorkerBase'):
        pass

    def _run_flow_action(self, account_id: 'str', action: 'Callable[[object], Awaitable[Any]]') -> 'Any':
        pass

    def run_flow_sync(self, account_id: 'str', action: 'Callable[[object], Awaitable[Any]]', *, timeout: 'float' = 300.0) -> 'Any':
        pass

    def export_cookies_if_warm(self, account_id: 'str') -> 'list[dict]':
        """Read the warm Flow cookie jar without cold-starting a browser.

        This non-starting valve is important during first warmup: the worker
        still needs the headed-login/DB bootstrap cookies, so asking the farm to
        start itself from inside its own cookie injection would recurse."""
        pass

    def capture_account_session_sync(self, account_id: 'str', *, include_credits: 'bool' = True, timeout: 'float' = 45.0) -> 'dict':
        """Capture token and optional tier/credits from the warm Flow page.

        The returned cookie jar is diagnostic only. BrowserManager's stable login
        profile remains the authoritative full-cookie checkpoint."""
        pass

    def _ready_count(self, account_id: 'str') -> 'int':
        pass

    def _inflight_count(self, account_id: 'str') -> 'int':
        pass

    def _pooled_count(self, account_id: 'str') -> 'int':
        pass

    def _pool_snapshot(self, account_id: 'str') -> 'str':
        pass

    def _pop_ready_browser_unlocked(self, account_id: 'str') -> 'Optional[BrowserWorkerBase]':
        pass

    def _pop_standby(self, account_id: 'str') -> 'Optional[BrowserWorkerBase]':
        pass

    def _store_ready_browser(self, account_id: 'str', browser: 'BrowserWorkerBase', reason: 'str') -> 'None':
        pass

    def _wait_until_mature(self, browser: 'BrowserWorkerBase', account_id: 'str', reason: 'str') -> 'None':
        pass

    def _maybe_engage_warp(self, key: 'str', account: 'dict') -> 'None':
        pass

    def _record_http_outcome(self, key: 'str', status_code: 'int', error_text: 'str' = ''):
        pass

    def _handle_forbidden(self, key: 'str', account: 'dict', browser, result: 'dict', *, context: 'str') -> 'None':
        """Xử lý 403 TẬP TRUNG cho mọi đường gọi (direct fetch + Flow UI DOM).

        Quyết định của failure_policy được gắn vào result["forbidden_decision"]
        để tầng API-call/transport phía trên đồng bộ theo:
          - "hold"   → giữ browser; caller retry direct (×2) rồi DOM trên CÙNG browser
          - "rotate" → 403 liên tiếp lần 3 (thường là DOM cũng fail) → browser này đã
                       drop + warmup browser mới; job retry sau chạy trên browser mới
          - "dead"   → auth chết → caller dừng retry + bỏ DOM, dispatcher migrate account
        2xx (direct hay DOM thành công) reset bộ đếm — browser được giữ lại."""
        pass

    def _try_rotate_proxy_ip(self, account: 'dict') -> 'None':
        pass

    def _space_out_request(self, key: 'str') -> 'None':
        """Giãn cách generate call cùng account: chờ đủ _min_request_gap_seconds kể từ phát trước.

        Gọi TRONG per-account lock (đã serialize) → output 1 chạy ngay, output 2,3,4 mỗi cái
        chờ thêm gap. asyncio.sleep yield → account KHÁC không bị chặn (lock + timer riêng)."""
        pass

    def _create_warmed_browser_unlocked(self, account_id: 'str', reason: 'str') -> 'BrowserAcquireResult':
        pass

    def _execute_api_call(self, url: 'str', payload: 'dict', action: 'str', timeout_ms: 'int', account_id: 'str', stage_token: 'str' = '', request_type: 'str' = '') -> 'dict':
        pass

    def _execute_api_call_staged(self, url: 'str', payload: 'dict', action: 'str', timeout_ms: 'int', key: 'str', tok: 'str', request_type: 'str' = '') -> 'dict':
        pass

    def _fetch_media(self, url: 'str', account_id: 'str', timeout_ms: 'int') -> 'dict':
        """Fetch media bytes qua browser ĐANG warm của account (cookie sống).

        Khác _execute_api_call: KHÔNG warmup/tạo browser mới — thumbnail là
        best-effort, không đáng giá một lần warmup; thiếu browser → caller
        fallback httpx+cookie DB."""
        pass

    def fetch_media_sync(self, url: 'str', account_id: 'str' = None, timeout_ms: 'int' = 20000, **_) -> 'dict':
        pass

    def _get_tokens(self, account_id: 'str', action: 'str', timeout_ms: 'int') -> 'dict':
        pass

    def _execute_flow_edit_ui(self, kind: 'str', request: 'dict', timeout_ms: 'int', account_id: 'str', stage_token: 'str' = '') -> 'dict':
        pass

    def _execute_flow_edit_ui_staged(self, kind: 'str', request: 'dict', timeout_ms: 'int', key: 'str', tok: 'str') -> 'dict':
        pass

    def _drop_browser(self, browser: 'BrowserWorkerBase') -> 'None':
        pass

    def _evict_account_browsers(self, account_id: 'str', reason: 'str') -> 'dict':
        pass

    def _reset_account_browsers(self, account_id: 'str', reason: 'str') -> 'dict':
        pass

    def _await_warmup(self, account_id: 'str') -> 'None':
        pass

    def _schedule_warmup(self, account_id: 'str', reason: 'str' = '') -> 'None':
        pass

    def _warmup_replacement(self, account_id: 'str', reason: 'str' = '') -> 'None':
        pass

    def prewarm_account_sync(self, account_id: 'str', reason: 'str' = 'prewarm') -> 'dict':
        pass

    def reset_account_sync(self, account_id: 'str', reason: 'str' = 'account_reset') -> 'dict':
        pass

    def evict_account_sync(self, account_id: 'str', reason: 'str' = 'account_unavailable') -> 'dict':
        pass

    def evict_account_async(self, account_id: 'str', reason: 'str' = 'account_unavailable') -> 'dict':
        pass

    def request_account_reset(self, account_id: 'str', reason: 'str' = 'account_reset') -> 'dict':
        pass

    def execute_api_call_sync(self, url: 'str', payload: 'dict', action: 'str', timeout_ms: 'int', account_id: 'str', request_type: 'str' = '', **_) -> 'dict':
        pass

    def _submit_flow_edit(self, kind: 'str', request: 'dict', timeout_ms: 'int', account_id: 'str', timeout_reason: 'str') -> 'dict':
        pass

    def execute_flow_edit_extend_sync(self, request: 'dict', timeout_ms: 'int' = 120000, account_id: 'str' = None, **_) -> 'dict':
        pass

    def execute_flow_edit_upscale_sync(self, request: 'dict', timeout_ms: 'int' = 120000, account_id: 'str' = None, **_) -> 'dict':
        pass

    def execute_flow_create_sync(self, request: 'dict', timeout_ms: 'int' = 120000, account_id: 'str' = None, **_) -> 'dict':
        pass

    def get_tokens_sync(self, account_id: 'str' = None, action: 'str' = None, timeout_ms: 'int' = 60000, **_) -> 'dict':
        pass

    def shutdown_sync(self) -> 'None':
        pass


# --- Top-Level Functions ---
def _resolve_engine_class():
    pass

def _surface_page_alive(page: 'object') -> 'bool':
    pass

def _resolve_exact_capture_account(identifier: 'str') -> 'dict':
    pass

def _getenv(name: 'str', default: 'str' = '') -> 'str':
    pass

def _env_float(name: 'str', default: 'float') -> 'float':
    pass

def _env_int(name: 'str', default: 'int', minimum: 'int' = 1, maximum: 'int' = 8) -> 'int':
    pass

def _env_ratio(name: 'str', default: 'float', minimum: 'float' = 0.0, maximum: 'float' = 1.0) -> 'float':
    pass

def _is_http_403_result(result: 'dict | None') -> 'bool':
    pass

def _resolve_farm_headless(_requested='new'):
    pass

def get_browser_farm() -> 'BrowserFarm':
    pass
