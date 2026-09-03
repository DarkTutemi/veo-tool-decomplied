"""
Decompiled / Reconstructed Module: qml_app.models.omni_profile_filter_model

Docstring:
Filtered view of the approved OmniVoice profile catalogue.
"""

from __future__ import annotations
import sys, os, typing
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)

# --- Class: OmniProfileFilterModel ---
class OmniProfileFilterModel(QSortFilterProxyModel):
    """Filter a DictListModel without copying it back into a QVariantList."""
    staticMetaObject = PySide6.QtCore.QMetaObject("OmniProfileFilterModel" inherits "QSortFilterProxyModel":
Methods:
  #101 type=Slot, signatu...

    def __init__(self, parent: 'Any' = None) -> 'None':
        pass

    def setFilter(self, query: 'str', mode: 'str', selected_id: 'str') -> 'None':
        # [PyArmor BCC constants]: 'str', '', 'strip', 'casefold', 'lower', 'selected', '_query', '_selection_only', '_selected_id', 'getattr', 'beginFilterChange', 'endFilterChange', 'QtCore', 'QSortFilterProxyModel', 'Direction'
        pass

    def filterAcceptsRow(self, source_row: 'int', source_parent: 'QtCore.QModelIndex') -> 'bool':
        # [PyArmor BCC constants]: 'name', 'label', 'kind', 'quality', 'language'
        pass

