"""
Decompiled / Reconstructed Module: services.video_core.schema
Source PyC: schema.pyc

Docstring:
Data contracts for the unified video scene compiler.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
List = typing.List

# --- Class: CompileResult ---
class CompileResult:
    """Compiled scene prompt and routing metadata for dispatcher/API layers."""
    def __init__(self, text: 'str', payload: 'Dict[str, Any]', reference_plan: 'Any', prompt_data_patch: 'Dict[str, Any]' = <factory>, flow_character_specs: 'List[Dict[str, Any]]' = <factory>, diagnostics: 'Dict[str, Any]' = <factory>) -> None:
        pass

    def __repr__(self):
        pass

