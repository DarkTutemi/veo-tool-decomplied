"""
Decompiled / Reconstructed Module: utils.window_corners

Docstring:
Windows 11 native rounded window corners (DWM) — no translucency required.

The app window is frameless + OPAQUE (see window_surface.py — a translucent surface
caused the white-box bug, so we don't use it). To still get soft rounded corners when
the window is NOT maximized, we ask DWM to round them via the
DWMWA_WINDOW_CORNER_PREFERENCE attribute. DWM rounds the corners only while the window
is windowed and squares them when maximized / fullscreen — exactly the desired behaviour
("bo góc khi ở dạng cửa sổ"). Native → anti-aliased + real shadow, opaque-safe.

No-op on Windows 10 (attribute unsupported → corners stay square) and non-Windows.
Force off with VEOFLOW_ROUND_CORNERS=0.
"""

from __future__ import annotations
import sys, os, typing
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)

# --- Top-Level Functions ---
def apply_rounded_corners(hwnd: 'int', *, small: 'bool' = False) -> 'bool':
    # [PyArmor BCC constants]: 'sys', 'platform', 'win32', False, 'os', 'getenv', 'VEOFLOW_ROUND_CORNERS', '', 'strip', 'lower', 'off', '0', 'no', 'false', 33
    pass
