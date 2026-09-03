"""
Decompiled / Reconstructed Module: services.automation_center.__init__
Source PyC: __init__.pyc

Docstring:
Tool 1-owned, in-process Automation Center backend.

Importing the package is deliberately dormant: it does not import adapters,
open SQLite, start a thread, contact a server, or register anything with Qt.
The composition root is resolved only when a caller asks for it.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['AutomationCenterService']

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
TYPE_CHECKING = False
__all__ = ['AutomationCenterService']
