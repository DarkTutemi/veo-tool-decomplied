"""
Decompiled / Reconstructed Module: services.tabs.affiliate.product_source.__init__
Source PyC: __init__.pyc

Docstring:
Nguồn sản phẩm từ LINK (Shopee / TikTok Shop / web bất kỳ).

Engine bóc data THUẦN (không phụ thuộc browser) ở ``extractors`` — nhận HTML của
trang sản phẩm, trả về dict chuẩn để đổ vào pipeline import cũ (normalize sheet +
AI điền nốt). Browser layer (fetch headless / overlay lướt headed) nằm ở
``services.tabs.affiliate.product_fetcher`` — dùng chromium_persistent_manager sẵn có.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['extract_product', 'detect_source', 'SUPPORTED_HINTS']

# --- Module Constants & Globals ---
SUPPORTED_HINTS = ('shopee', 'tiktok', 'lazada', 'tiki', 'web bất kỳ')
__all__ = ['extract_product', 'detect_source', 'SUPPORTED_HINTS']
