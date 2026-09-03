"""
Decompiled / Reconstructed Module: core.prominent_person_notice
Source PyC: prominent_person_notice.pyc

Docstring:
One-shot runtime notice for Google's prominent/public-person image filter.

The dispatcher may be processing many scene jobs from one submission.  Emitting a
dialog per failed scene would bury the useful instruction, so this funnel de-dupes
by the canonical run/group id supplied by FailureHandler.  The shared signal hub
delivers the event to Qt through its queued connection; no GUI work happens here.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['notify_prominent_person_blocked', 'notify_character_ip_t2v_fallback']

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
_LOCK = <unlocked _thread.lock object at 0x00000264D772FDC0>
_notified_runs = set()
__all__ = ['notify_prominent_person_blocked', 'notify_character_ip_t2v_fallback']

# --- Top-Level Functions ---
def _source_geometry(source_path: 'str') -> 'tuple[str, str]':
    pass

def notify_prominent_person_blocked(notice_key: 'str', detail: 'str' = '', source_path: 'str' = '', output_aspect: 'str' = '') -> 'None':
    pass

def notify_character_ip_t2v_fallback(notice_key: 'str', detail: 'str' = '') -> 'None':
    pass
