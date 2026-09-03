"""
Decompiled / Reconstructed Module: services.shared.routing.runtime_model_resolver
Source PyC: runtime_model_resolver.pyc

Docstring:
Runtime model resolver for profile-first video model selection.

This module keeps the user's cost/speed preference separate from the final
runtime kind (T2V/R2V/I2V/extend), which may only be known after per-scene refs
have been attached.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
List = typing.List
Optional = typing.Optional
Tuple = typing.Tuple
KIND_TO_TYPES = {'t2v': ('text_to_video', 'text_to_video'), 'r2v': ('r2v', 'r2v'), 'i2v': ('image_to_video', 'image_to_video'), 'interpolation': ('image_to_video', 'image_to_video'), 'extend': ('extend', 'extend')}

# --- Class: ModelProfile ---
class ModelProfile:
    """ModelProfile(profile_key: 'str' = '', target_credits: 'Optional[int]' = None, speed: 'Optional[str]' = None, fallback_policy: 'str' = 'nearest_lower', legacy_model_key: 'str' = '')"""
    profile_key = ''
    target_credits = None
    speed = None
    fallback_policy = 'nearest_lower'
    legacy_model_key = ''

    def __init__(self, profile_key: 'str' = '', target_credits: 'Optional[int]' = None, speed: 'Optional[str]' = None, fallback_policy: 'str' = 'nearest_lower', legacy_model_key: 'str' = '') -> None:
        pass

    def __repr__(self):
        pass


# --- Class: RuntimeModelResolution ---
class RuntimeModelResolution:
    """RuntimeModelResolution(model_key: 'str', runtime_kind: 'str', feature_type: 'str', speed: 'str', credits: 'int', aspect_ratio: 'str', profile_key: 'str', fallback_reason: 'str' = '')"""
    fallback_reason = ''

    def __init__(self, model_key: 'str', runtime_kind: 'str', feature_type: 'str', speed: 'str', credits: 'int', aspect_ratio: 'str', profile_key: 'str', fallback_reason: 'str' = '') -> None:
        pass

    def __repr__(self):
        pass


# --- Top-Level Functions ---
def _tier_key(tier_mode: 'str' = 'ultra') -> 'str':
    pass

def _is_portrait(aspect_ratio: 'Any') -> 'bool':
    pass

def _credit_for(info: 'Dict[str, Any]', tier_mode: 'str' = 'ultra') -> 'Optional[int]':
    pass

def runtime_kind_from_feature_type(feature_type: 'str', variant: 'Optional[str]' = None) -> 'str':
    pass

def feature_type_for_runtime_kind(runtime_kind: 'str', aspect_ratio: 'str') -> 'str':
    pass

def _truthy(value: 'Any') -> 'bool':
    pass

def picker_kind_for_config(config: 'Dict[str, Any]', *, library_char_r2v: 'bool' = True) -> 'str':
    pass

def profile_from_model_key(model_key: 'str', tier_mode: 'str' = 'ultra') -> 'ModelProfile':
    pass

def infer_runtime_kind(prompt_data: 'Dict[str, Any]', dispatcher_feature: 'str' = '') -> 'str':
    pass

def _candidate_models(runtime_kind: 'str', aspect_ratio: 'str', tier_mode: 'str', variant: 'Optional[str]' = None, duration_seconds: 'Optional[int]' = None) -> 'Tuple[List[Tuple[str, Dict[str, Any], int]], str]':
    pass

def resolve_runtime_model(runtime_kind: 'str', aspect_ratio: 'str', profile: 'ModelProfile | Dict[str, Any] | None', tier_mode: 'str' = 'ultra', variant: 'Optional[str]' = None, duration_seconds: 'Optional[int]' = None) -> 'RuntimeModelResolution':
    pass

def apply_runtime_model(prompt_data: 'Dict[str, Any]', base_model: 'str' = '', aspect_ratio: 'str' = '16:9', tier_mode: 'str' = 'ultra', dispatcher_feature: 'str' = '', variant: 'Optional[str]' = None) -> 'RuntimeModelResolution':
    pass

def _duration_from_prompt(prompt_data: 'Dict[str, Any]', base_model: 'str' = '') -> 'Optional[int]':
    pass
