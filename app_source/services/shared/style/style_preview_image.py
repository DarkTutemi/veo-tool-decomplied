"""
Decompiled / Reconstructed Module: services.shared.style.style_preview_image
Source PyC: style_preview_image.pyc

Docstring:
WebP encoding helpers for style/camera preview images.

Style previews are opaque, photographic AI images shown in a grid — lossy WebP
(q≈82) cuts file size ~70% vs PNG with no perceptible loss, so the grid loads
and decodes far faster. The system already resolves ``.webp`` first
(``_STYLE_PREVIEW_EXTS``); these helpers make sure that's what actually lands on
disk, both for newly generated previews and a one-time migration of old PNGs.

All functions are defensive: if Pillow is missing or an image can't be decoded
they return ``None``/``False`` so callers can fall back to the original bytes
instead of losing a preview.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Optional = typing.Optional
WEBP_QUALITY = 82
WEBP_METHOD = 6
_RASTER_SUFFIXES = {'.png', '.jpg', '.tif', '.gif', '.bmp', '.jpeg', '.tiff'}

# --- Top-Level Functions ---
def is_webp_bytes(raw: 'bytes') -> 'bool':
    pass

def encode_webp(raw: 'bytes', *, quality: 'int' = 82) -> 'Optional[bytes]':
    pass

def convert_file_to_webp(path: 'Path', *, quality: 'int' = 82) -> 'Optional[Path]':
    pass

def convert_dir_to_webp(base: 'Path', *, quality: 'int' = 82) -> 'dict':
    """Recursively convert every raster preview under ``base`` to WebP.

    Idempotent: existing ``.webp`` files are skipped. Never raises."""
    pass
