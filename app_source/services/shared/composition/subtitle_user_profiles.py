"""
Decompiled / Reconstructed Module: services.shared.composition.subtitle_user_profiles
Source PyC: subtitle_user_profiles.pyc

Docstring:
Durable named profiles for the shared Subtitle Studio.

The visual preset catalogue answers *what the subtitle looks like*.  A user
profile captures the complete working setup (content mode, preset, font,
layout and learning-language options) so it can be reused across routes with
one click.  All store methods are pure Python and are expected to be called
off the GUI thread by the QML controller.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['SubtitleUserProfileStore', 'profile_snapshot']

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Mapping = typing.Mapping
_SCHEMA_VERSION = 1
_MAX_PROFILES = 40
__all__ = ['SubtitleUserProfileStore', 'profile_snapshot']

# --- Class: SubtitleUserProfileStore ---
class SubtitleUserProfileStore:
    """Small atomic JSON store for named Subtitle Studio configurations."""
    def __init__(self, path: 'str | Path | None' = None) -> 'None':
        pass

    def _read_unlocked(self) -> 'dict[str, Any]':
        pass

    def _write_unlocked(self, payload: 'Mapping[str, Any]') -> 'None':
        pass

    @staticmethod
    def _sorted_rows(rows: 'list[dict[str, Any]]') -> 'list[dict[str, Any]]':
        pass

    def list_profiles(self) -> 'list[dict[str, Any]]':
        pass

    def save_profile(self, name: 'str', profile: 'Mapping[str, Any]', route: 'str', profile_id: 'str' = '') -> 'dict[str, Any]':
        pass

    def delete_profile(self, profile_id: 'str') -> 'list[dict[str, Any]]':
        pass

    def mark_used(self, profile_id: 'str') -> 'list[dict[str, Any]]':
        pass

    def load_autosave(self, route: 'str') -> 'dict[str, Any]':
        pass

    def save_autosave(self, route: 'str', state: 'Mapping[str, Any]') -> 'dict[str, Any]':
        pass

    def clear_autosave(self, route: 'str') -> 'bool':
        pass


# --- Top-Level Functions ---
def _utc_now() -> 'str':
    pass

def _safe_name(value: 'Any') -> 'str':
    pass

def profile_snapshot(profile: 'Mapping[str, Any] | None') -> 'dict[str, Any]':
    pass
