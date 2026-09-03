"""
Decompiled / Reconstructed Module: utils.decorators

Docstring:
Decorators for VEO3 Tool v2.0
Contains license and other decorators
"""

from __future__ import annotations
import sys, os, typing
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['require_license', 'require_paid_license']

# --- Module Constants & Globals ---
LICENSE_AVAILABLE = None
__all__ = ['require_license', 'require_paid_license']

# --- Top-Level Functions ---
def _check_license_available():
    # [PyArmor BCC constants]: 'LICENSE_AVAILABLE', 'UnifiedLicenseClient', True, False, 'ImportError'
    pass

def require_license(func):
    # [PyArmor BCC constants]: 'bool', 'getattr', 'sys', 'frozen', False, 'hasattr', '_check_license_or_block', 'operation_name', '__name__', 'show_error_ui', True, 'print', 'Central gate error: ', 'Exception', '_check_license_available'
    pass

def require_paid_license(func):
    # [PyArmor BCC constants]: 'require_license', 'functools', 'wraps'
    pass
