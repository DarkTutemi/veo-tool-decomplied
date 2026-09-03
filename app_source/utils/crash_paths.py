"""
Decompiled / Reconstructed Module: utils.crash_paths

Docstring:
Shared filesystem paths for crash reports, logs, and diagnostics.
"""

from __future__ import annotations
import sys, os, typing
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
APP_DIR_NAME = 'VEO3_Generator_Pro'

# --- Top-Level Functions ---
def get_appdata_dir() -> 'Path':
    # [PyArmor BCC constants]: 'os', 'getenv', 'APPDATA', 'path', 'expanduser', '~', 'Path', 'APP_DIR_NAME', 'mkdir', 'parents', True, 'exist_ok'
    pass

def get_logs_dir() -> 'Path':
    # [PyArmor BCC constants]: 'get_appdata_dir', 'logs', 'mkdir', 'parents', True, 'exist_ok'
    pass

def get_crash_reports_dir() -> 'Path':
    # [PyArmor BCC constants]: 'get_appdata_dir', 'crash_reports', 'mkdir', 'parents', True, 'exist_ok'
    pass

def get_crash_log_path() -> 'Path':
    pass

def get_faulthandler_log_path() -> 'Path':
    pass

def get_startup_debug_log_path() -> 'Path':
    pass

def get_runtime_debug_log_path() -> 'Path':
    pass

def get_diagnostics_dir() -> 'Path':
    # [PyArmor BCC constants]: 'get_appdata_dir', 'diagnostics', 'mkdir', 'parents', True, 'exist_ok'
    pass

def get_minidump_dir() -> 'Path':
    # [PyArmor BCC constants]: 'get_appdata_dir', 'crash_dumps', 'mkdir', 'parents', True, 'exist_ok'
    pass

def get_executable_identity() -> 'dict':
    # [PyArmor BCC constants]: 'Path', 'sys', 'executable', 'frozen', 'cwd', 'bool', 'getattr', False, 'str', 'os', 'getcwd'
    pass

def get_telemetry_queue_dir() -> 'Path':
    # [PyArmor BCC constants]: 'get_appdata_dir', 'telemetry_queue', 'mkdir', 'parents', True, 'exist_ok'
    pass

def get_telemetry_pending_dir() -> 'Path':
    # [PyArmor BCC constants]: 'get_telemetry_queue_dir', 'pending', 'mkdir', 'parents', True, 'exist_ok'
    pass

def get_telemetry_sent_dir() -> 'Path':
    # [PyArmor BCC constants]: 'get_telemetry_queue_dir', 'sent', 'mkdir', 'parents', True, 'exist_ok'
    pass

def get_telemetry_failed_dir() -> 'Path':
    # [PyArmor BCC constants]: 'get_telemetry_queue_dir', 'failed', 'mkdir', 'parents', True, 'exist_ok'
    pass
