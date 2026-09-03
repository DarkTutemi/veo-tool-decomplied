"""
Decompiled / Reconstructed Module: core.gemini_web.wire
Source PyC: wire.pyc

Docstring:
Wire builders / parsers for Gemini Web StreamGenerate (freepath).

Live reverse 2026-07-11 (Ultra, Playwright):

Auth layers (NOT the same as AI Studio)
---------------------------------------
1. **Cookies** — Google session (``__Secure-1PSID`` / ``__Secure-1PSIDTS`` / SAPISID…)
2. **SNlM0e** (form ``at=``) — page XSRF/access token from ``WIZ_global_data.SNlM0e``
   - Warm **once** per page/session (stable until refresh), ~42 chars
   - Format: ``AD1_…:timestamp``
3. **inner[3] BotGuard bang-token** — UI always sends ``!…`` (~1.6–2.6k chars)
   - Hook on ``botguard.bg`` did **not** fire on send (mint path obfuscated)
   - Freepath smoke: **omit [3] OR fake ``!`` token → still HTTP 200** for text chat
   - Unlike AI Studio: content-hash BotGuard mint is **not required** for basic
     independent text calls (may still matter for media / abuse-sensitive ops)

Call shape (gateway-like independent)
-------------------------------------
- ``inner[2]`` empty metadata = **new conversation every call** (no history burn)
- Each freepath call → new ``c_*`` id (stateless like go-gateway generate)
- Multi-turn = pass previous metadata (cid/rid/rcid) in ``inner[2]``

Endpoint
--------
POST ``/_/BardChatUi/data/assistant.lamda.BardFrontendService/StreamGenerate``
  ?bl=<build_label>&f.sid=<FdrFJe>&hl=<lang>&_reqid=<int>&rt=c
Content-Type: application/x-www-form-urlencoded
  at=<SNlM0e>
  f.req=[null, "<inner JSON string>"]
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Optional = typing.Optional
DR_CAP_FLAG_INDEX = 55
DR_PLAN_TOOLS_INDEX = 54
TEMPORARY_CHAT_FLAG_INDEX = 45
TOOL_MODE_DEEP_RESEARCH = 1
TOOL_MODE_IMAGE = 14
TOOL_MODE_INDEX = 49
TOOL_MODE_MUSIC = 21
TOOL_MODE_NONE = 0
TOOL_MODE_VIDEO = 11
TOOL_MODES = {'none': 0, 'chat': 0, 'deep_research': 1, 'research': 1, 'video': 11, 'create_video': 11, 'image': 14, 'create_image': 14, 'music': 21, 'create_music': 21}
_INNER_LEN = 92
_FREEPATH_SEND_JS = '\n(async (args) => {\n  const snl = (window.WIZ_global_data && window.WIZ_global_data.SNlM0e) || args.accessToken;\n  if (!snl) return JSON.stringify({status:0, error:\'no_snlm0e\'});\n  const bl = a... [truncated]

# --- Top-Level Functions ---
def empty_chat_metadata() -> 'list':
    """New-chat / independent-call metadata (live UI)."""
    pass

def chat_metadata(cid: 'str' = '', rid: 'str' = '', rcid: 'str' = '', *, context_token: 'Optional[str]' = None) -> 'list':
    pass

def fake_botguard_token(length: 'int' = 1950) -> 'str':
    pass

def resolve_tool_mode(tool: 'Optional[str]' = None, *, deep_research: 'bool' = False) -> 'int':
    pass

def build_inner(*, prompt: 'str', language: 'str' = 'en', metadata: 'Optional[list]' = None, file_data: 'Optional[list]' = None, botguard_token: 'Optional[str]' = None, request_id_hex: 'Optional[str]' = None, client_uuid: 'Optional[str]' = None, deep_research: 'bool' = False, tool: 'Optional[str]' = None, temporary: 'bool' = False, gem_id: 'Optional[str]' = None) -> 'list':
    """Build StreamGenerate inner array (freepath text / tools / DR).

    ``metadata=None`` → empty slots → **independent** call (recommended freepath).
    ``botguard_token=None`` → omit slot [3] (OK for text freepath 2026-07-11).
    ``deep_research=True`` or ``tool=deep_research|image|video|music`` →
    set mode flags; auto fake BotGuard for tool modes (UI always sends !…).
    ``temporary=True`` → UI "Cuộc trò chuyện tạm thời" — ``inner[45]=1``
    (không vào sidebar Gần đây; ideal cho freepath call lẻ)."""
    pass

def build_stream_body(*, prompt: 'str', access_token: 'str', language: 'str' = 'en', metadata: 'Optional[list]' = None, file_data: 'Optional[list]' = None, botguard_token: 'Optional[str]' = None, request_id_hex: 'Optional[str]' = None, independent: 'bool' = True, deep_research: 'bool' = False, tool: 'Optional[str]' = None, temporary: 'bool' = False, gem_id: 'Optional[str]' = None) -> 'str':
    pass

def build_stream_params(*, build_label: 'str', session_id: 'str', language: 'str' = 'en', reqid: 'int' = 100000) -> 'dict[str, str]':
    pass

def parse_stream_frames(raw: 'str') -> 'list[Any]':
    pass

def extract_answer(raw: 'str') -> 'dict[str, Any]':
    pass

def extract_page_tokens(html: 'str') -> 'dict[str, Optional[str]]':
    pass

def file_data_from_uploads(uploads: 'list[tuple[str, str]]') -> 'list':
    pass
