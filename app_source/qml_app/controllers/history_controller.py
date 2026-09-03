"""
Decompiled / Reconstructed Module: qml_app.controllers.history_controller

Docstring:
History v3 controller.

Every blocking read/action runs on a worker.  Workers return immutable payloads
through queued signals; QAbstractListModels are mutated only on the GUI thread.
"""

from __future__ import annotations
import sys, os, typing
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
SOURCE_FILTERS = [{'key': 'all', 'label': 'Tất cả'}, {'key': 'normal_panel', 'label': 'Normal'}, {'key': 'clone_video', 'label': 'Clone'}, {'key': 'transcript_video', 'label': 'Audio → Video'}, {'key': 'master_prompt'... [truncated]
STATE_FILTERS = [{'key': 'all', 'label': 'Mọi trạng thái'}, {'key': 'queued', 'label': 'Đang chờ'}, {'key': 'running', 'label': 'Đang chạy'}, {'key': 'needs_attention', 'label': 'Cần xử lý'}, {'key': 'completed', 'la... [truncated]

# --- Class: HistoryItemListModel ---
class HistoryItemListModel(DictListModel):
    staticMetaObject = PySide6.QtCore.QMetaObject("HistoryItemListModel" inherits "DictListModel":
)


# --- Class: HistoryRunListModel ---
class HistoryRunListModel(DictListModel):
    staticMetaObject = PySide6.QtCore.QMetaObject("HistoryRunListModel" inherits "DictListModel":
)

    def appendRows(self, rows: 'Any') -> 'None':
        pass


# --- Class: HistoryController ---
class HistoryController(QObject):
    staticMetaObject = PySide6.QtCore.QMetaObject("HistoryController" inherits "QObject":
Properties:
  #1 "runsModel", QObject* [constant] [de...

    filtersChanged = Signal()
    loadingChanged = Signal()
    statsChanged = Signal()
    selectedRunIdChanged = Signal()
    selectedDetailChanged = Signal()
    statusMessageChanged = Signal()
    actionResult = Signal()
    openTargetRequested = Signal()
    _listPayload = Signal()
    _detailPayload = Signal()
    _actionPayload = Signal()
    _storeChanged = Signal()
    def __init__(self, service: 'HistoryService | None' = None) -> 'None':
        pass

    def _get_service(self) -> 'HistoryService':
        # [PyArmor BCC constants]: '_service', '_service_lock', 'get_history_service'
        pass

    def runsModel(*args, **kwargs):
        pass

    def itemsModel(*args, **kwargs):
        pass

    def sources(*args, **kwargs):
        pass

    def stateFilters(*args, **kwargs):
        pass

    def source(*args, **kwargs):
        pass

    def state(*args, **kwargs):
        pass

    def search(*args, **kwargs):
        pass

    def stats(*args, **kwargs):
        pass

    def listLoading(*args, **kwargs):
        pass

    def detailLoading(*args, **kwargs):
        pass

    def actionLoading(*args, **kwargs):
        pass

    def actionsLocked(*args, **kwargs):
        pass

    def canLoadMore(*args, **kwargs):
        pass

    def selectedRunId(*args, **kwargs):
        pass

    def selectedDetail(*args, **kwargs):
        pass

    def statusMessage(*args, **kwargs):
        pass

    def _set_status(self, value: 'str') -> 'None':
        # [PyArmor BCC constants]: 'str', '', '_status_message', 'statusMessageChanged', 'emit'
        pass

    def setActive(self, active: 'bool') -> 'None':
        # [PyArmor BCC constants]: 'bool', '_active', '_connect_store_listener', '_runs_model', 'rows', 'refresh'
        pass

    def _connect_store_listener(self) -> 'None':
        # [PyArmor BCC constants]: '_store_listener', '_get_service', 'store', '_storeChanged', 'emit', 'str', '', 'add_listener', 'Exception'
        pass

    def setSource(self, value: 'str') -> 'None':
        # [PyArmor BCC constants]: 'str', 'all', 'SOURCE_FILTERS', 'key', '_source', 'filtersChanged', 'emit', 'refresh'
        pass

    def setState(self, value: 'str') -> 'None':
        # [PyArmor BCC constants]: 'str', 'all', 'STATE_FILTERS', 'key', '_state', 'filtersChanged', 'emit', 'refresh'
        pass

    def setSearch(self, value: 'str') -> 'None':
        # [PyArmor BCC constants]: 'str', '', 'strip', '_search', 'filtersChanged', 'emit', 'refresh'
        pass

    def _request(self, cursor: 'str' = '') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'source', 'state', 'search', 'cursor', 'pageSize', '_source', '_state', '_search', 50
        pass

    def refresh(self) -> 'None':
        # [PyArmor BCC constants]: '_active', '_list_loading', True, '_refresh_pending', False, 1, '_list_token', '_request', 'loadingChanged', 'emit', '_get_service', 'query_runs', 'ok', 'token', 'append'
        pass

    def loadMore(self) -> 'None':
        # [PyArmor BCC constants]: 'canLoadMore', '_list_token', '_request', '_next_cursor', True, '_list_loading', 'loadingChanged', 'emit', '_get_service', 'query_runs', 'ok', 'token', 'append', 'error', False
        pass

    def _apply_list_payload(self, payload: 'dict[str, Any]') -> 'None':
        # [PyArmor BCC constants]: 'int', 'get', 'token', 1, '_list_token', False, '_list_loading', 'ok', 'list', 'rows', 'append', '_runs_model', 'appendRows', 'setRows', 'dict'
        pass

    def selectRun(self, run_id: 'str') -> 'None':
        # [PyArmor BCC constants]: 'str', '', 1, '_detail_token', '_selected_run_id', '_selected_detail', '_items_model', 'setRows', 'bool', '_detail_loading', 'selectedRunIdChanged', 'emit', 'selectedDetailChanged', 'loadingChanged', '_get_service'
        pass

    def _apply_detail_payload(self, payload: 'dict[str, Any]') -> 'None':
        # [PyArmor BCC constants]: 'int', 'get', 'token', 1, '_detail_token', 'str', 'runId', '', '_selected_run_id', False, '_detail_loading', 'ok', 'dict', 'detail', '_selected_detail'
        pass

    def _target_for(self, action: 'str') -> 'tuple[str, str]':
        # [PyArmor BCC constants]: 'dict', '_selected_detail', 'get', 'actionTargets', 'open_output', 'open_video', 'str', 'outputKind', '', 'output', 'path', 'openable_target', 'open_folder', 'folderKind', 'folder'
        pass

    def _target_for_item(self, item_id: 'str', action: 'str') -> 'tuple[str, str]':
        # [PyArmor BCC constants]: 'open_output', 'list', '_selected_detail', 'get', 'items', 'str', 'itemId', '', 'openKind', 'openTarget', 'path', 'openable_target', 'output', 'thumbnail'
        pass

    def _emit_open_target(self, kind: 'str', target: 'str', *, missing: 'str') -> 'bool':
        # [PyArmor BCC constants]: 'str', '', 'strip', '_set_status', False, 'openable_target', 'openTargetRequested', 'emit', 'path', 'Đang mở…', True
        pass

    def executeAction(self, action_id: 'str') -> 'None':
        # [PyArmor BCC constants]: 'str', '', 'strip', 'actionsLocked', '_target_for', 'open_output', 'open_video', '_emit_open_target', 'missing', 'Chưa có file output trên máy.', 'open_folder', 'Chưa có thư mục output.', 'delete_permanently', 'retry_failed', 'archive'
        pass

    def executeItemAction(self, item_id: 'str', action_id: 'str') -> 'None':
        # [PyArmor BCC constants]: 'str', '', 'strip', 'actionsLocked', '_target_for_item', 'open_output', '_emit_open_target', 'missing', 'Job con này chưa có file output.', 'recreate_item', '_set_status', 'Action job con không được hỗ trợ.', '_selected_run_id', True, '_action_loading'
        pass

    def openArtifact(self, target: 'str') -> 'None':
        # [PyArmor BCC constants]: 'str', '', 'strip', 'openable_target', '_set_status', 'Không mở được file này.', 'openTargetRequested', 'emit', 'path'
        pass

    def _apply_action_payload(self, payload: 'dict[str, Any]') -> 'None':
        # [PyArmor BCC constants]: False, '_action_loading', 'loadingChanged', 'emit', 'dict', 'get', 'result', 'actionResult', 'ok', '_set_status', 'str', 'error', 'Action thất bại', 'action', ''
        pass

    def _on_store_changed(self, run_id: 'str') -> 'None':
        # [PyArmor BCC constants]: '_active', '_refresh_debounce', 'start', '_selected_run_id', '_detail_loading', 'selectRun'
        pass

    def shutdown(self) -> 'None':
        # [PyArmor BCC constants]: '_store_listener', '_get_service', 'store', 'remove_listener', 'Exception'
        pass

