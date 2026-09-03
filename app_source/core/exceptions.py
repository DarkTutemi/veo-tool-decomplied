"""
Decompiled / Reconstructed Module: core.exceptions
Source PyC: exceptions.pyc

Docstring:
Custom exceptions for reCAPTCHA token handling.

This module provides specialized exceptions for tracking reCAPTCHA-related errors
with proper browser index attribution to avoid race conditions.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
Optional = typing.Optional

# --- Class: RecaptchaTokenError ---
class RecaptchaTokenError(Exception):
    """Exception raised when getting a reCAPTCHA token fails.

    This is raised BEFORE making an API call, when the token acquisition itself fails.

    Attributes:
        message: Error message describing why token acquisition failed
        browser_idx: Browser index (if available) for tracking
        provider_status: Status from provider manager ('all_failed', 'all_circuit_open', 'none')"""
    def __init__(self, message: str = 'Failed to get reCAPTCHA token', browser_idx: Optional[int] = None, provider_status: Optional[str] = None):
        pass

    def __str__(self):
        pass

    def is_circuit_open(self) -> bool:
        pass


# --- Class: CaptchaProviderDownError ---
class CaptchaProviderDownError(Exception):
    """Exception raised when all captcha providers are down (circuit breaker OPEN).

    This indicates a temporary server outage - job should wait and retry
    when providers recover, NOT fail permanently.

    Attributes:
        message: Error message
        recovery_wait: Suggested wait time before retry (seconds)"""
    def __init__(self, message: str = 'All captcha providers are down', recovery_wait: int = 60):
        pass

    def __str__(self):
        pass


# --- Class: RecaptchaError ---
class RecaptchaError(Exception):
    """Exception raised when an API call fails due to reCAPTCHA validation (403 error).

    This is raised AFTER making an API call, when the server rejects the token.
    The browser_idx is preserved in the exception to avoid race conditions in async flows.

    Attributes:
        message: Error message
        browser_idx: Browser index that provided the failed token (CRITICAL for feedback)
        http_status: HTTP status code (typically 403)
        original_error: Original exception that triggered this (optional)
        provider_id: ID of the provider that supplied the failed token (for exclude_providers)"""
    def __init__(self, message: str = 'reCAPTCHA verification failed', browser_idx: Optional[int] = None, http_status: int = 403, original_error: Optional[Exception] = None, provider_id: Optional[str] = None):
        pass

    def __str__(self):
        pass


# --- Class: ContentPolicyError ---
class ContentPolicyError(Exception):
    """Exception raised when upload is rejected due to content policy (e.g. minor/child images).

    Google API returns 400 with reason PUBLIC_ERROR_MINOR_UPLOAD.
    Should NOT retry - the image itself is the problem."""
    def __init__(self, message: str = 'Content policy violation'):
        pass

