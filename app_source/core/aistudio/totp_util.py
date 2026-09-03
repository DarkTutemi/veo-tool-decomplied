"""
Decompiled / Reconstructed Module: core.aistudio.totp_util
Source PyC: totp_util.pyc

Docstring:
RFC 6238 TOTP helpers (stdlib only — no pyotp dependency).
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['account_totp_secret', 'generate_totp_code', 'normalize_totp_secret']

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Optional = typing.Optional
_BASE32_RE = re.compile('[^A-Z2-7]')
__all__ = ['account_totp_secret', 'generate_totp_code', 'normalize_totp_secret']

# --- Top-Level Functions ---
def normalize_totp_secret(raw: 'str | None') -> 'str':
    pass

def generate_totp_code(secret: 'str', *, for_time: 'Optional[float]' = None, step: 'int' = 30, digits: 'int' = 6) -> 'str':
    pass

def account_totp_secret(account_name: 'str' = '', *, account: 'dict | None' = None) -> 'str':
    pass
