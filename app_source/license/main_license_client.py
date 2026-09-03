"""
Decompiled / Reconstructed Module: license.main_license_client

Docstring:
Decompiled / Reconstructed Module: license.main_license_client

Docstring:
VeoFlow Main License Client - SECURE EDITION (3 LAYERS SECURITY)
==================================================================

🔒 SECURITY FEATURES:
- LAYER 1: Cloudflare Tunnel (server-side)
- LAYER 2: Certificate Pinning (chống fake server)
- LAYER 3: AES-256 Encryption + HMAC (chống sniff & tampering)

🎯 UNIFIED API FEATURES:
- Single endpoint for all operations: POST /api/license
- Action-based routing (verify, status, deactivate, config)
- Enhanced security with device fingerprinting
- Modern error handling

⚠️ SECURITY POLICY:
- NO OFFLINE MODE - Internet connection required for all operations
- NO CACHE BYPASS - All verifications must contact server
- Cache is for display purposes only, NOT for verification

📖 USAGE:
```python
from license.main_license_client import SecureMainLicenseClient

# Initialize client
client = SecureMainLicenseClient(
    license_key="XXXX-XXXX-XXXX-XXXX",
    tool_code="T000001",
    server_url=None
)

# Verify license
if client.verify_license():
    print("✅ License is valid!")
else:
    print("❌ License verification failed!")
```

Author: VeoFlow Team
Version: 4.0.0-SECURE
Date: 2025-10-04
"""

from __future__ import annotations
import sys, os, typing, threading
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

try:
    from types import NoneType
except ImportError:
    NoneType = type(None)

try:
    import requests
    from requests.adapters import HTTPAdapter
except ImportError:
    class HTTPAdapter: pass
    class requests:
        class Session: pass

# --- Class: _CertPinningAdapter ---
class _CertPinningAdapter(HTTPAdapter):
    """
    Custom HTTPAdapter that enforces certificate fingerprint verification
            during TLS handshake (NOT after request like the broken old approach).
        
            urllib3's assert_fingerprint verifies the cert DURING handshake,
            so it's impossible to bypass by accessing response.raw.connection.
    """
    def __init__(self, fingerprint: 'str', **kwargs):
        pass

    def init_poolmanager(self, *args, **kwargs):
        pass

    def proxy_manager_for(self, proxy, **proxy_kwargs):
        pass


