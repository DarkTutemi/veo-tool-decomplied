"""
Decompiled / Reconstructed Module: core.asset_schema
Source PyC: asset_schema.pyc
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
List = typing.List
CANONICAL_ASSET_LIBRARY_CONTRACT = 'ASSET LIBRARY SCHEMA\n- asset_library.characters: reusable character anchors, ids CHAR_000, CHAR_001, ...\n- asset_library.objects: reusable prop/product/story anchors, ids OBJ_000, OBJ_001, ...\n- a... [truncated]

# --- Top-Level Functions ---
def build_asset_library_contract() -> 'str':
    pass

def empty_asset_library() -> 'Dict[str, List[Dict[str, Any]]]':
    pass

def normalize_asset_library_schema(asset_library: 'Any', *, keep_legacy_settings: 'bool' = True) -> 'Dict[str, Any]':
    pass

def canonicalize_prompt_schema_text(text: 'str') -> 'str':
    pass

def _dict_list(value: 'Any') -> 'List[Dict[str, Any]]':
    pass

def _list(value: 'Any') -> 'List[Any]':
    pass
