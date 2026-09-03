"""
Decompiled / Reconstructed Module: utils.single_instance_manager

Docstring:
Single Instance Manager for VEO3 Tool
Chrome-style implementation: Hidden Message Window + WM_COPYDATA + Mutex
100% Windows compatible - handles all edge cases.
"""

from __future__ import annotations
import sys, os, typing
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
WINDOW_CLASS_NAME = 'VEO3_TOOL_SINGLETON_MSG_WINDOW'
WINDOW_TITLE = 'VEO3_TOOL_SINGLETON'
MUTEX_NAME = 'Global\\VEO3_TOOL_SINGLETON_MUTEX'
WM_COPYDATA = 74
WM_CLOSE = 16
COPYDATA_ACTIVATE = 1447382835
LOCK_FILE_DIR = 'C:\\Users\\vutru\\AppData\\Local\\VEO3Tool'
kernel32 = <WinDLL 'kernel32', handle 7ffb91670000 at 0x1df91ee36b0>
user32 = <WinDLL 'user32', handle 7ffb91eb0000 at 0x1df91f09a90>
_mutex_handle = None
_msg_window_hwnd = None
_lock_file_handle = None
_wndproc_ref = None
_activation_signal = None
_class_registered = False
_class_name_buffer = None
_window_title_buffer = None

# --- Class: COPYDATASTRUCT ---
class COPYDATASTRUCT(Structure):
    _fields_ = [('dwData', <class 'ctypes.c_void_p'>), ('cbData', <class 'ctypes.c_ulong'>), ('lpData', <class 'ctypes.c_void_p'>)]
    dwData = <Field type=c_void_p, ofs=0, size=8>
    cbData = <Field type=c_ulong, ofs=8, size=4>
    lpData = <Field type=c_void_p, ofs=16, size=8>


# --- Class: WNDCLASSEXW ---
class WNDCLASSEXW(Structure):
    _fields_ = [('cbSize', <class 'ctypes.c_ulong'>), ('style', <class 'ctypes.c_ulong'>), ('lpfnWndProc', <class 'ctypes.WINFUNCTYPE.<...
    cbSize = <Field type=c_ulong, ofs=0, size=4>
    style = <Field type=c_ulong, ofs=4, size=4>
    lpfnWndProc = <Field type=WinFunctionType, ofs=8, size=8>
    cbClsExtra = <Field type=c_long, ofs=16, size=4>
    cbWndExtra = <Field type=c_long, ofs=20, size=4>
    hInstance = <Field type=c_void_p, ofs=24, size=8>
    hIcon = <Field type=c_void_p, ofs=32, size=8>
    hCursor = <Field type=c_void_p, ofs=40, size=8>
    hbrBackground = <Field type=c_void_p, ofs=48, size=8>
    lpszMenuName = <Field type=c_wchar_p, ofs=56, size=8>
    lpszClassName = <Field type=c_wchar_p, ofs=64, size=8>
    hIconSm = <Field type=c_void_p, ofs=72, size=8>


# --- Class: ActivationSignal ---
class ActivationSignal(QObject):
    """Signal emitter for cross-thread window activation."""
    staticMetaObject = PySide6.QtCore.QMetaObject("ActivationSignal" inherits "QObject":
Methods:
  #4 type=Signal, signature=activate_window()...

    activate_window = Signal()

# --- Top-Level Functions ---
def _bring_window_to_front():
    # [PyArmor BCC constants]: 'QGuiApplication', 'instance', 'topLevelWindows', 'isVisible', 'hasattr', 'showNormal', 'raise_', 'requestActivate', 'int', 'winId', 'user32', 'AllowSetForegroundWindow', 1, 'SetForegroundWindow', 'FlashWindow'
    pass

def _acquire_mutex() -> bool:
    # [PyArmor BCC constants]: 'kernel32', 'CreateMutexW', True, 'MUTEX_NAME', 'GetLastError', 183, 'CloseHandle', False, '_mutex_handle'
    pass

def _wndproc(hwnd, msg, wparam, lparam):
    # [PyArmor BCC constants]: 'WM_COPYDATA', 'ctypes', 'cast', 'POINTER', 'COPYDATASTRUCT', 'contents', 'dwData', 'COPYDATA_ACTIVATE', '_activation_signal', 'activate_window', 'emit', 1, 'Exception', 'user32', 'DefWindowProcW'
    pass

def _register_window_class():
    # [PyArmor BCC constants]: '_class_registered', True, 'kernel32', 'GetModuleHandleW', 'WNDPROC', '_wndproc', '_wndproc_ref', 'ctypes', 'create_unicode_buffer', 'WINDOW_CLASS_NAME', '_class_name_buffer', 'WNDCLASSEXW', 'sizeof', 'cbSize', 'lpfnWndProc'
    pass

def _create_message_window():
    # [PyArmor BCC constants]: '_register_window_class', 'kernel32', 'GetModuleHandleW', 'ctypes', 'create_unicode_buffer', 'WINDOW_TITLE', '_window_title_buffer', 128, 2147483648, 'user32', 'CreateWindowExW', '_class_name_buffer', 10000, 1, '_msg_window_hwnd'
    pass

def _find_existing_window():
    # [PyArmor BCC constants]: 'user32', 'FindWindowW', 'WINDOW_CLASS_NAME', 'WINDOW_TITLE'
    pass

def _send_activate_message(hwnd):
    # [PyArmor BCC constants]: 'COPYDATASTRUCT', 'COPYDATA_ACTIVATE', 'dwData', 'len', 'cbData', 'ctypes', 'cast', 'c_char_p', 'c_void_p', 'lpData', 'user32', 'SendMessageW', 'WM_COPYDATA', 'WPARAM', 0
    pass

def _get_hardware_id() -> str:
    # [PyArmor BCC constants]: 'ctypes', 'c_ulong', 'kernel32', 'GetVolumeInformationW', 'C:\\', 0, 'byref', 'os', 'environ', 'get', 'COMPUTERNAME', 'UNKNOWN', 'USERNAME', 'value', '-'
    pass

def _acquire_lock_file() -> bool:
    # [PyArmor BCC constants]: 'os', 'makedirs', 'LOCK_FILE_DIR', 'exist_ok', True, 'path', 'join', '.instance_', '_get_hardware_id', '.lock', 1073741824, 2, 67108864, 256, 'kernel32'
    pass

def check_single_instance():
    # [PyArmor BCC constants]: '_find_existing_window', '_send_activate_message', '_acquire_mutex', 'range', 3, 'sleep', 0.1, '_acquire_lock_file', '_create_message_window', 'ActivationSignal', '_activation_signal', 'activate_window', 'connect', '_bring_window_to_front', True
    pass

def set_instance_manager(_):
    pass

def cleanup_instance_lock():
    # [PyArmor BCC constants]: '_msg_window_hwnd', 'user32', 'DestroyWindow', '_mutex_handle', 'kernel32', 'ReleaseMutex', 'CloseHandle', '_lock_file_handle'
    pass
