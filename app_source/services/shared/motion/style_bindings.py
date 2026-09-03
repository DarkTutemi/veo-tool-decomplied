"""
Decompiled / Reconstructed Module: services.shared.motion.style_bindings
Source PyC: style_bindings.pyc

Docstring:
Persistent Draw motion profiles for any visual Style Framework.

Built-in style definitions are release-owned and read-only. User overrides live
in AppData so an update can replace ``resources/styles.json`` without erasing a
chosen motion actor or tool. Writes are atomic and are expected to run off the
Qt GUI thread.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['draw_style_hand_binding', 'draw_style_motion_profile', 'load_draw_style_hand_bindings', 'load_draw_style_motion_profiles', 'save_draw_style_hand_bindings', 'save_draw_style_motion_profiles']

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Mapping = typing.Mapping
Optional = typing.Optional
_SCHEMA_VERSION = 2
_FILENAME = 'draw_motion_style_bindings.json'
_LOCK = <unlocked _thread.RLock object owner=0 count=0 at 0x00000264E2BB3C80>
_HAND_CACHE = None
_PROFILE_CACHE = None
_ACTOR_RENDERERS = {'move': 'object_place', 'hand_pen': 'stroke_reveal', 'pen': 'stroke_reveal'}
__all__ = ['draw_style_hand_binding', 'draw_style_motion_profile', 'load_draw_style_hand_bindings', 'load_draw_style_motion_profiles', 'save_draw_style_hand_bindings', 'save_draw_style_motion_profiles']

# --- Top-Level Functions ---
def _binding_path(path: 'Path | str | None' = None) -> 'Path':
    pass

def _normalise_bindings(value: 'Any') -> 'dict[str, str]':
    pass

def _normalise_profiles(value: 'Any') -> 'dict[str, dict[str, Any]]':
    pass

def _read_document(target: 'Path') -> 'dict[str, Any]':
    pass

def _write_document(target: 'Path', bindings: 'Mapping[str, Any]', profiles: 'Mapping[str, Any]') -> 'None':
    pass

def load_draw_style_hand_bindings(path: 'Path | str | None' = None, force: 'bool' = False) -> 'dict[str, str]':
    pass

def load_draw_style_motion_profiles(path: 'Path | str | None' = None, force: 'bool' = False) -> 'dict[str, dict[str, Any]]':
    pass

def save_draw_style_hand_bindings(bindings: 'Mapping[str, Any]', path: 'Path | str | None' = None) -> 'dict[str, str]':
    pass

def save_draw_style_motion_profiles(profiles: 'Mapping[str, Any]', path: 'Path | str | None' = None) -> 'dict[str, dict[str, Any]]':
    pass

def draw_style_hand_binding(style_id: 'Any') -> 'str':
    pass

def draw_style_motion_profile(style_id: 'Any') -> 'dict[str, Any]':
    pass
