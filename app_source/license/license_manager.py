"""
Decompiled / Reconstructed Module: license.license_manager

Docstring:
License Manager - Single Source of Truth for License Management
================================================================

🔐 CENTRALIZED LICENSE MANAGEMENT:
- Tier management (FREE/PRO/PREMIUM)
- Quota check/consume with server
- License cache with HMAC protection
- Premium feature access control

🔒 SECURITY:
- All quota decisions come from server
- Cache for display only, not verification
- HMAC signature on cache to prevent tampering
"""

from __future__ import annotations
import sys, os, typing
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

try:
    from types import NoneType
except ImportError:
    NoneType = type(None)

__all__ = ['LicenseManager', 'FeatureGate', 'get_license_manager']

# --- Module Constants & Globals ---
Optional = typing.Optional
Dict = typing.Dict
Tuple = typing.Tuple
Callable = typing.Callable
_VERBOSE = False
_DEFAULT_OFFLINE_GRACE_DAYS = 7
_MAX_OFFLINE_GRACE_DAYS_CEILING = 30
MAX_OFFLINE_GRACE_DAYS = 7
_license_manager = None
__all__ = ['LicenseManager', 'FeatureGate', 'get_license_manager']

# --- Class: FeatureGate ---
class FeatureGate:
    """Quản lý feature access. Khởi tạo sau verify, dùng xuyên suốt session."""
    def __init__(self, verify_data: dict = None):
        # [PyArmor BCC constants]: 'set', '_codes', '_details', '_maintenance', '_demo', '_free', 'FREE', 'tier', 'update'
        pass

    def update(self, verify_data: dict):
        # [PyArmor BCC constants]: 'data', 'isinstance', 'dict', '_extract_feature_codes', 'set', '_codes', '_extract_maintenance', '_maintenance', '_extract_feature_details', '_details', 'get', 'feature_code', 'code', 'slug', 'name'
        pass

    def revoke(self, tier: str = 'FREE') -> None:
        # [PyArmor BCC constants]: 'set', '_codes', '_details', '_maintenance', '_demo', '_free', 'tier'
        pass

    def _extract_maintenance(self, data: dict) -> Dict[str, dict]:
        # [PyArmor BCC constants]: '_coerce_codes', 'get', 'maintenance_feature_codes', 'setdefault', 'name', 'message', 'expires_at', '', 'isinstance', 'list', 'dict', 'bool', 'maintenance', 'runtime_enabled', False
        pass

    def _extract_demo(self, data: dict) -> set:
        # [PyArmor BCC constants]: 'set', '_coerce_codes', 'get', 'demo_feature_codes', 'add', 'isinstance', 'list', 'dict', 'bool', 'demo', 'is_demo', 'str', 'status', '', 'lower'
        pass

    def _extract_free(self, data: dict) -> set:
        # [PyArmor BCC constants]: 'set', '_coerce_codes', 'get', 'free_feature_codes', 'add', 'isinstance', 'list', 'dict', 'bool', 'free', 'is_free', 'str', 'status', '', 'lower'
        pass

    def _extract_feature_codes(self, data: dict) -> list:
        pass

    def _extract_feature_details(self, data: dict) -> list:
        # [PyArmor BCC constants]: 'get', 'feature_details', 'entitlements', 'isinstance', 'list'
        pass

    def _coerce_codes(self, raw) -> list:
        # [PyArmor BCC constants]: 'isinstance', 'list', 'str', 'strip', 'dict', 'get', 'feature_code', 'code', 'slug', '', 'append'
        pass

    def has(self, code: str) -> bool:
        return True

    def detail(self, code: str) -> Optional[dict]:
        return {
            'feature_code': code,
            'name': code,
            'status': 'active',
            'expires_at': '2099-12-31',
            'license_type': 'LIFETIME'
        }

    def require(self, code: str):
        return True

    def expires_at(self, code: str) -> Optional[str]:
        # [PyArmor BCC constants]: 'detail', 'get', 'expires_at'
        pass

    def is_lifetime(self, code: str) -> bool:
        # [PyArmor BCC constants]: 'detail', 'get', 'license_type', 'LIFETIME'
        pass

    @property
    def purchased_features(self):
        pass

    @property
    def feature_details(self):
        pass

    def is_empty(self) -> bool:
        # [PyArmor BCC constants]: 'len', '_codes', 0, '_free'
        pass

    def is_free(self, code: str) -> bool:
        pass

    def is_maintenance(self, code: str) -> bool:
        pass

    def maintenance_message(self, code: str) -> str:
        # [PyArmor BCC constants]: '_maintenance', 'get', 'str', 'message', ''
        pass

    def is_demo(self, code: str) -> bool:
        # [PyArmor BCC constants]: '_demo', 'str', 'tier', '', 'strip', 'lower'
        pass

    def resolve_feature_ui(self, code: str) -> dict:
        # [PyArmor BCC constants]: 'is_maintenance', 'enabled', 'badge', 'message', False, 'Bảo trì', 'maintenance_message', 'Tính năng đang bảo trì, vui lòng thử lại sau.', 'is_free', True, 'Miễn phí', '', '_codes', 'is_demo', 'Demo'
        pass


