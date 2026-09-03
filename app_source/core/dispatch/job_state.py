"""
Decompiled / Reconstructed Module: core.dispatch.job_state
Source PyC: job_state.pyc

Docstring:
core/dispatch/job_state.py — JobStateSync

Implements IJobStateSync from contracts.py.

Improvement over the god-object:
- No static/class-level state.
- JobStore is injected (falls back to get_job_store() if None).
- Signals are injected as a plain dict of callables → testable without Qt.
- Attempt fence prevents stale workers from clobbering completed jobs.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Callable = typing.Callable
Dict = typing.Dict
Optional = typing.Optional

# --- Class: JobStateSync ---
class JobStateSync:
    """Single responsibility: write job state to JobStore + fire UI callbacks.

    Constructor args:
        job_store   — any object with update_status(job_id, *, ...) and
                      update_job_meta(job_id, meta_dict) and
                      get_job(job_id).  Pass None to use get_job_store().
        signals     — dict of optional callbacks:
                        'on_generating'  : (job_id, phase) -> None
                        'on_polling'     : (job_id) -> None
                        'on_completed'   : (job_id, result) -> None
                        'on_failed'      : (job_id, error, category) -> None
                        'on_retrying'    : (job_id, delay, reason) -> None"""
    def __init__(self, job_store=None, signals: 'Optional[Dict[str, Callable]]' = None) -> 'None':
        pass

    def _store(self):
        pass

    def add_listener(self, name: 'str', cb: 'Callable') -> 'None':
        pass

    def _fire(self, name: 'str', *args: 'Any') -> 'None':
        pass

    def _update(self, job_id: 'str', **kwargs: 'Any') -> 'bool':
        pass

    def _update_meta(self, job_id: 'str', meta: 'Dict[str, Any]') -> 'None':
        pass

    def is_current_attempt(self, handle: 'JobHandle') -> 'bool':
        pass

    def _guard(self, handle: 'JobHandle', phase: 'str') -> 'bool':
        pass

    def on_generating(self, handle: 'JobHandle', phase: 'str' = '') -> 'None':
        pass

    def on_polling(self, handle: 'JobHandle') -> 'None':
        pass

    def on_upscaling(self, handle: 'JobHandle', resolution: 'str' = '1080p') -> 'None':
        pass

    def on_completed(self, handle: 'JobHandle', result: 'GenResult') -> 'None':
        pass

    def reset_for_regen(self, job_id: 'str') -> 'None':
        pass

    def on_failed(self, handle: 'JobHandle', error: 'str', error_category: 'str' = '') -> 'None':
        pass

    def on_retrying(self, handle: 'JobHandle', delay: 'float', reason: 'str' = '') -> 'None':
        pass

    def persist_media_id(self, handle: 'JobHandle', media_id: 'str', video_url_720p: 'str' = '') -> 'None':
        pass

    def save_pending_thumbnail(self, handle: 'JobHandle', thumbnail_url: 'str', show: 'bool' = False) -> 'None':
        pass

    def mark_attempt_heartbeat(self, handle: 'JobHandle', phase: 'str' = 'polling') -> 'None':
        pass


# --- Top-Level Functions ---
def _get_store(job_store):
    pass

def _upscale_eta_seconds(resolution: 'str') -> 'int':
    pass
