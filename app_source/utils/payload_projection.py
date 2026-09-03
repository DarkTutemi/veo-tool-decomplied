"""
Decompiled / Reconstructed Module: utils.payload_projection

Docstring:
Lightweight projections for queue persistence and QML-facing payloads.
"""

from __future__ import annotations
import sys, os, typing
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Optional = typing.Optional
_OMITTED = '<binary payload omitted>'
_BLOB_KEY_PARTS = ('base64', 'thumbnail_data', 'image_data', 'audio_data', 'video_data', 'file_bytes', 'raw_bytes')

# --- Top-Level Functions ---
def _is_blob_key(key: 'object') -> 'bool':
    pass

def project_payload(value: 'Any', *, max_depth: 'int' = 16, max_text_chars: 'Optional[int]' = None, _depth: 'int' = 0, _key: 'object' = '') -> 'Any':
    # [PyArmor BCC constants]: '<nested payload omitted>', 'isinstance', 'dict', 'items', 'str', 'project_payload', 'max_depth', 'max_text_chars', '_depth', 1, '_key', 'list', 'tuple', 'bytes', 'bytearray'
    pass

def project_for_persistence(value: 'Any') -> 'Any':
    # [PyArmor BCC constants]: 'project_payload', 'max_depth', 20, 'max_text_chars'
    pass

def project_for_qml(value: 'Any') -> 'Any':
    # [PyArmor BCC constants]: 'project_payload', 'max_depth', 14, 'max_text_chars', 250000
    pass
