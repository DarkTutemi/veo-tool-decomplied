"""
Decompiled / Reconstructed Module: qml_app.models.history_models

Docstring:
Small, identity-preserving list models for the unified History screen.
"""

from __future__ import annotations
import sys, os, typing
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)

# --- Class: DictListModel ---
class DictListModel(QAbstractListModel):
    _ROLE = 257
    staticMetaObject = PySide6.QtCore.QMetaObject("DictListModel" inherits "QAbstractListModel":
Methods:
  #76 type=Slot, signature=setRows(QV...

    def __init__(self, parent: 'Any' = None) -> 'None':
        pass

    def roleNames(self):
        pass

    def rowCount(self, parent=<PySide6.QtCore.QModelIndex(-1,-1,0x0,QObject(0x0)) at 0x0000021AD009CBC0>) -> 'int':
        # [PyArmor BCC constants]: 'isValid', 0, 'len', '_rows'
        pass

    def data(self, index, role=0):
        # [PyArmor BCC constants]: 'isValid', 0, 'row', 'len', '_rows'
        pass

    def setRows(self, rows: 'Any') -> 'None':
        # [PyArmor BCC constants]: 'isinstance', 'dict', '_rows', 'len', 'beginInsertRows', 'QtCore', 'QModelIndex', 1, 'endInsertRows', 'beginRemoveRows', 'endRemoveRows', 0, 'dataChanged', 'emit', 'index'
        pass

    def rows(self) -> 'list[dict]':
        pass


# --- Class: HistoryRunListModel ---
class HistoryRunListModel(DictListModel):
    staticMetaObject = PySide6.QtCore.QMetaObject("HistoryRunListModel" inherits "DictListModel":
)

    def appendRows(self, rows: 'Any') -> 'None':
        pass


# --- Class: HistoryItemListModel ---
class HistoryItemListModel(DictListModel):
    staticMetaObject = PySide6.QtCore.QMetaObject("HistoryItemListModel" inherits "DictListModel":
)

