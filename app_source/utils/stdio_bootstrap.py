"""
Decompiled / Reconstructed Module: utils.stdio_bootstrap

Docstring:
Repair standard streams before a windowed frozen app emits startup logs.
"""

from __future__ import annotations
import sys, os, typing
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)

# --- Class: NullBinaryBuffer ---
class NullBinaryBuffer:
    """Binary sink for libraries that write to ``stream.buffer`` (yt-dlp)."""
    def write(self, data: 'Any' = b'', *args: 'Any', **kwargs: 'Any') -> 'int':
        # [PyArmor BCC constants]: 0, 'len', 'TypeError'
        pass

    def flush(self, *args: 'Any', **kwargs: 'Any') -> 'None':
        pass

    def close(self, *args: 'Any', **kwargs: 'Any') -> 'None':
        pass

    def isatty(self) -> 'bool':
        pass

    @property
    def closed(self):
        pass


# --- Class: NullStream ---
class NullStream:
    """Small text-stream contract backed by the process null device."""
    _devnull_fd = None
    _binary_buffer = <utils.stdio_bootstrap.NullBinaryBuffer object at 0x000001DF91F0B1D0>

    def write(self, data: 'Any' = '', *args: 'Any', **kwargs: 'Any') -> 'int':
        # [PyArmor BCC constants]: 'isinstance', 'str', 'len', 0
        pass

    def read(self, *args: 'Any', **kwargs: 'Any') -> 'str':
        pass

    def readline(self, *args: 'Any', **kwargs: 'Any') -> 'str':
        pass

    def readlines(self, *args: 'Any', **kwargs: 'Any') -> 'list[str]':
        pass

    def flush(self, *args: 'Any', **kwargs: 'Any') -> 'None':
        pass

    def close(self, *args: 'Any', **kwargs: 'Any') -> 'None':
        pass

    def isatty(self) -> 'bool':
        pass

    def reconfigure(self, **kwargs: 'Any') -> 'None':
        pass

    def fileno(self) -> 'int':
        # [PyArmor BCC constants]: 'NullStream', '_devnull_fd', 'os', 'open', 'devnull', 'O_RDWR'
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


# --- Top-Level Functions ---
def _output_stream_usable(stream: 'Any') -> 'bool':
    # [PyArmor BCC constants]: False, 'fileno', 'AttributeError', 'TypeError', 'UnsupportedOperation', 'OSError', 'ValueError', 'isinstance', 'int', 0, 'os', 'fstat', 'write', '', 'flush'
    pass

def prepare_standard_streams(stream_owner: 'Any' = None) -> 'tuple[str, ...]':
    # [PyArmor BCC constants]: 'sys', 'getattr', 'stdin', 'NullStream', 'append', '_output_stream_usable', 'setattr', 'hasattr', 'set', 'id', 'add', 'reconfigure', 'callable', 'encoding', 'utf-8'
    pass
