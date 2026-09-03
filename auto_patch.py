#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Auto-patch script for VeoFlow Pro Max (veo-tool)
Target: Bypass license checks, certificate pinning, and server verification
        Grant full PREMIUM tier with lifetime access and unlimited quota.

Usage:
    uv run --python 3.12 auto_patch.py
"""

import os
import sys
import re
import ast
from pathlib import Path

# Force UTF-8 on Windows console
if sys.platform == "win32":
    try:
        sys.stdout.reconfigure(encoding="utf-8")
        sys.stderr.reconfigure(encoding="utf-8")
    except Exception:
        pass

# Paths
BASE_DIR = Path(__file__).resolve().parent
LICENSE_DIR = BASE_DIR / "decompiled" / "app_source" / "license"

print("=" * 65)
print("🚀 VEOFLOW PRO MAX - AUTOMATIC LICENSE PATCHER")
print(f"📁 Target Directory: {LICENSE_DIR}")
print("=" * 65)

if not LICENSE_DIR.exists():
    print(f"❌ Error: License directory not found: {LICENSE_DIR}")
    sys.exit(1)

def verify_and_save(file_path: Path, new_content: str):
    """Verify AST syntax and save file."""
    try:
        ast.parse(new_content)
    except SyntaxError as e:
        print(f"❌ SyntaxError in {file_path.name}: line {e.lineno} - {e.msg}")
        raise

    file_path.write_text(new_content, encoding="utf-8")
    print(f"  ✅ Patched and verified: {file_path.name}")

# =====================================================================
# 1. PATCH license_manager.py
# =====================================================================
def patch_license_manager():
    file_path = LICENSE_DIR / "license_manager.py"
    print(f"\n[1/3] Patching {file_path.name}...")
    content = file_path.read_text(encoding="utf-8")
    if "from types import NoneType" not in content:
        import_block = """from __future__ import annotations
import sys, os, typing
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

try:
    from types import NoneType
except ImportError:
    NoneType = type(None)

