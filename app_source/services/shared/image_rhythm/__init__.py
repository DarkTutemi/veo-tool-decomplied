"""
Decompiled / Reconstructed Module: services.shared.image_rhythm.__init__
Source PyC: __init__.pyc

Docstring:
Canonical image-rhythm policy, manifest and invariant helpers.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['IMAGE_RHYTHM_MODES', 'IMAGE_RHYTHM_CONFIG_KEYS', 'IMAGE_RHYTHM_DENSITY_ENVELOPES', 'IMAGE_RHYTHM_VERSION', 'ImageRhythmInvariantError', 'apply_image_rhythm_intent', 'build_image_rhythm_manifest', 'expected_image_count', 'image_rhythm_group_constraints', 'normalize_image_rhythm_config', 'normalize_image_rhythm_mode', 'resolve_image_rhythm_intent', 'strip_implicit_image_rhythm_override', 'validate_image_rhythm_manifest']

# --- Module Constants & Globals ---
IMAGE_RHYTHM_MODES = ('single', 'auto', 'fixed', 'detailed', 'balanced', 'chapter', 'template')
IMAGE_RHYTHM_CONFIG_KEYS = frozenset({'image_pacing', 'image_count_mode', 'image_rhythm_target', 'image_rhythm_mode', 'image_target_count', 'image_rhythm_template_id', 'image_rhythm_version'})
IMAGE_RHYTHM_DENSITY_ENVELOPES = {'balanced': {'min_average_hold_s': 60.0, 'max_average_hold_s': 180.0}, 'chapter': {'min_average_hold_s': 180.0, 'max_average_hold_s': 480.0}}
IMAGE_RHYTHM_VERSION = 1
__all__ = ['IMAGE_RHYTHM_MODES', 'IMAGE_RHYTHM_CONFIG_KEYS', 'IMAGE_RHYTHM_DENSITY_ENVELOPES', 'IMAGE_RHYTHM_VERSION', 'ImageRhythmInvariantError', 'apply_image_rhythm_intent', 'build_image_rhythm_manifest', 'e... [truncated]
