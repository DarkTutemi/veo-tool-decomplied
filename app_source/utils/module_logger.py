"""
Decompiled / Reconstructed Module: utils.module_logger

Docstring:
Module Logger - Hệ thống log có thể bật/tắt theo module

Usage:
    from utils.module_logger import log

    log.clone("🔄 Processing job...")
    log.dispatcher("📤 Dispatching job...")
    log.api("🔄 Calling Gemini API...")

Để bật/tắt logs, chỉnh sửa flags trong class ModuleLogger.

IMPORTANT: Call setup_global_print_filter() in main.py to suppress all print() statements
"""

from __future__ import annotations
import sys, os, typing
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
_original_stdout = None
_print_filter = None
log = <utils.module_logger.ModuleLogger object at 0x000001DF91EB4EC0>

# --- Class: PrintFilter ---
class PrintFilter(TextIOBase):
    """
    Custom stdout filter để chặn tất cả print() statements
        CHỈ cho phép logs từ ModuleLogger đi qua
    """
    _abc_impl = <_abc._abc_data object at 0x000001DF91EB9200>

    def __init__(self, original_stdout):
        pass

    def write(self, text):
        """Override write() - chặn tất cả output TRỪ logs từ ModuleLogger"""
        # [PyArmor BCC constants]: '[CLONE]', '[SERVICE]', '[API]', '[DISPATCHER]', '[TEXT_VIDEO]', '[PORTRAIT]', '[MASTER]', '[GENERAL]'
        pass

    def flush(self):
        pass


# --- Class: ModuleLogger ---
class ModuleLogger:
    """
    Centralized module logger với flags bật/tắt cho từng module
        
        ✅ ENABLE = True  → Print logs
        ❌ ENABLE = False → Silent (không print)
    """
    ENABLE_CLONE_VIDEO = True
    ENABLE_DISPATCHER = False
    ENABLE_TEXT_VIDEO = False
    ENABLE_PORTRAIT_VIDEO = False
    ENABLE_MASTER_PROMPT = False
    ENABLE_GEMINI_API = True
    ENABLE_CLONE_SERVICE = True
    ENABLE_GENERAL = False
    SHOW_TIMESTAMP = True
    SHOW_THREAD = True

    @staticmethod
    def _format_message(msg: str, prefix: str = '') -> str:
        # [PyArmor BCC constants]: 'ModuleLogger', 'SHOW_TIMESTAMP', 'datetime', 'now', 'strftime', '%H:%M:%S.%f', 3, 'append', '[', ']', 'SHOW_THREAD', 'current_thread', 'name', ' ', 'join'
        pass

    @staticmethod
    def clone(msg: str):
        # [PyArmor BCC constants]: 'ModuleLogger', 'ENABLE_CLONE_VIDEO', '_format_message', '[CLONE]', 'print', 'flush', True
        pass

    @staticmethod
    def dispatcher(msg: str):
        # [PyArmor BCC constants]: 'ModuleLogger', 'ENABLE_DISPATCHER', '_format_message', '[DISPATCHER]', 'print', 'flush', True
        pass

    @staticmethod
    def text_video(msg: str):
        # [PyArmor BCC constants]: 'ModuleLogger', 'ENABLE_TEXT_VIDEO', '_format_message', '[TEXT_VIDEO]', 'print', 'flush', True
        pass

    @staticmethod
    def portrait_video(msg: str):
        # [PyArmor BCC constants]: 'ModuleLogger', 'ENABLE_PORTRAIT_VIDEO', '_format_message', '[PORTRAIT]', 'print', 'flush', True
        pass

    @staticmethod
    def master_prompt(msg: str):
        # [PyArmor BCC constants]: 'ModuleLogger', 'ENABLE_MASTER_PROMPT', '_format_message', '[MASTER]', 'print', 'flush', True
        pass

    @staticmethod
    def api(msg: str):
        # [PyArmor BCC constants]: 'ModuleLogger', 'ENABLE_GEMINI_API', '_format_message', '[API]', 'print', 'flush', True
        pass

    @staticmethod
    def service(msg: str):
        # [PyArmor BCC constants]: 'ModuleLogger', 'ENABLE_CLONE_SERVICE', '_format_message', '[SERVICE]', 'print', 'flush', True
        pass

    @staticmethod
    def general(msg: str):
        # [PyArmor BCC constants]: 'ModuleLogger', 'ENABLE_GENERAL', '_format_message', '[GENERAL]', 'print', 'flush', True
        pass

    @staticmethod
    def always(msg: str):
        pass


# --- Top-Level Functions ---
def setup_global_print_filter(enabled: bool = True):
    # [PyArmor BCC constants]: '_original_stdout', 'sys', 'stdout', 'PrintFilter', '_print_filter', 'write', '🔇 [PRINT FILTER] Enabled - blocking all print() statements except ModuleLogger\n', 'flush', '🔊 [PRINT FILTER] Disabled - allowing all print() statements\n'
    pass

def disable_global_print_filter():
    pass
