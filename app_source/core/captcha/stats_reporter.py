"""
Decompiled / Reconstructed Module: core.captcha.stats_reporter
Source PyC: stats_reporter.pyc

Docstring:
Captcha statistics reporter - sends periodic stats to server.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
Optional = typing.Optional
Dict = typing.Dict
log = <Logger core.captcha.stats_reporter (WARNING)>

# --- Class: StatsReporter ---
class StatsReporter:
    """Singleton that periodically reports captcha stats to server."""
    _instance = None
    _lock = <unlocked _thread.lock object at 0x00000264DA622500>

    def __init__(self) -> None:
        pass

    def configure(self, server_url: str, license_key: str, enabled: bool = True) -> None:
        pass

    def start(self) -> None:
        pass

    def stop(self) -> None:
        pass

    def report_now(self) -> bool:
        pass

    def _report_loop(self) -> None:
        pass

    @staticmethod
    def _has_meaningful_stats(stats: Dict[str, Any]) -> bool:
        pass

    def _build_payload(self, stats: Dict[str, Any]) -> Dict[str, Any]:
        pass

    def _send_to_server(self, payload: Dict[str, Any]) -> bool:
        pass


# --- Top-Level Functions ---
def get_stats_reporter() -> core.captcha.stats_reporter.StatsReporter:
    pass
