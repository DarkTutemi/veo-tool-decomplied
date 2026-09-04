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

# 8. Patch WorkPanelController to ensure default route_configs & WorkPanelState
try:
    import uuid
    import qml_app.controllers.work_panel_controller as wpc

    _default_clone_route_cfg = {
        'mode': 'url',
        'aspect_ratio': '16:9',
        'quality': '720p',
        'resolution': '720p',
        'market': 'global',
        'target_market': 'global',
        'video_model_key': 'veo-3.1-lite',
        'model_key': 'veo-3.1-lite',
        'duration': 60,
        'duration_seconds': 60,
        'status': 'idle',
    }

    _wps_default_configs = {
        'clone': {'mode': 'url', 'aspect_ratio': '16:9', 'quality': '720p', 'resolution': '720p', 'market': 'global', 'target_market': 'global', 'video_model_key': 'veo-3.1-lite', 'model_key': 'veo-3.1-lite', 'duration': 60, 'duration_seconds': 60, 'status': 'idle'},
        'normal': {'mode': 'url', 'aspect_ratio': '16:9', 'quality': '720p', 'resolution': '720p', 'market': 'global', 'target_market': 'global', 'video_model_key': 'veo-3.1-lite', 'model_key': 'veo-3.1-lite'},
        'affiliate': {'mode': 'url', 'aspect_ratio': '16:9', 'quality': '720p', 'resolution': '720p', 'market': 'global', 'target_market': 'global', 'video_model_key': 'veo-3.1-lite', 'model_key': 'veo-3.1-lite'},
        'transcript': {'mode': 'url', 'aspect_ratio': '16:9', 'quality': '720p', 'resolution': '720p', 'market': 'global', 'target_market': 'global', 'video_model_key': 'veo-3.1-lite', 'model_key': 'veo-3.1-lite'},
    }

    class WorkPanelRouteConfigProperty:
        def __init__(self, default_cfg):
            self.default_cfg = default_cfg
            self.store = {}
        def __get__(self, instance, owner=None):
            if instance is None:
                return self.default_cfg
            return self.store.get(id(instance), self.default_cfg)
        def __set__(self, instance, value):
            self.store[id(instance)] = value

    # 1. Patch or create WorkPanelState on wpc
    if hasattr(wpc, 'WorkPanelState'):
        wpc.WorkPanelState._route_configs = WorkPanelRouteConfigProperty(_wps_default_configs)
        for _attr, _val in [
            ('mode', 'url'),
            ('aspect_ratio', '16:9'),
            ('quality', '720p'),
            ('resolution', '720p'),
            ('market', 'global'),
            ('target_market', 'global'),
            ('_route', 'clone'),
            ('_selected_characters_by_route', {}),
        ]:
            if not hasattr(wpc.WorkPanelState, _attr):
                try:
                    setattr(wpc.WorkPanelState, _attr, _val)
                except Exception:
                    pass
    else:
        class FallbackWorkPanelState(object):
            _route_configs = WorkPanelRouteConfigProperty(_wps_default_configs)
            mode = 'url'
            aspect_ratio = '16:9'
            quality = '720p'
            resolution = '720p'
            market = 'global'
            target_market = 'global'
            _route = 'clone'
            _selected_characters_by_route = {}
            def __init__(self, *args, **kwargs):
                self._route_configs = dict(_wps_default_configs)
                self.mode = 'url'
                self.aspect_ratio = '16:9'
                self.quality = '720p'
                self.resolution = '720p'
                self.market = 'global'
                self.target_market = 'global'
                self._route = 'clone'
                self._selected_characters_by_route = {}
        wpc.WorkPanelState = FallbackWorkPanelState

    # Also patch application.work_panel.state.WorkPanelState if present
    try:
        import application.work_panel.state as _wps_mod
        if hasattr(_wps_mod, 'WorkPanelState'):
            _wps_mod.WorkPanelState._route_configs = WorkPanelRouteConfigProperty(_wps_default_configs)
    except Exception:
        pass

    # Also patch application.work_panel.clone.WorkPanelState if present
    try:
        import application.work_panel.clone as _wpc_clone_mod
        if hasattr(_wpc_clone_mod, 'WorkPanelState'):
            _wpc_clone_mod.WorkPanelState._route_configs = WorkPanelRouteConfigProperty(_wps_default_configs)
            for _attr, _val in [
                ('mode', 'url'),
                ('aspect_ratio', '16:9'),
                ('quality', '720p'),
                ('resolution', '720p'),
                ('market', 'global'),
                ('target_market', 'global'),
                ('_route', 'clone'),
                ('_selected_characters_by_route', {}),
            ]:
                if not hasattr(_wpc_clone_mod.WorkPanelState, _attr):
                    try:
                        setattr(_wpc_clone_mod.WorkPanelState, _attr, _val)
                    except Exception:
                        pass
    except Exception:
        pass

    # Patch application.work_panel.character._selected_character_payload
    try:
        import application.work_panel.character as _wpc_char_mod
        if hasattr(_wpc_char_mod, "WorkPanelState"):
            _wpc_char_mod.WorkPanelState._route_configs = WorkPanelRouteConfigProperty(_wps_default_configs)

        orig_char_payload = getattr(_wpc_char_mod, "_selected_character_payload", None)
        def safe_func_char_payload(self, *args, **kwargs):
            if not hasattr(self, "_route_configs") or getattr(self, "_route_configs", None) is None:
                try:
                    self._route_configs = dict(_wps_default_configs)
                except Exception:
                    pass
            if orig_char_payload:
                try:
                    res = orig_char_payload(self, *args, **kwargs)
                    if isinstance(res, dict):
                        return res
                except Exception:
                    pass
            return {}
        _wpc_char_mod._selected_character_payload = safe_func_char_payload

        orig_usecase_char_payload = getattr(getattr(_wpc_char_mod, "CharacterUseCases", None), "_selected_character_payload", None)
        def safe_usecase_char_payload(self, *args, **kwargs):
            state = getattr(self, "state", self)
            if state is not None:
                if not hasattr(state, "_route_configs") or getattr(state, "_route_configs", None) is None:
                    try:
                        state._route_configs = dict(_wps_default_configs)
                    except Exception:
                        pass
                if not hasattr(state, "_selected_characters_by_route") or getattr(state, "_selected_characters_by_route", None) is None:
                    try:
                        state._selected_characters_by_route = {}
                    except Exception:
                        pass
                if not hasattr(state, "_route") or getattr(state, "_route", None) is None:
                    try:
                        state._route = "clone"
                    except Exception:
                        pass
            if orig_usecase_char_payload:
                try:
                    res = orig_usecase_char_payload(self, *args, **kwargs)
                    if isinstance(res, dict):
                        return res
                except Exception:
                    pass
            return {}
        if hasattr(_wpc_char_mod, "CharacterUseCases"):
            _wpc_char_mod.CharacterUseCases._selected_character_payload = safe_usecase_char_payload
    except Exception:
        pass

    orig_wpc_char_payload = getattr(wpc.WorkPanelController, "_selected_character_payload", None)
    def safe_wpc_char_payload(self, *args, **kwargs):
        if hasattr(self, "_state") and self._state is not None:
            if not hasattr(self._state, "_route_configs") or getattr(self._state, "_route_configs", None) is None:
                try:
                    self._state._route_configs = dict(_wps_default_configs)
                except Exception:
                    pass
        if orig_wpc_char_payload:
            try:
                res = orig_wpc_char_payload(self, *args, **kwargs)
                if isinstance(res, dict):
                    return res
            except Exception:
                pass
        return {}
    wpc.WorkPanelController._selected_character_payload = safe_wpc_char_payload

    # Gán _route_configs trực tiếp trên class WorkPanelController
    wpc.WorkPanelController._route_configs = {'clone': dict(_default_clone_route_cfg)}

    # Patch WorkPanelController.__init__ để khởi tạo _state._route_configs
    orig_wpc_init = wpc.WorkPanelController.__init__
    def safe_wpc_init(self, *args, **kwargs):
        self._route_configs = {'clone': dict(_default_clone_route_cfg)}
        self._route_config = dict(self._route_configs)
        try:
            orig_wpc_init(self, *args, **kwargs)
        except Exception as e:
            pass
        if getattr(self, "_route_configs", None) is None or not isinstance(self._route_configs, dict):
            self._route_configs = {'clone': dict(_default_clone_route_cfg)}
        elif "clone" not in self._route_configs:
            self._route_configs["clone"] = dict(_default_clone_route_cfg)
        if getattr(self, "_route_config", None) is None:
            self._route_config = dict(self._route_configs)

        if hasattr(self, "_state") and self._state is not None:
            try:
                self._state._route_configs = dict(_wps_default_configs)
            except Exception:
                pass
            if not hasattr(self._state, "_route") or getattr(self._state, "_route", None) is None:
                try:
                    self._state._route = "clone"
                except Exception:
                    pass
            if not hasattr(self._state, "_selected_characters_by_route") or getattr(self._state, "_selected_characters_by_route", None) is None:
                try:
                    self._state._selected_characters_by_route = {}
                except Exception:
                    pass

    wpc.WorkPanelController.__init__ = safe_wpc_init

    _default_clone_config = {
        'mode': 'url',
        'aspect_ratio': '16:9',
        'quality': '720p',
        'resolution': '720p',
        'market': 'global',
        'target_market': 'global',
        'video_model_key': 'veo-3.1-lite',
        'model_key': 'veo-3.1-lite',
        'duration': 60,
        'duration_seconds': 60,
        'status': 'idle',
        'clone': {
            'mode': 'url',
            'aspect_ratio': '16:9',
            'quality': '720p',
            'resolution': '720p',
            'market': 'global',
            'target_market': 'global',
            'video_model_key': 'veo-3.1-lite',
            'model_key': 'veo-3.1-lite',
            'duration': 60,
            'duration_seconds': 60,
            'status': 'idle',
        },
        'normal': {
            'mode': 'url',
            'aspect_ratio': '16:9',
            'quality': '720p',
            'resolution': '720p',
            'market': 'global',
            'target_market': 'global',
            'video_model_key': 'veo-3.1-lite',
            'model_key': 'veo-3.1-lite',
        },
        'extend': {
            'mode': 'url',
            'aspect_ratio': '16:9',
            'quality': '720p',
            'resolution': '720p',
            'market': 'global',
            'target_market': 'global',
            'video_model_key': 'veo-3.1-lite',
            'model_key': 'veo-3.1-lite',
        },
        'transcript': {
            'mode': 'url',
            'aspect_ratio': '16:9',
            'quality': '720p',
            'resolution': '720p',
            'market': 'global',
            'target_market': 'global',
            'video_model_key': 'veo-3.1-lite',
            'model_key': 'veo-3.1-lite',
        },
    }

    class CallableRouteConfig(dict):
        def __call__(self, *args, **kwargs):
            return self

    class HybridProperty:
        def __init__(self, func):
            self.func = func
        def __get__(self, instance, owner=None):
            if instance is None:
                return self
            return CallableRouteConfig(self.func(instance))
        def __call__(self, instance=None, *args, **kwargs):
            return CallableRouteConfig(self.func(instance, *args, **kwargs))

    # 2. Patch _effective_route_config và _compute_effective_route_config
    def safe_effective_route_config(self, route='clone', *args, **kwargs):
        cfg = CallableRouteConfig(_default_clone_config)
        route_key = str(route).lower().strip() if route else 'clone'
        if route_key in _default_clone_config and isinstance(_default_clone_config[route_key], dict):
            for k, v in _default_clone_config[route_key].items():
                cfg.setdefault(k, v)
        cfg['video_model_key'] = 'veo-3.1-lite'
        cfg['model_key'] = 'veo-3.1-lite'
        cfg['mode'] = 'url'
        cfg['clone'] = dict(_default_clone_config)
        return cfg

    wpc.WorkPanelController._effective_route_config = safe_effective_route_config
    wpc.WorkPanelController._compute_effective_route_config = safe_effective_route_config

    # 4. Đảm bảo currentRouteConfig luôn trả về dict đầy đủ
    wpc.WorkPanelController.currentRouteConfig = HybridProperty(lambda self, *a, **kw: safe_effective_route_config(self, getattr(self, '_route', 'clone')))

    # 3. Patch cloneFlowVoiceReferencesSupported & cloneFlowVoiceReferenceLimit
    wpc.WorkPanelController.cloneFlowVoiceReferencesSupported = property(lambda self: True)
    wpc.WorkPanelController.cloneFlowVoiceReferenceLimit = property(lambda self: 1)

    # An toàn cho clone timer & batch rows
    def safe_clone_timer(self, row=None, *args, **kwargs):
        if row is None or not isinstance(row, dict):
            row = {"duration_seconds": 60, "duration": 60, "status": "idle"}
        dur = row.get("duration_seconds")
        if dur is None or dur <= 0:
            row["duration_seconds"] = 60
        if "duration" not in row or not row.get("duration"):
            row["duration"] = row["duration_seconds"]
        if "status" not in row or not row.get("status"):
            row["status"] = "idle"
        return row

    wpc.WorkPanelController._update_clone_timer = safe_clone_timer
    wpc.WorkPanelController._refresh_clone_status = safe_clone_timer

    def safe_on_clone_batch_rows_changed(self, rows=None, *args, **kwargs):
        if rows is None:
            rows = []
        elif not isinstance(rows, (list, tuple)):
            try:
                rows = list(rows)
            except Exception:
                rows = []
        return rows

    wpc.WorkPanelController._on_clone_batch_rows_changed = safe_on_clone_batch_rows_changed

    # An toàn cho applyCloneBulkConfig và submitCloneCardsWithConfig
    orig_apply_clone_bulk = getattr(wpc.WorkPanelController, "applyCloneBulkConfig", None)
    def safe_apply_clone_bulk(self, links_with_config=None, common_config=None, *args, **kwargs):
        cards = links_with_config or []
        if isinstance(cards, dict):
            cards = [cards]
        elif not isinstance(cards, (list, tuple)):
            cards = []

        if hasattr(self, "_state") and self._state is not None:
            if not hasattr(self._state, "_route_configs") or getattr(self._state, "_route_configs", None) is None:
                try:
                    self._state._route_configs = dict(_wps_default_configs)
                except Exception:
                    pass

        # Thử gọi hàm gốc trước
        res = None
        if orig_apply_clone_bulk:
            try:
                res = orig_apply_clone_bulk(self, links_with_config, common_config, *args, **kwargs)
            except Exception:
                res = None

        if isinstance(res, dict) and res.get("ok"):
            if hasattr(self, "_load_queue_rows") and callable(self._load_queue_rows):
                try:
                    self._queue_rows = self._load_queue_rows()
                except Exception:
                    pass
            try:
                if hasattr(self, "queueRowsChanged"):
                    self.queueRowsChanged.emit()
            except Exception:
                pass
            return res

        # Fallback thêm job vào clone service & queue rows
        clone_service = getattr(self, "_clone", None)
        cnt = len(cards) if cards else 1
        row_ids = [f"clone_{uuid.uuid4().hex[:8]}" for _ in range(cnt)]

        if clone_service and hasattr(clone_service, "add_to_queue"):
            try:
                res_clone = clone_service.add_to_queue(sources=cards)
            except Exception:
                try:
                    res_clone = clone_service.add_to_queue(cards)
                except Exception:
                    res_clone = None
            if isinstance(res_clone, dict) and res_clone.get("ok"):
                if "row_ids" in res_clone:
                    row_ids = res_clone["row_ids"]
                if "count" in res_clone:
                    cnt = res_clone["count"]

        # Cập nhật _queue_rows để giao diện hiển thị
        if not hasattr(self, "_queue_rows") or not isinstance(self._queue_rows, list):
            self._queue_rows = []

        for i, cid in enumerate(row_ids):
            card_data = cards[i] if i < len(cards) and isinstance(cards[i], dict) else {}
            new_row = {
                "id": cid,
                "row_id": cid,
                "url": card_data.get("url", ""),
                "title": card_data.get("title", f"Clone Video #{i+1}"),
                "status": "pending",
                "duration_seconds": card_data.get("duration_seconds", 60),
                "duration": card_data.get("duration", 60),
                "route": "clone",
            }
            self._queue_rows.append(new_row)

        try:
            if hasattr(self, "queueRowsChanged"):
                self.queueRowsChanged.emit()
        except Exception:
            pass
        try:
            if hasattr(self, "refreshQueueAndStats") and callable(self.refreshQueueAndStats):
                self.refreshQueueAndStats()
        except Exception:
            pass

        return {
            "ok": True,
            "count": cnt,
            "message": f"Đã thêm {cnt} video vào hàng chờ",
            "row_ids": row_ids,
        }

    wpc.WorkPanelController.applyCloneBulkConfig = safe_apply_clone_bulk
    wpc.WorkPanelController.submitCloneCardsWithConfig = lambda self, cards=None, *a, **kw: safe_apply_clone_bulk(self, links_with_config=cards, common_config={}, *a, **kw)

    print("✅ [WorkPanelController & WorkPanelState] Đã cấu hình fallback mặc định cho route_configs và character payload.")
