"""
Decompiled / Reconstructed Module: core.aistudio.direct.license_bridge
Source PyC: license_bridge.pyc

Docstring:
core/aistudio/direct/license_bridge.py — đưa license xuống fork qua CDP.

Cơ chế: fork (Chromium C++) tự gate với server (docs/BROWSER_FORK_LICENSE_GATE_SPEC.md).
Client KHÔNG quyết entitlement — chỉ CHUYỂN license string xuống fork qua CDP command
`VeoFlow.setLicense`; fork nhận (browser-process C++) rồi tự hỏi server "active?" trước
khi cho gen chạy.

`push_license_to_fork` thu lỗi CDP thành False để caller dọn phiên sạch sẽ.
Mọi caller bắt buộc gọi `require_fork_armed`; fork cũ / lỗi gate / license bị từ chối
đều fail-closed trước khi phiên được đưa vào pool.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
MIN_FORK_GATE_PROTOCOL = 2
MIN_FORK_VERSION = '1.0.13'
_log = <Logger aistudio.direct.license_bridge (WARNING)>

# --- Class: ForkLicenseGateError ---
class ForkLicenseGateError(RuntimeError):
    """Fork did not prove that its server-backed license gate is armed."""
    pass


# --- Top-Level Functions ---
def require_fork_armed(armed: 'bool') -> 'None':
    pass

def fork_contract_supported(fork_version: 'str', gate_protocol) -> 'bool':
    pass

def push_license_to_fork(page) -> 'bool':
    """Gửi {license, device_id, fingerprint, tool_version} xuống fork qua CDP.

    Trả True chỉ khi fork xác nhận gate đã armed; mọi lỗi → False."""
    pass

def _collect_identity():
    pass
