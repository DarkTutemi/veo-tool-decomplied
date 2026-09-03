"""
Decompiled / Reconstructed Module: services.shared.flow.flow_voice_runtime
Source PyC: flow_voice_runtime.pyc

Docstring:
Runtime boundary for Flow voice-lock prompt data.

Prompt compilers produce ``flow_character_specs`` as a route-agnostic intent.
Dispatcher/API code consumes ``flow_character_ids`` / ``reference_entities``.
This module owns that conversion so tabs do not each invent their own bridge.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict

# --- Top-Level Functions ---
def attach_flow_voice_runtime_entities(prompt_data: 'Dict[str, Any]', *, source: 'str' = '') -> 'Dict[str, Any]':
    pass
