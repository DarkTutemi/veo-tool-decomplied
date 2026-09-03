"""
Decompiled / Reconstructed Module: services.tabs.clone_video.narration_policy
Source PyC: narration_policy.pyc

Docstring:
Clone VIDEO narrator policy and source-evidence gate.

The generated scene JSON is not sufficient evidence that the *source* contained
an editorial narrator: the authoring model can accidentally put ambient footage
into ``narrator_voice``.  This module keeps the user policy and the conservative
AUTO gate in one pure, testable seam immediately before narration rendering.

IMAGE output intentionally does not use this policy.  Its one completed TTS WAV
is the clock consumed by the shared Audio-to-Video image pipeline.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['NARRATION_POLICY_AUTO', 'NARRATION_POLICY_OFF', 'NARRATION_POLICY_ON', 'VALID_NARRATION_POLICIES', 'apply_clone_video_narration_policy', 'build_clone_source_audio_contract', 'normalize_clone_narration_policy', 'source_narration_evidence']

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
Iterable = typing.Iterable
Mapping = typing.Mapping
NARRATION_POLICY_AUTO = 'auto'
NARRATION_POLICY_ON = 'on'
NARRATION_POLICY_OFF = 'off'
VALID_NARRATION_POLICIES = {'auto', 'on', 'off'}
__all__ = ['NARRATION_POLICY_AUTO', 'NARRATION_POLICY_OFF', 'NARRATION_POLICY_ON', 'VALID_NARRATION_POLICIES', 'apply_clone_video_narration_policy', 'build_clone_source_audio_contract', 'normalize_clone_narrati... [truncated]

# --- Top-Level Functions ---
def normalize_clone_narration_policy(value: 'Any') -> 'str':
    pass

def build_clone_source_audio_contract(policy: 'Any') -> 'str':
    pass

def _mapping(value: 'Any') -> 'Dict[str, Any]':
    pass

def _iter_evidence(value: 'Any') -> 'Iterable[Dict[str, Any]]':
    pass

def source_narration_evidence(result_data: 'Mapping[str, Any]') -> 'Dict[str, Any]':
    pass

def _scene_collections(result_data: 'Dict[str, Any]') -> 'Iterable[Any]':
    pass

def _iter_scenes(collection: 'Any') -> 'Iterable[Dict[str, Any]]':
    pass

def _strip_app_narrator(result_data: 'Dict[str, Any]') -> 'int':
    pass

def _effective_output_audio_flags(result_data: 'Dict[str, Any]') -> 'tuple[bool, bool]':
    pass

def apply_clone_video_narration_policy(result_data: 'Dict[str, Any]', policy: 'Any') -> 'Dict[str, Any]':
    pass
