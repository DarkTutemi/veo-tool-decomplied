"""
Decompiled / Reconstructed Module: qml_app.controllers.i18n_controller

Docstring:
QML-facing i18n adapter using the existing resources/locales files.
"""

from __future__ import annotations
import sys, os, typing
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)

# --- Class: I18nController ---
class I18nController(QObject):
    """Expose existing JSON translations to QML without duplicating locale files."""
    staticMetaObject = PySide6.QtCore.QMetaObject("I18nController" inherits "QObject":
Properties:
  #1 "locale", QString [designable], notify=...

    localeChanged = Signal()
    revisionChanged = Signal()
    def __init__(self, default_locale: 'str' = 'vi') -> 'None':
        pass

    def locale(*args, **kwargs):
        pass

    def revision(*args, **kwargs):
        pass

    def t(self, key: 'str', fallback: 'str' = '') -> 'str':
        # [PyArmor BCC constants]: 'tr', 'replace', '&&', '&'
        pass

    def availableLocales(self) -> 'list[str]':
        pass

    def setLocale(self, locale: 'str') -> 'None':
        # [PyArmor BCC constants]: 'get_language', 'set_language', 1, '_revision', 'localeChanged', 'emit', 'revisionChanged'
        pass

