"""
Decompiled / Reconstructed Module: services.automation_center.reference_packs
Source PyC: reference_packs.pyc

Docstring:
Immutable reference packs for local channel planning.

Reference packs own operator-supplied research inputs.  They do not browse,
scrape, execute a workflow, or publish.  Every update creates an immutable
revision so a Channel Copilot revision can freeze the exact evidence set it
used while planning.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['ReferencePackStore', 'normalize_reference_pack']

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
UTC = datetime.timezone.utc
Iterator = typing.Iterator
MAX_BATCH_SOURCES = 200
_MAX_SNAPSHOT_BYTES = 33554432
__all__ = ['ReferencePackStore', 'normalize_reference_pack']

# --- Class: ReferencePackStore ---
class ReferencePackStore:
    """SQLite source of truth for immutable research-pack revisions."""
    def __init__(self, database_path: 'str | Path') -> 'None':
        pass

    def _connect(self) -> "Iterator[__assert_armored__((sqlite3, b'\\x81\\xa6\\x94\\x1bR\\xb4\\xfdR\\xbe&\\xa3'))]":
        pass

    def _initialize(self) -> 'None':
        pass

    def upsert(self, value: 'Mapping[str, Any]') -> 'dict[str, Any]':
        pass

    def append_sources(self, reference_pack_id: 'str', sources: 'Sequence[Mapping[str, Any]]') -> 'dict[str, Any]':
        pass

    def get(self, reference_pack_id: 'str', *, version: 'int' = 0) -> 'dict[str, Any]':
        pass

    def list(self) -> 'list[dict[str, Any]]':
        pass


# --- Top-Level Functions ---
def _utc_now() -> 'str':
    pass

def _bounded_text(value: 'Any', field: 'str', maximum: 'int', *, required: 'bool' = False) -> 'str':
    pass

def _canonical_json(value: 'Any') -> 'str':
    pass

def _normalize_source(value: 'Mapping[str, Any]') -> 'dict[str, Any]':
    pass

def normalize_reference_pack(value: 'Mapping[str, Any]') -> 'dict[str, Any]':
    pass
