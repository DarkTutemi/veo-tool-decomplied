"""
Decompiled / Reconstructed Module: services.automation_center.copilot
Source PyC: copilot.pyc

Docstring:
AI Studio strategy/content-plan engine for Tool 1 Channel Copilot.

This module is intentionally draft-only.  It can reason over a durable project
brief and prior chat messages, but it cannot scrape, browse, create work orders,
or publish.  Readiness for each native workflow is derived locally instead of
being trusted to the model.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['AIStudioChannelCopilot', 'ChannelCopilotDraft', 'COPILOT_PLAN_SCHEMA', 'MAX_CONTENT_ITEMS']

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
AISTUDIO_UNAVAILABLE = 'automation_planner_aistudio_unavailable'
INVALID_REQUEST = 'automation_planner_invalid_request'
MALFORMED_RESPONSE = 'automation_planner_malformed_response'
POLICY_VIOLATION = 'automation_planner_policy_violation'
PROVIDER_FAILED = 'automation_planner_provider_failed'
ProviderFactory = typing.Callable[[], services.automation_center.planner.SynchronousAIProvider]
MAX_PROJECT_BRIEF_CHARS = 20000
MAX_MESSAGE_CHARS = 20000
MAX_ASSISTANT_MESSAGE_CHARS = 4000
MAX_STRATEGY_TEXT_CHARS = 4000
MAX_ITEM_TEXT_CHARS = 12000
MAX_CONTENT_ITEMS = 24
_FEATURE_NAME = 'automation_center_channel_copilot'
_SUPPORTED_PLATFORMS = frozenset({'tiktok', 'youtube', 'facebook', 'instagram'})
_COPILOT_INPUT_MODES = {'master': frozenset({'script', 'idea'}), 'clone': frozenset({'local_video', 'video_url'}), 'transcript': frozenset({'audio_file', 'text', 'audio_url'}), 'affiliate': frozenset({'prepared_product'}), ... [truncated]
_CHANNEL_PLANNING_CONFIG_KEYS = frozenset({'enable_narrator', 'enable_char_consistency', 'image_rhythm_mode', 'variation_count', 'variation_auto', 'auto_merge_video', 'auto_next_job', 'market', 'char_mode', 'aspect_ratio', 'char_con... [truncated]
_URL_RE = re.compile('(?i)(?:\\bhttps?://|\\bwww\\.)', re.IGNORECASE)
_EXECUTION_RE = re.compile('(?i)(?:\\bbrowser\\s*(?:click|type|open|navigate)|\\b(?:powershell|cmd\\.exe|shell)\\b)', re.IGNORECASE)
COPILOT_PLAN_SCHEMA = {'type': 'object', 'additionalProperties': False, 'required': ['assistant_message', 'strategy', 'content_items', 'approval'], 'properties': {'assistant_message': {'type': 'string', 'maxLength': 4000},... [truncated]
_SYSTEM_INSTRUCTION = 'You are Channel Copilot inside the local Tool 1 Automation Center.\nTurn the supplied project brief and conversation into one practical channel strategy and a\ncontent production plan that uses only ... [truncated]
__all__ = ['AIStudioChannelCopilot', 'ChannelCopilotDraft', 'COPILOT_PLAN_SCHEMA', 'MAX_CONTENT_ITEMS']

# --- Class: ChannelCopilotDraft ---
class ChannelCopilotDraft:
    """ChannelCopilotDraft(assistant_message: 'str', strategy: 'dict[str, Any]', content_items: 'tuple[dict[str, Any], ...]', contract_hash: 'str', draft_hash: 'str', source_mode: 'str' = 'brief_only')"""
    source_mode = 'brief_only'

    def to_mapping(self) -> 'dict[str, Any]':
        pass

    def __init__(self, assistant_message: 'str', strategy: 'dict[str, Any]', content_items: 'tuple[dict[str, Any], ...]', contract_hash: 'str', draft_hash: 'str', source_mode: 'str' = 'brief_only') -> None:
        pass

    def __repr__(self):
        pass


# --- Class: AIStudioChannelCopilot ---
class AIStudioChannelCopilot:
    """Create a reviewed, evidence-free channel plan with one AI Studio call."""
    def __init__(self, provider: 'SynchronousAIProvider | None' = None, provider_factory: 'ProviderFactory | None' = None) -> 'None':
        pass

    def plan(self, project_brief: 'str', user_message: 'str', conversation: 'Sequence[Mapping[str, Any]]', allowed_workflows: 'Iterable[str]', current_strategy: 'Mapping[str, Any] | None' = None, available_sources: 'Sequence[Mapping[str, Any]]' = (), channel_context: 'Mapping[str, Any] | None' = None) -> 'ChannelCopilotDraft':
        pass

    def _get_provider(self) -> 'SynchronousAIProvider':
        pass


# --- Top-Level Functions ---
def _build_prompt(brief: 'str', message: 'str', conversation: 'Sequence[Mapping[str, str]]', workflows: 'tuple[str, ...]', current_strategy: 'Mapping[str, Any]', sources: 'Mapping[str, Mapping[str, Any]]', channel_context: 'Mapping[str, Any]', workflow_modes: 'Mapping[str, frozenset[str]]') -> 'str':
    pass

def _normalize_workflows(values: 'Iterable[str]') -> 'tuple[str, ...]':
    pass

def _normalize_conversation(values: 'Sequence[Mapping[str, Any]]') -> 'tuple[dict[str, str], ...]':
    pass

def _normalize_sources(values: 'Sequence[Mapping[str, Any]]', workflows: 'tuple[str, ...]', workflow_modes: 'Mapping[str, frozenset[str]]') -> 'dict[str, dict[str, Any]]':
    pass

def _planning_config_summary(value: 'Any') -> 'dict[str, Any]':
    pass

def _channel_workflow_modes(channel_context: 'Mapping[str, Any]', workflows: 'tuple[str, ...]') -> 'dict[str, frozenset[str]]':
    pass

def _normalize_channel_context(value: 'Mapping[str, Any] | None', workflows: 'tuple[str, ...]') -> 'dict[str, Any]':
    pass

def _prompt_source_row(value: 'Mapping[str, Any]') -> 'dict[str, Any]':
    pass

def _coerce_response(value: 'Any') -> 'Mapping[str, Any]':
    pass

def _validate_draft(raw: 'Mapping[str, Any]', workflows: 'tuple[str, ...]', workflow_modes: 'Mapping[str, frozenset[str]]', brief: 'str', message: 'str', sources: 'Mapping[str, Mapping[str, Any]]') -> 'ChannelCopilotDraft':
    pass

def _validate_strategy(raw: 'Mapping[str, Any]') -> 'dict[str, Any]':
    pass

def _validate_item(raw: 'Any', workflows: 'tuple[str, ...]', workflow_modes: 'Mapping[str, frozenset[str]]', sources: 'Mapping[str, Mapping[str, Any]]') -> 'dict[str, Any]':
    pass

def _reject_execution_text(value: 'str', field: 'str') -> 'None':
    pass

def _closed_keys(value: 'Mapping[str, Any]', expected: 'set[str]', field: 'str') -> 'None':
    pass

def _bounded_text(value: 'Any', field: 'str', limit: 'int', required: 'bool') -> 'str':
    pass

def _policy(field: 'str', message: 'str') -> 'PlannerError':
    pass

def _canonical_hash(value: 'Any') -> 'str':
    pass
