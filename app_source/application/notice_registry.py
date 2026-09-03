"""
Decompiled / Reconstructed Module: application.notice_registry
Source PyC: notice_registry.pyc

Docstring:
SINGLE source of truth for every "why can't I run / what must I fix" notice.

Before this, each surface invented its own payload and they drifted:

* the pre-submit gates built ad-hoc dicts — one (`no_links`) shipped with NO ``message``
  at all, so the UI fell back to printing the raw code ``"no_links"`` at the user;
* ``run_preflight`` told users to *log in* when the real problem was an account that was
  logged in but switched OFF — the wrong instruction entirely;
* ``status_controller`` built a third shape for the runtime-alert dialog, and the Accounts
  banner a fourth.

Now there is ONE :class:`Notice` per condition, and three converters render it to the three
surfaces (blocker payload / runtime-alert dialog / persistent banner). Consequences:

* a condition can never again reach the user without a message and an action;
* the banner can never contradict the blocker the user hits on Run — same Notice;
* adding a condition = adding one row here; it shows up on every surface for free.

Detection lives with the caller (it has the context); this module owns WHAT to say and
WHICH buttons to offer. :func:`diagnose_accounts` is the exception — the account family is
shared by the gate, the banner and the alert, so its priority ladder lives here too.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['SEV_BLOCK', 'SEV_WARN', 'SEV_INFO', 'SURFACE_GATE', 'SURFACE_ALERT', 'SURFACE_BANNER', 'Notice', 'NoticeAction', 'OPEN_ACCOUNTS', 'CLOSE_ACTION', 'to_blocker', 'to_alert', 'to_banner', 'account_snapshot', 'diagnose_accounts', 'account_credits_notice', 'video_credits_exhausted_notice', 'aistudio_quota_waiting_notice', 'ai_credits_exhausted_notice', 'insufficient_funds_notice', 'account_expired_notice', 'backend_overload_notice', 'device_overloaded_notice', 'prominent_person_policy_notice', 'character_ip_t2v_fallback_notice', 'no_links_notice', 'unfetched_links_notice', 'video_too_long_notice']

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Optional = typing.Optional
SEV_BLOCK = 'block'
SEV_WARN = 'warn'
SEV_INFO = 'info'
SURFACE_GATE = 'gate'
SURFACE_ALERT = 'alert'
SURFACE_BANNER = 'banner'
CLOSE_ACTION = NoticeAction(label='Đóng', action='close', value='', tone='neutral')
OPEN_ACCOUNTS = NoticeAction(label='Mở Tài khoản', action='route', value='settings', tone='green')
_TIER_HINT = 'TIER phải khớp MODE đang chọn (ULTRA / PRO) — bật tài khoản ULTRA sẽ tự tắt PRO và ngược lại, không trộn 2 loại.'
__all__ = ['SEV_BLOCK', 'SEV_WARN', 'SEV_INFO', 'SURFACE_GATE', 'SURFACE_ALERT', 'SURFACE_BANNER', 'Notice', 'NoticeAction', 'OPEN_ACCOUNTS', 'CLOSE_ACTION', 'to_blocker', 'to_alert', 'to_banner', 'account_snap... [truncated]

# --- Class: NoticeAction ---
class NoticeAction:
    """One button on the alert dialog.

    ``action`` is the verb the QML alert handler dispatches on (App.qml
    ``onActionRequested``): ``route`` (go to a screen), ``open_login_browser``,
    ``commerce`` (top-up), ``refresh_accounts``, ``close``."""
    value = ''
    tone = ''

    def __init__(self, label: 'str', action: 'str', value: 'str' = '', tone: 'str' = '') -> None:
        pass

    def __repr__(self):
        pass


# --- Class: Notice ---
class Notice:
    """One user-facing condition: what happened + what to do about it."""
    hints = ()
    actions = ()
    detail_label = ''

    def full_text(self) -> 'str':
        """Message + the hint checklist — what a dialog or status line shows."""
        pass

    def __init__(self, code: 'str', severity: 'str', title: 'str', message: 'str', hints: 'tuple[str, ...]' = (), actions: 'tuple[NoticeAction, ...]' = (), detail_label: 'str' = '') -> None:
        pass

    def __repr__(self):
        pass


# --- Top-Level Functions ---
def to_blocker(notice: 'Notice', action: 'str' = '', route: 'str' = '') -> 'dict[str, Any]':
    pass

def to_alert(notice: 'Notice', detail: 'str' = '') -> 'dict[str, Any]':
    """Runtime-alert dialog payload (statusController.publishRuntimeAlert)."""
    pass

def to_banner(notice: 'Optional[Notice]') -> 'dict[str, Any]':
    pass

def account_snapshot() -> 'dict[str, int]':
    """Count accounts by state so we can name the ACTUAL cause.

    "Ready" = paid AND Live AND enabled — the exact filter ``AccountManager.get_live_accounts``
    (and therefore the run gate) uses, so a diagnosis here can never disagree with the
    gate. A row can fail in two INDEPENDENT ways that need different fixes — logged in
    but switched OFF, or switched on but not logged in — so they are counted separately."""
    pass

def diagnose_accounts() -> 'Optional[Notice]':
    pass

def account_credits_notice(model_name: 'str', required: 'int') -> 'Notice':
    pass

def video_credits_exhausted_notice(account_label: 'str' = '') -> 'Notice':
    pass

def aistudio_quota_waiting_notice(retry_seconds: 'int' = 0, account_count: 'int' = 0, ai_feature: 'str' = '', model_names: 'tuple[str, ...]' = ()) -> 'Notice':
    """Copy for the all-pairs daily-quota wait. Status bar only — do not modal.

    The worker already parks at the current stage and retries; a dialog would
    interrupt the user for an action the pipeline is already doing."""
    pass

def _tr(key: 'str', fallback: 'str') -> 'str':
    pass

def ai_credits_exhausted_notice(detail_label: 'str' = '') -> 'Notice':
    pass

def insufficient_funds_notice() -> 'Notice':
    pass

def account_expired_notice(account_email: 'str' = '') -> 'Notice':
    pass

def device_overloaded_notice() -> 'Notice':
    pass

def backend_overload_notice(minutes: 'int' = 6) -> 'Notice':
    pass

def prominent_person_policy_notice(source_label: 'str' = '', output_aspect: 'str' = '', source_orientation: 'str' = '', source_size: 'str' = '') -> 'Notice':
    """Google identified the uploaded source as a prominent/public person.

    This is deliberately separate from generic prompt policy: changing words or
    resending the same image cannot repair an identity-based source verdict."""
    pass

def character_ip_t2v_fallback_notice() -> 'Notice':
    pass

def no_links_notice() -> 'Notice':
    pass

def unfetched_links_notice(count: 'int', urls: 'tuple[str, ...]' = ()) -> 'Notice':
    """Clone: a link was pasted but auto-fetch never resolved it (no title, no duration).

    Two card paths feed the clone queue and only ONE of them verifies: auto-fetch builds a
    card from real yt-dlp metadata (and refuses ``_fetch_failed``), while a raw paste makes
    a card straight from the URL. Queueing the raw one burns a whole clone run on a link we
    cannot even read — the "- / - / submitted" row. So it is blocked here."""
    pass

def omni_voice_required_notice() -> 'Notice':
    pass

def video_too_long_notice(count: 'int', cap_minutes: 'int', items: 'tuple[str, ...]' = ()) -> 'Notice':
    """Clone: the source video is longer than the clone length cap.

    Blocked at ADD time, not at run time. yt-dlp metadata already gives us the duration
    while the card is being listed, so we know before a single byte is downloaded — and a
    too-long video would otherwise burn the download + the upload before failing."""
    pass
