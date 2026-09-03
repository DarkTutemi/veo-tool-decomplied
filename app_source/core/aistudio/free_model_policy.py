"""
Decompiled / Reconstructed Module: core.aistudio.free_model_policy
Source PyC: free_model_policy.pyc

Docstring:
AI Studio live catalog observer for free-text quota routing.

Source of truth is live AI Studio data, refreshed on session warm / TTL /
quota exhaustion:

  POST MakerSuiteService/ListModels  (same cookies as the warm page)

Reverse-engineered live 2026-07-11 (Playwright, Ultra account):
  Each model record is a positional array; field index 77:
      2  → UI shows Paid badge (requires API key / paid plan for free playground)
      1  → free image-lite style
      null/absent → free text chat models
  The quota lane is exactly the live free generateContent Gemini text ids.
  Guessed ids that are missing or Paid are never merged in.

If Google renumbers the field, scrape still returns all ids; we re-detect by
comparing against a secondary signal (field 74 missing free-tier tag 10 for
plain text) and log a warning. DOM badge scrape remains a fallback.

Until the first successful scrape, a cached catalog (or a 3.6/3.5 bootstrap)
is used so generation still has a fallback.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Optional = typing.Optional
DEFAULT_TEXT_MODEL = 'gemini-3.6-flash'
_log = <Logger aistudio.free_model_policy (WARNING)>
PAID_BADGE_SELECTOR = '.badge.paid'
CATALOG_TTL_SEC = 21600
_CACHE_FILENAME = 'aistudio_text_catalog.json'
_cache_io_enabled = True
_cache_loaded = False
DEFAULT_FREE_MODEL = 'gemini-3.6-flash'
DEFAULT_FREE_IMAGE_MODEL = 'gemini-3.1-flash-lite-image'
LIST_MODELS_URL = 'https://alkalimakersuite-pa.clients6.google.com/$rpc/google.internal.alkali.applications.makersuite.v1.MakerSuiteService/ListModels'
API_KEY = 'AIzaSyDdP816MREB3SkjZO04QXbjsigfcI0GWOs'
ORIGIN = 'https://aistudio.google.com'
_IDX_PAID_ENUM = 77
_IDX_METHODS = 7
_IDX_DISPLAY = 3
_FREE_TIER_TAG = 10
_IDX_TAGS = 74
_SCRAPE_MODEL_CATALOG_JS_TMPL = '\nasync () => {\n  const out = { paid: [], free: [], titles: {}, error: null, signals: {} };\n  const ORIGIN = "https://aistudio.google.com";\n  const URL = __LIST_MODELS_URL__;\n  const API_KEY = __... [truncated]
SCRAPE_MODEL_CATALOG_JS = '\nasync () => {\n  const out = { paid: [], free: [], titles: {}, error: null, signals: {} };\n  const ORIGIN = "https://aistudio.google.com";\n  const URL = "https://alkalimakersuite-pa.clients6.goog... [truncated]
_CATALOG = FreeModelCatalog(paid_ids=set(), free_ids=[], titles={}, updated_at=0.0, source='empty', signals={})

# --- Class: FreeModelCatalog ---
class FreeModelCatalog:
    """FreeModelCatalog(paid_ids: 'set[str]' = <factory>, free_ids: 'list[str]' = <factory>, titles: 'dict[str, str]' = <factory>, updated_at: 'float' = 0.0, source: 'str' = 'empty', signals: 'dict[str, Any]' = <factory>, _lock: 'threading.RLock' = <factory>)"""
    updated_at = 0.0
    source = 'empty'

    def is_fresh(self, ttl: 'float' = 21600) -> 'bool':
        pass

    def apply_scan(self, data: 'dict[str, Any]') -> 'None':
        pass

    def is_paid(self, model: 'Optional[str]') -> 'bool':
        pass

    def pick_free(self, wanted: 'Optional[str]' = None, *, light: 'bool' = False, default: 'str' = 'gemini-3.6-flash') -> 'str':
        pass

    def __init__(self, paid_ids: 'set[str]' = <factory>, free_ids: 'list[str]' = <factory>, titles: 'dict[str, str]' = <factory>, updated_at: 'float' = 0.0, source: 'str' = 'empty', signals: 'dict[str, Any]' = <factory>, _lock: 'threading.RLock' = <factory>) -> None:
        pass

    def __repr__(self):
        pass


# --- Top-Level Functions ---
def _norm(model: 'str') -> 'str':
    pass

def _catalog_cache_path() -> 'Path':
    pass

def _write_catalog_cache(paid: 'set[str]', free_ids: 'list[str]', titles: 'dict[str, str]', signals: 'dict[str, Any]', quota_lane: 'tuple[str, ...]') -> 'None':
    pass

def load_cached_catalog() -> 'bool':
    pass

def ensure_cached_catalog() -> 'None':
    pass

def invalidate_catalog() -> 'None':
    pass

def get_catalog() -> 'FreeModelCatalog':
    pass

def _reset_catalog_for_tests() -> 'None':
    pass

def needs_refresh(ttl: 'float' = 21600) -> 'bool':
    pass

def update_catalog_from_scan(data: 'dict[str, Any]') -> 'bool':
    pass

def refresh_catalog_from_page_async(page) -> 'bool':
    pass

def refresh_catalog_from_page_sync(page) -> 'bool':
    pass

def is_paid_badge_model(model: 'Optional[str]') -> 'bool':
    pass

def ensure_free_aistudio_model(model: 'Optional[str]', *, default: 'str' = 'gemini-3.6-flash', light: 'bool' = False) -> 'str':
    pass

def ensure_free_aistudio_image_model(model: 'Optional[str]' = None) -> 'str':
    pass
