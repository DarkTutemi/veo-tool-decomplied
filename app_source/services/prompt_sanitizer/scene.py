"""
Decompiled / Reconstructed Module: services.prompt_sanitizer.scene
Source PyC: scene.pyc

Docstring:
Scene-level pre-dispatch sanitizers.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
DEFAULT_SCENE_STRIP_KEYS = ('action_extend', 'extend_of', 'extend', 'scene_id', 'visualization_type', 'audio_topic')

# --- Top-Level Functions ---
def strip_runtime_scene_fields(scene: dict, *, keys=('action_extend', 'extend_of', 'extend', 'scene_id', 'visualization_type', 'audio_topic')) -> dict:
    pass
