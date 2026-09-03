"""
Decompiled / Reconstructed Module: core.captcha.ip_block_state
Source PyC: ip_block_state.pyc

Docstring:
Global reCAPTCHA "score-burn" detector + state (legacy name: IP-burn).

A generate call 403s (`recaptcha_failed` / UNUSUAL_ACTIVITY) when the reCAPTCHA
Enterprise SCORE drops below threshold. That score is weighted by ACCOUNT reputation
× request VELOCITY × IP reputation — it is NOT decided by the browser/headless mode.
Verified 2026-07-07: a fresh account passes headless=new on the very same host IP that
a burned account 403s on, so 403 ≠ "IP blocked" and ≠ "headless detected". Concretely:
  • A SINGLE account 403-storming = that account's velocity/reputation is spent.
    Retrying harder burns it DEEPER — rest / rotate the account, don't hammer.
  • MANY DISTINCT accounts 403ing at once on one IP = the IP is the likely common
    factor (dirty / datacenter) — route through a clean proxy / WARP.

This module aggregates 403/success across accounts into ONE global state so the UI
shows a single, non-spammy notice and the dispatcher can hard-pause + clear browsers.
(Note: with the default threshold=1 a single account's burn also trips this — so the
notice is worded for both causes, not just IP.)
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Callable = typing.Callable
_MESSAGE = 'Google đang báo HOẠT ĐỘNG BẤT THƯỜNG (unusual activity) khi tạo video / ảnh, nên đang bị chặn tạm thời.\n\nNguyên nhân thường là ĐA YẾU TỐ (tài khoản + IP) nên khó xác định tuyệt đối, nhưng đa số trư... [truncated]
_instance = None
_instance_lock = <unlocked _thread.lock object at 0x00000264DA620800>

# --- Class: _IpBlockState ---
class _IpBlockState:
    def __init__(self) -> 'None':
        pass

    @staticmethod
    def _threshold() -> 'int':
        pass

    @staticmethod
    def _window() -> 'int':
        pass

    def report_403(self, account_key: 'str') -> 'None':
        pass

    def report_success(self, account_key: 'str') -> 'None':
        pass

    def force_resume(self) -> 'None':
        pass

    def schedule_cooldown(self, base_seconds: 'float' = 180.0) -> 'None':
        pass

    def _cooldown_expired(self) -> 'None':
        pass

    def _cancel_cooldown_timer(self) -> 'None':
        pass

    def is_blocked(self) -> 'bool':
        pass

    @staticmethod
    def message() -> 'str':
        pass

    def add_listener(self, cb: 'Callable[[bool], None]') -> 'None':
        pass

    def _prune(self, now: 'float') -> 'None':
        pass

    def _notify(self, blocked: 'bool') -> 'None':
        pass


# --- Top-Level Functions ---
def _env_int(name: 'str', default: 'int', minimum: 'int', maximum: 'int') -> 'int':
    pass

def get_ip_block_state() -> '_IpBlockState':
    pass
