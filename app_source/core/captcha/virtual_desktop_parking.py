"""
Decompiled / Reconstructed Module: core.captcha.virtual_desktop_parking
Source PyC: virtual_desktop_parking.pyc

Docstring:
Park headed CAPTCHA browser windows on a dedicated Windows virtual desktop.

The Farm launches the window off-screen first, then calls this module after CDP is
ready.  Moving and creating virtual desktops uses pyvda's Windows-version-aware
COM definitions.  All COM work stays on one dedicated thread because the COM
objects created by pyvda are apartment-bound.

This module is deliberately Farm-only.  Manual login/open-account browsers never
call it and therefore remain on the user's current desktop.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
BACKGROUND_DESKTOP_NAME = 'VeoFlow Background'
FOREGROUND_DESKTOP_NUMBER = 1
_GWL_EXSTYLE = -20
_WS_EX_TOOLWINDOW = 128
_WS_EX_APPWINDOW = 262144
_SW_HIDE = 0
_SW_SHOWNOACTIVATE = 4
_SWP_NOSIZE = 1
_SWP_NOMOVE = 2
_SWP_NOZORDER = 4
_SWP_NOACTIVATE = 16
_SWP_FRAMECHANGED = 32
_HWND_BOTTOM = 1
_executor = None
_executor_lock = <unlocked _thread.lock object at 0x00000264DA5E7E40>
_owned_desktop_id = None

# --- Class: VirtualDesktopParkingError ---
class VirtualDesktopParkingError(RuntimeError):
    """The browser could not be safely moved away from the active desktop."""
    pass


# --- Top-Level Functions ---
def _parking_executor() -> 'ThreadPoolExecutor':
    pass

def _load_pyvda():
    pass

def _visible_process_windows(process_id: 'int') -> 'list[dict[str, Any]]':
    pass

def _hide_window_from_taskbar(hwnd: 'int') -> 'bool':
    pass

def _desktop_name(desktop) -> 'str':
    pass

def _desktop_id(desktop) -> 'str':
    pass

def _ensure_background_desktop(pyvda_module):
    pass

def _resolve_desktop1(pyvda_module):
    pass

def _restore_offscreen_window(hwnd: 'int', rect: 'list[int]') -> 'None':
    pass

def _park_process_window_to_target_sync(process_id: 'int', target_kind: 'str') -> 'dict[str, Any]':
    pass

def _park_process_window_sync(process_id: 'int') -> 'dict[str, Any]':
    pass

def _park_process_window_desktop1_sync(process_id: 'int') -> 'dict[str, Any]':
    pass

def _cleanup_background_desktop_sync() -> 'dict[str, Any]':
    pass

def park_process_window(process_id: 'int') -> 'dict[str, Any]':
    """Move one headed Chromium window without blocking the Farm event loop."""
    pass

def park_process_window_on_desktop1(process_id: 'int') -> 'dict[str, Any]':
    """Move one headed Chromium window onto Windows Desktop 1, on-screen."""
    pass

def cleanup_background_desktop(timeout: 'float' = 5.0) -> 'dict[str, Any]':
    pass
