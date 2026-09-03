"""
Decompiled / Reconstructed Module: core.content_design_profiles
Source PyC: content_design_profiles.pyc

Docstring:
Content design profiles shared by architect and video prompt services.

The backend keeps one canonical scene envelope for routing. These profiles teach
AI how a chosen content type should shape `director_brief` (legacy `shot_plan`
is still accepted as a compatibility alias).
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
Iterable = typing.Iterable
List = typing.List
CONTENT_TYPES = ['narrative', 'documentary', 'educational', 'tutorial', 'advertisement', 'product_demo', 'montage', 'motivational', 'music_video', 'comedy', 'horror', 'action', 'vlog', 'news', 'recipe', 'travel', 'te... [truncated]
ALIASES = {'story': 'narrative', 'drama': 'narrative', 'fiction': 'narrative', 'doc': 'documentary', 'docs': 'documentary', 'explainer': 'educational', 'education': 'educational', 'learning': 'educational', 'le... [truncated]
COMMON_FIELDS = ['duration', 'atmosphere', 'camera', 'actors', 'timeline', 'audio_sfx', 'constraints']
PROFILES = {'narrative': ContentDesignProfile(key='narrative', label='Narrative Story', purpose='Tell a complete character-driven moment with clear change.', scene_structure='hook -> setup -> rising action -> tu... [truncated]

# --- Class: ContentDesignProfile ---
class ContentDesignProfile:
    """ContentDesignProfile(key: 'str', label: 'str', purpose: 'str', scene_structure: 'str', shot_plan_fields: 'List[str]', asset_strategy: 'str', routing_guidance: 'str', duration_guidance: 'str', example_shot_plan: 'Dict[str, object]')"""
    def __init__(self, key: 'str', label: 'str', purpose: 'str', scene_structure: 'str', shot_plan_fields: 'List[str]', asset_strategy: 'str', routing_guidance: 'str', duration_guidance: 'str', example_shot_plan: 'Dict[str, object]') -> None:
        pass

    def __repr__(self):
        pass


# --- Top-Level Functions ---
def _profile(key: 'str', label: 'str', purpose: 'str', scene_structure: 'str', shot_plan_fields: 'Iterable[str]', asset_strategy: 'str', routing_guidance: 'str', duration_guidance: 'str', example_shot_plan: 'Dict[str, object]') -> 'ContentDesignProfile':
    pass

def normalize_content_type(raw: 'str', default: 'str' = 'narrative') -> 'str':
    pass

def get_content_design_profile(content_type: 'str') -> 'ContentDesignProfile':
    pass

def list_content_types_for_prompt() -> 'str':
    pass

def _render_example(example: 'object', *, clip: 'int') -> 'str':
    pass

def format_content_design_profile_block(content_type: 'str', clip_duration_seconds: 'int' = 8) -> 'str':
    pass

def format_content_design_catalog_block(clip_duration_seconds: 'int' = 8) -> 'str':
    pass
