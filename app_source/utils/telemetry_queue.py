"""
Decompiled / Reconstructed Module: utils.telemetry_queue

Docstring:
Local telemetry queue for diagnostics/crash uploads.
"""

from __future__ import annotations
import sys, os, typing
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
List = typing.List
Optional = typing.Optional

# --- Class: TelemetryQueue ---
class TelemetryQueue:
    def __init__(self):
        # [PyArmor BCC constants]: 'get_telemetry_pending_dir', 'pending_dir', 'get_telemetry_sent_dir', 'sent_dir', 'get_telemetry_failed_dir', 'failed_dir'
        pass

    def enqueue(self, payload: 'Dict') -> 'Path':
        # [PyArmor BCC constants]: 'get', 'report_id', 'event_', 'datetime', 'now', 'strftime', '%Y%m%d_%H%M%S_%f', 'setdefault', 'status', 'pending', 'retry_count', 0, 'next_retry_at', 'pending_dir', '.json'
        pass

    def list_pending(self) -> 'List[Path]':
        # [PyArmor BCC constants]: 'time', 'sorted', 'pending_dir', 'glob', '*.json', 'json', 'loads', 'read_text', 'encoding', 'utf-8', 'Exception', 'get', 'next_retry_at', 0, 'append'
        pass

    def mark_sent(self, path: 'Path') -> 'Path':
        # [PyArmor BCC constants]: 'sent_dir', 'name', 'exists', 'unlink', 'missing_ok', True, 'replace'
        pass

    def mark_retry(self, path: 'Path', payload: 'Dict', delay_seconds: 'int') -> 'None':
        # [PyArmor BCC constants]: 'pending', 'status', 'int', 'get', 'retry_count', 0, 1, 'time', 'next_retry_at', 'write_text', 'json', 'dumps', 'ensure_ascii', False, 'indent'
        pass

    def mark_failed(self, path: 'Path', payload: 'Dict') -> 'Path':
        # [PyArmor BCC constants]: 'failed', 'status', 'failed_dir', 'name', 'write_text', 'json', 'dumps', 'ensure_ascii', False, 'indent', 2, 'encoding', 'utf-8', 'unlink', 'missing_ok'
        pass

