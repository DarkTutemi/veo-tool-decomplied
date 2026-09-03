"""
Decompiled / Reconstructed Module: update.__init__

Docstring:
Update module for VEO3 Tool
Contains auto-updater functionality
"""

from __future__ import annotations
import sys, os, typing
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['AutoUpdater', 'UnifiedDownloader', 'UpdateStateManager', 'apply_update', 'apply_pending_update']

# --- Module Constants & Globals ---
__all__ = ['AutoUpdater', 'UnifiedDownloader', 'UpdateStateManager', 'apply_update', 'apply_pending_update']

# --- Class: AutoUpdater ---
class AutoUpdater:
    """
    Non-blocking auto-updater for VEO3 Tool (zip self-update).
    
        All heavy work runs in QThread. Main thread only handles UI dialogs.
        Download logic in UpdateDialog, apply logic in apply_update/apply_pending_update.
    """
    def __init__(self, parent_window=None):
        # [PyArmor BCC constants]: 'parent', 'VEO3Config', 'TOOL_VERSION', 'current_version', 'checker', 'downloader', True, 'silent_check', False, '_checking'
        pass

    def check_for_updates(self, silent=False):
        # [PyArmor BCC constants]: '_checking', 'silent_check', True, '_stop_thread', 'checker', 'UpdateChecker', 'current_version', 'update_available', 'connect', '_on_update_available', 'Qt', 'ConnectionType', 'QueuedConnection', 'no_update', '_on_no_update'
        pass

    def cleanup(self):
        pass

    def check_pending_install(self):
        # [PyArmor BCC constants]: 'UpdateStateManager', 'has_pending_install', 'parent', 'dict', 'get', 'status', '', 'version', '?', 'downloaded', 'print', '[AutoUpdater] Pending update ', '; QML shell owns install confirmation.'
        pass

    def _on_checker_done(self):
        # [PyArmor BCC constants]: False, '_checking', 'checker', 'deleteLater'
        pass

    def _on_update_available(self, update_info):
        # [PyArmor BCC constants]: 'isinstance', 'dict', 'get', 'latest_version', '?', 'bool', 'required', False, 'print', '[AutoUpdater] Update available version=', ' required='
        pass

    def _on_no_update(self):
        # [PyArmor BCC constants]: False, '_checking', 'silent_check', 'parent', 'print', '[AutoUpdater] Up to date: ', 'current_version'
        pass

    def _on_check_error(self, error_msg):
        # [PyArmor BCC constants]: False, '_checking', 'silent_check', 'parent', 'print', '[AutoUpdater] Check error: '
        pass

    @staticmethod
    def _stop_thread(thread):
        # [PyArmor BCC constants]: 'isRunning', 'quit', 'wait', 2000, 'RuntimeError', 'AttributeError'
        pass


