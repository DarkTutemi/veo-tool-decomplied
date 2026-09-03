"""
Decompiled / Reconstructed Module: application.token_monitor_service
Source PyC: token_monitor_service.pyc

Docstring:
Headless service for credit/token usage monitoring.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
List = typing.List
Optional = typing.Optional
_MODEL_DISPLAY_NAMES = {'deep-research-pro-preview-12-2025': 'GEMINI - DEEP RESEARCH', 'gemini-3.1-flash-tts-preview': 'GEMINI - TTS 3.1', 'gemini-2.5-flash-preview-tts': 'GEMINI - TTS', 'gemini-2.5-pro-preview-tts': 'GEMIN... [truncated]
_FEATURE_LABELS = {'clone_video': 'Clone video', 'transcript_video': 'Transcript — dựng cảnh', 'transcript_map': 'Transcript — chia cảnh', 'image_story': 'Ảnh kể chuyện', 'affiliate_video': 'Affiliate', 'image_video': ... [truncated]

# --- Class: TokenMonitorService ---
class TokenMonitorService:
    """Facade around CreditHistoryStore with API-ready shapes."""
    def __init__(self) -> 'None':
        pass

    def history(self, days: 'int' = 1, model: 'Optional[str]' = None) -> 'Dict[str, Any]':
        pass

    def summary(self, days: 'int' = 1) -> 'Dict[str, Any]':
        pass

    def models(self, days: 'int' = 1) -> 'Dict[str, Any]':
        pass

    def snapshot(self, days: 'int' = 1, model: 'Optional[str]' = None) -> 'Dict[str, Any]':
        pass

    def export_csv(self, days: 'int' = 1, model: 'Optional[str]' = None) -> 'Dict[str, Any]':
        pass

    def clear_history(self) -> 'Dict[str, Any]':
        pass


# --- Top-Level Functions ---
def _days(value: 'int') -> 'int':
    pass

def _display_model(raw: 'str') -> 'str':
    pass

def _feature_label(raw: 'str') -> 'str':
    pass

def _entry_id(entry: 'Dict[str, Any]') -> 'str':
    pass

def _safe_float(value: 'Any', fallback: 'float' = 0.0) -> 'float':
    pass

def _entry_cost(entry: 'Dict[str, Any]') -> 'float':
    pass

def _entry_currency(entry: 'Dict[str, Any]') -> 'str':
    pass

def _entry_response(entry: 'Dict[str, Any]') -> 'Dict[str, Any]':
    pass

def _summary_response(summary: 'Dict[str, Any]') -> 'Dict[str, Any]':
    pass

def get_token_monitor_service() -> 'TokenMonitorService':
    pass
