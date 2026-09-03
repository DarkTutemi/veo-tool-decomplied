"""
Decompiled / Reconstructed Module: services.shared.media.image_reference_inputs
Source PyC: image_reference_inputs.pyc

Docstring:
Resolve image-generation references for the account executing the job.

Image generation accepts Google ``mediaName`` values in ``imageInputs``.  UI
routes, however, persist references as Media Library ids and/or local paths.
Those values are account-independent until dispatch chooses a worker, so the
upload must happen at the execution edge for that exact account.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)

# --- Top-Level Functions ---
def _text(value: 'Any') -> 'str':
    pass

def _str_list(value: 'Any') -> 'list[str]':
    pass

def _first_list(data: 'dict[str, Any]', *keys: 'str') -> 'list[str]':
    pass

def _looks_like_remote_media_name(value: 'str') -> 'bool':
    pass

def _append_image_input(image_inputs: 'list[dict[str, str]]', seen: 'set[str]', media_name: 'Any') -> 'bool':
    pass

def has_image_reference_sources(data: 'dict[str, Any]') -> 'bool':
    pass

def resolve_image_reference_inputs(data: 'dict[str, Any]', account: 'dict[str, Any]', *, limit: 'int' = 10) -> 'list[dict[str, str]]':
    pass
