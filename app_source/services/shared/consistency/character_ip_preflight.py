"""
Decompiled / Reconstructed Module: services.shared.consistency.character_ip_preflight
Source PyC: character_ip_preflight.pyc

Docstring:
Shared identity preflight: classify famous/copyrighted characters, then analogue.

Call after analyzer/LLM (INTAKE) and again at CharGen. Famous/public/copyrighted
identities stay in the pipeline: rename + rewrite the CharGen visual prompt into
an original analogue. CHAR_XXX routing IDs never change. Master, Clone, and
Audio-to-Video all share this rewrite so CharGen never portraits a real likeness.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
List = typing.List
BLOCKED_IDENTITY_CLASSES = frozenset({'copyrighted_fiction', 'real_public_person'})
ALLOWED_IDENTITY_CLASSES = frozenset({'original', 'generic_person', 'generic_creature'})
_VISUAL_FIELDS = ('visual_description', 'summary', 'description', 'appearance', 'physical_description', 'face_details', 'hair', 'clothing', 'outfit')
_ANALOGUE_CONTRACT = 'Original analogue character only — not a real public figure, celebrity likeness, or copyrighted franchise identity. Change face, costume marks, emblems and signature accessories. Keep role, age band,... [truncated]
_SKIP_REWRITE_KEYS = frozenset({'clone_job_id', 'ip_evidence', 'identity_class', 'identity_evidence', 'job_id', 'id', 'media_id', 'char_id', 'scene_id'})
_VIETNAMESE_CHARS = 'àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđ'

# --- Top-Level Functions ---
def _text(value: 'Any') -> 'str':
    pass

def _norm_class(value: 'Any') -> 'str':
    pass

def iter_analysis_characters(result_data: 'Dict[str, Any] | None') -> 'List[Dict[str, Any]]':
    pass

def character_identity_class(char: 'Dict[str, Any] | None') -> 'str':
    pass

def collect_blocked_characters(result_data: 'Dict[str, Any] | None') -> 'List[Dict[str, Any]]':
    pass

def _looks_like_protected_name(name: 'str') -> 'bool':
    pass

def _analogue_name(char: 'Dict[str, Any]') -> 'str':
    pass

def _replace_name_in_text(text: 'str', old_name: 'str', new_name: 'str') -> 'str':
    pass

def _rewrite_name_mentions(result_data: 'Dict[str, Any]', old_name: 'str', new_name: 'str') -> 'None':
    pass

def _analogue_visual(value: 'Any', old_name: 'str' = '') -> 'Any':
    pass

def apply_character_ip_analogue(result_data: 'Dict[str, Any] | None') -> 'Dict[str, Any]':
    pass
