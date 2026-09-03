"""
Decompiled / Reconstructed Module: core.flow_voice_preview_cache
Source PyC: flow_voice_preview_cache.pyc

Docstring:
Download and cache Flow generated voice previews locally.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Callable = typing.Callable
Dict = typing.Dict
Optional = typing.Optional
DEFAULT_VOICE_CACHE_DIR = WindowsPath('H:/veo-tool/unpack-veotool/VEOFLOWPROMAX.exe_extracted/PYZ.pyz_extracted/resources/voices')
_EXT_BY_CONTENT_TYPE = {'audio/wav': '.wav', 'audio/x-wav': '.wav', 'audio/wave': '.wav', 'audio/mpeg': '.mp3', 'audio/mp3': '.mp3', 'audio/mp4': '.m4a', 'audio/x-m4a': '.m4a', 'audio/ogg': '.ogg', 'audio/webm': '.webm'}

# --- Top-Level Functions ---
def _safe_media_id(value: 'str') -> 'str':
    pass

def _extension_from_response(content_type: 'str' = '', final_url: 'str' = '') -> 'str':
    pass

def cache_flow_voice_preview(media_id: 'str', *, account_name: 'str' = '', account_email: 'str' = '', cache_dir: 'Optional[str | Path]' = None, get_cookies: 'Optional[Callable[[str], Dict[str, str]]]' = None, fetch: 'Optional[Callable[..., object]]' = None) -> 'str':
    pass
