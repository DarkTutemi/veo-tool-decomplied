"""
Decompiled / Reconstructed Module: application.taxonomy_service
Source PyC: taxonomy_service.pyc

Docstring:
Headless taxonomy service for themes and strategies.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
List = typing.List
Optional = typing.Optional
_LOCK = <unlocked _thread.RLock object owner=0 count=0 at 0x00000264D62B0A00>

# --- Class: TaxonomyError ---
class TaxonomyError(ValueError):
    def __init__(self, code: 'str', message: 'str') -> 'None':
        pass


# --- Class: TaxonomyService ---
class TaxonomyService:
    """CRUD facade for editable theme and strategy taxonomies."""
    def _themes_data(self) -> 'tuple[Path, Dict[str, Any]]':
        pass

    def _strategies_data(self) -> 'tuple[Path, Dict[str, Any]]':
        pass

    def list_themes(self, search: 'str' = '') -> 'Dict[str, Any]':
        pass

    def get_theme(self, theme_id: 'str') -> 'Dict[str, Any]':
        pass

    def validate_theme(self, theme_id: 'str') -> 'Dict[str, Any]':
        pass

    def create_theme(self, theme_id: 'str', name: 'str', keywords: 'Optional[List[Any]]' = None, description: 'str' = '') -> 'Dict[str, Any]':
        pass

    def update_theme(self, theme_id: 'str', name: 'Optional[str]' = None, keywords: 'Optional[List[Any]]' = None, description: 'Optional[str]' = None) -> 'Dict[str, Any]':
        pass

    def delete_theme(self, theme_id: 'str') -> 'Dict[str, Any]':
        pass

    def list_strategies(self, search: 'str' = '') -> 'Dict[str, Any]':
        pass

    def get_strategy(self, strategy_id: 'str') -> 'Dict[str, Any]':
        pass

    def validate_strategy(self, strategy_id: 'str') -> 'Dict[str, Any]':
        pass

    def create_strategy(self, strategy_id: 'str', display_name: 'str', description: 'str' = '') -> 'Dict[str, Any]':
        pass

    def update_strategy(self, strategy_id: 'str', display_name: 'Optional[str]' = None, description: 'Optional[str]' = None) -> 'Dict[str, Any]':
        pass

    def delete_strategy(self, strategy_id: 'str') -> 'Dict[str, Any]':
        pass

    def taxonomy_payload(self, search: 'str' = '') -> 'Dict[str, Any]':
        pass

    def management_payload(self, kind: 'str', search: 'str' = '') -> 'Dict[str, Any]':
        pass

    def theme_dialog_payload(self, theme_id: 'str' = '', search: 'str' = '') -> 'Dict[str, Any]':
        pass

    def strategy_dialog_payload(self, strategy_id: 'str' = '', search: 'str' = '') -> 'Dict[str, Any]':
        pass

    def save_theme_payload(self, payload: 'Dict[str, Any]') -> 'Dict[str, Any]':
        pass

    def save_strategy_payload(self, payload: 'Dict[str, Any]') -> 'Dict[str, Any]':
        pass

    def delete_theme_payload(self, theme_id: 'str') -> 'Dict[str, Any]':
        pass

    def delete_strategy_payload(self, strategy_id: 'str') -> 'Dict[str, Any]':
        pass

    def _error_payload(self, kind: 'str', exc: 'TaxonomyError') -> 'Dict[str, Any]':
        pass


# --- Top-Level Functions ---
def _json_path(filename: 'str') -> 'Path':
    pass

def _load_json(path: 'Path', default_key: 'str') -> 'Dict[str, Any]':
    pass

def _save_json(path: 'Path', data: 'Dict[str, Any]') -> 'None':
    pass

def _clean_string(value: 'Any') -> 'str':
    pass

def _clean_strings(values: 'Optional[List[Any]]') -> 'List[str]':
    pass

def _matches_query(item: 'Dict[str, Any]', query: 'str') -> 'bool':
    pass

def _theme_id(item: 'Dict[str, Any]') -> 'str':
    pass

def _strategy_id(item: 'Dict[str, Any]') -> 'str':
    pass

def _theme_response(item: 'Dict[str, Any]') -> 'Dict[str, Any]':
    pass

def _strategy_response(item: 'Dict[str, Any]') -> 'Dict[str, Any]':
    pass

def get_taxonomy_service() -> 'TaxonomyService':
    pass
