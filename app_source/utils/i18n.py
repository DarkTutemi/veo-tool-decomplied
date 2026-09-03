"""
Decompiled / Reconstructed Module: utils.i18n

Docstring:
i18n Module - Internationalization support for VEO3 Tool
Hỗ trợ đa ngôn ngữ cho UI (Vietnamese, English, ...)
"""

from __future__ import annotations
import sys, os, typing
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
Dict = typing.Dict
Optional = typing.Optional
_current_language = 'vi'
_translations = {}
_fallback_language = 'en'
LANGUAGE_NAMES = {'vi': '🇻🇳 Tiếng Việt', 'en': '🇺🇸 English', 'zh': '🇨🇳 中文', 'ja': '🇯🇵 日本語', 'ko': '🇰🇷 한국어'}

# --- Top-Level Functions ---
def get_locales_dir() -> pathlib.Path:
    # [PyArmor BCC constants]: 'getattr', 'sys', 'frozen', False, 'hasattr', '_MEIPASS', 'Path', 'executable', 'parent', '_internal', 'resources', 'locales', 'exists', '__file__'
    pass

def load_translations(language: str) -> Dict[str, str]:
    # [PyArmor BCC constants]: 'get_locales_dir', '.json', 'exists', 'open', 'r', 'encoding', 'utf-8', 'json', 'load', 'print', '[i18n] Error loading ', '.json: ', 'Exception'
    pass

def init_i18n(language: str = 'vi'):
    # [PyArmor BCC constants]: '_current_language', 'load_translations', '_translations', '_fallback_language', 'os', 'environ', 'get', 'VEOFLOW_VERBOSE_INIT', '1', 'print', '[i18n] Initialized with language: ', '[i18n] Loaded ', 'len', ' translations'
    pass

def set_language(language: str):
    # [PyArmor BCC constants]: '_translations', 'load_translations', '_current_language', 'os', 'environ', 'get', 'VEOFLOW_VERBOSE_INIT', '1', 'print', '[i18n] Language changed to: '
    pass

def get_language() -> str:
    pass

def get_available_languages() -> list:
    # [PyArmor BCC constants]: 'get_locales_dir', 'exists', 'vi', 'en', 'glob', '*.json', 'append', 'stem'
    pass

def tr(key: str, **kwargs) -> str:
    # [PyArmor BCC constants]: '_get_translation', '_current_language', '_fallback_language', 'format', 'KeyError', '&', '<', 'replace', '&&'
    pass

def _get_translation(key: str, language: str) -> Optional[str]:
    # [PyArmor BCC constants]: '_translations', 'get', 'split', '.', 'isinstance', 'dict', 'str'
    pass

def _(key: str, **kwargs) -> str:
    # [PyArmor BCC constants]: '_get_translation', '_current_language', '_fallback_language', 'format', 'KeyError', '&', '<', 'replace', '&&'
    pass
