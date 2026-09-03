"""
Decompiled / Reconstructed Module: services.automation_center.adapters.route_config
Source PyC: route_config.pyc

Docstring:
Canonical Tool 1 route configuration snapshots for local automation rows.

Automation Center must freeze the same effective configuration that each native
tab would use.  Reading ``defaults + saved JSON`` here used to bypass the
normalization performed by Clone, Audio-to-Video and Affiliate (model aliases,
image rhythm, library policy, voice options, legacy migrations, and so on).
The route use-cases are Qt-free, so reuse those loaders instead of maintaining a
second, gradually diverging configuration implementation.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['load_route_config']

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
__all__ = ['load_route_config']

# --- Top-Level Functions ---
def load_route_config(route: 'str', *, settings_manager: 'Any | None' = None) -> 'dict[str, Any]':
    pass
