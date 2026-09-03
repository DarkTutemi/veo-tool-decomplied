"""
Decompiled / Reconstructed Module: qml_app.models.job_panel_page_proxy

Docstring:
Bound-N page WINDOW over a JobPanelListModel, with live-frontier auto-follow.

Exposes exactly the active page's ``pageSize`` source rows as a fixed set of N slots. The
source model keeps ALL rows (the feed mutates it unchanged); this model is a thin window.

Why a hand-written window and not a ``QSortFilterProxyModel`` index-range filter: on a page
change the filter swaps the ENTIRE accepted row set (0-4 → 5-9), which the proxy signals as
``layoutChanged`` → the view re-lays-out, may reset scroll, and churns the delegate pool.
This window instead keeps the N slots and emits a surgical ``dataChanged(0..N-1)`` to REBIND
them in place — the N JobPanelCard delegates persist and just re-read the new page's data
(a flip, not a tear-down). Only the last (partial) page resizes via begin/endInsert/Remove.

A ``dataChanged`` on a source row INSIDE the window maps to its slot; rows outside the window
are ignored (no render). Jobs are FIFO oldest-first, so the generating frontier walks down as
pages complete — **auto-follow** keeps ``activePage`` on the page of the first non-terminal
job; the user paging ``‹ ›`` pins it (following=False); ``goLive()`` resumes + jumps.

Registered as the QML type ``VeoFlow.JobPanelPageProxy`` (name kept for the QML side); one per
JobPanelWidget, ``sourceModel`` bound to the controller's shared job model.
"""

from __future__ import annotations
import sys, os, typing
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
_TERMINAL = frozenset({'done', 'complete', 'completed', 'canceled', 'cancelled', 'error', 'failed'})
_FAILED = frozenset({'cancelled', 'error', 'failed', 'canceled'})

