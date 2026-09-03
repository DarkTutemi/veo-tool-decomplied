"""
Decompiled / Reconstructed Module: qml_app.models.timemachine_models

Docstring:
QAbstractListModels for the Time Machine realtime workspace.
"""

from __future__ import annotations
import sys, os, typing
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['TimeMachineChapterCellModel', 'TimeMachineChapterModel', 'TimeMachineGridModel', 'TimeMachineMotionModel', 'TimeMachineStageModel', 'TimeMachineTimelineModel', 'TimeMachineViewModel']

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Iterable = typing.Iterable
__all__ = ['TimeMachineChapterCellModel', 'TimeMachineChapterModel', 'TimeMachineGridModel', 'TimeMachineMotionModel', 'TimeMachineStageModel', 'TimeMachineTimelineModel', 'TimeMachineViewModel']

# --- Class: _RoleListModel ---
class _RoleListModel(QAbstractListModel):
    ROLE_NAMES = ()
    staticMetaObject = PySide6.QtCore.QMetaObject("_RoleListModel" inherits "QAbstractListModel":
Properties:
  #1 "count", int [designable], n...

    countChanged = Signal()
    def __init__(self, parent: 'QtCore.QObject | None' = None) -> 'None':
        pass

    def rowCount(self, parent: 'QtCore.QModelIndex' = <PySide6.QtCore.QModelIndex(-1,-1,0x0,QObject(0x0)) at 0x0000021AD009D580>) -> 'int':
        # [PyArmor BCC constants]: 'isValid', 0, 'len', '_rows'
        pass

    def count(*args, **kwargs):
        pass

    def data(self, index: 'QtCore.QModelIndex', role: 'int' = 0) -> 'Any':
        # [PyArmor BCC constants]: 'isValid', 0, 'row', 'len', '_rows', '_name_by_role', 'get', 'int'
        pass

    def roleNames(self) -> "dict[int, __assert_armored__((QtCore, b'\\x81\\xb4\\xb9\\x0cH\\xb4\\xdfT\\xa5(\\xb4'))]":
        # [PyArmor BCC constants]: '_role_by_name', 'items', 'QtCore', 'QByteArray', 'encode', 'utf-8'
        pass

    def set_rows(self, rows: 'Iterable[dict[str, Any]]') -> 'None':
        # [PyArmor BCC constants]: 'warn_if_off_gui', 'type', '__name__', '.set_rows', 'isinstance', 'dict', 'len', '_rows', 'beginResetModel', 'endResetModel', 'countChanged', 'emit'
        pass

    def update_row(self, row_index: 'int', patch: 'dict[str, Any]') -> 'bool':
        # [PyArmor BCC constants]: 'warn_if_off_gui', 'type', '__name__', '.update_row', 0, 'len', '_rows', False, 'items', '_role_by_name', 'get', 'update', 'index', 'dataChanged', 'emit'
        pass

    def rows(self) -> 'list[dict[str, Any]]':
        pass


# --- Class: TimeMachineGridModel ---
class TimeMachineGridModel(_RoleListModel):
    ROLE_NAMES = ('rowIdx', 'viewId', 'viewLabel', 'stageIdx', 'status', 'imagePath', 'locked', 'onTimeline', 'edgeToNext', 'seqBadge', '...
    staticMetaObject = PySide6.QtCore.QMetaObject("TimeMachineGridModel" inherits "_RoleListModel":
)

    def __init__(self, parent: 'QtCore.QObject | None' = None) -> 'None':
        pass

    def set_rows(self, rows: 'Iterable[dict[str, Any]]') -> 'None':
        pass

    def update_cell(self, view_id: 'str', stage: 'int', patch: 'dict[str, Any]') -> 'bool':
        # [PyArmor BCC constants]: '_cell_index', 'get', 'str', 'int', False, 'update_row'
        pass


# --- Class: TimeMachineStageModel ---
class TimeMachineStageModel(_RoleListModel):
    ROLE_NAMES = ('stageIdx', 'name', 'visibleDescription')
    staticMetaObject = PySide6.QtCore.QMetaObject("TimeMachineStageModel" inherits "_RoleListModel":
)


# --- Class: TimeMachineViewModel ---
class TimeMachineViewModel(_RoleListModel):
    ROLE_NAMES = ('rowIdx', 'viewId', 'label', 'anchorPath')
    staticMetaObject = PySide6.QtCore.QMetaObject("TimeMachineViewModel" inherits "_RoleListModel":
)


# --- Class: TimeMachineTimelineModel ---
class TimeMachineTimelineModel(_RoleListModel):
    ROLE_NAMES = ('seq', 'viewId', 'viewLabel', 'stageIdx', 'edgeToNext', 'badge')
    staticMetaObject = PySide6.QtCore.QMetaObject("TimeMachineTimelineModel" inherits "_RoleListModel":
)


# --- Class: TimeMachineMotionModel ---
class TimeMachineMotionModel(_RoleListModel):
    ROLE_NAMES = ('rowIdx', 'promptIdx', 'motionKey', 'viewId', 'viewLabel', 'fromStage', 'toStage', 'fromSeq', 'toSeq', 'editSeq', 'stat...
    staticMetaObject = PySide6.QtCore.QMetaObject("TimeMachineMotionModel" inherits "_RoleListModel":
)


# --- Class: TimeMachineChapterCellModel ---
class TimeMachineChapterCellModel(_RoleListModel):
    ROLE_NAMES = ('viewId', 'viewLabel', 'stageIdx', 'stageName', 'visibleDescription', 'status', 'imagePath', 'locked', 'isAnchor', 'sou...
    staticMetaObject = PySide6.QtCore.QMetaObject("TimeMachineChapterCellModel" inherits "_RoleListModel":
)


# --- Class: TimeMachineChapterModel ---
class TimeMachineChapterModel(_RoleListModel):
    ROLE_NAMES = ('rowIdx', 'viewId', 'label', 'storyOrder', 'contextFromPrevious', 'stageCount', 'clipCount', 'completedClipCount', 'gen...
    staticMetaObject = PySide6.QtCore.QMetaObject("TimeMachineChapterModel" inherits "_RoleListModel":
)

    def __init__(self, parent: 'QtCore.QObject | None' = None) -> 'None':
        pass

    def set_chapters(self, rows: 'Iterable[dict[str, Any]]') -> 'None':
        pass

    def update_cell(self, view_id: 'str', stage: 'int', patch: 'dict[str, Any]') -> 'bool':
        # [PyArmor BCC constants]: '_cells_by_view', 'get', 'str', False, 'enumerate', '_rows', 'int', 'stageIdx', 0, 'update_row'
        pass

