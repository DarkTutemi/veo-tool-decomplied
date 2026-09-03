"""
Decompiled / Reconstructed Module: core.dispatch.upscale_service
Source PyC: upscale_service.pyc

Docstring:
core/dispatch/upscale_service.py — UpscaleService implementation.

Extracts upscale logic from smart_job_dispatcher._execute_upscale_synchronous,
_is_black_thumbnail, _fetch_thumbnail_bytes, _download_thumbnail_once,
_save_thumbnail_file. No god-object deps; injects api_client functions.

Improvements over old dispatcher:
- Retry is caller-side: upscale() returns UpscaleResult(retryable=True) on failure
  instead of raising with embedded "|phase:upscale" tags.
- check_black() and resolve_thumbnail() are standalone, testable, pure-ish.
- No side-effects on JobStore / Qt signals — those stay in the orchestrator.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Optional = typing.Optional
_BLACK_BRIGHTNESS_THRESHOLD = 15
_BLACK_VARIANCE_THRESHOLD = 100

# --- Class: UpscaleService ---
class UpscaleService:
    """Implements IUpscaleService.

    Wraps the synchronous upscale_video_to_1080p api_client function in an
    async interface so strategy callers can use asyncio.to_thread naturally.

    Retry policy is NOT owned here — callers receive UpscaleResult(retryable=True)
    on failure and decide whether to retry.

    check_black() and resolve_thumbnail() are module-level helpers exposed on
    the class for convenience; they do not carry instance state."""
    @staticmethod
    def check_black(thumbnail_url_or_b64: 'str') -> 'bool':
        pass

    @staticmethod
    def resolve_thumbnail(raw: 'str', account_email: 'str' = '') -> 'str':
        pass

    def upscale(self, req: 'UpscaleRequest') -> 'UpscaleResult':
        """Run upscale synchronously in a thread; return UpscaleResult."""
        pass

    def _upscale_sync(self, req: 'UpscaleRequest') -> 'UpscaleResult':
        pass


# --- Top-Level Functions ---
def _fetch_thumbnail_bytes(thumbnail_url: 'str') -> 'bytes':
    pass

def check_black(thumbnail_url_or_b64: 'str') -> 'bool':
    pass

def resolve_thumbnail(raw: 'str', account_email: 'str' = '') -> 'str':
    pass