# --- Class: UnifiedDownloader ---
class UnifiedDownloader(QThread):
    """
    Download update ZIP with retry, Range-resume, and hash verification.
    
        Bytes land in ``<target>.part``; the final name is claimed by an atomic
        rename only AFTER magic + SHA-256 verification. Because the exact final
        path is deterministic per (version, hash12) — see UpdateStateManager.package_path —
        a restarted session downloading the same release automatically resumes the
        leftover `.part` instead of refetching from zero. Corruption that sneaks
        past TCP cannot survive the mandatory hash gate: a bad hash drops the
        partial and forces one full-fresh pass before reporting failure.
    """
    CHUNK_SIZE = 524288
    MAX_RETRIES = 3
    staticMetaObject = PySide6.QtCore.QMetaObject("UnifiedDownloader" inherits "QThread":
Methods:
  #12 type=Signal, signature=progress_update...

    progress_updated = Signal()
    download_completed = Signal()
    download_failed = Signal()
    def __init__(self, url: str, filename: str, expected_hash: str | None = None, target_path: str | None = None, allow_exe: bool = False):
        pass

    def cancel(self):
        pass

    @property
    def part_suffix(self):
        pass

    def run(self):
        # [PyArmor BCC constants]: 'target_path', 'os', 'path', 'join', 'tempfile', 'gettempdir', 'filename', 'deliver', 'progress_updated', 'emit', 100, 'callable', 'tr', 'update_dialog.completed', 'Download complete'
        pass

    def deliver(self, file_path: str) -> bool:
        # [PyArmor BCC constants]: 'os', 'makedirs', 'path', 'dirname', 'abspath', 'exist_ok', True, 'part_suffix', 'exists', 'getsize', 0, 'log_debug', 'AutoUpdater download target=', ' url=', 'url'
        pass

    def _download_with_resume(self, part_path: str):
        # [PyArmor BCC constants]: 'range', 'MAX_RETRIES', 1, '_cancelled', 0, 'progress_updated', 'emit', 'Retry ', '/', '...', 'time', 'sleep', 'min', 2, 6
        pass

    def _download_once(self, part_path: str):
        # [PyArmor BCC constants]: 'os', 'path', 'exists', 'getsize', 0, 'range_header_for', 'requests', 'get', 'url', 'stream', True, 'timeout', 120, 'headers', 'status_code'
        pass

    def _fresh_redownload(self, part_path: str):
        # [PyArmor BCC constants]: '_safe_remove', '_speed_bps', '_download_once'
        pass

    def _verify_file(self, file_path: str):
        # [PyArmor BCC constants]: 'os', 'path', 'exists', 'getsize', 0, '_VerificationError', 'Downloaded file is empty or missing', 'open', 'rb', 'read', 4, 2, 'allow_exe', 'zipfile', 'is_zipfile'
        pass

    @staticmethod
    def _safe_remove(path: str):
        # [PyArmor BCC constants]: 'os', 'path', 'exists', 'remove', 'OSError'
        pass


# --- Class: UpdateStateManager ---
class UpdateStateManager:
    """Persist update state to survive app restarts."""
    STATE_FILE = 'C:\\Users\\vutru\\AppData\\Roaming\\VEO3_Generator_Pro\\pending_update.json'
    _LOCK = <unlocked _thread.RLock object owner=0 count=0 at 0x000001DF91AAF540>

    @classmethod
    def save_state(cls, **kwargs):
        # [PyArmor BCC constants]: 'datetime', 'items', 'setdefault', 'saved_at', 'now', 'isoformat', 'STATE_FILE', '.', 'os', 'getpid', 'threading', 'get_ident', '.tmp', '_LOCK', 'makedirs'
        pass

    @classmethod
    def load_state(cls):
        # [PyArmor BCC constants]: '_LOCK', 'os', 'path', 'exists', 'STATE_FILE', 'open', 'r', 'encoding', 'utf-8', 'json', 'load', 'isinstance', 'dict', 'OSError', 'JSONDecodeError'
        pass

    @classmethod
    def clear_state(cls, remove_artifacts=False):
        # [PyArmor BCC constants]: 'load_state', '_LOCK', 'os', 'path', 'exists', 'STATE_FILE', 'remove', 'OSError', '_remove_owned_artifacts'
        pass

    @classmethod
    def package_path(cls, filename, version='', file_hash=''):
        # [PyArmor BCC constants]: 'os', 'path', 'basename', 'str', '', 'replace', '\\', '/', 're', 'sub', '[^A-Za-z0-9._-]+', '_', 'lower', 'endswith', '.zip'
        pass

    @classmethod
    def state_version(cls, state):
        # [PyArmor BCC constants]: 'dict', 'str', 'get', 'version', '', 'strip', 'file_path', 'zip_path', 'os', 'path', 'isfile', '_read_update_archive_manifest', 'Exception'
        pass

    @classmethod
    def _remove_owned_artifacts(cls, state):
        # [PyArmor BCC constants]: 'os', 'path', 'realpath', 'tempfile', 'gettempdir', 'get', 'file_path', 'zip_path', 'staging_dir', 'list', 'str', '', 'strip', 'endswith', '.part'
        pass

    @classmethod
    def has_pending_install(cls):
        # [PyArmor BCC constants]: 'load_state', 'get', 'status', '', 'content_root', 'staging_dir', 'os', 'path', 'isdir', True, 'clear_state', 'remove_artifacts', 'downloaded', 'file_path', 'exists'
        pass

