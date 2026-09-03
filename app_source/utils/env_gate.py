"""
Decompiled / Reconstructed Module: utils.env_gate

Docstring:
Environment gate — hard block weak machines before QML / browser prewarm.

Call ``enforce_env_gate()`` once from ``main()`` after single-instance, before
``_run_qml_mode``. Fast OS queries only (<50ms typical).

Thresholds — chặn trước khi QML/browser khởi động nếu máy không còn đủ headroom:
  - RAM total/free < max(4 GB, 2 GB app + 3 browser owners x 1 GB x enabled account)
                     (nâng RAM/tắt account, hoặc đóng bớt ứng dụng rồi mở lại)
  - Disk free  < 2 GB   (không đủ chỗ ghi output)
  - CPU cores  < 2
  - Not x64 on Windows
  - Không đọc được RAM / disk / CPU (không thể chứng minh máy đủ tài nguyên)

Soft / limited (VẪN cho chạy, chỉ giảm chất lượng render; KHÔNG tắt prewarm):
  - RAM total  < 12 GB  OR  cores < 4  OR  disk < 10 GB

Source-only debug escape: VEOFLOW_FORCE_RUN=1  |  --force-run
Demo:   VEOFLOW_ENV_GATE_DEMO=1  |  python -m utils.env_gate --demo
"""

from __future__ import annotations
import sys, os, typing
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Optional = typing.Optional
MIN_RAM_GB = 4.0
MIN_RAM_FREE_GB = 4.0
MIN_DISK_FREE_GB = 2.0
MIN_CPU_CORES = 2
BROWSER_OWNERS_PER_ENABLED_ACCOUNT = 3
RAM_GB_PER_BROWSER_OWNER = 1.0
APP_RAM_RESERVE_GB = 2.0
LIMITED_RAM_GB = 12.0
LIMITED_DISK_FREE_GB = 10.0
LIMITED_CPU_CORES = 4

# --- Class: CheckRow ---
class CheckRow:
    """CheckRow(key: 'str', label: 'str', required: 'str', actual: 'str', ok: 'bool', hard: 'bool', reason: 'str' = '')"""
    reason = ''

    def __init__(self, key: 'str', label: 'str', required: 'str', actual: 'str', ok: 'bool', hard: 'bool', reason: 'str' = '') -> None:
        pass

    def __repr__(self):
        pass


# --- Class: EnvReport ---
class EnvReport:
    """EnvReport(ok: 'bool', limited: 'bool', tier: 'str', rows: 'list[CheckRow]' = <factory>, hard_fails: 'list[str]' = <factory>, soft_warns: 'list[str]' = <factory>, metrics: 'dict[str, Any]' = <factory>, elapsed_ms: 'float' = 0.0, forced: 'bool' = False)"""
    elapsed_ms = 0.0
    forced = False

    def to_dict(self) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'ok', 'limited', 'tier', 'rows', 'hard_fails', 'soft_warns', 'metrics', 'elapsed_ms', 'forced', 'asdict', 'list', 'dict'
        pass

    def __init__(self, ok: 'bool', limited: 'bool', tier: 'str', rows: 'list[CheckRow]' = <factory>, hard_fails: 'list[str]' = <factory>, soft_warns: 'list[str]' = <factory>, metrics: 'dict[str, Any]' = <factory>, elapsed_ms: 'float' = 0.0, forced: 'bool' = False) -> None:
        pass

    def __repr__(self):
        pass


# --- Top-Level Functions ---
def _env_truthy(name: 'str') -> 'bool':
    # [PyArmor BCC constants]: 'os', 'environ', 'get', '', 'strip', 'lower', '1', 'on', 'yes', 'true'
    pass

def required_browser_prewarm_ram_gb(enabled_account_count: 'Optional[int]') -> 'float':
    # [PyArmor BCC constants]: 'isinstance', 'bool', 'int', 'ValueError', 'enabled account count must be a non-negative integer', 0, 'BROWSER_OWNERS_PER_ENABLED_ACCOUNT', 'RAM_GB_PER_BROWSER_OWNER', 'max', 'MIN_RAM_FREE_GB', 'APP_RAM_RESERVE_GB'
    pass

def read_enabled_account_count_strict() -> 'int':
    # [PyArmor BCC constants]: 'get_sqlite_accounts_store', '_connect', 'execute', 'SELECT COUNT(*) AS count FROM accounts WHERE enabled = 1', 'fetchone', 'RuntimeError', 'account capacity query returned no result', 'int', 'count', 0, 'account capacity query returned an invalid count'
    pass

def _gb(n_bytes: 'float') -> 'float':
    pass

def _fmt_gb(n_gb: 'float') -> 'str':
    # [PyArmor BCC constants]: 100, '.0f', ' GB', 10, '.1f', '.2f'
    pass

