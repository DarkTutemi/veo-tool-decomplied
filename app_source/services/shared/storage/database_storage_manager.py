"""
Decompiled / Reconstructed Module: services.shared.storage.database_storage_manager
Source PyC: database_storage_manager.pyc

Docstring:
Manage the movable SQLite database location for VEOFlow.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
DB_NAME = 'veoflow.db'

# --- Top-Level Functions ---
def default_database_dir() -> 'Path':
    pass

def current_database_path() -> 'Path':
    pass

def database_size_bytes(db_path: 'Path | None' = None) -> 'int':
    pass

def format_size(size: 'int') -> 'str':
    pass

def get_database_status() -> 'Dict[str, str]':
    pass

def migrate_database_to(target_dir: 'str') -> 'Path':
    pass

def vacuum_current_database() -> 'None':
    pass
