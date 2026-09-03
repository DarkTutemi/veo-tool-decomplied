"""
Decompiled / Reconstructed Module: services.tabs.affiliate.shopee_offer_service
Source PyC: shopee_offer_service.pyc

Docstring:
Đọc Shopee Product Offer bằng API của chính trang affiliate.

Luồng này cố ý chạy trong tab ``affiliate.shopee.vn`` đang mở: cookie và lớp ký
request của Shopee được giữ nguyên, không mở PDP/tab mới và không dùng requests.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['MAX_SELECTION', 'MAX_CATALOG', 'fetch_offer_catalog', 'fetch_offer_details', 'normalize_offer_record', 'fetch_selected_offers']

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Callable = typing.Callable
Dict = typing.Dict
Iterable = typing.Iterable
List = typing.List
urlsplit = <functools._lru_cache_wrapper object at 0x00000264D08DE6C0>
MAX_SELECTION = 20
MAX_CATALOG = 500
_IMAGE_BASE = 'https://down-vn.img.susercontent.com/file/'
_FETCH_CATALOG_JS = '\nasync ({ listUrl, keyword, maxItems }) => {\n  const fallback = "/api/v3/offer/product/list?list_type=0&sort_type=1&page_offset=0&page_limit=20&client_type=1";\n  let seed;\n  try {\n    seed = new... [truncated]
_FETCH_SELECTED_JS = '\nasync ({ ids, listUrl, seedRows }) => {\n  const parseBody = (value) => {\n    if (typeof value !== "string") return value || {};\n    try { return JSON.parse(value); } catch { return {}; }\n  };\n... [truncated]
__all__ = ['MAX_SELECTION', 'MAX_CATALOG', 'fetch_offer_catalog', 'fetch_offer_details', 'normalize_offer_record', 'fetch_selected_offers']

# --- Top-Level Functions ---
def _catalog_page_key(value: 'Any') -> 'tuple[str, str]':
    pass

def _live_page_url(page: 'Any') -> 'str':
    pass

def _resolve_catalog_page(page: 'Any', requested_url: 'str' = '') -> 'Any':
    pass

def _is_navigation_context_error(exc: 'Exception') -> 'bool':
    pass

def _evaluate_catalog_page(page: 'Any', requested_url: 'str', payload: 'Dict[str, Any]') -> 'Any':
    pass

def _text(value: 'Any') -> 'str':
    pass

def _first_dict(value: 'Any') -> 'Dict[str, Any]':
    pass

def _deep_first(value: 'Any', keys: 'Iterable[str]') -> 'Any':
    """Find the first non-empty value under likely detail keys."""
    pass

def _rate(value: 'Any') -> 'float':
    pass

def _price(value: 'Any') -> 'str':
    pass

def _float(value: 'Any') -> 'float':
    pass

def _int(value: 'Any') -> 'int':
    pass

def _image_url(value: 'Any') -> 'str':
    pass

def normalize_offer_record(record: 'Dict[str, Any]', *, dom_row: 'Dict[str, Any] | None' = None, affiliate_link: 'str' = '', account: 'str' = '') -> 'Dict[str, Any]':
    pass

def fetch_offer_catalog(page, *, list_api_url: 'str' = '', page_url: 'str' = '', keyword: 'str' = '', max_items: 'int' = 500, account: 'str' = 'affiliate') -> 'Dict[str, Any]':
    pass

def fetch_offer_details(page, selections: 'List[Dict[str, Any]]', *, list_api_url: 'str' = '', account: 'str' = 'affiliate', progress: 'Callable[[int, int, str], None] | None' = None) -> 'Dict[str, Any]':
    """Fetch full detail for selected rows in-place, without creating affiliate links."""
    pass

def fetch_selected_offers(page, selections: 'List[Dict[str, Any]]', *, list_api_url: 'str' = '', account: 'str' = 'affiliate', progress: 'Callable[[int, int, str], None] | None' = None) -> 'Dict[str, Any]':
    """Detail first, then one batchCustomLink call for all importable products."""
    pass
