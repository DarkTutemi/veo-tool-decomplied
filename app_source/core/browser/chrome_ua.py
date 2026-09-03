"""
Decompiled / Reconstructed Module: core.browser.chrome_ua
Source PyC: chrome_ua.pyc

Docstring:
Auto-fetch latest stable Chrome version → build User-Agent động.

Chrome sync client-hints theo `--user-agent`, nên chỉ
cần UA khớp bản Chrome stable MỚI NHẤT là qua reCAPTCHA. Trước đây UA bị hardcode
(Chrome/148) → cũ dần → 403 PUBLIC_ERROR_UNUSUAL_ACTIVITY.

Module này lấy major version stable mới nhất từ Chrome Version History API,
cache ra đĩa (TTL) + refresh nền, fallback an toàn khi mất mạng.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Optional = typing.Optional
_VERSION_API = 'https://versionhistory.googleapis.com/v1/chrome/platforms/win64/channels/stable/versions'
_CACHE_TTL = 43200
_FETCH_TIMEOUT = 5.0
_FALLBACK_MAJOR = 149
_UA_TEMPLATE = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/{major}.0.0.0 Safari/537.36'
_lock = <unlocked _thread.lock object at 0x00000264D7686500>
_mem = {'major': None, 'fetched_at': 0.0}
_refreshing = False

# --- Top-Level Functions ---
def _cache_path() -> 'Optional[Path]':
    pass

def _load_disk() -> 'tuple[Optional[int], float]':
    pass

def _save_disk(major: 'int', ts: 'float') -> 'None':
    pass

def _fetch_latest_major(timeout: 'float' = 5.0) -> 'Optional[int]':
    pass

def _refresh_async() -> 'None':
    pass

def get_latest_chrome_major(block_first: 'bool' = False) -> 'int':
    pass

def get_latest_chrome_ua(block_first: 'bool' = False) -> 'str':
    pass
