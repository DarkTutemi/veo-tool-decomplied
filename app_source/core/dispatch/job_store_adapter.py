"""
Decompiled / Reconstructed Module: core.dispatch.job_store_adapter
Source PyC: job_store_adapter.pyc

Docstring:
core/dispatch/job_store_adapter.py — bridge orchestrator/regen ↔ real JobStore.

The DispatchOrchestrator and RegenService talk to the store through a small
``get_meta(job_id) -> dict`` / ``update_meta(job_id, updates)`` surface (the
``IJobStore`` protocol). The real ``core.job_store.JobStore`` exposes
``get_job()`` / ``create_job()`` / ``update_job_meta()`` instead.

Without this adapter the orchestrator's ``store.get_meta`` / ``store.update_meta``
calls raise ``AttributeError`` on the real store. They are wrapped in try/except,
so the failure is swallowed and ``_prompt_data`` is never persisted or read —
every live job would then run with an empty ``prompt_data``. Tests passed only
because they inject a fake store that already speaks get_meta/update_meta.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
logger = <Logger core.dispatch.job_store_adapter (WARNING)>
_FEATURE_MAP = {'text_video': 'text2video_16_9', 'portrait_video': 'portrait_video', 'image_video': 'image_to_video', 'extend_video': 'extend_video', 'multi_asset_video': 'multi_asset_video', 'image_generation': 'im... [truncated]

# --- Class: DispatchJobStoreAdapter ---
class DispatchJobStoreAdapter:
    """Adapts the real JobStore to the get_meta/update_meta surface."""
    def __init__(self, core_store: 'Any') -> 'None':
        pass

    def get_meta(self, job_id: 'str') -> 'dict':
        pass

    def get_job(self, job_id: 'str'):
        pass

    def list_jobs(self):
        pass

    def update_prompt(self, job_id: 'str', prompt: 'str') -> 'None':
        pass

    def update_meta(self, job_id: 'str', updates: 'dict') -> 'None':
        pass

