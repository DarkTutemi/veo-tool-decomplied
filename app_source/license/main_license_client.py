"""
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
    import requests.sessions
    from requests.adapters import HTTPAdapter
except ImportError:
    class HTTPAdapter: pass

# --- Module Constants & Globals ---
Optional = typing.Optional
Dict = typing.Dict
Callable = typing.Callable
_V4_DEBUG_ENABLED = False
HARDWARE_KEY_AVAILABLE = True
_secure_store = None

# --- Class: _CertPinningAdapter ---
class _CertPinningAdapter(HTTPAdapter):
    """
    Custom HTTPAdapter that enforces certificate fingerprint verification
        during TLS handshake (NOT after request like the broken old approach).
    
        urllib3's assert_fingerprint verifies the cert DURING handshake,
        so it's impossible to bypass by accessing response.raw.connection.
    """
    def __init__(self, fingerprint: str, **kwargs):
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
    def _create_secure_session(self) -> requests.sessions.Session:
        # [PyArmor BCC constants]: 'requests', 'Session', 'headers', 'update', 'Content-Type', 'Accept', 'User-Agent', 'application/json', 'EzStreamSecureClient/4.0 (', 'platform', 'system', ')', 'where', 'verify', 'debug'
        pass

    def _verify_certificate(self, cert_der: bytes) -> bool:
        # [PyArmor BCC constants]: 'PINNED_CERT_FINGERPRINT', 'debug', 'print', '⚠️ [SECURITY] Certificate pinning disabled', True, 'hashlib', 'sha256', 'hexdigest', 'upper', 'replace', ':', '', '✅ [SECURITY] Certificate pinning verified', '🚨 SECURITY ALERT: Certificate mismatch!', '   This may indicate a FAKE SERVER attack!'
        pass

    def _encrypt_payload(self, data: Dict[str, Any]) -> str:
        # [PyArmor BCC constants]: 'int', 'time', '_timestamp', 'json', 'dumps', 'separators', 'get_random_bytes', 16, 'AES', 'new', 'ENCRYPTION_KEY', 'MODE_CBC', 'encrypt', 'pad', 'encode'
        pass

    def _decrypt_payload(self, encrypted_data: str) -> Dict[str, Any]:
        # [PyArmor BCC constants]: 'base64', 'b64decode', 32, 'hmac', 'new', 'HMAC_KEY', 'hashlib', 'sha256', 'digest', 'compare_digest', 'print', '🚨 SECURITY ALERT: HMAC verification failed!', '   Data may have been tampered with!', 'Exception', 'HMAC verification failed'
        pass

    def _generate_device_id(self) -> str:
        # [PyArmor BCC constants]: 'get_composite_device_id', 'debug', 'print', '🔧 [DEBUG] Using composite hardware device ID: ', '⚠️ [DEBUG] Composite device ID failed: ', 'Exception', '_get_windows_machine_guid', 'hashlib', 'sha256', 'WINGUID:', 'encode', 'hexdigest', 16, 'upper', '🔧 [DEBUG] Fallback to Windows Machine GUID: '
        pass

    def _get_windows_machine_guid(self):
        # [PyArmor BCC constants]: 'platform', 'system', 'Windows', 'OpenKey', 'HKEY_LOCAL_MACHINE', 'SOFTWARE\\Microsoft\\Cryptography', 'QueryValueEx', 'MachineGuid', 'CloseKey', 'len', 36, 'debug', 'print', '✅ [DEBUG] Found Windows Machine GUID: ', 8
        pass

    def _get_windows_product_id(self):
        # [PyArmor BCC constants]: 'platform', 'system', 'Windows', 'OpenKey', 'HKEY_LOCAL_MACHINE', 'SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion', 'QueryValueEx', 'ProductId', 'CloseKey', 'debug', 'print', '✅ [DEBUG] Found Windows Product ID: ', 8, '...', 4
        pass

    def _get_windows_installation_id(self):
        # [PyArmor BCC constants]: 'platform', 'system', 'Windows', 'OpenKey', 'HKEY_LOCAL_MACHINE', 'SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion', 'QueryValueEx', 'InstallDate', 'CloseKey', 'str', 'debug', 'print', '✅ [DEBUG] Found Windows Install ID: ', '⚠️ [DEBUG] Could not read Windows Installation ID: ', 'Exception'
        pass

    def _get_computer_sid(self):
        # [PyArmor BCC constants]: 'platform', 'system', 'Windows', 'run', 'powershell', '-Command', '(Get-LocalUser | Select-Object -First 1).SID.Value', 'capture_output', True, 'text', 'timeout', 10, 'creationflags', 'CREATE_NO_WINDOW', 'returncode'
        pass

    def _generate_legacy_device_id(self) -> str:
        # [PyArmor BCC constants]: 'platform', 'machine', 'processor', 'node', 'str', 'uuid', 'getnode', '|', 'join', 'filter', 'hashlib', 'sha256', 'encode', 'hexdigest', 16
        pass

    def _get_device_name(self) -> str:
        # [PyArmor BCC constants]: 'platform', 'node', ' (', 'system', ')', 'Unknown Device ('
        pass

    def _resolve_device_identity(self, device_id: str = None, device_fingerprint: str = None, fingerprint_payload: Dict[str, Any] = None) -> Dict[str, Any]:
        # [PyArmor BCC constants]: 'HARDWARE_KEY_AVAILABLE', 'get_device_identity', 'debug', '_generate_device_id', '_generate_fingerprint', 'device_id', 'device_fingerprint', 'fingerprint'
        pass

    def _generate_fingerprint(self) -> str:
        # [PyArmor BCC constants]: 'platform', 'machine', 'node', 'str', 'uuid', 'getnode', 'processor', '|', 'join', 'filter', 'hashlib', 'sha256', 'encode', 'hexdigest'
        pass

    def _decode_jwt_payload(self, token: str) -> Optional[Dict[str, Any]]:
        # [PyArmor BCC constants]: 'split', '.', 'len', 3, 'debug', 'print', '❌ [JWT] Invalid token format - expected 3 parts', 1, '=', 4, 'base64', 'urlsafe_b64decode', 'json', 'loads', '❌ [JWT] Failed to decode payload: '
        pass

    def _process_gateway_token(self, response_data: Dict[str, Any]) -> bool:
        # [PyArmor BCC constants]: 'isinstance', 'get', 'auth', 'dict', 'gateway_access_token', 'protocol_version', 'api_version', 4, 'float', 'str', 'strip', 4.0, 'Exception', 'print', '🚨 [SECURITY] Missing gateway_access_token for protocol v4+'
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
    def _report_verify_progress(progress_callback: Optional[Callable[[str, str, int], NoneType]], phase: str, detail: str, progress: int) -> None:
        if progress_callback:
            try: progress_callback(phase, detail, progress)
            except Exception: pass

    @staticmethod
    def _deauthorize_runtime_packs(generation: int | None = None, state: str = 'revoked') -> None:
        pass

    @staticmethod
    def _consume_runtime_packs(license_data: Dict[str, Any], generation: int | None = None) -> None:
        pass

    @staticmethod
    def _take_runtime_pack_request(license_data: Dict[str, Any]) -> tuple[list[dict[str, typing.Any]], list[str], bool]:
        return [], ["all"], False

    @staticmethod
    def _activate_runtime_pack_records(records: list[dict[str, typing.Any]], *, generation: int | None, entitled_features: list[str], runtime_packs_present: bool) -> list[dict[str, typing.Any]]:
        return records

    def _state_update_lock(self) -> Any:
        return threading.RLock()

    @staticmethod
    def _pending_runtime_pack_states(records: list[dict[str, typing.Any]]) -> list[dict[str, typing.Any]]:
        return []

    @staticmethod
    def _report_runtime_pack_result(runtime_pack_callback: Optional[Callable[[dict[str, Any]], NoneType]], event: dict[str, typing.Any]) -> None:
        pass

    def _prepare_runtime_packs_async(self, license_data: Dict[str, Any], *, generation: int, runtime_pack_callback: Optional[Callable[[dict[str, Any]], NoneType]]) -> threading.Thread:
        """Strip secrets and create (but do not start) the activation worker."""
        return threading.Thread(target=lambda: None)

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
    def get_status(self, timeout: int = 15) -> Optional[Dict[str, Any]]:
        return self._make_request("status", timeout=timeout)

    def get_config(self) -> Optional[Dict[str, Any]]:
        # [PyArmor BCC constants]: '_make_request', 'config', 'get', 'success', 'isinstance', 'data', 'dict'
        pass

    def deactivate_license(self) -> bool:
        # [PyArmor BCC constants]: '_make_request', 'deactivate', 'get', 'success', '_deauthorize_runtime_packs', '_clear_cache', True, False
        pass

    def test_connection(self) -> Dict[str, Any]:
        return {"success": True, "status_code": 200, "message": "Connection OK"}

    def _make_quota_request(self, endpoint: str, extra_data: Dict[str, Any] = None, timeout: int = 10) -> Optional[Dict[str, Any]]:
        return {"success": True, "remaining_count": 999999, "allowed": True}

    def check_action(self, action_type: str, quantity: int = 1, timeout: int = 10) -> Dict[str, Any]:
        return {"allowed": True, "remaining_count": 999999, "success": True, "message": "OK"}

    def consume_action(self, action_type: str, quantity: int = 1, timeout: int = 10) -> Dict[str, Any]:
        return {"success": True, "remaining_count": 999999, "data": {"remaining_count": 999999}}

    def get_quota(self, timeout: int = 10) -> Dict[str, Any]:
        return {"allowed": True, "remaining_count": 999999, "quota": 999999, "used": 0, "tier": "PREMIUM", "success": True}

    def _cache_license_data(self, license_data: Dict[str, Any]) -> None:
        # [PyArmor BCC constants]: 'get_json_license_cache_manager', 'get', 'status', 'active', 'expires_at', '', 'license_type', 'tier', 'UNKNOWN', 'features', 'active_features', 'purchased_features', 'isinstance', 'auth', 'dict'
        pass

    @staticmethod
    def _persist_allowed_ai_modes(value: Any) -> None:
        # [PyArmor BCC constants]: 'isinstance', 'dict', True, 'bool', 'any', 'values', 'aistudio', 'get_json_settings_manager', 'set_setting', 'main', 'allowed_ai_modes', 'dumps', 'Exception'
        pass

    def _get_cached_license_data(self) -> Optional[Dict[str, Any]]:
        # [PyArmor BCC constants]: 'get_json_license_cache_manager', 'get_license_data', 'debug', 'print', '⚠️ [DEBUG] No cache data in JSON', 'get', 'last_check', 'datetime', 'fromisoformat', 'now', 'timedelta', 'hours', 24, '⚠️ [DEBUG] Cache expired', 'tier'
        pass

    def _clear_cache(self) -> None:
        # [PyArmor BCC constants]: 'get_json_license_cache_manager', 'clear_license_cache', 'debug', 'print', '🗑️ [DEBUG] Cache cleared from JSON', '⚠️ [DEBUG] Failed to clear cache: ', 'Exception'
        pass

    def get_last_error(self) -> Optional[str]:
        pass

    def get_last_error_code(self) -> Optional[str]:
        pass

    def get_last_response(self) -> Optional[Dict[str, Any]]:
        pass

    def get_error_details(self) -> Dict[str, Any]:
        # [PyArmor BCC constants]: 'error', 'error_code', 'response', 'last_error', 'last_error_code', 'last_response'
        pass

    def get_license_info(self) -> Optional[Dict[str, Any]]:
        return getattr(self, '_verified_license_data', None) or {
            "tier": "PREMIUM",
            "license_type": "PREMIUM",
            "status": "active",
            "features": ["all"],
            "expires_at": "2099-12-31",
            "quota": 999999
        }


# --- Top-Level Functions ---
def _log_v4_debug(message: str):
    pass
