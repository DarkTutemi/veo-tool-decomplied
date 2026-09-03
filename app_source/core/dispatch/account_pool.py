"""
Decompiled / Reconstructed Module: core.dispatch.account_pool
Source PyC: account_pool.pyc

Docstring:
core/dispatch/account_pool.py — AccountPool

Manages the live account roster and per-account concurrency caps.

Replaces: account_states dict + busy-worker counting in smart_job_dispatcher.py.

Design (2026-06-21 — counter-based, roster/accounting decoupled):
- The ROSTER (`_accounts`) is what register/unregister/reload_accounts manage:
  which accounts exist + their per-account cap. It is rebuilt freely on every
  login / cookie-refresh / 403-rotation event without affecting concurrency.
- The CONCURRENCY ACCOUNTING (`_inflight`: account_key → in-flight job count) is
  the SINGLE SOURCE OF TRUTH for the cap. acquire() increments, release()
  decrements. register/unregister NEVER reset a live in-flight count.
  This makes the per-account cap immune to the reload storm that previously let
  one account run 54 jobs / poll 24 at once: the old design stored "busy" inside
  the slot objects that register() rebuilt, so each reload reset the cap counter
  to 0 and admitted SLOTS_PER_ACCOUNT more jobs while the old ones still ran.

Recaptcha-sensitive cap logic ported directly from:
    _is_recaptcha_sensitive_job   (lines 5913-5950)
    _account_dynamic_video_cap    (lines 5959-5967)
    _can_account_accept_more_job  (lines 5969-5973)
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
List = typing.List
Optional = typing.Optional
SLOTS_PER_ACCOUNT = 5
_RECAPTCHA_SENSITIVE_FEATURES = frozenset({<Feature.TEXT_VIDEO: 'text_video'>, <Feature.PORTRAIT_VIDEO: 'portrait_video'>, <Feature.IMAGE_VIDEO: 'image_video'>, <Feature.EXTEND_VIDEO: 'extend_video'>, <Feature.MULTI_ASSET: 'multi_as... [truncated]

# --- Class: _Account ---
class _Account:
    """Roster entry: the account view + its physical concurrency cap.

    Rebuilt freely by register()/reload_accounts(); carries NO concurrency state
    (that lives in AccountPool._inflight so reloads can't reset the cap)."""
    max_slots = 5

    def __init__(self, slot: 'AccountSlot', max_slots: 'int' = 5) -> None:
        pass

    def __repr__(self):
        pass


# --- Class: AccountPool ---
class AccountPool:
    """Thread-safe account roster with per-account concurrency enforcement.

    Parameters
    ----------
    recaptcha_cap_default:
        Max simultaneous recaptcha-sensitive jobs per account (not in 403-cd).
    recaptcha_cap_403:
        Tighter cap when the account is in 403 cooldown (default 1)."""
    def __init__(self, recaptcha_cap_default: 'int' = 5, recaptcha_cap_403: 'int' = 1) -> 'None':
        pass

    def register(self, account: 'AccountSlot', max_slots: 'int' = 5) -> 'None':
        pass

    def unregister(self, account_key: 'str') -> 'None':
        pass

    def acquire(self, account_key: 'str', job_handle: 'Optional[JobHandle]' = None, is_403_cooldown: 'bool' = False) -> 'Optional[AccountSlot]':
        pass

    def release(self, account_key: 'str') -> 'bool':
        pass

    def pick_account(self, job_handle: 'JobHandle', cooldown_gate) -> 'Optional[AccountSlot]':
        """Return the first available AccountSlot that:

        1. Is not in session cooldown.
        2. Is not in 403 (reCAPTCHA soft-cap) cooldown.
        3. Passes the recaptcha-sensitive cap.
        4. Passes ``cooldown_gate.can_afford`` if the gate has that method;
           otherwise the gate is treated as a plain 403-cooldown oracle via
           ``cooldown_gate.is_403_cooldown(key)``.
        5. RUNTIME POOL (chỉ PRO mode — ULTRA chạy song song nguyên đội): nằm trong
           active set 1..N account xoay vòng (core/dispatch/runtime_pool.py).
           ``locked_account_key`` bypass — extend/upscale phải về đúng account
           giữ media. Ảnh/char-gen 0cr được spill sang account drained (hết
           khả năng VIDEO, vẫn Live).

        Mirrors the three-pass worker selection in ``_dispatch_jobs`` but
        simplified to one pass (session/quota/403-cooled accounts are skipped).

        403 cooldown is a HARD skip, not a cap reduction. The old Pass-2
        "probe" re-admitted jobs onto the resting account the moment its
        inflight slot freed, so on a single-account setup the "90s rest" never
        happened — one submit every ~10s re-burned the reCAPTCHA score for as
        long as the queue had jobs (log 29/8/2026: 457 recaptcha_failed over
        82 min on one account). The rest window IS the recovery mechanism;
        during it jobs park on the orchestrator's waiting_for_account path.

        ACCOUNT_LOCKED affinity: when the handle carries ``locked_account_key``
        (extend/upscale — media_id tied to that account's project) only that
        account is considered; no fallback to other accounts."""
        pass

    def pick_alternative(self, current: 'AccountSlot', excluded_keys: 'Optional[set[str]]' = None) -> 'Optional[AccountSlot]':
        """Return a registered account different from *current* (MIGRATE path).

        Round-robin across the remaining accounts so repeated migrations spread
        load instead of always hammering the first registered account.
        Returns None when no other account is registered."""
        pass

    def all_busy(self) -> 'bool':
        """True when every registered account is at its physical cap."""
        pass

    def busy_count(self) -> 'int':
        """Total number of in-flight jobs across all accounts."""
        pass

    def free_count(self) -> 'int':
        pass

    def accounts(self) -> 'List[str]':
        pass

    def live_slots(self) -> 'List[AccountSlot]':
        pass

    def inflight_for(self, account_key: 'str') -> 'int':
        pass

    def _effective_cap(self, acc: '_Account', handle: 'Optional[JobHandle]', is_403_cooldown: 'bool') -> 'int':
        pass


# --- Top-Level Functions ---
def _job_slots_default() -> 'int':
    pass

def is_recaptcha_sensitive(handle: 'JobHandle') -> 'bool':
    pass

def _runtime_pool_filter(keys: 'List[str]', universe: 'List[str]') -> 'List[str]':
    pass

def _is_free_image_feature(handle: 'JobHandle') -> 'bool':
    pass

def _merge_drained_for_free_jobs(filtered: 'List[str]', original: 'List[str]') -> 'List[str]':
    pass
