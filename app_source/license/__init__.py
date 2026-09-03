"""
Decompiled / Reconstructed Module: license.__init__

Docstring:
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

__all__ = ['UnifiedLicenseClient', 'VeoflowAPIClient', 'get_veoflow_client', 'reset_veoflow_client', 'LicenseManager', 'FeatureGate', 'get_license_manager']

# --- Module Constants & Globals ---
Dict = typing.Dict
List = typing.List
Optional = typing.Optional
Tuple = typing.Tuple
Union = typing.Union
Callable = typing.Callable
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
    def __init__(self, license_key: 'str', tool_code: 'str', server_url: 'str' = None, prefer_v4: 'bool' = True, debug: 'bool' = False, client_version: 'str' = '92.0.117', device_id: 'str' = None, device_fingerprint: 'str' = None, fingerprint_payload: 'Dict[str, Any]' = None):
        pass

    def _initialize_client(self):
        pass

    def _try_init_v4(self) -> 'bool':
        pass

    def verify_license(self, timeout: 'int' = 30, progress_callback: 'Optional[Callable[[str, str, int], NoneType]]' = None, runtime_pack_callback: 'Optional[Callable[[dict], NoneType]]' = None) -> 'bool':
        pass

    def check_status(self, timeout: 'int' = 30) -> 'Optional[Dict[str, Any]]':
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
        pass

    @property
    def last_error(self):
        pass

    @property
    def last_error_code(self):
        pass

    def get_error_details(self) -> 'Dict[str, Any]':
        """Get detailed error information"""
        pass

    def check_action(self, action_type: 'str', quantity: 'int' = 1, timeout: 'int' = 10) -> 'Dict[str, Any]':
        pass

    def consume_action(self, action_type: 'str', quantity: 'int' = 1, timeout: 'int' = 10) -> 'Dict[str, Any]':
        pass

    def get_quota(self, timeout: 'int' = 10) -> 'Dict[str, Any]':
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
    def __init__(self, license_key: 'str', base_url: 'str' = None, api_secret: 'Optional[str]' = None):
        pass

    @property
    def _secret(self):
        pass

    @staticmethod
    def _extract_api_secret(data) -> 'str':
        pass

    def _generate_signature(self, timestamp: 'int', body: 'str') -> 'str':
        pass

    def _get_headers(self, body: 'str') -> 'Dict[str, str]':
        pass

    def _debug_request(self, method: 'str', url: 'str', headers: 'Dict[str, str]', body: 'str' = ''):
        pass

    def _debug_response(self, response: 'requests.models.Response'):
        pass

    def _cached_runtime_context(self) -> 'Dict[str, Any]':
        pass

    def _normalize_activity_payload(self, event_type: 'str', payload: 'Dict[str, Any]', default_tool_code: 'Optional[str]' = None) -> 'Dict[str, Any]':
        pass

    def get_config(self) -> 'Dict[str, Any]':
        pass

    def report_stats(self, stats: 'Dict[str, Any]') -> 'Dict[str, Any]':
        pass

    def report_usage(self, count: 'int', tool_code: 'str' = 'VEO3PROTOOL') -> 'Optional[Dict[str, Any]]':
        pass

    def get(self, endpoint: 'str', params: 'Optional[Dict[str, Any]]' = None, timeout: 'int' = 30) -> 'Optional[dict]':
        pass

    def post(self, endpoint: 'str', data: 'dict', timeout: 'int' = 30) -> 'Optional[dict]':
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
        pass

    def configure(self, license_key: 'str', device_id: 'str', tool_code: 'str' = 'VEO3PROTOOL', server_url: 'str' = None, initial_tier: 'str' = None, license_info: 'Dict[str, Any]' = None):
        pass

    def configure_from_cache(self) -> 'bool':
        pass

    def _get_device_id(self) -> 'Optional[str]':
        pass

    def _create_client(self):
        pass

    def _ensure_client(self) -> 'bool':
        pass

    def is_configured(self) -> 'bool':
        pass

    def verify_license(self, timeout: 'int' = 15, progress_callback: 'Optional[Callable[[str, str, int], NoneType]]' = None, runtime_pack_callback: 'Optional[Callable[[dict], NoneType]]' = None) -> 'Tuple[bool, Dict[str, Any]]':
        pass

    def _verify_license_serialized(self, timeout: 'int' = 15, progress_callback: 'Optional[Callable[[str, str, int], NoneType]]' = None, runtime_pack_callback: 'Optional[Callable[[dict], NoneType]]' = None) -> 'Tuple[bool, Dict[str, Any]]':
        pass

    @staticmethod
    def _cache_age_days(last_check) -> 'Optional[float]':
        pass

    @staticmethod
    def _is_authoritative_reject(error_code, error_msg) -> 'bool':
        """
        True when the server AUTHORITATIVELY rejected the license (reachable + said no),
                        vs a transient/offline failure that should keep the cached entitlements.
                
                        Transient (keep cache): CONNECTION_ERROR / TIMEOUT / SSL_ERROR / HTTP_5xx / gateway
                        token issues / UNKNOWN — the server didn't render a license verdict.
                        Authoritative (revoke): any invalid-license signal (suspended / expired / revoked /
                        invalid / disabled / blocked / not-found) or any other HTTP 4xx from the server.
        """
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

    def get_license_info(self) -> 'dict':
        pass

    def refresh_credits(self) -> 'None':
        pass

    def refresh_features(self, timeout: 'int' = 12) -> 'Tuple[bool, Dict[str, Any]]':
        pass

    def _get_main_api_client(self):
        pass

    def get_main_config(self) -> 'Tuple[bool, Dict[str, Any]]':
        pass

    def report_client_stats(self, payload: 'Dict[str, Any]') -> 'Tuple[bool, Dict[str, Any]]':
        pass

    def report_usage(self, count: 'int', tool_code: 'str' = None) -> 'Tuple[bool, Dict[str, Any]]':
        pass

    def upload_crash_report(self, payload: 'Dict[str, Any]') -> 'Tuple[bool, Dict[str, Any]]':
        pass

    def upload_telemetry(self, payload: 'Dict[str, Any]') -> 'Tuple[bool, Dict[str, Any]]':
        pass

    def get_proxy_list(self) -> 'Tuple[bool, Dict[str, Any]]':
        pass

    def get_home_content(self) -> 'Tuple[bool, Dict[str, Any]]':
        pass

    def check_version(self, current_version: 'str', platform: 'str' = 'windows') -> 'Tuple[bool, Dict[str, Any]]':
        pass

    @property
    def feature_gate(self):
        pass

    def has_feature(self, code: 'str') -> 'bool':
        pass

    def check_feature_access(self, feature_code: 'str') -> 'Tuple[bool, str]':
        pass

    def checkout(self, timeout: 'int' = 15) -> 'Tuple[bool, Dict[str, Any]]':
        pass

    def topup(self, preset_amount: 'int' = None, timeout: 'int' = 15) -> 'Tuple[bool, Dict[str, Any]]':
        pass

    def gemini_api_config(self, timeout: 'int' = 15) -> 'Tuple[bool, Dict[str, Any]]':
        pass

    def _gateway_access_token(self) -> 'str':
        pass

    def _refresh_gateway_token(self, timeout: 'int' = 10) -> 'bool':
        pass

    def _client_v1_request(self, method: 'str', path: 'str', body: 'Dict[str, Any]' = None, timeout: 'int' = 15, retry_refresh: 'bool' = True, extra_headers: 'Dict[str, str]' = None) -> 'Tuple[bool, Dict[str, Any]]':
        pass

    def get_api_keys(self, timeout: 'int' = 10) -> 'Tuple[bool, Dict[str, Any]]':
        pass

    def save_api_key(self, provider: 'str', api_key: 'str', label: 'str' = '', timeout: 'int' = 15) -> 'Tuple[bool, Dict[str, Any]]':
        pass

    def delete_api_key(self, key_id: 'int', timeout: 'int' = 10) -> 'Tuple[bool, Dict[str, Any]]':
        pass

    def update_api_settings(self, api_mode: 'str', timeout: 'int' = 10) -> 'Tuple[bool, Dict[str, Any]]':
        pass

    def get_tool_store(self, tool_code: 'str' = None, timeout: 'int' = 15) -> 'Tuple[bool, Dict[str, Any]]':
        pass

    def buy_tool_or_features(self, payload: 'Dict[str, Any]', timeout: 'int' = 15) -> 'Tuple[bool, Dict[str, Any]]':
        pass

    def buy_feature_days(self, feature_code: 'str', days: 'int', payment_method: 'str', idempotency_key: 'str', timeout: 'int' = 15) -> 'Tuple[bool, Dict[str, Any]]':
        pass

    def create_credit_topup_order(self, amount: 'float', payment_method: 'str' = 'BANK_TRANSFER', currency: 'str' = 'VND', timeout: 'int' = 15) -> 'Tuple[bool, Dict[str, Any]]':
        pass

    def renew_feature_order(self, payload: 'Dict[str, Any]', timeout: 'int' = 15) -> 'Tuple[bool, Dict[str, Any]]':
        pass

    def get_order_payment_info(self, order_code: 'str', timeout: 'int' = 10) -> 'Tuple[bool, Dict[str, Any]]':
        pass

    def get_client_order(self, order_code: 'str', timeout: 'int' = 10) -> 'Tuple[bool, Dict[str, Any]]':
        pass

    def get_credit_usage_dashboard(self, timeout: 'int' = 10) -> 'Tuple[bool, Dict[str, Any]]':
        pass

    def load_from_cache(self) -> 'Optional[Dict[str, Any]]':
        pass

    def clear_cache(self) -> 'bool':
        pass


# --- Class: FeatureGate ---
class FeatureGate:
    """Quản lý feature access. Khởi tạo sau verify, dùng xuyên suốt session."""
    def __init__(self, verify_data: 'dict' = None):
        pass

    def update(self, verify_data: 'dict'):
        pass

    def revoke(self, tier: 'str' = 'FREE') -> 'None':
        pass

    def _extract_maintenance(self, data: 'dict') -> 'Dict[str, dict]':
        pass

    def _extract_demo(self, data: 'dict') -> 'set':
        pass

    def _extract_free(self, data: 'dict') -> 'set':
        pass

    def _extract_feature_codes(self, data: 'dict') -> 'list':
        pass

    def _extract_feature_details(self, data: 'dict') -> 'list':
        pass

    def _coerce_codes(self, raw) -> 'list':
        pass

    def has(self, code: 'str') -> 'bool':
        pass

    def detail(self, code: 'str') -> 'Optional[dict]':
        pass

    def require(self, code: 'str'):
        pass

    def expires_at(self, code: 'str') -> 'Optional[str]':
        pass

    def is_lifetime(self, code: 'str') -> 'bool':
        pass

    @property
    def purchased_features(self):
        pass

    @property
    def feature_details(self):
        pass

    def is_empty(self) -> 'bool':
        pass

    def is_free(self, code: 'str') -> 'bool':
        pass

    def is_maintenance(self, code: 'str') -> 'bool':
        pass

    def maintenance_message(self, code: 'str') -> 'str':
        pass

    def is_demo(self, code: 'str') -> 'bool':
        pass

    def resolve_feature_ui(self, code: 'str') -> 'dict':
        pass

