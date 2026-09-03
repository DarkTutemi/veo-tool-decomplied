"""
Decompiled / Reconstructed Module: core.dispatch.cooldown
Source PyC: cooldown.pyc

Docstring:
core/dispatch/cooldown.py — CooldownGate

Extracted from the scattered per-account dicts on SmartJobDispatcher.
All state is explicit, per-account, and thread-safe via per-key locks.

Improvement over the god-object: one class, zero hidden side effects,
injectable / testable without starting the whole dispatcher.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
Iterable = typing.Iterable
Optional = typing.Optional

# --- Class: CooldownGate ---
class CooldownGate:
    """Centralises all per-account throttle / cooldown state.

    State dicts (account_key → value):
        _403_cooldowns      : float  — expiry timestamp (403 soft-cap)
        _session_cooldowns  : float  — expiry timestamp (session expired)
        _media_uploading    : bool   — media pre-upload in progress
        _locks              : Lock   — per-account mutex (thread safety)

    Default cooldown durations match the dispatcher defaults:
        403 cooldown   → 30 s
        session cd     → 60 s"""
    def __init__(self, default_403_seconds: 'Optional[float]' = None, default_session_seconds: 'float' = 60.0) -> 'None':
        pass

    def _account_lock(self, account_key: 'str') -> "__assert_armored__((threading, b'\\x81\\xa9\\x94\\x16W'))":
        pass

    def is_403_cooldown(self, account_key: 'str') -> 'bool':
        pass

    def set_403_cooldown(self, account_key: 'str', seconds: 'Optional[float]' = None) -> 'None':
        pass

    def clear_403_cooldown(self, account_key: 'str') -> 'None':
        pass

    def is_session_cooldown(self, account_key: 'str') -> 'bool':
        pass

    def set_session_cooldown(self, account_key: 'str', seconds: 'Optional[float]' = None) -> 'None':
        pass

    def get_session_cooldown_remaining(self, account_key: 'str') -> 'float':
        pass

    def clear_session_cooldown(self, account_key: 'str') -> 'None':
        pass

    def is_quota_cooldown(self, account_key: 'str') -> 'bool':
        pass

    def set_quota_cooldown(self, account_key: 'str', seconds: 'Optional[float]' = None) -> 'None':
        pass

    def get_quota_cooldown_remaining(self, account_key: 'str') -> 'float':
        pass

    def clear_quota_cooldown(self, account_key: 'str') -> 'None':
        pass

    def set_media_uploading(self, account_key: 'str', uploading: 'bool') -> 'None':
        pass

    def is_media_uploading(self, account_key: 'str') -> 'bool':
        pass

    def can_afford(self, account: 'AccountSlot', model_key: 'str', required_credits: 'int') -> 'bool':
        pass

    def any_can_afford(self, accounts: 'Iterable[AccountSlot]', model_key: 'str', required_credits: 'int') -> 'bool':
        pass


# --- Top-Level Functions ---
def _default_403_rest_seconds() -> 'float':
    pass
