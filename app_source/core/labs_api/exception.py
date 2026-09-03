"""
Decompiled / Reconstructed Module: core.labs_api.exception
Source PyC: exception.pyc

Docstring:
core/labs_api/exception.py — VEO3GenerationError (unified generation exception).

Relocated from core/api_client.py. api_client re-exports it for backward compat;
labs_api modules import it from here so the package no longer bridges the
exception back through the god-file.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)

# --- Class: VEO3GenerationError ---
class VEO3GenerationError(Exception):
    """Unified exception for video generation errors.

    Attributes:
        message: human-readable error message.
        category: error category from utils/retry_logic.py (e.g. 'auth_expired',
            'policy', 'rate_limit').
        cached_data: data to preserve for retry (e.g. start_media_id, end_media_id).
        retryable: whether this error can be retried (derived from category unless
            given explicitly).

    ``str()`` renders ``message|error_category:category`` so the value round-trips
    through utils.retry_logic.get_error_category()."""
    NON_RETRYABLE_CATEGORIES = frozenset({'credits', 'auth_expired', 'account_banned', 'insufficient_credits'})

    def __init__(self, message: 'str', category: 'str' = 'unknown', cached_data: 'dict' = None, retryable: 'bool' = None):
        pass

    def __str__(self) -> 'str':
        pass

    def __repr__(self) -> 'str':
        pass

