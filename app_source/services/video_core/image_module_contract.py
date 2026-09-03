"""
Decompiled / Reconstructed Module: services.video_core.image_module_contract
Source PyC: image_module_contract.pyc

Docstring:
Shared single-frame module contract for IMAGE-story prompt generation.

Parallel to ``module_contract.py`` (which is timeline/motion oriented for VIDEO
scenes). An image scene is ONE frozen frame: no intra-scene timeline, no motion,
no dialogue/narration/sound. The audio already carries all voice — each image is
a silent still that ILLUSTRATES what the audio means during its time window.

Two philosophies differ from the video contract:
  • No ``timeline``. A scene is described as a single composed frame.
  • Time windows are VARIABLE and LLM-decided (0-5s, 5-15s, …) and must tile the
    whole audio with no gaps → Σ duration == total_duration by construction.

Used by:
  • image_analyzer_service — ``build_image_scene_module_contract`` +
    ``build_image_scene_response_blueprint`` feed the analyze prompt.
  • image_story_service — ``compile_image_prompt`` flattens a scene's ``image``
    dict into the text prompt handed to the image model.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
List = typing.List
Mapping = typing.Mapping
Optional = typing.Optional
IMAGE_MODULE_POOL = [{'id': 'subjects', 'purpose': 'WHO is in the frame. For every visible recurring actor use {entity_id, name, role, action, pose, expression, gaze, placement}; describe the exact held action/state for ... [truncated]
IMAGE_CONTENT_TYPE_PROFILES = {'photo_cinematic': {'render_type': 'PHOTO', 'module_ids': ['subjects', 'interaction', 'setting', 'objects', 'composition', 'lighting', 'color_mood', 'style_application', 'atmosphere', 'reference', 'c... [truncated]
_DEFAULT_PROFILE = 'photo_cinematic'
_COMPILE_ORDER = ['subject', 'subjects', 'action', 'interaction', 'setting', 'objects', 'composition', 'lighting', 'color_mood', 'atmosphere', 'style_application']
_BLANK_TOKENS = {'', 'na', 'false', 'n/a', 'empty', 'null', '-', '…', 'unknown', '—', 'no', 'none', 'nil', 'tbd', '...'}

# --- Top-Level Functions ---
def image_content_type_profile(content_type: 'str | None') -> 'Dict[str, Any]':
    pass

def image_module_ids_for_content_type(content_type: 'str | None') -> 'List[str]':
    pass

def _is_blank(text: 'Any') -> 'bool':
    pass

def _prune_image(value: 'Any') -> 'Any':
    """Recursively drop valueless fields (None / "" / [] / {} / placeholder tokens like
    'none','n/a','-') so only content-bearing fields reach the model — less noise."""
    pass

def _append_scene_text(body: 'str', text_field: 'Any') -> 'str':
    pass

def _clean_value(value: 'Any') -> 'str':
    pass

def _named_frame_item(value: 'Any', *, kind: 'str') -> 'str':
    pass

def _render_frame_items(value: 'Any', *, kind: 'str') -> 'str':
    pass

def _reference_category(entity_id: 'str') -> 'str':
    pass

def _entity_library_index(entity_library: 'Mapping[str, Any] | None') -> 'Dict[str, Dict[str, Any]]':
    pass

def build_image_reference_manifest(scene: 'Mapping[str, Any]', entity_library: 'Mapping[str, Any] | None', selected_metadata: 'Mapping[str, Any] | None') -> 'List[Dict[str, Any]]':
    """Bind ordered provider ref slots to semantic entities for one still.

    ``selected_metadata`` is already scene-scoped by shared ATTACH. Its insertion
    order is therefore the exact image-input order. The backend performs no
    semantic guess here: it maps that deterministic order back to names and lock
    roles authored by the LLM/entity library."""
    pass

def append_image_reference_binding(prompt: 'str', reference_manifest: 'Optional[List[Dict[str, Any]]]') -> 'str':
    pass

def prepend_image_style_contract(prompt: 'str', style_snapshot: 'Mapping[str, Any] | None') -> 'str':
    pass

def compile_image_prompt(scene: 'Dict[str, Any]', reference_manifest: 'Optional[List[Dict[str, Any]]]' = None) -> 'str':
    """Flatten a scene's ``image`` descriptor into the text prompt for the image model.

    Reads scene["image"] (or the scene itself if already flat). Joins the present
    frozen-frame fields in a readable order, appends on-image text as an explicit
    instruction, and moves negatives into a trailing constraints block. Entity ids
    are stripped to human names via clean_model_facing_scene_text."""
    pass

def build_image_scene_response_blueprint(*, total_duration: 'int', min_scene_seconds: 'int' = 3, max_scene_seconds: 'int' = 15) -> 'Dict[str, Any]':
    pass

def build_image_scene_module_contract(*, total_duration: 'int' = 0, min_scene_seconds: 'int' = 3, max_scene_seconds: 'int' = 15, timing_locked: 'bool' = False) -> 'str':
    pass

def build_clone_image_scene_authoring_contract() -> 'str':
    pass
