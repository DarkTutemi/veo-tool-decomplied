"""
Decompiled / Reconstructed Module: utils.telemetry_reporter

Docstring:
High-level telemetry reporter for diagnostics and crash events.
"""

from __future__ import annotations
import sys, os, typing
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
Optional = typing.Optional

# --- Top-Level Functions ---
def _client_info(extra: 'Optional[Dict[str, Any]]' = None) -> 'Dict[str, Any]':
    # [PyArmor BCC constants]: 'version', 'tool_code', 'tool_name', 'server_url', 'VEO3Config', 'TOOL_VERSION', 'TOOL_CODE', 'TOOL_NAME', 'get_server_url', 'update'
    pass

def _base_event(event_type: 'str', report_id: 'str', payload: 'Dict[str, Any]') -> 'Dict[str, Any]':
    # [PyArmor BCC constants]: 'event_type', 'report_id', 'session_id', 'timestamp', 'error_type', 'error_message', 'primary_category', 'confidence', 'context', 'client_info', 'traceback', 'source', 'executable_identity', 'app_version', 'get'
    pass

def queue_crash_payload(payload: 'Dict[str, Any]', event_type: 'str' = 'crash_event') -> 'None':
    # [PyArmor BCC constants]: 'get_telemetry_uploader', 'enqueue_event', '_base_event', 'get', 'report_id'
    pass

def queue_unexpected_shutdown(report: 'Dict[str, Any]') -> 'None':
    # [PyArmor BCC constants]: 'get_telemetry_uploader', 'get', 'previous_session', 'event_type', 'report_id', 'session_id', 'timestamp', 'error_type', 'error_message', 'primary_category', 'confidence', 'context', 'client_info', 'traceback', 'source'
    pass

def queue_diagnostics_summary() -> 'None':
    # [PyArmor BCC constants]: 'get_telemetry_uploader', 'collect_diagnostics_summary', 'event_type', 'report_id', 'session_id', 'timestamp', 'error_type', 'error_message', 'primary_category', 'confidence', 'context', 'client_info', 'traceback', 'source', 'executable_identity'
    pass
