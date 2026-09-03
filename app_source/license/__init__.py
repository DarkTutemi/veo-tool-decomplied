"""
Decompiled / Reconstructed Module: license.__init__

Docstring:
License module for VEO3 Tool
Contains all license-related functionality

NOTE: Do NOT import from ui.dialogs here to avoid circular imports!
The license_splash module imports from license.unified_license_client,
so importing back here creates a circular dependency.
"""

from __future__ import annotations
import sys, os, typing
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

try:
    from types import NoneType
except ImportError:
    NoneType = type(None)

try:
    import requests
    import requests.sessions
except ImportError:
    pass

__all__ = ['UnifiedLicenseClient', 'VeoflowAPIClient', 'get_veoflow_client', 'reset_veoflow_client', 'LicenseManager', 'FeatureGate', 'get_license_manager']

# --- Module Constants & Globals ---
__all__ = ['UnifiedLicenseClient', 'VeoflowAPIClient', 'get_veoflow_client', 'reset_veoflow_client', 'LicenseManager', 'FeatureGate', 'get_license_manager']

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


# --- Class: VeoflowAPIClient ---
class VeoflowAPIClient:
    """
    VeoFlow API Client with HMAC authentication.
    
        Signature algorithm:
        1. secret_key = SHA256(license_key + ":" + api_secret)
        2. data = license_key + timestamp + body
        3. signature = HMAC-SHA256(data, secret_key)
    """
    def __init__(self, license_key: str, base_url: str = None, api_secret: Optional[str] = None):
        # [PyArmor BCC constants]: 'license_key', 'get_main_server_url', 'rstrip', '/', 'base_url', '_api_secret'
        pass

    @property
    def _secret(self):
        pass

    @staticmethod
    def _extract_api_secret(data) -> str:
        # [PyArmor BCC constants]: 'isinstance', 'dict', '', 'get', 'str', 'strip'
        pass

    def _generate_signature(self, timestamp: int, body: str) -> str:
        # [PyArmor BCC constants]: 'hashlib', 'sha256', 'license_key', ':', '_secret', 'encode', 'digest', 'hmac', 'new', 'hexdigest'
        pass

    def _get_headers(self, body: str) -> Dict[str, str]:
        # [PyArmor BCC constants]: 'int', 'time', '_generate_signature', 'X-License-Key', 'X-Timestamp', 'X-Signature', 'Content-Type', 'Accept', 'User-Agent', 'license_key', 'str', 'application/json', 'VeoFlow-Tool/3.0.0'
        pass

    def _debug_request(self, method: str, url: str, headers: Dict[str, str], body: str = ''):
        pass

    def _debug_response(self, response: requests.models.Response):
        # [PyArmor BCC constants]: 'status_code', 400, 'json', 'text', 200, 'Exception', 'print', '[VeoflowAPI] <-- ', ' '
        pass

    def _cached_runtime_context(self) -> Dict[str, Any]:
        # [PyArmor BCC constants]: 'JSONLicenseCacheManager', 'get_license_data', 'Exception', 'isinstance', 'dict'
        pass

    def _normalize_activity_payload(self, event_type: str, payload: Dict[str, Any], default_tool_code: Optional[str] = None) -> Dict[str, Any]:
        # [PyArmor BCC constants]: 'dict', '_cached_runtime_context', 'get', 'license_key', 'device_id', 'client_id', 'session_id', 'session_token', 'gateway_access_token', 'tool_code', 'app_version', 'client_info', 'version', 'VEO3Config', 'getattr'
        pass

    def get_config(self) -> Dict[str, Any]:
        # [PyArmor BCC constants]: '', '_get_headers', 'base_url', '/api/config', 3, 2, 'range', 0, 'print', '🔄 [VeoflowAPI] Retry attempt ', 1, '/', ' for config...', 'time', 'sleep'
        pass

    def report_stats(self, stats: Dict[str, Any]) -> Dict[str, Any]:
        # [PyArmor BCC constants]: 'json', 'dumps', '_normalize_activity_payload', 'client_stats', 'separators', '_get_headers', 'base_url', '/api/client/stats', '_debug_request', 'POST', 'requests', 'post', 'headers', 'data', 'timeout'
        pass

    def report_usage(self, count: int, tool_code: str = 'VEO3PROTOOL') -> Optional[Dict[str, Any]]:
        # [PyArmor BCC constants]: '_normalize_activity_payload', 'client_report_usage', 'count', 'tool_code', 'default_tool_code', 'json', 'dumps', 'separators', '_get_headers', 'base_url', '/api/client/report-usage', '_debug_request', 'POST', 'requests', 'post'
        pass

    def get(self, endpoint: str, params: Optional[Dict[str, Any]] = None, timeout: int = 30) -> Optional[dict]:
        # [PyArmor BCC constants]: '', '_get_headers', 'base_url', '_debug_request', 'GET', 'requests', 'get', 'headers', 'params', 'timeout', '_debug_response', 'raise_for_status', 'json', 'print', '[ERROR] [VeoflowAPI] Failed to GET '
        pass

    def post(self, endpoint: str, data: dict, timeout: int = 30) -> Optional[dict]:
        # [PyArmor BCC constants]: '_normalize_activity_payload', 'client_telemetry_event', 'json', 'dumps', 'separators', '_get_headers', 'base_url', '_debug_request', 'POST', 'requests', 'post', 'headers', 'data', 'timeout', '_debug_response'
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
        # [PyArmor BCC constants]: '_initialized', True, '_license_key', '_device_id', '_device_fingerprint', '_fingerprint_payload', 'VEO3PROTOOL', '_tool_code', 'get_main_server_url', '_server_url', '_client', 'FREE', '_cached_tier', '_cached_quota', 0
        pass

    def configure(self, license_key: str, device_id: str, tool_code: str = 'VEO3PROTOOL', server_url: str = None, initial_tier: str = None, license_info: Dict[str, Any] = None):
        # [PyArmor BCC constants]: '_get_device_id', '_license_key', '_device_id', '_tool_code', 'get_main_server_url', 'rstrip', '/', '_server_url', 'str', 'strip', 'upper', '_cached_tier', '_vlog', '✅ [LicenseManager] Initial tier: ', '_license_info'
        pass

    def configure_from_cache(self) -> bool:
        # [PyArmor BCC constants]: '_vlog', '[LicenseManager][BOOT] configure_from_cache start', '\n        🔒 Auto-configure from cached license data.\n\n        This is the RECOMMENDED way to initialize LicenseManager on app startup.\n        Returns True if successfully configured from cache.\n        ', '_license_revoked', 'print', '🔒 [LicenseManager] configure_from_cache SKIPPED — license revoked this session.', False, 'get_json_license_cache_manager', 'get_tool_code', 'get_server_url', 'get_license_data', '[LicenseManager][BOOT] cache loaded has_key=', 'bool', 'get', 'license_key'
        pass

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
        pass

    def verify_license(self, timeout: int = 15, progress_callback: Optional[Callable[[str, str, int], NoneType]] = None, runtime_pack_callback: Optional[Callable[[dict], NoneType]] = None) -> Tuple[bool, Dict[str, Any]]:
        # [PyArmor BCC constants]: 'max', 0.1, 'float', 15, 15.0, 'TypeError', 'ValueError', '_request_lock', 'acquire', 'timeout', False, 'error', 'Another license verification is still in progress', 'error_code', 'VERIFY_BUSY'
        pass

    def _verify_license_serialized(self, timeout: int = 15, progress_callback: Optional[Callable[[str, str, int], NoneType]] = None, runtime_pack_callback: Optional[Callable[[dict], NoneType]] = None) -> Tuple[bool, Dict[str, Any]]:
        # [PyArmor BCC constants]: '_vlog', '[LicenseManager][BOOT] verify_license start configured=', 'is_configured', ' timeout=', '\n        🔒 Verify license with server and update cache.\n\n        This is the SINGLE method to verify license. After success, it:\n        1. Updates cached tier from server response\n        2. Saves to cache automatically\n        3. Returns license info\n\n        Returns:\n            (success, license_info)\n        ', '_license_key', False, 'error', 'No license key configured', '_ensure_client', 'Failed to create client', '[LicenseManager][BOOT] delegating to UnifiedLicenseClient.verify_license', '_client', 'verify_license', 'timeout'
        pass

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
        pass

    @property
    def license_key(self):
        pass

    @property
    def license_info(self):
        pass

    def get_license_info(self) -> dict:
        pass

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
        pass

    def has_feature(self, code: str) -> bool:
        pass

    def check_feature_access(self, feature_code: str) -> Tuple[bool, str]:
        # [PyArmor BCC constants]: '_feature_gate', 'has', 'detail', 'name', False, "🔒 Tính năng '", "' chưa được kích hoạt\n\nTruy cập veoflow.dev để mua tính năng này."
        pass

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
        pass

    def detail(self, code: str) -> Optional[dict]:
        pass

    def require(self, code: str):
        # [PyArmor BCC constants]: 'has', '_details', 'get', 'name', 'PermissionError', "Feature '", "' chưa được mua. Truy cập veoflow.dev"
        pass

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