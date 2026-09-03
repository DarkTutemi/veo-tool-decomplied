"""
Decompiled / Reconstructed Module: application.run_preflight
Source PyC: run_preflight.pyc

Docstring:
Bộ quy tắc tiền-kiểm CHUNG trước khi enqueue/start job ở mọi tab.

Tất cả các tab tạo video (master, clone, transcript, normal, batch, extend,
affiliate) đều bắt buộc phải có ít nhất 1 tài khoản đang hoạt động (Live) thì
mới chạy được. Thay vì để job submit rồi chắc chắn fail, ta CHẶN ngay tại điểm
"thêm vào hàng chờ" / "bắt đầu xử lý" và cảnh báo người dùng.

Voice Studio dùng cơ chế riêng nên KHÔNG áp gate này.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
_ROUTE_FEATURE = {'master': 'master_panel', 'master_prompt': 'master_panel', 'clone': 'clone_panel', 'clone_video': 'clone_panel', 'transcript': 'transcript_panel', 'transcript_video': 'transcript_panel', 'research': ... [truncated]

# --- Top-Level Functions ---
def account_snapshot() -> 'dict[str, int]':
    pass

def live_account_count() -> 'int':
    pass

def has_live_account() -> 'bool':
    pass

def run_blocker(action: 'str' = 'queue.preflight') -> 'dict[str, Any] | None':
    pass

def feature_for_route(route: 'str') -> 'str':
    pass

def feature_blocker(feature_code: 'str', action: 'str' = 'feature.preflight') -> 'dict[str, Any] | None':
    pass

def _gate_empty(gate: 'object') -> 'bool':
    pass

def _entitlement_gate():
    pass

def run_and_feature_blocker(feature_code: 'str', action: 'str' = 'queue.preflight') -> 'dict[str, Any] | None':
    pass

def alert_payload() -> 'dict[str, Any]':
    pass
