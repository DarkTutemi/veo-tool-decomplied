"""
Decompiled / Reconstructed Module: services.tabs.affiliate.import_library
Source PyC: import_library.pyc

Docstring:
On-demand projection of the durable Affiliate product library for Import UI.

The product library is history/deduplication state. Merely listing it must never
admit work; only ``reopen_products`` (called by an explicit Import gesture)
clears the completed-product gate.

Cleanup has a deliberately narrow ownership boundary:

* product rows and raw files under ``affiliate_products/staging`` belong here;
* completed/history rows in ``veoflow.db`` and final identity sheets in Media
  Library do not, so cleanup never deletes them.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)

# --- Top-Level Functions ---
def marketplace_ref(product: 'dict[str, Any]') -> 'tuple[str, str]':
    pass

def _existing_sources(product: 'dict[str, Any]') -> 'list[str]':
    pass

def _file_url(path: 'str') -> 'str':
    pass

def project_product(product: 'dict[str, Any]', *, completed: 'dict[str, set[str]] | None' = None) -> 'dict[str, Any]':
    """Create a QML-safe, blob-free row from one durable product record."""
    pass

def list_import_library(search: 'str' = '') -> 'list[dict[str, Any]]':
    pass

def reopen_products(product_ids: 'list[str]') -> 'dict[str, Any]':
    """Explicitly reopen selected products without deleting history or videos."""
    pass

def _normalized_path(path: 'Any') -> 'str':
    pass

def _inside_staging(path: 'Any', staging_root: 'Path') -> 'Path | None':
    pass

def _delete_orphan_staging_files(*, staging_root: 'Path', referenced_paths: 'set[str]') -> 'tuple[int, int, int]':
    """Delete unreferenced files and then empty directories inside staging."""
    pass

def cleanup_import_library(action: 'str', product_ids: 'list[str] | None' = None, *, protected_product_ids: 'list[str] | None' = None, search: 'str' = '') -> 'dict[str, Any]':
    pass
