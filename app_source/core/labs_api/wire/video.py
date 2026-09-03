"""
Decompiled / Reconstructed Module: core.labs_api.wire.video
Source PyC: video.pyc

Docstring:
core/labs_api/wire/video.py — payload builders for each video generation feature.

Pure functions: (params) -> (url, payload dict). No I/O, no browser, no session.
Ported verbatim from the payload-build blocks in core/api_client.py.

Covered:
  build_t2v      — batchAsyncGenerateVideoText (1430-1467)
  build_i2v      — batchAsyncGenerateVideoStartImage (1730-1755)
  build_2i2v     — batchAsyncGenerateVideoStartAndEndImage (2760-2800)
  build_multi    — batchAsyncGenerateVideoReferenceImages (1885-1900)
  build_extend   — batchAsyncGenerateVideoExtendVideo (1641-1658)
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
List = typing.List
Optional = typing.Optional
Tuple = typing.Tuple
_RESOLUTION_OUTPUT_SPEC = {'360p': 'VIDEO_RESOLUTION_360P', '720p': 'VIDEO_RESOLUTION_720P', '1080p': 'VIDEO_RESOLUTION_1080P', '4k': 'VIDEO_RESOLUTION_4K'}
_GEN_RES_RANK = {'VIDEO_RESOLUTION_360P': 0, 'VIDEO_RESOLUTION_720P': 1, 'VIDEO_RESOLUTION_1080P': 2, 'VIDEO_RESOLUTION_4K': 3}
_DEFAULT_GEN_RESOLUTIONS = ('VIDEO_RESOLUTION_720P',)

# --- Top-Level Functions ---
def _client_ctx(session_id: 'str', project_id: 'str', user_tier: 'str') -> 'Dict[str, Any]':
    pass

def _random_seed() -> 'int':
    pass

def _api_key(model: 'str') -> 'str':
    pass

def _normalize_aspect(aspect_ratio: 'str') -> 'str':
    pass

def _output_spec(resolution: 'Any') -> 'Dict[str, Any]':
    pass

def _model_generation_resolutions(model: 'str') -> 'tuple':
    """Resolutions this model may emit on a GENERATE call (not upsample)."""
    pass

def _output_spec_for_model(model: 'str', resolution: 'Any') -> 'Dict[str, Any]':
    pass

def build_t2v(wire_prompt: 'str', model: 'str', output_count: 'int', aspect_ratio: 'str', session_id: 'str', project_id: 'str', user_tier: 'str', seed: 'Optional[int]' = None, batch_id: 'Optional[str]' = None, resolution: 'str' = '') -> 'Tuple[str, Dict[str, Any]]':
    pass

def build_i2v(media_id: 'str', wire_prompt: 'str', model: 'str', aspect_ratio: 'str', session_id: 'str', project_id: 'str', user_tier: 'str', seed: 'Optional[int]' = None, batch_id: 'Optional[str]' = None) -> 'Tuple[str, Dict[str, Any]]':
    pass

def build_2i2v(start_media_id: 'str', end_media_id: 'str', wire_prompt: 'str', model: 'str', aspect_ratio: 'str', session_id: 'str', project_id: 'str', user_tier: 'str', seed: 'Optional[int]' = None, batch_id: 'Optional[str]' = None) -> 'Tuple[str, Dict[str, Any]]':
    pass

def build_multi(wire_prompt: 'str', model: 'str', output_count: 'int', reference_images: 'List[Dict[str, str]]', reference_audio_entries: 'List[Any]', reference_entity_entries: 'List[Any]', requests_list: 'List[Dict[str, Any]]', session_id: 'str', project_id: 'str', user_tier: 'str', batch_id: 'Optional[str]' = None) -> 'Tuple[str, Dict[str, Any]]':
    pass

def build_extend(wire_prompt: 'str', media_id: 'str', model: 'str', aspect_ratio: 'str', session_id: 'str', project_id: 'str', user_tier: 'str', workflow_id: 'str' = '', seed: 'Optional[int]' = None, batch_id: 'Optional[str]' = None) -> 'Tuple[str, Dict[str, Any]]':
    pass
