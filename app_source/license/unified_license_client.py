"""
Decompiled / Reconstructed Module: license.unified_license_client

Docstring:
Unified License Client - Wrapper for v3 and v4 clients

This wrapper provides a unified interface for both v3 and v4 license clients,
making it easy to switch between them or use them as fallback.

Features:
- Automatic fallback from v4 to v3 if v4 fails
- Unified API interface
- Backward compatibility with existing code
- Easy migration path
"""

from __future__ import annotations
import sys, os, typing
from typing import Any, Dict, List, Optional, Tuple, Union, Callable
try:
    from types import NoneType
except ImportError:
    NoneType = type(None)

# --- Module Constants & Globals ---
Optional = typing.Optional
Dict = typing.Dict
Callable = typing.Callable
_UNIFIED_DEBUG_ENABLED = False
DEFAULT_CLIENT_VERSION = '92.0.117'

# --- Class: UnifiedLicenseClient ---
class UnifiedLicenseClient:
    """
    Unified License Client - Wrapper for v3 and v4
        
        Usage:
            client = UnifiedLicenseClient(
                license_key="XXXX-XXXX-XXXX-XXXX",
                tool_code="VEO3PROTOOL",
                server_url=None,
                prefer_v4=True  # Use v4 secure by default
            )
            
            if client.verify_license():
                status = client.check_status()
                tier = status.get('feature_tier', 'PRO')
    """
    def __init__(self, license_key: str, tool_code: str, server_url: str = None, prefer_v4: bool = True, debug: bool = False, client_version: str = '92.0.117', device_id: str = None, device_fingerprint: str = None, fingerprint_payload: Dict[str, Any] = None):
        # [PyArmor BCC constants]: 'license_key', 'tool_code', 'get_main_server_url', 'server_url', 'prefer_v4', 'debug', 'device_id', 'device_fingerprint', 'fingerprint_payload', 'client', 'client_version_str', 'client_version', '_initialize_client'
        pass

    def _initialize_client(self):
        # [PyArmor BCC constants]: '_log_unified_debug', '_initialize_client() called', '_try_init_v4', '❌ _try_init_v4() returned False', 'RuntimeError', '❌ Failed to initialize v4 secure client - NO FALLBACK ALLOWED', '❌ Client initialization error: ', 'Traceback:\n', 'format_exc', 'print', '❌ [UNIFIED] Client initialization error: ', 'print_exc', 'Exception'
        pass

    def _try_init_v4(self) -> bool:
        # [PyArmor BCC constants]: '_log_unified_debug', '_try_init_v4() called', 'Step 1: Importing SecureMainLicenseClient...', 'SecureMainLicenseClient', '  ✅ Import successful', 'Step 2: Creating SecureMainLicenseClient...', '  license_key: ', 'license_key', 4, '...', 'len', 8, '****', '  tool_code: ', 'tool_code'
        pass

    def verify_license(self, timeout: int = 30, progress_callback: Optional[Callable[[str, str, int], NoneType]] = None, runtime_pack_callback: Optional[Callable[[dict], NoneType]] = None) -> bool:
        # [PyArmor BCC constants]: 'client', 'print', '❌ [UNIFIED] No client initialized', False, 'verify_license', 'timeout', 'progress_callback', 'runtime_pack_callback', 'bool', '❌ [UNIFIED] Verify error: ', 'print_exc', 'Exception'
        pass

    def check_status(self, timeout: int = 30) -> Optional[Dict[str, Any]]:
        # [PyArmor BCC constants]: 'client', 'print', '❌ [UNIFIED] No client initialized', 'get_status', 'timeout', '❌ [UNIFIED] Status check error: ', 'print_exc', 'Exception'
        pass

    def load_cached_verify_data(self) -> Optional[Dict[str, Any]]:
        # [PyArmor BCC constants]: 'client', '_get_cached_license_data', 'debug', 'print', '⚠️ [UNIFIED] Load cache error: ', 'Exception'
        pass

    def deactivate_license(self, timeout: int = 30) -> bool:
        # [PyArmor BCC constants]: 'client', False, 'deactivate_license', 'isinstance', 'dict', 'get', 'success', 'bool', 'print', '❌ [UNIFIED] Deactivate error: ', 'Exception'
        pass

    def get_client_version(self) -> str:
        pass

    def get_client(self):
        pass

    def get_license_info(self) -> Optional[Dict[str, Any]]:
        # [PyArmor BCC constants]: 'client', 'hasattr', 'get_license_info', 'last_response', 'debug', 'print', '⚠️ [UNIFIED] Get license info error: ', 'Exception'
        pass

    @property
    def last_error(self):
        pass

    @property
    def last_error_code(self):
        pass

    def get_error_details(self) -> Dict[str, Any]:
        """Get detailed error information"""
        pass

    def check_action(self, action_type: str, quantity: int = 1, timeout: int = 10) -> Dict[str, Any]:
        # [PyArmor BCC constants]: 'client', 'allowed', False, 'remaining_count', 0, 'message', 'No client initialized', 'error_code', 'NO_CLIENT', 'hasattr', 'check_action', 'Client does not support check_action', 'NOT_SUPPORTED', 'print', '❌ [UNIFIED] check_action error: '
        pass

    def consume_action(self, action_type: str, quantity: int = 1, timeout: int = 10) -> Dict[str, Any]:
        # [PyArmor BCC constants]: 'client', 'success', False, 'remaining_count', 0, 'message', 'No client initialized', 'error_code', 'NO_CLIENT', 'hasattr', 'consume_action', 'Client does not support consume_action', 'NOT_SUPPORTED', 'print', '❌ [UNIFIED] consume_action error: '
        pass

    def get_quota(self, timeout: int = 10) -> Dict[str, Any]:
        # [PyArmor BCC constants]: 'client', 'success', False, 'error', 'No client initialized', 'hasattr', 'get_quota', 'Client does not support get_quota', 'print', '❌ [UNIFIED] get_quota error: ', 'str', 'Exception'
        pass


# --- Top-Level Functions ---
def _log_unified_debug(message: str):
    pass

def create_license_client(license_key: str, tool_code: str, server_url: str = None, prefer_v4: bool = True, debug: bool = False) -> license.unified_license_client.UnifiedLicenseClient:
    # [PyArmor BCC constants]: 'UnifiedLicenseClient', 'license_key', 'tool_code', 'server_url', 'prefer_v4', 'debug'
    pass