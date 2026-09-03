"""
Decompiled / Reconstructed Module: core.captcha.captcha_token_manager
Source PyC: captcha_token_manager.pyc

Docstring:
Captcha token manager facade.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Optional = typing.Optional

# --- Class: CaptchaTokenManager ---
class CaptchaTokenManager:
    """Stable public API backed by the browser runtime."""
    _instance = None
    _lock = <unlocked _thread.lock object at 0x00000264DA579B80>

    def __init__(self) -> 'None':
        pass

    def _runtime(self):
        pass

    def _get_stats_tracker(self):
        pass

    def get_tokens(self, account_id: 'str' = None, action: 'str' = None, timeout_ms: 'int' = 60000, priority: 'int' = 2, sequence_number: 'int' = 0, request_type: 'str' = 'image_generation') -> 'dict':
        pass

    def execute_api_call(self, url: 'str', payload: 'dict', action: 'str' = None, timeout_ms: 'int' = 60000, account_id: 'str' = None, priority: 'int' = 2, sequence_number: 'int' = 0, request_type: 'str' = 'image_generation') -> 'dict':
        pass

    def execute_flow_edit_extend(self, request: 'dict', timeout_ms: 'int' = 120000, account_id: 'str' = None, **_) -> 'dict':
        pass

    def execute_flow_edit_upscale(self, request: 'dict', timeout_ms: 'int' = 120000, account_id: 'str' = None, **_) -> 'dict':
        pass

    def execute_flow_create(self, request: 'dict', timeout_ms: 'int' = 120000, account_id: 'str' = None, **_) -> 'dict':
        pass

    def prewarm_account(self, account_id: 'str', reason: 'str' = 'prewarm', *, replace_existing: 'bool' = False) -> 'dict':
        pass

    def get_last_provider_id(self) -> 'Optional[str]':
        pass

    def get_status(self) -> 'dict':
        pass


# --- Top-Level Functions ---
def get_captcha_token_manager() -> 'CaptchaTokenManager':
    pass
