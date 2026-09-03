"""
Decompiled / Reconstructed Module: services.shared.media.account_asset_cleanup
Source PyC: account_asset_cleanup.pyc

Docstring:
Cleanup account-scoped media/Flow caches when accounts are removed.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)

# --- Top-Level Functions ---
def _text(value: 'Any') -> 'str':
    pass

def _value(account: 'Any', key: 'str') -> 'Any':
    pass

def account_identity_keys(account: 'Any') -> 'list[str]':
    pass

def cleanup_account_asset_state(account: 'Any') -> 'dict[str, Any]':
    """Delete local account-scoped upload/entity/voice sync state."""
    pass
