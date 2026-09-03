"""
Decompiled / Reconstructed Module: services.tabs.deep_research.research_scheduler
Source PyC: research_scheduler.pyc

Docstring:
Research Scheduler — Tự động hoá Deep Research pipeline theo lịch
Hỗ trợ: one-time, daily, weekly scheduling
Lưu queue vào AppData, chạy background QTimer check mỗi phút
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
Dict = typing.Dict
List = typing.List
Optional = typing.Optional
_SCHEDULE_FILE = 'research_schedule.json'
_HISTORY_FILE = 'research_schedule_history.json'
MAX_RETRIES_ONCE = 2
MAX_RETRIES_RECURRING = 3
_scheduler = None

# --- Class: ScheduleFrequency ---
class ScheduleFrequency:
    ONCE = 'once'
    DAILY = 'daily'
    WEEKLY = 'weekly'
    WEEKDAYS = 'weekdays'


# --- Class: ScheduleStatus ---
class ScheduleStatus:
    PENDING = 'pending'
    RUNNING = 'running'
    DONE = 'done'
    FAILED = 'failed'
    PAUSED = 'paused'


# --- Class: ResearchScheduler ---
class ResearchScheduler:
    """Manages the research schedule queue.
    UI calls check_due() periodically (e.g. every 60s via QTimer)."""
    def __init__(self):
        pass

    def _schedule_path(self) -> str:
        pass

    def _history_path(self) -> str:
        pass

    def load(self):
        pass

    def _validate_on_load(self):
        pass

    def save(self):
        pass

    def _ensure_loaded(self):
        pass

    def add(self, item: Dict) -> str:
        pass

    def remove(self, item_id: str):
        pass

    def update(self, item_id: str, **kwargs):
        pass

    def get_all(self) -> List[Dict]:
        pass

    def get_enabled(self) -> List[Dict]:
        pass

    def toggle_enabled(self, item_id: str):
        pass

    def reset_item(self, item_id: str):
        pass

    def check_due(self) -> List[Dict]:
        pass

    def mark_running(self, item_id: str):
        pass

    def mark_done(self, item_id: str):
        pass

    def mark_failed(self, item_id: str, error: str = ''):
        pass

    def _append_history(self, item: Dict, result: str, error: str = ''):
        pass

    def get_history(self, limit: int = 50) -> List[Dict]:
        pass


# --- Top-Level Functions ---
def make_schedule_item(topic: str, template_id: str = '', language: str = 'vi', script_format: str = 'monologue', voice_name: str = 'Kore', voice2_name: str = 'Puck', speaker1: str = 'Host', speaker2: str = 'Guest', run_at: str = None, frequency: str = 'once', hour: int = 8, minute: int = 0, weekday: int = None, quality_mode: bool = True, auto_director_notes: bool = True, auto_import: bool = True, enabled: bool = True, audio_route: str = 'overview') -> Dict:
    pass

def _compute_next_run(run_at: str, frequency: str, hour: int, minute: int, weekday: int) -> str:
    pass

def _advance_next_run(item: Dict) -> str:
    pass

def get_scheduler() -> services.tabs.deep_research.research_scheduler.ResearchScheduler:
    pass
