"""
Decompiled / Reconstructed Module: core.gemini_web.blocks
Source PyC: blocks.pyc

Docstring:
Gemini Web freepath media blocks — soft timestamps in prompt (no VideoMetadata path).

AI Studio free path:
  - **video** → hard window via Part.start_offset/end_offset (VideoMetadata wire)
  - **audio** → soft time-range text + independent calls (``_run_stateless_media_blocks``)

Gemini Web has **no** hard media window (content-push file id only). Therefore:
  - **audio** → same soft prefix + stateless blocks as AI Studio audio freepath
  - **video** → same soft prefix (convert windows → timestamps in prompt) + optional
    Phase-0 envelope scan (text twin of AI Studio ``_run_video_blocks`` Phase-0/1,
    but window is soft-prompt only)

1-1 freepath contracts verified against ``DirectProvider._soft_time_range_prefix`` and
stateless block/correction task shapes.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Callable = typing.Callable
Optional = typing.Optional
Sequence = typing.Sequence
MAX_BLOCK_CORRECTIONS = 3
CallFn = typing.Callable[[str], str]

# --- Top-Level Functions ---
def soft_time_range_prefix(start: 'int', end: 'int', *, kind: 'str' = 'media') -> 'str':
    pass

def video_phase0_prompt(base_prompt: 'str') -> 'str':
    pass

def block_task_prompt(*, start: 'int', end: 'int', blk_text: 'str' = '', missing: 'Optional[Sequence[str]]' = None, attempt: 'int' = 0) -> 'str':
    pass

def compose_block_user_text(*, base_prompt: 'str', start: 'int', end: 'int', blk_text: 'str' = '', envelope: 'Optional[dict]' = None, missing: 'Optional[Sequence[str]]' = None, attempt: 'int' = 0, range_kind: 'str' = 'media') -> 'str':
    pass

def extract_json_loose(text: 'str') -> 'Any':
    pass

def scene_items(resp_text: 'str') -> 'dict[str, dict]':
    pass

def absorb_envelope(envelope: 'dict', resp_text: 'str') -> 'None':
    pass

def normalize_blocks(blocks: 'Sequence[Any]') -> 'list[dict]':
    pass

def detect_media_kind(mime_or_path: 'str' = '', explicit: 'str' = '') -> 'str':
    pass

def run_stateless_media_blocks(*, call_fn: 'CallFn', prompt: 'str', blocks: 'Sequence[Any]', media_kind: 'str' = 'media', on_progress: 'Optional[Callable[[int, str], None]]' = None, max_corrections: 'int' = 3, video_phase0: 'bool' = True) -> 'str':
    """Run freepath block loop; return merged JSON envelope string.

    ``call_fn(user_text)`` must be an **independent** freepath generate that
    always attaches the same uploaded media (caller binds files)."""
    pass
