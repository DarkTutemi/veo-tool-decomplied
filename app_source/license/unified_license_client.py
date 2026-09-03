"""
Decompiled / Reconstructed Module: license.unified_license_client

Docstring:
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

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
List = typing.List
Optional = typing.Optional
Tuple = typing.Tuple
Union = typing.Union
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
    def __init__(self, license_key: 'str', tool_code: 'str', server_url: 'str' = None, prefer_v4: 'bool' = True, debug: 'bool' = False, client_version: 'str' = '92.0.117', device_id: 'str' = None, device_fingerprint: 'str' = None, fingerprint_payload: 'Dict[str, Any]' = None):
        pass

    def _initialize_client(self):
        # [PyArmor BCC constants]: 'license_key', 'tool_code', 'server_url', 'debug'
        pass

    def _try_init_v4(self) -> 'bool':
        # [PyArmor BCC constants]: 'license_key', 'tool_code', 'server_url', 'debug'
        pass

    def verify_license(self, timeout: 'int' = 30, progress_callback: 'Optional[Callable[[str, str, int], NoneType]]' = None, runtime_pack_callback: 'Optional[Callable[[dict], NoneType]]' = None) -> 'bool':
        # [PyArmor BCC constants]: 'success', 'tier', 'license_type', 'status', 'features', 'expires_at', 'remaining_count', 'quota', 'auth'
        pass

    def check_status(self, timeout: 'int' = 30) -> 'Optional[Dict[str, Any]]':
        # [PyArmor BCC constants]: 'tier', 'feature_tier', 'license_type', 'status', 'features', 'expires_at', 'remaining_count', 'quota'
        pass

    def load_cached_verify_data(self) -> 'Optional[Dict[str, Any]]':
        pass

    def deactivate_license(self, timeout: 'int' = 30) -> 'bool':
        pass

    def get_client_version(self) -> 'str':
        pass

    def get_client(self):
        pass

    def get_license_info(self) -> 'Optional[Dict[str, Any]]':
        # [PyArmor BCC constants]: 'tier', 'license_type', 'status', 'features', 'expires_at', 'quota'
        pass

    @property
    def last_error(self):
        pass

    @property
    def last_error_code(self):
        pass

    def get_error_details(self) -> 'Dict[str, Any]':
        pass

    def check_action(self, action_type: 'str', quantity: 'int' = 1, timeout: 'int' = 10) -> 'Dict[str, Any]':
        # [PyArmor BCC constants]: 'allowed', 'remaining_count', 'success', 'message'
        pass

    def consume_action(self, action_type: 'str', quantity: 'int' = 1, timeout: 'int' = 10) -> 'Dict[str, Any]':
        pass

    def get_quota(self, timeout: 'int' = 10) -> 'Dict[str, Any]':
        # [PyArmor BCC constants]: 'allowed', 'remaining_count', 'quota', 'used', 'tier', 'success'
        pass


# --- Top-Level Functions ---
def _log_unified_debug(message: 'str'):
    pass

def create_license_client(license_key: 'str', tool_code: 'str', server_url: 'str' = None, prefer_v4: 'bool' = True, debug: 'bool' = False) -> 'license.unified_license_client.UnifiedLicenseClient':
    pass
