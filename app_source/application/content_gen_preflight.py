"""
Decompiled / Reconstructed Module: application.content_gen_preflight
Source PyC: content_gen_preflight.pyc

Docstring:
Tầng tiền-kiểm SỐ DƯ TIỀN trước khi gọi AI provider generate nội dung.

Khác tầng 1 (run_preflight: phải có tài khoản Live để chạy video job), tầng này
kiểm TIỀN của user (ví/balance VND) ngay tại chokepoint gọi AI provider để sinh
nội dung (script, ý tưởng, template, metadata...). Nếu user dùng ví VND và số dư
khả dụng ≤ 0 → chặn, không gọi (tránh tốn round-trip + báo rõ).

Bảo thủ: chỉ chặn khi CHẮC CHẮN gateway user + balance là số ≤ 0. Số dư
thiếu/None/không xác định → KHÔNG chặn (server vẫn là nguồn sự thật cuối).
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)

# --- Class: InsufficientFundsError ---
class InsufficientFundsError(RuntimeError):
    """Raised tại chokepoint AI provider khi số dư tiền không đủ để generate."""
    code = 'insufficient_funds'


# --- Top-Level Functions ---
def _to_number(value: 'Any') -> 'float | None':
    pass

def _money() -> 'dict[str, Any]':
    pass

def funds_status() -> 'dict[str, Any]':
    pass

def has_sufficient_funds() -> 'bool':
    pass

def _message() -> 'str':
    pass

def ensure_funds_or_raise(feature: 'str' = '') -> 'None':
    pass

def funds_blocker(action: 'str' = 'content.generate') -> 'dict[str, Any] | None':
    pass

def alert_payload() -> 'dict[str, Any]':
    pass
