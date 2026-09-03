"""
Decompiled / Reconstructed Module: core.account_mode
Source PyC: account_mode.pyc

Docstring:
Global account tier MODE — tool chạy ULTRA MODE hoặc PRO MODE, KHÔNG trộn.

PRO = chế độ chống cháy (account PRO unlimited, rẻ). ULTRA = chế độ chính
(account ULTRA, max 10). Pool chỉ nạp account đúng effective mode.

KHÔNG có pref/auto. Mode được quyết THUẦN theo LOẠI account đang bật (enable-enforcement
đảm bảo chỉ 1 loại enabled tại một thời điểm). Status Live chỉ quyết pool có worker hay
không, KHÔNG quyết mode: account ULTRA "Need Login" vẫn là ULTRA (chờ login lại), không
tụt về PRO giả. Đổi mode = bật/tắt account loại tương ứng.

Dùng chung bởi: pool (build_account_slots), master config (quality/model theo tier),
và nút gạt ở Account Settings.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
List = typing.List
Optional = typing.Optional
MODE_ULTRA = 'ultra'
MODE_PRO = 'pro'
ULTRA_MAX_ACCOUNTS = 10

# --- Top-Level Functions ---
def _is_supported(acc: 'Dict[str, Any]') -> 'bool':
    pass

def _is_live_enabled(acc: 'Dict[str, Any]') -> 'bool':
    pass

def _is_ultra(acc: 'Dict[str, Any]') -> 'bool':
    pass

def _all_accounts() -> 'List[Dict[str, Any]]':
    pass

def has_live_ultra(accounts: 'Optional[List[Dict[str, Any]]]' = None) -> 'bool':
    pass

def resolve_active_mode(accounts: 'Optional[List[Dict[str, Any]]]' = None) -> 'str':
    """Effective mode ('ultra' | 'pro') — theo loại account đang BẬT.

    Enable-enforcement chỉ cho 1 loại enabled tại một thời điểm nên kết quả xác định.
    - Còn account Live+enabled → mode theo loại đó (hệ thống khoẻ).
    - KHÔNG còn account Live nào nhưng còn account ENABLED (vd ULTRA "Need Login" đang
      chờ login lại) → GIỮ mode theo loại đang bật, KHÔNG tụt về PRO giả. Pool sẽ rỗng
      tới khi login lại, nhưng tier model + UI vẫn đúng ULTRA (không degrade nhầm)."""
    pass

def account_matches_mode(acc: 'Dict[str, Any]', mode: 'str') -> 'bool':
    pass

def _email_of(acc: 'Dict[str, Any]') -> 'str':
    pass

def classify_enable(target: 'Dict[str, Any]', accounts: 'Optional[List[Dict[str, Any]]]' = None) -> 'Dict[str, Any]':
    pass

def classify_set_mode(mode: 'str', accounts: 'Optional[List[Dict[str, Any]]]' = None) -> 'Dict[str, Any]':
    """Quyết khi GẠT MODE (nút PRO/ULTRA ở Account Settings) — radio thuần, KHÔNG ưu tiên.

    • "ultra": cần ≥1 account ULTRA trong hệ thống, else ``no_ultra_account``.
    • "pro":   cần ≥1 account PRO (non-ultra) trong hệ thống, else ``no_pro_account``.
      Chọn PRO KHÔNG bị khoá bởi ULTRA — switch sẽ tự tắt ULTRA (xem ``setAccountMode``).
    • mode lạ → ``bad_mode``.

    Returns dict{allowed, reason, target_mode}."""
    pass

def has_account_of_mode(mode: 'str', accounts: 'Optional[List[Dict[str, Any]]]' = None) -> 'bool':
    """Có account thuộc ``mode`` trong hệ thống (để biết có thể ghìm mode đó không)."""
    pass
