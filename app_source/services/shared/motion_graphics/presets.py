"""
Decompiled / Reconstructed Module: services.shared.motion_graphics.presets
Source PyC: presets.pyc

Docstring:
Deterministic Time Graphics design-system catalog.

The LLM may select one catalog entry, but it never authors colors, fonts or
FFmpeg syntax.  Rendering stays reproducible across source and frozen builds.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['VARIANTS_PER_PRESET', 'apply_preset_contract', 'density_ids', 'density_options', 'normalize_variation_seed', 'preset_ids', 'preset_options', 'resolve_density', 'resolve_preset', 'resolve_preset_variant', 'variation_index']

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Mapping = typing.Mapping
_BASE = {'primary': 'FFFFFF', 'accent': '4E8CFF', 'muted': 'C9D4E5', 'shadow': '000000', 'panel': '101827', 'panel_alpha': 70, 'font_role': 'display', 'outline': 2, 'shadow_depth': 1, 'tracking': 0, 'rail_y':... [truncated]
_PRESETS = {'historical_cinematic': {'primary': 'FFFFFF', 'accent': 'E7B866', 'muted': 'E8DDC8', 'shadow': '000000', 'panel': '211A12', 'panel_alpha': 70, 'font_role': 'editorial', 'outline': 2, 'shadow_depth': ... [truncated]
_DENSITIES = {'minimal': {'label': 'Tối giản', 'description': 'Chỉ chương, niên đại và mốc thật sự quan trọng.', 'max_overlays_per_clip': 2}, 'balanced': {'label': 'Cân bằng', 'description': 'Đủ định hướng thời gi... [truncated]
VARIANTS_PER_PRESET = 96
_MAX_VARIATION_SEED = 2147483647
__all__ = ['VARIANTS_PER_PRESET', 'apply_preset_contract', 'density_ids', 'density_options', 'normalize_variation_seed', 'preset_ids', 'preset_options', 'resolve_density', 'resolve_preset', 'resolve_preset_vari... [truncated]

# --- Top-Level Functions ---
def normalize_variation_seed(value: 'Any') -> 'int':
    pass

def variation_index(value: 'Any') -> 'int':
    pass

def _shift_hex(value: 'str', *, hue: 'float', saturation: 'float', brightness: 'float') -> 'str':
    pass

def _variant_rail_choices(preset: 'Mapping[str, Any]') -> 'tuple[str, ...]':
    pass

def resolve_preset_variant(name: 'str', variation_seed: 'Any' = 0) -> 'dict[str, Any]':
    pass

def preset_ids() -> 'tuple[str, ...]':
    pass

def density_ids() -> 'tuple[str, ...]':
    pass

def resolve_preset(name: 'str') -> 'dict[str, Any]':
    pass

def resolve_density(name: 'str') -> 'dict[str, Any]':
    pass

def preset_options(*, include_auto: 'bool' = True) -> 'list[dict[str, Any]]':
    pass

def density_options() -> 'list[dict[str, Any]]':
    pass

def apply_preset_contract(script: 'Mapping[str, Any]', *, preset_id: 'str', density: 'str', locale_contract: 'Mapping[str, Any]', variation_seed: 'Any' = 0, signature_id: 'str' = 'auto') -> 'dict[str, Any]':
    pass