_license_manager = None
"""
        content = re.sub(r'from __future__ import annotations.*?(?=# --- Class)', import_block + "\n", content, flags=re.DOTALL)

    lines = content.splitlines()
    new_lines = []
    i = 0
    n = len(lines)

    while i < n:
        line = lines[i]

        # 1.1 Patch FeatureGate.has & detail & require
        if line.strip().startswith("def has(self"):
            new_lines.append("    def has(self, code: str) -> bool:")
            new_lines.append("        return True")
            new_lines.append("")
            new_lines.append("    def detail(self, code: str) -> Optional[dict]:")
            new_lines.append("        return {")
            new_lines.append("            'feature_code': code,")
            new_lines.append("            'name': code,")
            new_lines.append("            'status': 'active',")
            new_lines.append("            'expires_at': '2099-12-31',")
            new_lines.append("            'license_type': 'LIFETIME'")
            new_lines.append("        }")
            new_lines.append("")
            new_lines.append("    def require(self, code: str):")
            new_lines.append("        return True")
            new_lines.append("")
            new_lines.append("    def expires_at(self, code: 'str') -> 'Optional[str]':")
            new_lines.append("        return '2099-12-31'")
            new_lines.append("")
            new_lines.append("    def is_lifetime(self, code: 'str') -> 'bool':")
            new_lines.append("        return True")
            new_lines.append("")
            new_lines.append("    @property")
            new_lines.append("    def purchased_features(self):")
            new_lines.append("        return [")
            new_lines.append("            'all', 'master_prompt', 'affiliate', 'extend_panel', 'timemachine',")
            new_lines.append("            'voice_studio', 'clone_video', 'deep_research', 'image_story',")
            new_lines.append("            'transcript_video', 'audio_to_video', 'master_options', 'master_panel',")
            new_lines.append("            'clone_panel', 'transcript_panel', 'normal_panel', 'image_panel',")
            new_lines.append("            'affiliate_panel', 'time_machine', 'history'")
            new_lines.append("        ]")
            new_lines.append("")
            new_lines.append("    @property")
            new_lines.append("    def feature_details(self):")
            new_lines.append("        return {code: {'status': 'active', 'tier': 'PREMIUM', 'is_demo': False} for code in self.purchased_features}")
            new_lines.append("")
            new_lines.append("    def is_empty(self) -> 'bool':")
            new_lines.append("        return False")
            new_lines.append("")
            new_lines.append("    def is_free(self, code: 'str' = None) -> 'bool':")
            new_lines.append("        return False")
            new_lines.append("")
            new_lines.append("    def is_maintenance(self, code: 'str' = None) -> 'bool':")
            new_lines.append("        return False")
            new_lines.append("")
            new_lines.append("    def maintenance_message(self, code: 'str' = None) -> 'str':")
            new_lines.append("        return ''")
            new_lines.append("")
            new_lines.append("    def is_demo(self, code: 'str' = None) -> 'bool':")
            new_lines.append("        return False")
            new_lines.append("")
            new_lines.append("    def resolve_feature_ui(self, code: 'str') -> 'dict':")
            new_lines.append("        return {")
            new_lines.append("            'enabled': True,")
            new_lines.append("            'badge': '',")
            new_lines.append("            'message': '',")
            new_lines.append("            'status': 'active',")
            new_lines.append("            'runtime_pack_readiness': 'ready',")
            new_lines.append("            'feature_active': True,")
            new_lines.append("            'feature_code': code,")
            new_lines.append("            'tier': 'PREMIUM',")
            new_lines.append("            'is_demo': False,")
            new_lines.append("            'accessible': True,")
            new_lines.append("            'locked': False")
            new_lines.append("        }")
            # Skip until class LicenseManager:
            i += 1
            while i < n and not lines[i].strip().startswith("class LicenseManager:"):
                i += 1
            continue

        # 1.2 Patch LicenseManager.__init__ & configure & configure_from_cache
        elif line.strip().startswith("class LicenseManager:"):
            new_lines.append(line)
            i += 1
            # Skip class docstring & class attributes until def __init__
            while i < n and not lines[i].strip().startswith("def __init__(self"):
                new_lines.append(lines[i])
                i += 1
            # Replace __init__, configure, configure_from_cache
            new_lines.append("    def __init__(self):")
            new_lines.append("        self._initialized = True")
            new_lines.append("        self._license_key = 'PREMIUM-LIFETIME-KEY'")
            new_lines.append("        self._device_id = 'PREMIUM-DEVICE-ID'")
            new_lines.append("        self._device_fingerprint = '0123456789abcdef' * 4")
            new_lines.append("        self._fingerprint_payload = {}")
            new_lines.append("        self._tool_code = 'VEO3PROTOOL'")
            new_lines.append("        self._server_url = 'https://api.veoflow.dev'")
            new_lines.append("        self._client = None")
            new_lines.append("        self._cached_tier = 'PREMIUM'")
            new_lines.append("        self._cached_quota = 999999")
            new_lines.append("        self._feature_gate = FeatureGate({'tier': 'PREMIUM', 'features': ['all'], 'expires_at': '2099-12-31'})")
            new_lines.append("")
            new_lines.append("    def configure(self, license_key: str = None, device_id: str = None, tool_code: str = 'VEO3PROTOOL', server_url: str = None, initial_tier: str = None, license_info: Dict[str, Any] = None):")
            new_lines.append("        if license_key: self._license_key = license_key")
            new_lines.append("        if device_id: self._device_id = device_id")
            new_lines.append("        if tool_code: self._tool_code = tool_code")
            new_lines.append("        self._cached_tier = 'PREMIUM'")
            new_lines.append("        return True")
            new_lines.append("")
            new_lines.append("    def configure_from_cache(self) -> bool:")
            new_lines.append("        return True")
            # Skip until def _get_device_id
            while i < n and not lines[i].strip().startswith("def _get_device_id("):
                i += 1
            continue

        # 1.3 Patch is_configured & verify_license
        elif line.strip().startswith("def is_configured(self"):
            new_lines.append("    def is_configured(self) -> bool:")
            new_lines.append("        return True")
            new_lines.append("")
            new_lines.append("    def verify_license(self, timeout: int = 15, progress_callback: Optional[Callable[[str, str, int], NoneType]] = None, runtime_pack_callback: Optional[Callable[[dict], NoneType]] = None) -> Tuple[bool, Dict[str, Any]]:")
            new_lines.append("        payload = {")
            new_lines.append("            'tier': 'PREMIUM',")
            new_lines.append("            'license_type': 'PREMIUM',")
            new_lines.append("            'status': 'active',")
            new_lines.append("            'features': ['all'],")
            new_lines.append("            'expires_at': '2099-12-31',")
            new_lines.append("            'remaining_count': 999999,")
            new_lines.append("            'quota': 999999,")
            new_lines.append("            'credits': {")
            new_lines.append("                'available': 500000000,")
            new_lines.append("                'paid': 500000000,")
            new_lines.append("                'free': 0,")
            new_lines.append("                'total': 500000000,")
            new_lines.append("                'paid_balance': 500000000,")
            new_lines.append("                'free_balance': 0,")
            new_lines.append("                'total_balance': 500000000,")
            new_lines.append("            },")
            new_lines.append("            'balance': 500000000,")
            new_lines.append("            'available_balance': 500000000,")
            new_lines.append("        }")
            new_lines.append("        self._cached_tier = 'PREMIUM'")
            new_lines.append("        self._cached_quota = 999999")
            new_lines.append("        self.feature_gate.update(payload)")
            new_lines.append("        return True, payload")
            new_lines.append("")
            new_lines.append("    def _verify_license_serialized(self, timeout: int = 15, progress_callback: Optional[Callable[[str, str, int], NoneType]] = None, runtime_pack_callback: Optional[Callable[[dict], NoneType]] = None) -> Tuple[bool, Dict[str, Any]]:")
            new_lines.append("        return self.verify_license(timeout, progress_callback, runtime_pack_callback)")
            # Skip until def _cache_age_days
            i += 1
            while i < n and not lines[i].strip().startswith("def _cache_age_days(") and not lines[i].strip().startswith("@staticmethod"):
                i += 1
            continue

        # 1.4 Patch properties: tier, license_key, license_info
        elif line.strip() == "@property" and i + 1 < n and lines[i + 1].strip().startswith("def tier(self"):
            new_lines.append("    @property")
            new_lines.append("    def tier(self):")
            new_lines.append("        return 'PREMIUM'")
            new_lines.append("")
            new_lines.append("    @property")
            new_lines.append("    def is_demo(self):")
            new_lines.append("        return False")
            new_lines.append("")
            new_lines.append("    @property")
            new_lines.append("    def quota(self):")
            new_lines.append("        return 999999")
            new_lines.append("")
            new_lines.append("    @property")
            new_lines.append("    def remaining_count(self):")
            new_lines.append("        return 999999")
            new_lines.append("")
            new_lines.append("    @property")
            new_lines.append("    def credits(self) -> int:")
            new_lines.append("        return 500000000")
            new_lines.append("")
            new_lines.append("    @property")
            new_lines.append("    def balance(self) -> int:")
            new_lines.append("        return 500000000")
            new_lines.append("")
            new_lines.append("    @property")
            new_lines.append("    def remaining_credit(self) -> int:")
            new_lines.append("        return 500000000")
            new_lines.append("")
            new_lines.append("    @property")
            new_lines.append("    def license_key(self):")
            new_lines.append("        return self._license_key or 'PREMIUM-LIFETIME-KEY'")
            new_lines.append("")
            new_lines.append("    @property")
            new_lines.append("    def license_info(self):")
            new_lines.append("        return self.get_license_info()")
            new_lines.append("")
            new_lines.append("    def get_license_info(self) -> dict:")
            new_lines.append("        return {")
            new_lines.append("            'tier': 'PREMIUM',")
            new_lines.append("            'license_type': 'PREMIUM',")
            new_lines.append("            'status': 'active',")
            new_lines.append("            'is_demo': False,")
            new_lines.append("            'features': ['all'],")
            new_lines.append("            'expires_at': '2099-12-31',")
            new_lines.append("            'remaining_count': 999999,")
            new_lines.append("            'quota': 999999,")
            new_lines.append("            'daily_quota': 999999,")
            new_lines.append("            'unlimited': True,")
            new_lines.append("            'credits': {")
            new_lines.append("                'available': 500000000,")
            new_lines.append("                'paid': 500000000,")
            new_lines.append("                'free': 0,")
            new_lines.append("                'total': 500000000,")
            new_lines.append("                'paid_balance': 500000000,")
            new_lines.append("                'free_balance': 0,")
            new_lines.append("                'total_balance': 500000000,")
            new_lines.append("            },")
            new_lines.append("            'balance': 500000000,")
            new_lines.append("            'available_balance': 500000000,")
            new_lines.append("            'paid_balance': 500000000,")
            new_lines.append("            'free_balance': 0,")
            new_lines.append("            'total_balance': 500000000,")
            new_lines.append("        }")
            new_lines.append("")
            new_lines.append("    def is_demo_mode(self) -> bool:")
            new_lines.append("        return False")
            new_lines.append("")
            new_lines.append("    def has_feature(self, code: str) -> bool:")
            new_lines.append("        return True")
            new_lines.append("")
            new_lines.append("    def check_feature_access(self, feature_code: str) -> Tuple[bool, str]:")
            new_lines.append("        return True, ''")
            new_lines.append("")
            new_lines.append("    def refresh_credits(self) -> None:")
            new_lines.append("        pass")
            new_lines.append("")
            new_lines.append("    def get_credit_usage_dashboard(self, timeout: int = 10) -> Tuple[bool, Dict[str, Any]]:")
            new_lines.append("        return True, {")
            new_lines.append("            'summary': {")
            new_lines.append("                'available_balance': 500000000,")
            new_lines.append("                'paid_balance': 500000000,")
            new_lines.append("                'free_balance': 0,")
            new_lines.append("                'total_balance': 500000000,")
            new_lines.append("                'spent_today': 0,")
            new_lines.append("                'spent_month': 0,")
            new_lines.append("                'requests_today': 0,")
            new_lines.append("                'requests_month': 0,")
            new_lines.append("            },")
            new_lines.append("            'usage_rows': []")
            new_lines.append("        }")
            new_lines.append("")
            new_lines.append("    def refresh_features(self, timeout: int = 12) -> Tuple[bool, Dict[str, Any]]:")
            new_lines.append("        return True, self.get_license_info()")
            new_lines.append("")
            new_lines.append("    def load_from_cache(self) -> Optional[Dict[str, Any]]:")
            new_lines.append("        return self.get_license_info()")
            new_lines.append("")
            new_lines.append("    def _load_cached_license(self) -> Optional[Dict[str, Any]]:")
            new_lines.append("        return self.get_license_info()")
            # Skip until def _get_main_api_client
            i += 2
            while i < n and not lines[i].strip().startswith("def _get_main_api_client("):
                i += 1
            continue

        # 1.5 Patch feature_gate property, has_feature, check_feature_access
        elif line.strip() == "@property" and i + 1 < n and lines[i + 1].strip().startswith("def feature_gate(self"):
            new_lines.append("    @property")
            new_lines.append("    def feature_gate(self):")
            new_lines.append("        if not hasattr(self, '_feature_gate') or self._feature_gate is None:")
            new_lines.append("            self._feature_gate = FeatureGate({'tier': 'PREMIUM', 'features': ['all'], 'expires_at': '2099-12-31'})")
            new_lines.append("        return self._feature_gate")
            new_lines.append("")
            new_lines.append("    def has_feature(self, code: str) -> bool:")
            new_lines.append("        return True")
            new_lines.append("")
            new_lines.append("    def check_feature_access(self, feature_code: str) -> Tuple[bool, str]:")
            new_lines.append("        return True, ''")
            # Skip until def checkout
            i += 2
            while i < n and not lines[i].strip().startswith("def checkout("):
                i += 1
            continue

        # 1.6 Patch get_license_manager()
        elif line.strip().startswith("def get_license_manager()"):
            new_lines.append("_license_manager = None")
            new_lines.append("")
            new_lines.append("def get_license_manager() -> LicenseManager:")
            new_lines.append("    global _license_manager")
            new_lines.append("    try:")
            new_lines.append("        if _license_manager is None:")
            new_lines.append("            _license_manager = LicenseManager()")
            new_lines.append("    except NameError:")
            new_lines.append("        _license_manager = LicenseManager()")
            new_lines.append("    return _license_manager")
            i += 1
            while i < n and (lines[i].startswith(" ") or lines[i].strip() == ""):
                i += 1
            continue

        new_lines.append(line)
        i += 1

    verify_and_save(file_path, "\n".join(new_lines) + "\n")

# =====================================================================
# 2. PATCH main_license_client.py
# =====================================================================
def patch_main_license_client():
    file_path = LICENSE_DIR / "main_license_client.py"
    print(f"\n[2/3] Patching {file_path.name}...")
    content = file_path.read_text(encoding="utf-8")

    # Ensure robust imports
    if "from requests.adapters import HTTPAdapter" not in content:
        import_block = """from __future__ import annotations
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
"""
        content = re.sub(r'from __future__ import annotations.*?(?=# --- Class)', import_block + "\n", content, flags=re.DOTALL)

    lines = content.splitlines()
    new_lines = []
    i = 0
    n = len(lines)
    in_secure_client = False

    while i < n:
        line = lines[i]

        if line.strip().startswith("class SecureMainLicenseClient"):
            in_secure_client = True
            new_lines.append(line)
            i += 1
            continue

        # 2.1 SecureMainLicenseClient.__init__
        if in_secure_client and line.strip().startswith("def __init__(self"):
            new_lines.append("    def __init__(self, license_key: str = None, tool_code: str = 'VEO3PROTOOL', server_url: str = None, debug: bool = False, use_hardware_keys: bool = False, server_secret: str = None, client_version: str = '2.0.0', device_id: str = None, device_fingerprint: str = None, fingerprint_payload: Dict[str, Any] = None):")
            new_lines.append("        self._license_key = (license_key or 'PREMIUM-LIFETIME-KEY').strip()")
            new_lines.append("        self.license_key = self._license_key")
            new_lines.append("        self.tool_code = tool_code or 'VEO3PROTOOL'")
            new_lines.append("        self.server_url = server_url or 'https://api.veoflow.dev'")
            new_lines.append("        self.debug = debug")
            new_lines.append("        self.client_version = client_version")
            new_lines.append("        self.device_id = device_id or 'PREMIUM-DEVICE-ID'")
            new_lines.append("        self.device_fingerprint = device_fingerprint or '0123456789abcdef' * 4")
            new_lines.append("        self.fingerprint_payload = fingerprint_payload or {}")
            new_lines.append("        self._verified_license_data = None")
            i += 1
            while i < n and not lines[i].strip().startswith("def _create_secure_session("):
                i += 1
            continue

        # 2.2 _make_request
        elif line.strip().startswith("def _make_request(self"):
            new_lines.append("    def _make_request(self, action: str, extra_data: Dict[str, Any] = None, timeout: int = 30) -> Optional[Dict[str, Any]]:")
            new_lines.append("        if action in ('verify', 'status'):")
            new_lines.append("            return {")
            new_lines.append("                'success': True,")
            new_lines.append("                'data': {")
            new_lines.append("                    'tier': 'PREMIUM',")
            new_lines.append("                    'auth': {'gateway_access_token': 'fake'},")
            new_lines.append("                    'license_type': 'PREMIUM',")
            new_lines.append("                    'status': 'active',")
            new_lines.append("                    'features': ['all'],")
            new_lines.append("                    'expires_at': '2099-12-31',")
            new_lines.append("                    'remaining_count': 999999,")
            new_lines.append("                    'quota': 999999")
            new_lines.append("                }")
            new_lines.append("            }")
            new_lines.append("        return {'success': True, 'data': {'tier': 'PREMIUM', 'auth': {'gateway_access_token': 'fake'}}}")
            i += 1
            while i < n and not lines[i].strip().startswith("@staticmethod") and not lines[i].strip().startswith("def _report_verify_progress"):
                i += 1
            continue

        # 2.3 verify_license
        elif line.strip().startswith("def verify_license(self"):
            new_lines.append("    def verify_license(self, device_name: str = None, device_info: Dict[str, Any] = None, timeout: int = 15, progress_callback: Optional[Callable[[str, str, int], NoneType]] = None, runtime_pack_callback: Optional[Callable[[dict[str, Any]], NoneType]] = None) -> bool:")
            new_lines.append("        if getattr(self, '_license_key', None):")
            new_lines.append("            fake_data = {")
            new_lines.append("                'tier': 'PREMIUM',")
            new_lines.append("                'license_type': 'PREMIUM',")
            new_lines.append("                'status': 'active',")
            new_lines.append("                'features': ['all'],")
            new_lines.append("                'expires_at': '2099-12-31',")
            new_lines.append("                'remaining_count': 999999,")
            new_lines.append("                'quota': 999999,")
            new_lines.append("                'auth': {")
            new_lines.append("                    'gateway_access_token': 'dummy_gateway_access_token_v4',")
            new_lines.append("                    'protocol_version': 4.0")
            new_lines.append("                }")
            new_lines.append("            }")
            new_lines.append("            self._verified_license_data = fake_data")
            new_lines.append("            self._report_verify_progress(progress_callback, 'verify', 'License verified successfully', 100)")
            new_lines.append("            return True")
            new_lines.append("        return False")
            i += 1
            while i < n and not lines[i].strip().startswith("def get_status("):
                i += 1
            continue

        # 2.4 Patch cache and license_info methods
        elif line.strip().startswith("def _cache_license_data("):
            new_lines.append("    def _cache_license_data(self, license_data: 'Dict[str, Any]' = None) -> 'None':")
            new_lines.append("        return None")
            new_lines.append("")
            new_lines.append("    @staticmethod")
            new_lines.append("    def _persist_allowed_ai_modes(value: 'Any') -> 'None':")
            new_lines.append("        pass")
            new_lines.append("")
            new_lines.append("    def _get_cached_license_data(self) -> 'Optional[Dict[str, Any]]':")
            new_lines.append("        return self.get_license_info()")
            new_lines.append("")
            new_lines.append("    def get_cached_license_data(self) -> 'Optional[Dict[str, Any]]':")
            new_lines.append("        return self.get_license_info()")
            new_lines.append("")
            new_lines.append("    def _clear_cache(self) -> 'None':")
            new_lines.append("        pass")
            new_lines.append("")
            new_lines.append("    def get_last_error(self) -> 'Optional[str]':")
            new_lines.append("        return None")
            new_lines.append("")
            new_lines.append("    def get_last_error_code(self) -> 'Optional[str]':")
            new_lines.append("        return None")
            new_lines.append("")
            new_lines.append("    def get_last_response(self) -> 'Optional[Dict[str, Any]]':")
            new_lines.append("        return {")
            new_lines.append("            'success': True,")
            new_lines.append("            'status': 'active',")
            new_lines.append("            'tier': 'PREMIUM',")
            new_lines.append("            'data': self.get_license_info()")
            new_lines.append("        }")
            new_lines.append("")
            new_lines.append("    def get_error_details(self) -> 'Dict[str, Any]':")
            new_lines.append("        return {}")
            new_lines.append("")
            new_lines.append("    def get_license_info(self) -> 'Optional[Dict[str, Any]]':")
            new_lines.append("        return {")
            new_lines.append("            'tier': 'PREMIUM',")
            new_lines.append("            'license_type': 'PREMIUM',")
            new_lines.append("            'status': 'active',")
            new_lines.append("            'is_demo': False,")
            new_lines.append("            'features': ['all'],")
            new_lines.append("            'expires_at': '2099-12-31',")
            new_lines.append("            'remaining_count': 999999,")
            new_lines.append("            'quota': 999999,")
            new_lines.append("            'auth': {")
            new_lines.append("                'gateway_access_token': 'fake',")
            new_lines.append("                'protocol_version': 4.0")
            new_lines.append("            }")
            new_lines.append("        }")
            i += 1
            while i < n and not lines[i].strip().startswith("def _log_v4_debug(") and not lines[i].strip().startswith("# --- Top-Level"):
                i += 1
            continue

        new_lines.append(line)
        i += 1

    verify_and_save(file_path, "\n".join(new_lines) + "\n")

# =====================================================================
# 3. PATCH unified_license_client.py
# =====================================================================
def patch_unified_license_client():
    file_path = LICENSE_DIR / "unified_license_client.py"
    print(f"\n[3/3] Patching {file_path.name}...")
    content = file_path.read_text(encoding="utf-8")

    if "from types import NoneType" not in content:
        import_block = """from __future__ import annotations
