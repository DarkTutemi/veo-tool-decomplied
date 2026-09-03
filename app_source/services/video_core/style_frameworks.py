"""
Decompiled / Reconstructed Module: services.video_core.style_frameworks
Source PyC: style_frameworks.pyc

Docstring:
Style framework resolver for structural visual systems.

Surface styles continue to work as before.
Framework styles add extra prompt blocks that steer script generation,
asset generation, and per-scene dispatch toward a fixed visual ontology.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
Optional = typing.Optional
Tuple = typing.Tuple
_STYLES_CACHE = {}
_STYLES_CACHE_KEY = ('', 0.0)
_SCENE_CONTENT_EXAMPLE_KEYS = {'scenario_mapping', 'good_examples', 'scene_mapping', 'bad_examples', 'examples'}
_STYLIZED_3D_IDS = {'pixar_3d', 'dreamworks', 'plastic_toy'}
_ANIME_IDS = {'anime', 'manga'}
_TOON_IDS = {'rubber_hose', 'disney_2d', 'cartoon_2d', 'children_book', 'cel_shaded'}
_ILLUSTRATION_IDS = {'pop_art', 'baroque', 'cubism', 'comic_book', 'graffiti_street_art', 'sumi_e', 'ukiyo_e', 'art_nouveau', 'art_deco', 'a_14th_century_gothic_miniature_manuscript_aesthetic_utilizing_f', 'studio_ghibli... [truncated]
_MATERIAL_WORLD_IDS = {'sketch_animation', 'holographic', 'glitch_art', 'sand_art', 'ascii_art', 'claymation', 'organic', 'mosaic', 'embroidery', 'silhouette', 'knitting', 'pixel_art', 'chalk_art', 'stained_glass', 'metal'... [truncated]
_SURFACE_GENRE_IDS = {'film_noir', 'psychedelic', 'matte_painting', 'film_grain_vintage', 'vhs_retro_material', 'monochrome_bw', 'cyberpunk', 'gothic', 'synthwave', 'a_dark_atmospheric_medieval_aesthetic_characterized_by_... [truncated]
_STRUCTURAL_WORLD_IDS = {'negative_space', 'thin_white_line_stickman', 'pictogram_iso', 'egyptian_hieroglyphic', 'blueprint_schematic', 'continuous_line', 'isometric_low_poly', 'whiteboard_stickman', 'ikea_exploded_view'}

# --- Top-Level Functions ---
def _load_styles_json() -> 'Dict[str, Any]':
    pass

def _find_material(material_id: 'str' = '', material_name: 'str' = '') -> 'Optional[Dict[str, Any]]':
    pass

def _v2_find_item(style_id: 'str', *, bucket: 'Optional[str]' = None) -> 'Optional[Dict[str, Any]]':
    pass

def _pick_primary_v2(structural_style_id: 'str', structural_camera_id: 'str') -> 'Tuple[Optional[Dict[str, Any]], str]':
    pass

def build_default_framework_template() -> 'Dict[str, Any]':
    pass

def _as_list(value: 'Any') -> 'list':
    pass

def _as_dict(value: 'Any') -> 'Dict[str, Any]':
    pass

def _unique_list(*lists: 'Any') -> 'list':
    pass

def _join_text(*values: 'Any') -> 'str':
    pass

def _join_unique_text(*values: 'Any') -> 'str':
    pass

def _append_unique_text(base: 'str', addition: 'str') -> 'str':
    pass

def _extend_unique_list(existing: 'Any', additions: 'Any') -> 'list':
    pass

def _sanitize_style_surface_language(text: 'Any') -> 'Any':
    pass

def _sanitize_framework_definition(value: 'Any') -> 'Any':
    pass

def strip_scene_content_examples(framework: 'Any') -> 'Dict[str, Any]':
    pass

def _strip_generated_style_contract(text: 'Any') -> 'Any':
    pass

def _profile_for_style(style_id: 'str', style_item: 'Dict[str, Any]', style_fw: 'Dict[str, Any]') -> 'Dict[str, str]':
    """Return a normalized visual contract profile for weak built-in styles."""
    pass

def compile_style_contract_for_item(style_id: 'str', style_item: 'Optional[Dict[str, Any]]' = None, framework_definition: 'Optional[Dict[str, Any]]' = None, raw_style_prompt: 'str' = '') -> 'Dict[str, Any]':
    """Strengthen weak style definitions into an operational visual contract.

    This is intentionally runtime-safe: existing strong material-world frameworks
    keep their hand-authored locks, while weak built-in/custom styles gain the
    missing rules needed by Master/Clone/Transcript/manual dispatch paths."""
    pass

def _anchor_strategy(*values: 'Any') -> 'str':
    pass

def _framework_type(*frameworks: 'Dict[str, Any]') -> 'str':
    pass

def _injection_strategy(framework_type: 'str', *frameworks: 'Dict[str, Any]') -> 'str':
    pass

def _lookup_v3(item_id: 'str', kind: 'str') -> 'Dict[str, Any]':
    pass

def _merge_frameworks(style_fw: 'Dict[str, Any]', camera_fw: 'Dict[str, Any]', raw_style_prompt: 'str', camera_prompt: 'str') -> 'Dict[str, Any]':
    pass

def resolve_style_framework(*, style_id: 'str' = '', camera_id: 'str' = '', raw_style_prompt: 'str' = '', camera_prompt: 'str' = '', context: 'Optional[Dict[str, Any]]' = None, material_id: 'str' = '', material_name: 'str' = '', structural_style_id: 'str' = '', structural_camera_id: 'str' = '', surface_style_id: 'str' = '', surface_camera_id: 'str' = '') -> 'Dict[str, Any]':
    """Resolve the JIT framework knowledge package for prompt generation.

    v3 callers pass `style_id` and `camera_id`. Legacy callers are accepted and
    mapped so old tabs continue to receive a framework package while they are
    being migrated."""
    pass
