"""
Decompiled / Reconstructed Module: qml_app.models.dict_list_model

Docstring:
DictListModel — a drop-in QAbstractListModel for a list of plain dicts.

The recurring Law-3 anti-pattern is `@pyqtProperty("QVariantList")` bound to a ListView: the whole
view is copied + rebuilt on every change. This model fixes that WITHOUT touching delegates: it
exposes a single role named `modelData`, so a delegate that already reads `modelData.someField`
(the QVariantList style) keeps working unchanged. The controller swaps the QVariantList property for
a `pyqtProperty(QObject, constant=True)` returning this model and calls `setRows(...)` on update;
same-length updates emit a narrow `dataChanged` (no full rebuild), length changes do a minimal
insert/remove instead of a blanket reset.

    # controller
    self._jobs_model = DictListModel(self)
    @pyqtProperty(QObject, constant=True)
    def jobsModel(self): return self._jobs_model
    # on update:  self._jobs_model.setRows(normalized)

    // QML:  ListView { model: ctrl.jobsModel; delegate: Card { /* modelData.title still works */ } }
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

    def rowCount(self, parent=<PySide6.QtCore.QModelIndex(-1,-1,0x0,QObject(0x0)) at 0x000001DFC1CE90C0>) -> 'int':
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

