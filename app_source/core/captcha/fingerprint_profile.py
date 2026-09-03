"""
Decompiled / Reconstructed Module: core.captcha.fingerprint_profile
Source PyC: fingerprint_profile.pyc

Docstring:
Shared deterministic fingerprint profile helpers.

Keep this table and RNG sequence in lockstep with
third_party/blink/renderer/platform/stealth/fingerprint_seed.h/.cc.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Tuple = typing.Tuple
SCREEN_PROFILES = ((1920, 1080, 1.0), (1536, 864, 1.25), (1280, 720, 1.5), (2560, 1440, 1.0), (2048, 1152, 1.25), (2560, 1440, 1.5), (1920, 1080, 2.0), (1280, 800, 2.0), (1440, 900, 2.0), (1366, 768, 1.0))
_MASK64 = 18446744073709551615

# --- Top-Level Functions ---
def _next_xorshift64(state: 'int') -> 'int':
    pass

def seeded_screen_profile(seed: 'int') -> 'Tuple[int, int, float]':
    pass
