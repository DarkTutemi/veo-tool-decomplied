"""
Decompiled / Reconstructed Module: services.automation_center.account_conversation
Source PyC: account_conversation.pyc

Docstring:
Account-bound, persistent LLM conversation for Channel Copilot.

The conversation lives on the authenticated Google account/browser owned by
Tool 1.  SQLite stores only the binding, conversation metadata and an audit
mirror; local message replay is never used as model context.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['ACTION_ENVELOPE_END', 'ACTION_ENVELOPE_START', 'AccountLLMChannelCopilot', 'COPILOT_ACCOUNT_DRIFT', 'COPILOT_ACTION_SCHEMA', 'COPILOT_ACTION_INVALID', 'COPILOT_CONVERSATION_DRIFT', 'ChannelConversationReply', 'account_fingerprint', 'visible_stream_text']

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
COPILOT_PLAN_SCHEMA = {'type': 'object', 'additionalProperties': False, 'required': ['assistant_message', 'strategy', 'content_items', 'approval'], 'properties': {'assistant_message': {'type': 'string', 'maxLength': 4000},... [truncated]
MAX_MESSAGE_CHARS = 20000
MAX_PROJECT_BRIEF_CHARS = 20000
AISTUDIO_UNAVAILABLE = 'automation_planner_aistudio_unavailable'
PROVIDER_FAILED = 'automation_planner_provider_failed'
ACTION_ENVELOPE_START = '<veoflow_action_envelope>'
ACTION_ENVELOPE_END = '</veoflow_action_envelope>'
CONVERSATION_SURFACE = 'gemini_web'
DEFAULT_CONVERSATION_MODEL = 'flash'
COPILOT_ACTION_SCHEMA = {'type': 'object', 'additionalProperties': False, 'required': ['strategy', 'content_items', 'approval'], 'properties': {'strategy': {'type': 'object', 'additionalProperties': False, 'required': ['titl... [truncated]
COPILOT_ACCOUNT_DRIFT = 'COPILOT_ACCOUNT_DRIFT'
COPILOT_CONVERSATION_DRIFT = 'COPILOT_CONVERSATION_DRIFT'
COPILOT_ACTION_INVALID = 'COPILOT_ACTION_INVALID'
_ACCOUNT_SYSTEM_PROMPT = "You are the Channel Copilot inside VeoFlow Tool 1.\nYou are having a real, continuing conversation with the operator. Answer naturally and\ndirectly in the operator's language. Tool 1 owns all execut... [truncated]
__all__ = ['ACTION_ENVELOPE_END', 'ACTION_ENVELOPE_START', 'AccountLLMChannelCopilot', 'COPILOT_ACCOUNT_DRIFT', 'COPILOT_ACTION_SCHEMA', 'COPILOT_ACTION_INVALID', 'COPILOT_CONVERSATION_DRIFT', 'ChannelConversat... [truncated]

# --- Class: ConversationTransport ---
class ConversationTransport(Protocol):
    _is_protocol = True
    _abc_impl = <_abc._abc_data object at 0x00000264DF436740>

    def warm(self) -> 'bool':
        pass

    def generate(self, prompt: 'str', *, metadata: 'list[Any] | None' = None, model: 'str' = 'flash', independent: 'bool' = False, temporary: 'bool' = False, on_text_update: 'Callable[[str], None] | None' = None) -> 'Any':
        pass

    def __init__(self, *args, **kwargs):
        pass


# --- Class: ChannelConversationReply ---
class ChannelConversationReply:
    """ChannelConversationReply(assistant_message: 'str', conversation: 'dict[str, Any]', draft: 'ChannelCopilotDraft | None' = None, action_state: 'str' = 'none', action_error_code: 'str' = '', action_error_message: 'str' = '')"""
    draft = None
    action_state = 'none'
    action_error_code = ''
    action_error_message = ''

    def draft_mapping(self) -> 'dict[str, Any] | None':
        pass

    def __init__(self, assistant_message: 'str', conversation: 'dict[str, Any]', draft: 'ChannelCopilotDraft | None' = None, action_state: 'str' = 'none', action_error_code: 'str' = '', action_error_message: 'str' = '') -> None:
        pass

    def __repr__(self):
        pass


# --- Class: AccountLLMChannelCopilot ---
class AccountLLMChannelCopilot:
    """Continue one Gemini Web conversation on one exact Tool 1 account."""
    def __init__(self, transport_factory: 'Callable[[str], ConversationTransport] | None' = None, account_selector: 'Callable[[], str] | None' = None, identity_resolver: 'Callable[[Mapping[str, Any]], Mapping[str, Any]] | None' = None) -> 'None':
        pass

    def resolve_account(self, bound_conversation: 'Mapping[str, Any] | None' = None) -> 'dict[str, Any]':
        pass

    def verify_account(self, account: 'Mapping[str, Any]') -> 'None':
        pass

    def send_turn(self, *, account: 'Mapping[str, Any]', conversation: 'Mapping[str, Any] | None', project_brief: 'str', user_message: 'str', allowed_workflows: 'Iterable[str]', current_strategy: 'Mapping[str, Any] | None' = None, available_sources: 'Sequence[Mapping[str, Any]]' = (), channel_context: 'Mapping[str, Any] | None' = None, on_text_update: 'Callable[[str], None] | None' = None) -> 'ChannelConversationReply':
        pass


# --- Top-Level Functions ---
def account_fingerprint(value: 'Mapping[str, Any]') -> 'str':
    pass

def visible_stream_text(value: 'Any') -> 'str':
    pass

def _conversation_prompt(message: 'str', context: 'Mapping[str, Any]', *, first_turn: 'bool') -> 'str':
    pass

def _split_action_envelope(raw_text: 'str') -> 'tuple[str, Mapping[str, Any] | None, str]':
    pass

def _result_value(result: 'Any', field: 'str') -> 'Any':
    pass

def _default_transport_factory(account_name: 'str') -> 'ConversationTransport':
    pass

def _default_account_selector() -> 'str':
    pass

def _default_identity_resolver(value: 'Mapping[str, Any]') -> 'Mapping[str, Any]':
    pass
