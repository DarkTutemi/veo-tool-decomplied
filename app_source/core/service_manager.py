"""
Decompiled / Reconstructed Module: core.service_manager
Source PyC: service_manager.pyc
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
Optional = typing.Optional

# --- Class: ServiceManager ---
class ServiceManager:
    """Centralized manager for all application services (Watchdog, RTH, Browser Pool).
    Singleton pattern to ensure only one manager instance exists."""
    _instance = None
    _lock = <unlocked _thread.lock object at 0x00000264D774FF40>

    def __init__(self):
        pass

    def start_all_startup_services(self, status_callback=None):
        pass

    def start_watchdog(self):
        pass

    def start_rth_service(self):
        pass

    def init_browser_pool(self, status_callback=None):
        pass

    def stop_all(self):
        """Stop ALL services safely - Fast version with parallel cleanup."""
        pass

    def prepare_for_update(self):
        pass


# --- Top-Level Functions ---
def get_service_manager():
    pass
