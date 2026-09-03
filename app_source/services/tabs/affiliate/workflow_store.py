"""
Decompiled / Reconstructed Module: services.tabs.affiliate.workflow_store
Source PyC: workflow_store.pyc

Docstring:
Durable Affiliate campaign/product/variant workflow state.

The shared prompt queue remains a compact dispatch adapter.  Expensive Affiliate
plans and their restart/idempotency state live here so progress updates do not
rewrite one ever-growing JSON document.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['ACTIVE_CAMPAIGN_STATES', 'AffiliateWorkflowStore', 'SUCCESS_VARIANT_STATES', 'TERMINAL_CAMPAIGN_STATES', 'TERMINAL_VARIANT_STATES', 'get_affiliate_workflow_store']

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
Iterable = typing.Iterable
List = typing.List
Optional = typing.Optional
SUCCESS_VARIANT_STATES = {'PUBLISH_READY', 'COMPLETE', 'PUBLISHED'}
TERMINAL_VARIANT_STATES = {'PUBLISH_READY', 'CANCELLED', 'COMPLETE', 'FAILED', 'PUBLISHED'}
TERMINAL_CAMPAIGN_STATES = {'CANCELLED', 'CAMPAIGN_COMPLETE', 'PARTIAL', 'FAILED'}
ACTIVE_CAMPAIGN_STATES = {'QUEUING', 'WAITING_QUEUE', 'CREATED', 'RUNNING', 'CAMPAIGN_RUNNING', 'PREPARING', 'CANCELLING'}
_STORE = None
_STORE_LOCK = <unlocked _thread.lock object at 0x00000264E58172C0>
__all__ = ['ACTIVE_CAMPAIGN_STATES', 'AffiliateWorkflowStore', 'SUCCESS_VARIANT_STATES', 'TERMINAL_CAMPAIGN_STATES', 'TERMINAL_VARIANT_STATES', 'get_affiliate_workflow_store']

# --- Class: AffiliateWorkflowStore ---
class AffiliateWorkflowStore:
    """Small connection-per-operation SQLite store, safe across worker threads."""
    def __init__(self, db_path: 'str | Path | None' = None, legacy_db_path: 'str | Path | None' = None) -> 'None':
        pass

    def _connect(self) -> "__assert_armored__((sqlite3, b'\\x81\\xa6\\x94\\x1bR\\xb4\\xfdR\\xbe&\\xa3'))":
        pass

    def _ensure_schema(self) -> 'None':
        pass

    def _migrate_legacy_database(self) -> 'None':
        """Copy the former standalone workflow DB into canonical veoflow.db.

        The old file is intentionally retained as a recovery backup.  INSERT OR
        IGNORE makes the migration restart-safe while every new write immediately
        goes to the shared database selected by ``get_database_dir()``."""
        pass

    def create_campaign(self, config: 'Dict[str, Any]', columns: 'Iterable[Dict[str, Any]]', *, campaign_id: 'str' = '') -> 'str':
        pass

    def set_campaign_state(self, campaign_id: 'str', state: 'str', error: 'str' = '') -> 'bool':
        pass

    def set_campaign_state_if_active(self, campaign_id: 'str', state: 'str', error: 'str' = '') -> 'bool':
        """Advance an active campaign without regressing a concurrent terminal update."""
        pass

    def request_cancel(self, campaign_id: 'str') -> 'bool':
        pass

    def is_cancel_requested(self, campaign_id: 'str') -> 'bool':
        pass

    def finalize_orchestration_cancel(self, campaign_id: 'str') -> 'None':
        pass

    def set_product_state(self, campaign_id: 'str', column_id: 'str', state: 'str', error: 'str' = '', *, increment_attempt: 'bool' = False) -> 'bool':
        pass

    def upsert_variants(self, campaign_id: 'str', column_id: 'str', product_id: 'str', variants: 'Iterable[Dict[str, Any]]') -> 'List[Dict[str, Any]]':
        pass

    def save_variant_package(self, variant_run_id: 'str', package: 'Dict[str, Any]', *, state: 'str' = 'PACKAGE_READY', allow_queued: 'bool' = False) -> 'bool':
        pass

    def mark_variant_submitted(self, variant_run_id: 'str', batch_id: 'str') -> 'bool':
        pass

    def set_variant_state(self, variant_run_id: 'str', state: 'str', error: 'str' = '') -> 'bool':
        pass

    def _refresh_parent_states_locked(self, conn: 'sqlite3.Connection', campaign_id: 'str', product_run_id: 'str', now: 'float') -> 'None':
        pass

    def _refresh_campaign_state_locked(self, conn: 'sqlite3.Connection', campaign_id: 'str', now: 'float') -> 'None':
        pass

    def get_variant(self, variant_run_id: 'str') -> 'Optional[Dict[str, Any]]':
        pass

    def get_variant_by_batch(self, batch_id: 'str') -> 'Optional[Dict[str, Any]]':
        pass

    def product_variants(self, campaign_id: 'str', column_id: 'str') -> 'List[Dict[str, Any]]':
        pass

    def campaign_payload(self, campaign_id: 'str') -> 'Optional[Dict[str, Any]]':
        pass

    def campaign_summary(self, campaign_id: 'str') -> 'Dict[str, Any]':
        pass

    def active_campaigns(self) -> 'List[Dict[str, Any]]':
        pass

    def tracking_product_ids(self) -> 'Dict[str, set[str]]':
        pass


# --- Top-Level Functions ---
def _json(value: 'Any') -> 'str':
    pass

def _object(value: 'Any', fallback: 'Any') -> 'Any':
    pass

def get_affiliate_workflow_store() -> 'AffiliateWorkflowStore':
    pass
