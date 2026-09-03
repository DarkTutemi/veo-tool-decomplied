"""
Decompiled / Reconstructed Module: utils.gpu_backend

Docstring:
Rendering: trust Qt6's automatic backend; opt into 4x MSAA only.

Qt6 already auto-selects Direct3D 11 on Windows and auto-falls-back to the WARP
software D3D11 adapter (guaranteed on every Windows — VMs, GPU-less boxes) when no
hardware adapter is usable — still the D3D11 pipeline, never QPainter software. So
we do NOT pin the backend: setting QSG_RHI_BACKEND=d3d11 only repeats what Qt does
anyway. The one thing that is NOT a default is the anti-aliasing sample count, so
that is all we set — 4x MSAA for smoother shape / border / rounded-corner edges.

No self-heal ladder, no backend swapping: a native access violation at startup is
an engine / import race, NOT a graphics fault — fix the race, don't demote the GPU.
End users set nothing; an explicit QSG_RHI_BACKEND / QT_QUICK_BACKEND still wins.
"""

from __future__ import annotations
import sys, os, typing
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)

# --- Top-Level Functions ---
def pin_graphics_backend() -> 'str | None':
    # [PyArmor BCC constants]: 'sys', 'platform', 'win32', 'os', 'environ', 'get', 'QSG_RHI_BACKEND', 'QT_QUICK_BACKEND', 'setdefault', 'QSG_SAMPLES', '4', '4x MSAA (backend: Qt auto)'
    pass
