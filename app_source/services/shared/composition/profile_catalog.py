"""
Decompiled / Reconstructed Module: services.shared.composition.profile_catalog
Source PyC: profile_catalog.pyc

Docstring:
Shared Sequence Graphics profile contract for every video-producing tab.

The UI may edit a profile, but jobs only consume a normalized snapshot.  The
renderer therefore never depends on a live QML controller or on whichever tab
is visible when final merge starts.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['PROFILE_MODES', 'PROFILE_VERSION', 'SUBTITLE_PRESETS', 'default_sequence_graphics_profile', 'export_sequence_graphics_profile', 'normalize_sequence_graphics_profile', 'resolve_sequence_graphics_profile']

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Mapping = typing.Mapping
PROFILE_VERSION = '1.1'
PROFILE_MODES = frozenset({'auto', 'locked', 'off'})
_LEARNING_LANGUAGE_CODES = frozenset({'ko', 'en', 'pt', 'vi', 'zh', 'th', 'bn', 'fr', 'it', 'ms', 'hi', 'ru', 'es', 'ur', 'de', 'id', 'ar', 'ja', 'tl', 'tr'})
_READING_SYSTEMS = frozenset({'native_and_romanization', 'romanization', 'auto', 'native_reading', 'ipa'})
_LEARNING_LAYOUTS = frozenset({'original_reading_translation', 'original_translation', 'karaoke_learning'})
_LEARNING_HIGHLIGHTS = frozenset({'phrase', 'word_when_measured', 'off'})
_LEARNING_FAILURE_POLICIES = frozenset({'fail_job', 'plain_subtitles'})
SUBTITLE_PRESETS = ({'preset_id': 'clean', 'label': 'Clean', 'category': 'essential', 'description': 'Hai dòng rõ, nền kính nhẹ, dùng tốt cho mọi ngôn ngữ.', 'recommended_for': 'Master · Clone · giáo dục', 'accent': '4E... [truncated]
_PRESET_BY_ID = {'clean': {'preset_id': 'clean', 'label': 'Clean', 'category': 'essential', 'description': 'Hai dòng rõ, nền kính nhẹ, dùng tốt cho mọi ngôn ngữ.', 'recommended_for': 'Master · Clone · giáo dục', 'acc... [truncated]
_LEGACY_STYLE_ALIASES = {'social': 'social_pop', 'kids': 'kids_bounce', 'minimal': 'clean'}
__all__ = ['PROFILE_MODES', 'PROFILE_VERSION', 'SUBTITLE_PRESETS', 'default_sequence_graphics_profile', 'export_sequence_graphics_profile', 'normalize_sequence_graphics_profile', 'resolve_sequence_graphics_prof... [truncated]

# --- Top-Level Functions ---
def default_sequence_graphics_profile(route: 'str' = '') -> 'dict[str, Any]':
    pass

def normalize_sequence_graphics_profile(raw: 'Mapping[str, Any] | None', *, route: 'str' = '') -> 'dict[str, Any]':
    pass

def resolve_sequence_graphics_profile(raw: 'Mapping[str, Any] | None', *, route: 'str', content_language: 'str' = '', market: 'str' = '', content_tags: 'tuple[str, ...]' = ()) -> 'dict[str, Any]':
    pass

def export_sequence_graphics_profile(profile: 'Mapping[str, Any]', output_path: 'str') -> 'str':
    pass
