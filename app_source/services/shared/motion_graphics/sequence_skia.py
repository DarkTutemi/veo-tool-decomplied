"""
Decompiled / Reconstructed Module: services.shared.motion_graphics.sequence_skia
Source PyC: sequence_skia.pyc

Docstring:
Skia Sequence Graphics spine matching SequenceCompositionPreview.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Sequence = typing.Sequence
YEARS = ('1800', '1850', '1946', '2000', '2024')
LABELS = ('Khởi nguyên', 'Chuyển dịch', 'Bước ngoặt', 'Mở rộng', 'Hiện tại')
_FACE_CACHE = {}
_ROLE_FILES = {'display': 'BeVietnamPro-SemiBold.ttf', 'editorial': 'NotoSerif-SemiBold.ttf', 'data': 'IBMPlexSans-SemiBold.ttf', 'condensed': 'BarlowCondensed-SemiBold.ttf', 'rounded': 'BeVietnamPro-Bold.ttf'}

# --- Top-Level Functions ---
def _hex(value: 'Any', fallback: 'str' = 'FFFFFF', alpha: 'int' = 255) -> 'int':
    pass

def _fill(color: 'int', alpha: 'int | None' = None):
    pass

def _stroke(color: 'int', width: 'float', alpha: 'int' = 255):
    pass

def font_path_for_role(role: 'str') -> 'str':
    pass

def _bundled_display_font() -> 'str':
    pass

def _typeface(font_path: 'str' = ''):
    pass

def _text(canvas, text: 'str', x: 'float', y: 'float', size: 'float', color: 'int', *, bold: 'bool' = False, font_path: 'str' = '', glow: 'float' = 0.0, shadow: 'float' = 0.0) -> 'None':
    pass

def paint_sequence_spine(canvas: 'Any', *, width: 'int', height: 'int', progress: 'float', theme: 'dict[str, Any] | None' = None, title: 'str' = '', years: 'Sequence[str] | None' = None, labels: 'Sequence[str] | None' = None, marker_count: 'int' = 5) -> 'None':
    pass
