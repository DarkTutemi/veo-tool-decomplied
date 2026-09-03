"""
Decompiled / Reconstructed Module: services.tabs.timemachine.temporal_budget
Source PyC: temporal_budget.pyc

Docstring:
Pure duration and credit estimates for a Time Machine state graph.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['DEFAULT_CLIP_DURATION_S', 'estimate_plan_budget', 'estimate_temporal_budget', 'recommended_state_count']

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Mapping = typing.Mapping
Sequence = typing.Sequence
DEFAULT_CLIP_DURATION_S = 8.0
__all__ = ['DEFAULT_CLIP_DURATION_S', 'estimate_plan_budget', 'estimate_temporal_budget', 'recommended_state_count']

# --- Top-Level Functions ---
def recommended_state_count(target_duration_s: 'float', *, clip_duration_s: 'float' = 8.0, include_final_reveal: 'bool' = True, minimum_states: 'int' = 2) -> 'int':
    pass

def estimate_temporal_budget(*, transition_durations_s: 'Sequence[float]', credit_per_clip: 'int' = 0, include_final_reveal: 'bool' = True, final_reveal_duration_s: 'float' = 8.0, target_duration_s: 'float' = 0.0, temporal_scale_mode: 'str' = 'event_driven') -> 'dict[str, Any]':
    pass

def estimate_plan_budget(plan: 'Mapping[str, Any]', *, credit_per_clip: 'int' = 0, include_final_reveal: 'bool' = True, target_duration_s: 'float' = 0.0) -> 'dict[str, Any]':
    pass
