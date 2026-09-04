#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
VeoFlow Pro Max - Unpatched Demo Application Loader
Runs the unpacked application in original demo mode (without license/controller patches)
and captures all network traffic for analysis.
"""

import os
import sys
import types
import subprocess
import shutil
import importlib.abc
import importlib.util

# 1. Ensure running under Python 3.12 because unpacked bytecode .pyc is compiled for Python 3.12
if sys.version_info[:2] != (3, 12):
    py312_paths = [
        os.path.expandvars(r"%APPDATA%\uv\python\cpython-3.12-windows-x86_64-none\python.exe"),
        os.path.expanduser(r"~\AppData\Roaming\uv\python\cpython-3.12-windows-x86_64-none\python.exe"),
    ]
    py312_exe = None
    for p in py312_paths:
        if os.path.exists(p):
            py312_exe = p
            break

    if py312_exe:
        sys.exit(subprocess.call([py312_exe, os.path.abspath(__file__)] + sys.argv[1:]))
    elif shutil.which("uv"):
        sys.exit(subprocess.call(["uv", "run", "--python", "3.12", "python", os.path.abspath(__file__)] + sys.argv[1:]))
    else:
        print(f"⚠️ Cảnh báo: Bạn đang dùng Python {sys.version.split()[0]}.")
        print("Bytecode của tool được đóng gói cho Python 3.12. Vui lòng cài Python 3.12 hoặc uv.")

# 2. Force UTF-8 on Windows console
if sys.platform == "win32":
    try:
        sys.stdout.reconfigure(encoding="utf-8")
        sys.stderr.reconfigure(encoding="utf-8")
    except Exception:
        pass

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
EXTRACTED_DIR = os.path.join(BASE_DIR, "unpack-veotool", "VEOFLOWPROMAX.exe_extracted")
PYZ_DIR = os.path.join(EXTRACTED_DIR, "PYZ.pyz_extracted")
APP_SOURCE_DIR = os.path.join(BASE_DIR, "decompiled", "app_source")

# Cờ điều khiển Mock: mặc định True, False khi truyền --no-mock
ENABLE_MOCK = False if "--no-mock" in sys.argv else True
CAPTURE_LOG_FILE = os.path.join(BASE_DIR, "capture_unpack_demo_log.txt")
ERROR_LOG_FILE = os.path.join(BASE_DIR, "capture_error.log")

def capture_log(msg: str):
    print(msg)
    try:
        with open(CAPTURE_LOG_FILE, "a", encoding="utf-8") as f:
            f.write(msg + "\n")
            f.flush()
    except Exception:
        pass

def log_error(msg: str):
    print(f"❌ [LỖI]: {msg}")
    try:
        with open(ERROR_LOG_FILE, "a", encoding="utf-8") as f:
            f.write(msg + "\n")
            f.flush()
    except Exception:
        pass

# 3. Add DLL search directories for C/C++ dependencies and Qt
if hasattr(os, "add_dll_directory"):
    try:
        os.add_dll_directory(BASE_DIR)
        os.add_dll_directory(EXTRACTED_DIR)
        numpy_libs = os.path.join(PYZ_DIR, "numpy.libs")
        if os.path.exists(numpy_libs):
            os.add_dll_directory(numpy_libs)
    except Exception:
        pass

# 4. Configure sys.path prioritizing original unpack PYZ exclusively
sys.path = [PYZ_DIR, EXTRACTED_DIR, BASE_DIR] + [p for p in sys.path if p not in (PYZ_DIR, EXTRACTED_DIR, BASE_DIR)]

# Load original unpatched license from license_backup (bản demo gốc)
backup_license_dir = os.path.join(PYZ_DIR, "license_backup")
if os.path.exists(backup_license_dir):
    try:
        spec = importlib.util.spec_from_file_location(
            "license",
            os.path.join(backup_license_dir, "__init__.pyc"),
            submodule_search_locations=[backup_license_dir]
        )
        mod = importlib.util.module_from_spec(spec)
        sys.modules["license"] = mod
        spec.loader.exec_module(mod)
        print("📦 Đã nạp module license gốc từ license_backup (Bản demo gốc).")
    except Exception as e:
        log_error(f"Không thể nạp license_backup: {e}")

# 5. Smart MetaPath stub loader for missing optional services only
class SmartService:
    def __getattr__(self, name):
        if name in ("list_queue", "get_queue"):
            return lambda *a, **kw: {"ok": True, "rows": []}
        if name == "get_stats":
            return lambda *a, **kw: {"total": 0, "pending": 0, "generating": 0, "completed": 0, "failed": 0}
        if name in ("add_to_queue", "start_queue", "cancel_job", "retry_row", "remove_row"):
            return lambda *a, **kw: {"ok": True, "count": 1}
        if name in ("is_ready", "ready", "enabled", "has_feature", "check_feature_access"):
            return lambda *a, **kw: True
        return lambda *a, **kw: {}
    def __call__(self, *a, **kw):
        return self
    def __iter__(self):
        return iter([])
    def __bool__(self):
        return True

class SmartModule(types.ModuleType):
    def __getattr__(self, name):
        return lambda *a, **kw: SmartService()

class SmartStubFinder(importlib.abc.MetaPathFinder):
    def find_spec(self, fullname, path, target=None):
        if fullname.startswith("services.tabs.") or fullname.startswith("application."):
            # Check if module exists physically in sys.path first
            for finder in sys.meta_path:
                if finder is self:
                    continue
                if hasattr(finder, "find_spec"):
                    try:
                        s = finder.find_spec(fullname, path, target)
                        if s is not None:
                            return s
                    except Exception:
                        pass
            return importlib.util.spec_from_loader(fullname, AutoStubLoader())
        return None

class AutoStubLoader(importlib.abc.Loader):
    def create_module(self, spec):
        return SmartModule(spec.name)
    def exec_module(self, module):
        pass

sys.meta_path.insert(0, SmartStubFinder())

# 5b. Safe fallback for .vfp feature packs runtime
try:
    import core.feature_packs.runtime as fpr
    orig_activate = fpr.activate_entitled_runtime_packs
    def safe_activate_entitled_runtime_packs(*a, **kw):
        try:
            return orig_activate(*a, **kw)
        except Exception as e:
            print(f"⚠️ [FeaturePacks] Fallback activation: {e}")
            return []
    fpr.activate_entitled_runtime_packs = safe_activate_entitled_runtime_packs
except Exception:
    pass

# 6. [COMMENTED OUT] Toàn bộ patch secure_memory (Dùng secure_memory gốc từ license_backup)
# from types import ModuleType
# class FakeSecureStore:
#     def store_bytes(self, name, value): pass
#     def store_str(self, name, value): pass
#     def get_bytes(self, name): return b''
#     def get_str(self, name): return ''
#     def destroy(self): pass
# class FakeSecureModule(ModuleType):
#     def __getattr__(self, name):
#         if name == 'get_secure_store': return lambda: FakeSecureStore()
#         if name == 'SecureMemoryStore': return FakeSecureStore
#         return lambda *a, **kw: None
# sm = FakeSecureModule('license.secure_memory')
# sys.modules['license.secure_memory'] = sm

# Patch certifi to point to a valid cacert.pem so SSL connections work properly
cacert_candidate = os.path.join(PYZ_DIR, "certifi", "cacert.pem")
if not os.path.exists(cacert_candidate):
    sys_cacert = os.path.expandvars(r"%APPDATA%\uv\python\cpython-3.12.13-windows-x86_64-none\Lib\site-packages\pip\_vendor\certifi\cacert.pem")
    if os.path.exists(sys_cacert):
        os.makedirs(os.path.dirname(cacert_candidate), exist_ok=True)
        shutil.copy2(sys_cacert, cacert_candidate)
    else:
        os.makedirs(os.path.dirname(cacert_candidate), exist_ok=True)
        with open(cacert_candidate, "w") as f: f.write("")

os.environ["SSL_CERT_FILE"] = cacert_candidate
os.environ["REQUESTS_CA_BUNDLE"] = cacert_candidate

try:
    import certifi
    certifi.where = lambda: cacert_candidate
except Exception:
    pass

# 7. Request logging & network capturer
try:
    import json
    import requests

    old_session_request = requests.Session.request

    def fake_session_request(self, method, url, *args, **kwargs):
        headers = kwargs.get("headers", {})
        body = kwargs.get("data") or kwargs.get("json") or ""

        # Khi ENABLE_MOCK is False: gửi request thật, in log và ghi vào file capture_unpack_demo_log.txt
        if not ENABLE_MOCK:
            capture_log(f"[REAL REQUEST] Method: {method} | URL: {url} | Headers: {headers} | Body: {body}")
            try:
                resp = old_session_request(self, method, url, *args, **kwargs)
                resp_text = getattr(resp, "text", "")[:500]
                capture_log(f"[REAL RESPONSE] Status: {resp.status_code} | Body: {resp_text}\n")
                return resp
            except Exception as e:
                capture_log(f"[REAL REQUEST ERROR] Method: {method} | URL: {url} | Error: {e}\n")
                log_error(f"Lỗi request: {method} {url} -> {e}")
                raise

        # Mock fallback nếu ENABLE_MOCK is True
        return old_session_request(self, method, url, *args, **kwargs)

    requests.Session.request = fake_session_request
    requests.request = lambda method, url, *a, **kw: fake_session_request(requests.Session(), method, url, *a, **kw)
    requests.get = lambda url, *a, **kw: fake_session_request(requests.Session(), "GET", url, *a, **kw)
    requests.post = lambda url, *a, **kw: fake_session_request(requests.Session(), "POST", url, *a, **kw)

    # Hook urllib.request as well to catch all lower-level network calls
    import urllib.request
    old_urlopen = urllib.request.urlopen
    def fake_urlopen(url, *a, **kw):
        if not ENABLE_MOCK:
            req_url = url.full_url if hasattr(url, "full_url") else str(url)
            capture_log(f"[REAL URLOPEN REQUEST] URL: {req_url}")
            try:
                res = old_urlopen(url, *a, **kw)
                capture_log(f"[REAL URLOPEN RESPONSE] Status: {getattr(res, 'status', 'OK')} | URL: {req_url}\n")
                return res
            except Exception as e:
                capture_log(f"[REAL URLOPEN ERROR] URL: {req_url} | Error: {e}\n")
                raise
        return old_urlopen(url, *a, **kw)
    urllib.request.urlopen = fake_urlopen

except Exception as e:
    log_error(f"Lỗi hook requests: {e}")

# 8. [COMMENTED OUT] Toàn bộ patch cho WorkPanelController & AppController (Chạy 100% theo logic gốc)
# try:
#     import qml_app.controllers.work_panel_controller as wpc
#     wpc.WorkPanelController._account_run_blocker = lambda self, *a, **kw: None
#     wpc.WorkPanelController._credit_gate_blocker = lambda self, *a, **kw: None
#     wpc.WorkPanelController.cloneNoLiveAccountsPauseRequired = property(lambda self: False)
#     wpc.WorkPanelController.cloneAuthPauseRequired = property(lambda self: False)
#     wpc.WorkPanelController.transcriptQueuePaused = property(lambda self: False)
#     wpc.WorkPanelController.clone_queue_paused = property(lambda self: False)
#     wpc.WorkPanelController.cloneQueuePaused = property(lambda self: False)
#     wpc.WorkPanelController.clone_credit_blocked = property(lambda self: False)
#     wpc.WorkPanelController.cloneCreditBlocked = property(lambda self: False)
#     wpc.WorkPanelController.authPauseRequired = property(lambda self: False)
#     wpc.WorkPanelController.noLiveAccountsPauseRequired = property(lambda self: False)
#     wpc.WorkPanelController.clone_auto_fetch_busy = property(lambda self: False)
#     wpc.WorkPanelController.cloneAutoFetchBusy = property(lambda self: False)
#     wpc.WorkPanelController.currentRouteConfig = ...
#     wpc.WorkPanelController._clone = ...
#     wpc.WorkPanelController.applyCloneBulkConfig = ...
# except Exception:
#     pass

# try:
#     import qml_app.controllers.app_controller as ac
#     ac.AppController.liveAccountCount = lambda self: 1
#     ac.AppController.live_account_count = property(lambda self: 1)
# except Exception:
#     pass

# 9. [COMMENTED OUT] Toàn bộ patch FeatureGate & license_manager (Bản demo gốc chạy logic tự nhiên)
# import license.license_manager as lm_mod
# from license.license_manager import get_license_manager
# lm = get_license_manager()
# lm.configure(license_key="PREMIUM-LIFETIME-KEY", device_id="PREMIUM-DEVICE-ID")
# success, info = lm.verify_license()

print("=" * 65)
print("🚀 VEOFLOW PRO MAX - ORIGINAL DEMO RUNNER & TRAFFIC CAPTURER")
print("=" * 65)
print("  • Chế độ hoạt động : BẢN DEMO GỐC (KHÔNG PATCH LICENSE / CONTROLLER)")
print(f"  • Chế độ Mock      : {'BẬT (MOCK)' if ENABLE_MOCK else 'TẮT (GỬI REQUEST THẬT --no-mock)'}")
print(f"  • File lưu log     : {CAPTURE_LOG_FILE}")
print("=" * 65)

# Reset proxy về trạng thái tự động khi kết thúc hoặc thoát
def reset_proxy_to_automatic():
    try:
        import winreg
        key = winreg.OpenKey(winreg.HKEY_CURRENT_USER, r"Software\Microsoft\Windows\CurrentVersion\Internet Settings", 0, winreg.KEY_WRITE)
        winreg.SetValueEx(key, "ProxyEnable", 0, winreg.REG_DWORD, 0)
        winreg.CloseKey(key)
        print("🌐 Đã xác nhận / reset proxy về chế độ 'Tự động' (ProxyEnable = 0).")
    except Exception as e:
        log_error(f"Không thể reset proxy: {e}")

import atexit
atexit.register(reset_proxy_to_automatic)

# 10. Test Clone Video auto pipeline if --test-clone is passed
if "--test-clone" in sys.argv:
    print("\n🧪 [TRIGGER CLONE VIDEO FLOW ON DEMO VERSION]")
    test_url = "https://www.youtube.com/watch?v=t8Gl7tf8Sfo"
    try:
        import services.tabs.clone_video.youtube_clone_service as ycs
        service = ycs.get_youtube_clone_service()
        print(f"  • Service instance: {service}")
        print(f"  • Đang kiểm tra video details cho: {test_url}")
        try:
            details = service.get_video_details(test_url)
            print(f"  • Video details: {details}")
        except Exception as e:
            print(f"  • get_video_details response / error: {e}")
            log_error(f"get_video_details: {e}")

        try:
            print(f"  • Đang thử gọi clone_video trên bản demo gốc:")
            res = service.clone_video(test_url, {})
            print(f"  • clone_video result: {res}")
        except Exception as e:
            print(f"  • clone_video response / error: {e}")
            log_error(f"clone_video: {e}")
    except Exception as e:
        log_error(f"Lỗi khi chạy test-clone: {e}")
        import traceback
        traceback.print_exc()

    print("✅ Hoàn tất kích hoạt Clone Video trên bản demo gốc.")
    reset_proxy_to_automatic()
    sys.exit(0)

# 11. Launch application GUI
try:
    print("⏳ Đang khởi động giao diện bản demo gốc...")
    import qml_app.main
    sys.exit(qml_app.main.main(sys.argv))
except Exception as e:
    if "QGuiApplication" in str(e) or "cannot connect to display" in str(e).lower() or "qt" in str(e).lower():
        print(f"ℹ️ [Thông báo] Giao diện đồ họa đóng hoặc headless: {e}")
        reset_proxy_to_automatic()
        sys.exit(0)
    else:
        log_error(f"Lỗi khi chạy bản demo: {e}")
        import traceback
        traceback.print_exc()
        reset_proxy_to_automatic()
        sys.exit(1)
finally:
    reset_proxy_to_automatic()
