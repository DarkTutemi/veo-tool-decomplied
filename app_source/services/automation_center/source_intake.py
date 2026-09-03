"""
Decompiled / Reconstructed Module: services.automation_center.source_intake
Source PyC: source_intake.pyc

Docstring:
Verified batch-source intake for the local Channel Copilot.

Only explicit operator inputs are accepted here.  URL metadata probes are
blocking by nature, so callers must invoke this object from Automation Center's
worker executor, never from a Qt/QML handler.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['CopilotSourceIntake', 'MAX_BATCH_SOURCES']

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
MAX_BATCH_SOURCES = 200
_VIDEO_EXTENSIONS = {'.3gpp', '.mov', '.mp4', '.mpg', '.wmv', '.webm', '.mkv', '.mpeg', '.flv', '.avi'}
_AUDIO_EXTENSIONS = {'.ogg', '.m4a', '.mp3', '.wav'}
_IMAGE_EXTENSIONS = {'.png', '.jpg', '.avif', '.jpeg', '.webp'}
_MODE_ALIASES = {'url': 'video_url', 'clone_url': 'video_url', 'link': 'audio_url', 'audio_link': 'audio_url'}
_DEFAULT_WORKFLOW = {'idea': 'master', 'script': 'master', 'video_url': 'clone', 'local_video': 'clone', 'text': 'transcript', 'audio_url': 'transcript', 'audio_file': 'transcript', 'prepared_product': 'affiliate'}
_ALLOWED_MODES = {'master': frozenset({'script', 'idea'}), 'clone': frozenset({'local_video', 'video_url'}), 'transcript': frozenset({'audio_file', 'text', 'audio_url'}), 'affiliate': frozenset({'prepared_product'}), ... [truncated]
__all__ = ['CopilotSourceIntake', 'MAX_BATCH_SOURCES']

# --- Class: CopilotSourceIntake ---
class CopilotSourceIntake:
    """Normalize and verify a bounded batch of operator-owned sources."""
    def __init__(self, clone_metadata_provider: 'Callable[[str], Mapping[str, Any]] | None' = None, audio_metadata_provider: 'Callable[[str], Mapping[str, Any]] | None' = None, product_provider: 'Callable[[str], Mapping[str, Any] | None] | None' = None) -> 'None':
        pass

    def prepare_batch(self, values: 'Iterable[Mapping[str, Any]]') -> 'list[dict[str, Any]]':
        pass

    def _prepare_one(self, position: 'int', value: 'Mapping[str, Any]') -> 'dict[str, Any]':
        pass

    @staticmethod
    def _invalid_row(position: 'int', value: 'Mapping[str, Any]', code: 'str', message: 'str') -> 'dict[str, Any]':
        pass

    @staticmethod
    def _positive_int(value: 'Any') -> 'int':
        pass

    @staticmethod
    def _default_clone_metadata(url: 'str') -> 'Mapping[str, Any]':
        pass

    @staticmethod
    def _default_audio_metadata(url: 'str') -> 'Mapping[str, Any]':
        pass

    @staticmethod
    def _default_product(product_id: 'str') -> 'Mapping[str, Any] | None':
        pass


# --- Top-Level Functions ---
def _text(value: 'Any') -> 'str':
    pass

def _canonical_hash(value: 'Mapping[str, Any]') -> 'str':
    pass

def _http_url(value: 'str') -> 'bool':
    pass
