"""
Decompiled / Reconstructed Module: qml_app.models.prompt_card_list_model

Docstring:
QAbstractListModel projection for WorkPanel prompt cards.
"""

from __future__ import annotations
import sys, os, typing
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
_PROMPT_CARD_ROLE_NAMES = ('cardData', 'cardId', 'title', 'prompt', 'selected', 'status', 'referencePreviews', 'referenceImages', 'referenceImageIds', 'refCount')
_BASE_ROLE = 257
_ROLE_BY_NAME = {'cardData': 257, 'cardId': 258, 'title': 259, 'prompt': 260, 'selected': 261, 'status': 262, 'referencePreviews': 263, 'referenceImages': 264, 'referenceImageIds': 265, 'refCount': 266}
_NAME_BY_ROLE = {257: 'cardData', 258: 'cardId', 259: 'title', 260: 'prompt', 261: 'selected', 262: 'status', 263: 'referencePreviews', 264: 'referenceImages', 265: 'referenceImageIds', 266: 'refCount'}

# --- Class: PromptCardListModel ---
class PromptCardListModel(QAbstractListModel):
    """
    Expose prompt cards to QML without copying a QVariantList on every bind.
    
        ARCHITECTURE NOTE:
        Batch workspaces should bind to this model for large prompt-card lists.
        The legacy ``cards`` QVariantList remains for small/old surfaces only; using
        it for 500-1000 batch cards forces large Python->QML list copies.
    """
    CardDataRole = 257
    _ALL_ROLES = [257, 258, 259, 260, 261, 262, 263, 264, 265, 266]
    staticMetaObject = PySide6.QtCore.QMetaObject("PromptCardListModel" inherits "QAbstractListModel":
Properties:
  #1 "count", int [designabl...

    countChanged = Signal()
    def __init__(self, parent: 'QtCore.QObject | None' = None) -> 'None':
        pass

    @staticmethod
    def _card_id(card: 'Any') -> 'str':
        # [PyArmor BCC constants]: 'isinstance', 'dict', '', 'str', 'get', 'id', 'row_id', 'batch_id', 'strip'
        pass

    def _rebuild_index(self) -> 'None':
        # [PyArmor BCC constants]: 'enumerate', '_cards', '_card_id', '_id_to_row'
        pass

    def rowCount(self, parent: 'QtCore.QModelIndex' = <PySide6.QtCore.QModelIndex(-1,-1,0x0,QObject(0x0)) at 0x000001DFC08DED80>) -> 'int':
        # [PyArmor BCC constants]: 'isValid', 0, 'len', '_cards'
        pass

    def count(*args, **kwargs):
        pass

    def data(self, index: 'QtCore.QModelIndex', role: 'int' = 0) -> 'Any':
        # [PyArmor BCC constants]: 'isValid', 'int', 'row', 0, 'len', '_cards', '_NAME_BY_ROLE', 'get', 'cardData', 'cardId', 'str', 'id', 'row_id', 'batch_id', ''
        pass

    def roleNames(self) -> "dict[int, __assert_armored__((QtCore, b'\\x81\\xb4\\xb9\\x0cH\\xb4\\xdfT\\xa5(\\xb4'))]":
        # [PyArmor BCC constants]: '_ROLE_BY_NAME', 'items', 'QtCore', 'QByteArray', 'encode', 'utf-8'
        pass

    def set_cards(self, cards: 'list[dict[str, Any]]') -> 'None':
        # [PyArmor BCC constants]: 'warn_if_off_gui', 'PromptCardListModel.set_cards', 'list', 'isinstance', 'dict', 'len', '_cards', '_crumb', 'cardmodel', 'set_cards(reset)', 'n', 'prev', 'beginResetModel', '_rebuild_index', 'endResetModel'
        pass

    def apply_rows(self, cards: 'list[dict[str, Any]]') -> 'None':
        # [PyArmor BCC constants]: 'warn_if_off_gui', 'PromptCardListModel.apply_rows', 'list', 'isinstance', 'dict', '_cards', '_card_id', 'enumerate', 'index', 0, 'dataChanged', 'emit', '_ALL_ROLES', 'len', 'range'
        pass

    def upsert_row(self, card: 'dict[str, Any]') -> 'None':
        # [PyArmor BCC constants]: 'isinstance', 'dict', 'warn_if_off_gui', 'PromptCardListModel.upsert_row', '_card_id', '_id_to_row', 'get', 0, 'len', '_cards', 'index', 'dataChanged', 'emit', '_ALL_ROLES', 'beginInsertRows'
        pass

    def remove_card(self, card_id: 'str') -> 'bool':
        # [PyArmor BCC constants]: '_id_to_row', 'get', 'str', '', 'strip', 0, 'len', '_cards', False, 'beginRemoveRows', 'QtCore', 'QModelIndex', '_rebuild_index', 'endRemoveRows', 'countChanged'
        pass

    def cards(self) -> 'list[dict[str, Any]]':
        pass

