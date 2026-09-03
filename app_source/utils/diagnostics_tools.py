"""
Decompiled / Reconstructed Module: utils.diagnostics_tools

Docstring:
Diagnostics export and analysis helpers for customer machines.
"""

from __future__ import annotations
import sys, os, typing
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
List = typing.List

# --- Top-Level Functions ---
def _safe_read_text(path: 'Path', limit: 'int' = 20000) -> 'str':
    # [PyArmor BCC constants]: 'read_text', 'encoding', 'utf-8', 'errors', 'replace', '', 'Exception'
    pass

def collect_diagnostics_summary() -> 'Dict[str, Any]':
    # [PyArmor BCC constants]: 'get_logs_dir', 'get_crash_reports_dir', 'sorted', 'glob', '*.json', 20, 'json', 'loads', 'read_text', 'encoding', 'utf-8', 'Exception', 'append', 'file', 'error_type'
    pass

def export_diagnostics_bundle(output_dir: 'Path | None' = None) -> 'Path':
    # [PyArmor BCC constants]: 'get_appdata_dir', 'get_logs_dir', 'get_crash_reports_dir', 'diagnostics_exports', 'mkdir', 'parents', True, 'exist_ok', 'datetime', 'now', 'strftime', '%Y%m%d_%H%M%S', 'veoflow_diagnostics_', '.zip', 'collect_diagnostics_summary'
    pass

def analyze_existing_logs() -> 'Dict[str, Any]':
    pass
