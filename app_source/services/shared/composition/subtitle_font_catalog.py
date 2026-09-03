"""
Decompiled / Reconstructed Module: services.shared.composition.subtitle_font_catalog
Source PyC: subtitle_font_catalog.pyc

Docstring:
Font discovery and validation for the shared Subtitle Studio.

The catalog is deliberately Qt-free.  Controllers run the potentially slow
system-font scan off the GUI thread, while render workers resolve the same
stable font id back to an absolute file.  A custom font is copied into
VeoFlow's writable data directory so queued jobs never depend on a removable
download path.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['FONT_CATALOG_VERSION', 'SUPPORTED_FONT_SUFFIXES', 'build_font_catalog', 'bundled_font_catalog', 'custom_font_catalog', 'font_has_text', 'import_custom_font', 'resolve_catalog_font', 'resolve_covering_font', 'scan_system_fonts', 'system_font_directories']

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Iterable = typing.Iterable
Mapping = typing.Mapping
FONT_CATALOG_VERSION = '1.0'
SUPPORTED_FONT_SUFFIXES = frozenset({'.otf', '.ttf', '.ttc'})
_BUNDLED_FONT_ROWS = (('display', 'Be Vietnam Pro', 'BeVietnamPro-SemiBold.ttf', 'Hiện đại · Latin/Vietnamese'), ('rounded', 'Be Vietnam Pro Bold', 'BeVietnamPro-Bold.ttf', 'Đậm · social · trẻ em'), ('editorial', 'Noto Se... [truncated]
scan_system_fonts = <functools._lru_cache_wrapper object at 0x00000264E15F4BF0>
__all__ = ['FONT_CATALOG_VERSION', 'SUPPORTED_FONT_SUFFIXES', 'build_font_catalog', 'bundled_font_catalog', 'custom_font_catalog', 'font_has_text', 'import_custom_font', 'resolve_catalog_font', 'resolve_coverin... [truncated]

# --- Top-Level Functions ---
def _font_id(source: 'str', path: 'Path') -> 'str':
    pass

def _font_names(path: 'Path') -> 'tuple[str, str]':
    """Read family/subfamily without making fontTools a runtime requirement."""
    pass

def _row(path: 'Path', *, source: 'str', role: 'str' = 'custom', note: 'str' = '') -> 'dict[str, Any]':
    pass

def bundled_font_catalog() -> 'list[dict[str, Any]]':
    pass

def system_font_directories() -> 'tuple[Path, ...]':
    pass

def sys_platform() -> 'str':
    pass

def custom_font_directory() -> 'Path':
    pass

def _iter_font_files(roots: 'Iterable[Path]', *, limit: 'int' = 1200) -> 'Iterable[Path]':
    pass

def custom_font_catalog() -> 'list[dict[str, Any]]':
    pass

def build_font_catalog(*, include_system: 'bool' = True, system_limit: 'int' = 600) -> 'list[dict[str, Any]]':
    pass

def import_custom_font(source_path: 'str', *, target_dir: 'str' = '') -> 'dict[str, Any]':
    pass

def font_has_text(path: 'str', text: 'str') -> 'dict[str, Any]':
    """Return a deterministic glyph coverage report for one real font file."""
    pass

def resolve_catalog_font(profile: 'Mapping[str, Any]', *, language: 'str', market: 'str' = 'global') -> 'dict[str, Any]':
    """Resolve a user font selection, falling back to locale-safe bundled data."""
    pass

def resolve_covering_font(profile: 'Mapping[str, Any]', text: 'str', *, language: 'str', market: 'str' = 'global') -> 'dict[str, Any]':
    pass
