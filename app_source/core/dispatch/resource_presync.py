"""
Decompiled / Reconstructed Module: core.dispatch.resource_presync
Source PyC: resource_presync.pyc

Docstring:
Account-agnostic resource pre-sync for dispatch payloads.

The dispatcher treats account-bound server IDs as derived cache entries. When a
logical source is present, this module removes stale server IDs so existing
handler lazy-resolution paths rebuild them for the account selected to run the
job.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
logger = <Logger core.dispatch.resource_presync (WARNING)>

# --- Top-Level Functions ---
def _has_value(value: 'Any') -> 'bool':
    pass

def _first_entity_id(reference_entities: 'Any') -> 'str':
    pass

def _append_warning(prompt_data: 'dict', *, resource: 'str', reason: 'str', stale_id: 'Any') -> 'None':
    pass

def _account_keys(account: 'Any') -> 'set[str]':
    pass

def _current_account_media_map(value: 'Any', account_keys: 'set[str]') -> 'dict':
    pass

def _drop_keyframe_server_refs(prompt_data: 'dict', prefix: 'str', account_keys: 'set[str]') -> 'None':
    pass

def _drop_output_resume_refs(prompt_data: 'dict') -> 'None':
    pass

def _drop_stale_reference_entities(prompt_data: 'dict') -> 'None':
    pass

def presync_account_resources(prompt_data: 'dict', account, *, services=None) -> 'dict':
    pass
