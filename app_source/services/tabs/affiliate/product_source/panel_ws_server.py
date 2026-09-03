"""
Decompiled / Reconstructed Module: services.tabs.affiliate.product_source.panel_ws_server
Source PyC: panel_ws_server.pyc

Docstring:
panel_ws_server.py — cầu WebSocket app ↔ side-panel extension (P0).

BẢO MẬT = Origin-allowlist, KHÔNG token: chỉ chấp nhận connection có
`Origin: chrome-extension://<PANEL_EXTENSION_ID>`. Trang web (tiktok/shopee) nối vào
cùng port sẽ gửi `Origin: https://…` → bị từ chối. JS KHÔNG giả được Origin header của
WebSocket (browser set, JS cấm ghi đè), nên đây đủ chặn trang — threat model thật ở đây.

Sống trong thread + asyncio loop RIÊNG (không đụng farm loop). Protocol v2 giữ nguyên
`{v:2, id, type, payload, ok}` để P1 nối thẳng router cũ (_route_overlay_message /
_on_overlay_message) mà không đổi logic — chỉ thay transport.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Callable = typing.Callable
Optional = typing.Optional
AFFILIATE_PANEL_WS_PORT = 47821
_log = <Logger affiliate.panel_ws (WARNING)>
PANEL_EXTENSION_ID = 'egkckajbblpbokfobjaligicalflbhla'
ALLOWED_ORIGIN = 'chrome-extension://egkckajbblpbokfobjaligicalflbhla'
DEFAULT_PORT = 47821
_server = None
_server_lock = <unlocked _thread.lock object at 0x00000264E518F040>

# --- Class: PanelWsServer ---
class PanelWsServer:
    """WS server 1-panel cho affiliate. Thread-safe start/stop/broadcast.

    on_message(msg_type, payload, reply) — reply(type, payload) đẩy ngược xuống panel.
    P0 để None cũng chạy (chỉ handshake OVERLAY_READY → CONNECTION)."""
    def __init__(self, on_message: 'Optional[Callable[[str, dict, Callable[[str, dict], None]], None]]' = None, port: 'int' = 47821) -> 'None':
        pass

    def start(self) -> 'bool':
        pass

    def stop(self) -> 'None':
        pass

    def _run(self) -> 'None':
        pass

    def _serve(self) -> 'None':
        pass

    def _handler(self, ws) -> 'None':
        pass

    def _dispatch(self, ws, msg: 'dict') -> 'None':
        pass

    def _send(self, ws, mtype: 'str', payload: 'dict') -> 'None':
        pass

    def broadcast(self, mtype: 'str', payload: 'dict') -> 'None':
        """Đẩy 1 message xuống mọi panel đang nối. Gọi được từ THREAD BẤT KỲ."""
        pass


# --- Top-Level Functions ---
def panel_ext_dir() -> 'str':
    pass

def panel_enabled() -> 'bool':
    pass

def get_panel_ws_server(on_message=None) -> "'PanelWsServer'":
    pass