def _read_memory() -> 'tuple[float, float]':
    """Return (total_gb, available_gb)."""
    pass

def _read_disk_free(path: 'str') -> 'float':
    # [PyArmor BCC constants]: 'sys', 'platform', 'win32', 'c_ulonglong', 0, 'os', 'path', 'splitdrive', 'abspath', '\\', 'windll', 'kernel32', 'GetDiskFreeSpaceExW', 'c_wchar_p', 'byref'
    pass

def _appdata_dir() -> 'str':
    # [PyArmor BCC constants]: 'sys', 'platform', 'win32', 'os', 'environ', 'get', 'APPDATA', 'path', 'expanduser', '~', 'join', 'VEO3_Generator_Pro', '.veoflow'
    pass

def _install_dir() -> 'str':
    # [PyArmor BCC constants]: 'getattr', 'sys', 'frozen', False, 'os', 'path', 'dirname', 'executable', 'abspath', '__file__'
    pass

def _cpu_cores() -> 'int':
    # [PyArmor BCC constants]: 'int', 'os', 'cpu_count', 0
    pass

def _is_x64() -> 'bool':
    # [PyArmor BCC constants]: 'platform', 'machine', '', 'lower', 'amd64', 'x64', 'x86_64', True, 'sys', 'maxsize', 2, 32
    pass

def evaluate_environment(*, demo_fail: 'bool' = False, enabled_account_count: 'Optional[int]' = None) -> 'EnvReport':
    """
    Run checks and return a structured report.
    
        Hardware probes are converted into fail rows. An invalid browser-account
        count raises deliberately so startup cannot under-size the mandatory pool.
    """
    # [PyArmor BCC constants]: 4.0, 0.8, 1.2, 1, False
    pass

def apply_limited_mode(report: 'EnvReport') -> 'None':
    # [PyArmor BCC constants]: 'tier', 'limited', 'refuse', 'os', 'environ', 'setdefault', 'VEOFLOW_SAFE_RENDER', '1', 'QSG_SAMPLES', '0'
    pass

def persist_report(report: 'EnvReport') -> 'Optional[str]':
    # [PyArmor BCC constants]: 'Path', '_appdata_dir', 'mkdir', 'parents', True, 'exist_ok', 'env_check.json', 'to_dict', 'time', 'strftime', '%Y-%m-%dT%H:%M:%S', 'ts', 'write_text', 'json', 'dumps'
    pass

def _user_facing_rows(report: 'EnvReport') -> 'list[CheckRow]':
    pass

def _user_plain_summary(report: 'EnvReport') -> 'str':
    # [PyArmor BCC constants]: 'VeoFlow — Máy chưa đủ điều kiện chạy', '', '_user_facing_rows', 'ok', 'append', '• ', 'label', ': máy có ', 'actual', ' (cần ', 'required', ')', 'reason', '  → ', 'extend'
    pass

def show_block_dialog(report: 'EnvReport', *, title: 'str' = 'VeoFlow') -> 'None':
    # [PyArmor BCC constants]: 'Qt', 'QColor', 'QGuiApplication', 'QAbstractItemView', 'QApplication', 'QDialog', 'QFrame', 'QHBoxLayout', 'QHeaderView', 'QLabel', 'QPushButton', 'QSizePolicy', 'QTableWidget', 'QTableWidgetItem', 'QVBoxLayout'
    pass

def grab_dialog_screenshot(report: 'EnvReport', out_path: 'str') -> 'str':
    # [PyArmor BCC constants]: 'QTimer', 'QApplication', 'QDialog', 'instance', 'os', 'environ', 'setdefault', 'QT_ENABLE_HIGHDPI_SCALING', '1', 'sys', 'argv', 1, 'path', 'show', 'raise_'
    pass

def enforce_env_gate(*, demo: 'bool' = False, force_run: 'bool' = False, enabled_account_count: 'Optional[int]' = None) -> 'EnvReport':
    # [PyArmor BCC constants]: '_env_truthy', 'VEOFLOW_ENV_GATE_DEMO', 'VEOFLOW_FORCE_RUN', 'bool', 'getattr', 'sys', 'frozen', False, 'evaluate_environment', 'demo_fail', 'enabled_account_count', 'str', 'tier', '', 'os'
    pass

def main(argv: 'Optional[list[str]]' = None) -> 'int':
    # [PyArmor BCC constants]: 'list', 'sys', 'argv', 1, 'ArgumentParser', 'description', 'VeoFlow environment gate', 'add_argument', '--demo', 'action', 'store_true', 'help', 'Force fail + show block dialog', '--check', 'Print report JSON and exit'
    pass
