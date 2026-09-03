"""
Decompiled / Reconstructed Module: services.shared.consistency.scene_consistency_helper
Source PyC: scene_consistency_helper.pyc

Docstring:
Anchor Consistency Helper — shared logic for clone_video_tab + transcript_video_tab.

This keeps important visual identity anchors stable across scenes without locking
ambient scenery. It generates refs only for assets that should not drift:
  - locked hero props / vehicles / products / devices / landmarks / fixed sets
  - not generic ocean/sky/coral/bubbles/glow/crowds/minor props

Config/API names still use enable_scene_consistency for backward compatibility.
Public API remains apply_scene_consistency(...) and attach_scene_assets(...).
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['apply_scene_consistency', 'attach_scene_assets']

# --- Module Constants & Globals ---
Callable = typing.Callable
Dict = typing.Dict
List = typing.List
Optional = typing.Optional
Tuple = typing.Tuple
_FRAG_RANK = {'high': 0, 'hard': 0, 'locked': 0, 'medium': 1, 'med': 1, 'low': 2}
__all__ = ['apply_scene_consistency', 'attach_scene_assets']

# --- Top-Level Functions ---
def _fragility_rank_for_id(library: Optional[Dict], asset_id: str) -> int:
    pass

def _strip_runtime_base64_from_meta(meta: Dict) -> Dict:
    pass

def _store_runtime_base64_for_dispatch(asset_id: str, meta: Dict) -> None:
    pass

def _object_meta_for_scene(obj_metadata: Optional[Dict], scene_id: str, logical_object_id: str) -> Tuple[Dict, str]:
    pass

def _get_background_entries(asset_library: Dict) -> List[Dict]:
    pass

def _get_filtered_background_entries(filtered_library: Dict) -> List[Dict]:
    pass

def _scene_character_ids(filtered_library: Dict) -> set:
    pass

def _prepare_scene_character_meta(prompt_data: Dict, filtered_library: Dict, *, character_limit: int = 3) -> Dict:
    pass

def _mark_r2v(prompt_data: Dict) -> None:
    pass

def _inject_visual_quality_field(prompt_data: Dict) -> None:
    pass

def _split_provided(items: list) -> Tuple[list, Dict]:
    pass

def _library_only_categories(library_policy: Optional[Dict]) -> set:
    pass

def _apply_library_only_gate(candidates: list, category: str, locked_categories: set) -> list:
    pass

def apply_scene_consistency(config, result_data: Dict, character_metadata: Dict, dispatcher=None, progress_callback: Optional[Callable] = None, library_policy: Optional[Dict] = None) -> Tuple[Optional[Dict], Optional[Dict], Optional[Dict]]:
    pass

def _plan_field(reference_plan, field: str) -> list:
    pass

def _attach_scene_assets_planned(prompt_data: Dict, scene_id: str, bg_metadata: Dict, obj_metadata: Dict, composite_for_scene: Optional[Dict], reference_limit: int, character_limit: int, reference_plan, scene_asset_plan: Dict, character_metadata: Dict, entity_library: Dict) -> None:
    pass

def attach_scene_assets(prompt_data: Dict, scene_id: str, filtered_library: Dict, bg_metadata: Optional[Dict], obj_metadata: Optional[Dict], composite_frames: Optional[Dict], reference_limit: int = 3, character_limit: int = 3, reference_plan=None, scene_asset_plan: Optional[Dict] = None, character_metadata: Optional[Dict] = None, entity_library: Optional[Dict] = None) -> None:
    pass
