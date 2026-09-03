"""
Decompiled / Reconstructed Module: services.shared.image_rhythm.framework
Source PyC: framework.pyc

Docstring:
Single authority for image-count and image-pacing decisions.

The UI chooses exactly one rhythm mode. This module migrates legacy two-control
configs, mirrors compatibility keys for older callers, and creates an immutable
count/timeline manifest that every downstream stage must obey.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
List = typing.List
MutableMapping = typing.MutableMapping
Optional = typing.Optional
Sequence = typing.Sequence
IMAGE_RHYTHM_VERSION = 1
IMAGE_RHYTHM_MODES = ('single', 'auto', 'fixed', 'detailed', 'balanced', 'chapter', 'template')
IMAGE_RHYTHM_CONFIG_KEYS = frozenset({'image_pacing', 'image_count_mode', 'image_rhythm_target', 'image_rhythm_mode', 'image_target_count', 'image_rhythm_template_id', 'image_rhythm_version'})
IMAGE_RHYTHM_TEMPLATES = {'sleep_winddown': {'label_vi': 'Audio đi ngủ / dỗ ngủ', 'description': 'Đầu dày giữ chân người nghe, càng về sau càng thưa, cuối chỉ 1-2 ảnh đại diện.', 'auto_hints': "bedtime story, sleep aid, calm ... [truncated]
_IMAGE_TEMPLATE_ALIASES = {'auto': 'auto', 'sleep': 'sleep_winddown', 'bedtime': 'sleep_winddown', 'ngu': 'sleep_winddown', 'meditation': 'meditation_guide', 'thien': 'meditation_guide', 'list': 'listicle', 'listicle': 'listic... [truncated]
_MODE_ALIASES = {'off': 'single', 'one': 'single', 'one_image': 'single', 'single_static': 'single', 'manual': 'fixed', 'fixed_count': 'fixed', 'exact': 'fixed', 'moment': 'auto', 'scene': 'detailed', 'dense': 'detai... [truncated]
_MODE_TO_PACING = {'single': 'auto', 'auto': 'auto', 'fixed': 'auto', 'detailed': 'detailed', 'balanced': 'moderate', 'chapter': 'sparse', 'template': 'auto'}
IMAGE_RHYTHM_DENSITY_ENVELOPES = {'balanced': {'min_average_hold_s': 60.0, 'max_average_hold_s': 180.0}, 'chapter': {'min_average_hold_s': 180.0, 'max_average_hold_s': 480.0}}
IMAGE_RHYTHM_MIN_HOLD_S = 1.0
MAX_GROUPS_PER_PASS1_CALL = 40

# --- Class: ImageRhythmInvariantError ---
class ImageRhythmInvariantError(RuntimeError):
    """Raised when a downstream stage would change an authored rhythm manifest."""
    def __init__(self, code: 'str', message: 'str', details: 'Optional[Dict[str, Any]]' = None) -> 'None':
        pass


# --- Top-Level Functions ---
def image_rhythm_template_ids() -> 'List[str]':
    pass

def normalize_image_rhythm_template(value: 'Any') -> 'str':
    pass

def image_rhythm_template(id_value: 'Any') -> 'Optional[Dict[str, Any]]':
    pass

def image_rhythm_template_catalog_text() -> 'str':
    pass

def image_rhythm_phase_weights(template_id: 'Any', durations: 'Sequence[float]', audio_duration: 'float') -> 'List[float]':
    pass

def image_rhythm_effective_target(config: 'Optional[Dict[str, Any]]', audio_duration: 'float', srt_row_count: 'int' = 0) -> 'Dict[str, Any]':
    pass

def _target_count(value: 'Any', fallback: 'int' = 1) -> 'int':
    pass

def normalize_image_rhythm_mode(value: 'Any', default: 'str' = 'auto') -> 'str':
    pass

def resolve_image_rhythm_intent(config: 'Optional[Dict[str, Any]]') -> 'Dict[str, Any]':
    pass

def apply_image_rhythm_intent(config: 'MutableMapping[str, Any]', mode: 'Any' = None, target_count: 'Any' = None) -> 'Dict[str, Any]':
    pass

def normalize_image_rhythm_config(config: 'Optional[Dict[str, Any]]') -> 'Dict[str, Any]':
    pass

def strip_implicit_image_rhythm_override(override: 'Optional[Dict[str, Any]]') -> 'Dict[str, Any]':
    pass

def image_rhythm_group_constraints(config: 'Optional[Dict[str, Any]]', audio_duration: 'float', srt_row_count: 'int' = 0) -> 'Dict[str, Any]':
    pass

def _window_bounds(window: 'Dict[str, Any]') -> 'tuple[float, float]':
    pass

def build_image_rhythm_manifest(config: 'Optional[Dict[str, Any]]', windows: 'Sequence[Dict[str, Any]]', audio_duration: 'float', srt_row_count: 'int' = 0, boundary_source: 'str' = 'srt_semantic') -> 'Dict[str, Any]':
    pass

def expected_image_count(result_data: 'Optional[Dict[str, Any]]', scenes: 'Optional[Sequence[Dict[str, Any]]]' = None) -> 'int':
    pass

def validate_image_rhythm_manifest(manifest: 'Optional[Dict[str, Any]]', scenes: 'Optional[Sequence[Dict[str, Any]]]' = None, images: 'Optional[Sequence[str]]' = None, require_files: 'bool' = False, stage: 'str' = '') -> 'Dict[str, Any]':
    pass
