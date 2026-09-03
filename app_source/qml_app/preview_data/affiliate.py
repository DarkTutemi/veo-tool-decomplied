"""
Decompiled / Reconstructed Module: qml_app.preview_data.affiliate

Docstring:
Fake Affiliate cockpit data used only by the opt-in UI preview mode.
"""

from __future__ import annotations
import sys, os, typing
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)

# --- Top-Level Functions ---
def _web_image(seed: 'str') -> 'str':
    pass

def _image_previews(seed: 'str', count: 'int' = 5) -> 'list[dict[str, str]]':
    # [PyArmor BCC constants]: 'range', 1, 'thumbnail_url', '_web_image', '-'
    pass

def _variant(index: 'int', video_type: 'str', label: 'str', hook: 'str', cta: 'str') -> 'dict[str, Any]':
    # [PyArmor BCC constants]: 'variant_index', 'video_type', 'video_type_label', 'hook', 'cta'
    pass

def build_affiliate_ui_preview(project_root: 'Path') -> 'dict[str, Any]':
    # [PyArmor BCC constants]: 'assets', 'demo', 'timemachine_treehouse', 'range', 1, 7, 'str', 'view-01-stage-', '02d', '.png', 'id', 'product_id', 'selected', 'status', 'prep_status'
    pass
