"""
Decompiled / Reconstructed Module: services.tabs.affiliate.product_browser
Source PyC: product_browser.pyc

Docstring:
Browser cho affiliate link-import — profile RIÊNG, tách farm/aistudio.

Dùng BrowserManager sẵn có nhưng thư mục profile riêng
(``browser_profiles_affiliate``) để cookie đăng nhập Shopee/TikTok của user PERSIST,
không bị farm kill/restart đụng vào (mô phỏng đúng pattern get_aistudio_browser_manager).

  · ``start_browse`` — Chrome THẬT (headed) để user đăng nhập + lướt (Mode B).
  · ``start_fetch``  — nền (headless=new) để fetch dán-link (Mode A); CHUNG profile
    nên thừa hưởng cookie login của lần browse.
  · ``dump_page_structure`` — soi 1 trang: JSON-LD / og / state-global / ảnh mẫu +
    chạy thử extractor hiện tại (gap analysis). Dùng bởi scripts/affiliate_probe.py.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['get_affiliate_browser_manager', 'start_browse', 'start_fetch', 'new_page', 'current_page', 'run_page_action', 'open_import_browse', 'fetch_product_by_link', 'dump_page_structure']

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Callable = typing.Callable
Dict = typing.Dict
List = typing.List
Optional = typing.Optional
_manager = None
_lock = <unlocked _thread.lock object at 0x00000264E5175E40>
_ACCOUNT = 'affiliate'
DEFAULT_ACCOUNT = 'affiliate'
MARKETPLACE_URLS = {'shopee': 'https://affiliate.shopee.vn/offer/product_offer', 'tiktok': 'https://shop.tiktok.com/streamer/showcase/product/list'}
_DEFAULT_MARKETPLACE = 'https://affiliate.shopee.vn/offer/product_offer'
_running_mode = {}
_login_return_lock = <unlocked _thread.lock object at 0x00000264E51749C0>
_login_return_stops = {}
_LOGIN_RETURN_PREAUTH_WATCH_S = 45.0
_LOGIN_RETURN_AUTH_TIMEOUT_S = 900.0
_LOGIN_RETURN_TARGET_STABLE_S = 12.0
_LOGIN_RETURN_POLL_S = 1.0
_ACCOUNTS_FILE = 'browser_accounts.json'
_POLL_INTERVAL_S = 1.2
_DRAIN_JS = '() => { const q = window.__vfImportQ || []; window.__vfImportQ = []; return q; }'
_poll_stop = None
_PUSH_JS = '(msg) => { try { window.__vf && window.__vf.recv(msg); return true; } catch (e) { return false; } }'
_WHOAMI_JS = '\n() => {\n  const host = location.hostname || \'\';\n  const path = (location.pathname || \'\') + (location.search || \'\');\n  const marker = host + path;\n  const isLogin = /login|passport|\\/buye... [truncated]
_DUMP_JS = '\n() => {\n  const pick = (sel, attr) => Array.from(document.querySelectorAll(sel))\n      .map(e => e.getAttribute(attr)).filter(Boolean);\n  const meta = {};\n  document.querySelectorAll(\'meta[pro... [truncated]
__all__ = ['get_affiliate_browser_manager', 'start_browse', 'start_fetch', 'new_page', 'current_page', 'run_page_action', 'open_import_browse', 'fetch_product_by_link', 'dump_page_structure']

# --- Top-Level Functions ---
def _text(value: 'Any') -> 'str':
    pass

def resolve_marketplace_url(target: 'str' = '') -> 'str':
    pass

def _accounts_file():
    pass

def list_accounts() -> 'List[Dict[str, str]]':
    pass

def channels_status() -> 'Dict[str, bool]':
    pass

def add_account(label: 'str') -> 'Dict[str, Any]':
    """Thêm kênh: label bố gõ ('Kênh 2') → key slug an toàn làm TÊN THƯ MỤC profile.
    Trùng label cũ → trả kênh cũ (idempotent), không đẻ profile mới."""
    pass

def get_affiliate_browser_manager():
    pass

def _cached_browser_definitely_dead(manager, account: 'str') -> 'bool':
    pass

def _start_in_mode(account: 'str', *, headless: 'bool', initial_url: 'Optional[str]' = None) -> 'bool':
    pass

def start_browse(initial_url: 'str' = 'https://affiliate.shopee.vn/offer/product_offer', account: 'str' = 'affiliate') -> 'bool':
    pass

def start_fetch(account: 'str' = 'affiliate') -> 'bool':
    pass

def new_page(url: 'Optional[str]' = None, account: 'str' = 'affiliate'):
    pass

def current_page(account: 'str' = 'affiliate'):
    pass

def rotate_fingerprint(account: 'str' = 'affiliate') -> 'int':
    pass

def run_page_action(page, action: 'Callable', timeout: 'float' = 60.0, account: 'str' = 'affiliate'):
    pass

def _probe_login(page, account: 'str') -> 'Dict[str, Any]':
    pass

def _normalized_url_parts(value: 'str'):
    pass

def _target_url_reached(current_url: 'str', target_url: 'str') -> 'bool':
    pass

def _same_marketplace_family(current_url: 'str', target_url: 'str') -> 'bool':
    pass

def _url_looks_like_login(value: 'str') -> 'bool':
    pass

def _start_post_login_return_monitor(page, account: 'str', target_url: 'str', on_ready: 'Optional[Callable[[], None]]' = None) -> 'None':
    pass

def _marketplace_id(product: 'Dict[str, Any]', platform: 'str') -> 'str':
    pass

def _workflow_marketplace_policy(products: 'List[Dict[str, Any]]', platform: 'str') -> 'Dict[str, List[str]]':
    pass

def _shopee_offer_policy() -> 'Dict[str, Any]':
    pass

def _tiktok_showcase_policy() -> 'Dict[str, Any]':
    pass

def _broadcast_marketplace_policies() -> 'None':
    pass

def _exclude_completed_products(products: 'List[Dict[str, Any]]') -> 'tuple[List[Dict[str, Any]], int]':
    pass

def _route_overlay_message(data, account, on_product, on_message, push, push_hello):
    pass

def open_import_browse(on_product: 'Callable[[Dict[str, Any]], None]', initial_url: 'str' = 'https://affiliate.shopee.vn/offer/product_offer', account: 'str' = 'affiliate', on_message: 'Optional[Callable[[str, Dict[str, Any], Callable], None]]' = None, use_side_panel: 'Optional[bool]' = None) -> 'Dict[str, Any]':
    """Mở browser Affiliate với native Side Panel (mặc định) hoặc overlay dự phòng.

    BRIDGE 2 CHIỀU:
      - Overlay → App: message typed đẩy vào __vfImportQ; poll thread drain + route.
      - App → Overlay: ``push(type, payload)`` gọi window.__vf.recv trên trang.

    ``on_product(product_dict)`` gọi cho mỗi SP trong IMPORT_PRODUCTS (giữ nguyên hợp
    đồng cũ — caller marshal về GUI, Law 1/3). ``on_message(type, payload, push)`` (tuỳ
    chọn) nhận các message khác (HARVEST_START/LINKS_CREATE/ORDERS_FETCH/…) để controller
    tự wire dịch vụ tương ứng; ``push`` đẩy state ngược overlay. CONNECTION + CHANNELS
    được đẩy tự động khi overlay báo OVERLAY_READY."""
    pass

def fetch_product_by_link(url: 'str', account: 'str' = 'affiliate') -> 'Dict[str, Any]':
    pass

def dump_page_structure(page) -> 'Dict[str, Any]':
    pass
