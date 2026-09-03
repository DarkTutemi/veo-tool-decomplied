"""
Decompiled / Reconstructed Module: core.captcha.contracts
Source PyC: contracts.pyc

Docstring:
Typed contracts for browser-farm acquisition.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Optional = typing.Optional

# --- Class: BrowserAcquireResult ---
class BrowserAcquireResult:
    """Outcome of obtaining one ready browser for an account."""
    browser = None
    error_category = ''
    error = ''
    retryable = True
    status = None
    success = <property object at 0x00000264DA5C78D0>

    @classmethod
    def ready(cls, browser: 'Any') -> "'BrowserAcquireResult'":
        pass

    @classmethod
    def failure(cls, error_category: 'str', error: 'str', retryable: 'bool' = True, status: 'Optional[int]' = None) -> "'BrowserAcquireResult'":
        pass

    def to_failure_dict(self) -> 'dict':
        pass

    def __init__(self, browser: 'Optional[Any]' = None, error_category: 'str' = '', error: 'str' = '', retryable: 'bool' = True, status: 'Optional[int]' = None) -> None:
        pass

    def __repr__(self):
        pass

