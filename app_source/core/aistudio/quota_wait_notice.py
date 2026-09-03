"""
Decompiled / Reconstructed Module: core.aistudio.quota_wait_notice
Source PyC: quota_wait_notice.pyc

Docstring:
Process-wide AI Studio quota wait/recovery notification funnel.

Structured AI calls stay on AI Studio.  When every configured Flash-model/account
pair is quota-limited, the provider worker pauses at the current call and retries.
This module reports that episode once through the existing queued runtime-feedback
hub, then clears the latch when any pair succeeds again.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['aistudio_quota_waiting', 'reset_aistudio_quota_wait_notice', 'notify_aistudio_quota_waiting', 'notify_aistudio_tts_local_fallback', 'notify_aistudio_quota_recovered']

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
_LOCK = <unlocked _thread.lock object at 0x00000264D96C5140>
_waiting = False
__all__ = ['aistudio_quota_waiting', 'reset_aistudio_quota_wait_notice', 'notify_aistudio_quota_waiting', 'notify_aistudio_tts_local_fallback', 'notify_aistudio_quota_recovered']

# --- Top-Level Functions ---
def aistudio_quota_waiting() -> 'bool':
    pass

def reset_aistudio_quota_wait_notice() -> 'None':
    pass

def notify_aistudio_quota_waiting(*, retry_seconds: 'float', account_count: 'int', model_names: 'tuple[str, ...]', ai_feature: 'str' = '', detail: 'str' = '', local_tts_hint: 'str' = '') -> 'None':
    pass

def notify_aistudio_tts_local_fallback(*, engine: 'str' = '', ai_feature: 'str' = '') -> 'None':
    pass

def notify_aistudio_quota_recovered(*, account_label: 'str' = '', model_name: 'str' = '', ai_feature: 'str' = '') -> 'None':
    pass
