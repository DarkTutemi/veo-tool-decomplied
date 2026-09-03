"""
Decompiled / Reconstructed Module: core.gemini_web.media
Source PyC: media.pyc

Docstring:
Extract generated media (image / video / music) from StreamGenerate bodies.

Paths reverse-engineered from live Ultra capture 2026-07-11 + gemini_webapi
candidate parsing ([12,7,0] images, [12,59,…] video, [12,86] music).
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Optional = typing.Optional

# --- Class: GeneratedImage ---
class GeneratedImage:
    """GeneratedImage(url: 'str', image_id: 'str' = '', title: 'str' = '', mime: 'str' = 'image/png', width: 'Optional[int]' = None, height: 'Optional[int]' = None)"""
    image_id = ''
    title = ''
    mime = 'image/png'
    width = None
    height = None

    def __init__(self, url: 'str', image_id: 'str' = '', title: 'str' = '', mime: 'str' = 'image/png', width: 'Optional[int]' = None, height: 'Optional[int]' = None) -> None:
        pass

    def __repr__(self):
        pass


# --- Class: GeneratedVideo ---
class GeneratedVideo:
    """GeneratedVideo(url: 'str' = '', thumbnail: 'str' = '', pending: 'bool' = False)"""
    url = ''
    thumbnail = ''
    pending = False

    def __init__(self, url: 'str' = '', thumbnail: 'str' = '', pending: 'bool' = False) -> None:
        pass

    def __repr__(self):
        pass


# --- Class: GeneratedMusic ---
class GeneratedMusic:
    """GeneratedMusic(url: 'str' = '', mp3_url: 'str' = '', thumbnail: 'str' = '', pending: 'bool' = False)"""
    url = ''
    mp3_url = ''
    thumbnail = ''
    pending = False

    def __init__(self, url: 'str' = '', mp3_url: 'str' = '', thumbnail: 'str' = '', pending: 'bool' = False) -> None:
        pass

    def __repr__(self):
        pass


# --- Class: MediaBundle ---
class MediaBundle:
    """MediaBundle(text: 'str' = '', images: 'list[GeneratedImage]' = <factory>, videos: 'list[GeneratedVideo]' = <factory>, music: 'list[GeneratedMusic]' = <factory>, cid: 'str' = '', rid: 'str' = '', rcid: 'str' = '', raw: 'str' = '')"""
    text = ''
    cid = ''
    rid = ''
    rcid = ''
    raw = ''
    has_media = <property object at 0x00000264DC010B30>

    def __init__(self, text: 'str' = '', images: 'list[GeneratedImage]' = <factory>, videos: 'list[GeneratedVideo]' = <factory>, music: 'list[GeneratedMusic]' = <factory>, cid: 'str' = '', rid: 'str' = '', rcid: 'str' = '', raw: 'str' = '') -> None:
        pass

    def __repr__(self):
        pass


# --- Top-Level Functions ---
def _iter_nested(data: 'Any'):
    pass

def _get(data: 'Any', path: 'list', default=None):
    pass

def _load_frame_bodies(raw: 'str') -> 'list[Any]':
    pass

def _parse_candidate_media(candidate: 'list') -> 'tuple[list[GeneratedImage], list[GeneratedVideo], list[GeneratedMusic]]':
    pass

def extract_media(raw: 'str') -> 'MediaBundle':
    pass
