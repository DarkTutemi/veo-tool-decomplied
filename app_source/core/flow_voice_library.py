"""
Decompiled / Reconstructed Module: core.flow_voice_library
Source PyC: flow_voice_library.pyc

Docstring:
View-model helpers for the Media Library voice tab.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
Iterable = typing.Iterable
List = typing.List
DEFAULT_VOICE_CACHE_DIR = WindowsPath('H:/veo-tool/unpack-veotool/VEOFLOWPROMAX.exe_extracted/PYZ.pyz_extracted/resources/voices')

# --- Top-Level Functions ---
def _clean_text(value: 'Any') -> 'str':
    pass

def _voice_preview_keys(voice: 'FlowVoice') -> 'List[str]':
    pass

def _local_voice_preview_path(voice: 'FlowVoice') -> 'str':
    pass

def _voice_preview_path(voice: 'FlowVoice') -> 'str':
    pass

def build_voice_library_rows(voices: 'Iterable[FlowVoice]') -> 'List[Dict[str, Any]]':
    pass

def flow_voice_recipe_from_row(row: 'Dict[str, Any]', *, speaker: 'str' = '') -> 'Dict[str, Any]':
    """Convert one voice row into a character flow_voice recipe."""
    pass

def _media_character_structure(media: 'Dict[str, Any]') -> 'Dict[str, Any]':
    pass

def _voice_matches_row(flow_voice: 'Dict[str, Any]', voice_row: 'Dict[str, Any]') -> 'bool':
    pass

def build_bound_character_voice_rows(media_items: 'Iterable[Dict[str, Any]]', voice_row: 'Dict[str, Any] | None' = None) -> 'List[Dict[str, Any]]':
    pass

def is_local_preview_path(path: 'str') -> 'bool':
    pass
