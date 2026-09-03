"""
Decompiled / Reconstructed Module: license.main_api_client

Docstring:
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

# --- Module Constants & Globals ---
Dict = typing.Dict
List = typing.List
Optional = typing.Optional
Tuple = typing.Tuple
Union = typing.Union
Callable = typing.Callable
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


# --- Top-Level Functions ---
def get_veoflow_client(license_key: 'Optional[str]' = None, base_url: 'str' = None) -> 'Optional[license.main_api_client.VeoflowAPIClient]':
    pass

def reset_veoflow_client():
    pass
