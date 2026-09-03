"""
Decompiled / Reconstructed Module: utils.frozen_path_helper

Docstring:
Helper for finding resources in frozen executables.
Supports both FLAT structure and _internal structure.
"""

from __future__ import annotations
import sys, os, typing
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
Optional = typing.Optional
List = typing.List

# --- Top-Level Functions ---
def get_base_path() -> pathlib.Path:
    # [PyArmor BCC constants]: 'getattr', 'sys', 'frozen', False, 'Path', 'executable', 'parent', '__file__'
    pass

def find_resource_path(relative_path: str, search_internal: bool = True) -> Optional[pathlib.Path]:
    # [PyArmor BCC constants]: 'getattr', 'sys', 'frozen', False, 'Path', '__file__', 'parent', 'exists', 'get_base_path', 'hasattr', '_MEIPASS', 'append', '_internal'
    pass

def find_resource_paths(relative_path: str, search_internal: bool = True) -> List[pathlib.Path]:
    # [PyArmor BCC constants]: 'getattr', 'sys', 'frozen', False, 'Path', '__file__', 'parent', 'get_base_path', 'hasattr', '_MEIPASS', 'append', '_internal'
    pass

def get_resource_path(relative_path: str) -> str:
    # [PyArmor BCC constants]: 'find_resource_path', 'str', 'getattr', 'sys', 'frozen', False, 'get_base_path', 'exists', '_internal', 'Path', '__file__', 'parent'
    pass