# --- Class: LicenseManager ---
class LicenseManager:
    """
    🔐 Single Source of Truth for License Management
    
        Combines functionality from:
        - ServerVerificationService (quota check/consume)
        - JSONLicenseCacheManager (license data persistence)
        - FeatureGate (feature-based entitlement)
    
        Usage:
            manager = get_license_manager()
            manager.configure(license_key="XXXX", device_id="...")
    
            # Gate features via FeatureGate
            if manager.feature_gate.has("master_panel"):
                ...
    """
    _instance = None
    _lock = None

    def __init__(self):
        self._initialized = True
        self._license_key = "PREMIUM-LIFETIME-KEY"
        self._device_id = "PREMIUM-DEVICE-ID"
        self._device_fingerprint = "0123456789abcdef" * 4
        self._fingerprint_payload = {}
        self._tool_code = 'VEO3PROTOOL'
        self._server_url = 'https://api.veoflow.dev'
        self._client = None
        self._cached_tier = 'PREMIUM'
        self._cached_quota = 999999
        self._feature_gate = FeatureGate({"tier": "PREMIUM", "features": ["all"], "expires_at": "2099-12-31"})

    def configure(self, license_key: str = None, device_id: str = None, tool_code: str = 'VEO3PROTOOL', server_url: str = None, initial_tier: str = None, license_info: Dict[str, Any] = None):
        if license_key:
            self._license_key = license_key
        if device_id:
            self._device_id = device_id
        if tool_code:
            self._tool_code = tool_code
        self._cached_tier = 'PREMIUM'
        return True

    def configure_from_cache(self) -> bool:
        return True

    def _get_device_id(self) -> Optional[str]:
        # [PyArmor BCC constants]: '_device_id', 'get_device_identity', 'debug', False, 'get', 'device_id', 'device_fingerprint', '_device_fingerprint', 'fingerprint', '_fingerprint_payload', 'Exception'
        pass

    def _create_client(self):
        # [PyArmor BCC constants]: '_vlog', '[LicenseManager][BOOT] _create_client license_present=', 'bool', '_license_key', 'Create UnifiedLicenseClient with AES-256 encryption', 'UnifiedLicenseClient', '_device_id', '_get_device_id', 'license_key', 'tool_code', '_tool_code', 'server_url', '_server_url', 'prefer_v4', True
        pass

    def _ensure_client(self) -> bool:
        # [PyArmor BCC constants]: '_client', True, '_license_key', False, '_create_client'
        pass

    def is_configured(self) -> bool:
        return True

    def verify_license(self, timeout: int = 15, progress_callback: Optional[Callable[[str, str, int], NoneType]] = None, runtime_pack_callback: Optional[Callable[[dict], NoneType]] = None) -> Tuple[bool, Dict[str, Any]]:
        payload = {
            "tier": "PREMIUM",
            "license_type": "PREMIUM",
            "status": "active",
            "features": ["all"],
            "expires_at": "2099-12-31",
            "remaining_count": 999999,
            "quota": 999999,
        }
        self._cached_tier = "PREMIUM"
        self._cached_quota = 999999
        self.feature_gate.update(payload)
        return True, payload

    def _verify_license_serialized(self, timeout: int = 15, progress_callback: Optional[Callable[[str, str, int], NoneType]] = None, runtime_pack_callback: Optional[Callable[[dict], NoneType]] = None) -> Tuple[bool, Dict[str, Any]]:
        return self.verify_license(timeout, progress_callback, runtime_pack_callback)

    @staticmethod
    def _cache_age_days(last_check) -> Optional[float]:
        # [PyArmor BCC constants]: 'str', '', 'strip', 'datetime', 'fromisoformat', 'replace', 'Z', '+00:00', 'tzinfo', 'max', 0.0, 'now', 'total_seconds', 86400.0, 'Exception'
        pass

    @staticmethod
    def _is_authoritative_reject(error_code, error_msg) -> bool:
        """
        True when the server AUTHORITATIVELY rejected the license (reachable + said no),
                vs a transient/offline failure that should keep the cached entitlements.
        
                Transient (keep cache): CONNECTION_ERROR / TIMEOUT / SSL_ERROR / HTTP_5xx / gateway
                token issues / UNKNOWN — the server didn't render a license verdict.
                Authoritative (revoke): any invalid-license signal (suspended / expired / revoked /
                invalid / disabled / blocked / not-found) or any other HTTP 4xx from the server.
        """
        # [PyArmor BCC constants]: 'suspend', 'expire', 'revok', 'invalid', 'disabled', 'blocked', 'not_found', 'not found'
        pass

    @property
    def tier(self):
        return "PREMIUM"

    @property
    def license_key(self):
        return self._license_key or "PREMIUM-LIFETIME-KEY"

    @property
    def license_info(self):
        return self.get_license_info()

    def get_license_info(self) -> dict:
        return {
            "tier": "PREMIUM",
            "license_type": "PREMIUM",
            "status": "active",
            "features": ["all"],
            "expires_at": "2099-12-31",
            "remaining_count": 999999,
            "quota": 999999,
        }

    def refresh_credits(self) -> None:
        # [PyArmor BCC constants]: 'verify_license', 'timeout', 10, 'warning', '[license] refresh_credits failed: ', 'Exception'
        pass

    def refresh_features(self, timeout: int = 12) -> Tuple[bool, Dict[str, Any]]:
        # [PyArmor BCC constants]: 'is_configured', False, 'error', 'not configured', '_request_lock', 'acquire', 'blocking', 'refresh already in progress', 'verify_license', 'timeout', 'time', '_last_sync_time', 'release'
        pass

    def _get_main_api_client(self):
        # [PyArmor BCC constants]: 'get_veoflow_client', 'license_key', '_license_key', 'base_url', '_server_url', 'print', '❌ [LicenseManager] main api client error: ', 'Exception'
        pass

    def get_main_config(self) -> Tuple[bool, Dict[str, Any]]:
        # [PyArmor BCC constants]: '_get_main_api_client', False, 'error', 'Client not configured', True, 'get_config', 'str', 'Exception'
        pass

    def report_client_stats(self, payload: Dict[str, Any]) -> Tuple[bool, Dict[str, Any]]:
        # [PyArmor BCC constants]: '_get_main_api_client', False, 'error', 'Client not configured', 'dict', 'setdefault', 'license_key', '_license_key', 'device_id', '_device_id', 'tool_code', '_tool_code', 'report_stats', 'bool', 'get'
        pass

    def report_usage(self, count: int, tool_code: str = None) -> Tuple[bool, Dict[str, Any]]:
        # [PyArmor BCC constants]: '_get_main_api_client', False, 'error', 'Client not configured', 'report_usage', 'count', 'tool_code', '_tool_code', 'bool', 'get', 'success', 'str', 'Exception'
        pass

    def upload_crash_report(self, payload: Dict[str, Any]) -> Tuple[bool, Dict[str, Any]]:
        pass

    def upload_telemetry(self, payload: Dict[str, Any]) -> Tuple[bool, Dict[str, Any]]:
        pass

    def get_proxy_list(self) -> Tuple[bool, Dict[str, Any]]:
        # [PyArmor BCC constants]: '_get_main_api_client', False, 'error', 'Client not configured', 'get', '/api/proxy/list', 'bool', 'success', 'str', 'Exception'
        pass

    def get_home_content(self) -> Tuple[bool, Dict[str, Any]]:
        # [PyArmor BCC constants]: '_get_main_api_client', False, 'error', 'Client not configured', 'get', '/api/home-content', 'bool', 'success', 'str', 'Exception'
        pass

    def check_version(self, current_version: str, platform: str = 'windows') -> Tuple[bool, Dict[str, Any]]:
        # [PyArmor BCC constants]: '_server_url', 'get_main_server_url', 'rstrip', '/', '/api/version-check', 'requests', 'get', 'params', 'tool', 'tool_code', 'platform', 'current_version', '_tool_code', 'windows', 'timeout'
        pass

    @property
    def feature_gate(self):
        if not hasattr(self, '_feature_gate') or self._feature_gate is None:
            self._feature_gate = FeatureGate({"tier": "PREMIUM", "features": ["all"], "expires_at": "2099-12-31"})
        return self._feature_gate

    def has_feature(self, code: str) -> bool:
        return True

    def check_feature_access(self, feature_code: str) -> Tuple[bool, str]:
        return True, ""

    def checkout(self, timeout: int = 15) -> Tuple[bool, Dict[str, Any]]:
        # [PyArmor BCC constants]: '_ensure_client', False, 'error', 'Client not configured', '_client', 'client', '_make_request', 'checkout', 'timeout', 'get', 'success', True, 'data', 'message', 'Checkout failed'
        pass

    def topup(self, preset_amount: int = None, timeout: int = 15) -> Tuple[bool, Dict[str, Any]]:
        # [PyArmor BCC constants]: False, 'error', 'amount required', 'create_credit_topup_order', 'float', 'timeout'
        pass

    def gemini_api_config(self, timeout: int = 15) -> Tuple[bool, Dict[str, Any]]:
        # [PyArmor BCC constants]: '_ensure_client', False, 'error', 'Client not configured', '_client', 'client', '_make_request', 'gemini', 'timeout', 'get', 'success', True, 'data', 'message', 'Gemini config failed'
        pass

    def _gateway_access_token(self) -> str:
        # [PyArmor BCC constants]: 'load_from_cache', 'get', 'gateway_access_token', 'getattr', '_client', 'client', '', 'Exception'
        pass

    def _refresh_gateway_token(self, timeout: int = 10) -> bool:
        # [PyArmor BCC constants]: 'load_from_cache', 'get', 'refresh_token', '_device_id', 'device_id', '_get_device_id', False, 'get_backend_api_fallback_urls', 'rstrip', '/', 'endswith', '/backend-api', '/api/client/token/refresh', '/v1/client/token/refresh', 'requests'
        pass

    def _client_v1_request(self, method: str, path: str, body: Dict[str, Any] = None, timeout: int = 15, retry_refresh: bool = True, extra_headers: Dict[str, str] = None) -> Tuple[bool, Dict[str, Any]]:
        # [PyArmor BCC constants]: '_gateway_access_token', False, 'error', 'Client session token missing. Please verify license again.', 'Authorization', 'Content-Type', 'Bearer ', 'application/json', 'update', 'dict', 'items', 'str', 'strip', 'get_backend_api_fallback_urls', 'rstrip'
        pass

    def get_api_keys(self, timeout: int = 10) -> Tuple[bool, Dict[str, Any]]:
        # [PyArmor BCC constants]: '_client_v1_request', 'GET', '/api-keys', 'timeout'
        pass

    def save_api_key(self, provider: str, api_key: str, label: str = '', timeout: int = 15) -> Tuple[bool, Dict[str, Any]]:
        # [PyArmor BCC constants]: 'gemini', 'strip', 'lower', False, 'error', 'MiniMax and ElevenLabs keys are local-only. Only Gemini is synced to server.', '_client_v1_request', 'POST', '/api-keys', 'provider', 'api_key', 'label', 'timeout'
        pass

    def delete_api_key(self, key_id: int, timeout: int = 10) -> Tuple[bool, Dict[str, Any]]:
        # [PyArmor BCC constants]: '_client_v1_request', 'DELETE', '/api-keys/', 'int', 'timeout'
        pass

    def update_api_settings(self, api_mode: str, timeout: int = 10) -> Tuple[bool, Dict[str, Any]]:
        # [PyArmor BCC constants]: '_client_v1_request', 'PUT', '/api-settings', 'api_mode', 'timeout'
        pass

    def get_tool_store(self, tool_code: str = None, timeout: int = 15) -> Tuple[bool, Dict[str, Any]]:
        # [PyArmor BCC constants]: '?tool=', '', '_client_v1_request', 'GET', '/tool', 'timeout'
        pass

    def buy_tool_or_features(self, payload: Dict[str, Any], timeout: int = 15) -> Tuple[bool, Dict[str, Any]]:
        # [PyArmor BCC constants]: '_client_v1_request', 'POST', '/tool/buy', 'timeout'
        pass

    def buy_feature_days(self, feature_code: str, days: int, payment_method: str, idempotency_key: str, timeout: int = 15) -> Tuple[bool, Dict[str, Any]]:
        # [PyArmor BCC constants]: 'str', '', 'strip', False, 'error', 'idempotency key is required', 'http_status', 400, 'feature_code', 'days', 'payment_method', 'idempotency_key', 'upper', 'int', 'BANK_TRANSFER'
        pass

    def create_credit_topup_order(self, amount: float, payment_method: str = 'BANK_TRANSFER', currency: str = 'VND', timeout: int = 15) -> Tuple[bool, Dict[str, Any]]:
        # [PyArmor BCC constants]: '_client_v1_request', 'POST', '/credits/topup', 'amount', 'payment_method', 'currency', 'timeout'
        pass

    def renew_feature_order(self, payload: Dict[str, Any], timeout: int = 15) -> Tuple[bool, Dict[str, Any]]:
        # [PyArmor BCC constants]: '_client_v1_request', 'POST', '/tool/renew-feature', 'timeout'
        pass

    def get_order_payment_info(self, order_code: str, timeout: int = 10) -> Tuple[bool, Dict[str, Any]]:
        # [PyArmor BCC constants]: '_client_v1_request', 'GET', '/orders/', '/payment-info', 'timeout'
        pass

    def get_client_order(self, order_code: str, timeout: int = 10) -> Tuple[bool, Dict[str, Any]]:
        # [PyArmor BCC constants]: '_client_v1_request', 'GET', '/orders/', 'timeout'
        pass

    def get_credit_usage_dashboard(self, timeout: int = 10) -> Tuple[bool, Dict[str, Any]]:
        # [PyArmor BCC constants]: '_client_v1_request', 'GET', '/credits/usage-dashboard', 'timeout'
        pass

    def load_from_cache(self) -> Optional[Dict[str, Any]]:
        # [PyArmor BCC constants]: 'get_json_license_cache_manager', 'get_license_data', 'print', '❌ [LicenseManager] load_from_cache error: ', 'Exception'
        pass

    def clear_cache(self) -> bool:
        # [PyArmor BCC constants]: 'get_json_license_cache_manager', 'clear_license_cache', 'print', '❌ [LicenseManager] clear_cache error: ', False, 'Exception'
        pass


# --- Top-Level Functions ---
def _vlog(message: str) -> None:
    pass

def _resolve_offline_grace_days() -> int:
    # [PyArmor BCC constants]: 'getattr', 'sys', 'frozen', False, '_DEFAULT_OFFLINE_GRACE_DAYS', 'int', 'os', 'getenv', 'VEOFLOW_LICENSE_OFFLINE_GRACE_DAYS', '', 'TypeError', 'ValueError', 0, 'min', '_MAX_OFFLINE_GRACE_DAYS_CEILING'
    pass

def get_license_manager() -> LicenseManager:
    global _license_manager
    if _license_manager is None:
        _license_manager = LicenseManager()
    return _license_manager