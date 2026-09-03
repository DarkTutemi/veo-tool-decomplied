"""
Decompiled / Reconstructed Module: utils.boot_smoke

Docstring:
Shared payload for the frozen/source QML boot smoke.

The existing ``--self-check`` and ``--startup-smoke-output`` paths never call
``engine.load(App.qml)``. A duplicate QML property therefore ships. This module
is the pass/fail contract for ``--boot-smoke-output``.

Production double-click must stay a normal app: enable only from argv
``--boot-smoke-output <path>``. Leftover env vars must not silent-exit.
"""

from __future__ import annotations
import sys, os, typing
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
BOOT_SMOKE_OPTION = '--boot-smoke-output'

# --- Top-Level Functions ---
def boot_smoke_output_path(argv: 'list[str] | None' = None) -> 'str':
    # [PyArmor BCC constants]: 'list', 'sys', 'argv', 'BOOT_SMOKE_OPTION', '=', 'str', 'startswith', 'split', 1, 'strip', 'index', '', 'ValueError', 'len', '-'
    pass

def boot_smoke_enabled(argv: 'list[str] | None' = None) -> 'bool':
    pass

def report_is_pass(payload: 'Any') -> 'bool':
    # [PyArmor BCC constants]: 'isinstance', 'dict', False, 'str', 'get', 'status', '', 'pass', 'int', 'root_objects', 0, 'TypeError', 'ValueError', 1, 'error'
    pass

def write_boot_smoke_report(path: 'str | Path', payload: 'dict[str, Any]') -> 'None':
    # [PyArmor BCC constants]: 'Path', 'parent', 'mkdir', 'parents', True, 'exist_ok', 'with_name', 'name', '.tmp', 'write_text', 'json', 'dumps', 'ensure_ascii', 'sort_keys', '\n'
    pass
