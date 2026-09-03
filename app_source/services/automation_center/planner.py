"""
Decompiled / Reconstructed Module: services.automation_center.planner
Source PyC: planner.pyc

Docstring:
Stateless AI Studio planner for Tool 1 Automation Center.

The planner is deliberately a draft-only boundary.  It asks Tool 1's existing
AI Studio direct provider for a small, closed JSON document, validates that
document against local policy, and returns an immutable value object.  It does
not import the Automation Center service/store, create work orders, control a
browser, or publish anything.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['AISTUDIO_UNAVAILABLE', 'AUTOMATION_PLAN_SCHEMA', 'AutomationPlan', 'AutomationPlanMapping', 'AutomationPlanner', 'AIStudioAutomationPlanner', 'INVALID_REQUEST', 'MALFORMED_RESPONSE', 'POLICY_VIOLATION', 'PROVIDER_FAILED', 'WORKFLOW_INPUT_MODES', 'PlannerError', 'PlannerErrorMapping', 'default_aistudio_provider_factory']

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Callable = typing.Callable
Iterable = typing.Iterable
Mapping = typing.Mapping
Sequence = typing.Sequence
SUPPORTED_WORKFLOWS = frozenset({'master', 'timemachine', 'affiliate', 'transcript', 'clone'})
WORKFLOW_INPUT_MODES = {'master': frozenset({'script', 'idea'}), 'clone': frozenset({'local_video'}), 'transcript': frozenset({'audio_file', 'text'}), 'affiliate': frozenset({'prepared_product'}), 'timemachine': frozenset({... [truncated]
PUBLISH_PLATFORM = 'tiktok'
MAX_BRIEF_CHARS = 12000
MAX_TITLE_CHARS = 160
MAX_CONTENT_CHARS = 12000
MAX_CAPTION_CHARS = 2200
INVALID_REQUEST = 'automation_planner_invalid_request'
AISTUDIO_UNAVAILABLE = 'automation_planner_aistudio_unavailable'
PROVIDER_FAILED = 'automation_planner_provider_failed'
MALFORMED_RESPONSE = 'automation_planner_malformed_response'
POLICY_VIOLATION = 'automation_planner_policy_violation'
_FEATURE_NAME = 'automation_center_planner'
_SAFE_IDENTIFIER_RE = re.compile('^[A-Za-z0-9][A-Za-z0-9._:-]{0,127}$')
_URL_RE = re.compile('(?i)(?:\\bhttps?://|\\bwww\\.|\\b[a-z0-9][a-z0-9-]*\\.(?:com|net|org|dev|io)(?:\\b|/))', re.IGNORECASE)
_EXECUTION_PRIMITIVE_RE = re.compile('(?i)\\b(?:browser|playwright|selenium|locator|selector|queryselector|click|goto|navigate|evaluate|javascript|webdriver|powershell|cmd(?:\\.exe)?|bash|curl|wget|shell|cookie|authorization|p... [truncated]
_SHELL_FRAGMENT_RE = re.compile('(?i)(?:\\brm\\s+-rf\\b|\\bpython\\s+-c\\b|\\bnode\\s+-e\\b|(?:^|\\s)(?:&&|\\|\\||\\$\\(|`))', re.IGNORECASE)
_OBVIOUS_SECRET_RE = re.compile('(?i)\\b(?:cookie|authorization|password|secret|access[_ -]?token|api[_ -]?key)\\s*[:=]', re.IGNORECASE)
ProviderFactory = typing.Callable[[], services.automation_center.planner.SynchronousAIProvider]
AUTOMATION_PLAN_SCHEMA = {'type': 'object', 'additionalProperties': False, 'required': ['title', 'content', 'workflow', 'input_mode', 'steps', 'publish', 'approval'], 'properties': {'title': {'type': 'string', 'maxLength': 16... [truncated]
_SYSTEM_INSTRUCTION = 'You are the draft planner inside Tool 1 Automation Center.\nProduce exactly one independent, stateless JSON draft matching the supplied closed schema.\nThe draft is descriptive only: never execute a ... [truncated]
__all__ = ['AISTUDIO_UNAVAILABLE', 'AUTOMATION_PLAN_SCHEMA', 'AutomationPlan', 'AutomationPlanMapping', 'AutomationPlanner', 'AIStudioAutomationPlanner', 'INVALID_REQUEST', 'MALFORMED_RESPONSE', 'POLICY_VIOLATI... [truncated]

# --- Class: PublishDraftMapping ---
class PublishDraftMapping(dict):
    pass


# --- Class: ApprovalDraftMapping ---
class ApprovalDraftMapping(dict):
    pass


# --- Class: PlannerProvenanceMapping ---
class PlannerProvenanceMapping(dict):
    pass


# --- Class: AutomationPlanMapping ---
class AutomationPlanMapping(dict):
    pass


# --- Class: PlannerErrorMapping ---
class PlannerErrorMapping(dict):
    pass


# --- Class: AutomationPlan ---
class AutomationPlan:
    """Normalized, immutable draft returned by :class:`AIStudioAutomationPlanner`."""
    approved = <member 'approved' of 'AutomationPlan' objects>
    caption = <member 'caption' of 'AutomationPlan' objects>
    content = <member 'content' of 'AutomationPlan' objects>
    contract_hash = <member 'contract_hash' of 'AutomationPlan' objects>
    draft_hash = <member 'draft_hash' of 'AutomationPlan' objects>
    input_mode = <member 'input_mode' of 'AutomationPlan' objects>
    profile_id = <member 'profile_id' of 'AutomationPlan' objects>
    publish_enabled = <member 'publish_enabled' of 'AutomationPlan' objects>
    publish_platform = <member 'publish_platform' of 'AutomationPlan' objects>
    requires_approval = <member 'requires_approval' of 'AutomationPlan' objects>
    source_brief = <member 'source_brief' of 'AutomationPlan' objects>
    status = <member 'status' of 'AutomationPlan' objects>
    steps = <member 'steps' of 'AutomationPlan' objects>
    title = <member 'title' of 'AutomationPlan' objects>
    workflow = <member 'workflow' of 'AutomationPlan' objects>

    def to_mapping(self) -> 'AutomationPlanMapping':
        pass

    def __init__(self, title: 'str', content: 'str', workflow: 'str', input_mode: 'str', steps: 'tuple[str, ...]', publish_enabled: 'bool' = False, publish_platform: 'str' = '', profile_id: 'str' = '', caption: 'str' = '', requires_approval: 'bool' = True, approved: 'bool' = False, source_brief: 'str' = '', contract_hash: 'str' = '', draft_hash: 'str' = '', status: 'str' = 'draft') -> None:
        pass

    def __repr__(self):
        pass


# --- Class: PlannerError ---
class PlannerError(RuntimeError):
    """Stable, structured failure safe to surface without provider internals."""
    code = <member 'code' of 'PlannerError' objects>
    details = <member 'details' of 'PlannerError' objects>
    message = <member 'message' of 'PlannerError' objects>

    def __init__(self, code: 'str', message: 'str', details: 'Mapping[str, Any] | None' = None) -> 'None':
        pass

    def to_mapping(self) -> 'PlannerErrorMapping':
        pass


# --- Class: SynchronousAIProvider ---
class SynchronousAIProvider(Protocol):
    _is_protocol = True
    _abc_impl = <_abc._abc_data object at 0x00000264DFBE24C0>

    def generate_json(self, **kwargs: 'Any') -> 'Any':
        pass

    def __init__(self, *args, **kwargs):
        pass


# --- Class: AIStudioAutomationPlanner ---
class AIStudioAutomationPlanner:
    """Generate policy-checked Automation Center drafts using one AI Studio call."""
    def __init__(self, provider: 'SynchronousAIProvider | None' = None, provider_factory: 'ProviderFactory | None' = None) -> 'None':
        pass

    def plan(self, brief: 'str', allowed_workflows: 'Iterable[str] | Mapping[str, Any]', available_profiles: 'Sequence[Mapping[str, Any]] | Mapping[str, Any]' = (), publish_intent: 'Mapping[str, Any] | str | bool | None' = None) -> 'AutomationPlan':
        pass

    def draft_plan(self, brief: 'str', allowed_workflows: 'Iterable[str] | Mapping[str, Any]', available_profiles: 'Sequence[Mapping[str, Any]] | Mapping[str, Any]' = (), publish_intent: 'Mapping[str, Any] | str | bool | None' = None) -> 'AutomationPlan':
        pass

    def _get_provider(self) -> 'SynchronousAIProvider':
        pass


# --- Class: AutomationPlanner ---
class AutomationPlanner:
    """Generate policy-checked Automation Center drafts using one AI Studio call."""
    def __init__(self, provider: 'SynchronousAIProvider | None' = None, provider_factory: 'ProviderFactory | None' = None) -> 'None':
        pass

    def plan(self, brief: 'str', allowed_workflows: 'Iterable[str] | Mapping[str, Any]', available_profiles: 'Sequence[Mapping[str, Any]] | Mapping[str, Any]' = (), publish_intent: 'Mapping[str, Any] | str | bool | None' = None) -> 'AutomationPlan':
        pass

    def draft_plan(self, brief: 'str', allowed_workflows: 'Iterable[str] | Mapping[str, Any]', available_profiles: 'Sequence[Mapping[str, Any]] | Mapping[str, Any]' = (), publish_intent: 'Mapping[str, Any] | str | bool | None' = None) -> 'AutomationPlan':
        pass

    def _get_provider(self) -> 'SynchronousAIProvider':
        pass


# --- Top-Level Functions ---
def default_aistudio_provider_factory() -> 'SynchronousAIProvider':
    pass

def _normalize_brief(value: 'Any') -> 'str':
    pass

def _normalize_capabilities(values: 'Iterable[str] | Mapping[str, Any]') -> 'tuple[str, ...]':
    pass

def _normalize_profiles(values: 'Sequence[Mapping[str, Any]] | Mapping[str, Any]') -> 'dict[str, dict[str, str]]':
    pass

def _normalize_publish_intent(value: 'Mapping[str, Any] | str | bool | None', profiles: 'Mapping[str, Mapping[str, str]]') -> 'dict[str, str] | None':
    pass

def _build_prompt(brief: 'str', capabilities: 'tuple[str, ...]', profiles: 'Mapping[str, Mapping[str, str]]', intent: 'Mapping[str, str] | None') -> 'str':
    pass

def _coerce_response(value: 'Any') -> 'Mapping[str, Any]':
    pass

def _validate_plan(raw: 'Mapping[str, Any]', capabilities: 'tuple[str, ...]', profiles: 'Mapping[str, Mapping[str, str]]', intent: 'Mapping[str, str] | None', brief: 'str' = '') -> 'AutomationPlan':
    pass

def _canonical_hash(value: 'Mapping[str, Any]') -> 'str':
    pass

def _require_closed_keys(value: 'Mapping[str, Any]', expected: 'set[str]', field: 'str') -> 'None':
    pass

def _bounded_text(value: 'Any', field: 'str', limit: 'int', required: 'bool') -> 'str':
    pass
