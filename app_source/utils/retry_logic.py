"""
Decompiled / Reconstructed Module: utils.retry_logic

Docstring:
Shared Retry Logic

Centralized retry/regeneration logic used across multiple modules:
- managers/smart_job_dispatcher.py
- core/hybrid_video_core.py
- threads/image_generation.py
- And more...

This module provides:
1. is_retryable_error() - Check if error should be retried
2. calculate_retry_delay() - Calculate exponential backoff delay
3. get_error_category() - Classify error type
4. Consistent error classification across the codebase

Note: AI auto-fix for policy violations is in services/ai_providers.py
"""

from __future__ import annotations
import sys, os, typing
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['PROMINENT_PERSON_ERROR_CATEGORY', 'is_prominent_person_policy_error', 'is_retryable_error', 'calculate_retry_delay', 'get_error_category', 'classify_http_error']

# --- Module Constants & Globals ---
PROMINENT_PERSON_ERROR_CATEGORY = 'prominent_person_policy'
_PROMINENT_PERSON_MARKERS = ('public_error_prominent_people_filter_failed', 'public_error_prominent_people_filter', 'prominent_people_filter_failed', 'prominent_people_filter', 'prominent_person')
__all__ = ['PROMINENT_PERSON_ERROR_CATEGORY', 'is_prominent_person_policy_error', 'is_retryable_error', 'calculate_retry_delay', 'get_error_category', 'classify_http_error']

# --- Top-Level Functions ---
def is_prominent_person_policy_error(error_message: str) -> bool:
    """True when Google returned its prominent/public-person filter marker."""
    pass

def is_retryable_error(error_message: str, retry_count: int = 0, max_retries: int = 3) -> bool:
    """
    Check if error is retryable
        
        Args:
            error_message: Error message to check
            retry_count: Current retry attempt (0-based)
            max_retries: Maximum retry attempts allowed
        
        Returns:
            True if error should be retried, False if permanent error or max retries reached
        
        Examples:
            >>> is_retryable_error("500 Internal Server Error", retry_count=0)
            True
            >>> is_retryable_error("Policy violation", retry_count=0)
            True  # ✅ Retryable with AI auto-fix (max 2 retries)
            >>> is_retryable_error("PUBLIC_ERROR_UNSAFE_GENERATION", retry_count=1)
            True  # Will use AI to fix prompt after 2 retries
            >>> is_retryable_error("Insufficient credits", retry_count=0)
            False  # Permanent error
    """
    # [PyArmor BCC constants]: '500', 'internal server error', 'server error', '502', 'bad gateway', '503', 'service unavailable', '429', 'too many requests', 'rate limit', 'rate_limit', 'resource_exhausted', 'resource has been exhausted', 'check quota', 'throttled'
    pass

def calculate_retry_delay(retry_count: int, is_rate_limit: bool = False, base_delay: int = 60) -> int:
    # [PyArmor BCC constants]: 15, 60, 10, 2, 'min'
    pass

def get_error_category(error_message: str) -> str:
    """
    Categorize error for better logging/reporting
    
        Args:
            error_message: Error message to categorize
    
        Returns:
            Error category string
    
        Categories:
            - 'server_error': 500, 502, 503
            - 'rate_limit': 429, too many requests
            - 'timeout': timeout, deadline
            - 'network': connection errors
            - 'policy': policy violations
            - 'auth_expired': 401, 403, token expired (cookie die - needs user action)
            - 'client': 400, 404
            - 'credits': insufficient credits
            - 'unknown': unknown error
    """
    # [PyArmor BCC constants]: 'targetclosederror', 'target page, context or browser has been closed', 'browser has been closed', 'browser disconnected', 'failed to load page', 'net::err_aborted', "'nonetype' object has no attribute 'goto'", "'nonetype' object has no attribute 'evaluate'", "'nonetype' object has no attribute 'add_cookies'", "'nonetype' object has no attribute 'reload'", "'nonetype' object has no attribute 'url'", 'all_browsers_crashed', 'no available browser', 'epipe', 'broken pipe'
    pass

def classify_http_error(status_code: int, response_text: str = '') -> dict:
    # [PyArmor BCC constants]: 401, 'error_category', 'auth_expired', 'retryable', False, 'message', 'Authentication failed - token expired', 403, 'recaptcha_failed', True, '403 Forbidden - reCAPTCHA validation failed (will retry with new token)', 429, 'rate_limit', 'Rate limit exceeded - will retry after cooldown', 500
    pass
