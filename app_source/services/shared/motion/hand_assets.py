"""
Decompiled / Reconstructed Module: services.shared.motion.hand_assets
Source PyC: hand_assets.pyc

Docstring:
Bundled hand/tool sprites for the shared Draw renderer.

Only production-safe actors are exposed: photorealistic young-adult feminine
and masculine hands with fair/light skin and a bare bottom-entry forearm, plus
hand-free writing tools. Style matching is deterministic so retries render the
same actor instead of visually changing hands between attempts.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['HAND_ASSETS', 'HandAsset', 'default_hand_asset_id', 'hand_asset_options', 'normalize_hand_asset_id', 'resolve_hand_asset']

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Optional = typing.Optional
HAND_ASSETS = (HandAsset(asset_id='female_fair_fineliner_right', label='Young woman · Fair hand / fineliner', resource_path='resources/motion/hands/sprites/bare_long_fair_fineliner.png', native_anchor=(188, 120), t... [truncated]
_BY_ID = {'female_fair_fineliner_right': HandAsset(asset_id='female_fair_fineliner_right', label='Young woman · Fair hand / fineliner', resource_path='resources/motion/hands/sprites/bare_long_fair_fineliner.pn... [truncated]
_HAND_DRAW_ASSETS = ('female_fair_fineliner_right', 'female_fair_pencil_right', 'female_fair_ballpoint_left', 'female_fair_fountain_right', 'female_fair_brush_left', 'female_fair_crayon_right', 'female_fair_stylus_left',... [truncated]
_PLACEMENT_ASSETS = ('female_fair_place_push_right', 'female_fair_place_pinch_right', 'female_fair_place_slide_left', 'female_fair_place_twofinger_right', 'female_fair_place_drag_left', 'female_fair_place_openpalm_right'... [truncated]
_PEN_ONLY_ASSETS = ('marker_only_black', 'pencil_only_wood', 'paintbrush_only', 'fountain_pen_only', 'crayon_only_red', 'technical_fineliner_only', 'mechanical_pencil_only', 'charcoal_stick_only', 'calligraphy_brush_onl... [truncated]
__all__ = ['HAND_ASSETS', 'HandAsset', 'default_hand_asset_id', 'hand_asset_options', 'normalize_hand_asset_id', 'resolve_hand_asset']

# --- Class: HandAsset ---
class HandAsset:
    """HandAsset(asset_id: 'str', label: 'str', resource_path: 'str', native_anchor: 'tuple[int, int]', tool_family: 'str', symbol: 'str', auto_safe: 'bool' = True, dark_background_only: 'bool' = False, motion_role: 'str' = '', forearm_exit_anchor: 'Optional[tuple[int, int]]' = None, entry_edge: 'str' = '')"""
    auto_safe = True
    dark_background_only = False
    motion_role = ''
    forearm_exit_anchor = None
    entry_edge = ''
    render_role = <property object at 0x00000264E2B8FDD0>

    def resolved_path(self) -> 'str':
        pass

    def __init__(self, asset_id: 'str', label: 'str', resource_path: 'str', native_anchor: 'tuple[int, int]', tool_family: 'str', symbol: 'str', auto_safe: 'bool' = True, dark_background_only: 'bool' = False, motion_role: 'str' = '', forearm_exit_anchor: 'Optional[tuple[int, int]]' = None, entry_edge: 'str' = '') -> None:
        pass

    def __repr__(self):
        pass


# --- Top-Level Functions ---
def _female_draw(asset_id: 'str', label: 'str', filename: 'str', anchor: 'tuple[int, int]', tool_family: 'str', symbol: 'str', exit_anchor: 'tuple[int, int]') -> 'HandAsset':
    pass

def _female_place(asset_id: 'str', label: 'str', filename: 'str', anchor: 'tuple[int, int]', symbol: 'str', exit_anchor: 'tuple[int, int]') -> 'HandAsset':
    pass

def _male_draw(asset_id: 'str', label: 'str', filename: 'str', anchor: 'tuple[int, int]', tool_family: 'str', symbol: 'str', exit_anchor: 'tuple[int, int]') -> 'HandAsset':
    pass

def _male_place(asset_id: 'str', label: 'str', filename: 'str', anchor: 'tuple[int, int]', symbol: 'str', exit_anchor: 'tuple[int, int]') -> 'HandAsset':
    pass

def normalize_hand_asset_id(value: 'Any') -> 'str':
    pass

def hand_asset_options() -> 'list[dict[str, Any]]':
    """Return one static QML model; the UI performs no directory scans."""
    pass

def _seed_index(seed: 'str', count: 'int') -> 'int':
    pass

def _pick(asset_ids: 'tuple[str, ...]', seed: 'str') -> 'HandAsset':
    pass

def _automatic_candidates(style_id: 'str', role: 'str') -> 'tuple[str, ...]':
    pass

def resolve_hand_asset(selection: 'Any', style_id: 'str' = '', seed: 'str' = '', background_luminance: 'Optional[float]' = None, motion_role: 'str' = '') -> 'HandAsset':
    """Resolve Auto/Random/explicit selection to one role-compatible sprite."""
    pass

def default_hand_asset_id(style_id: 'Any', motion_role: 'str' = 'hand_draw') -> 'str':
    pass
