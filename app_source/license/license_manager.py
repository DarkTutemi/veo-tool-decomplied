"""
Decompiled / Reconstructed Module: license.license_manager

Docstring:
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

__all__ = ['LicenseManager', 'FeatureGate', 'get_license_manager']

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
List = typing.List
Optional = typing.Optional
Tuple = typing.Tuple
Union = typing.Union
Callable = typing.Callable
__all__ = ['LicenseManager', 'FeatureGate', 'get_license_manager']
_VERBOSE = False
_DEFAULT_OFFLINE_GRACE_DAYS = 7
_MAX_OFFLINE_GRACE_DAYS_CEILING = 30
MAX_OFFLINE_GRACE_DAYS = 7
_license_manager = None

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
        # [PyArmor BCC constants]: 'feature_code', 'name', 'status', 'expires_at', 'license_type'
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

    def configure(self, license_key: 'str' = None, device_id: 'str' = None, tool_code: 'str' = 'VEO3PROTOOL', server_url: 'str' = None, initial_tier: 'str' = None, license_info: 'Dict[str, Any]' = None):
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
        # [PyArmor BCC constants]: 'tier', 'license_type', 'status', 'features', 'expires_at', 'remaining_count', 'quota'
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
        # [PyArmor BCC constants]: 'tier', 'license_type', 'status', 'features', 'expires_at', 'remaining_count', 'quota'
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


# --- Top-Level Functions ---
def _vlog(message: 'str') -> 'None':
    pass

def _resolve_offline_grace_days() -> 'int':
    pass

def get_license_manager() -> 'LicenseManager':
    pass
