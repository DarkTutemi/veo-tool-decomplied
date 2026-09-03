"""
Decompiled / Reconstructed Module: services.tabs.affiliate.tiktok_showcase
Source PyC: tiktok_showcase.pyc

Docstring:
Nguồn SP từ TIKTOK SHOP SHOWCASE — danh sách SP user ĐÃ GẮN (bố chỉ 22/7).

Vì sao lấy ở đây (thay vì lướt shop ngoài): showcase **sync với điện thoại**, và khi
đăng video xong bố chỉ việc chọn SP có sẵn trong showcase để gắn — khỏi đi tìm lại
ngoài shop rồi gán thủ công.

Trang: https://shop.tiktok.com/streamer/showcase/product/list (Streamer Desktop)
API (soi bằng CDP 22/7, KHÔNG hook JS):
    GET /api/v1/streamer_desktop/showcase_product/list?count=20&offset=0&origin=2
    → {code:0, data:{products:[...], total:N}}
Mỗi product có sẵn: product_id · title · format_available_price · seller_info.shop_name
    · cover + images[] (nhiều ảnh) · affiliate_info (hoa hồng) · category_info · stock_num

Gọi IN-PAGE trên shop.tiktok.com (cùng origin, đi qua lớp ký của site) — cùng lý do
với Shopee `batchCustomLink`. Trả về HÀNG theo schema cổng import chung (bảng 7 cột)
nên đổ thẳng vào `importAffiliateProductsAsync` được, không cần đường riêng.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['harvest_showcase', 'fetch_showcase_products', 'fetch_product_description', 'fetch_showcase_product_details', 'fetch_selected_showcase_products', 'manage_showcase_products', 'product_to_row', 'load_harvested', 'mark_harvested', 'forget_harvested', 'SHOWCASE_URL', 'PRODUCT_URL_TMPL', 'MAX_IMPORT_SELECTION']

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
List = typing.List
SHOWCASE_URL = 'https://shop.tiktok.com/streamer/showcase/product/list'
_HOST = 'shop.tiktok.com'
PRODUCT_URL_TMPL = 'https://shop.tiktok.com/vn/pdp/{pid}'
MAX_IMAGES = 10
PAGE_SIZE = 20
MAX_SHOWCASE_PRODUCTS = 2000
MAX_IMPORT_SELECTION = 20
_TPLV_RE = re.compile('~tplv-([A-Za-z0-9]+)-[^.]+\\.(?:jpeg|jpg|webp|png)')
_ORIGIN_TPL = '~tplv-\\1-origin-image.jpeg'
_FETCH_JS = "\nasync (opts) => {\n  const { limit, pageSize } = opts;\n  const out = []; let total = -1; let offset = 0;\n  while (out.length < limit) {\n    const path = `/api/v1/streamer_desktop/showcase_produc... [truncated]
_MANAGE_JS = "\nasync (opts) => {\n  const ids = (opts.productIds || []).map(String).filter(Boolean).slice(0, 100);\n  if (!ids.length) return { error: 'no_product_ids' };\n  const action = String(opts.action || '... [truncated]
_PDP_JS = '\nasync ({ url, productId }) => {\n  const ctl = new AbortController();\n  const timer = setTimeout(() => ctl.abort(), 25000);\n  let response, html = \'\';\n  try {\n    response = await fetch(url, ... [truncated]
_CACHE_NAME = 'tiktok_harvested.json'
_CACHE_LOCK = <unlocked _thread.lock object at 0x00000264E520C940>
__all__ = ['harvest_showcase', 'fetch_showcase_products', 'fetch_product_description', 'fetch_showcase_product_details', 'fetch_selected_showcase_products', 'manage_showcase_products', 'product_to_row', 'load_h... [truncated]

# --- Top-Level Functions ---
def _text(v: 'Any') -> 'str':
    pass

def _full_res(url: 'str') -> 'str':
    pass

def _is_tiktok_product_image_url(url: 'str') -> 'bool':
    pass

def _image_urls(product: 'Dict[str, Any]') -> 'List[str]':
    pass

def _commission(product: 'Dict[str, Any]') -> 'str':
    pass

def _description(product: 'Dict[str, Any]') -> 'str':
    """Tận dụng mô tả nếu TikTok đã nhúng trong row API (schema thay đổi theo region)."""
    pass

def _clean_pdp_description(value: 'Any') -> 'str':
    pass

def _factual_description(row: 'Dict[str, Any]') -> 'str':
    """Fallback trung thực khi API showcase/PDP không trả mô tả gốc."""
    pass

def product_to_row(product: 'Dict[str, Any]') -> 'Dict[str, Any]':
    pass

def manage_showcase_products(product_ids, *, action: 'str', account: 'str' = '', page=None, source_map: 'Dict[str, Any] | None' = None, delete_confirmation: 'str' = '') -> 'Dict[str, Any]':
    """Ẩn/hiện/xóa SP qua API TikTok ngay trong tab hiện tại.

    Xóa là irreversible nên backend yêu cầu token ``DELETE:<count>`` ngoài xác nhận UI."""
    pass

def fetch_product_description(product_id: 'str', *, account: 'str' = '', page=None) -> 'Dict[str, Any]':
    """Fetch + parse PDP ngay trong tab TikTok hiện tại, tuyệt đối không mở/goto tab."""
    pass

def fetch_showcase_product_details(product: 'Dict[str, Any]', *, account: 'str' = '', page=None) -> 'Dict[str, Any]':
    pass

def fetch_selected_showcase_products(products, *, account: 'str' = '', page=None, progress=None) -> 'Dict[str, Any]':
    pass

def _cache_file():
    pass

def load_harvested() -> 'Dict[str, Any]':
    pass

def mark_harvested(product_id: 'str', name: 'str' = '') -> 'None':
    pass

def forget_harvested(product_ids=None) -> 'int':
    pass

def harvest_showcase(limit: 'int' = 50, *, skip_known: 'bool' = True, on_product=None, on_progress=None, account: 'str' = '', cancel_check=None) -> 'Dict[str, Any]':
    pass

def fetch_showcase_products(limit: 'int' = 50, *, account: 'str' = '') -> 'Dict[str, Any]':
    pass
