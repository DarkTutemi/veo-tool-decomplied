"""
Decompiled / Reconstructed Module: services.video_core.style_combo_synthesis
Source PyC: style_combo_synthesis.pyc

Docstring:
AI synthesis for structural + surface style combos.

When the user selects both a structural style (form language) and a surface
style (render treatment), plain text concatenation produces two competing
world-replacement contracts. This module calls the AI provider ONCE per style
pair to fuse them into a single unified contract:

- Form / silhouette / shape language / scenario logic   <- structural style
- Material / surface / palette / lighting / render finish <- surface style
- Conflict on look -> surface wins; conflict on form -> structural wins
- ONE world rule: the result must read as a single coherent visual world.

Results are cached on disk keyed by the (structural_id, surface_id) pair plus
a fingerprint of both source contracts, so the AI is only called again when a
style definition actually changes. All failures fall back to the legacy
`_merge_frameworks` concatenation in style_frameworks.py.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
Optional = typing.Optional
_CACHE_FILENAME = 'style_combo_cache.json'
_CACHE_SCHEMA_VERSION = 1
_AI_FAILURE_COOLDOWN_SECONDS = 600.0
_cache_lock = <unlocked _thread.lock object at 0x00000264E77F38C0>
_failed_pairs = {}
_SYNTHESIS_SYSTEM_INSTRUCTION = 'You are a senior visual development director who fuses two video style contracts into ONE coherent hybrid visual world. Return ONLY valid JSON matching the requested schema.'
_SYNTHESIS_SCHEMA_HINT = '{\n  "summary": "1-2 sentence description of the fused hybrid world",\n  "style_contract": {\n    "subject_transform": "how people/animals/faces look in the fused world",\n    "environment_transform"... [truncated]

# --- Top-Level Functions ---
def _text(value: 'Any') -> 'str':
    pass

def _as_dict(value: 'Any') -> 'Dict[str, Any]':
    pass

def _join_text(*values: 'Any') -> 'str':
    pass

def _unique_list(*lists: 'Any') -> 'list':
    pass

def _cache_path() -> 'Path':
    pass

def _load_cache() -> 'Dict[str, Any]':
    pass

def _save_cache(cache: 'Dict[str, Any]') -> 'None':
    pass

def _combo_key(structural_id: 'str', surface_id: 'str') -> 'str':
    pass

def _fingerprint(structural_fw: 'Dict[str, Any]', surface_fw: 'Dict[str, Any]') -> 'str':
    pass

def _contract_brief(label: 'str', item: 'Dict[str, Any]', fw: 'Dict[str, Any]') -> 'str':
    pass

def _build_synthesis_prompt(structural_item: 'Dict[str, Any]', surface_item: 'Dict[str, Any]', structural_fw: 'Dict[str, Any]', surface_fw: 'Dict[str, Any]') -> 'str':
    pass

def _validate_synthesis(data: 'Any') -> 'Optional[Dict[str, Any]]':
    pass

def _call_ai(prompt: 'str') -> 'Optional[Dict[str, Any]]':
    pass

def get_combo_synthesis(structural_id: 'str', surface_id: 'str', *, structural_fw: 'Dict[str, Any]', surface_fw: 'Dict[str, Any]', structural_item: 'Optional[Dict[str, Any]]' = None, surface_item: 'Optional[Dict[str, Any]]' = None, allow_ai: 'bool' = True) -> 'Optional[Dict[str, Any]]':
    pass

def prewarm_combo_synthesis(structural_id: 'str', surface_id: 'str') -> 'None':
    pass

def apply_combo_synthesis(merged_fw: 'Dict[str, Any]', synthesis: 'Dict[str, Any]') -> 'Dict[str, Any]':
    pass
