"""
Decompiled / Reconstructed Module: services.shared.motion.aistudio_asset_separator
Source PyC: aistudio_asset_separator.pyc

Docstring:
Two-call AI Studio separation for Draw object-placement scenes.

The model does semantic editing only: one same-canvas transparent foreground
sheet and one clean background plate. OpenCV remains responsible for turning
the foreground alpha into independent animation layers.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['SeparatedAssetPair', 'compose_separation_matte', 'separate_scene_assets']

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Optional = typing.Optional
_MODEL = 'gemini-3.1-flash-lite-image'
_CONTRACT_VERSION = 'draw-assets-v2'
_FOREGROUND_PROMPT = 'Cut the foreground subjects out of this image. Keep every person, animal, vehicle, prop, and piece of equipment in the exact original pixels and original positions. Replace ALL background — sky, grou... [truncated]
_BACKGROUND_PROMPT = 'Return one clean background plate on the same-size canvas. Remove every foreground subject (people, animals, vehicles, props) and naturally fill only the holes they leave. Keep the original style, te... [truncated]
_MAGENTA_BGR = (255, 0, 255)
_GREEN_BGR = (0, 255, 0)
__all__ = ['SeparatedAssetPair', 'compose_separation_matte', 'separate_scene_assets']

# --- Class: SeparatedAssetPair ---
class SeparatedAssetPair:
    """SeparatedAssetPair(foreground_path: 'str', background_path: 'str', model: 'str', cached: 'bool')"""
    def __init__(self, foreground_path: 'str', background_path: 'str', model: 'str', cached: 'bool') -> None:
        pass

    def __repr__(self):
        pass


# --- Top-Level Functions ---
def _mime_for_path(path: 'str') -> 'str':
    pass

def _first_image_bytes(response: 'Any') -> 'bytes':
    pass

def _decode_image(payload: 'bytes') -> 'Any':
    pass

def _write_png(decoded: 'Any', output_path: 'str') -> 'None':
    pass

def _as_bgr(decoded: 'Any') -> 'Any':
    pass

def _resize_to(decoded: 'Any', width: 'int', height: 'int') -> 'Any':
    pass

def _occupancy(alpha: 'Any') -> 'float':
    pass

def _chroma_key_alpha(bgr: 'Any', key_bgr: 'tuple[int, int, int]', threshold: 'float') -> 'Any | None':
    pass

def _checkerboard_key_alpha(bgr: 'Any') -> 'Any | None':
    pass

def compose_separation_matte(source: 'Any', foreground: 'Any', background: 'Any') -> 'Any':
    pass

def _cache_key(image_path: 'str') -> 'str':
    pass

def separate_scene_assets(image_path: 'str', cache_dir: 'str', *, provider: 'Optional[Any]' = None, force: 'bool' = False) -> 'SeparatedAssetPair':
    """Return cached or newly generated same-canvas foreground/background PNGs.

    This function refuses a non-AI-Studio provider, so a difficult Draw scene
    can never silently spend gateway credit."""
    pass
