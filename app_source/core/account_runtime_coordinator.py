"""
Decompiled / Reconstructed Module: core.account_runtime_coordinator
Source PyC: account_runtime_coordinator.pyc

Docstring:
Canonical account-runtime transition side effects.

``AccountManager`` remains the persistence source of truth.  This coordinator
owns the *runtime projection* of a persisted account transition:

    AccountManager -> dispatcher roster -> browser farm -> recovery -> notice

No caller should independently unregister a dispatcher account, evict its farm
browser, and notify the UI.  Keeping those side effects here prevents the
split-brain state where the Account tab says ``Need Login`` while the dispatcher
continues assigning work to the same account.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Optional = typing.Optional
logger = <Logger core.account_runtime_coordinator (WARNING)>
_instance = None
_instance_lock = <unlocked _thread.lock object at 0x00000264D6C64D00>

# --- Class: AccountStatusTransition ---
class AccountStatusTransition:
    """AccountStatusTransition(account_key: 'str', profile_name: 'str', old_status: 'str', new_status: 'str', reason: 'str' = '')"""
    reason = ''
    is_live = <property object at 0x00000264D83731A0>
    needs_login = <property object at 0x00000264D8395A30>

    def __init__(self, account_key: 'str', profile_name: 'str', old_status: 'str', new_status: 'str', reason: 'str' = '') -> None:
        pass

    def __repr__(self):
        pass


# --- Class: AccountRuntimeCoordinator ---
class AccountRuntimeCoordinator:
    """Project persisted account state into every runtime consumer.

    The class intentionally stores no account state of its own.  It is a
    serialized side-effect gate, not a second source of truth."""
    def __init__(self) -> 'None':
        pass

    def reload_account_roster(self) -> 'None':
        pass

    def _evict_farm_account(self, transition: 'AccountStatusTransition') -> 'None':
        pass

    def _schedule_session_probe(self, transition: 'AccountStatusTransition') -> 'None':
        pass

    def _notify_need_login(self, transition: 'AccountStatusTransition') -> 'None':
        pass

    def _clear_live_recovery_state(self, transition: 'AccountStatusTransition') -> 'None':
        pass

    def reconcile(self, transition: 'AccountStatusTransition') -> 'None':
        pass


# --- Top-Level Functions ---
def get_account_runtime_coordinator() -> 'AccountRuntimeCoordinator':
    pass
