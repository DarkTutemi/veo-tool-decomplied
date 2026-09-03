"""
Decompiled / Reconstructed Module: services.tabs.timemachine.temporal_contract
Source PyC: temporal_contract.pyc

Docstring:
Topic-agnostic temporal contracts for Time Machine.

The old Time Machine contract equated every story with reverse decomposition.
This module separates *what changes over time* from *how missing keyframes are
materialized*.  The planner/renderer may therefore keep one stable world while
showing assembly, growth, decay, replacement, operation, or epoch-scale change.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['ANCHOR_ROLES', 'CHANGE_PRIMITIVES', 'CONTINUITIES', 'GENERATION_STRATEGIES', 'TEMPORAL_BRIEF_SCHEMA', 'TEMPORAL_MODES', 'TEMPORAL_PROFILE_SCHEMA', 'TIME_SCALES', 'TRANSITION_REGIMES', 'TemporalContractError', 'build_temporal_edges', 'classify_temporal_intent', 'generation_strategy_for_chapter', 'knowledge_guided_temporal_brief', 'legacy_temporal_brief', 'legacy_temporal_profile', 'resolve_idea_only_temporal_brief', 'stamp_llm_temporal_brief_contract', 'temporal_edge_key', 'upgrade_plan_temporal_contract', 'validate_temporal_brief', 'validate_temporal_profile']

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
Mapping = typing.Mapping
Optional = typing.Optional
Sequence = typing.Sequence
TEMPORAL_MODES = {'lifecycle', 'construction', 'restoration', 'hybrid', 'assembly', 'fabrication', 'natural_evolution', 'epoch_evolution', 'operation', 'technology_evolution', 'reorganization', 'deconstruction', 'grow... [truncated]
GENERATION_STRATEGIES = {'reverse_regression', 'forward_progression', 'bidirectional_bridge', 'milestone_synthesis'}
TIME_SCALES = {'days', 'seconds', 'years', 'millennia', 'decades', 'centuries', 'mixed', 'minutes', 'months', 'hours'}
CONTINUITIES = {'discrete_milestones', 'hybrid', 'compressed_continuous', 'continuous_physical'}
TRANSITION_REGIMES = {'environment_transition', 'replacement', 'physical_process', 'compressed_process', 'final_reveal', 'epoch_transition', 'cut', 'growth', 'decay'}
CHANGE_PRIMITIVES = {'DECAY', 'ERA_TRANSITION', 'ENVIRONMENT_SHIFT', 'DISASSEMBLE', 'REPLACE', 'REORGANIZE', 'OPERATE', 'ADD', 'ASSEMBLE', 'RESTORE', 'GROW', 'MOVE', 'MODIFY', 'REMOVE'}
TEMPORAL_DIRECTIONS = {'forward', 'bidirectional', 'reverse'}
ANCHOR_ROLES = {'final_state', 'world_reference', 'initial_state', 'provided_state'}
_WORLD_ANCHOR_SCHEMA = {'type': 'object', 'additionalProperties': False, 'properties': {'subject_identity': {'type': 'string', 'minLength': 1}, 'permanent_facts': {'type': 'array', 'minItems': 1, 'items': {'type': 'string',... [truncated]
TEMPORAL_BRIEF_SCHEMA = {'type': 'object', 'additionalProperties': False, 'properties': {'contract_version': {'type': 'string', 'enum': ['2.0']}, 'temporal_mode': {'type': 'string', 'enum': ['assembly', 'construction', 'deca... [truncated]
_TRANSITION_SCHEMA = {'type': 'object', 'additionalProperties': False, 'properties': {'from_stage': {'type': 'integer', 'minimum': 0}, 'to_stage': {'type': 'integer', 'minimum': 1}, 'regime': {'type': 'string', 'enum': ['... [truncated]
_DIRECTOR_TRANSITION_BINDING_FIELDS = {'to_date', 'to_event_id', 'middle_budget_s', 'from_event_id', 'mapping', 'transition_mode', 'screen_duration_s', 'from_date'}
TEMPORAL_PROFILE_SCHEMA = {'type': 'object', 'additionalProperties': False, 'properties': {'temporal_mode': {'type': 'string', 'enum': ['assembly', 'construction', 'decay', 'deconstruction', 'epoch_evolution', 'fabrication', '... [truncated]
__all__ = ['ANCHOR_ROLES', 'CHANGE_PRIMITIVES', 'CONTINUITIES', 'GENERATION_STRATEGIES', 'TEMPORAL_BRIEF_SCHEMA', 'TEMPORAL_MODES', 'TEMPORAL_PROFILE_SCHEMA', 'TIME_SCALES', 'TRANSITION_REGIMES', 'TemporalContr... [truncated]

# --- Class: TemporalContractError ---
class TemporalContractError(ValueError):
    """A planner result violates the generic Time Machine time contract."""
    pass


# --- Top-Level Functions ---
def _object(properties: 'Dict[str, Any]', required: 'Sequence[str]') -> 'Dict[str, Any]':
    pass

def _text(value: 'Any', path: 'str') -> 'str':
    pass

def _enum(value: 'Any', allowed: 'set[str]', path: 'str') -> 'str':
    pass

def _string_list(value: 'Any', path: 'str', allowed: 'Optional[set[str]]' = None) -> 'list[str]':
    pass

def _exact(data: 'Mapping[str, Any]', expected: 'set[str]', path: 'str') -> 'None':
    pass

def validate_temporal_brief(raw: 'Any') -> 'Dict[str, Any]':
    pass

def stamp_llm_temporal_brief_contract(raw: 'Any') -> 'Dict[str, Any]':
    pass

def knowledge_guided_temporal_brief(*, intent: 'str', grounding_context: 'Mapping[str, Any]') -> 'Dict[str, Any]':
    """Project a locked factual timeline into the generic temporal contract.

    Timeline Director already owns classification, chronology and transition
    modes for knowledge-guided work.  Asking a second LLM to classify the same
    idea can contradict that locked result and is unnecessary.  This projection
    is deterministic and keeps the exact same v2 contract consumed by anchor,
    planner and renderer stages."""
    pass

def validate_temporal_profile(raw: 'Any', *, stage_count: 'int') -> 'Dict[str, Any]':
    pass

def legacy_temporal_brief(direction: 'str') -> 'Dict[str, Any]':
    pass

def legacy_temporal_profile(*, ladder: 'Sequence[Mapping[str, Any]]', brief: 'Mapping[str, Any]') -> 'Dict[str, Any]':
    pass

def temporal_edge_key(view_id: 'Any', from_stage: 'Any', to_stage: 'Any') -> 'str':
    pass

def build_temporal_edges(chapters: 'Sequence[Mapping[str, Any]]') -> 'Dict[str, Dict[str, Any]]':
    pass

def generation_strategy_for_chapter(plan: 'Mapping[str, Any]', view_id: 'str') -> 'str':
    pass

def _upgrade_fact_snapshot_contract(plan: 'Dict[str, Any]') -> 'Dict[str, Any]':
    """Repair stored factual plans that encoded one still as a date range.

    Timeline Director v2.0 originally kept only ``date_start/date_end``.  Old
    persisted ladders consequently said e.g. ``100000 BP to 70000 BP`` even
    though a generated keyframe can represent only one instant.  Resume runs
    pass through this projection before any prompt writer sees the ladder."""
    pass

def upgrade_plan_temporal_contract(plan: 'Mapping[str, Any]') -> 'Dict[str, Any]':
    pass

def classify_temporal_intent(*, intent: 'str', provider: 'Any', has_reference_images: 'bool', source_context: 'Optional[Mapping[str, Any]]' = None) -> 'Dict[str, Any]':
    pass

def resolve_idea_only_temporal_brief(*, intent: 'str', provider: 'Any', grounding_context: 'Mapping[str, Any]', source_context: 'Optional[Mapping[str, Any]]' = None) -> 'Dict[str, Any]':
    pass
