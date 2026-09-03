"""
Decompiled / Reconstructed Module: services.shared.jobs.server_job_tracker
Source PyC: server_job_tracker.pyc

Docstring:
Server Job Tracker — tracks active jobs on the Go server's job queue.
Singleton service used by UI to display queue position and progress.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
Dict = typing.Dict
Optional = typing.Optional
Callable = typing.Callable
List = typing.List

# --- Class: TrackedJob ---
class TrackedJob:
    """A job being tracked on the server."""
    status = 'pending'
    progress = 0
    progress_msg = ''
    queue_position = 0
    submitted_at = 0.0
    error = ''
    on_progress = None
    on_complete = None
    on_error = None

    def __init__(self, job_id: str, job_type: str, status: str = 'pending', progress: int = 0, progress_msg: str = '', queue_position: int = 0, submitted_at: float = 0.0, error: str = '', result: dict = <factory>, on_progress: Optional[Callable] = None, on_complete: Optional[Callable] = None, on_error: Optional[Callable] = None) -> None:
        pass

    def __repr__(self):
        pass


# --- Class: ServerJobTracker ---
class ServerJobTracker:
    """Tracks active server-side jobs for UI display."""
    _instance = None
    _lock = <unlocked _thread.lock object at 0x00000264E2275A80>

    def __init__(self):
        pass

    def set_update_callback(self, callback: Callable):
        pass

    def track_job(self, job_id: str, job_type: str, queue_position: int = 0, on_progress: Callable = None, on_complete: Callable = None, on_error: Callable = None) -> services.shared.jobs.server_job_tracker.TrackedJob:
        pass

    def update_job(self, job_id: str, status: str = None, progress: int = None, progress_msg: str = None, error: str = None, result: dict = None):
        pass

    def remove_job(self, job_id: str):
        pass

    def _remove_job(self, job_id: str):
        pass

    def get_active_jobs(self) -> List[services.shared.jobs.server_job_tracker.TrackedJob]:
        pass

    def get_active_count(self) -> int:
        """Get count of non-terminal jobs."""
        pass

    def get_summary(self) -> str:
        pass

    def _notify_update(self):
        pass


# --- Top-Level Functions ---
def get_server_job_tracker() -> services.shared.jobs.server_job_tracker.ServerJobTracker:
    pass
