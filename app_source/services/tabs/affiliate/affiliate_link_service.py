"""
Decompiled / Reconstructed Module: services.tabs.affiliate.affiliate_link_service
Source PyC: affiliate_link_service.pyc

Docstring:
Sinh LINK TIẾP THỊ Shopee cho sản phẩm đã import (bố chốt 22/7).

Bố soi network trang tiếp thị: Shopee đổi link SP → link hoa hồng bằng MỘT endpoint
GraphQL nhận MẢNG, nên N sản phẩm chỉ tốn 1 request:

    POST https://affiliate.shopee.vn/api/v3/gql?q=batchCustomLink
    { operationName: "batchGetCustomLink", query: <gql>, variables: {
        linkParams: [{originalLink, advancedLinkParams:{}}...],
        sourceCaller: "CUSTOM_LINK_CALLER" } }
    → data.batchCustomLink[] = {shortLink, longLink, failCode}

VÌ SAO GỌI IN-PAGE (không dùng requests): request thật mang header ký chống bot
`Af-Ac-Enc-Dat` / `Af-Ac-Enc-Sz-Token`; đo được trên trang Shopee thì `window.fetch`
và `XMLHttpRequest` ĐỀU đã bị chính Shopee bọc (không còn "[native code]") — tức lớp ký
nằm trong đó. Gọi fetch NGAY TRONG trang affiliate.shopee.vn thì header tự có.

VÌ SAO DÙNG BROWSER ĐANG MỞ: mở/đóng browser liên tục tạo hàng loạt phiên mới → Shopee
siết `verify/traffic`. `product_browser.start_browse` tái dùng instance đang chạy.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['create_affiliate_links', 'link_eligible', 'CUSTOM_LINK_URL', 'MAX_BATCH']

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
List = typing.List
CUSTOM_LINK_URL = 'https://affiliate.shopee.vn/offer/custom_link'
_HOST = 'affiliate.shopee.vn'
MAX_BATCH = 50
_LINK_JS = '\nasync (links) => {\n  const body = {\n    operationName: "batchGetCustomLink",\n    query: `\n    query batchGetCustomLink($linkParams: [CustomLinkParam!], $sourceCaller: SourceCaller){\n      batc... [truncated]
__all__ = ['create_affiliate_links', 'link_eligible', 'CUSTOM_LINK_URL', 'MAX_BATCH']

# --- Top-Level Functions ---
def _text(v: 'Any') -> 'str':
    pass

def link_eligible(product_url: 'str') -> 'bool':
    pass

def _blocked_state(url: 'str') -> 'str':
    pass

def create_affiliate_links(product_urls: 'List[str]', *, account: 'str' = '', page=None) -> 'Dict[str, Any]':
    pass
