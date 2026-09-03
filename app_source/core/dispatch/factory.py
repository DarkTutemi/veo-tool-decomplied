"""
Decompiled / Reconstructed Module: core.dispatch.factory
Source PyC: factory.pyc

Docstring:
core/dispatch/factory.py — dispatcher factory.

Usage::

    dispatcher = get_dispatcher()

V2 is the ONLY engine. ``get_dispatcher()`` returns ``LegacyCompatDispatcher``
(core/dispatch/compat.py) — a thin FACADE that exposes the old caller API but
runs entirely on the V2 ``DispatchOrchestrator`` (wired in ``_build_new_dispatcher``).
"LegacyCompat" = legacy-compatible INTERFACE, not legacy implementation. The old
SmartJobDispatcher was removed (2026-06-13); there is no flag/fallback anymore.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
logger = <Logger core.dispatch.factory (WARNING)>

# --- Top-Level Functions ---
def get_dispatcher():
    pass

def _make_account_unavailable_hook(account_pool):
    pass

def _build_new_dispatcher():
    pass
