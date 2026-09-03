"""
Decompiled / Reconstructed Module: core.dispatch.account_resource_ready
Source PyC: account_resource_ready.pyc

Docstring:
Ensure account-scoped media/entities/voices exist BEFORE the scene prompt.

``resource_presync`` only drops stale server IDs. This module does the real work
for the account just picked (including a runtime-pool promotion): upload library
media, sync Flow character entities, sync custom voice. The generate call must
not run until that finishes. Cache hits are success.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Callable = typing.Callable
Optional = typing.Optional
logger = <Logger core.dispatch.account_resource_ready (WARNING)>
_SKIP_FEATURES = frozenset({'upscale_video', 'character_generation', 'image_generation', 'extend_video'})
_SKIP_API_JOBS = frozenset({'upscale', 'extend', 'image_gen', 'character_gen'})

# --- Class: AccountResourcesNotReady ---
class AccountResourcesNotReady(Exception):
    """Required media/entity/voice is not on this account yet — do not send prompt."""
    def __init__(self, message: 'str', error_category: 'str' = 'account_resources_pending', retryable: 'bool' = True) -> 'None':
        pass


# --- Top-Level Functions ---
def _feature_value(handle: 'Any') -> 'str':
    pass

def _api_job_value(handle: 'Any') -> 'str':
    pass

def _should_ensure(handle: 'Any') -> 'bool':
    pass

def _account_dict(account: 'Any') -> 'dict':
    pass

def _account_keys(account: 'Any') -> 'set[str]':
    pass

def _text(value: 'Any') -> 'str':
    pass

def _unique(values: 'list[str]') -> 'list[str]':
    pass

def _collect_library_ids(prompt_data: 'Mapping[str, Any]') -> 'list[str]':
    pass

def _collect_flow_character_ids(prompt_data: 'Mapping[str, Any]') -> 'list[str]':
    pass

def _collect_voice_refs(prompt_data: 'Mapping[str, Any]') -> 'list[dict]':
    pass

def _default_upload_media(media_id: 'str', account: 'dict', **kwargs) -> 'Optional[str]':
    pass

def _default_lookup_media(media_id: 'str') -> 'Any':
    pass

def _default_ensure_character(character_id: 'str', account: 'dict', **kwargs) -> 'str':
    pass

def _default_ensure_voice(voice_ref: 'dict', account: 'dict') -> 'dict':
    pass

def _raise_policy(exc: 'BaseException') -> 'None':
    pass

def ensure_account_resources(prompt_data: 'dict', account, handle=None, upload_media: 'Optional[Callable]' = None, ensure_character: 'Optional[Callable]' = None, ensure_voice: 'Optional[Callable]' = None, lookup_media: 'Optional[Callable]' = None, heartbeat: 'Optional[Callable]' = None, stop_check: 'Optional[Callable]' = None) -> 'dict':
    pass

def execute_after_resources_ready(handler, handle, prompt_data: 'dict', account, services, upload_media: 'Optional[Callable]' = None, ensure_character: 'Optional[Callable]' = None, ensure_voice: 'Optional[Callable]' = None, lookup_media: 'Optional[Callable]' = None) -> 'GenResult':
    pass
