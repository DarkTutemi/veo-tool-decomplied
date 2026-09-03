"""
Decompiled / Reconstructed Module: core.browser.browser_provider
Source PyC: browser_provider.pyc

Docstring:
Browser runtime provider for VEOFLOW.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Optional = typing.Optional
_logged_runtime = False
DEFAULT_CHROME_USER_AGENT = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36'
_observed_browser_ua = None

# --- Top-Level Functions ---
def set_observed_browser_ua(ua: 'Optional[str]') -> 'None':
    pass

def get_chrome_runtime_version() -> 'str':
    pass

def chrome_user_agent_override() -> 'str':
    pass

def browser_http_user_agent() -> 'str':
    pass

def browser_http_chrome_major() -> 'str':
    pass

def resolve_geo(account: 'dict') -> 'tuple[str, str]':
    pass

def build_chrome_args(account: 'dict', locale: 'str', extra_args: 'Optional[list[str]]' = None) -> 'list[str]':
    pass
