"""
Decompiled / Reconstructed Module: core.auth_loss_notice
Source PyC: auth_loss_notice.pyc

Docstring:
Global 'account signed out on the browser — re-login needed' notice funnel.

A cookie-authed labs read (e.g. ``media.getMediaUrlRedirect`` when downloading an
upscaled clip) can return HTTP 401. Normally that self-heals: we force-refresh the
cookies from the persistent login browser (the cookie SOT) and retry. But when that
refresh ITSELF fails (``sync_from_browser`` throws "Failed to fetch"), the browser
has no live session — the Google account is genuinely signed out. No amount of
retrying fixes that; the user must log back in.

Previously this surfaced only as a generic ``upscale_failed`` / ``[DOWNLOAD] failed:
401`` in the log with no user-facing prompt. This funnel raises the SYSTEM runtime
alert ("account needs re-login", routes to the Accounts tab) EXACTLY ONCE per
account (mirrors ``core.quota_notice.notify_video_quota_exhausted``). The latch is
re-armed when that account next downloads successfully, so a fresh logout later in
the same run notifies again.

The emit goes through the shared InstantUpscaleManager signal hub, whose QML-side
connection is a queued cross-thread one, so this is safe to call from dispatcher
worker threads.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
_LOCK = <unlocked _thread.lock object at 0x00000264D7687280>
_notified = set()

# --- Top-Level Functions ---
def _key(account: 'str') -> 'str':
    pass

def mark_auth_dead(account: 'str' = '') -> 'None':
    pass

def is_auth_dead(account: 'str' = '') -> 'bool':
    pass

def reset_account_logout_notice(account: 'str' = '') -> 'None':
    pass

def notify_account_logged_out(account: 'str' = '', detail: 'str' = '', sync_status: 'bool' = True) -> 'None':
    pass
