"""
Decompiled / Reconstructed Module: core.aistudio.auth_health
Source PyC: auth_health.pyc

Docstring:
Process-local circuit breaker for the AI cookie consumer.

Labs owns the Google login and global account status. AI Studio/Gemini consume
that same identity-bound SSO state in their shared persistent browser. An AI
redirect alone must therefore request a Labs-owner probe rather than evicting
the account, while a successful AI warm cannot promote Labs to ``Live``. This
TTL gate only prevents repeated expensive consumer warm attempts; it never
writes AccountManager state.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['clear_aistudio_auth_block', 'is_aistudio_auth_blocked', 'mark_aistudio_auth_blocked']

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
_LOCK = <unlocked _thread.lock object at 0x00000264D8383A80>
_blocked_at = {}
_AUTH_BLOCK_TTL_S = 60.0
__all__ = ['clear_aistudio_auth_block', 'is_aistudio_auth_blocked', 'mark_aistudio_auth_blocked']

# --- Top-Level Functions ---
def _key(account: 'str') -> 'str':
    pass

def mark_aistudio_auth_blocked(account: 'str' = '') -> 'None':
    pass

def is_aistudio_auth_blocked(account: 'str' = '') -> 'bool':
    pass

def clear_aistudio_auth_block(account: 'str' = '') -> 'None':
    pass
