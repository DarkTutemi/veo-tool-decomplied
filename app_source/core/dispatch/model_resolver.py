"""
Decompiled / Reconstructed Module: core.dispatch.model_resolver
Source PyC: model_resolver.pyc

Docstring:
core/dispatch/model_resolver.py — Centralised model-resolution logic.

Replaces the following methods in managers/smart_job_dispatcher.py:
  - _extract_speed_from_model   → ModelResolver.extract_speed
  - _duration_from_prompt_data  → ModelResolver.duration_from_prompt
  - _get_r2v_model_for_aspect_ratio → ModelResolver.resolve_r2v
  - _get_t2v_model_for_aspect_ratio → ModelResolver.resolve_t2v
  - _get_upscale_aspect_ratio   → ModelResolver.resolve_upscale_aspect
  - _late_bind_model            → ModelResolver.late_bind
  - ModelGuard block (line ~8022)→ ModelResolver.guard_t2v_model

This class is PURE: no state, no DB, no worker references.
All methods are @staticmethod-compatible; the class is stateless.
Implements the IModelResolver Protocol from core.dispatch.contracts.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
_LOGGED_ONCE = set()

# --- Class: ModelResolver ---
class ModelResolver:
    """Stateless helper that centralises every model-key decision.

    Implements ``IModelResolver`` (core.dispatch.contracts).
    All methods delegate to ``ModelConfig`` for the authoritative
    model catalogue; this class adds the routing/guard logic only."""
    @staticmethod
    def extract_speed(model_key: 'str') -> 'str':
        pass

    @staticmethod
    def duration_from_prompt(prompt_data: 'dict', base_model: 'str' = '') -> 'int | None':
        pass

    @staticmethod
    def resolve_t2v(aspect: 'str', tier: 'str' = 'PAYGATE_TIER_TWO', speed: 'str' = 'ultra') -> 'str':
        pass

    @staticmethod
    def resolve_r2v(aspect: 'str', tier: 'str' = 'PAYGATE_TIER_TWO', speed: 'str' = 'ultra', duration_seconds: 'float | None' = None, source_model_key: 'str' = '') -> 'str':
        pass

    @staticmethod
    def family_available_durations(model_key: 'str', tier: 'str' = 'ultra', model_type: 'str' = '') -> 'list':
        pass

    @staticmethod
    def align_model_duration(model_key: 'str', target_duration: "'int | float | None'", aspect: 'str' = '16:9', tier: 'str' = 'ultra') -> 'str':
        pass

    @staticmethod
    def resolve_upscale_aspect(aspect_ratio_str: 'str | None') -> 'str':
        pass

    @staticmethod
    def late_bind(model_key: 'str', prompt_data: 'dict', user_tier: 'str') -> 'str':
        pass

    @staticmethod
    def guard_t2v_model(model_key: 'str', aspect: 'str', tier: 'str', has_ref_assets: 'bool', job_type: 'str') -> 'str':
        pass


# --- Top-Level Functions ---
def _log_once(key: 'str', message: 'str') -> 'None':
    pass
