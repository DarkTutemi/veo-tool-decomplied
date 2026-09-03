"""
Decompiled / Reconstructed Module: utils.audio_preview

Docstring:
Inline WAV preview — play through an audio API, NEVER an external app window.

Owner (19/7): voice preview must not pop the system media player. Engine order:
  1. winsound (Windows stdlib): async, windowless, zero deps — the normal path.
  2. ffplay -nodisp (bundled ffmpeg runtime): windowless process, any OS.
  3. OS default app — last resort only (the old behavior).

A new play_wav_preview() call replaces the currently playing preview (winsound
SND_ASYNC semantics), so rapid voice switching just switches the sound.
"""

from __future__ import annotations
import sys, os, typing
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
_CREATE_NO_WINDOW = 134217728

# --- Top-Level Functions ---
def play_wav_preview(path: 'str') -> 'Dict[str, Any]':
    # [PyArmor BCC constants]: 'str', '', 'os', 'path', 'isfile', 'ok', 'message', False, 'not found: ', 'name', 'nt', 'PlaySound', 'SND_FILENAME', 'SND_ASYNC', 'SND_NODEFAULT'
    pass

def stop_wav_preview() -> 'None':
    # [PyArmor BCC constants]: 'os', 'name', 'nt', 'PlaySound', 'SND_PURGE', 'Exception'
    pass
