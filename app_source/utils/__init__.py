"""
Decompiled / Reconstructed Module: utils.__init__

Docstring:
Utility module for VEO3 Tool v2.0
"""

from __future__ import annotations
import sys, os, typing
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['require_license', 'FileUtils']

# --- Module Constants & Globals ---
__all__ = ['require_license', 'FileUtils']

# --- Class: FileUtils ---
class FileUtils:
    """File utility functions"""
    @staticmethod
    def create_cookies_folder():
        # [PyArmor BCC constants]: 'os', 'environ', 'get', 'APPDATA', 'path', 'expanduser', '~', 'join', 'VEO3_Generator_Pro', 'Cookies', 'makedirs', 'exist_ok', True, 'print', 'Error creating Cookies folder: '
        pass

    @staticmethod
    def ensure_folder_exists(folder_path):
        # [PyArmor BCC constants]: 'os', 'path', 'exists', 'makedirs', 'print', '✅ Created folder: ', True, '❌ Error creating folder ', ': ', False, 'Exception'
        pass

    @staticmethod
    def get_app_directory():
        # [PyArmor BCC constants]: 'getattr', 'sys', 'frozen', False, 'os', 'path', 'dirname', 'executable', 'abspath', '__file__'
        pass

