"""
Decompiled / Reconstructed Module: services.shared.media.object_normalizer
Source PyC: object_normalizer.pyc

Docstring:
Object reference normalizer — auto-clean product/object images at import.

Owner design (20/7): the import-time AI analysis now answers ONE extra question —
``needs_normalization``. When true, this service regenerates the image as a clean
2x2 catalog turnaround sheet (same product, four angles, white studio background)
using the ORIGINAL image as the generation reference, then OVERWRITES the media
blob in place (same media_id → every existing reference picks up the clean sheet;
``update_media_base64`` also clears the VEO3 upload cache so accounts re-upload).

Everything is best-effort: any failure keeps the original image and logs loudly —
a media import must never break because a beautification step failed.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
Optional = typing.Optional
NORMALIZE_SHEET_PROMPT = 'Professional e-commerce product reference sheet of THIS EXACT product from the reference image — keep the product 100% identical in shape, color, material, proportions, and every distinctive detail. ... [truncated]

# --- Top-Level Functions ---
def normalize_object_media(media_id: 'str', *, reason: 'str' = '', progress: 'Optional[Any]' = None) -> 'Dict[str, Any]':
    pass
