"""
Decompiled / Reconstructed Module: core.dispatch.retry_policy
Source PyC: retry_policy.pyc

Docstring:
core/dispatch/retry_policy.py — Centralised retry/failure decision logic.

Replaces: ERROR_STRATEGY table + _get_error_strategy + _calculate_strategy_delay
          + the dynamic-getattr special_handler dispatch in _handle_job_failure.

Improvement over old dispatcher:
  - No getattr(self, handler_name) — special cases return explicit FailureAction
    (MIGRATE / COOLDOWN) and the caller (FailureHandler) acts on them.
  - Pure function: no side-effects, no account-state mutation, easy to unit-test.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Final = typing.Final
_BACKOFF_BASE = 10
_BACKOFF_CAP = 60
_RL_BASE = 15
_RL_CAP = 60
_STRATEGY_TABLE = {'auth_expired': {'max_retries': 999, 'terminal': True, 'can_regen': False, 'delay_type': 'none', 'action': <FailureAction.MIGRATE: 4>}, 'account_unavailable': {'max_retries': 999, 'terminal': True, '... [truncated]
_DEFAULT_STRATEGY = {'max_retries': 3, 'terminal': False, 'can_regen': False, 'delay_type': 'backoff'}

# --- Class: RetryPolicy ---
class RetryPolicy:
    """Stateless retry/failure decision engine.

    Usage::

        policy = RetryPolicy()
        decision = policy.decide(handle, result, account)
        # decision.action is a FailureAction enum value"""
    STRATEGY_TABLE = {'auth_expired': {'max_retries': 999, 'terminal': True, 'can_regen': False, 'delay_type': 'none', 'action': <FailureActi...
    DEFAULT_STRATEGY = {'max_retries': 3, 'terminal': False, 'can_regen': False, 'delay_type': 'backoff'}

    def classify(self, result: 'GenResult') -> 'str':
        pass

    def decide(self, handle: 'JobHandle', result: 'GenResult', account: 'AccountSlot') -> 'RetryDecision':
        pass

    def get_delay(self, strategy: 'dict', retry_count: 'int') -> 'float':
        pass

    def _get_strategy(self, error_category: 'str') -> 'dict':
        pass


# --- Top-Level Functions ---
def _backoff(retry_count: 'int', *, rate_limit: 'bool' = False) -> 'float':
    pass
