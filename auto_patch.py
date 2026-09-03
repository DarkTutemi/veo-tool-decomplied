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
    lines = file_path.read_text(encoding="utf-8").splitlines()

    # Reconstruct cleanly
    new_lines = []
    i = 0
    n = len(lines)

    while i < n:
        line = lines[i]

        # 1.1 Patch FeatureGate.has & detail & require
        if line.strip().startswith("def has(self, code: str) -> bool:"):
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
            # Skip until expires_at
            i += 1
            while i < n and not lines[i].strip().startswith("def expires_at("):
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
        elif line.strip().startswith("def is_configured(self) -> bool:"):
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
        elif line.strip() == "@property" and i + 1 < n and lines[i + 1].strip().startswith("def tier(self):"):
            new_lines.append("    @property")
            new_lines.append("    def tier(self):")
            new_lines.append("        return 'PREMIUM'")
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
            new_lines.append("            'features': ['all'],")
            new_lines.append("            'expires_at': '2099-12-31',")
            new_lines.append("            'remaining_count': 999999,")
            new_lines.append("            'quota': 999999,")
            new_lines.append("        }")
            # Skip until def refresh_credits
            i += 2
            while i < n and not lines[i].strip().startswith("def refresh_credits("):
                i += 1
            continue

        # 1.5 Patch feature_gate property, has_feature, check_feature_access
        elif line.strip() == "@property" and i + 1 < n and lines[i + 1].strip().startswith("def feature_gate(self):"):
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
            new_lines.append("def get_license_manager() -> LicenseManager:")
            new_lines.append("    global _license_manager")
            new_lines.append("    if _license_manager is None:")
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
    lines = file_path.read_text(encoding="utf-8").splitlines()

    new_lines = []
    i = 0
    n = len(lines)

    while i < n:
        line = lines[i]

        # 2.1 SecureMainLicenseClient.__init__
        if line.strip().startswith("def __init__(self, license_key: str = None") or \
           line.strip().startswith("def __init__(self, license_key: str, tool_code: str"):
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
        elif line.strip().startswith("def _make_request(self, action: str"):
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
        elif line.strip().startswith("def verify_license(self, device_name: str = None"):
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

        new_lines.append(line)
        i += 1

    verify_and_save(file_path, "\n".join(new_lines) + "\n")

# =====================================================================
# 3. PATCH unified_license_client.py
# =====================================================================
def patch_unified_license_client():
    file_path = LICENSE_DIR / "unified_license_client.py"
    print(f"\n[3/3] Patching {file_path.name}...")
    lines = file_path.read_text(encoding="utf-8").splitlines()

    new_lines = []
    i = 0
    n = len(lines)

    while i < n:
        line = lines[i]

        # 3.1 __init__ & _initialize_client fallback
        if line.strip().startswith("def __init__(self, license_key: str"):
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
        elif line.strip().startswith("def verify_license(self, timeout: int = 30"):
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
# 4. VERIFICATION SUITE
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

    print("\n" + "=" * 65)
    print("🎉 ALL PATCHES APPLIED AND VERIFIED 100% SUCCESSFULLY!")
    print("=" * 65)

if __name__ == "__main__":
    patch_license_manager()
    patch_main_license_client()
    patch_unified_license_client()
    run_verification()
