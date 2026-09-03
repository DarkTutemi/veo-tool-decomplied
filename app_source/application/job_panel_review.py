"""
Decompiled / Reconstructed Module: application.job_panel_review
Source PyC: job_panel_review.pyc

Docstring:
Persist scene-review marks on JobStore rows (pass / flagged / unseen).
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
_STATUSES = frozenset({'pass', 'unseen', 'flagged'})

# --- Top-Level Functions ---
def _text(value: 'Any') -> 'str':
    pass

def normalize_review_status(value: 'Any') -> 'str':
    pass

def review_from_meta(meta: 'Any') -> 'dict[str, Any]':
    pass

def flatten_review_fields(row: 'dict[str, Any]', meta: 'Mapping[str, Any] | None' = None) -> 'dict[str, Any]':
    pass

def set_job_panel_review(job_store: 'Any', job_id: 'str', status: 'str', *, expected_tab_sources: 'Iterable[str] | str | None' = None, reason: 'str' = '', bump_gen: 'bool' = False) -> 'dict[str, Any]':
    pass

def mark_review_after_regen(job_store: 'Any', job_id: 'str') -> 'None':
    pass
