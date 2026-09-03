"""
Decompiled / Reconstructed Module: core.aistudio.drive_consent_notice
Source PyC: drive_consent_notice.pyc

Docstring:
One-shot UI notice when Drive OAuth needs interactive 2FA / user grant.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['notify_drive_consent_user_required', 'reset_drive_consent_notice']

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
_LOCK = <unlocked _thread.lock object at 0x00000264D8F0D900>
_notified = set()
__all__ = ['notify_drive_consent_user_required', 'reset_drive_consent_notice']

# --- Top-Level Functions ---
def _key(account: 'str') -> 'str':
    pass

def reset_drive_consent_notice(account: 'str' = '') -> 'None':
    pass

def notify_drive_consent_user_required(account: 'str' = '', *, email: 'str' = '', reason: 'str' = '', detail: 'str' = '') -> 'None':
    pass
