"""
Decompiled / Reconstructed Module: utils.unified_logger

Docstring:
UnifiedLogger - Hệ thống log tập trung cho toàn bộ app
Hook stdout/stderr, capture vào ring buffer, phát signal cho UI.

Usage:
    from utils.unified_logger import get_unified_logger
    logger = get_unified_logger()
    logger.install()  # Hook stdout/stderr

    # Subscribe UI panel
    logger.subscribe(my_callback)  # callback(entry: dict)
    logger.unsubscribe(my_callback)

    # Get buffer
    entries = logger.get_entries()  # list of dicts
    logger.clear()
"""

from __future__ import annotations
import sys, os, typing
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
_logger = None

# --- Class: _LogStreamHook ---
class _LogStreamHook(TextIOBase):
    """
    Hook wrapper cho stdout/stderr.
        Capture output vào UnifiedLogger buffer, đồng thời giữ nguyên output gốc.
    """
    _abc_impl = <_abc._abc_data object at 0x0000021AA00DF380>

    def __init__(self, original_stream, logger_instance, source: str = 'stdout'):
        pass

    def write(self, text):
        # [PyArmor BCC constants]: 0, '_original', 'hasattr', 'write', 'Exception', 'strip', '_logger', '_append_entry', '_source', 'rstrip', '\n'
        pass

    def flush(self):
        # [PyArmor BCC constants]: '_original', 'hasattr', 'flush', 'Exception'
        pass

    def fileno(self):
        # [PyArmor BCC constants]: '_original', 'hasattr', 'fileno', 'Exception', 'open', 'devnull', 'O_RDWR', 1
        pass

    def isatty(self):
        pass

    def close(self):
        pass

    def reconfigure(self, **kwargs):
        pass

    @property
    def closed(self):
        pass

    @property
    def encoding(self):
        pass

    @property
    def errors(self):
        pass

    @property
    def buffer(self):
        pass


# --- Class: UnifiedLogger ---
class UnifiedLogger:
    """
    Singleton logger: hook stdout/stderr → ring buffer → UI subscribers.
        Thread-safe.
    """
    _instance = None
    _lock = <unlocked _thread.lock object at 0x0000021AA010B180>
    BUFFER_MAX = 10000

    def install(self):
        # [PyArmor BCC constants]: '_installed', 'sys', 'stdout', '_original_stdout', 'stderr', '_original_stderr', '_LogStreamHook', True
        pass

    def _append_entry(self, source: str, message: str):
        # [PyArmor BCC constants]: 'timestamp', 'source', 'message', 'datetime', 'now', 'strftime', '%H:%M:%S.%f', 3, '_buffer', 'append', '_sub_lock', 'list', '_subscribers', 'Exception'
        pass

    def subscribe(self, callback):
        pass

    def unsubscribe(self, callback):
        # [PyArmor BCC constants]: '_sub_lock', '_subscribers', 'remove', 'ValueError'
        pass

    def get_entries(self):
        pass

    def clear(self):
        pass


# --- Top-Level Functions ---
def get_unified_logger() -> utils.unified_logger.UnifiedLogger:
    pass
