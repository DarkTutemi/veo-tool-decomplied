"""
Decompiled / Reconstructed Module: core.browser.profile_directory_lock
Source PyC: profile_directory_lock.pyc

Docstring:
Cross-process ownership for one persistent browser profile directory.

Chromium's own ``Singleton*`` files are launch artefacts, not an ownership
contract: Tool 1 deliberately cleans stale Chromium locks before launch.  This
module provides a separate VeoFlow lock outside the profile directory so two
BrowserManager instances (or two Tool 1 processes) cannot clean and launch the
same persistent profile concurrently.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['ProfileDirectoryMutex']

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
_PROCESS_LOCK = <unlocked _thread.lock object at 0x00000264DA57A080>
_PROCESS_OWNERS = {}
__all__ = ['ProfileDirectoryMutex']

# --- Class: ProfileDirectoryMutex ---
class ProfileDirectoryMutex:
    """Non-blocking OS lock held for the lifetime of one browser context."""
    acquired = <property object at 0x00000264DA576C00>

    def __init__(self, profile_directory: 'str | Path') -> 'None':
        pass

    def acquire(self) -> 'bool':
        pass

    def release(self) -> 'None':
        pass

    def __enter__(self) -> "'ProfileDirectoryMutex'":
        pass

    def __exit__(self, exc_type: 'object', exc: 'object', traceback: 'object') -> 'None':
        pass


# --- Top-Level Functions ---
def _canonical_profile_key(profile_directory: 'str | Path') -> 'tuple[str, Path]':
    pass

def _lock_one_byte(handle: 'BinaryIO') -> 'None':
    pass

def _unlock_one_byte(handle: 'BinaryIO') -> 'None':
    pass
