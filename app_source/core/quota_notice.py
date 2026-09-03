"""
Decompiled / Reconstructed Module: core.quota_notice
Source PyC: quota_notice.pyc

Docstring:
Global 'video account out of credits' (Flow 429 quota) notice funnel.

When a generation hits HTTP 429 ``PUBLIC_ERROR_USER_QUOTA_REACHED`` the account
has spent its Google Flow generation quota — it can't run credit-consuming models
until the quota resets. With multi-account dispatch this would otherwise spam the
user once per failed job. This funnel raises the SYSTEM runtime-alert dialog once
per exhausted account, so account rotation remains visible without job-level spam.

The emit goes through the shared InstantUpscaleManager signal hub, whose QML-side
connection is a queued cross-thread one, so this is safe to call from dispatcher
worker threads.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
_LOCK = <unlocked _thread.lock object at 0x00000264D8E8B600>
_notified_accounts = set()

# --- Top-Level Functions ---
def video_quota_exhausted() -> 'bool':
    pass

def reset_video_quota_notice() -> 'None':
    pass

def notify_video_quota_exhausted(account_label: 'str' = '', detail: 'str' = '') -> 'None':
    pass
