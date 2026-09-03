"""
Decompiled / Reconstructed Module: qml_app.models.automation_center_run_model

Docstring:
GUI-thread projection of Automation Center runs for QML delegates.

The backend returns plain dictionaries from a worker thread.  The host applies
those snapshots on the GUI thread through this model so QML never observes a
partially-mutated shared list.  Rows are exposed through a single ``modelData``
role to keep delegates small and make the row contract explicit at the Python
boundary.
"""

from __future__ import annotations
import sys, os, typing
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['AutomationCenterRunModel']

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
_ROW_KEYS = ('jobId', 'attemptId', 'internalRunId', 'title', 'workflow', 'status', 'statusLabel', 'stage', 'progress', 'message', 'errorCode', 'createdAt', 'active', 'localReady')
__all__ = ['AutomationCenterRunModel']

# --- Class: AutomationCenterRunModel ---
class AutomationCenterRunModel(QAbstractListModel):
    """Stable list model with atomic structural swaps and narrow row updates."""
    _MODEL_DATA_ROLE = 257
    staticMetaObject = PySide6.QtCore.QMetaObject("AutomationCenterRunModel" inherits "QAbstractListModel":
Properties:
  #1 "count", int [desi...

    countChanged = Signal()
    def __init__(self, parent: 'QtCore.QObject | None' = None) -> 'None':
        pass

    def roleNames(self) -> "dict[int, __assert_armored__((QtCore, b'\\x81\\xb4\\xb9\\x0cH\\xb4\\xdfT\\xa5(\\xb4'))]":
        # [PyArmor BCC constants]: '_MODEL_DATA_ROLE', 'QtCore', 'QByteArray'
        pass

    def rowCount(self, parent: 'QtCore.QModelIndex' = <PySide6.QtCore.QModelIndex(-1,-1,0x0,QObject(0x0)) at 0x000001DFC250D240>) -> 'int':
        # [PyArmor BCC constants]: 'isValid', 0, 'len', '_rows'
        pass

    def data(self, index: 'QtCore.QModelIndex', role: 'int' = 0) -> 'Any':
        # [PyArmor BCC constants]: 'isValid', 0, 'row', 'len', '_rows', 'int', 'QtCore', 'Qt', 'ItemDataRole', 'DisplayRole', '_MODEL_DATA_ROLE', 'dict'
        pass

    def count(*args, **kwargs):
        pass

    def get(self, index: 'int') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 0, 'int', 'len', '_rows', 'dict'
        pass

    def setRows(self, rows: 'Any') -> 'None':
        # [PyArmor BCC constants]: 'warn_if_off_gui', 'AutomationCenterRunModel.setRows', 'isinstance', 'Mapping', '_copy_row', '_rows', 'len', '_identity', 'beginResetModel', 'endResetModel', 'countChanged', 'emit', 1, 'enumerate', 'zip'
        pass

    def rows(self) -> 'list[dict[str, Any]]':
        pass


# --- Top-Level Functions ---
def _copy_row(value: 'Mapping[str, Any]') -> 'dict[str, Any]':
    pass

def _identity(row: 'Mapping[str, Any]') -> 'tuple[str, str, str]':
    # [PyArmor BCC constants]: 'str', 'get', 'attemptId', '', 'jobId', 'internalRunId'
    pass
