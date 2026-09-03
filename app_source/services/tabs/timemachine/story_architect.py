"""
Decompiled / Reconstructed Module: services.tabs.timemachine.story_architect
Source PyC: story_architect.pyc

Docstring:
Content-first Story Architect for Time Machine.

This stage decides complete narrative coverage before Timeline Director chooses
cameras or visible states.  It never writes image prompts or video recipes.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['STORY_BLUEPRINT_SCHEMA', 'STORY_BLUEPRINT_VERSION', 'TimeMachineStoryArchitectureError', 'build_story_blueprint', 'validate_story_blueprint']

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Callable = typing.Callable
Mapping = typing.Mapping
STORY_BLUEPRINT_VERSION = '1.0'
_IMPORTANCE = ('required', 'supporting', 'optional')
_PRESENTATION = ('visual', 'narration', 'graphics')
_VISUAL_PRIORITY = ('required', 'supporting', 'none')
_CONFIDENCE = ('high', 'medium', 'low')
_KNOWLEDGE = ('established_knowledge', 'reasoned_reconstruction', 'speculative')
_BEAT_TYPES = ('turning_point', 'development_phase', 'daily_life_shift', 'environmental_change')
_CHANGE_DIMENSIONS = ('environment', 'geography', 'settlement', 'transport', 'technology', 'energy', 'science', 'construction', 'infrastructure', 'sanitation', 'communication', 'work', 'migration', 'economy', 'governance'... [truncated]
_EVOLUTION_BEAT_TYPES = {'daily_life_shift', 'environmental_change', 'development_phase'}
_CHAPTER_SCHEMA = {'type': 'object', 'additionalProperties': False, 'properties': {'chapter_id': {'type': 'string', 'minLength': 1}, 'title': {'type': 'string', 'minLength': 1}, 'date_start': {'type': 'string', 'minLen... [truncated]
_BEAT_SCHEMA = {'type': 'object', 'additionalProperties': False, 'properties': {'beat_id': {'type': 'string', 'minLength': 1}, 'chapter_id': {'type': 'string', 'minLength': 1}, 'chronology_index': {'type': 'integer'... [truncated]
_EVOLUTION_THREAD_SCHEMA = {'type': 'object', 'additionalProperties': False, 'properties': {'thread_id': {'type': 'string', 'minLength': 1}, 'title': {'type': 'string', 'minLength': 1}, 'dimension': {'type': 'string', 'enum': [... [truncated]
_COVERAGE_SCHEMA = {'type': 'object', 'additionalProperties': False, 'properties': {'requirement_id': {'type': 'string', 'minLength': 1}, 'source_text': {'type': 'string', 'minLength': 1}, 'covered_by_beat_ids': {'type'... [truncated]
STORY_BLUEPRINT_SCHEMA = {'type': 'object', 'additionalProperties': False, 'properties': {'contract_version': {'type': 'string', 'enum': ['1.0']}, 'content_class': {'type': 'string'}, 'knowledge_strategy': {'type': 'string'},... [truncated]
__all__ = ['STORY_BLUEPRINT_SCHEMA', 'STORY_BLUEPRINT_VERSION', 'TimeMachineStoryArchitectureError', 'build_story_blueprint', 'validate_story_blueprint']

# --- Class: TimeMachineStoryArchitectureError ---
class TimeMachineStoryArchitectureError(RuntimeError):
    def __init__(self, message: 'str', code: 'str' = 'story_architecture_invalid', path: 'str' = '') -> 'None':
        pass


# --- Top-Level Functions ---
def _object(properties: 'dict[str, Any]', required: 'tuple[str, ...]') -> 'dict[str, Any]':
    pass

def _clean(value: 'Any') -> 'str':
    pass

def _list(value: 'Any') -> 'list[str]':
    pass

def _json_mapping(value: 'Any') -> 'dict[str, Any]':
    pass

def _alias(value: 'Any', allowed: 'tuple[str, ...]', aliases: 'Mapping[str, str]') -> 'str':
    pass

def _canonicalize_provider_blueprint(raw: 'Any') -> 'dict[str, Any]':
    """Normalize harmless provider vocabulary drift, never historical meaning."""
    pass

def _integer_equals(value: 'Any', expected: 'int') -> 'bool':
    pass

def _provider_contract_issues(data: 'Mapping[str, Any]', *, directive: 'Mapping[str, Any]', reference_date: 'Any' = None) -> 'list[str]':
    """Collect repairable contract failures so the Critic receives one full brief."""
    pass

def _raise_provider_contract_issues(issues: 'list[str]') -> 'None':
    pass

def _fingerprint(value: 'Mapping[str, Any]') -> 'str':
    pass

def validate_story_blueprint(raw: 'Mapping[str, Any]', *, directive: 'Mapping[str, Any]', reference_date: 'Any' = None) -> 'dict[str, Any]':
    pass

def _bind_budget(blueprint: 'Mapping[str, Any]', *, intent: 'str', directive: 'Mapping[str, Any]', source_context: 'Mapping[str, Any]') -> 'dict[str, Any]':
    pass

def _architect_prompt(*, intent: 'str', directive: 'Mapping[str, Any]', language: 'str', source_context: 'Mapping[str, Any]') -> 'str':
    pass

def _critic_prompt(*, base_prompt: 'str', draft: 'Any', error: 'str') -> 'str':
    pass

def _atomic_json(path: 'Path', value: 'Mapping[str, Any]') -> 'None':
    pass

def build_story_blueprint(*, intent: 'str', directive: 'Mapping[str, Any]', provider: 'Any', language: 'str', source_context: 'Mapping[str, Any] | None' = None, checkpoint_folder: 'str' = '', status_callback: 'Callable[[str, str], None] | None' = None) -> 'dict[str, Any]':
    """Author once, run at most one bounded Critic, and persist accepted output."""
    pass
