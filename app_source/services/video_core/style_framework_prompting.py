"""
Decompiled / Reconstructed Module: services.video_core.style_framework_prompting
Source PyC: style_framework_prompting.pyc

Docstring:
Shared framework prompt helpers for non-pipeline services.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
List = typing.List
Optional = typing.Optional

# --- Top-Level Functions ---
def _clean_list(values: 'Any') -> 'List[str]':
    pass

def _json_block(payload: 'Dict[str, Any]') -> 'str':
    pass

def build_framework_prompt_block(style_package: 'Optional[Dict[str, Any]]') -> 'str':
    pass

def _truncate(text: 'str', limit: 'int' = 500) -> 'str':
    pass

def build_pre_generation_style_anchor(style_package: 'Optional[Dict[str, Any]]') -> 'str':
    """Short visual anchor injected BEFORE the LLM writes scenes.

    Works for both framework styles and surface styles. The goal is to seed
    the model with the visual direction (lighting, palette, lens, mood) so
    the scene descriptions it writes are visually consistent with the style
    from the start — instead of being neutral text that depends on a later
    suffix to look right (the JIT-forgets problem).

    Returns "" when no style is selected."""
    pass

def build_style_framework_extraction_prompt() -> 'str':
    pass

def build_manual_prompt_style_prefix(style_package: 'Optional[Dict[str, Any]]') -> 'str':
    """Compact style prefix for manual prompt tabs (Normal / Batch Image).

    Manual tabs do not have an upstream AI planning pass, so they cannot rely on
    the model rewriting neutral user text into a framework-native asset plan.
    This prefix gives the generation model the structural rules directly while
    keeping the user's prompt untouched."""
    pass

def build_post_generation_style_fields(style_package: 'Optional[Dict[str, Any]]', raw_style_fallback: 'Optional[str]' = None, raw_camera_fallback: 'Optional[str]' = None) -> 'Dict[str, str]':
    pass
