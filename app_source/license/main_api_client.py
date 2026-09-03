"""
Decompiled / Reconstructed Module: license.main_api_client

Docstring:
VeoFlow MAIN server API client.

This module centralizes desktop client calls to the MAIN web/license server so
license-related runtime traffic lives under the `license` package instead of the
broad `services` bucket.
"""

from __future__ import annotations
import sys, os, typing
from typing import Any, Dict, List, Optional, Tuple, Union, Callable
try:
    import requests
    import requests.sessions
except ImportError:
    pass

# --- Module Constants & Globals ---
Dict = typing.Dict
Optional = typing.Optional
_client_instance = None

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


# --- Top-Level Functions ---
def get_veoflow_client(license_key: Optional[str] = None, base_url: str = None) -> Optional[license.main_api_client.VeoflowAPIClient]:
    # [PyArmor BCC constants]: '_client_instance', 'JSONLicenseCacheManager', 'get_license_data', 'get', 'license_key', 'api_secret', 'Exception', 'VeoflowAPIClient'
    pass

def reset_veoflow_client():
    pass