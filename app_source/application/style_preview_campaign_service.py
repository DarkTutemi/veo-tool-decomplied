"""
Decompiled / Reconstructed Module: application.style_preview_campaign_service
Source PyC: style_preview_campaign_service.pyc

Docstring:
Campaign planning helpers for style preview generation.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)

# --- Top-Level Functions ---
def _text(value: 'Any') -> 'str':
    pass

def style_preview_dedupe_key(item: 'dict[str, Any]', preview_version: 'str' = 'v1') -> 'str':
    pass

def build_style_preview_campaign(items: 'list[dict[str, Any]] | None', *, only_missing: 'bool' = True, preview_version: 'str' = 'v1') -> 'dict[str, Any]':
    pass