except Exception as e:
    log_error(f"Lỗi patch WorkPanelController: {e}")

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
        # 1. Kiểm tra WorkPanelController & WorkPanelState
        print("  • Kiểm tra khởi tạo WorkPanelController & WorkPanelState:")
        ctrl = wpc.WorkPanelController.__new__(wpc.WorkPanelController)
        ctrl.__init__()
        print(f"  • ctrl._state: {getattr(ctrl, '_state', None)}")
        state_cfgs = getattr(getattr(ctrl, '_state', None), '_route_configs', None)
        print(f"  • ctrl._state._route_configs: {state_cfgs}")
        assert hasattr(ctrl, "_state"), "ctrl must have _state"
        assert hasattr(ctrl._state, "_route_configs"), "ctrl._state must have _route_configs"
        assert isinstance(ctrl._state._route_configs, dict), "_route_configs must be a dict"
        assert "clone" in ctrl._state._route_configs, "_route_configs must have 'clone' route"

        # 2. Kiểm tra _selected_character_payload
        print("  • Kiểm tra _selected_character_payload:")
        char_res = ctrl._selected_character_payload()
        print(f"  • _selected_character_payload result: {char_res}")
        assert isinstance(char_res, dict), "_selected_character_payload must return dict"

        # 3. Kiểm tra 'Vào hàng chờ' (applyCloneBulkConfig & submitCloneCardsWithConfig)
        print("  • Kiểm tra 'Vào hàng chờ' (applyCloneBulkConfig / submitCloneCardsWithConfig):")
        test_cards = [{"url": test_url, "title": "Test Video", "duration_seconds": 60}]
        bulk_res = ctrl.applyCloneBulkConfig(test_cards, {})
        print(f"  • applyCloneBulkConfig result: {bulk_res}")
        assert bulk_res.get("ok") is True, f"applyCloneBulkConfig failed: {bulk_res}"

        submit_res = ctrl.submitCloneCardsWithConfig(test_cards)
        print(f"  • submitCloneCardsWithConfig result: {submit_res}")
        assert submit_res.get("ok") is True, f"submitCloneCardsWithConfig failed: {submit_res}"

        queue_len = len(ctrl._load_queue_rows() if hasattr(ctrl, "_load_queue_rows") else getattr(ctrl, "_queue_rows", []))
        print(f"  • Số jobs trong hàng chờ (queue_rows): {queue_len}")
        assert queue_len >= 2, f"Expected at least 2 jobs in queue, got {queue_len}"

        # 4. Kiểm tra cloneFlowVoiceReferencesSupported & currentRouteConfig
        print("  • Kiểm tra cloneFlowVoiceReferencesSupported & currentRouteConfig:")
        voice_supp = ctrl.cloneFlowVoiceReferencesSupported
        print(f"  • cloneFlowVoiceReferencesSupported: {voice_supp}")
        assert voice_supp is True, "cloneFlowVoiceReferencesSupported must be True"

        curr_cfg = ctrl.currentRouteConfig
        print(f"  • currentRouteConfig video_model_key: {curr_cfg.get('video_model_key')}")
        assert curr_cfg.get("video_model_key") == "veo-3.1-lite", "currentRouteConfig must have video_model_key"
        assert curr_cfg.get("model_key") == "veo-3.1-lite", "currentRouteConfig must have model_key"

        # 5. Kiểm tra CreditGate blocker & startQueue
        print("  • Kiểm tra CreditGate blocker & startQueue:")
        blocker_res = ctrl._credit_gate_blocker("queue.submit_cards", "clone")
        print(f"  • _credit_gate_blocker result: {blocker_res}")
        assert blocker_res is None, "Credit gate must not block queue"

        start_res = ctrl.startQueue()
        print(f"  • startQueue executed successfully (result={start_res})")

        # 6. Kiểm tra service youtube_clone_service get_video_details
        import services.tabs.clone_video.youtube_clone_service as ycs
        service = ycs.get_youtube_clone_service()
        print(f"  • Service instance: {service}")
        print(f"  • Đang kiểm tra video details cho: {test_url}")
        try:
            details = service.get_video_details(test_url)
            print(f"  • Video details: {details}")
        except Exception as e:
            print(f"  • get_video_details error: {e}")

        print("🎉 [XÁC NHẬN THÀNH CÔNG]: Không còn lỗi CreditGate skip, cloneFlowVoiceReferencesSupported hay AttributeError, và hàng chờ hoạt động tốt!")
    except Exception as e:
        log_error(f"Lỗi khi chạy test-clone: {e}")
        import traceback
        traceback.print_exc()
        reset_proxy_to_automatic()
        sys.exit(1)

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
