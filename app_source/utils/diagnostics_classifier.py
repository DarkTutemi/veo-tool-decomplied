"""
Decompiled / Reconstructed Module: utils.diagnostics_classifier

Docstring:
Simple diagnostics classifier for crash and forensic artifacts.
"""

from __future__ import annotations
import sys, os, typing
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
Iterable = typing.Iterable
List = typing.List
_RULES = [('browser_crash', ['browser_crash', 'target closed', 'browser has been closed', 'disconnected', 'playwright', 'chromium']), ('gpu_driver', ['nvwgf2umx', 'igd', 'd3d', 'opengl', 'gpu process', 'graphi... [truncated]
_BENIGN_NOISE = ('[watermarkremover]', '[h264 @', '[hevc @', 'mmco: unref short failure', 'mmco: unref short', 'non-existing pps', 'decode_slice_header error', 'co located pocs unavailable', 'error while decoding mb'... [truncated]

# --- Top-Level Functions ---
def _strip_benign_noise(text: 'str') -> 'str':
    """Drop known-benign decoder/watermark lines so they never classify as errors."""
    pass

def _normalize_text(parts: 'Iterable[str]') -> 'str':
    pass

def classify_text(text: 'str') -> 'Dict[str, Any]':
    # [PyArmor BCC constants]: '_strip_benign_noise', '', 'lower', '_RULES', 'append', 'category', 'matched_terms', 0, 'unknown', 'primary_category', 'matches'
    pass

def classify_report(report: 'Dict[str, Any]') -> 'Dict[str, Any]':
    # [PyArmor BCC constants]: '_normalize_text', 'str', 'get', 'error_type', '', 'error_message', 'traceback', 'source', 'context', 'classify_text', 'exception_type', 'MemoryError', 'memory_or_oom', 'primary_category', 'matches'
    pass
