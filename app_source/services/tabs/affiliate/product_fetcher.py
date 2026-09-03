"""
Decompiled / Reconstructed Module: services.tabs.affiliate.product_fetcher
Source PyC: product_fetcher.pyc

Docstring:
Ingest 1 sản phẩm đã bóc (overlay/dán-link) → tải ảnh về temp → đổ pipeline cũ.

Dùng chung Mode A (dán link) + Mode B (overlay). Product dict = shape của
PRODUCT_EXTRACT_JS / extract_product: {name, price, image_urls[], description,
category_hint, brand, source, url}. Trả về ``{ok, name, price, paths[], meta}`` để
caller feed ``AffiliateUseCases.normalizeAndPrepareProduct(paths, name, category)`` —
name/price/mô tả LÀ DATA THẬT (không phải AI đoán), AI chỉ bổ sung nỗi đau/góc bán.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['ingest_product', 'download_images', 'fetch_images_from_browser', 'MAX_IMAGES', 'MAX_BROWSER_IMAGE_BYTES', 'MAX_BROWSER_PRODUCT_BYTES']

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
List = typing.List
MAX_IMAGES = 10
MAX_BROWSER_IMAGE_BYTES = 8388608
MAX_BROWSER_PRODUCT_BYTES = 41943040
_IMG_EXT = {'.png', '.jpg', '.jpeg', '.webp'}
_BROWSER_FETCH_IMAGE_JS = '\nasync ({ urls, maxBytes, maxTotalBytes }) => {\n  const sourceUrls = Array.isArray(urls) ? urls.map(String) : [];\n  const results = new Array(sourceUrls.length);\n  let cursor = 0;\n  let accepted... [truncated]
_BROWSER_PRELOAD_IMAGES_JS = '\nasync ({ urls }) => {\n  const sourceUrls = Array.isArray(urls) ? urls.map(String) : [];\n  const loaded = [];\n  await Promise.all(sourceUrls.map(url => new Promise(resolve => {\n    const image =... [truncated]
__all__ = ['ingest_product', 'download_images', 'fetch_images_from_browser', 'MAX_IMAGES', 'MAX_BROWSER_IMAGE_BYTES', 'MAX_BROWSER_PRODUCT_BYTES']

# --- Top-Level Functions ---
def _text(v: 'Any') -> 'str':
    pass

def _price_text(v: 'Any') -> 'str':
    pass

def _guess_ext(url: 'str', content_type: 'str') -> 'str':
    pass

def _is_decodable_image(path: 'str') -> 'bool':
    pass

def fetch_images_from_browser(page, urls: 'List[str]', *, account: 'str' = 'affiliate', dest_dir: 'str' = '', limit: 'int' = 10, max_image_bytes: 'int' = 8388608, max_product_bytes: 'int' = 41943040) -> 'Dict[str, Any]':
    """Lấy byte ảnh trong đúng tab marketplace rồi ghi vào vùng tạm của worker.

    ``cache: force-cache`` cho phép Chromium dùng lại HTTP cache mà trang vừa tải.
    Kết quả base64 chỉ đi trên Playwright transport của worker, được giải mã ngay;
    QML và WebSocket side-panel chỉ nhận path/metadata nhỏ."""
    pass

def download_images(urls: 'List[str]', *, dest_dir: 'str' = '', limit: 'int' = 10) -> 'List[str]':
    pass

def ingest_product(product: 'Dict[str, Any]', *, dest_dir: 'str' = '') -> 'Dict[str, Any]':
    pass
