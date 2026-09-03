"""
Decompiled / Reconstructed Module: core.aistudio.direct.interactive_login
Source PyC: interactive_login.pyc

Docstring:
Explicit headed authentication facade for the dedicated AI profile.

These functions are intentionally separate from normal warm/generate calls.
Importing this module never launches a browser; only ``start_interactive_login``
may request headed presentation for the selected account.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['cancel_interactive_login', 'poll_interactive_login', 'run_interactive_action', 'start_interactive_login']

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
_log = <Logger core.aistudio.direct.interactive_login (WARNING)>
__all__ = ['cancel_interactive_login', 'poll_interactive_login', 'run_interactive_action', 'start_interactive_login']

# --- Top-Level Functions ---
def _failed(reason: 'str', message: 'str') -> 'dict':
    pass

def start_interactive_login(account) -> 'dict':
    pass

def poll_interactive_login(account) -> 'dict':
    pass

def cancel_interactive_login(account) -> 'None':
    pass

def run_interactive_action(account, action, *, timeout: 'float' = 180.0):
    pass
