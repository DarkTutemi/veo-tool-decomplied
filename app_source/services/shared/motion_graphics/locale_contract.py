"""
Decompiled / Reconstructed Module: services.shared.motion_graphics.locale_contract
Source PyC: locale_contract.pyc

Docstring:
Output-locale and bundled-font contract for rendered Time graphics.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['font_directory', 'format_calendar_year', 'localized_viewer_terms', 'locale_instruction', 'resolve_output_locale', 'supported_language_codes']

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Mapping = typing.Mapping
_LANGUAGE_LOCALES = {'vi': ('vi-VN', 'latin', 'latn', 'vi'), 'en': ('en-US', 'latin', 'latn', 'en'), 'zh': ('zh-CN', 'cjk_sc', 'latn', 'zh'), 'ja': ('ja-JP', 'cjk_jp', 'latn', 'ja'), 'ko': ('ko-KR', 'cjk_kr', 'latn', 'ko... [truncated]
_FONT_PACKS = {'latin_display': ('Be Vietnam Pro', 'BeVietnamPro-SemiBold.ttf'), 'latin_editorial': ('Noto Serif', 'NotoSerif-SemiBold.ttf'), 'latin_data': ('IBM Plex Sans', 'IBMPlexSans-SemiBold.ttf'), 'latin_cond... [truncated]
_DATE_TERMS = {'vi': {'years_ago': 'năm trước', 'bce': 'TCN', 'ce': 'SCN', 'approx': 'xấp xỉ'}, 'ja': {'years_ago': '年前', 'bce': '紀元前', 'ce': '西暦', 'approx': '約'}, 'ko': {'years_ago': '년 전', 'bce': '기원전', 'ce': '서기... [truncated]
_YEAR_AFFIXES = {'vi': {'year_prefix': 'NĂM', 'year_suffix': '', 'year_joiner': ' '}, 'ja': {'year_prefix': '西暦', 'year_suffix': '年', 'year_joiner': ''}, 'ko': {'year_prefix': '서기', 'year_suffix': '년', 'year_joiner':... [truncated]
_VIEWER_TERMS = {'vi': {'milestone': 'Cột mốc', 'preview_chapter': 'CHƯƠNG 02 · HÀNH TRÌNH', 'timeline': 'DÒNG THỜI GIAN'}, 'en': {'milestone': 'Milestone', 'preview_chapter': 'CHAPTER 02 · JOURNEY', 'timeline': 'TIM... [truncated]
__all__ = ['font_directory', 'format_calendar_year', 'localized_viewer_terms', 'locale_instruction', 'resolve_output_locale', 'supported_language_codes']

# --- Top-Level Functions ---
def localized_viewer_terms(language: 'str') -> 'dict[str, str]':
    pass

def format_calendar_year(value: 'Any', locale_contract: 'Mapping[str, Any] | None' = None, value_format: 'str' = '') -> 'str':
    pass

def _font_key(script: 'str', role: 'str') -> 'str':
    pass

def resolve_output_locale(language: 'str', *, market: 'str' = 'global', language_source: 'str' = 'user_locked', font_role: 'str' = 'display') -> 'dict[str, Any]':
    pass

def supported_language_codes() -> 'tuple[str, ...]':
    pass

def locale_instruction(contract: 'Mapping[str, Any]') -> 'str':
    pass

def font_directory(contract: 'Mapping[str, Any]') -> 'str':
    pass