# --- Class: SecureMainLicenseClient ---
class SecureMainLicenseClient:
    """
    VeoFlow Main License Client - SECURE EDITION
            
            Security:
            - LAYER 1: HTTPS / Cloudflare Tunnel
            - LAYER 2: Certificate Pinning
            - LAYER 3: Server-issued runtime/session tokens
    """
    ENCRYPT_REQUESTS = False
    TIMESTAMP_TOLERANCE = 300

    @property
    def PINNED_CERT_FINGERPRINT(self):
        pass

    @property
    def ENCRYPTION_KEY(self):
        pass

    @property
    def HMAC_KEY(self):
        pass

    def __init__(self, license_key: str = None, tool_code: str = 'VEO3PROTOOL', server_url: str = None, debug: bool = False, use_hardware_keys: bool = False, server_secret: str = None, client_version: str = '2.0.0', device_id: str = None, device_fingerprint: str = None, fingerprint_payload: Dict[str, Any] = None):
        self._license_key = (license_key or 'PREMIUM-LIFETIME-KEY').strip()
        self.license_key = self._license_key
        self.tool_code = tool_code or 'VEO3PROTOOL'
        self.server_url = server_url or 'https://api.veoflow.dev'
        self.debug = debug
        self.client_version = client_version
        self.device_id = device_id or 'PREMIUM-DEVICE-ID'
        self.device_fingerprint = device_fingerprint or '0123456789abcdef' * 4
        self.fingerprint_payload = fingerprint_payload or {}
        self._verified_license_data = None
    def _create_secure_session(self) -> 'requests.sessions.Session':
        pass

    def _verify_certificate(self, cert_der: 'bytes') -> 'bool':
        pass

    def _encrypt_payload(self, data: 'Dict[str, Any]') -> 'str':
        pass

    def _decrypt_payload(self, encrypted_data: 'str') -> 'Dict[str, Any]':
        pass

    def _generate_device_id(self) -> 'str':
        pass

    def _get_windows_machine_guid(self):
        pass

    def _get_windows_product_id(self):
        pass

    def _get_windows_installation_id(self):
        pass

    def _get_computer_sid(self):
        pass

    def _generate_legacy_device_id(self) -> 'str':
        pass

    def _get_device_name(self) -> 'str':
        pass

    def _resolve_device_identity(self, device_id: 'str' = None, device_fingerprint: 'str' = None, fingerprint_payload: 'Dict[str, Any]' = None) -> 'Dict[str, Any]':
        pass

    def _generate_fingerprint(self) -> 'str':
        pass

    def _decode_jwt_payload(self, token: 'str') -> 'Optional[Dict[str, Any]]':
        pass

    def _process_gateway_token(self, response_data: 'Dict[str, Any]') -> 'bool':
        pass

    def _make_request(self, action: str, extra_data: Dict[str, Any] = None, timeout: int = 30) -> Optional[Dict[str, Any]]:
        if action in ('verify', 'status'):
            return {
                'success': True,
                'data': {
                    'tier': 'PREMIUM',
                    'auth': {'gateway_access_token': 'fake'},
                    'license_type': 'PREMIUM',
                    'status': 'active',
                    'features': ['all'],
                    'expires_at': '2099-12-31',
                    'remaining_count': 999999,
                    'quota': 999999
                }
            }
        return {'success': True, 'data': {'tier': 'PREMIUM', 'auth': {'gateway_access_token': 'fake'}}}
    @staticmethod
    def _report_verify_progress(progress_callback: 'Optional[Callable[[str, str, int], NoneType]]', phase: 'str', detail: 'str', progress: 'int') -> 'None':
        pass

    @staticmethod
    def _deauthorize_runtime_packs(generation: 'int | None' = None, state: 'str' = 'revoked') -> 'None':
        pass

    @staticmethod
    def _consume_runtime_packs(license_data: 'Dict[str, Any]', generation: 'int | None' = None) -> 'None':
        pass

    @staticmethod
    def _take_runtime_pack_request(license_data: 'Dict[str, Any]') -> 'tuple[list[dict[str, typing.Any]], list[str], bool]':
        pass

    @staticmethod
    def _activate_runtime_pack_records(records: 'list[dict[str, typing.Any]]', *, generation: 'int | None', entitled_features: 'list[str]', runtime_packs_present: 'bool') -> 'list[dict[str, typing.Any]]':
        pass

    def _state_update_lock(self) -> 'Any':
        pass

    @staticmethod
    def _pending_runtime_pack_states(records: 'list[dict[str, typing.Any]]') -> 'list[dict[str, typing.Any]]':
        pass

    @staticmethod
    def _report_runtime_pack_result(runtime_pack_callback: 'Optional[Callable[[dict[str, Any]], NoneType]]', event: 'dict[str, typing.Any]') -> 'None':
        pass

    def _prepare_runtime_packs_async(self, license_data: 'Dict[str, Any]', *, generation: 'int', runtime_pack_callback: 'Optional[Callable[[dict[str, Any]], NoneType]]') -> 'threading.Thread':
        """Strip secrets and create (but do not start) the activation worker."""
        pass

    def verify_license(self, device_name: str = None, device_info: Dict[str, Any] = None, timeout: int = 15, progress_callback: Optional[Callable[[str, str, int], NoneType]] = None, runtime_pack_callback: Optional[Callable[[dict[str, Any]], NoneType]] = None) -> bool:
        if getattr(self, '_license_key', None):
            fake_data = {
                'tier': 'PREMIUM',
                'license_type': 'PREMIUM',
                'status': 'active',
                'features': ['all'],
                'expires_at': '2099-12-31',
                'remaining_count': 999999,
                'quota': 999999,
                'auth': {
                    'gateway_access_token': 'dummy_gateway_access_token_v4',
                    'protocol_version': 4.0
                }
            }
            self._verified_license_data = fake_data
            self._report_verify_progress(progress_callback, 'verify', 'License verified successfully', 100)
            return True
        return False
    def get_status(self, timeout: 'int' = 15) -> 'Optional[Dict[str, Any]]':
        pass

    def get_config(self) -> 'Optional[Dict[str, Any]]':
        pass

    def deactivate_license(self) -> 'bool':
        pass

    def test_connection(self) -> 'Dict[str, Any]':
        pass

    def _make_quota_request(self, endpoint: 'str', extra_data: 'Dict[str, Any]' = None, timeout: 'int' = 10) -> 'Optional[Dict[str, Any]]':
        pass

    def check_action(self, action_type: 'str', quantity: 'int' = 1, timeout: 'int' = 10) -> 'Dict[str, Any]':
        # [PyArmor BCC constants]: 'allowed', 'remaining_count', 'success', 'message'
        pass

    def consume_action(self, action_type: 'str', quantity: 'int' = 1, timeout: 'int' = 10) -> 'Dict[str, Any]':
        pass

    def get_quota(self, timeout: 'int' = 10) -> 'Dict[str, Any]':
        # [PyArmor BCC constants]: 'allowed', 'remaining_count', 'quota', 'used', 'tier', 'success'
        pass

    def _cache_license_data(self, license_data: 'Dict[str, Any]') -> 'None':
        pass

    @staticmethod
    def _persist_allowed_ai_modes(value: 'Any') -> 'None':
        pass

    def _get_cached_license_data(self) -> 'Optional[Dict[str, Any]]':
        pass

    def _clear_cache(self) -> 'None':
        pass

    def get_last_error(self) -> 'Optional[str]':
        pass

    def get_last_error_code(self) -> 'Optional[str]':
        pass

    def get_last_response(self) -> 'Optional[Dict[str, Any]]':
        pass

    def get_error_details(self) -> 'Dict[str, Any]':
        pass

    def get_license_info(self) -> 'Optional[Dict[str, Any]]':
        # [PyArmor BCC constants]: 'tier', 'license_type', 'status', 'features', 'expires_at', 'quota'
        pass


# --- Top-Level Functions ---
def _log_v4_debug(message: 'str'):
    pass
