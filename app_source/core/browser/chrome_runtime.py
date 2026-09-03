"""
Decompiled / Reconstructed Module: core.browser.chrome_runtime
Source PyC: chrome_runtime.pyc

Docstring:
Đảm bảo Google Chrome hệ thống có sẵn cho farm + login + scraper (channel="chrome").

Real Chrome THẬT của máy là engine DUY NHẤT. Mọi
browser launch dùng Playwright channel="chrome"; không bundle/tải Chromium nữa — máy
user chưa có Chrome thì cài qua winget. Wire ở bootstrap (app_controller resources stage).

    from core.browser.chrome_runtime import ensure_system_chrome
    ensure_system_chrome()   # idempotent, non-blocking; trả path hoặc None
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Optional = typing.Optional
_CHROME_PATHS = ('%ProgramFiles%\\Google\\Chrome\\Application\\chrome.exe', '%ProgramFiles(x86)%\\Google\\Chrome\\Application\\chrome.exe', '%LOCALAPPDATA%\\Google\\Chrome\\Application\\chrome.exe')
_checked = False
_resolved = None

# --- Top-Level Functions ---
def find_system_chrome() -> 'Optional[str]':
    pass

def _winget_install_chrome() -> 'bool':
    pass

def ensure_system_chrome() -> 'Optional[str]':
    pass