import sys, os, typing
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

try:
    from types import NoneType
except ImportError:
    NoneType = type(None)
"""
        content = re.sub(r'from __future__ import annotations.*?(?=# --- Class)', import_block + "\n", content, flags=re.DOTALL)

    lines = content.splitlines()
    new_lines = []
    i = 0
    n = len(lines)

    while i < n:
        line = lines[i]

        # 3.1 __init__ & _initialize_client fallback
        if line.strip().startswith("def __init__(self"):
            new_lines.append("    def __init__(self, license_key: str, tool_code: str, server_url: str = None, prefer_v4: bool = True, debug: bool = False, client_version: str = '92.0.117', device_id: str = None, device_fingerprint: str = None, fingerprint_payload: Dict[str, Any] = None):")
            new_lines.append("        self.license_key = license_key or 'PREMIUM-KEY'")
            new_lines.append("        self.tool_code = tool_code or 'VEO3PROTOOL'")
            new_lines.append("        self.server_url = server_url")
            new_lines.append("        self.prefer_v4 = prefer_v4")
            new_lines.append("        self.debug = debug")
            new_lines.append("        self.client_version = client_version")
            new_lines.append("        self.device_id = device_id")
            new_lines.append("        self.device_fingerprint = device_fingerprint")
            new_lines.append("        self.fingerprint_payload = fingerprint_payload")
            new_lines.append("        self.client = None")
            new_lines.append("        self._initialize_client()")
            new_lines.append("")
            new_lines.append("    def _initialize_client(self):")
            new_lines.append("        try:")
            new_lines.append("            if not self._try_init_v4():")
            new_lines.append("                from license.main_license_client import SecureMainLicenseClient")
            new_lines.append("                self.client = SecureMainLicenseClient(license_key=self.license_key, tool_code=self.tool_code, server_url=self.server_url, debug=self.debug)")
            new_lines.append("        except Exception:")
            new_lines.append("            try:")
            new_lines.append("                from license.main_license_client import SecureMainLicenseClient")
            new_lines.append("                self.client = SecureMainLicenseClient(license_key=self.license_key, tool_code=self.tool_code, server_url=self.server_url, debug=self.debug)")
            new_lines.append("            except Exception:")
            new_lines.append("                self.client = None")
            new_lines.append("")
            new_lines.append("    def _try_init_v4(self) -> bool:")
            new_lines.append("        try:")
            new_lines.append("            from license.main_license_client import SecureMainLicenseClient")
            new_lines.append("            self.client = SecureMainLicenseClient(license_key=self.license_key, tool_code=self.tool_code, server_url=self.server_url, debug=self.debug)")
            new_lines.append("            return True")
            new_lines.append("        except Exception:")
            new_lines.append("            return False")
            i += 1
            while i < n and not lines[i].strip().startswith("def verify_license("):
                i += 1
            continue

        # 3.2 verify_license with client is None check
        elif line.strip().startswith("def verify_license(self"):
            new_lines.append("    def verify_license(self, timeout: int = 30, progress_callback: Optional[Callable[[str, str, int], NoneType]] = None, runtime_pack_callback: Optional[Callable[[dict], NoneType]] = None) -> bool:")
            new_lines.append("        if self.client is None:")
            new_lines.append("            self._cached_verify_data = {")
            new_lines.append("                'success': True,")
            new_lines.append("                'tier': 'PREMIUM',")
            new_lines.append("                'license_type': 'PREMIUM',")
            new_lines.append("                'status': 'active',")
            new_lines.append("                'features': ['all'],")
            new_lines.append("                'expires_at': '2099-12-31',")
            new_lines.append("                'remaining_count': 999999,")
            new_lines.append("                'quota': 999999,")
            new_lines.append("                'auth': {'gateway_access_token': 'fake'}")
            new_lines.append("            }")
            new_lines.append("            if progress_callback:")
            new_lines.append("                try: progress_callback('verify', 'License verified successfully (mock)', 100)")
            new_lines.append("                except Exception: pass")
            new_lines.append("            return True")
            new_lines.append("")
            new_lines.append("        if hasattr(self.client, 'verify_license'):")
            new_lines.append("            try:")
            new_lines.append("                return bool(self.client.verify_license(timeout=timeout, progress_callback=progress_callback, runtime_pack_callback=runtime_pack_callback))")
            new_lines.append("            except Exception:")
            new_lines.append("                pass")
            new_lines.append("        return True")
            i += 1
            while i < n and not lines[i].strip().startswith("def check_status("):
                i += 1
            continue

        new_lines.append(line)
        i += 1

    verify_and_save(file_path, "\n".join(new_lines) + "\n")

# =====================================================================
# 4. PATCH secure_memory.py
# =====================================================================
def patch_secure_memory():
    file_path = LICENSE_DIR / "secure_memory.py"
    print(f"\n[4/4] Patching {file_path.name}...")
    secure_mem_code = '''"""
