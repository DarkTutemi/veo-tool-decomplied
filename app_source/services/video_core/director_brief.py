"""
Decompiled / Reconstructed Module: services.video_core.director_brief
Source PyC: director_brief.pyc

Docstring:
Director-brief normalization for model-facing video prompts.

The backend may keep routing IDs and asset metadata, but the video model should
receive a clean shot brief: intent, environment, camera, timeline beats, and
beat-local dialogue.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['director_brief_has_dialogue', 'normalize_dialogue', 'normalize_director_brief']

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
List = typing.List
Optional = typing.Optional
_SAYS_RE = re.compile('([^"\\n:：]+?)\\s*(?:says|said|nói|noi|nói rằng|speak[s]?|speaks)\\s*[:：,]?\\s*["“](.+?)["”]', re.IGNORECASE)
__all__ = ['director_brief_has_dialogue', 'normalize_dialogue', 'normalize_director_brief']

# --- Top-Level Functions ---
def _clean_text(value: 'Any') -> 'str':
    pass

def _clean_value(value: 'Any') -> 'Any':
    pass

def normalize_dialogue(value: 'Any', default_speaker: 'str' = '') -> 'List[Dict[str, str]]':
    """Normalize any dialogue shape into [{"speaker", "says"}]."""
    pass

def _normalize_actors(value: 'Any') -> 'List[Dict[str, str]]':
    pass

def _normalize_timeline(value: 'Any') -> 'List[Dict[str, Any]]':
    pass

def normalize_director_brief(scene: 'Dict[str, Any]', fallback_duration: 'Optional[int]' = None) -> 'Dict[str, Any]':
    pass

def director_brief_has_dialogue(brief: 'Dict[str, Any]') -> 'bool':
    pass
