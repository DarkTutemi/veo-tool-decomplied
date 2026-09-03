"""
Decompiled / Reconstructed Module: services.shared.tts.audio_analysis
Source PyC: audio_analysis.pyc

Docstring:
Cached audio facts for the Voice Studio job inspector.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)

# --- Top-Level Functions ---
def _waveform_buckets(samples: 'array', count: 'int') -> 'list[float]':
    pass

def _loudness(path: 'Path') -> 'dict[str, Any]':
    pass

def analyze_audio(path: 'str', waveform_points: 'int' = 96) -> 'dict[str, Any]':
    pass
