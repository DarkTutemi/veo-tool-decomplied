"""
Decompiled / Reconstructed Module: utils.crash_logger

Docstring:
Crash and diagnostics logger with local persistence and server upload.
"""

from __future__ import annotations
import sys, os, typing
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
Optional = typing.Optional
LOGGING_ENABLED = True
_crash_logger = <utils.crash_logger.CrashLogger object at 0x0000021A9FE4BCB0>

# --- Class: CrashLogger ---
class CrashLogger:
    """Centralized crash logger with report bundling and background upload."""
    pause_on_crash = False

    def __init__(self):
        # [PyArmor BCC constants]: 'get_crash_log_path', 'crash_log_path', 'get_crash_reports_dir', 'reports_dir', 'get_logs_dir', 'qml_runtime.log', 'qml_log_path', 'Exception', 'threading', 'Lock', '_lock', '_auto_detect_debug_mode', '_setup_exception_hook'
        pass

    def _auto_detect_debug_mode(self):
        # [PyArmor BCC constants]: 'getattr', 'sys', 'frozen', False, 'Path', 'executable', 'resolve', 'parent', '.debug', 'exists', True, 'CrashLogger', 'pause_on_crash', 'Exception'
        pass

    def _setup_exception_hook(self):
        # [PyArmor BCC constants]: 'sys', 'excepthook', 'KeyboardInterrupt', 'log_crash', 'source', 'sys.excepthook', '_show_pause_dialog', 'isinstance', 'exc_value', 'ValueError', 'I/O operation on closed file', 'str', 'exc_type', 'exc_traceback', 'threading.excepthook'
        pass

    def _show_pause_dialog(self, exc_type, exc_value):
        # [PyArmor BCC constants]: 'CrashLogger', 'pause_on_crash', '__name__', ': ', '\n\nCrash log: ', 'crash_log_path', '\nReports dir: ', 'reports_dir', 'sys', 'platform', 'win32', 'windll', 'user32', 'MessageBoxW', 0
        pass

    def _collect_client_info(self) -> 'Dict[str, Any]':
        # [PyArmor BCC constants]: 'version', 'platform', 'platform_detail', 'python', 'frozen', 'executable_identity', 'faulthandler_log', 'getattr', 'sys', '_veoflow_version', 'unknown', 'bool', False, 'get_executable_identity', 'str'
        pass

    def _append_text_log(self, lines: 'list[str]') -> 'None':
        # [PyArmor BCC constants]: '_lock', 'open', 'crash_log_path', 'a', 'encoding', 'utf-8', 'write', '\n', 'join', 'OSError'
        pass

    def _write_report_bundle(self, payload: 'Dict[str, Any]') -> 'Path':
        # [PyArmor BCC constants]: 'get', 'report_id', 'crash_', 'datetime', 'now', 'strftime', '%Y%m%d_%H%M%S_%f', 'reports_dir', '.json', '_lock', 'write_text', 'json', 'dumps', 'ensure_ascii', False
        pass

    def _format_text_block(self, title: 'str', payload: 'Dict[str, Any]') -> 'list[str]':
        # [PyArmor BCC constants]: '[UNSENT] ', '=', 71, 80, '', 'append', 'Timestamp: ', 'get', 'timestamp', 'Report ID: ', 'report_id', 'Source: ', 'source', 'Type: ', 'error_type'
        pass

    def _enqueue_upload(self, payload: 'Dict[str, Any]') -> 'None':
        pass

    def _do_upload_report(self, payload: 'Dict[str, Any]') -> 'None':
        # [PyArmor BCC constants]: 'get_license_manager', 'get', 'report_path', 'report_id', 'error_type', 'error_message', 'traceback', 'context', 'client_info', 'timestamp', '', 12000, 'upload_crash_report', 'json', 'loads'
        pass

    def _log_payload(self, error_type: 'str', error_message: 'str', traceback_str: 'str', *, context: 'Optional[Dict[str, Any]]' = None, source: 'str' = 'manual') -> 'Dict[str, Any]':
        # [PyArmor BCC constants]: 'report_id', 'timestamp', 'source', 'error_type', 'error_message', 'traceback', 'context', 'client_info', '_', 'datetime', 'now', 'strftime', '%Y%m%d_%H%M%S_%f', 'isoformat', 1000
        pass

    def _log_qt_error(self, message, context):
        # [PyArmor BCC constants]: 'file', 'line', 'function', 'category', 'Exception', '_log_payload', 'qt_error', 'str', '', 'join', 'traceback', 'format_stack', 'context', 'source', 'qt_message_handler'
        pass

    def log_crash(self, exc_type, exc_value, exc_traceback, source: 'str' = 'exception'):
        # [PyArmor BCC constants]: '', 'join', 'traceback', 'format_exception', '_log_payload', 'crash', 'str', 'getattr', '__name__', 'Exception', 'context', 'exception_type', 'source'
        pass

    def log_manual_crash(self, error_message: 'str', context: 'dict' = None):
        # [PyArmor BCC constants]: '_log_payload', 'manual', '', 'join', 'traceback', 'format_stack', 'context', 'source'
        pass

    def log_info(self, message: 'str'):
        # [PyArmor BCC constants]: 'datetime', 'now', 'strftime', '%Y-%m-%d %H:%M:%S', '_append_text_log', '[', '] [INFO] ', 'LOGGING_ENABLED', 'print'
        pass

    def log_debug(self, message: 'str', tag: 'str' = 'GENERAL'):
        # [PyArmor BCC constants]: 'datetime', 'now', 'strftime', '%H:%M:%S.%f', 3, '_append_text_log', '[', '] [', '] ', 'LOGGING_ENABLED', 'print'
        pass

    def upload_crash_report(self, error_type: 'str', error_message: 'str', traceback_str: 'str', context: 'dict' = None):
        # [PyArmor BCC constants]: '_log_payload', 'context', 'source', 'upload_api'
        pass

    def upload_unsent_crashes(self):
        pass

    def _do_upload_unsent(self):
        # [PyArmor BCC constants]: 'sorted', 'reports_dir', 'glob', '*.json', 'json', 'loads', 'read_text', 'encoding', 'utf-8', 'Exception', 'get', 'uploaded', 'str', 'report_path', '_do_upload_report'
        pass


# --- Top-Level Functions ---
def get_crash_logger() -> 'CrashLogger':
    pass

def log_crash(error_message: 'str', context: 'dict' = None):
    pass

def log_info(message: 'str'):
    pass

def log_debug(message: 'str', tag: 'str' = 'GENERAL'):
    pass

def upload_unsent_crashes():
    pass
