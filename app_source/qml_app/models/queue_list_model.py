"""
Decompiled / Reconstructed Module: qml_app.models.queue_list_model

Docstring:
Shared QAbstractListModel for QUEUE rows (batch-aggregate queue tables).

Counterpart of ``JobPanelListModel`` for the per-route QUEUE list (clone / master
/ normal / extend): each row is a *batch* summarised from N dispatcher jobs.
Exposing it as a real model — instead of a ``QVariantList`` reassigned wholesale —
lets the ListView repaint ONLY the delegate whose row changed (via ``dataChanged``)
rather than destroying + rebuilding every delegate on each progress tick.

The delegate reads the whole row through the ``qrow`` role because the existing
queue helper functions (``rowTitle``/``queueProgressText``/``queueStatusKey`` …)
take the row dict — so migrating a ListView is just ``model: queueRows`` →
``model: controller.queueModel`` and ``modelData`` → ``model.qrow``.
"""

from __future__ import annotations
import sys, os, typing
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
_QUEUE_ROLE_NAMES = ('qrow', 'rowId')
_BASE_ROLE = 257
_ROLE_BY_NAME = {'qrow': 257, 'rowId': 258}
_NAME_BY_ROLE = {257: 'qrow', 258: 'rowId'}

# --- Class: QueueListModel ---
class QueueListModel(QAbstractListModel):
    """
    Incremental queue-row model. Same ``apply_rows`` diff contract as
        ``JobPanelListModel``: identical id-set → per-row ``dataChanged``; a different
        id-set (add/remove/reorder) → one ``beginResetModel`` reset.
    """
    _ROLE_BY_NAME = {'qrow': 257, 'rowId': 258}
    _NAME_BY_ROLE = {257: 'qrow', 258: 'rowId'}
    _ALL_ROLES = [257, 258]
    staticMetaObject = PySide6.QtCore.QMetaObject("QueueListModel" inherits "QAbstractListModel":
)

    def __init__(self, parent: 'QtCore.QObject | None' = None) -> 'None':
        pass

    def rowCount(self, parent: 'QtCore.QModelIndex' = <PySide6.QtCore.QModelIndex(-1,-1,0x0,QObject(0x0)) at 0x000001DFC1CCFF00>) -> 'int':
        # [PyArmor BCC constants]: 'isValid', 0, 'len', '_rows'
        pass

    def data(self, index: 'QtCore.QModelIndex', role: 'int' = 0) -> 'Any':
        # [PyArmor BCC constants]: 'isValid', 'int', 'row', 0, 'len', '_rows', '_NAME_BY_ROLE', 'get', 'qrow', 'dict', 'rowId', '_row_id'
        pass

    def roleNames(self) -> "dict[int, __assert_armored__((QtCore, b'\\x81\\xb4\\xb9\\x0cH\\xb4\\xdfT\\xa5(\\xb4'))]":
        # [PyArmor BCC constants]: '_ROLE_BY_NAME', 'items', 'QtCore', 'QByteArray', 'encode', 'utf-8'
        pass

    def set_rows(self, rows: 'list[dict[str, Any]]') -> 'None':
        # [PyArmor BCC constants]: 'warn_if_off_gui', 'QueueListModel.set_rows', 'beginResetModel', 'list', 'isinstance', 'dict', '_rows', 'endResetModel'
        pass

    def apply_rows(self, rows: 'list[dict[str, Any]]') -> 'None':
        # [PyArmor BCC constants]: 'warn_if_off_gui', 'QueueListModel.apply_rows', 'list', 'isinstance', 'dict', '_rows', '_row_id', 'set_rows', 'enumerate', 'index', 0, 'dataChanged', 'emit', '_ALL_ROLES'
        pass

    def rows(self) -> 'list[dict[str, Any]]':
        pass


# --- Top-Level Functions ---
def _row_id(row: 'Any') -> 'str':
    # [PyArmor BCC constants]: 'isinstance', 'dict', '', 'str', 'get', 'id', 'row_id', 'batch_id', 'strip'
    pass
