"""
Decompiled / Reconstructed Module: core.aistudio.direct.fork_runtime
Source PyC: fork_runtime.pyc

Docstring:
Dedicated persistent AI Studio/Gemini browser runtime.

AI Studio and Gemini Web share one dedicated VeoFlowOS process/profile per
account, separate from BrowserFarm's Flow process.  This boundary is required:
live verification on 2026-08-02 showed the dedicated ``headless=new`` runtime
completed GenerateContent 3/3, while putting AI Studio on a sibling page inside
the already-warm Flow BrowserContext returned gRPC 7 in 3/3 runs.  Presentation
was not the cause; collapsing the two runtime owners was.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['AiStudioForkRuntime', 'apply_ai_profile_cookie_policy', 'attest_persistent_profile_owner', 'clear_cookie_handoff_pending', 'close_aistudio_fork_runtime', 'cookie_handoff_generation', 'cookie_handoff_pending', 'force_ai_profile_cookie_handoff', 'get_aistudio_fork_runtime', 'mark_cookie_handoff_pending']

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Awaitable = typing.Awaitable
Callable = typing.Callable
Dict = typing.Dict
Optional = typing.Optional
_log = <Logger core.aistudio.direct.fork_runtime (WARNING)>
_STRONG_GOOGLE_SSO_COOKIE_NAMES = frozenset({'__Secure-3PSID', 'SID', '__Secure-1PSID', 'SAPISID'})
_PROFILE_V2_DIR = '.profiles-v2'
_PROFILE_OWNER_MANIFEST = '.veoflow-profile-owner.json'
_profile_path_lock = <unlocked _thread.lock object at 0x00000264D97222C0>
_MEDIA_CONSENT_MARKER = '.media_consent_ok'
_COOKIE_HANDOFF_MARKER = '.cookie_handoff_pending'
_COOKIE_HANDOFF_GENERATION = '.cookie_handoff_generation'
GEMINI_APP_URL = 'https://gemini.google.com/app'
_HUNG_WORKER_REAP_SECONDS = 8.0
_engine_cls_cache = {}
__all__ = ['AiStudioForkRuntime', 'apply_ai_profile_cookie_policy', 'attest_persistent_profile_owner', 'clear_cookie_handoff_pending', 'close_aistudio_fork_runtime', 'cookie_handoff_generation', 'cookie_handoff... [truncated]

# --- Class: _DeadWorkerError ---
class _DeadWorkerError(RuntimeError):
    """Carry the exact dead worker across the sync runtime boundary."""
    def __init__(self, message: 'str', worker=None) -> 'None':
        pass


# --- Class: _RuntimeSubmitTimeout ---
class _RuntimeSubmitTimeout(TimeoutError):
    def __init__(self, message: 'str', future, completion: 'threading.Event') -> 'None':
        pass


# --- Class: AiStudioForkRuntime ---
class AiStudioForkRuntime:
    """One background asyncio loop hosting a dedicated worker per account."""
    _instance = None
    _cls_lock = <unlocked _thread.lock object at 0x00000264D839FCC0>

    def _init(self) -> 'None':
        pass

    def _canonical_key(self, account_name) -> 'str':
        pass

    def _ensure_loop(self) -> 'None':
        pass

    def _run_loop(self) -> 'None':
        pass

    def _submit(self, coro: 'Awaitable', timeout: 'float' = 300.0, cancel_on_timeout: 'bool' = True):
        pass

    def _quarantine_timed_out_action(self, account_key: 'str', timeout_error: '_RuntimeSubmitTimeout') -> 'None':
        pass

    def _abandon_hung_worker(self, account_key: 'str', timeout_error):
        pass

    def _assert_no_unfinished_actions(self, account_key: 'str') -> 'None':
        pass

    def _assert_ordinary_admission(self, account_key: 'str') -> 'None':
        pass

    def _queue_deferred_close(self, account_key: 'str') -> 'None':
        pass

    def _run_deferred_close(self, account_key: 'str') -> 'None':
        pass

    def _queue_close_reaper(self, account_key: 'str', worker, close_future) -> 'None':
        pass

    def _run_close_reaper(self, account_key: 'str', worker, close_future) -> 'None':
        pass

    def _acc_lock(self, account_name: 'str') -> "__assert_armored__((threading, b'\\x81\\xa9\\x94\\x16W'))":
        pass

    def _AccRW(writer_lock: 'threading.Lock') -> 'None':
        pass

    def _acc_rw(self, account_name: 'str') -> "'AiStudioForkRuntime._AccRW'":
        pass

    @staticmethod
    def _parallel_cap() -> 'int':
        pass

    @staticmethod
    def _generation_min_interval() -> 'float':
        pass

    def pace_generation(self, account_name: 'str') -> 'None':
        pass

    def _read_sem(self, account_name: 'str') -> "__assert_armored__((threading, b'\\x81\\xa7\\x94\\x00R\\xb5\\xfbB\\x84,\\xa0\\xae\\xf7>)pY'))":
        pass

    def run_shared(self, account_name: 'str', action: 'Callable[[object], Awaitable]', *, timeout: 'float' = 300.0):
        """Compatibility entry for pure generation; production is per-account serial."""
        pass

    def _gemini_lock(self, account_name: 'str') -> "__assert_armored__((threading, b'\\x81\\xa9\\x94\\x16W'))":
        pass

    def _surface_lock(self, account_name: 'str', surface: 'str') -> "__assert_armored__((threading, b'\\x81\\xa9\\x94\\x16W'))":
        pass

    def _async_worker_lock(self, account_name: 'str') -> "__assert_armored__((asyncio, b'\\x81\\xa9\\x94\\x16W'))":
        pass

    def _spawn_account_worker_locked(self, account_key: 'str', *, interactive: 'bool' = False):
        """Create/publish one worker while ``_async_worker_lock`` is held."""
        pass

    def _reap_finished_close(self, account_key: 'str') -> 'bool':
        pass

    def _close_worker_for_replacement(self, account_key: 'str', worker) -> 'None':
        """Close a whole context without orphaning it on caller cancellation."""
        pass

    def _get_worker(self, account_name: 'str'):
        pass

    def _replace_worker_for_recovery(self, account_key: 'str', expected):
        """Identity-safe whole-context replacement under both surface locks."""
        pass

    def _ensure_gemini_page(self, worker):
        """Tab B on the SAME context as AIS page — shared cookies, separate DOM."""
        pass

    def _spawn_worker(self, acc: 'dict', account_name: 'str'):
        """Spawn the ordinary, never-visible AI worker."""
        pass

    def _spawn_interactive_worker(self, acc: 'dict', account_name: 'str'):
        """Spawn only the explicitly requested headed authentication worker."""
        pass

    def _spawn_worker_with_presentation(self, acc: 'dict', account_name, *, headless):
        """Bring up a pinned, gate-capable VeoFlowOS worker.

        VeoFlowBrowserInstance owns the compatibility retry ladder so the farm
        and AI Studio use the same recovery behavior. Never fall back to vanilla
        Chrome: Chrome cannot host the fork license gate and only turns one
        launch error into a long series of misleading gate failures."""
        pass

    def _cleanup_unpublished_worker(self, account_key: 'str', worker) -> 'None':
        """Track cleanup for a fork that timed out before publication.

        The worker was never usable, so it must never appear in ``_workers``.
        ``_closing_workers`` alone retains the object until close finishes and
        prevents another spawn from racing its stable profile."""
        pass

    def run(self, account_name: 'str', action: 'Callable[[object], Awaitable]', *, timeout: 'float' = 300.0, surface: 'str' = 'aistudio'):
        """Run ``action(page)`` on the dedicated persistent AI browser.

        ``surface``:
          - ``"aistudio"`` (default): worker.page (MakerSuite mint path)
          - ``"gemini"``: worker.gemini_page (Gemini Web in-page transport)

        Per-surface locks allow AI Studio and Gemini to run concurrently while
        the worker lifecycle remains serialized per account."""
        pass

    def _interactive_state(self, account_key: 'str') -> 'dict | None':
        pass

    @staticmethod
    def _clear_interactive_auth_block(state: 'dict') -> 'None':
        pass

    def _finish_verified_interactive_locked(self, account_key: 'str', state: 'dict') -> 'dict':
        pass

    def start_interactive_login(self, account_name: 'str', *, timeout: 'float' = 180.0) -> 'dict':
        """Open this account's exact persistent AI profile in headed mode.

        This is the only headed launch path.  It waits for both AI surfaces to
        drain, replaces the ordinary headless worker, then leaves the headed
        browser under user control.  Re-clicking while it is alive is idempotent."""
        pass

    def poll_interactive_login(self, account_name: 'str', *, timeout: 'float' = 15.0) -> 'dict':
        """Verify exact AI identity and finish headed presentation on success."""
        pass

    def run_interactive_action(self, account_name: 'str', action: 'Callable[[object], Awaitable]', *, timeout: 'float' = 180.0):
        """Run ``action(page)`` on an already-open headed interactive worker.

            Ordinary ``run()`` is blocked while interactive presentation is active.
            Drive consent / step-up UI on that headed page through this entry only."""
        pass

    def cancel_interactive_login(self, account_name: 'str') -> 'None':
        pass

    def is_alive(self, account_name: 'str') -> 'bool':
        pass

    def _close_worker_locked(self, account_key: 'str') -> 'None':
        pass

    def close(self, account_name: 'str') -> 'None':
        pass

    def rebuild_profile_from_login_owner(self, account_name: 'str') -> 'bool':
        pass

    def rotate_seed(self, account_name: 'str') -> 'int':
        pass

    @staticmethod
    def _removal_aliases(resolved: 'dict', account_key: 'str') -> 'set[str]':
        pass

    def prepare_account_removal(self, account: 'dict') -> 'None':
        pass

    def finalize_account_removal(self, account: 'dict') -> 'None':
        pass

    def remove_account(self, account: 'dict') -> 'None':
        pass

    def restore_account(self, account: 'dict') -> 'None':
        pass

    def close_all(self, timeout: 'float' = 5.0) -> 'int':
        """Close only dedicated AI Studio/Gemini workers during shutdown."""
        pass


# --- Top-Level Functions ---
def _resolve_headless(account=None):
    pass

def _has_strong_google_sso_cookie(cookies) -> 'bool':
    pass

def apply_ai_profile_cookie_policy(context, incoming_cookies) -> 'str':
    """Synchronize the full exact-account jar into the persistent AI profile.

    AI Studio and Gemini call this same helper before importing cookies from the
    Labs login owner. The owner jar always overlays matching consumer cookies;
    AI-local cookies that are absent from the owner remain profile-local.

    Returns ``"profile"``, ``"bootstrap"``, ``"handoff"`` or ``"blank"``.
    Inspection errors fail closed so an uninspected profile is never mutated."""
    pass

def _apply_ai_profile_cookie_policy(context, incoming_cookies, *, force_handoff: 'bool') -> 'str':
    """Implementation seam for an identity-bound login handoff.

    The identity-bound login owner is the cookie authority. Every ordinary warm
    overlays its complete jar. ``force_handoff`` keeps the explicit retry seam
    used after the live target rejects the first navigation."""
    pass

def force_ai_profile_cookie_handoff(context, incoming_cookies) -> 'str':
    """Overlay one exact-account login checkpoint after live auth rejection."""
    pass

def _persistent_profile_base() -> 'Path':
    pass

def _normalise_owner_value(value) -> 'str':
    pass

def _profile_owner(account) -> 'dict[str, str | int]':
    pass

def _account_key(account) -> 'str':
    pass

def _legacy_account_key(account) -> 'str':
    """Exact directory key used by all releases before profile-v2."""
    pass

def _owner_manifest_text(owner: 'dict[str, str | int]') -> 'str':
    pass

def _legacy_profile_is_unique_to_owner(account: 'dict', owner: 'dict[str, str | int]') -> 'bool':
    pass

def _discover_legacy_profile(account: 'dict', owner: 'dict[str, str | int]') -> 'Path | None':
    pass

def _runtime_identity_key(account, fallback: 'str' = '') -> 'str':
    """Canonical in-memory owner for one Google account.

    Login profiles now intentionally use opaque names (``account-<id>``), while
    callers that persisted older job metadata may still address the same account
    by email.  Resolve every alias to the DB row, then derive one opaque owner
    from immutable DB id + stable ``profile_name``.  Email remains the external
    Google identity proof; it is not the runtime/profile owner key."""
    pass

def _resolve_profile_account(account) -> 'dict':
    pass

def _v2_profile_path(owner: 'dict[str, str | int]') -> 'Path':
    pass

def _existing_v2_profile(owner: 'dict[str, str | int]') -> 'Path | None':
    pass

def _claimed_legacy_profile(owner: 'dict[str, str | int]') -> 'Path | None':
    pass

def _find_existing_profile(account) -> 'Path | None':
    pass

def _persistent_account_profile(account) -> 'Path':
    pass

def attest_persistent_profile_owner(account) -> 'bool':
    pass

def _remove_persistent_account_profile(account) -> 'None':
    pass

def mark_cookie_handoff_pending(account) -> 'bool':
    pass

def cookie_handoff_pending(account) -> 'bool':
    pass

def cookie_handoff_generation(account) -> 'str':
    pass

def clear_cookie_handoff_pending(account) -> 'None':
    pass

def _media_consent_done(account) -> 'bool':
    pass

def _mark_media_consent_done(account) -> 'None':
    pass

def _page_alive(worker) -> 'bool':
    pass

def _worker_runtime_alive(worker) -> 'bool':
    pass

def _tab_alive(page) -> 'bool':
    pass

def _interactive_status(*, ok: 'bool', pending: 'bool', verified: 'bool', running: 'bool', reason: 'str', message: 'str') -> 'dict':
    pass

def _is_dead_page_error(e) -> 'bool':
    """True if an action failed because the browser/page died mid-flight (→ re-warm),
    NOT a legitimate app error (upload button missing, timeout on a live page, …).

    Hung ``run()`` timeouts are converted to ``_DeadWorkerError`` after the
    process is killed (B2). Do not match the timeout string here or a second
    timeout after re-warm would loop."""
    pass

def _closing_future_can_reap(closing_future, worker) -> 'bool':
    pass

def _force_kill_worker_process(worker) -> 'None':
    pass

def _fork_binary_ready() -> 'bool':
    pass

def _fork_base():
    pass

def _pinned_class(base_cls):
    """Subclass the fork into an AI-Studio-pinned worker: one stable device
    per account (never rotate) + persistent per-account profile. Cached per base class."""
    pass

def get_aistudio_fork_runtime() -> 'AiStudioForkRuntime':
    pass

def close_aistudio_fork_runtime(timeout: 'float' = 5.0) -> 'int':
    pass
