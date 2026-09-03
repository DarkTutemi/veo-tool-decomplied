"""
Decompiled / Reconstructed Module: services.automation_center.adapters.transcript
Source PyC: transcript.pyc

Docstring:
Audio-to-Video adapter using Tool 1's canonical Transcript queue.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['TranscriptWorkflowAdapter']

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
_STYLE_KEYS = ('selected_style_id', 'style_id', 'override_style', 'selected_style', 'selected_style_name', 'structural_style_id')
_AUDIO_EXTENSIONS = {'.ogg', '.m4a', '.mp3', '.wav'}
__all__ = ['TranscriptWorkflowAdapter']

# --- Class: TranscriptWorkflowAdapter ---
class TranscriptWorkflowAdapter(Tool1ProductQueueAdapter):
    workflow = 'transcript'
    capability = 'video.audio_to_video'
    display_name = 'Audio-to-Video'
    input_modes = ('text', 'audio_file', 'audio_url')
    feature_code = 'transcript_panel'

    def __init__(self, *, service_provider: 'Callable[[], Any] | None' = None, config_provider: 'Callable[[], Mapping[str, Any]] | None' = None, admission_provider: 'Callable[[], Mapping[str, Any] | None] | None' = None, session_key: 'str' = 'transcript_video') -> 'None':
        pass

    @staticmethod
    def _default_service_provider() -> 'Any':
        pass

    @staticmethod
    def _default_config_provider() -> 'Mapping[str, Any]':
        pass

    @staticmethod
    def _default_admission_provider() -> 'Mapping[str, Any] | None':
        pass

    def validate(self, job: 'AutomationJob') -> 'None':
        pass

    def start(self, job: 'AutomationJob', *, on_internal_run_created: 'Callable[[str], None]') -> 'str':
        pass

    @staticmethod
    def _transcript_input(value: 'Mapping[str, Any]') -> 'tuple[dict[str, Any], str]':
        pass

    def _find_row(self, internal_run_id: 'str') -> 'dict[str, Any] | None':
        pass

    def _start_target(self, internal_run_id: 'str', row: 'Mapping[str, Any]') -> 'Mapping[str, Any]':
        pass

