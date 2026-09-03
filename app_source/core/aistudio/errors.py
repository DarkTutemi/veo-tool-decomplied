"""
Decompiled / Reconstructed Module: core.aistudio.errors
Source PyC: errors.pyc

Docstring:
core/aistudio/errors.py — AI Studio web provider exceptions.

Recovery law lives here. Callers classify, then apply the matching layer:

* S1 poison — DirectSession.soft_reset once (401 / gRPC 13 / 14 / empty / HTTP 5xx)
* S2 media-7 — session waits + reload; lane may switch model afterwards
* S3 text-7 — session reload once (including TTS); lane may switch model
* Q quota — router pair cooldown, never a page reload
* A auth — block this AI Studio account, never mint
* F fail-fast — gRPC 3 / block_manifest_incomplete, do not retry
* T transport — resource manager re-warm, then account rotate
* B1 crash — Playwright closed/crashed: replace worker + retry action once
* B2 hung — run() timeout: kill process, then same as B1 (once)
* B3 stale page — ensure_ready probe (URL + app + BotGuard): close + full warm
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
SESSION_MEDIA_PERMISSION_WAITS = (25.0, 35.0, 45.0, 45.0)
SESSION_POISON_SLEEP_SECONDS = 3.0
_HTTP_STATUS_RE = re.compile('\\bhttp\\s+(\\d{3})\\b', re.IGNORECASE)

# --- Class: AiStudioError ---
class AiStudioError(Exception):
    """Base exception for AI Studio web provider."""
    NON_RETRYABLE_CATEGORIES = frozenset({'auth_expired', 'session_invalid', 'account_banned'})

    def __init__(self, message: 'str', category: 'str' = 'unknown', retryable: 'bool' = None):
        pass

    def __str__(self) -> 'str':
        pass

    def __repr__(self) -> 'str':
        pass


# --- Class: AiStudioGenerationError ---
class AiStudioGenerationError(AiStudioError):
    """Generation failed (internal error, timeout, DOM scrape failure)."""
    pass


# --- Class: BlockManifestIncompleteError ---
class BlockManifestIncompleteError(AiStudioGenerationError):
    """One manifest-driven block stayed incomplete after local recovery.

    This is deliberately non-retryable at the *job* boundary.  The provider has
    already retained every completed block, retried only the missing scene IDs,
    and tried the allow-listed fallback model.  Re-running the outer Master /
    Clone / Transcript job would discard that checkpoint and repeat paid work."""
    def __init__(self, block_label: 'str', missing_ids, attempted_models=()):
        pass


# --- Class: AiStudioAuthError ---
class AiStudioAuthError(AiStudioError):
    """Session expired or not logged in.

    EXCEPTION THUẦN DATA — KHÔNG tự báo động hay ghi trạng thái account. AI Studio
    và Labs/Flow là hai browser surface độc lập: lỗi ở đây chỉ được phép đóng
    circuit-breaker trong ``core.aistudio.auth_health``. Chỉ một Labs token/session
    probe mới có quyền chuyển AccountManager sang ``Need Login``.

    _AiStudioRouter._call là nơi đánh dấu AI Studio auth-block sau một call thật;
    prewarm/keepalive best-effort vẫn im lặng và không làm account video bị evict."""
    def __init__(self, message: 'str', account: 'str' = ''):
        pass


# --- Class: AiStudioSelectorError ---
class AiStudioSelectorError(AiStudioError):
    """DOM selector not found — Google may have changed the UI."""
    def __init__(self, selector: 'str', context: 'str' = ''):
        pass


# --- Top-Level Functions ---
def is_block_manifest_incomplete_error(error: 'BaseException') -> 'bool':
    pass

def _error_category(error: 'BaseException') -> 'str':
    pass

def _error_message(error: 'BaseException') -> 'str':
    pass

def classify_grpc_error(code: 'int', http_status: 'int' = 0) -> 'str':
    pass

def is_session_refresh_error(error: 'BaseException') -> 'bool':
    pass

def is_transient_internal_error(error: 'BaseException') -> 'bool':
    pass

def is_empty_response_error(error: 'BaseException') -> 'bool':
    pass

def is_http_server_error(error: 'BaseException') -> 'bool':
    pass

def is_retryable_backend_error(error: 'BaseException') -> 'bool':
    pass

def is_permission_denied_error(error: 'BaseException') -> 'bool':
    pass

def is_quota_error(error: 'BaseException') -> 'bool':
    pass

def is_tts_text_modality_error(error: 'BaseException') -> 'bool':
    pass

def is_fail_fast_error(error: 'BaseException') -> 'bool':
    pass

def plan_session_recovery(error: 'BaseException', has_media: 'bool', session_refresh_used: 'int', poison_used: 'int', text_permission_used: 'int', media_permission_used: 'int'):
    pass

def session_recovery_loop_len(has_media: 'bool') -> 'int':
    pass
