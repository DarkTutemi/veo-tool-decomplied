"""
Decompiled / Reconstructed Module: utils.window_surface

Docstring:
Decide whether the frameless splash window uses a translucent or opaque surface.

The bootstrap splash is a frameless window. A translucent (`color: "transparent"`)
surface gives it soft rounded corners, but it relies on the compositor doing alpha
compositing — and on some machines (DWM composition disabled, security software
hooking the compositor, driver alpha bugs) that surface never composites and renders
as a blank WHITE box (the "2 mystery white windows" bug). We could not reliably detect
which machines fail, so the DEFAULT is OPAQUE on Windows (square-corner splash, but
never a white/ghost box). Non-Windows keeps the translucent splash.

Force either way with VEOFLOW_OPAQUE_WINDOW=1 (opaque) / =0 (transparent — opt back
into the rounded splash on a machine known to composite correctly).
"""

from __future__ import annotations
import sys, os, typing
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)

# --- Top-Level Functions ---
def _env_override():
    # [PyArmor BCC constants]: 'os', 'environ', 'get', 'VEOFLOW_OPAQUE_WINDOW', '', 'strip', 'lower', 'yes', '1', 'on', 'true', False, 'off', '0', 'no'
    pass

def transparent_window_safe() -> 'bool':
    # [PyArmor BCC constants]: '_env_override', 'sys', 'platform', 'win32'
    pass
