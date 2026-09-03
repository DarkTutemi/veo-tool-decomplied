"""
Decompiled / Reconstructed Module: core.aistudio.rpc_client
Source PyC: rpc_client.pyc

Docstring:
core/aistudio/rpc_client.py — Direct RPC calls to MakerSuite API.

Uses the AI Studio browser page ONLY as cookie/auth context. No DOM
automation — calls the same gRPC-web endpoints that the Angular frontend
uses, via in-page fetch().

Auth: SAPISIDHASH (computed from SAPISID cookie — standard Google pattern).
Payload: Gemini-API–compatible GenerateContentRequest JSON.
Response: streamed protobuf-JSON (nested arrays with [null, "text"] pairs).
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
List = typing.List
Optional = typing.Optional
_log = <Logger aistudio.rpc (WARNING)>
RPC_BASE = 'https://alkalimakersuite-pa.clients6.google.com/$rpc/google.internal.alkali.applications.makersuite.v1.MakerSuiteService'
ORIGIN = 'https://aistudio.google.com'
_FETCH_RPC_JS = "\n(async ([url, payloadStr, timeoutMs]) => {\n    // ── 1. Compute SAPISIDHASH from cookies ──\n    let sapisid = '';\n    for (const c of document.cookie.split(';')) {\n        const eq = c.indexOf(... [truncated]
_PROBE_AUTH_JS = "\n(() => {\n    let sapisid = '';\n    for (const c of document.cookie.split(';')) {\n        const eq = c.indexOf('=');\n        if (eq < 0) continue;\n        const name = c.slice(0, eq).trim();\n ... [truncated]
_MIME_MAP = {'.jpg': 'image/jpeg', '.jpeg': 'image/jpeg', '.png': 'image/png', '.webp': 'image/webp', '.gif': 'image/gif', '.mp4': 'video/mp4', '.webm': 'video/webm', '.mov': 'video/quicktime', '.mp3': 'audio/mpe... [truncated]

# --- Class: AiStudioRpcClient ---
class AiStudioRpcClient:
    """Direct RPC caller — no DOM automation.

    Requires a Playwright page that is navigated to aistudio.google.com
    and authenticated (valid Google cookies)."""
    def __init__(self, page):
        pass

    def check_auth(self) -> 'bool':
        pass

    def generate_content(self, prompt: 'str', *, model: 'Optional[str]' = None, system_instruction: 'str' = '', file_paths: 'Optional[List[str]]' = None, temperature: 'Optional[float]' = None, max_output_tokens: 'int' = 65536, response_mime_type: 'Optional[str]' = None, timeout_ms: 'int' = 120000) -> 'str':
        pass

    def generate_content_multiturn(self, turns: 'List[Dict[str, Any]]', *, model: 'Optional[str]' = None, system_instruction: 'str' = '', temperature: 'Optional[float]' = None, max_output_tokens: 'int' = 65536, response_mime_type: 'Optional[str]' = None, timeout_ms: 'int' = 120000) -> 'str':
        pass

    def count_tokens(self, prompt: 'str', *, model: 'Optional[str]' = None, timeout_ms: 'int' = 10000) -> 'int':
        pass

    @staticmethod
    def _build_generate_payload(*, model: 'str', prompt: 'str', system_instruction: 'str' = '', file_paths: 'Optional[List[str]]' = None, temperature: 'Optional[float]' = None, max_output_tokens: 'int' = 65536, response_mime_type: 'Optional[str]' = None) -> 'dict':
        pass

    @staticmethod
    def _build_multiturn_payload(*, model: 'str', turns: 'List[Dict[str, Any]]', system_instruction: 'str' = '', temperature: 'Optional[float]' = None, max_output_tokens: 'int' = 65536, response_mime_type: 'Optional[str]' = None) -> 'dict':
        pass

    def _rpc_call(self, url: 'str', payload: 'dict', *, timeout_ms: 'int' = 120000) -> 'dict':
        pass

    def _parse_generate_response(self, result: 'dict') -> 'str':
        pass


# --- Top-Level Functions ---
def _collect_model_text(data, parts: 'list'):
    pass

def _file_to_inline_data(file_path: 'str') -> 'Optional[Dict[str, Any]]':
    pass
