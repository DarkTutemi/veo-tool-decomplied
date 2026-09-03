"""
Decompiled / Reconstructed Module: application.readiness_service
Source PyC: readiness_service.pyc

Docstring:
Headless readiness manifest for the QML shell and internal API migration.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['get_readiness_manifest', 'get_home_readiness_manifest']

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
List = typing.List
Literal = typing.Literal
ReadinessState = typing.Literal['ready', 'partial', 'blocked']
_ITEMS = [ReadinessItem(area='qml_app_shell', state='ready', endpoints=[], notes='Top-level QML shell/navigation state is QML-local and no longer depends on PyQt Widgets or a separate app-shell HTTP slice.', b... [truncated]
_NAVIGATION_ACTIONS = [{'actionId': 'home.route.master', 'kind': 'route', 'route': 'master', 'capability': 'master_panel', 'titleKey': 'qml.home.feature_master', 'descKey': 'qml.home.feature_master_desc', 'fallbackTitle': ... [truncated]
_QUICK_ACTIONS = [{'actionId': 'home.refresh', 'kind': 'refresh', 'labelKey': 'common.refresh', 'fallbackLabel': 'Refresh', 'icon': 'RF', 'state': 'ready', 'notes': 'Refreshes local QML home summary/readiness without ... [truncated]
_STRUCTURED_BLOCKERS = []
__all__ = ['get_readiness_manifest', 'get_home_readiness_manifest']

# --- Class: ReadinessItem ---
class ReadinessItem:
    """ReadinessItem(area: 'str', state: 'ReadinessState', endpoints: 'List[str]', notes: 'str', blockers: 'List[str]')"""
    def to_dict(self) -> 'Dict[str, Any]':
        pass

    def __init__(self, area: 'str', state: 'ReadinessState', endpoints: 'List[str]', notes: 'str', blockers: 'List[str]') -> None:
        pass

    def __repr__(self):
        pass


# --- Top-Level Functions ---
def get_readiness_manifest() -> 'Dict[str, Any]':
    pass

def get_home_readiness_manifest() -> 'Dict[str, Any]':
    pass
