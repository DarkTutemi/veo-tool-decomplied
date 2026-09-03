"""
Decompiled / Reconstructed Module: services.shared.character_autosave
Source PyC: character_autosave.pyc

Docstring:
services/shared/character_autosave.py — shared auto-save of AI-generated
characters into the Media Library.

Used by Master, Clone, and Voice Studio. Each tab generates characters through a
different code path, so the generated image can live in any of four places:

  1. result_data['character_images_base64'][char_id]      (clone / consistency_service)
  2. result_data['character_metadata'][char_id]['base64']
  3. CharacterConsistencyCore._base64_store               (master char-gen, inline base64)
  4. result_data['character_metadata'][char_id]['asset_ref']  (master char-gen, ref only)

The master char-gen path submits with defer_base64_download=True and keeps the
image only as a remote reference (media_name / fife_url) — no inline base64 — so
sources (1)-(3) are often empty. Source (4) materializes a local file from that
reference (local_path on disk, else an auth-aware fife_url download), so no tab
loses its generated characters.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)

# --- Top-Level Functions ---
def _safe_dict(value: 'Any') -> 'dict':
    pass

def _safe_list(value: 'Any') -> 'list':
    pass

def _text(value: 'Any') -> 'str':
    pass

def _resolve_char_base64(char_id: 'str', char_images: 'dict', char_metadata: 'dict') -> 'str':
    pass

def _resolve_char_image_path(char_id: 'str', char_metadata: 'dict') -> 'str':
    pass

def save_generated_characters_to_media_library(result_data: 'dict[str, Any]', *, tag: 'str' = 'auto') -> 'int':
    pass
