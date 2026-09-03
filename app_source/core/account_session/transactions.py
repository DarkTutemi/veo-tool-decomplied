"""
Decompiled / Reconstructed Module: core.account_session.transactions
Source PyC: transactions.pyc

Docstring:
Per-account serialization for login ownership and session publication.

The headed login marker and the durable session checkpoint form one transaction:
either a verified snapshot publishes first, or Relogin becomes pending first and
all background publishers stand down.  A shared keyed ``RLock`` makes that order
atomic across BrowserManager and AccountSessionProvider without holding a lock
during slow browser/network calls.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
_locks_guard = <unlocked _thread.lock object at 0x00000264D8412D80>
_locks = {}

# --- Top-Level Functions ---
def _transaction_lock(account_name: 'str') -> "__assert_armored__((threading, b'\\x81\\xb7\\xb7\\x1a_\\xba'))":
    pass

def account_session_transaction(account_name: 'str') -> 'Iterator[None]':
    pass
