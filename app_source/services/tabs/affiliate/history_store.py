"""
Decompiled / Reconstructed Module: services.tabs.affiliate.history_store
Source PyC: history_store.pyc

Docstring:
Affiliate business history projected into the shared History surface.

This store owns the compact, domain-specific record: product, marketplace links,
variant/publish kit and the final merged video. Scene prompts, reference assets and
regen payloads remain in canonical ``history_runs/history_items``.

Both are stored in ``veoflow.db``. Every compact upsert is also projected onto the
canonical run with the same ``batch_id`` so the user sees one Affiliate row in the
shared History tab instead of a second UI.

Bản ghi khoá theo `batch_id` (id hàng queue) → chạy lại/merge xong chỉ UPSERT, không đẻ
dòng trùng.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
List = typing.List
Optional = typing.Optional
MAX_ENTRIES = 500
_FIELDS = ('batch_id', 'product_id', 'product_name', 'product_image', 'price', 'product_url', 'affiliate_link', 'platform', 'shopee_item_id', 'tiktok_product_id', 'variant', 'variant_index', 'video_type', 'hook... [truncated]
_store = None
_store_lock = <unlocked _thread.lock object at 0x00000264E5146340>

# --- Class: AffiliateHistoryStore ---
class AffiliateHistoryStore:
    def __init__(self, db_path: 'str | Path | None' = None, legacy_dir: 'str | Path | None' = None) -> 'None':
        pass

    def _connect(self) -> "__assert_armored__((sqlite3, b'\\x81\\xa6\\x94\\x1bR\\xb4\\xfdR\\xbe&\\xa3'))":
        pass

    def _ensure_sqlite_schema(self) -> 'None':
        pass

    @staticmethod
    def _read_json_entries(path: 'Path') -> 'List[Dict[str, Any]]':
        pass

    def _migrate_legacy_files(self) -> 'None':
        pass

    def _repair_existing_state(self) -> 'None':
        pass

    def _load(self) -> 'List[Dict[str, Any]]':
        pass

    def _write(self, entries: 'List[Dict[str, Any]]') -> 'None':
        pass

    def _completed_path(self) -> 'Path':
        pass

    def _load_completed(self) -> 'Dict[str, set[str]]':
        pass

    def _write_completed(self, completed: 'Dict[str, set[str]]') -> 'None':
        pass

    def _reimport_path(self) -> 'Path':
        pass

    def _load_reimport_overrides(self) -> 'Dict[str, set[str]]':
        pass

    def _write_reimport_overrides(self, overrides: 'Dict[str, set[str]]') -> 'None':
        pass

    def _clear_reimport_overrides_locked(self, refs: 'List[tuple[str, str]]') -> 'None':
        pass

    @staticmethod
    def _completed_refs(entry: 'Dict[str, Any]') -> 'List[tuple[str, str]]':
        pass

    def _remember_completed_locked(self, entry: 'Dict[str, Any]', completed: 'Optional[Dict[str, set[str]]]' = None, *, historical: 'bool' = False, reimport_overrides: 'Optional[Dict[str, set[str]]]' = None) -> 'bool':
        pass

    def record(self, entry: 'Dict[str, Any]') -> 'Dict[str, Any]':
        pass

    def _sync_canonical_entry(self, entry: 'Dict[str, Any]') -> 'None':
        """Project Affiliate business context onto the unified History run."""
        pass

    def attach_video(self, output_folder: 'str', video_path: 'str', success: 'bool' = True) -> 'int':
        pass

    def completed_item_ids(self, platform: 'str') -> 'set[str]':
        pass

    def reimport_override_item_ids(self, platform: 'str') -> 'set[str]':
        pass

    def allow_reimport(self, platform: 'str', item_ids: 'Any') -> 'int':
        pass

    def remember_completed(self, platform: 'str', item_ids: 'Any', *, video_path: 'str' = '', batch_id: 'str' = '', historical: 'bool' = False) -> 'bool':
        pass

    def list_entries(self, limit: 'int' = 200) -> 'List[Dict[str, Any]]':
        pass

    def delete(self, batch_ids: 'Any') -> 'int':
        pass

    def clear(self) -> 'int':
        pass


# --- Top-Level Functions ---
def _text(value: 'Any') -> 'str':
    pass

def _integer(value: 'Any') -> 'int':
    pass

def _normalize_business_status(entry: 'Dict[str, Any]') -> 'str':
    pass

def _product_business_fields(product_id: 'str') -> 'Dict[str, Any]':
    pass

def _affiliate_history_title(entry: 'Dict[str, Any]', limit: 'int' = 120) -> 'str':
    pass

def get_affiliate_history_store() -> 'AffiliateHistoryStore':
    pass
