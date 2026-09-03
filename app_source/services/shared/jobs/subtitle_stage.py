"""
Decompiled / Reconstructed Module: services.shared.jobs.subtitle_stage
Source PyC: subtitle_stage.pyc

Docstring:
Durable metadata contract for the post-picture-lock subtitle pipeline.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Mapping = typing.Mapping
SUBTITLE_SUCCESS_STAGES = frozenset({'skipped', 'disabled', 'complete'})
SUBTITLE_TERMINAL_STAGES = frozenset({'skipped', 'disabled', 'failed', 'complete'})

# --- Top-Level Functions ---
def apply_subtitle_stage(current: 'Mapping[str, Any] | None', stage: 'str', message: 'str') -> 'dict[str, Any]':
    pass
