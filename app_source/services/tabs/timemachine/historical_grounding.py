"""
Decompiled / Reconstructed Module: services.tabs.timemachine.historical_grounding
Source PyC: historical_grounding.pyc

Docstring:
Timeline-director contracts for factual Time Machine jobs.

Time Machine authors timelines from the selected AI model's existing knowledge.
Deep Research remains an independent Research Labs capability and is deliberately
not imported or invoked from this module.  Local code validates chronology,
causality metadata and chunk boundaries; it never fabricates citations.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['FACT_EVENTS_PER_CHAPTER', 'GROUNDING_DIRECTIVE_SCHEMA', 'MAX_TIMELINE_CHAPTERS', 'TIMELINE_CHAPTER_SCHEMA', 'TIMELINE_DIRECTOR_SCHEMA', 'TIMELINE_EDGE_SCHEMA', 'MILESTONE_OUTLINE_SCHEMA', 'MILESTONES_PER_CHAPTER', 'TIMELINE_OUTLINE_SCHEMA', 'TIMELINE_STATES_PER_CHAPTER', 'TimeMachineGroundingError', 'expand_milestone_outline', 'classify_grounding_requirement', 'parse_reference_date', 'timeline_date_bounds', 'anchor_timeline_context', 'build_timeline_edge_contracts', 'planner_grounding_context', 'run_fact_grounding', 'run_timeline_direction', 'validate_grounding_directive', 'validate_plan_evidence_bindings', 'validate_plan_timeline_bindings', 'validate_timeline_chapter_output', 'validate_timeline_director_output', 'validate_timeline_edge_contracts', 'validate_milestone_outline', 'validate_timeline_outline']

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Callable = typing.Callable
Dict = typing.Dict
Mapping = typing.Mapping
Optional = typing.Optional
Sequence = typing.Sequence
GROUNDING_CLASSES = {'speculative', 'fact_grounded', 'creative_process'}
TRUTH_POLICIES = {'historical_strict', 'speculative_labeled', 'process_grounded', 'knowledge_guided'}
KNOWLEDGE_STRATEGIES = {'speculative_reasoning', 'model_knowledge', 'creative_reasoning'}
VISUAL_STATUSES = {'historically_grounded_reconstruction', 'documented', 'inferred', 'unknown'}
CONFIDENCE_LEVELS = {'medium', 'low', 'high'}
KNOWLEDGE_BASES = {'reasoned_reconstruction', 'speculative', 'established_knowledge'}
TRANSITION_MODES = {'era_jump', 'compressed_process', 'discrete_milestone', 'continuous_process'}
OVERLAY_MODES = {'none', 'date', 'era', 'relative_time', 'date_range'}
TIMELINE_STATES_PER_CHAPTER = 24
MILESTONES_PER_CHAPTER = 8
MAX_TIMELINE_CHAPTERS = 64
MAX_COVERAGE_PAGES = 64
MAX_LEDGER_EVENTS_PER_INTERVAL = 1
FACT_EVENTS_PER_CHAPTER = 24
DEFAULT_CLIP_DURATION_S = 8.0
DEFAULT_ENDPOINT_HOLD_S = 1.0
CANONICAL_VIEWPORT_PREFIX = 'CANONICAL_VIEWPORT:'
_COVERAGE_REQUIREMENT_SCHEMA = {'type': 'object', 'additionalProperties': False, 'properties': {'requirement_id': {'type': 'string', 'minLength': 1}, 'snapshot_date': {'type': 'string', 'minLength': 1}, 'title': {'type': 'string', ... [truncated]
GROUNDING_DIRECTIVE_SCHEMA = {'type': 'object', 'additionalProperties': False, 'properties': {'contract_version': {'type': 'string', 'enum': ['2.0']}, 'content_class': {'type': 'string', 'enum': ['creative_process', 'fact_grounde... [truncated]
_EDIT_INSTRUCTION_SCHEMA = {'type': 'object', 'additionalProperties': False, 'properties': {'time_label': {'type': 'string'}, 'chapter_label': {'type': 'string'}, 'overlay_mode': {'type': 'string', 'enum': ['date', 'date_range'... [truncated]
_TIMELINE_EVENT_SCHEMA = {'type': 'object', 'additionalProperties': False, 'properties': {'event_id': {'type': 'string', 'minLength': 1}, 'requirement_ids': {'type': 'array', 'items': {'type': 'string', 'minLength': 1}}, 'cha... [truncated]
_VIEWPORT_MAPPING_SCHEMA = {'type': 'object', 'additionalProperties': False, 'properties': {'viewport_mode': {'type': 'string', 'enum': ['fixed_camera']}, 'from_visible_state': {'type': 'array', 'minItems': 1, 'items': {'type':... [truncated]
TIMELINE_EDGE_SCHEMA = {'type': 'object', 'additionalProperties': False, 'properties': {'from_event_id': {'type': 'string', 'minLength': 1}, 'to_event_id': {'type': 'string', 'minLength': 1}, 'from_date': {'type': 'string',... [truncated]
TIMELINE_DIRECTOR_SCHEMA = {'type': 'object', 'additionalProperties': False, 'properties': {'contract_version': {'type': 'string', 'enum': ['2.0']}, 'topic': {'type': 'string', 'minLength': 1}, 'timeline_summary': {'type': 'str... [truncated]
_TIMELINE_OUTLINE_CHAPTER_SCHEMA = {'type': 'object', 'additionalProperties': False, 'properties': {'chapter_id': {'type': 'string', 'minLength': 1}, 'chapter_title': {'type': 'string', 'minLength': 1}, 'date_start': {'type': 'string',... [truncated]
TIMELINE_OUTLINE_SCHEMA = {'type': 'object', 'additionalProperties': False, 'properties': {'contract_version': {'type': 'string', 'enum': ['2.0']}, 'topic': {'type': 'string', 'minLength': 1}, 'timeline_summary': {'type': 'str... [truncated]
TIMELINE_CHAPTER_SCHEMA = {'type': 'object', 'additionalProperties': False, 'properties': {'contract_version': {'type': 'string', 'enum': ['2.0']}, 'chapter_id': {'type': 'string', 'minLength': 1}, 'chapter_title': {'type': 's... [truncated]
_SLIM_MILESTONE_SCHEMA = {'type': 'object', 'additionalProperties': False, 'properties': {'event_id': {'type': 'string', 'minLength': 1}, 'beat_ids': {'type': 'array', 'minItems': 1, 'items': {'type': 'string', 'minLength': 1... [truncated]
_MILESTONE_OUTLINE_CHAPTER_SCHEMA = {'type': 'object', 'additionalProperties': False, 'properties': {'chapter_id': {'type': 'string', 'minLength': 1}, 'chapter_title': {'type': 'string', 'minLength': 1}, 'date_start': {'type': 'string',... [truncated]
_DIRECTOR_PLAN_SCHEMA = {'type': 'object', 'additionalProperties': False, 'properties': {'camera_mode': {'type': 'string', 'enum': ['single_locked', 'multi_view']}, 'invariant': {'type': 'string'}, 'primary_viewport': {'type... [truncated]
MILESTONE_OUTLINE_SCHEMA = {'type': 'object', 'additionalProperties': False, 'properties': {'contract_version': {'type': 'string', 'enum': ['2.0']}, 'topic': {'type': 'string', 'minLength': 1}, 'timeline_summary': {'type': 'str... [truncated]
_HISTORY_HINTS = re.compile('(?:history|historical|evolution|timeline|centur|millen|years?|bce|bc|ce|ad|lịch\\s*sử|tiến\\s*h[oó]a|phát\\s*triển|qua\\s*\\d+\\s*năm|thời\\s*(?:đại|kỳ)|\\d[\\d.,\\s]*\\s*năm\\s*(?:trước|q... [truncated]
_SPECULATIVE_HINTS = re.compile('(?:future|forecast|prediction|predict|alternate\\s+history|counterfactual|tương\\s*lai|dự\\s*(?:báo|đoán)|giả\\s*(?:định|sử)|nếu\\s+như)', re.IGNORECASE)
_TRUTH_POLICY_ALIASES = {'historical': 'knowledge_guided', 'factual': 'knowledge_guided', 'fact_grounded': 'knowledge_guided', 'historical_strict': 'knowledge_guided', 'process': 'process_grounded', 'creative': 'process_grou... [truncated]
_PRESENT_DATE_LABELS = {'hiện nay', 'now', 'today', 'đến nay', 'current date', 'present', 'nay', 'current', 'hiện tại', 'đến hiện tại'}
_BCE_MARKER_RE = re.compile('(?:\\bbc(?:e)?\\b|\\btcn\\b|trước\\s+công\\s+nguyên)', re.IGNORECASE)
_CE_MARKER_RE = re.compile('(?:\\bce\\b|\\bad\\b|\\bscn\\b|sau\\s+công\\s+nguyên)', re.IGNORECASE)
_YEARS_AGO_RE = re.compile('(?<!\\d)(\\d[\\d,.\\s]*)(?:\\s*)(?:years?\\s+ago|năm\\s+trước)(?!\\w)', re.IGNORECASE)
_BEFORE_PRESENT_RE = re.compile('(?<!\\d)(\\d[\\d,.\\s]*)(?:\\s*)(?:bp|before\\s+present)(?!\\w)', re.IGNORECASE)
_ISO_DATE_RE = re.compile('^([+-]?\\d{1,6})-(\\d{1,2})-(\\d{1,2})$')
_ISO_MONTH_RE = re.compile('^([+-]?\\d{1,6})-(\\d{1,2})$')
_YEAR_TOKEN_RE = re.compile('(?<!\\d)(\\d{1,7})(?!\\d)')
_DATE_RANGE_JOINER_RE = re.compile('\\s+(?:to|through|until|[-\\u2013\\u2014]|->|\\u2192)\\s+', re.IGNORECASE)
_REFERENCE_DATE = <ContextVar name='timemachine_reference_date' default=None at 0x00000264E67C79C0>
__all__ = ['FACT_EVENTS_PER_CHAPTER', 'GROUNDING_DIRECTIVE_SCHEMA', 'MAX_TIMELINE_CHAPTERS', 'TIMELINE_CHAPTER_SCHEMA', 'TIMELINE_DIRECTOR_SCHEMA', 'TIMELINE_EDGE_SCHEMA', 'MILESTONE_OUTLINE_SCHEMA', 'MILESTONE... [truncated]

# --- Class: TimeMachineGroundingError ---
class TimeMachineGroundingError(RuntimeError):
    """A Time Machine timeline is structurally unsafe for production."""
    def __init__(self, message: 'str', code: 'str' = '', path: 'str' = '', chapter_id: 'str' = '') -> 'None':
        pass


# --- Top-Level Functions ---
def _normalize_knowledge_basis(raw: 'Any') -> 'str':
    pass

def _historical_interval_mode(context: 'Mapping[str, Any] | None') -> 'bool':
    pass

def _viewport_lines(world_bible: 'Sequence[Any]') -> 'list[str]':
    pass

def _canonical_viewport_fact(world_bible: 'Sequence[Any]') -> 'str':
    pass

def _normalize_director_plan(raw: 'Any', *, default_viewport: 'str', chapters: 'Sequence[Mapping[str, Any]]') -> 'Dict[str, str]':
    pass

def _normalize_viewport_id(raw: 'Any', *, fallback: 'str') -> 'str':
    pass

def _require_keys(raw: 'Mapping[str, Any]', required: 'Sequence[str]', path: 'str') -> 'None':
    pass

def _object(properties: 'Dict[str, Any]', required: 'Sequence[str]') -> 'Dict[str, Any]':
    pass

def _has_explicit_future_year(value: 'str') -> 'bool':
    pass

def _clean_list(value: 'Any') -> 'list[str]':
    pass

def parse_reference_date(value: 'Any') -> 'date':
    pass

def _active_reference_date() -> 'date':
    pass

def _compact_date_label(value: 'Any') -> 'str':
    pass

def _number_token(value: 'str') -> 'Optional[int]':
    pass

def _normalize_fact_date_label(value: 'Any', current_date: 'Optional[date]' = None) -> 'tuple[str, Optional[tuple[int, int, int]], Optional[tuple[int, int, int]], bool]':
    """Return a stable label, inclusive date bounds and future-clamp status.

    Imprecise labels are intervals rather than fake exact dates: ``1923`` spans
    the whole year and ``1923-12`` spans the whole month.  Chronology validation
    can therefore reject only definitely backwards ranges without treating a
    valid day-to-month handoff as ``(month, 0, 0)``. Unknown dynasty/era prose is
    not guessed into a year. Recognized factual dates use an astronomical-style
    axis where BCE years are negative."""
    pass

def timeline_date_bounds(value: 'Any', reference_date: 'Any' = None) -> 'tuple[str, Optional[tuple[int, int, int]], Optional[tuple[int, int, int]], bool]':
    pass

def _validate_chronology_window(*, path: 'str', date_start: 'str', date_end: 'str') -> 'tuple[str, str, bool]':
    pass

def _validate_snapshot_date(*, path: 'str', snapshot_date: 'Any', date_start: 'str', date_end: 'str') -> 'tuple[str, tuple[int, int, int], bool]':
    pass

def _event_snapshot_date(event: 'Mapping[str, Any]') -> 'str':
    pass

def _event_visible_state(event: 'Mapping[str, Any]') -> 'list[str]':
    pass

def _viewport_mapping(from_event: 'Mapping[str, Any]', to_event: 'Mapping[str, Any]') -> 'Dict[str, Any]':
    pass

def build_timeline_edge_contracts(events: 'Sequence[Mapping[str, Any]]', screen_duration_s: 'float' = 8.0) -> 'list[Dict[str, Any]]':
    pass

def validate_timeline_edge_contracts(raw_edges: 'Any', events: 'Sequence[Mapping[str, Any]]') -> 'list[Dict[str, Any]]':
    pass

def _is_transient_provider_failure(exc: 'BaseException') -> 'bool':
    pass

def _normalize_classifier_output(raw: 'Any') -> 'Any':
    pass

def validate_grounding_directive(raw: 'Any') -> 'Dict[str, Any]':
    pass

def _coverage_continuation_prompt(*, intent: 'str', accepted: 'Mapping[str, Any]', source_context: 'Mapping[str, Any]') -> 'str':
    pass

def _coverage_full_audit_prompt(*, intent: 'str', accepted: 'Mapping[str, Any]', source_context: 'Mapping[str, Any]') -> 'str':
    pass

def classify_grounding_requirement(intent: 'str', *, provider: 'Any', source_context: 'Optional[Mapping[str, Any]]' = None) -> 'Dict[str, Any]':
    pass

def _normalize_edit_instruction(value: 'Any') -> 'Dict[str, Any]':
    pass

def validate_timeline_director_output(raw: 'Any') -> 'Dict[str, Any]':
    """Validate chronology and uncertainty without pretending to verify sources."""
    pass

def validate_timeline_outline(raw: 'Any') -> 'Dict[str, Any]':
    """Validate the bounded macro plan before any detailed chapter is authored."""
    pass

def validate_milestone_outline(raw: 'Any') -> 'Dict[str, Any]':
    """Validate the slim WHEN/WHAT outline. Camera and pixels are not here."""
    pass

def expand_milestone_outline(outline: 'Mapping[str, Any]') -> 'Dict[str, Any]':
    pass

def validate_timeline_chapter_output(raw: 'Any', *, outline_chapter: 'Mapping[str, Any]', world_bible: 'Sequence[Any]', previous_terminal_event: 'Optional[Mapping[str, Any]]' = None) -> 'Dict[str, Any]':
    pass

def _milestone_outline_prompt(intent: 'str', directive: 'Mapping[str, Any]', language: 'str', source_context: 'Mapping[str, Any]') -> 'str':
    pass

def _milestone_outline_critic_prompt(intent: 'str', directive: 'Mapping[str, Any]', language: 'str', source_context: 'Mapping[str, Any]', draft: 'Any', director_error: 'str') -> 'str':
    pass

def _outline_director_prompt(intent: 'str', directive: 'Mapping[str, Any]', language: 'str', source_context: 'Mapping[str, Any]') -> 'str':
    pass

def _outline_critic_prompt(intent: 'str', directive: 'Mapping[str, Any]', language: 'str', source_context: 'Mapping[str, Any]', draft: 'Any', director_error: 'str') -> 'str':
    pass

def _chapter_director_prompt(*, intent: 'str', directive: 'Mapping[str, Any]', language: 'str', source_context: 'Mapping[str, Any]', outline: 'Mapping[str, Any]', chapter_index: 'int', previous_terminal_event: 'Optional[Mapping[str, Any]]') -> 'str':
    pass

def _chapter_critic_prompt(*, intent: 'str', directive: 'Mapping[str, Any]', language: 'str', outline: 'Mapping[str, Any]', chapter_index: 'int', previous_terminal_event: 'Optional[Mapping[str, Any]]', draft: 'Any', director_error: 'str') -> 'str':
    pass

def _persist_timeline_outline(folder: 'str', outline: 'Mapping[str, Any]') -> 'None':
    pass

def _persist_timeline_chapter(folder: 'str', chapter_index: 'int', chapter: 'Mapping[str, Any]', accepted_count: 'int') -> 'None':
    pass

def _persist_timeline_failure(folder: 'str', error: 'BaseException', chapter_index: 'int' = -1, chapter_id: 'str' = '', raw: 'Any' = None) -> 'None':
    pass

def run_timeline_direction(*, intent: 'str', directive: 'Mapping[str, Any]', provider: 'Any', language: 'str', source_context: 'Optional[Mapping[str, Any]]' = None, status_callback: 'Optional[Callable[[str, str], None]]' = None, audit_mode: 'str' = 'repair_only', checkpoint_folder: 'str' = '') -> 'Dict[str, Any]':
    pass

def _finalize_milestone_timeline(*, intent: 'str', clean_directive: 'Mapping[str, Any]', slim_outline: 'Mapping[str, Any]', director_call_count: 'int', critic_call_count: 'int', critic_status: 'str', status_callback: 'Optional[Callable[[str, str], None]]') -> 'Dict[str, Any]':
    pass

def _try_milestone_outline(raw: 'Any') -> 'Optional[Dict[str, Any]]':
    pass

def _try_legacy_outline(raw: 'Any') -> 'Optional[Dict[str, Any]]':
    pass

def _required_event_coverage_failure(outline: 'Mapping[str, Any]', directive: 'Mapping[str, Any]', *, interval_mode: 'bool' = False) -> 'Optional[BaseException]':
    pass

def _complete_interval_ledger_outline(outline: 'Mapping[str, Any]', directive: 'Mapping[str, Any]') -> 'Dict[str, Any]':
    pass

def _story_coverage_failure(outline: 'Mapping[str, Any]', context: 'Mapping[str, Any]', directive: 'Optional[Mapping[str, Any]]' = None) -> 'Optional[BaseException]':
    pass

def _raise_story_coverage_failure(failure: 'BaseException', folder: 'str', raw: 'Any' = None) -> 'None':
    pass

def _merge_milestone_outline_pages(pages: 'Sequence[Mapping[str, Any]]') -> 'Dict[str, Any]':
    pass

def _visual_story_continuation_prompt(*, intent: 'str', directive: 'Mapping[str, Any]', language: 'str', source_context: 'Mapping[str, Any]', accepted_pages: 'Sequence[Mapping[str, Any]]', cursor: 'str', repair_error: 'str' = '', broken_draft: 'Any' = None) -> 'str':
    pass

def _complete_visual_story_pages(*, first_page: 'Mapping[str, Any]', intent: 'str', directive: 'Mapping[str, Any]', language: 'str', source_context: 'Mapping[str, Any]', provider: 'Any', status_callback: 'Optional[Callable[[str, str], None]]') -> 'tuple[Dict[str, Any], int]':
    pass

def _author_factual_timeline(intent: 'str', clean_directive: 'Mapping[str, Any]', provider: 'Any', language: 'str', context: 'Mapping[str, Any]', status_callback: 'Optional[Callable[[str, str], None]]', clean_audit_mode: 'str', folder: 'str') -> 'Dict[str, Any]':
    pass

def run_fact_grounding(*, intent: 'str', directive: 'Mapping[str, Any]', provider: 'Any', language: 'str', account_name: 'str' = '', status_callback: 'Optional[Callable[[str, str], None]]' = None) -> 'Dict[str, Any]':
    pass

def planner_grounding_context(grounding: 'Mapping[str, Any]') -> 'Dict[str, Any]':
    """Return the compact timeline packet consumed by independent AI calls."""
    pass

def anchor_timeline_context(grounding_context: 'Mapping[str, Any]') -> 'Dict[str, Any]':
    pass

def validate_plan_evidence_bindings(plan: 'Mapping[str, Any]', grounding_context: 'Mapping[str, Any]') -> 'Dict[str, Any]':
    """Fail closed when a directed factual plan loses chronology bindings."""
    pass

def validate_plan_timeline_bindings(plan: 'Mapping[str, Any]', grounding_context: 'Mapping[str, Any]') -> 'Dict[str, Any]':
    pass
