"""
Decompiled / Reconstructed Module: core.process_watchdog
Source PyC: process_watchdog.pyc

Docstring:
Process Watchdog - Quản lý vòng đời tất cả child processes của app.

Watchdog chạy như một subprocess riêng biệt, monitor PID của app chính.
Khi app chính die (crash/tắt), watchdog tự động cleanup tất cả child processes.

Flow:
1. App start → Spawn Watchdog (truyền parent PID)
2. App register child PIDs với Watchdog (qua file)
3. Watchdog monitor parent PID
4. Parent die → Watchdog kill all children → Exit
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
Optional = typing.Optional
Set = typing.Set
WATCHDOG_CHECK_INTERVAL = 2.0
PID_FILE_NAME = 'watchdog_pids.json'
_watchdog_process = None
_registry = None

# --- Class: ProcessRegistry ---
class ProcessRegistry:
    """Registry để app đăng ký child processes với watchdog."""
    def __init__(self):
        pass

    def _load_data(self) -> dict:
        pass

    def _save_data(self, data: dict):
        pass

    def register(self, name: str, pid: int):
        pass

    def unregister(self, name: str):
        pass

    def clear_all(self):
        pass


# --- Top-Level Functions ---
def _get_pid_file_path() -> pathlib.Path:
    pass

def _is_process_alive(pid: int) -> bool:
    pass

def _kill_process(pid: int, force: bool = False) -> bool:
    pass

def _kill_process_tree(pid: int) -> int:
    pass

def _watchdog_main(parent_pid: int):
    pass

def _cleanup_chrome_for_testing():
    pass

def _cleanup_rth_service():
    pass

def _find_watchdog_executable() -> str:
    pass

def start_watchdog() -> bool:
    pass

def _kill_old_watchdog():
    pass

def stop_watchdog():
    pass

def get_process_registry() -> core.process_watchdog.ProcessRegistry:
    pass
