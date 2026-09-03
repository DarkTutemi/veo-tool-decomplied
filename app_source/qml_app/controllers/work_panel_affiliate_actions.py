"""
Decompiled / Reconstructed Module: qml_app.controllers.work_panel_affiliate_actions

Docstring:
Affiliate primitive-action dispatch — tách khỏi work_panel_controller.py.

``WorkPanelController.executePrimitiveAction`` quá dài; toàn bộ nhánh
``work_panel.affiliate_*`` chuyển sang đây. Hàm thuần (Qt-free) nhận ``ctrl`` =
WorkPanelController và thao tác qua các thuộc tính/method công khai của nó
(``_route_configs``, ``_cards_by_route``, ``_affiliate_uc``, ``_state`` …). Trả về:
  * ``True``  — đã xử lý action,
  * ``dict``  — đã xử lý production action và có kết quả cấu trúc,
  * ``None``  — không phải affiliate action (controller xử lý tiếp).
"""

from __future__ import annotations
import sys, os, typing
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Optional = typing.Optional
_PRODUCTION_ACTIONS = frozenset({'work_panel.affiliate_auto_pool_toggle', 'work_panel.affiliate_continue_submit', 'work_panel.affiliate_start', 'work_panel.affiliate_generate_script', 'work_panel.affiliate_manual_enqueue',... [truncated]

# --- Top-Level Functions ---
def is_production_action(action_key: 'str') -> 'bool':
    # [PyArmor BCC constants]: 'str', '', 'strip', '_PRODUCTION_ACTIONS'
    pass

def requires_run_preflight(action_key: 'str', data: 'dict[str, Any] | None' = None) -> 'bool':
    # [PyArmor BCC constants]: 'str', '', 'strip', '_PRODUCTION_ACTIONS', False, 'work_panel.affiliate_auto_pool_toggle', 'bool', 'get', 'enabled', True
    pass

def preflight_action_name(action_key: 'str') -> 'str':
    # [PyArmor BCC constants]: 'str', '', 'strip', 'removeprefix', 'work_panel.affiliate_', 'queue.', 'production'
    pass

def _result(action: 'str', *, ok: 'bool', code: 'str', message: 'str', **details: 'Any') -> 'dict[str, Any]':
    # [PyArmor BCC constants]: 'ok', 'blocked', 'route', 'action', 'code', 'message', 'bool', 'affiliate', 'str', 'affiliate.production', '', 'affiliate_action_failed', 'error', 'update'
    pass

def _emit_worker_result(ctrl: 'Any', action: 'str', raw_result: 'Any', *, success_message: 'str', failure_message: 'str') -> 'None':
    # [PyArmor BCC constants]: 'isinstance', 'dict', 'bool', 'get', 'ok', 'setdefault', 'blocked', 'route', 'affiliate', 'action', 'code', 'affiliate_action_completed', 'affiliate_action_failed', 'error', 'message'
    pass

def dispatch(ctrl: 'Any', action_key: 'str', data: 'dict[str, Any]') -> 'Optional[bool | dict[str, Any]]':
    # [PyArmor BCC constants]: 'startswith', 'work_panel.affiliate', 'print', '[AFF.action] ', ' col=', 'get', 'column_id', '', ' idx=', 'index', ' key=', 'key', ' val=', 'str', 'value'
    pass