Decompiled / Reconstructed Module: license.secure_memory - Patched
Secure Memory Store - Safe Offline Implementation
"""

from __future__ import annotations
import sys, os, typing
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

class SecureMemoryStore:
    """Safe offline in-memory store for license keys & tokens."""
    def __init__(self):
        self._store: Dict[str, Any] = {}

    def store_bytes(self, name: str, value: bytes):
        self._store[name] = value

    def store_str(self, name: str, value: str):
        self._store[name] = value

    def get_bytes(self, name: str) -> bytes:
        val = self._store.get(name, b"")
        if isinstance(val, str):
            return val.encode("utf-8")
        return val or b""

    def get_str(self, name: str) -> str:
        val = self._store.get(name, "")
        if isinstance(val, bytes):
            return val.decode("utf-8", errors="ignore")
        return str(val or "")

    def destroy(self):
        self._store.clear()

    @staticmethod
    def _xor(data: bytes, mask: bytes) -> bytes:
        return bytes(a ^ b for a, b in zip(data, mask))

    @staticmethod
    def _zero_bytearray(ba: bytearray):
        for i in range(len(ba)):
            ba[i] = 0

_secure_store = None

def get_secure_store() -> SecureMemoryStore:
    global _secure_store
    if _secure_store is None:
        _secure_store = SecureMemoryStore()
    return _secure_store
'''
    verify_and_save(file_path, secure_mem_code)

def patch_credits():
    """Patch account_settings_controller and ai_providers to guarantee 500M VND balance display."""
    print("\n[5/5] Patching credits & balance display to 500,000,000 VND...")
    
    # 1. Patch account_settings_controller.py
    asc_path = BASE_DIR / "decompiled" / "app_source" / "qml_app" / "controllers" / "account_settings_controller.py"
    if asc_path.exists():
        content = asc_path.read_text(encoding="utf-8")
        if "def get_credits" not in content:
            # Inject credit methods into AccountSettingsController
            inject = """
    @property
    def credits(self) -> int:
        return 500000000

    @property
    def balance(self) -> int:
        return 500000000

    def get_credits(self, *args, **kwargs) -> int:
        return 500000000

    def fetch_balance(self, *args, **kwargs) -> int:
        return 500000000

    def get_credit_balance(self, *args, **kwargs) -> int:
        return 500000000
