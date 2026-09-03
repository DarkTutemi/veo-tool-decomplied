"""
Decompiled / Reconstructed Module: utils.streaming_multipart

Docstring:
Small, dependency-free helpers for bounded-memory media uploads.

``requests`` eagerly materializes the entire multipart body when ``files=`` is
used.  The helpers here expose a re-iterable body with an exact Content-Length,
so requests can stream from disk without falling back to chunked transfer.
"""

from __future__ import annotations
import sys, os, typing
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Iterator = typing.Iterator
Mapping = typing.Mapping
Optional = typing.Optional
DEFAULT_CHUNK_BYTES = 1048576

# --- Class: StreamingMultipartBody ---
class StreamingMultipartBody:
    """Re-iterable multipart/form-data body backed by one file on disk."""
    def __init__(self, file_path: 'os.PathLike[str] | str', *, field_name: 'str' = 'file', filename: 'Optional[str]' = None, mime_type: 'Optional[str]' = None, fields: 'Optional[Mapping[str, object]]' = None, boundary: 'Optional[str]' = None, chunk_bytes: 'int' = 1048576) -> 'None':
        # [PyArmor BCC constants]: 'os', 'fspath', 'file_path', 'path', 'isfile', 'FileNotFoundError', '_quoted_header_value', 'field_name', 'basename', 'filename', 'str', 'mimetypes', 'guess_type', 0, 'application/octet-stream'
        pass

    def _build_prefix(self) -> 'bytes':
        # [PyArmor BCC constants]: 'fields', 'items', '_quoted_header_value', 'append', '--', 'boundary', '\r\nContent-Disposition: form-data; name="', '"\r\n\r\n', '\r\n', 'encode', 'utf-8', 'field_name', '"; filename="', 'filename', '"\r\nContent-Type: '
        pass

    @property
    def content_type(self):
        pass

    @property
    def content_length(self):
        pass

    def __len__(self) -> 'int':
        pass


# --- Top-Level Functions ---
def _quoted_header_value(value: 'object') -> 'str':
    # [PyArmor BCC constants]: 'str', '', 'replace', '\r', ' ', '\n', '"', "'"
    pass

def decode_base64_to_file(encoded: 'str | bytes', output_path: 'os.PathLike[str] | str', *, chunk_chars: 'int' = 4194304) -> 'int':
    # [PyArmor BCC constants]: 'isinstance', 'str', 'startswith', 'data:', 'find', ',', 0, 1, 'bytes', 'max', 4, 'int', '', 'open', 'wb'
    pass

def estimated_base64_bytes(encoded: 'str | bytes') -> 'int':
    # [PyArmor BCC constants]: 'len', 'isinstance', 'str', 'startswith', 'data:', 'find', ',', 0, 1, 'bytes', 'max', 3, 4
    pass

def path_size(path: 'os.PathLike[str] | str') -> 'int':
    pass
