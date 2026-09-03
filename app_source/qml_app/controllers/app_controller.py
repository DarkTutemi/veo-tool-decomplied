"""
Decompiled / Reconstructed Module: qml_app.controllers.app_controller

Docstring:
Application shell controller for QML.
"""

from __future__ import annotations
import sys, os, typing
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
_APP_SHELL_KEY = 'app_shell'
_LAST_ROUTE_KEY = 'last_route'
_VALID_ROUTES = {'automation', 'clone', 'extend', 'affiliate', 'transcript', 'timemachine', 'home', 'voice', 'master', 'normal', 'batch', 'history', 'settings', 'research'}
_ROUTE_FEATURE = {'master': 'master_panel', 'clone': 'clone_panel', 'transcript': 'transcript_panel', 'research': 'deep_research', 'normal': 'normal_panel', 'extend': 'extend_panel', 'timemachine': 'time_machine', 'ba... [truncated]

# --- Class: AppController ---
class AppController(QObject):
    """
    Small UI-facing shell state.
    
        Business state should come from application services or internal APIs, not
        from legacy PyQt Widgets classes.
    """
    staticMetaObject = PySide6.QtCore.QMetaObject("AppController" inherits "QObject":
Properties:
  #1 "route", QString [designable], notify=ro...

    routeChanged = Signal()
    backendStatusChanged = Signal()
    bootstrapChanged = Signal()
    darkModeChanged = Signal()
    featureStatesChanged = Signal()
    routeBlockedNotice = Signal()
    _deviceReady = Signal()
    _licenseVerifyProgress = Signal()
    _licenseVerifyFinished = Signal()
    _licenseStateRefreshFinished = Signal()
    _runtimePacksFinished = Signal()
    _update_stage_signal = Signal()
    def __init__(self, initial_route: 'str' = 'master') -> 'None':
        pass

    def route(*args, **kwargs):
        pass

    def perfLogging(*args, **kwargs):
        pass

    def backendStatus(*args, **kwargs):
        pass

    def bootstrapVisible(*args, **kwargs):
        pass

    def bootstrapTitle(*args, **kwargs):
        pass

    def bootstrapMessage(*args, **kwargs):
        pass

    def bootstrapDetail(*args, **kwargs):
        pass

    def bootstrapProgress(*args, **kwargs):
        pass

    def statusTitle(*args, **kwargs):
        pass

    def statusSubtitle(*args, **kwargs):
        pass

    def deviceId(*args, **kwargs):
        pass

    def licenseKey(*args, **kwargs):
        pass

    def licenseHint(*args, **kwargs):
        pass

    def licenseBusy(*args, **kwargs):
        pass

    def licenseCheckPending(*args, **kwargs):
        pass

    def licenseVerified(*args, **kwargs):
        pass

    def featureTabState(self, route: 'str') -> 'dict':
        # [PyArmor BCC constants]: '_ROUTE_FEATURE', 'get', 'str', '', 'strip', 'enabled', True, 'badge', 'message', '_manager_feature_gate', '_feature_gate_empty', 'resolve_feature_ui', 'bool', 'runtime_pack_readiness', 'ready'
        pass

    def notifyFeatureEntitlementsUpdated(self) -> 'None':
        pass

    @staticmethod
    def _manager_feature_gate():
        # [PyArmor BCC constants]: 'get_license_manager', 'getattr', 'feature_gate', 'callable', 'is_empty', 'bool', 'is_configured', 'hasattr', 'configure_from_cache', 'Exception'
        pass

    @staticmethod
    def _feature_gate_empty(gate: 'object') -> 'bool':
        # [PyArmor BCC constants]: 'getattr', 'is_empty', 'callable', 'bool', False, 'Exception'
        pass

    def bootstrapError(*args, **kwargs):
        pass

    def showUpdateAction(*args, **kwargs):
        pass

    def progressLog(*args, **kwargs):
        pass

    def bootstrapStages(*args, **kwargs):
        pass

    def systemInfo(*args, **kwargs):
        pass

    def appVersion(*args, **kwargs):
        pass

    def _resolve_initial_route(self, initial_route: 'str') -> 'str':
        # [PyArmor BCC constants]: 'str', '', 'strip', 'home', '_VALID_ROUTES', '_settings', 'get_setting', '_APP_SHELL_KEY', '_LAST_ROUTE_KEY', 'Exception'
        pass

    def setRoute(self, route: 'str') -> 'None':
        # [PyArmor BCC constants]: 'time', 'perf_counter', '_route', '_perf_logging', 'print', '[PERF][AppRoute] same route=', ' ignored', 'get_forensic_logger', 'record_action', 'route_change', 'from', 'to', 'Exception', 'featureTabState', 'get'
        pass

    def liveAccountCount(self) -> 'int':
        pass

    def darkMode(*args, **kwargs):
        pass

    def setDarkMode(self, value: 'bool') -> 'None':
        # [PyArmor BCC constants]: '_settings', 'set_setting', '_APP_SHELL_KEY', 'dark_mode', 'bool', 'Exception', 'darkModeChanged', 'emit'
        pass

    def refreshBackendStatus(self) -> 'None':
        # [PyArmor BCC constants]: 'local', '_backend_status', 'backendStatusChanged', 'emit'
        pass

    def startBootstrap(self) -> 'None':
        # [PyArmor BCC constants]: 'time', 'monotonic', '_bootstrap_started_at', False, '_bootstrap_finish_deferred', True, '_bootstrap_visible', '_license_verified', '_set_stage', 'license', 'ok', '_license_stage_detail', '_license_key', 'pending', 'Cached key ready'
        pass

    def setLicenseInfo(self, info: 'object') -> 'None':
        # [PyArmor BCC constants]: 'isinstance', 'dict', '_normalize_license_info', '_license_info', 'str', 'get', 'license_key', '', 'strip', '_license_key', 'device_id', '_device_id', False, '_license_verified', '_license_denied'
        pass

    def setLicenseKey(self, key: 'str') -> 'None':
        # [PyArmor BCC constants]: '_license_verified', '_license_busy', '_license_check_pending', 'str', '', 'strip', '_license_key', 'len', 10, 'Ready', 'Enter your license key', '_license_hint', '_set_stage', 'license', 'pending'
        pass

    def verifyLicense(self) -> 'None':
        # [PyArmor BCC constants]: '_license_busy', '_license_verified', '_license_key', 'strip', 'len', 10, False, '_license_check_pending', 'Enter a valid license key first.', '_bootstrap_error', 'License key is too short', '_license_hint', 'bootstrapChanged', 'emit', True
        pass

    def clearLicense(self) -> 'None':
        # [PyArmor BCC constants]: 'get_json_license_cache_manager', 'clear_license_cache', 'Exception', 1, '_verify_request_id', True, '_ignore_verify_results', '_license_verify_timeout_timer', 'stop', 'idle', '_license_verify_phase', '', '_license_key', '_license_info', False
        pass

    def refreshLicenseState(self) -> 'None':
        # [PyArmor BCC constants]: '_license_state_refresh_running', '_license_busy', '_license_check_pending', '_bootstrap_finalized', '_license_verified', 'time', 'monotonic', '_license_refresh_last_at', 0, '_license_refresh_min_gap_s', 'str', '_license_key', '', 'strip', 'len'
        pass

    def _ensure_license_refresh_timer(self) -> 'None':
        # [PyArmor BCC constants]: '_license_refresh_timer', 'QTimer', 'setInterval', 'int', '_license_refresh_interval_ms', 'timeout', 'connect', 'refreshLicenseState', 'start'
        pass

    def _arm_app_focus_license_refresh(self) -> 'None':
        # [PyArmor BCC constants]: '_app_focus_refresh_armed', 'QGuiApplication', 'instance', 'hasattr', 'applicationStateChanged', 'Qt', 'getattr', 'ApplicationActive', 'refreshLicenseState', 'ApplicationState', 'Exception', 'connect', True
        pass

    def _run_license_state_refresh(self, key: 'str') -> 'None':
        # [PyArmor BCC constants]: 'get_server_url', 'get_tool_code', 'get_license_manager', '_resolve_device_id', 'configure', 'license_key', 'device_id', 'tool_code', 'server_url', 'initial_tier', '_license_info', 'get', 'tier', 'license_type', 'license_info'
        pass

    def copyDeviceId(self) -> 'None':
        # [PyArmor BCC constants]: 'QGuiApplication', 'clipboard', '_append_log', 'Clipboard unavailable', 'bootstrapChanged', 'emit', 'setText', '_device_id', 'Device ID copied'
        pass

    def exitApplication(self) -> 'None':
        pass

    def runBootstrapUpdateAction(self) -> 'None':
        # [PyArmor BCC constants]: '_append_log', 'Update action is not available from QML bootstrap yet', 'Update action is not available from this startup screen.', '_bootstrap_error', 'bootstrapChanged', 'emit'
        pass

    def setBootstrapState(self, message: 'str', detail: 'str' = '', progress: 'int' = 0) -> 'None':
        # [PyArmor BCC constants]: True, '_bootstrap_visible', 'str', '', '_bootstrap_message', '_bootstrap_detail', 'max', 0, 'min', 100, 'int', '_bootstrap_progress', '_status_title', '_status_subtitle', 'lower'
        pass

    def finishBootstrap(self) -> 'None':
        # [PyArmor BCC constants]: '_bootstrap_finalized', '_license_verified', False, '_bootstrap_finish_deferred', True, '_bootstrap_visible', '_license_denied', 'License expired or suspended', '_status_title', '_bootstrap_error', 'The server rejected this license. Renew it to continue.', '_status_subtitle', '_set_stage', 'license', 'error'
        pass

    def _read_min_bootstrap_visible_ms(self) -> 'int':
        # [PyArmor BCC constants]: 'os', 'environ', 'get', 'VEOFLOW_QML_BOOTSTRAP_MIN_MS', '4500', 'int', 4500, 'TypeError', 'ValueError', 'max', 0, 'min', 10000
        pass

    def _finalize_pending_stages(self) -> 'None':
        # [PyArmor BCC constants]: '_stages', 'get', 'key', 'state', 'ok', 'detail', 'Ready', 100, 'progress'
        pass

    def _run_real_bootstrap_checks(self) -> 'None':
        # [PyArmor BCC constants]: 'threading', 'Thread', 'target', '_real_checks_bg', 'daemon', True, 'name', 'QmlBootstrapChecks', 'start'
        pass

    def _real_checks_bg(self) -> 'None':
        # [PyArmor BCC constants]: 'phase', 'str', 'pct', 'int', 'msg', 'str', 'return', 'None'
        pass

    def _on_stage_update_from_thread(self, key: 'str', state: 'str', detail: 'str', progress: 'int') -> 'None':
        pass

    def _load_app_version(self) -> 'str':
        # [PyArmor BCC constants]: 'VEO3Config', 'str', 'getattr', 'TOOL_VERSION', '', 'Exception'
        pass

    def _stage(self, key: 'str', name: 'str', desc: 'str', state: 'str' = 'pending', detail: 'str' = '', progress: 'int' = -1) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'key', 'name', 'desc', 'state', 'detail', 'progress'
        pass

    def _set_stage(self, key: 'str', state: 'str', detail: 'str' = '', progress: 'int' = -1) -> 'None':
        # [PyArmor BCC constants]: '_stages', 'get', 'key', 'state', 'detail', 'int', 'progress'
        pass

    def _append_log(self, message: 'str') -> 'None':
        # [PyArmor BCC constants]: 'str', '', 'strip', 'datetime', 'now', 'strftime', '%H:%M:%S', '_progress_log', 'splitlines', 'append', '[', '] ', '\n', 'join', 80
        pass

    def _load_cached_license_key(self) -> 'None':
        # [PyArmor BCC constants]: 'get_json_license_cache_manager', 'get_license_data', 'Exception', 'isinstance', 'dict', '_normalize_license_info', '_license_info', 'str', 'get', 'license_key', '', 'strip', '_license_key', '_license_stage_detail', 'Cached - '
        pass

    def _load_device_identity(self) -> 'None':
        pass

    def _resolve_device_id(self) -> 'str':
        # [PyArmor BCC constants]: '_device_id', 'strip', 'lower', 'detecting...', 'get_device_identity', 'debug', False, 'str', 'get', 'device_id', '', 'Exception', 'platform', 'node', '|'
        pass

    def _on_device_ready(self, device_id: 'str') -> 'None':
        # [PyArmor BCC constants]: 'str', '_device_id', 'bootstrapChanged', 'emit'
        pass

    def _ensure_stats_reporter(self, license_key: 'str') -> 'None':
        # [PyArmor BCC constants]: 'get_server_url', 'get_stats_reporter', 'configure', 'server_url', 'license_key', 'enabled', True, 'start', '_append_log', 'Stats reporter not started: ', 'Exception'
        pass

    def _run_license_verify(self, key: 'str', request_id: 'int') -> 'None':
        # [PyArmor BCC constants]: '_licenseVerifyProgress', 'emit', 'setup', 'Configuring license manager', 30, 'get_server_url', 'get_tool_code', 'get_license_manager', '_resolve_device_id', '_deviceReady', 'configure', 'license_key', 'device_id', 'tool_code', 'server_url'
        pass

    def _on_license_verify_progress(self, request_id: 'int', phase: 'str', detail: 'str', progress: 'int') -> 'None':
        # [PyArmor BCC constants]: '_verify_request_id', '_ignore_verify_results', '_license_busy', 'str', '', 'strip', 'lower', '_license_verify_phase', 'license_request', 'setup', '_license_verify_timeout_timer', 'start', '_license_verify_timeout_ms', 'license_response', 'stop'
        pass

    def _on_license_verify_timeout(self, request_id: 'int | None' = None) -> 'None':
        # [PyArmor BCC constants]: '_verify_request_id', '_license_busy', '_license_verify_timeout_timer', 'stop', True, '_ignore_verify_results', False, '_license_check_pending', '_license_verified', 'timed_out', '_license_verify_phase', 'License server did not respond in time. Check network/server health and try again.', '_bootstrap_error', 'License verification timed out', 'len'
        pass

    def _on_license_verify_finished(self, request_id: 'int', success: 'bool', message: 'str', payload: 'object') -> 'None':
        # [PyArmor BCC constants]: '_verify_request_id', '_ignore_verify_results', '_schedule_runtime_pack_invalidation', '_license_verify_timeout_timer', 'stop', 'done', '_license_verify_phase', False, '_license_busy', '_license_check_pending', '_license_verified', 'str', 'License verification failed', '_bootstrap_error', 'Verification failed'
        pass

    def _on_runtime_packs_finished(self, payload: 'object') -> 'None':
        # [PyArmor BCC constants]: '_license_verified', 'isinstance', 'dict', 'get', 'states', 'list', '_license_info', 'runtime_pack_states', 'int', 'unavailable_count', 0, 'restart_count', '_append_log', 'Licensed features prepared; ', ' unavailable'
        pass

    def _on_license_state_refresh_finished(self, success: 'bool', payload: 'object') -> 'None':
        # [PyArmor BCC constants]: 'expire', 'suspend', 'revok', 'invalid'
        pass

    def _license_stage_detail(self) -> 'str':
        # [PyArmor BCC constants]: '_license_info', 'str', 'get', 'license_type', 'tier', 'feature_tier', 'Licensed', 'strip', 'status', '', ' / '
        pass

    def _normalize_license_info(self, info: 'object') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'isinstance', 'dict', 'get', 'data', 'str', 'license_type', 'tier', 'feature_tier', '', 'strip', 'status', 'license_status', 'expires_at', 'expires'
        pass


# --- Top-Level Functions ---
def _invalidate_runtime_packs_after_verify_timeout() -> 'None':
    # [PyArmor BCC constants]: 'mark_runtime_pack_generation', 'reserve_runtime_pack_generation', 'failed', 'deauthorize_and_clear_runtime_packs', 'generation', 'state', 'Exception'
    pass

def _schedule_runtime_pack_invalidation() -> 'None':
    # [PyArmor BCC constants]: 'threading', 'Thread', 'target', '_invalidate_runtime_packs_after_verify_timeout', 'daemon', True, 'name', 'LicenseVerifyTimeoutCleanup', 'start'
    pass
