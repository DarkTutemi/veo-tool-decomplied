"""
Decompiled / Reconstructed Module: core.dispatch.resume
Source PyC: resume.pyc

Docstring:
core/dispatch/resume.py — idempotency / resume helpers.

Prevent retries from re-generating or re-downloading work that already succeeded.
Reference: _get_existing_completed_result (L1765) + _get_resume_generation_result
(L1842) + _existing_video_path (L1722) in the old dispatcher.

JobStore-SoT design: state is read from the job's stored meta (prompt_data carries
the same keys at runtime). These return a GenResult when the job can be short-
circuited, else None.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)

# --- Top-Level Functions ---
def _existing_video_path(path: 'Any') -> 'str':
    pass

def _is_explicit_regen(prompt_data: 'dict') -> 'bool':
    pass

def _meta(job_store, job_id: 'str') -> 'dict':
    pass

def _store_status_complete(job_store, job_id: 'str') -> 'bool':
    pass

def check_existing_completed(handle: 'JobHandle', prompt_data: 'dict', job_store, *, enable_upscale: 'bool' = False) -> 'GenResult | None':
    pass

def check_resume_generation(handle: 'JobHandle', prompt_data: 'dict', job_store, *, enable_upscale: 'bool' = False) -> 'GenResult | None':
    pass
