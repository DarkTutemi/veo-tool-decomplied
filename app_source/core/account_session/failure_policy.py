"""
Decompiled / Reconstructed Module: core.account_session.failure_policy
Source PyC: failure_policy.pyc
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
_AUTH_WINDOW_S = 120.0
AUTH_FAILURE_TEXT_MARKERS = ('no_access_token', 'unauthorized', 'auth_expired', 'token_invalid', 'cookie_expired', 'cookies_dead', 'http_401')

# --- Class: _PolicyState ---
class _PolicyState:
    """_PolicyState(consecutive_401: 'int' = 0, consecutive_403: 'int' = 0, last_401_at: 'float' = 0.0, events: 'list[tuple[float, int]] | None' = None)"""
    consecutive_401 = 0
    consecutive_403 = 0
    last_401_at = 0.0
    events = None

    def __init__(self, consecutive_401: 'int' = 0, consecutive_403: 'int' = 0, last_401_at: 'float' = 0.0, events: 'list[tuple[float, int]] | None' = None) -> None:
        pass

    def __repr__(self):
        pass


# --- Class: AuthFailurePolicy ---
class AuthFailurePolicy:
    def __init__(self, *, consecutive_401_threshold: 'int' = 2, consecutive_403_threshold: 'int' = 3, ratio_window_seconds: 'int' = 300, ratio_min_samples: 'int' = 5, ratio_threshold: 'float' = 0.6, ratio_min_403: 'int' = 3):
        pass

    def _state(self, key: 'str') -> '_PolicyState':
        pass

    def record(self, key: 'str', *, status_code: 'int', error_text: 'str' = '') -> 'AuthDecision':
        pass


# --- Top-Level Functions ---
def is_auth_failure(status_code: 'int', error_text: 'str' = '') -> 'bool':
    pass
