"""
Decompiled / Reconstructed Module: services.automation_center.publishing.evidence
Source PyC: evidence.pyc

Docstring:
Canonical external-post evidence shared by dispatch and reconciliation.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['canonical_external_evidence']

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
urlsplit = <functools._lru_cache_wrapper object at 0x00000264D08DE6C0>
_TIKTOK_ID = re.compile('^[0-9]{10,24}$')
_YOUTUBE_ID = re.compile('^[A-Za-z0-9_-]{11}$')
_FACEBOOK_ID = re.compile('^[0-9]{5,40}(?:_[0-9]{5,40})?$')
__all__ = ['canonical_external_evidence']

# --- Top-Level Functions ---
def canonical_external_evidence(platform: 'object', value: 'Mapping[str, Any]') -> 'dict[str, str] | None':
    pass

def _valid_id(platform: 'str', value: 'str') -> 'bool':
    pass

def _evidence_from_url(platform: 'str', value: 'str') -> 'dict[str, str] | None':
    pass
