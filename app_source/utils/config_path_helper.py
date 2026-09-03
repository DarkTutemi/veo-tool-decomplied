"""
Decompiled / Reconstructed Module: utils.config_path_helper

Docstring:
Config Path Helper - Unified path management for VEO3
Handles read-only bundled resources vs writable user data
"""

from __future__ import annotations
import sys, os, typing
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
Optional = typing.Optional
WRITABLE_CONFIGS = ['api_config.json', 'app_settings.json', 'accounts.json', 'license_cache.json']
EDITABLE_DATA = ['themes.json', 'strategies.json']
TEMPLATE_FILES = ['templates/storytelling.json']
READONLY_DATA = []

# --- Top-Level Functions ---
def get_bundled_resources_dir() -> pathlib.Path:
    # [PyArmor BCC constants]: 'find_resource_path', 'resources', 'getattr', 'sys', 'frozen', False, 'Path', 'executable', 'parent', '__file__'
    pass

def _verbose_init_logs() -> bool:
    # [PyArmor BCC constants]: 'os', 'environ', 'get', 'VEOFLOW_VERBOSE_INIT', '1'
    pass

def _platform_system_fast() -> str:
    # [PyArmor BCC constants]: 'os', 'name', 'nt', 'Windows', 'sys', 'platform', 'darwin', 'Darwin', 'Linux'
    pass

def get_default_writable_data_dir() -> pathlib.Path:
    # [PyArmor BCC constants]: '_platform_system_fast', 'Windows', 'os', 'getenv', 'APPDATA', 'path', 'expanduser', '~', 'Path', 'VEO3_Generator_Pro', 'Darwin', 'home', 'Library', 'Application Support', 'XDG_DATA_HOME'
    pass

def _database_storage_settings_path() -> pathlib.Path:
    pass

def get_database_dir() -> pathlib.Path:
    # [PyArmor BCC constants]: 'get_default_writable_data_dir', 'data', '_database_storage_settings_path', 'exists', 'json', 'loads', 'read_text', 'encoding', 'utf-8', 'str', 'get', 'database_dir', '', 'strip', 'Path'
    pass

def set_database_dir_override(database_dir: str) -> pathlib.Path:
    # [PyArmor BCC constants]: 'Path', 'expanduser', 'mkdir', 'parents', True, 'exist_ok', '_database_storage_settings_path', 'write_text', 'json', 'dumps', 'database_dir', 'str', 'ensure_ascii', False, 'indent'
    pass

def get_writable_data_dir() -> pathlib.Path:
    # [PyArmor BCC constants]: '_platform_system_fast', 'Windows', 'os', 'getenv', 'APPDATA', 'path', 'expanduser', '~', 'Path', 'VEO3_Generator_Pro', 'Darwin', 'home', 'Library', 'Application Support', 'XDG_DATA_HOME'
    pass

def get_config_file_path(filename: str, writable: bool = True) -> pathlib.Path:
    pass

def ensure_writable_file(filename: str, copy_from_bundled: bool = True) -> pathlib.Path:
    # [PyArmor BCC constants]: 'get_config_file_path', 'writable', True, 'exists', False, 'shutil', 'copy2', '_verbose_init_logs', 'print', '📋 Copied ', ' from bundled resources to ', '⚠️ Bundled ', ' not found at '
    pass

def get_data_file_path(filename: str, ensure_writable: bool = False) -> pathlib.Path:
    # [PyArmor BCC constants]: 'styles.json', 'get_builtin_json_path', 'ensure_writable_file', 'copy_from_bundled', True, 'get_config_file_path', 'writable', 'exists', False
    pass

def get_bundled_resource_path(relative_path: str) -> pathlib.Path:
    pass

def get_user_data_path(relative_path: str = '') -> pathlib.Path:
    pass

def get_runtime_resource_root() -> pathlib.Path:
    # [PyArmor BCC constants]: '_get_default_resource_base', 'os', 'getenv', 'LOCALAPPDATA', 'path', 'expanduser', '~', 'Path', 'VeoFlow', 'resources', 'mkdir', 'parents', True, 'exist_ok', 'Exception'
    pass

def get_builtin_json_path(filename: str) -> pathlib.Path:
    pass

def get_user_json_path(filename: str) -> pathlib.Path:
    pass

def get_custom_styles_path() -> pathlib.Path:
    # [PyArmor BCC constants]: 'get_writable_data_dir', 'qml_custom_styles.json', 'exists', 'find_resource_path', 'data/qml_custom_styles.json', 'Path', 'shutil', 'copy2', 'Exception'
    pass

def _sync_styles_json(bundled_dir: pathlib.Path, data_dir: pathlib.Path):
    pass

def _sync_styles_json_legacy_disabled(bundled_dir: pathlib.Path, data_dir: pathlib.Path):
    """Auto-sync Style Manager v3 data while preserving user custom_items."""
    # [PyArmor BCC constants]: 'techniques', 'materials', 'structural_styles', 'structural_cameras', 'surface_styles', 'surface_cameras', 'custom_frameworks'
    pass

def initialize_user_data():
    # [PyArmor BCC constants]: 'print', '=', 70, 'getattr', 'sys', 'frozen', False, 'EXE', 'DEV', '🔧 [INIT] Initializing user data directory (', ' mode)...', 'get_bundled_resources_dir', 'get_writable_data_dir', '📁 [INIT] Bundled resources: ', '📁 [INIT] AppData folder: '
    pass