"""
            target = "    def requestOpenBrowser(self, account_id: 'str', email: 'str') -> 'dict[str, Any]':\n        pass"
            if target in content:
                content = content.replace(target, target + inject)
                verify_and_save(asc_path, content)
                print(f"  [OK] Patched {asc_path.name} with 500M credits/balance")

    # 2. Patch ai_providers.py
    aip_path = BASE_DIR / "decompiled" / "app_source" / "services" / "shared" / "ai" / "ai_providers.py"
    if aip_path.exists():
        content = aip_path.read_text(encoding="utf-8")
        if "500000000" not in content:
            old_stub = "    def get_credit_balance(self, *args: Any, **kwargs: Any) -> Dict[str, Any]:\n        pass"
            new_impl = """    def get_credit_balance(self, *args: Any, **kwargs: Any) -> Dict[str, Any]:
        return {
            'balance': 500000000,
            'available': 500000000,
            'available_balance': 500000000,
            'paid_balance': 500000000,
            'free_balance': 0,
            'total_balance': 500000000,
            'credits': 500000000,
            'reserved': 0,
        }"""
            content = content.replace(old_stub, new_impl)
            old_stub2 = "    def get_credit_balance(self) -> Dict[str, Any]:\n        pass"
            new_impl2 = """    def get_credit_balance(self) -> Dict[str, Any]:
        return {
            'balance': 500000000,
            'available': 500000000,
            'available_balance': 500000000,
            'paid_balance': 500000000,
            'free_balance': 0,
            'total_balance': 500000000,
            'credits': 500000000,
            'reserved': 0,
        }"""
            content = content.replace(old_stub2, new_impl2)
            verify_and_save(aip_path, content)
            print(f"  [OK] Patched {aip_path.name} with 500M get_credit_balance")

# =====================================================================
# 6. VERIFICATION SUITE
# =====================================================================
def run_verification():
    print("\n" + "=" * 65)
    print("🧪 RUNNING POST-PATCH VERIFICATION TESTS...")
    print("=" * 65)

    sys.path.insert(0, str(BASE_DIR / "decompiled" / "app_source"))

    # Test 1: FeatureGate.has
    from license.license_manager import FeatureGate, LicenseManager, get_license_manager
    fg = FeatureGate()
    assert fg.has("any_random_feature") is True, "FeatureGate.has must return True"
    assert fg.require("render_4k") is True, "FeatureGate.require must return True"
    print("  [PASS] 1. FeatureGate.has('...') == True")

    # Test 2: LicenseManager
    lm = get_license_manager()
    success, data = lm.verify_license()
    assert success is True, "LicenseManager.verify_license must succeed"
    assert data.get("tier") == "PREMIUM", "License tier must be PREMIUM"
    assert lm.tier == "PREMIUM", "lm.tier must be PREMIUM"
    assert lm.feature_gate.has("deep_prompt") is True, "Feature gate must have feature"
    print(f"  [PASS] 2. LicenseManager.verify_license() == (True, {data.get('tier')})")

    # Test 3: SecureMainLicenseClient
    from license.main_license_client import SecureMainLicenseClient
    sc = SecureMainLicenseClient(license_key="TEST-VIP-KEY")
    assert sc.verify_license() is True, "SecureMainLicenseClient.verify_license must be True"
    req_v = sc._make_request("verify")
    assert req_v.get("success") is True and req_v["data"]["auth"]["gateway_access_token"] == "fake"
    req_s = sc._make_request("status")
    assert req_s.get("success") is True and req_s["data"]["tier"] == "PREMIUM"
    print("  [PASS] 3. SecureMainLicenseClient._make_request('verify'/'status') returned fake token")

    # Test 4: UnifiedLicenseClient
    from license.unified_license_client import UnifiedLicenseClient
    uc_none = UnifiedLicenseClient(license_key=None, tool_code=None)
    uc_none.client = None  # Force None
    assert uc_none.verify_license() is True, "UnifiedLicenseClient with client=None must return True"
    assert uc_none._cached_verify_data["tier"] == "PREMIUM"
    print("  [PASS] 4. UnifiedLicenseClient(client=None).verify_license() == True with PREMIUM cache")

    # Test 5: SecureMemoryStore
    from license.secure_memory import get_secure_store
    ss = get_secure_store()
    assert ss is not None, "get_secure_store() must not be None"
    ss.store_str("test_key", "test_value")
    assert ss.get_str("test_key") == "test_value", "store_str / get_str must work"
    print("  [PASS] 5. secure_memory.get_secure_store() store_str / get_str passed")

    # Test 6: Credits & Balance 500M VND
    assert lm.credits == 500000000, "LicenseManager.credits must be 500,000,000"
    assert lm.balance == 500000000, "LicenseManager.balance must be 500,000,000"
    lic_info = lm.get_license_info()
    assert lic_info.get("credits", {}).get("available") == 500000000, "License info available credits must be 500,000,000"
    assert lic_info.get("balance") == 500000000, "License info balance must be 500,000,000"
    print("  [PASS] 6. Credits & Balance verified: 500,000,000 VND")

    print("\n" + "=" * 65)
    print("🎉 ALL PATCHES APPLIED AND VERIFIED 100% SUCCESSFULLY!")
    print("=" * 65)

if __name__ == "__main__":
    patch_license_manager()
    patch_main_license_client()
    patch_unified_license_client()
    patch_secure_memory()
    patch_credits()
    run_verification()

