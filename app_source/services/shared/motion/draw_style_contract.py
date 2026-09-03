"""
Decompiled / Reconstructed Module: services.shared.motion.draw_style_contract
Source PyC: draw_style_contract.pyc

Docstring:
Canonical Draw-style metadata for custom Style Frameworks.

The bundled Draw catalog is curated explicitly.  User-created styles need the
same runtime contract, while old custom styles (created before Draw authoring
existed) need a conservative in-memory upgrade so UI and renderer agree.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['DRAW_CONTRACT_VERSION', 'DRAW_TOPIC_ID', 'DRAW_TOPIC_NAME', 'VISIBLE_DRAW_RENDERERS', 'disable_draw_style_contract', 'ensure_draw_style_contract', 'has_explicit_draw_contract', 'looks_like_legacy_draw_style', 'normalize_custom_draw_style', 'strip_style_exemplar_inventory']

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Mapping = typing.Mapping
DRAW_TOPIC_ID = 'draw_motion_2d'
DRAW_TOPIC_NAME = '2D Motion / Hand-Drawn'
DRAW_CUSTOM_GROUP_ID = 'custom_draw'
DRAW_CUSTOM_GROUP_NAME = 'Custom Draw'
DRAW_CONTRACT_VERSION = 1
VISIBLE_DRAW_RENDERERS = ('stroke_reveal', 'outline_fill', 'object_place')
_MANDATORY_SUBJECT_RE = re.compile('\\b(?:must|always)\\s+(?:appear|include|be\\s+(?:included|present|visible))\\b|\\b(?:required|mandatory)\\s+(?:in|for)\\s+(?:every|each|all)\\s+scenes?\\b|\\b(?:recurring|signature)(?:\\s+... [truncated]
_EXEMPLAR_CAPTURE_PATTERNS = (re.compile('\\b(?:specifically|such\\s+as|for\\s+example|for\\s+instance|e\\.?\\s*g\\.?)\\s*\\[([^\\]]+)\\]', re.IGNORECASE), re.compile('\\(\\s*(?:such\\s+as|for\\s+example|for\\s+instance|e\\.?\\s*... [truncated]
_EXEMPLAR_REMOVE_PATTERNS = (re.compile('\\s*\\(\\s*(?:such\\s+as|for\\s+example|for\\s+instance|e\\.?\\s*g\\.?)\\s+[^)]*\\)', re.IGNORECASE), re.compile('(?:,\\s*)?\\b(?:specifically|such\\s+as|for\\s+example|for\\s+instance|e\... [truncated]
__all__ = ['DRAW_CONTRACT_VERSION', 'DRAW_TOPIC_ID', 'DRAW_TOPIC_NAME', 'VISIBLE_DRAW_RENDERERS', 'disable_draw_style_contract', 'ensure_draw_style_contract', 'has_explicit_draw_contract', 'looks_like_legacy_dr... [truncated]

# --- Top-Level Functions ---
def _text(value: 'Any') -> 'str':
    pass

def _mapping(value: 'Any') -> 'dict[str, Any]':
    pass

def _framework(item: 'Mapping[str, Any]') -> 'dict[str, Any]':
    pass

def _image_motion(item: 'Mapping[str, Any]') -> 'dict[str, Any]':
    pass

def _normalize_exemplar_phrase(value: 'str') -> 'str':
    pass

def _exemplar_anchors(*values: 'Any') -> 'tuple[str, ...]':
    pass

def _contains_exemplar_anchor(value: 'Any', anchors: 'tuple[str, ...]') -> 'bool':
    pass

def _strip_exemplar_clauses(text: 'str', anchors: 'tuple[str, ...]') -> 'str':
    pass

def _sanitize_runtime_value(value: 'Any', anchors: 'tuple[str, ...]', key: 'str' = '') -> 'Any':
    pass

def strip_style_exemplar_inventory(item: 'Mapping[str, Any]') -> 'dict[str, Any]':
    pass

def has_explicit_draw_contract(item: 'Mapping[str, Any]') -> 'bool':
    pass

def looks_like_legacy_draw_style(item: 'Mapping[str, Any]') -> 'bool':
    """Conservatively recognize pre-Draw custom styles.

    All three evidence families are required: a clean light field, authored
    marks, and sparse/flat 2D construction.  Positive photo/3D language is a
    hard rejection; negative clauses such as ``no 3D`` are removed first."""
    pass

def ensure_draw_style_contract(item: 'Mapping[str, Any]') -> 'dict[str, Any]':
    pass

def disable_draw_style_contract(item: 'Mapping[str, Any]') -> 'dict[str, Any]':
    pass

def normalize_custom_draw_style(item: 'Mapping[str, Any]') -> 'dict[str, Any]':
    pass
