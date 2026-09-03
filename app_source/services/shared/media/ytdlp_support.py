"""
Decompiled / Reconstructed Module: services.shared.media.ytdlp_support
Source PyC: ytdlp_support.pyc

Docstring:
Shared yt-dlp helpers for YouTube 403 / windowed-stdio crashes.

yt-dlp reports errors through ``write_string(sys.stderr)``. On the QML app
that stream's ``.buffer`` used to be ``None``, so a real YouTube 403 was
masked as ``'NoneType' object has no attribute 'write'``. Callers must pass a
logger, and YouTube media 403s retry cookie then player-client like A2V.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Callable = typing.Callable
Optional = typing.Optional
T = ~T
YOUTUBE_AUTH_GATE_SIGNALS = ('empty media response', 'sign in', 'log in', 'login', "confirm you're not a bot", 'confirm you’re not a bot', 'cookies', 'private video', 'members-only', 'age-restricted', 'age restricted', 'rate-lim... [truncated]
YOUTUBE_PLAYER_CLIENT_RETRIES = (('android', 'web'), ('ios', 'mweb'), ('tv', 'tv_embedded'))

# --- Class: YtDlpPrintLogger ---
class YtDlpPrintLogger:
    """yt-dlp logger that accepts str/bytes and never touches sys.stderr.buffer."""
    def __init__(self, prefix: 'str' = 'yt-dlp') -> 'None':
        pass

    def debug(self, msg: 'Any') -> 'None':
        pass

    def warning(self, msg: 'Any') -> 'None':
        pass

    def error(self, msg: 'Any') -> 'None':
        pass


# --- Top-Level Functions ---
def _as_text(msg: 'Any') -> 'str':
    pass

def is_youtube_url(url: 'str') -> 'bool':
    pass

def looks_like_ytdlp_auth_gate(*parts: 'Any') -> 'bool':
    pass

def youtube_cookiefile() -> 'Optional[str]':
    pass

def inject_js_runtime(ydl_opts: 'dict') -> 'dict':
    pass

def with_youtube_player_client(ydl_opts: 'dict', clients: 'tuple[str, ...] | list[str]') -> 'dict':
    pass

def run_ytdlp_with_youtube_fallbacks(*, url: 'str', base_opts: 'dict', download: 'Callable[[dict], T]', cookie_opts_factory: 'Optional[Callable[[dict, str], Optional[dict]]]' = None, on_retry: 'Optional[Callable[[str], None]]' = None) -> 'T':
    pass
