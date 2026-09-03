"""
Decompiled / Reconstructed Module: core.labs_api.calls
Source PyC: calls.pyc

Docstring:
core/labs_api/calls.py — per-feature orchestration (Strategy A).

Each function: resolve session → build wire payload → fetch via the farm browser
→ on 403/recaptcha fall back to the Flow UI adapter. The shared fetch/fallback
flow lives in transport.fetch_then_ui_fallback; payload building is delegated to
core/labs_api/wire/video.py so it stays pure and unit-testable without a browser.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
List = typing.List
Optional = typing.Optional

# --- Top-Level Functions ---
def _account_label(account_name: 'Optional[str]', account_email: 'Optional[str]') -> 'str':
    pass

def call_text_to_video(prompt: 'str', model: 'str', output_count: 'int', account_name: 'str', aspect_ratio: 'str' = '16:9', seed: 'Optional[int]' = None, extend_chain_id: 'Optional[str]' = None, account_email: 'Optional[str]' = None, user_tier: 'str' = 'PAYGATE_TIER_TWO', batch_id: 'Optional[str]' = None, resolution: 'str' = '') -> 'Dict[str, Any]':
    pass

def call_image_to_video(media_id: 'str', prompt: 'str', model: 'str', account_name: 'str', aspect_ratio: 'str' = 'VIDEO_ASPECT_RATIO_LANDSCAPE', seed: 'Optional[int]' = None, output_count: 'int' = 1, account_email: 'Optional[str]' = None, user_tier: 'str' = 'PAYGATE_TIER_TWO', batch_id: 'Optional[str]' = None) -> 'Dict[str, Any]':
    pass

def call_2_image_to_video(start_media_id: 'str', end_media_id: 'str', prompt: 'str', model: 'str', aspect_ratio: 'str', account_name: 'str', seed: 'Optional[int]' = None, output_count: 'int' = 1, account_email: 'Optional[str]' = None, user_tier: 'str' = 'PAYGATE_TIER_TWO', batch_id: 'Optional[str]' = None) -> 'Dict[str, Any]':
    pass

def _build_reference_audio(reference_audio: 'Optional[List[Any]]', model: 'str') -> 'List[Any]':
    pass

def _build_reference_entities(reference_entities: 'Optional[List[Any]]') -> 'List[Any]':
    pass

def call_multi_asset(prompt: 'str', model: 'str', output_count: 'int', reference_images: 'List[Dict[str, str]]', account_name: 'str', aspect_ratio: 'str' = '16:9', seed: 'Optional[int]' = None, account_email: 'Optional[str]' = None, user_tier: 'str' = 'PAYGATE_TIER_TWO', reference_audio: 'Optional[List[Any]]' = None, reference_entities: 'Optional[List[Any]]' = None, batch_id: 'Optional[str]' = None, resolution: 'str' = '') -> 'Dict[str, Any]':
    pass

def call_extend_video(prompt: 'str', media_id: 'str', model: 'str', account_name: 'str', aspect_ratio: 'str' = 'VIDEO_ASPECT_RATIO_LANDSCAPE', seed: 'Optional[int]' = None, workflow_id: 'str' = '', extend_chain_id: 'Optional[str]' = None, chain_scene_id: 'Optional[str]' = None, account_email: 'Optional[str]' = None, user_tier: 'str' = 'PAYGATE_TIER_TWO', batch_id: 'Optional[str]' = None, session_id: 'Optional[str]' = None) -> 'Dict[str, Any]':
    pass

def _store_chain_scene_id(extend_chain_id: 'str', result: 'Optional[Dict[str, Any]]') -> 'None':
    pass
