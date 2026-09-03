"""
Decompiled / Reconstructed Module: core.gemini_web.research
Source PyC: research.pyc

Docstring:
Gemini Web Deep Research freepath (plan → start → poll).

Live reverse 2026-07-11 (Ultra):
  StreamGenerate with inner[49]=1, [54]=[[[[[1]]]]], [55]=[[1]]
  Plan meta key "56", state "70"=2
  Start multi-turn confirm prompt; meta "57"/"58", state "70"=3
  Poll via batchexecute hNvQHb (READ_CHAT) — not kwDCne in live UI

immersive_entry_chip appears at START (not done). Do not treat chip alone as completed.

See docs/GEMINI_WEB_DEEP_RESEARCH.md.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Callable = typing.Callable
Optional = typing.Optional
TYPE_CHECKING = False
urlsplit = <functools._lru_cache_wrapper object at 0x00000264D08DE6C0>
APP_URL = 'https://gemini.google.com/app'
BATCHEXECUTE = 'https://gemini.google.com/_/BardChatUi/data/batchexecute'
DEFAULT_CONFIRM_PROMPTS = ('Bắt đầu nghiên cứu', 'Start research', 'Start researching')
DR_PROGRESS_META_KEY = '58'
DR_RUN_META_KEY = '57'
DR_STATE_META_KEY = '70'
DR_STATE_PLAN = 2
DR_STATE_RUNNING = 3
DR_PLAN_META_KEY = '56'
RPC_BARD_ACTIVITY = 'ESY5D'
RPC_DEEP_RESEARCH_ACK = 'PCck7e'
RPC_DEEP_RESEARCH_CAPS = 'aPya6c'
RPC_DEEP_RESEARCH_STATUS = 'kwDCne'
RPC_READ_CHAT = 'hNvQHb'
_log = <Logger gemini_web.research (WARNING)>
_UUID_RE = re.compile('\\b[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\\b', re.IGNORECASE)
_IM_RE = re.compile('\\bim_[A-Za-z0-9_]+\\b')
_PROGRESS_SNIPPETS = ('tôi đang tiến hành', "i'm working", 'i am working', 'khi nghiên cứu hoàn tất', 'when research is complete', 'you can leave the conversation', 'rời khỏi cuộc trò chuyện', 'deep_research_confirmation_... [truncated]
_FAILURE_SNIPPETS = ('i encountered an error', 'something went wrong', 'research failed', 'unable to complete the research', "couldn't complete the research", 'could not complete the research', 'đã xảy ra lỗi', 'nghiên c... [truncated]
_RESEARCH_PLAN_LINE_RE = re.compile('^\\s*(?:\\(\\d+\\)|\\d+[.)])\\s+(?:research|examine|study|analy[sz]e|investigate|identify|synthesi[sz]e|compile|review|compare|determine|evaluate|explore|nghiên\\s+cứu|xem\\s+xét|phân\\s+t... [truncated]
_WEB_URL_RE = re.compile('https?://[^\\s<>{}\\[\\]\\\\\\"\']+', re.IGNORECASE)
_INTERNAL_SOURCE_HOSTS = {'gemini.google.com', 'googleusercontent.com', 'gstatic.com', 'accounts.google.com', 'www.gstatic.com'}
_INTERNAL_SOURCE_HOST_SUFFIXES = ('.googleapis.com', '.googleusercontent.com', '.gstatic.com')

# --- Class: DeepResearchPlan ---
class DeepResearchPlan:
    """Plan card returned before user confirms research."""
    title = ''
    eta_text = None
    confirm_prompt = 'Bắt đầu nghiên cứu'
    modify_prompt = None
    confirmation_url = None
    query = None
    response_text = ''
    cid = ''
    rid = ''
    rcid = ''
    context_token = None
    research_id = None
    raw_state = None
    raw = ''

    def to_start_metadata(self) -> 'list':
        pass

    def __init__(self, title: 'str' = '', steps: 'list[str]' = <factory>, eta_text: 'Optional[str]' = None, confirm_prompt: 'str' = 'Bắt đầu nghiên cứu', modify_prompt: 'Optional[str]' = None, confirmation_url: 'Optional[str]' = None, query: 'Optional[str]' = None, response_text: 'str' = '', cid: 'str' = '', rid: 'str' = '', rcid: 'str' = '', context_token: 'Optional[str]' = None, research_id: 'Optional[str]' = None, raw_state: 'Optional[int]' = None, metadata: 'list' = <factory>, raw: 'str' = '') -> None:
        pass

    def __repr__(self):
        pass


# --- Class: DeepResearchStatus ---
class DeepResearchStatus:
    """One poll snapshot while research runs."""
    state = 'unknown'
    title = None
    report_text = ''
    cid = ''
    immersive_id = None
    task_id = None
    research_id = None
    raw_state = None
    done = False
    raw = ''

    def __init__(self, state: 'str' = 'unknown', title: 'Optional[str]' = None, notes: 'list[str]' = <factory>, report_text: 'str' = '', cid: 'str' = '', immersive_id: 'Optional[str]' = None, task_id: 'Optional[str]' = None, research_id: 'Optional[str]' = None, raw_state: 'Optional[int]' = None, done: 'bool' = False, citations: 'list[dict[str, str]]' = <factory>, raw: 'str' = '') -> None:
        pass

    def __repr__(self):
        pass


# --- Class: DeepResearchResult ---
class DeepResearchResult:
    """DeepResearchResult(plan: 'DeepResearchPlan', statuses: 'list[DeepResearchStatus]' = <factory>, start_text: 'str' = '', final_text: 'str' = '', done: 'bool' = False, cid: 'str' = '', citations: 'list[dict[str, str]]' = <factory>)"""
    start_text = ''
    final_text = ''
    done = False
    cid = ''

    def __init__(self, plan: 'DeepResearchPlan', statuses: 'list[DeepResearchStatus]' = <factory>, start_text: 'str' = '', final_text: 'str' = '', done: 'bool' = False, cid: 'str' = '', citations: 'list[dict[str, str]]' = <factory>) -> None:
        pass

    def __repr__(self):
        pass


# --- Class: DeepResearchMixin ---
class DeepResearchMixin:
    """Methods mixed into GeminiWebClient (or used via composition)."""
    def batch_execute(self: "'GeminiWebClient'", rpcid: 'str', payload: 'str' = '[]') -> 'str':
        pass

    def deep_research_preflight(self: "'GeminiWebClient'") -> 'dict[str, Any]':
        pass

    def deep_research_available(self: "'GeminiWebClient'") -> 'Optional[bool]':
        pass

    def create_deep_research_plan(self: "'GeminiWebClient'", prompt: 'str', *, model: 'str' = 'flash', botguard_token: 'Optional[str]' = None, preflight: 'bool' = True) -> 'DeepResearchPlan':
        pass

    def start_deep_research(self: "'GeminiWebClient'", plan: 'DeepResearchPlan', *, confirm_prompt: 'Optional[str]' = None, model: 'str' = 'flash', botguard_token: 'Optional[str]' = None, ack: 'bool' = True) -> 'GeminiWebResult':
        pass

    def get_deep_research_status(self: "'GeminiWebClient'", cid: 'str', *, research_id: 'Optional[str]' = None) -> 'DeepResearchStatus':
        pass

    def wait_for_deep_research(self: "'GeminiWebClient'", plan: 'DeepResearchPlan', *, poll_interval: 'float' = 10.0, timeout: 'float' = 600.0, on_status: 'Optional[Callable[[DeepResearchStatus], None]]' = None) -> 'DeepResearchResult':
        pass

    def deep_research(self: "'GeminiWebClient'", prompt: 'str', *, model: 'str' = 'flash', poll_interval: 'float' = 10.0, timeout: 'float' = 600.0, on_status: 'Optional[Callable[[DeepResearchStatus], None]]' = None, botguard_token: 'Optional[str]' = None, auto_start: 'bool' = True) -> 'DeepResearchResult':
        pass


# --- Top-Level Functions ---
def _iter_nested(data: 'Any'):
    pass

def _find_dict_with_key(data: 'Any', key: 'str') -> 'Optional[dict]':
    pass

def _wrb_parts(fr: 'Any') -> 'list[list]':
    pass

def _walk_loaded_frames(raw: 'str') -> 'list[Any]':
    pass

def _steps_from_payload(steps_payload: 'Any') -> 'list[str]':
    pass

def extract_deep_research_plan(raw: 'str', *, fallback_ids: 'Optional[dict[str, str]]' = None) -> 'Optional[DeepResearchPlan]':
    pass

def extract_start_state(raw: 'str') -> 'dict[str, Any]':
    pass

def _collect_notes(data: 'Any', *, limit: 'int' = 16) -> 'list[str]':
    pass

def looks_like_progress_only(text: 'str') -> 'bool':
    pass

def looks_like_research_plan(text: 'str') -> 'bool':
    """Reject a DR action plan before it can masquerade as a final report.

    Gemini's accepted-plan payload can be longer than 1,500 characters and is
    commonly emitted as ``(1) Research ...`` through ``(8) Compile ...``.
    Length alone therefore cannot prove that Deep Research has finished."""
    pass

def looks_like_final_report(text: 'str') -> 'bool':
    pass

def looks_like_research_failure(text: 'str') -> 'bool':
    """Recognize a terminal Gemini failure note without matching report prose."""
    pass

def extract_dr_report(raw: 'str') -> 'str':
    pass

def _normalize_research_source_url(value: 'Any') -> 'str':
    """Return one externally verifiable research URL or an empty string.

    READ_CHAT contains many Gemini UI/media URLs alongside the actual web
    sources.  Only expose external HTTP(S) documents.  Google ``/url`` links
    are unwrapped so the evidence ledger is pinned to the publisher URL, not a
    transient redirect."""
    pass

def _iter_research_payload_values(raw: 'str'):
    """Walk READ_CHAT frames and recursively decode nested JSON strings."""
    pass

def extract_deep_research_citations(raw: 'str', *, report_text: 'str' = '') -> 'list[dict[str, str]]':
    pass

def extract_deep_research_status(raw: 'str', *, cid: 'str' = '') -> 'DeepResearchStatus':
    pass

def build_batch_body(access_token: 'str', rpcid: 'str', payload: 'str') -> 'str':
    pass

def build_read_chat_payload(cid: 'str') -> 'str':
    pass
