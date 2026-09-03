"""
Decompiled / Reconstructed Module: utils.opencv_image_io

Docstring:
Unicode- and long-path-safe OpenCV still-image file I/O.

OpenCV's ``imread``/``imwrite`` path handling is backend-dependent on Windows
and can fail for perfectly valid files whose paths contain non-ASCII text.
Decode and encode bytes instead; Python owns the filesystem path boundary and
therefore uses the native wide-character APIs.
"""

from __future__ import annotations
import sys, os, typing
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['read_image_file', 'write_image_file']

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Sequence = typing.Sequence
_ENCODABLE_EXTENSIONS = frozenset({'.dib', '.exr', '.pic', '.pfm', '.tif', '.jpg', '.pnm', '.bmp', '.hdr', '.webp', '.pxm', '.pbm', '.ras', '.jpeg', '.jpe', '.tiff', '.png', '.jp2', '.ppm', '.sr', '.pgm'})
__all__ = ['read_image_file', 'write_image_file']

# --- Top-Level Functions ---
def _native_path(value: 'Any') -> 'str':
    # [PyArmor BCC constants]: 'os', 'fspath', 'name', 'nt', 'path', 'abspath', 'startswith', '\\\\?\\', 'len', 240, '\\\\', '\\\\?\\UNC\\', 2
    pass

def read_image_file(path: 'Any', flags: 'int | None' = None, cv2_module: 'Any' = None, numpy_module: 'Any' = None) -> 'Any':
    # [PyArmor BCC constants]: 'IMREAD_COLOR', 'int', 'open', '_native_path', 'rb', 'read', 'frombuffer', 'dtype', 'uint8', 'imdecode', 'Exception'
    pass

def write_image_file(path: 'Any', image: 'Any', params: 'Sequence[int] | None' = None, cv2_module: 'Any' = None) -> 'bool':
    # [PyArmor BCC constants]: '', '_native_path', 'os', 'path', 'splitext', 'fspath', 1, 'strip', 'lower', '.jpeg', '.jpg', '_ENCODABLE_EXTENSIONS', '.png', 'imencode', 'list'
    pass
