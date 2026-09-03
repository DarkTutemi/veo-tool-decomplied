"""
Decompiled / Reconstructed Module: core.dispatch.video_trim
Source PyC: video_trim.pyc

Docstring:
core/dispatch/video_trim.py — extend-video start trimming.

Port of SmartJobDispatcher._trim_extend_video_start. An extend clip begins with
a ~1s static transition frame copied from the input's last frame; when chained
this shows up as a frozen/duplicate frame at the join. We cut the first N seconds
(default 1.0s) using VideoMerger's GPU-aware encoder. Overwrites in place.

Best-effort: returns the (same) path on success, None on failure or when ffmpeg
is unavailable — callers keep the untrimmed file in that case.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Optional = typing.Optional
_VEO3_FPS = 24

# --- Top-Level Functions ---
def trim_extend_start(video_path: 'str', trim_seconds: 'float' = 1.0) -> 'Optional[str]':
    pass
