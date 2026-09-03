"""
Decompiled / Reconstructed Module: utils.forensic_logger

Docstring:
Simple forensic session logger for unexpected shutdown analysis.
"""

from __future__ import annotations
import sys, os, typing
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
Optional = typing.Optional

# --- Class: ForensicLogger ---
class ForensicLogger:
    _instance = None
    _instance_lock = <unlocked _thread.lock object at 0x0000021AA00AA640>

    def __init__(self):
        # [PyArmor BCC constants]: '_initialized', True, 'threading', 'Lock', '_lock', 'Event', '_heartbeat_stop', '_heartbeat_thread', 'get_logs_dir', 'logs_dir', 'uuid', 'uuid4', 'hex', 16, 'session_id'
        pass

    def _now(self) -> 'str':
        pass

    def _base_payload(self) -> 'Dict[str, Any]':
        # [PyArmor BCC constants]: 'session_id', 'pid', 'started_at', 'hostname', 'platform', 'python', 'frozen', 'executable', 'cwd', 'status', 'heartbeat_at', 'last_action', 'graceful_exit', 'os', 'getpid'
        pass

    def _write_json(self, path: 'Path', data: 'Dict[str, Any]') -> 'None':
        # [PyArmor BCC constants]: '_lock', 'write_text', 'json', 'dumps', 'ensure_ascii', False, 'indent', 2, 'encoding', 'utf-8'
        pass

    def _read_json(self, path: 'Path') -> 'Optional[Dict[str, Any]]':
        # [PyArmor BCC constants]: 'json', 'loads', 'read_text', 'encoding', 'utf-8', 'Exception'
        pass

    def _append_history(self, data: 'Dict[str, Any]') -> 'None':
        # [PyArmor BCC constants]: '_lock', 'open', 'session_history_path', 'a', 'encoding', 'utf-8', 'write', 'json', 'dumps', 'ensure_ascii', False, '\n'
        pass

    def detect_previous_unexpected_shutdown(self) -> 'Optional[Dict[str, Any]]':
        # [PyArmor BCC constants]: '_read_json', 'session_path', 'get', 'graceful_exit', 'detected_at', 'previous_session', 'last_action', '_now', 'last_action_path', '_write_json', 'report_path', '_append_history', 'event', 'unexpected_shutdown_detected'
        pass

    def start(self, heartbeat_interval: 'float' = 10.0) -> 'None':
        # [PyArmor BCC constants]: '_started', True, '_base_payload', 'running', 'status', '_write_json', 'session_path', '_append_history', 'event', 'session_started', 'threading', 'Thread', 'target', '_heartbeat_loop', 'args'
        pass

    def _heartbeat_loop(self, interval: 'float') -> 'None':
        pass

    def update_heartbeat(self) -> 'None':
        # [PyArmor BCC constants]: '_read_json', 'session_path', '_base_payload', '_now', 'heartbeat_at', 'last_action_path', 'exists', 'json', 'loads', 'read_text', 'encoding', 'utf-8', 'get', 'action', 'last_action'
        pass

    def record_action(self, action: 'str', **details: 'Any') -> 'None':
        # [PyArmor BCC constants]: 'drop', 'action', 'Exception', 'session_id', 'timestamp', 'details', '_now', '_write_json', 'last_action_path', '_read_json', 'session_path', '_base_payload', 'last_action', 'heartbeat_at', '_append_history'
        pass

    def mark_graceful_exit(self) -> 'None':
        # [PyArmor BCC constants]: '_heartbeat_stop', 'set', '_read_json', 'session_path', True, 'graceful_exit', 'stopped', 'status', '_now', 'stopped_at', '_write_json', '_append_history', 'event', 'session_stopped'
        pass


# --- Top-Level Functions ---
def get_forensic_logger() -> 'ForensicLogger':
    pass
