"""
Decompiled / Reconstructed Module: update.auto_updater

Docstring:
VEO3 Tool - Auto Updater
Non-blocking update checker, downloader, and installer launcher.

Architecture:
  - UpdateChecker(QThread)    — background version check
  - UnifiedDownloader(QThread)— download with retry, resume, hash verification
  - UpdateStateManager        — persist download state across app restarts
  - apply_update()            — extract update zip, launch updater.exe to apply
  - apply_pending_update()    — check for failed update on startup
  - AutoUpdater               — orchestrator (main thread, non-blocking)
"""

from __future__ import annotations
import sys, os, typing
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
MAX_RESUME_ATTEMPTS = 2
_NETWORK_ERRORS = (<class 'requests.exceptions.ConnectionError'>, <class 'requests.exceptions.ChunkedEncodingError'>, <class 'requests.exceptions.Timeout'>, <class 'ConnectionResetError'>)

# --- Class: UpdateChecker ---
class UpdateChecker(QThread):
    """Check server for new version (runs in background thread)."""
    staticMetaObject = PySide6.QtCore.QMetaObject("UpdateChecker" inherits "QThread":
Methods:
  #12 type=Signal, signature=update_available(QV...

    update_available = Signal()
    no_update = Signal()
    error_occurred = Signal()
    def __init__(self, current_version=None):
        pass

    def run(self):
        # [PyArmor BCC constants]: 'get_license_manager', 'check_version', 'current_version', 'log_debug', 'AutoUpdater version-check ok=', ' keys=', 'isinstance', 'dict', 'list', 'keys', 'tag', 'UPDATER', 'RuntimeError', 'get', 'error'
        pass


# --- Class: _DownloadError ---
class _DownloadError(Exception):
    """Internal exception for download or verification failures."""
    pass


# --- Class: _VerificationError ---
class _VerificationError(_DownloadError):
    """Integrity failure (bad magic / SHA-256 mismatch) — partial must be dropped."""
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


# --- Top-Level Functions ---
def _first_non_empty(*values):
    # [PyArmor BCC constants]: 'isinstance', 'str', 'strip', ''
    pass

def _normalize_update_info(raw: dict) -> dict:
    # [PyArmor BCC constants]: 'dict', '_first_non_empty', 'get', 'download_url', 'url', 'changelog', 'release_notes', 'file_hash', 'sha256', 'latest_version', 'version', 'file_name', 'filename', 'isinstance', 'str'
    pass

def _normalize_sha256(value):
    # [PyArmor BCC constants]: 'str', 'strip', 'lower', 'startswith', 'sha256:', 'split', ':', 1
    pass

def _version_parts(value):
    """Return a comparable numeric version tuple used by update state guards."""
    pass

def _compare_versions(left, right):
    # [PyArmor BCC constants]: 'list', '_version_parts', 'str', '', 'strip', 'lower', 'max', 'len', 'extend', 0
    pass

def delta_applies_to_current(base_version, current_version) -> bool:
    # [PyArmor BCC constants]: 'str', '', 'strip', True, False, '_compare_versions', 0
    pass

def pending_download_action(pending, latest_version, current_version, file_exists=None, staging_exists=None) -> str:
    # [PyArmor BCC constants]: 'dict', 'str', 'get', 'status', '', 'strip', 'lower', 'download', 'version', 'file_path', 'zip_path', 'bool', 'os', 'path', 'isfile'
    pass

def _is_installer_package(path) -> bool:
    # [PyArmor BCC constants]: 'str', '', 'lower', 'endswith', '.exe', True, 'open', 'rb', 'read', 2, False, 'OSError'
    pass

def installer_launch_argv(exe_path, install_dir):
    # [PyArmor BCC constants]: 'str', '/VERYSILENT', '/NORESTART', '/SUPPRESSMSGBOXES', '/DIR='
    pass

def _read_update_archive_manifest(zip_path):
    # [PyArmor BCC constants]: 'zipfile', 'is_zipfile', 'ZipFile', 'r', 'namelist', 'sorted', 'replace', '\\', '/', 'rstrip', 'endswith', '/manifest.json', 'manifest.json', 'ValueError', 'Update package must contain a payload manifest.json; found 0'
    pass

def range_header_for(existing_bytes: int) -> dict:
    # [PyArmor BCC constants]: 0, 'Range', 'bytes=', 'int', '-'
    pass

def resolve_range_plan(status_code: int, resume_requested: bool) -> str:
    # [PyArmor BCC constants]: 206, 'append', 200, 'restart', 'error'
    pass

def format_download_progress(downloaded: int, total: int, speed_bps: float | None = None) -> str:
    # [PyArmor BCC constants]: 'max', 0.0, 'float', 1024, 0, '.1f', ' MB', ' / ', 'int', ' • ', ' MB/s • còn ', 's'
    pass

def _find_updater_exe():
    # [PyArmor BCC constants]: 'str', 'getattr', 'sys', '_MEIPASS', '', 'append', 'os', 'path', 'join', 'resources', 'bin', 'updater.exe', 'frozen', False, 'dirname'
    pass

def _validate_update_manifest(staging_dir: str, version: str = '') -> dict:
    # [PyArmor BCC constants]: 'os', 'path', 'join', 'manifest.json', 'exists', 'ValueError', 'Invalid update package: manifest.json not found', 'open', 'r', 'encoding', 'utf-8', 'json', 'load', 'get', 'schema'
    pass

def _legacy_apply_update_unused(zip_path, version='', parent_window=None):
    # [PyArmor BCC constants]: 'os', 'path', 'join', 'tempfile', 'gettempdir', 'veoflow_update_staging', 'exists', 'shutil', 'rmtree', 'ignore_errors', True, 'log_debug', 'AutoUpdater apply_update zip=', 'tag', 'UPDATER'
    pass

def _legacy_apply_pending_update_unused():
    # [PyArmor BCC constants]: 'UpdateStateManager', 'load_state', False, 'get', 'status', '', 'apply_failed', 'error', 'Unknown error', 'log_crash', 'AutoUpdater apply failed from pending state', 'state', 'clear_state'
    pass

def _prepare_update_package(zip_path, version=''):
    # [PyArmor BCC constants]: 'log_debug', 'AutoUpdater apply_update zip=', 'tag', 'UPDATER', 'zipfile', 'is_zipfile', 'ValueError', 'Not a valid ZIP file: ', 'tempfile', 'mkdtemp', 'prefix', 'veoflow_update_staging_', 'ZipFile', 'r', 'os'
    pass

def _launch_updater(content_root, zip_path='', parent_window=None):
    # [PyArmor BCC constants]: 'os', 'path', 'isdir', 'FileNotFoundError', 'Update staging directory not found: ', '_validate_update_manifest', 'join', 'resources', 'bin', 'updater.exe', 'exists', '_find_updater_exe', 'log_crash', 'AutoUpdater updater.exe missing', 'zip_path'
    pass

def _launch_installer(exe_path, parent_window=None):
    # [PyArmor BCC constants]: 'os', 'path', 'isfile', 'FileNotFoundError', 'Installer not found: ', 'getattr', 'sys', 'frozen', False, 'dirname', 'executable', 'getcwd', 'installer_launch_argv', 'log_debug', 'AutoUpdater launching installer exe='
    pass

def apply_installer(exe_path, version=''):
    # [PyArmor BCC constants]: 'UpdateStateManager', 'save_state', 'status', 'applying', 'version', 'str', '', 'strip', 'file_path', 'package_kind', 'installer', '_launch_installer', 'apply_failed', 'error', 'Exception'
    pass

def apply_update(zip_path, version='', parent_window=None):
    # [PyArmor BCC constants]: '_is_installer_package', 'apply_installer', '_prepare_update_package', 'str', 'manifest', 'get', 'version', '', 'strip', 'UpdateStateManager', 'save_state', 'status', 'applying', 'file_path', 'zip_path'
    pass

def apply_pending_update():
    # [PyArmor BCC constants]: 'UpdateStateManager', 'load_state', False, 'get', 'status', '', 'state_version', 'str', 'VEO3Config', 'TOOL_VERSION', 'strip', '_compare_versions', 0, 'log_debug', 'AutoUpdater discarding stale pending target='
    pass
