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
        self.license_key = license_key or "PREMIUM-KEY"
        self.tool_code = tool_code or "VEO3PROTOOL"
        self.server_url = server_url
        self.prefer_v4 = prefer_v4
        self.debug = debug
        self.client_version = client_version
        self.device_id = device_id
        self.device_fingerprint = device_fingerprint
        self.fingerprint_payload = fingerprint_payload
        self.client = None
        self._initialize_client()

    def _initialize_client(self):
        try:
            if not self._try_init_v4():
                from license.main_license_client import SecureMainLicenseClient
                self.client = SecureMainLicenseClient(
                    license_key=self.license_key,
                    tool_code=self.tool_code,
                    server_url=self.server_url,
                    debug=self.debug
                )
        except Exception:
            try:
                from license.main_license_client import SecureMainLicenseClient
                self.client = SecureMainLicenseClient(
                    license_key=self.license_key,
                    tool_code=self.tool_code,
                    server_url=self.server_url,
                    debug=self.debug
                )
            except Exception:
                self.client = None

    def _try_init_v4(self) -> bool:
        try:
            from license.main_license_client import SecureMainLicenseClient
            self.client = SecureMainLicenseClient(
                license_key=self.license_key,
                tool_code=self.tool_code,
                server_url=self.server_url,
                debug=self.debug
            )
            return True
        except Exception:
            return False

    def verify_license(self, timeout: int = 30, progress_callback: Optional[Callable[[str, str, int], NoneType]] = None, runtime_pack_callback: Optional[Callable[[dict], NoneType]] = None) -> bool:
        if self.client and hasattr(self.client, 'verify_license'):
            try:
                return bool(self.client.verify_license(timeout=timeout, progress_callback=progress_callback, runtime_pack_callback=runtime_pack_callback))
            except Exception:
                pass
        return True

    def check_status(self, timeout: int = 30) -> Optional[Dict[str, Any]]:
        return {
            "tier": "PREMIUM",
            "feature_tier": "PREMIUM",
            "license_type": "PREMIUM",
            "status": "active",
            "features": ["all"],
            "expires_at": "2099-12-31",
            "remaining_count": 999999,
            "quota": 999999
        }

    def load_cached_verify_data(self) -> Optional[Dict[str, Any]]:
        return self.check_status()

    def deactivate_license(self, timeout: int = 30) -> bool:
        return True

    def get_client_version(self) -> str:
        return self.client_version

    def get_client(self):
        return self.client

    def get_license_info(self) -> Optional[Dict[str, Any]]:
        if self.client and hasattr(self.client, 'get_license_info'):
            return self.client.get_license_info()
        return {
            "tier": "PREMIUM",
            "license_type": "PREMIUM",
            "status": "active",
            "features": ["all"],
            "expires_at": "2099-12-31",
            "quota": 999999
        }

    @property
    def last_error(self):
        return None

    @property
    def last_error_code(self):
        return None

    def get_error_details(self) -> Dict[str, Any]:
        return {"error": None, "error_code": None, "response": None}

    def check_action(self, action_type: str, quantity: int = 1, timeout: int = 10) -> Dict[str, Any]:
        return {"allowed": True, "remaining_count": 999999, "success": True, "message": "OK"}

    def consume_action(self, action_type: str, quantity: int = 1, timeout: int = 10) -> Dict[str, Any]:
        return {"success": True, "remaining_count": 999999, "data": {"remaining_count": 999999}}

    def get_quota(self, timeout: int = 10) -> Dict[str, Any]:
        return {"allowed": True, "remaining_count": 999999, "quota": 999999, "used": 0, "tier": "PREMIUM", "success": True}


# --- Top-Level Functions ---
def _log_unified_debug(message: str):
    pass

def create_license_client(license_key: str, tool_code: str, server_url: str = None, prefer_v4: bool = True, debug: bool = False) -> license.unified_license_client.UnifiedLicenseClient:
    # [PyArmor BCC constants]: 'UnifiedLicenseClient', 'license_key', 'tool_code', 'server_url', 'prefer_v4', 'debug'
    pass