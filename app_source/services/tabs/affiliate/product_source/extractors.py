"""
Decompiled / Reconstructed Module: services.tabs.affiliate.product_source.extractors
Source PyC: extractors.pyc

Docstring:
Bóc data sản phẩm từ HTML trang — THUẦN, dependency-free (re/json/html stdlib).

Chiến thuật 3 tầng, ưu tiên bền nhất trước:

  1. JSON-LD schema.org/Product (``<script type="application/ld+json">``) — chuẩn
     e-commerce toàn cầu (Shopee/Lazada/Tiki/web shop riêng đều emit). Ít vỡ khi
     trang đổi giao diện vì là data có cấu trúc, không phải class DOM.
  2. Open Graph / Twitter meta (``og:title/og:image/product:price:amount``) — fallback
     phủ gần như mọi trang có share preview.
  3. Adapter theo domain (Shopee/TikTok) chỉ ĐÈ những gì generic bỏ sót: ảnh full-res
     (Shopee bỏ suffix ``_tn``), nhiều ảnh gallery, id sản phẩm/shop.

Trả về ``ProductExtract`` dict:
    {ok, source, url, name, price, description, image_urls[], category_hint,
     commission, error}

image_urls = ảnh ĐỘ PHÂN GIẢI CAO nhất tìm được (tối đa 10 — trần nano-banana sheet).
Không tự tải ảnh ở đây (browser layer lo); chỉ trả URL.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['extract_product', 'detect_source', 'SUPPORTED_HINTS', 'MAX_IMAGES', 'PRODUCT_EXTRACT_JS']

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
List = typing.List
Optional = typing.Optional
MAX_IMAGES = 10
SUPPORTED_HINTS = ('shopee', 'tiktok', 'lazada', 'tiki', 'web bất kỳ')
_NEXTDATA_RE = re.compile('<script[^>]+id=["\\\']__NEXT_DATA__["\\\'][^>]*>(.*?)</script>', re.IGNORECASE|re.DOTALL)
_NAME_KEYS = ('name', 'title', 'product_name', 'productName')
_PRICE_KEYS = ('price', 'sale_price', 'salePrice', 'list_price', 'listPrice', 'final_price', 'min_price')
_IMG_KEYS = ('images', 'image', 'gallery', 'image_urls', 'imageUrls', 'item_images', 'medias')
_DESC_KEYS = ('short_description', 'shortDescription', 'description', 'desc')
_LD_RE = re.compile('<script[^>]+type=["\\\']application/ld\\+json["\\\'][^>]*>(.*?)</script>', re.IGNORECASE|re.DOTALL)
PRODUCT_EXTRACT_JS = '\n() => {\n  const NAME=[\'name\',\'title\',\'product_name\',\'productName\'];\n  const PRICE=[\'price\',\'sale_price\',\'salePrice\',\'list_price\',\'listPrice\',\'final_price\',\'min_price\'];\n  c... [truncated]
__all__ = ['extract_product', 'detect_source', 'SUPPORTED_HINTS', 'MAX_IMAGES', 'PRODUCT_EXTRACT_JS']

# --- Top-Level Functions ---
def _text(value: 'Any') -> 'str':
    pass

def _clean_html(value: 'Any') -> 'str':
    pass

def _uniq(seq: 'List[str]') -> 'List[str]':
    pass

def detect_source(url: 'str') -> 'str':
    pass

def _looks_like_product(node: 'Dict[str, Any]') -> 'bool':
    pass

def _first_key(node: 'Dict[str, Any]', keys) -> 'Any':
    pass

def _norm_price(value: 'Any') -> 'str':
    pass

def _state_images(value: 'Any') -> 'List[str]':
    pass

def _walk_for_product(root: 'Any', max_depth: 'int' = 8) -> 'Dict[str, Any]':
    pass

def _from_state_json(html_text: 'str') -> 'Dict[str, Any]':
    pass

def _iter_ld_nodes(html_text: 'str'):
    """Yield mọi node dict trong các block JSON-LD (kể cả @graph lồng)."""
    pass

def _ld_is_product(node: 'Dict[str, Any]') -> 'bool':
    pass

def _ld_price(node: 'Dict[str, Any]') -> 'str':
    pass

def _ld_images(node: 'Dict[str, Any]') -> 'List[str]':
    pass

def _from_json_ld(html_text: 'str') -> 'Dict[str, Any]':
    pass

def _meta(html_text: 'str', *keys: 'str') -> 'str':
    pass

def _from_og(html_text: 'str') -> 'Dict[str, Any]':
    pass

def _merge(base: 'Dict[str, Any]', extra: 'Dict[str, Any]') -> 'Dict[str, Any]':
    pass

def _shopee_fullres(urls: 'List[str]') -> 'List[str]':
    pass

def _shopee_ids(url: 'str') -> 'Dict[str, str]':
    pass

def _apply_adapter(source: 'str', url: 'str', product: 'Dict[str, Any]', html_text: 'str') -> 'Dict[str, Any]':
    pass

def extract_product(url: 'str', html_text: 'str') -> 'Dict[str, Any]':
    pass
