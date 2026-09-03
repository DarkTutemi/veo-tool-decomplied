"""
Decompiled / Reconstructed Module: core.aistudio.auth_recovery
Source PyC: auth_recovery.pyc

Docstring:
Coordinate AI consumer auth recovery through the canonical Labs owner.

AI Studio and Gemini keep their own persistent browser context, but they are
not independent login authorities.  Their Google SSO state is rebuilt from the
identity-bound Labs cookie checkpoint.  If that recovery is rejected, this
module asks ``SessionKeeper`` to verify the stable Labs profile; only that owner
may change the global Live/Need Login status.

Requests are deduplicated per account episode so a failing job/router cannot
continuously wake the owner probe.  A confirmed AI warm or a completed Labs
login re-arms the account through :func:`reset`.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['is_login_owner_probe_pending', 'request_login_owner_probe', 'reset']

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
_log = <Logger core.aistudio.auth_recovery (WARNING)>
_LOCK = <unlocked _thread.lock object at 0x00000264D8F0D180>
_requested = set()
_aliases = {}
__all__ = ['is_login_owner_probe_pending', 'request_login_owner_probe', 'reset']

# --- Top-Level Functions ---
def _identity(account: 'str') -> 'str':
    pass

def _key(account: 'str') -> 'str':
    pass

def reset(account: 'str' = '') -> 'None':
    pass

def is_login_owner_probe_pending(account: 'str') -> 'bool':
    pass

def request_login_owner_probe(account: 'str', detail: 'str' = '') -> 'bool':
    """Request one serialized Labs-owner verification for an AI auth episode.

    This function never emits an AI-specific login notice and never writes an
    account status.  ``SessionKeeper`` performs the authoritative browser probe."""
    pass
