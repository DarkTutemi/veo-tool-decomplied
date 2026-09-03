"""
Decompiled / Reconstructed Module: services.shared.media.media_account_readiness
Source PyC: media_account_readiness.pyc

Docstring:
Account-aware readiness helpers for Media Library upload state.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Iterable = typing.Iterable
Mapping = typing.Mapping

# --- Top-Level Functions ---
def _text(value: 'Any') -> 'str':
    pass

def _account_value(account: 'Any', key: 'str') -> 'Any':
    pass

def account_key(account: 'Any') -> 'str':
    pass

def unique_account_keys(accounts: 'Iterable[Any] | None') -> 'list[str]':
    pass

def _usable_account(account: 'Any') -> 'bool':
    pass

def active_media_account_keys(accounts: 'Iterable[Any] | None' = None) -> 'list[str]':
    """Return account keys that can currently receive/use uploaded media."""
    pass

def normalize_upload_map(uploaded_accounts: 'Mapping[str, Any] | None') -> 'dict[str, str]':
    pass

def _badge_text(state: 'str', active_count: 'int', required_count: 'int') -> 'str':
    pass

def media_upload_readiness(uploaded_accounts: 'Mapping[str, Any] | None', account_keys: 'Iterable[str] | None' = None) -> 'dict[str, Any]':
    pass

def item_uploads(item: 'Mapping[str, Any]') -> 'dict[str, str]':
    pass

def item_analyzed(item: 'Mapping[str, Any]') -> 'bool':
    pass

def item_asset_type(item: 'Mapping[str, Any]') -> 'str':
    pass

def compute_media_stats(items: 'Iterable[Mapping[str, Any]]', account_keys: 'Iterable[str] | None' = None) -> 'dict[str, Any]':
    pass
