"""
Decompiled / Reconstructed Module: services.tabs.affiliate.product_source.overlay
Source PyC: overlay.pyc

Docstring:
VeoFlow Studio — overlay điều khiển in-page cho TikTok/Shopee (bản 2.0, 23/7/2026).

Thay bản form-import 1 màn (bố: "overlay xấu quá, thiếu chuyên nghiệp"). Đây là một
panel điều khiển đa-tab, dựng trong SHADOW DOM (CSS sàn không lọt vào), có token
design riêng, kéo-thả + thu gọn, và BRIDGE 2 CHIỀU với app.

## Kiến trúc
- `build_overlay_script()` trả init-script tự cài: tạo host → attachShadow → render app.
- **Bridge 2 chiều** `window.__vf`:
  - Overlay → App: `__vf.send(type, payload)` đẩy JSON vào `window.__vfImportQ`
    (poll thread trong `product_browser.open_import_browse` drain — giữ nguyên cơ chế
    PULL vì Playwright sync worker không nhận `expose_function`).
  - App → Overlay: Python gọi `page.evaluate("window.__vf.recv(<json>)")` mỗi nhịp
    poll để ĐẨY state vào overlay (tiến độ cào, đơn hàng, kết quả link…).
  - Protocol: `{v:2, id, type, payload, ok}`.
- 5 tab: Sản phẩm · Cào tự động · Link · Đơn hàng · Cài đặt.

## Message types (hợp đồng app ↔ overlay)
Overlay → App: `IMPORT_PRODUCTS` · `HARVEST_START` · `HARVEST_STOP` · `LINKS_CREATE`
  · `ORDERS_FETCH` · `EXPORT_SAVE` · `CACHE_FORGET` · `CHANNEL_PICK`
App → Overlay: `HARVEST_PROGRESS` · `HARVEST_ITEM` · `LINKS_RESULT` · `ORDERS_DATA`
  · `CHANNELS` · `CONNECTION` · `TOAST`

Front-end THUẦN vanilla (không framework, không CDN) — bơm qua CDP nên vượt CSP sàn,
chạy mọi trang. Đẹp đến từ token + component + micro-interaction, không phải string vá.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['build_overlay_script', '_OVERLAY_APP_JS']

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
PRODUCT_EXTRACT_JS = '\n() => {\n  const NAME=[\'name\',\'title\',\'product_name\',\'productName\'];\n  const PRICE=[\'price\',\'sale_price\',\'salePrice\',\'list_price\',\'listPrice\',\'final_price\',\'min_price\'];\n  c... [truncated]
_OVERLAY_APP_JS = '\n(() => {\n  if (window.__veoflowOverlayInstalled) return;\n  window.__veoflowOverlayInstalled = true;\n\n  /* ═══════════════ BRIDGE 2 CHIỀU ═══════════════ */\n  const BRIDGE = window.__vf = windo... [truncated]
__all__ = ['build_overlay_script', '_OVERLAY_APP_JS']

# --- Top-Level Functions ---
def build_overlay_script() -> 'str':
    pass
