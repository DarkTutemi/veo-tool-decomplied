"""
Decompiled / Reconstructed Module: core.dispatch.failure_handler
Source PyC: failure_handler.pyc

Docstring:
core/dispatch/failure_handler.py — FailureHandler

Centralises all failure routing logic extracted from SmartJobDispatcher._handle_job_failure
and its _handle_* family of methods.

Improvements over the old dispatcher:
- No getattr(self, handler_name) dynamic dispatch — every action is an explicit
  if/elif branch derived from the FailureAction enum.
- Model-switch side-effects (timeout, missing_audio) are isolated in _prepare_retry()
  and not mixed into the decision step (RetryPolicy).
- Fully injectable: zero references to global singletons at construction time.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Callable = typing.Callable
Optional = typing.Optional
logger = <Logger core.dispatch.failure_handler (WARNING)>

# --- Class: IAccountPool ---
class IAccountPool:
    """Minimal interface for account pool — only what FailureHandler needs."""
    def pick_alternative(self, current: 'AccountSlot', excluded_keys: 'Optional[set[str]]' = None) -> 'Optional[AccountSlot]':
        pass


# --- Class: ICooldownGate ---
class ICooldownGate:
    """Minimal interface for the cooldown gate."""
    def set_session_cooldown(self, account_key: 'str') -> 'None':
        pass

    def get_session_cooldown_remaining(self, account_key: 'str') -> 'float':
        pass


# --- Class: IJobQueue ---
class IJobQueue:
    """Minimal interface for the job queue."""
    def requeue(self, handle: 'JobHandle', delay: 'float' = 0.0) -> 'None':
        pass


# --- Class: IRegenService ---
class IRegenService:
    """Minimal interface for the regen service."""
    def regen(self, handle: 'JobHandle') -> 'JobHandle':
        pass


# --- Class: FailureHandler ---
class FailureHandler:
    """Routes a failed job to the correct action (RETRY / REGEN / FAIL / MIGRATE / COOLDOWN).

    All dependencies are injected so this class is testable without the full dispatcher.

    Args:
        retry_policy:  Stateless policy that maps (handle, result, account) → RetryDecision.
        job_state:     Writes status transitions to JobStore and emits UI signals.
        job_queue:     Async queue for requeueing retries.
        account_pool:  Provides alternative accounts for MIGRATE.
        regen_service: Handles REGEN path (builds a new job from stored prompt data).
        cooldown_gate: Optional — set session cooldowns on COOLDOWN action.
        job_store:     Optional — get_meta/update_meta access for model-switch
                       (prompt_data["model"] is owned by JobStore, not the handle).
        on_account_unavailable: Optional hook(account, error_category, error) —
                       called for auth_expired / account_banned so the wiring
                       layer can mark the account dead / detect tier downgrade
                       (port of _handle_auth_expired_error side-effects)."""
    _OVERLOAD_THRESHOLD = 3
    _OVERLOAD_COOLDOWN_SECONDS = 360.0

    def __init__(self, retry_policy: 'IRetryPolicy', job_state: 'IJobStateSync', job_queue: 'IJobQueue', account_pool: 'IAccountPool', regen_service: 'IRegenService', *, cooldown_gate: 'Optional[ICooldownGate]' = None, job_store=None, on_account_unavailable: 'Optional[Callable[[AccountSlot, str, str], None]]' = None) -> 'None':
        pass

    def handle(self, handle: 'JobHandle', result: 'GenResult', account: 'AccountSlot') -> 'None':
        """Route *handle* based on *result* and the retry policy decision."""
        pass

    def _note_backend_overload(self, category: 'str', account: 'AccountSlot') -> 'bool':
        pass

    def _note_recaptcha_failure(self, account: 'AccountSlot') -> 'None':
        pass

    def _extend_recaptcha_delay(self, decision: 'RetryDecision', account: 'AccountSlot') -> 'RetryDecision':
        pass

    def _do_retry(self, handle: 'JobHandle', result: 'GenResult', decision: 'RetryDecision', account: 'Optional[AccountSlot]' = None) -> 'None':
        """Apply model-switch side-effects, increment retry counter, requeue."""
        pass

    def _do_regen(self, handle: 'JobHandle', result: 'GenResult', decision: 'RetryDecision') -> 'None':
        """Delegate to RegenService — creates a fresh job handle from stored prompt data."""
        pass

    def _do_migrate(self, handle: 'JobHandle', result: 'GenResult', account: 'AccountSlot', decision: 'RetryDecision') -> 'None':
        """Try to find another account. On success: retry with new account. On failure: FAIL."""
        pass

    def _do_cooldown(self, handle: 'JobHandle', result: 'GenResult', account: 'AccountSlot', decision: 'RetryDecision') -> 'None':
        """Set account session cooldown, then requeue with decision delay."""
        pass

    def _do_fail(self, handle: 'JobHandle', result: 'GenResult', decision: 'RetryDecision') -> 'None':
        pass

    def _prepare_retry(self, handle: 'JobHandle', error_category: 'str', account: 'Optional[AccountSlot]' = None) -> 'None':
        pass

    def _mark_retry_overwrite(self, handle: 'JobHandle') -> 'None':
        pass


# --- Top-Level Functions ---
def _quota_cooldown_seconds() -> 'float':
    pass

def _maybe_await(value) -> 'None':
    """Await *value* if it is awaitable (real JobQueue.requeue is sync;
    test fakes and the IJobQueue protocol are async — support both)."""
    pass
