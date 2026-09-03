"""
Decompiled / Reconstructed Module: services.tabs.timemachine.runtime_pipeline
Source PyC: runtime_pipeline.pyc

Docstring:
Runtime phase projection and causal guards for Time Machine.

The planner owns semantic order inside the story.  This module owns the much
smaller execution DAG used by the desktop runtime: expensive work may fan out
only after every immutable input it consumes has been locked.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['CHECKPOINT_DEPENDENCIES', 'CHECKPOINT_LABELS', 'PIPELINE_STEPS', 'TimeMachineCausalityError', 'causal_projection', 'mark_checkpoint', 'new_causal_state', 'phase_projection', 'require_checkpoint', 'rewind_causal_state', 'validate_i2v_parallel_batch']

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Mapping = typing.Mapping
MutableMapping = typing.MutableMapping
Sequence = typing.Sequence
PIPELINE_STEPS = ({'key': 'intake', 'label': 'Timeline'}, {'key': 'plan', 'label': 'Storyboard'}, {'key': 'keyframes', 'label': 'Seed START–END'}, {'key': 'render', 'label': 'Live Chain'}, {'key': 'picture_lock', 'lab... [truncated]
_PHASE_STEP = {'draft': 0, 'queued': 0, 'analyzing': 0, 'session_ready': 0, 'asset_owner': 0, 'source_media': 0, 'source_media_ready': 0, 'input_ready': 0, 'vision_ready': 0, 'anchor_prompt': 0, 'anchor_generation'... [truncated]
_PHASE_LABEL = {'draft': 'BẢN PHÁC THẢO', 'queued': 'ĐANG CHỜ AUTOPILOT', 'analyzing': 'LLM ĐANG NHẬN DIỆN ĐẦU VÀO', 'session_ready': 'ĐÃ TẠO VÙNG LÀM VIỆC TẠM', 'asset_owner': 'ĐANG KHÓA TÀI KHOẢN TÀI NGUYÊN', 'sou... [truncated]
CHECKPOINT_DEPENDENCIES = {'input_locked': (), 'plan_locked': ('input_locked',), 'keyframes_locked': ('plan_locked',), 'motion_locked': ('keyframes_locked',), 'render_submitted': ('motion_locked',), 'render_locked': ('render_s... [truncated]
CHECKPOINT_LABELS = {'input_locked': 'Đầu vào', 'plan_locked': 'Kế hoạch', 'keyframes_locked': 'Keyframe', 'motion_locked': 'Motion', 'render_submitted': 'I2V đã phân phối', 'render_locked': 'I2V hoàn tất', 'picture_lock... [truncated]
__all__ = ['CHECKPOINT_DEPENDENCIES', 'CHECKPOINT_LABELS', 'PIPELINE_STEPS', 'TimeMachineCausalityError', 'causal_projection', 'mark_checkpoint', 'new_causal_state', 'phase_projection', 'require_checkpoint', 'r... [truncated]

# --- Class: TimeMachineCausalityError ---
class TimeMachineCausalityError(RuntimeError):
    """Raised when runtime work attempts to cross an unmet dependency."""
    pass


# --- Top-Level Functions ---
def phase_projection(phase: 'str', progress: 'int' = 0) -> 'dict[str, Any]':
    pass

def new_causal_state(job_id: 'str' = '', input_mode: 'str' = 'visual') -> 'dict[str, Any]':
    pass

def _normalized_state(state: 'Mapping[str, Any] | None') -> 'dict[str, Any]':
    pass

def require_checkpoint(state: 'Mapping[str, Any] | None', checkpoint: 'str') -> 'None':
    pass

def mark_checkpoint(state: 'MutableMapping[str, Any] | Mapping[str, Any] | None', checkpoint: 'str', details: 'Mapping[str, Any] | None' = None) -> 'dict[str, Any]':
    pass

def causal_projection(state: 'Mapping[str, Any] | None') -> 'dict[str, Any]':
    pass

def rewind_causal_state(state: 'Mapping[str, Any] | None', keep_through: 'str') -> 'dict[str, Any]':
    pass

def validate_i2v_parallel_batch(jobs: 'Sequence[Mapping[str, Any]]') -> 'dict[str, Any]':
    pass
