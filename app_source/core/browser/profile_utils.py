"""
Decompiled / Reconstructed Module: core.browser.profile_utils
Source PyC: profile_utils.pyc

Docstring:
Shared browser profile maintenance helpers.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)

# --- Top-Level Functions ---
def _unlink_with_retry(lock_path: 'Path', label: 'str', attempts: 'int' = 5, base_delay: 'float' = 0.2) -> 'bool':
    pass

def cleanup_firefox_locks(profile_dir: 'Path') -> 'bool':
    pass

def cleanup_chrome_locks(profile_dir: 'Path') -> 'bool':
    pass

def validate_profile(profile_dir: 'Path', browser_type: 'str' = 'chrome') -> 'bool':
    pass
