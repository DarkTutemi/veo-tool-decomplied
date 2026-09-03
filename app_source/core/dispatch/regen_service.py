"""
Decompiled / Reconstructed Module: core.dispatch.regen_service
Source PyC: regen_service.pyc

Docstring:
core/dispatch/regen_service.py — RegenService

Extracts the auto-regen path from SmartJobDispatcher.regen_job / _smart_regen_job
into a standalone, injectable service.

Improvements over the old dispatcher:
- No references to global singletons (get_job_store()) at call time — the store
  is injected at construction.
- build_regen_prompt_data() is a pure function: no network, no side effects.
- regen() is async-clean: no threading.Lock or worker pool lookups.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Optional = typing.Optional
logger = <Logger core.dispatch.regen_service (WARNING)>
_TRANSIENT_KEYS = frozenset({'resume_media_id', 'end_media_id_map', 'is_auto_regen', 'video_url_720p', 'character_images_base64', 'append_to_queue', 'visual_assets', 'reuse_job_id', 'start_media_id', 'reference_entitie... [truncated]

# --- Class: IJobStore ---
class IJobStore(Protocol):
    """Minimal JobStore surface that RegenService uses."""
    _is_protocol = True
    _abc_impl = <_abc._abc_data object at 0x00000264D83D1880>
    _is_runtime_protocol = True

    def get_meta(self, job_id: 'str') -> 'dict':
        pass

    def update_meta(self, job_id: 'str', updates: 'dict') -> 'None':
        pass

    def list_jobs(self) -> 'list':
        pass

    def __init__(self, *args, **kwargs):
        pass


# --- Class: IJobStateSync ---
class IJobStateSync(Protocol):
    _is_protocol = True
    _abc_impl = <_abc._abc_data object at 0x00000264DB251940>
    _is_runtime_protocol = True

    def on_retrying(self, handle: 'JobHandle', delay: 'float', reason: 'str') -> 'None':
        pass

    def __init__(self, *args, **kwargs):
        pass


# --- Class: IJobQueue ---
class IJobQueue(Protocol):
    _is_protocol = True
    _abc_impl = <_abc._abc_data object at 0x00000264DB251E00>
    _is_runtime_protocol = True

    def requeue(self, handle: 'JobHandle', delay: 'float' = 0.0) -> 'None':
        pass

    def __init__(self, *args, **kwargs):
        pass


# --- Class: RegenService ---
class RegenService:
    """Handles auto-regen: reads stored prompt data and enqueues a new attempt.

    Args:
        job_queue:  Async queue to enqueue the new handle into.
        job_state:  Writes on_retrying signal to JobStore / UI.
        job_store:  Persistent store for reading/updating job meta."""
    def __init__(self, job_queue: 'IJobQueue', job_state: 'IJobStateSync', job_store: 'IJobStore') -> 'None':
        pass

    def regen(self, handle: 'JobHandle') -> 'JobHandle':
        """Create a new attempt handle from the stored prompt data and enqueue it.

        Steps:
        1. Read ``_regen_prompt_data`` from JobStore meta.
        2. Build a new JobHandle with a fresh ``attempt_id``, reset counters.
        3. Update meta so the new handle references the same job_id.
        4. Signal on_retrying, then enqueue.

        Returns the new JobHandle.

        Raises:
            ValueError: If no ``_regen_prompt_data`` is found in meta."""
        pass

    @staticmethod
    def infer_feature(prompt_data: 'dict', meta: 'dict') -> 'str':
        pass

    @classmethod
    def prepare_replay(cls, meta: 'dict', store_prompt: 'str' = '') -> 'Optional[tuple[str, dict]]':
        """Build (feature, prompt_data) for a user-triggered regen.

        Reads ``_regen_prompt_data`` (captured at submit), restores filenames,
        infers the feature, sets regen flags, and syncs the user-edited prompt
        from the JobStore. Returns None when no usable replay data exists."""
        pass

    @staticmethod
    def lookup_previous_media_id(jobs: 'Any', extend_chain_id: 'str', current_position: 'int', root_card_index: 'Optional[int]' = None) -> 'Optional[str]':
        pass

    @staticmethod
    def build_regen_prompt_data(prompt_data: 'dict', feature: 'str') -> 'dict':
        pass


# --- Top-Level Functions ---
def _has_logical_voice_source(prompt_data: 'dict') -> 'bool':
    pass
