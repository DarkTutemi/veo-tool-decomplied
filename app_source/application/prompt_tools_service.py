"""
Decompiled / Reconstructed Module: application.prompt_tools_service
Source PyC: prompt_tools_service.pyc

Docstring:
Headless helpers for prompt editing dialogs.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict

# --- Top-Level Functions ---
def stats(text: 'str') -> 'Dict[str, Any]':
    pass

def validate_prompt(text: 'str', *, require_json: 'bool' = False) -> 'Dict[str, Any]':
    pass

def save_prompt(text: 'str', *, require_json: 'bool' = False) -> 'Dict[str, Any]':
    pass

def parse_bulk_items(text: 'str', mode: 'str' = 'auto') -> 'list[str]':
    pass

def bulk_import_preview(text: 'str', mode: 'str' = 'auto') -> 'Dict[str, Any]':
    pass

def _clean_items(items: 'Any') -> 'list[str]':
    pass

def _parse_json_blocks(text: 'str') -> 'list[str]':
    pass

def _json_to_prompt(obj: 'Any') -> 'str':
    pass

def _parse_markers(text: 'str') -> 'list[str]':
    pass

def _parse_scenes(text: 'str') -> 'list[str]':
    pass

def _parse_numbered(text: 'str') -> 'list[str]':
    pass

def _parse_bullets(text: 'str') -> 'list[str]':
    pass

def _parse_paragraphs(text: 'str') -> 'list[str]':
    pass
