"""
Decompiled / Reconstructed Module: core.credit_history_store
Source PyC: credit_history_store.pyc

Docstring:
CreditHistoryStore — Persistent JSON store for AI credit usage history.
Stores per-request credit breakdown, auto-cleans entries older than 7 days.
Thread-safe singleton.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
Dict = typing.Dict
List = typing.List
Optional = typing.Optional

# --- Class: CreditHistoryStore ---
class CreditHistoryStore:
    """Append-only JSON store: one file per day, auto-cleanup after 7 days."""
    _instance = None
    _lock_cls = <unlocked _thread.lock object at 0x00000264D83AA000>
    RETENTION_DAYS = 7

    def __init__(self):
        pass

    def _day_file(self, day_key: str) -> str:
        pass

    @staticmethod
    def _today_str() -> str:
        pass

    def _load_today(self):
        pass

    def _flush_today(self):
        pass

    def add(self, credit_usage: Dict, source: str = ''):
        pass

    def get_today(self) -> List[Dict]:
        pass

    def get_range(self, days: int = 7) -> List[Dict]:
        pass

    def get_summary(self, days: int = 1) -> Dict[str, Any]:
        """Aggregate summary for the last N days."""
        pass

    def export_csv(self, path: str, days: int = 7) -> int:
        pass

    def clear_all(self):
        pass

    def _cleanup_old(self):
        pass


# --- Top-Level Functions ---
def get_credit_history_store() -> core.credit_history_store.CreditHistoryStore:
    pass
