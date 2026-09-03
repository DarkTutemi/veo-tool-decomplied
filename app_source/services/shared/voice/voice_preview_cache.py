"""
Decompiled / Reconstructed Module: services.shared.voice.voice_preview_cache
Source PyC: voice_preview_cache.pyc

Docstring:
Shared narration-preview lookup and persistent cache.

Preview buttons across Master, Clone and Voice Studio must use the same policy:

1. Play a bundled provider/voice sample when one exists.
2. Reuse a previously rendered preview for the exact provider configuration.
3. Render only the first cache miss, off the GUI thread.

This module is deliberately Qt-free.  Filesystem work is expected to be called
from ``_VoiceWorker`` rather than from a QML handler.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Mapping = typing.Mapping
_SAFE_NAME_RE = re.compile('[^a-z0-9_-]+')

# --- Top-Level Functions ---
def _safe_name(value: 'Any', fallback: 'str' = 'default') -> 'str':
    pass

def _resource_roots() -> 'list[Path]':
    pass

def bundled_preview_path(provider: 'str', voice_id: 'str') -> 'Path | None':
    pass

def _ref_fingerprint(value: 'Any') -> 'dict[str, Any] | str':
    pass

def preview_cache_path(provider: 'str', text: 'str', voice_id: 'str', model: 'str', provider_options: 'Mapping[str, Any] | None') -> 'Path':
    pass

def usable_preview(path: 'str | Path | None') -> 'bool':
    pass
