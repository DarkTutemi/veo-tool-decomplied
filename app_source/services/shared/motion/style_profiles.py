"""
Decompiled / Reconstructed Module: services.shared.motion.style_profiles
Source PyC: style_profiles.pyc

Docstring:
Release-owned Draw style → motion actor bindings.

These profiles are the backend defaults.  The UI may send an explicit
``image_motion_actor_mode`` and hand/tool asset for a job, but Auto always
returns to this table.  Keeping the 40 shipped Draw frameworks here prevents
prompt output, route code, and QML from independently guessing how a style
should animate.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['ACTOR_MODES', 'DRAW_STYLE_MOTION_PROFILES', 'extracted_motion_profile', 'infer_motion_profile_for_style_item', 'motion_profile_for_style', 'normalize_actor_mode', 'renderer_for_actor']

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Mapping = typing.Mapping
ACTOR_MODES = frozenset({'hand_pen', 'pen', 'move'})
DRAW_ACTOR_MODES = frozenset({'pen', 'hand_pen'})
MOVE_ACTOR_MODES = frozenset({'move'})
DRAW_STYLE_MOTION_PROFILES = {'whiteboard_stickman': {'default_actor_mode': 'hand_pen', 'default_hand_asset': 'female_fair_fineliner_right', 'preferred_renderer': 'stroke_reveal'}, 'whiteboard_doodle_clean': {'default_actor_mode'... [truncated]
__all__ = ['ACTOR_MODES', 'DRAW_STYLE_MOTION_PROFILES', 'extracted_motion_profile', 'infer_motion_profile_for_style_item', 'motion_profile_for_style', 'normalize_actor_mode', 'renderer_for_actor']

# --- Top-Level Functions ---
def _profile(actor_mode: 'str', asset_id: 'str', renderer: 'str') -> 'dict[str, str]':
    pass

def normalize_actor_mode(value: 'Any', default: 'str' = 'auto') -> 'str':
    pass

def actor_family(mode: 'Any') -> 'str':
    pass

def allowed_actor_modes(native_mode: 'Any') -> 'tuple[str, ...]':
    pass

def clamp_actor_mode(requested: 'Any', native_mode: 'Any') -> 'str':
    pass

def actor_uses_llm_separation(actor_mode: 'Any') -> 'bool':
    pass

def actor_motion_role(actor_mode: 'Any') -> 'str':
    pass

def motion_profile_for_style(style_id: 'Any', capability: 'Mapping[str, Any] | None' = None) -> 'dict[str, str]':
    pass

def renderer_for_actor(actor_mode: 'Any', preferred: 'Any' = '') -> 'str':
    pass

def extracted_motion_profile(capability: 'Mapping[str, Any] | None') -> 'dict[str, str]':
    pass

def infer_motion_profile_for_style_item(item: 'Mapping[str, Any] | None') -> 'dict[str, str]':
    """Choose a safe first profile when a normal style explicitly opts into Draw.

    Unknown and filled styles default to object placement because the AI Studio
    separator can preserve their authored appearance. Pen drawing is selected
    only when the style text explicitly describes line construction."""
    pass
