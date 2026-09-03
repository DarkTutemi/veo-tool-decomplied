"""
Decompiled / Reconstructed Module: core.feature_flags
Source PyC: feature_flags.pyc

Docstring:
Runtime feature flags for unreleased or experimental behavior.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Top-Level Functions ---
def _env_bool(name: str, default: bool = False) -> bool:
    pass

def flow_voice_references_enabled() -> bool:
    pass

def structured_reference_parts_enabled() -> bool:
    pass