# --- Class: JobPanelPageProxy ---
class JobPanelPageProxy(QAbstractListModel):
    staticMetaObject = PySide6.QtCore.QMetaObject("JobPanelPageProxy" inherits "QAbstractListModel":
Properties:
  #1 "sourceModel", QObject* [...

    pageChanged = Signal()
    sourceModelChanged = Signal()
    def __init__(self, parent: 'QtCore.QObject | None' = None) -> 'None':
        pass

    def _get_source(self):
        pass

    def setSourceModel(self, model) -> 'None':
        # [PyArmor BCC constants]: '_source', 'beginResetModel', '_source_connections', 'disconnect', 'Exception', '_status_role', 'connect', 0, '_active_page', '_rebuild_index', '_apply_follow_target', '_compute_count', '_count', '_sync_hot_window', 'endResetModel'
        pass

    def _source_connections(self, model):
        # [PyArmor BCC constants]: 'dataChanged', '_on_source_data_changed', 'rowsInserted', '_on_source_count_changed', 'rowsRemoved', 'layoutChanged', 'modelReset', '_on_source_reset', 'hasattr', 'statusesPatched', '_on_statuses_patched'
        pass

    def sourceModel(*args, **kwargs):
        pass

    def rowCount(self, parent=<PySide6.QtCore.QModelIndex(-1,-1,0x0,QObject(0x0)) at 0x0000021ACFFCB5C0>) -> 'int':
        # [PyArmor BCC constants]: 'isValid', '_source', 0, '_count'
        pass

    def data(self, index: 'QtCore.QModelIndex', role: 'int' = 0):
        # [PyArmor BCC constants]: '_source', 'isValid', 'row', 0, '_count', '_source_row_for_slot', 'index', 'data'
        pass

    def roleNames(self):
        pass

    def _offset(self) -> 'int':
        pass

    def _source_total(self) -> 'int':
        # [PyArmor BCC constants]: '_filter', 'len', '_index', '_source', 'int', 'rowCount', 0
        pass

    def _source_row_for_slot(self, slot: 'int') -> 'int':
        # [PyArmor BCC constants]: '_offset', 'int', '_filter', 0, 'len', '_index', 1, '_source', 'rowCount'
        pass

    def _row_status(self, src_row: 'int') -> 'str':
        # [PyArmor BCC constants]: '_source', '_status_role_id', 0, '', 'str', 'data', 'index', 'strip', 'lower'
        pass

    def _rebuild_index(self) -> 'None':
        # [PyArmor BCC constants]: '_filter', '_source', '_index', 'failed', '_FAILED', 'range', 'int', 'rowCount', '_row_status', 'append'
        pass

    def _compute_count(self, page: 'int') -> 'int':
        # [PyArmor BCC constants]: '_source_total', '_page_size', 0, 'max', 'min'
        pass

    def _relayout(self, new_page: 'int', new_following: 'bool') -> 'None':
        # [PyArmor BCC constants]: '_active_page', '_count', '_compute_count', 'beginInsertRows', 'QtCore', 'QModelIndex', 1, '_following', 'endInsertRows', 'beginRemoveRows', 'endRemoveRows', '_sync_hot_window', '_source', 'hasattr', 'request_page_refresh'
        pass

    def _sync_hot_window(self, page: 'int', count: 'int') -> 'None':
        # [PyArmor BCC constants]: '_source', 'hasattr', 'set_hot_window', '_page_size', 0, 'clear_hot_window', '_filter', '_index', 'min', 'max', 1
        pass

    def _on_source_data_changed(self, top_left, bottom_right, roles=None) -> 'None':
        # [PyArmor BCC constants]: '_refreshing_page', '_filter', 'list', '_index', '_rebuild_index', '_relayout', '_clamped_page', False, '_offset', '_count', 'range', 'int', 'row', 1, 'index'
        pass

    def _on_source_count_changed(self, *args) -> 'None':
        # [PyArmor BCC constants]: '_filter', '_rebuild_index', '_clamped_page', '_following', '_live_page', '_relayout'
        pass

    def _on_source_reset(self, *args) -> 'None':
        # [PyArmor BCC constants]: 'beginResetModel', '_rebuild_index', '_clamped_page', '_active_page', '_apply_follow_target', '_compute_count', '_count', '_sync_hot_window', 'endResetModel', 'pageChanged', 'emit'
        pass

    def _status_role_id(self):
        # [PyArmor BCC constants]: '_status_role', '_source', 'roleNames', 'items', 'bytes', 'decode', 'utf-8', 'ignore', 'status', 'int'
        pass

    def _first_active_source_row(self) -> 'int':
        # [PyArmor BCC constants]: '_source', '_status_role_id', 1, 'range', 'rowCount', 'str', 'data', 'index', 0, '', 'strip', 'lower', '_TERMINAL'
        pass

    def _live_page(self):
        # [PyArmor BCC constants]: '_page_size', 0, '_first_active_source_row', 'pageCount', 'max', 'min', 1
        pass

    def _apply_follow_target(self) -> 'None':
        # [PyArmor BCC constants]: '_following', '_live_page', '_active_page'
        pass

    def following(*args, **kwargs):
        pass

    def livePage(*args, **kwargs):
        pass

    def goLive(self) -> 'None':
        # [PyArmor BCC constants]: '_live_page', '_relayout', '_active_page', True
        pass

    def statusFilter(*args, **kwargs):
        pass

    def pageSize(*args, **kwargs):
        pass

    def activePage(*args, **kwargs):
        pass

    def setActivePage(self, p: 'int') -> 'None':
        pass

    def nextPage(self) -> 'None':
        pass

    def prevPage(self) -> 'None':
        pass

    def totalCount(*args, **kwargs):
        pass

    def pageCount(*args, **kwargs):
        pass

    def _user_goto(self, p: 'int') -> 'None':
        # [PyArmor BCC constants]: '_relayout', 'max', 0, 'min', 'int', 'pageCount', 1, False
        pass

    def _clamped_page(self) -> 'int':
        # [PyArmor BCC constants]: 'max', 0, 'min', '_active_page', 'pageCount', 1
        pass

    def _on_statuses_patched(self) -> 'None':
        # [PyArmor BCC constants]: '_following', '_live_page', '_active_page', '_relayout', True
        pass

