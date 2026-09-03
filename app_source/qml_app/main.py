"""
Decompiled / Reconstructed Module: qml_app.main

Docstring:
Primary QML desktop entrypoint.

Do not import old ui/tabs or ui/dialogs modules here; QML controllers should
call application services.
"""

from __future__ import annotations
import sys, os, typing
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
PROJECT_ROOT = WindowsPath('H:/veo-tool/unpack-veotool/VEOFLOWPROMAX.exe_extracted/PYZ.pyz_extracted')
QML_ROOT = WindowsPath('H:/veo-tool/unpack-veotool/VEOFLOWPROMAX.exe_extracted/PYZ.pyz_extracted/qml')
APP_QML = WindowsPath('H:/veo-tool/unpack-veotool/VEOFLOWPROMAX.exe_extracted/PYZ.pyz_extracted/qml/App.qml')
PreExecHook = collections.abc.Callable[[PySide6.QtGui.QGuiApplication, PySide6.QtQml.QQmlApplicationEngine, dict[str, object]], None]

# --- Class: AccountSettingsController ---
class AccountSettingsController(QObject):
    """Thin account/proxy/API-key adapter for QML."""
    _MAX_BROWSER_LOGIN_POLLS = 150
    _BROWSER_LOGIN_TIMEOUT_SECONDS = 240.0
    _POOL_SWEEP_INTERVAL_MS = 21600000
    _POOL_SWEEP_STARTUP_DELAY_MS = 180000
    staticMetaObject = PySide6.QtCore.QMetaObject("AccountSettingsController" inherits "QObject":
Properties:
  #1 "accounts", QVariantList [de...

    accountsChanged = Signal()
    accountModeChanged = Signal()
    proxiesChanged = Signal()
    apiKeysChanged = Signal()
    apiModeChanged = Signal()
    allowedModesChanged = Signal()
    providerTestChanged = Signal()
    _providerTestPayload = Signal()
    proxyCheckChanged = Signal()
    resourcesChanged = Signal()
    resourceHealthChanged = Signal()
    statsChanged = Signal()
    statusMessageChanged = Signal()
    nativeActionChanged = Signal()
    pendingDialogChanged = Signal()
    browserLoginChanged = Signal()
    accountCheckChanged = Signal()
    localTtsInstallChanged = Signal()
    browserRuntimeChanged = Signal()
    runtimePoolChanged = Signal()
    settingsActionFinished = Signal()
    openPathRequested = Signal()
    _proxyCheckPayload = Signal()
    _accountCheckPayload = Signal()
    _browserLoginPayload = Signal()
    _browserLoginPollPayload = Signal()
    _localTtsInstallPayload = Signal()
    _apiKeysPayload = Signal()
    _resourcesPayload = Signal()
    _resourceHealthPayload = Signal()
    _accountsPayload = Signal()
    _settingsActionPayload = Signal()
    _browserRuntimePayload = Signal()
    _poolSweepPayload = Signal()
    def __init__(self, account_service: 'Any | None' = None, api_keys_service: 'Any | None' = None, browser_manager: 'Any | None' = None, account_manager: 'Any | None' = None, local_tts_manager: 'Any | None' = None, create_project_for_account: 'Callable[..., Any] | None' = None, local_tts_install_dir: 'Callable[[], Any] | None' = None) -> 'None':
        # [PyArmor BCC constants]: 'running', 'current', 'total', 'live', 'dead', 'rows', 'message'
        pass

    def _on_account_store_changed(self, *args) -> 'None':
        # [PyArmor BCC constants]: '_account_refresh_timer', 'start', 'refreshAccounts', 'Exception'
        pass

    def accounts(*args, **kwargs):
        pass

    def runtimePool(*args, **kwargs):
        pass

    def accountsReadiness(*args, **kwargs):
        pass

    def proxies(*args, **kwargs):
        pass

    def proxyCheck(*args, **kwargs):
        pass

    def apiKeys(*args, **kwargs):
        pass

    def apiMode(*args, **kwargs):
        pass

    def allowedModes(*args, **kwargs):
        pass

    def isModeAllowed(self, mode: 'str') -> 'bool':
        # [PyArmor BCC constants]: 'str', '', 'strip', 'lower', 'bool', '_allowed_modes', 'get', True
        pass

    def resources(*args, **kwargs):
        pass

    def resourceHealthModel(*args, **kwargs):
        pass

    def resourceFeaturedModel(*args, **kwargs):
        pass

    def resourceExtraModel(*args, **kwargs):
        pass

    def resourceHealth(*args, **kwargs):
        pass

    def browserLogin(*args, **kwargs):
        pass

    def accountCheck(*args, **kwargs):
        pass

    def localTtsInstall(*args, **kwargs):
        pass

    def browserRuntime(*args, **kwargs):
        pass

    def stats(*args, **kwargs):
        pass

    def statusMessage(*args, **kwargs):
        pass

    def nativeAction(*args, **kwargs):
        pass

    def pendingDialog(*args, **kwargs):
        pass

    def refresh(self) -> 'None':
        # [PyArmor BCC constants]: 'refreshAccounts', 'refreshProxies', 'refreshResources', 'checkAllResources', '_rebuild_stats'
        pass

    def refreshAccounts(self) -> 'None':
        # [PyArmor BCC constants]: '_accounts_loading', True, 'ok', 'accounts', 'list', '_account_service', 'list_accounts', 'include_inactive', 'message', False, 'Account refresh failed: ', 'type', '__name__', 'Exception', '_accountsPayload'
        pass

    def _apply_accounts_payload(self, payload: 'dict[str, Any]') -> 'None':
        # [PyArmor BCC constants]: False, '_accounts_loading', 'get', 'ok', '_accounts', '_set_status', 'str', 'message', 'Account refresh failed', 'account_mode', 'resolve_active_mode', 'MODE_ULTRA', 'Exception', 'accounts', '_normalize_account'
        pass

    def refreshProxies(self) -> 'None':
        # [PyArmor BCC constants]: '_account_service', 'list_proxies', '_normalize_proxy', '_proxies', '_set_status', 'Loaded ', 'len', ' proxy item(s)', 'Proxy refresh failed: ', 'type', '__name__', 'Exception', 'proxiesChanged', 'emit', '_rebuild_stats'
        pass

    def refreshApiKeys(self) -> 'None':
        # [PyArmor BCC constants]: '_api_keys_loading', True, '_set_status', 'Loading API keys...', '_api_keys_service', 'list_keys', 'ok', 'message', False, 'API key refresh failed: ', 'type', '__name__', 'Exception', '_apiKeysPayload', 'emit'
        pass

    def _apply_api_keys_payload(self, payload: 'dict[str, Any]') -> 'None':
        # [PyArmor BCC constants]: False, '_api_keys_loading', 'get', 'ok', '_api_keys', '_set_status', 'str', 'message', 'API key refresh failed', 'keys', '_normalize_api_key', '_apply_allowed_modes', 'allowed_ai_modes', '_set_api_mode', 'api_mode'
        pass

    def startGeminiApiConfig(self) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_api_keys_service', 'start_gemini_config', 'ok', 'error', 'message', False, 'type', '__name__', 'str', 'Client not configured', 'Exception', 'get', '', '_set_status'
        pass

    def requestDialog(self, dialog_id: 'str') -> 'None':
        # [PyArmor BCC constants]: 'str', '', 'strip', '_pending_dialog', 'pendingDialogChanged', 'emit'
        pass

    def consumePendingDialog(self, dialog_id: 'str') -> 'bool':
        # [PyArmor BCC constants]: 'str', '', 'strip', '_pending_dialog', False, 'pendingDialogChanged', 'emit', True
        pass

    def refreshResources(self) -> 'None':
        # [PyArmor BCC constants]: '_resources_loading', True, '_load_resources', 'ok', 'resources', 'message', False, 'Resource refresh failed: ', 'type', '__name__', 'Exception', '_resourcesPayload', 'emit', 'threading', 'Thread'
        pass

    def _apply_resources_payload(self, payload: 'dict[str, Any]') -> 'None':
        # [PyArmor BCC constants]: False, '_resources_loading', 'get', 'resources', 'isinstance', 'dict', '_resources', 'ok', 'databaseMode', 'str', 'message', 'Resource refresh failed', 'resourcesChanged', 'emit'
        pass

    def checkAllResources(self) -> 'None':
        # [PyArmor BCC constants]: '_resource_health_inflight', True, 'checking', 'repairingId', 'progress', 'phase', 'overall', 'message', '_resource_health', '', 0, 'Đang kiểm tra tài nguyên...', 'resourceHealthChanged', 'emit', '_resource_health_model'
        pass

    def _apply_resource_health_payload(self, payload: 'dict[str, Any]') -> 'None':
        # [PyArmor BCC constants]: 'get', 'rows', 'isinstance', 'list', '_publish_health_rows', 'mergeRow', 'dict', 'id', '_merge_health_row', '_resource_health_model', 'summary', '_resource_health', 'checking', 'overall', 'final'
        pass

    def _publish_health_rows(self, rows: 'list[dict[str, Any]]') -> 'None':
        # [PyArmor BCC constants]: 'dict', '_resource_health_model', 'setRows', '_resource_featured_model', 'get', 'featured', '_resource_extra_model'
        pass

    def repairResource(self, resource_id: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'str', '', 'strip', 'ok', False, 'message', 'Missing resource id', 'storage', 'requestOpenResourcesPath', 'resource.', '.repair', '_resource_health_inflight', '_settings_actions_running', 'pending', 'action'
        pass

    def openResourceFolder(self, resource_id: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'str', '', 'strip', 'storage', 'requestOpenResourcesPath', '_resource_health_model', 'rows', 'get', 'path', 'id', 'Path', 'suffix', 'parent', '_apply_open_path_action', 'ok'
        pass

    def refreshBrowserRuntime(self) -> 'None':
        # [PyArmor BCC constants]: '_browser_runtime_loading', True, 'message', '_browser_runtime', 'Checking browser runtime...', 'browserRuntimeChanged', 'emit', 'browser_runtime_snapshot', 'deep', False, 'ok', 'snapshot', 'Browser status failed: ', 'type', '__name__'
        pass

    def _apply_browser_runtime_payload(self, payload: 'dict[str, Any]') -> 'None':
        # [PyArmor BCC constants]: 'get', 'snapshot', 'isinstance', 'dict', 'progress', 'phase', 'message', '_browser_runtime', 'int', 0, 'str', 'ready', 'integrity', 'ok', 'Browser ready'
        pass

    def repairBrowser(self) -> 'dict[str, Any]':
        pass

    def _pending_action_payload(self, action: 'str', message: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'ok', 'pending', 'accepted', 'action', 'message', True
        pass

    def _interactive_browser_action_running(self) -> 'bool':
        # [PyArmor BCC constants]: 'account.open_browser', 'account.add_account', 'account.relogin', 'bool', '_browser_login', 'get', 'active', 'intersection', '_settings_actions_running'
        pass

    def _browser_action_busy_payload(self, action: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'ok', 'pending', 'action', 'error', 'message', False, True, 'browser_action_already_active', 'Another account browser action is already active', '_set_status'
        pass

    def _start_settings_action(self, *, action: 'str', message: 'str', work: 'Callable[[], dict[str, Any]]', refresh_accounts: 'bool' = False, refresh_proxies: 'bool' = False, refresh_api_keys: 'bool' = False, refresh_resources: 'bool' = False, apply_native: 'bool' = False) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'str', 'settings.action', 'strip', '_settings_actions_running', 'ok', 'pending', 'action', 'error', 'message', False, True, 'action_already_running', ' is already running', '_set_status', 'add'
        pass

    def _apply_settings_action_payload(self, payload: 'dict[str, Any]') -> 'None':
        # [PyArmor BCC constants]: 'str', 'get', 'action', '', '_settings_actions_running', 'discard', 'result', 'dict', 'isinstance', 'setdefault', 'bool', 'applyNative', '_apply_native_action', '_set_status', 'message'
        pass

    def toggleAccount(self, email: 'str', enabled: 'bool') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'action', 'message', 'work', 'refresh_accounts'
        pass

    def accountMode(self) -> 'dict[str, Any]':
        """
        Mode hiện tại cho nút chọn UI: effective + đếm ULTRA/PRO.
        
                Đếm bằng CÙNG classifier với switch (`account_mode.account_matches_mode`) để
                nút chọn không lệch với badge — mỗi nút chỉ disable khi hệ thống KHÔNG có
                account thuộc loại đó (radio thuần, không khoá theo ưu tiên).
        """
        # [PyArmor BCC constants]: 'effective', 'ultraCount', 'proCount', 'ultraMax', 'hasLiveUltra', 'needsRelogin', 'reloginEmail', 'reloginAccountId'
        pass

    def setAccountMode(self, mode: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'account_mode', 'str', '', 'strip', 'lower', 'get_account_manager', 'get_all_accounts_dict', 'Exception', 'classify_set_mode', 'allowed', 'reason', 'bad_mode', 'no_ultra_account', 'no_pro_account', 'Mode không hợp lệ: '
        pass

    @staticmethod
    def _read_runtime_pool_snapshot() -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'get_runtime_pool_policy', 'snapshot', 'enabled', False, 'maxActive', 2, 'active', 'drainedCount', 0, 'lastEvent', 'history', 'Exception'
        pass

    def _refresh_runtime_pool_state(self) -> 'None':
        # [PyArmor BCC constants]: '_read_runtime_pool_snapshot', '_runtime_pool', 'runtimePoolChanged', 'emit'
        pass

    def _pool_state_for_email(self, email: 'str') -> 'str':
        # [PyArmor BCC constants]: 'get_runtime_pool_policy', 'pool_state_for', '', 'Exception'
        pass

    def setRuntimePoolEnabled(self, on: 'bool') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'get_runtime_pool_policy', 'set_enabled', 'bool', 'ok', 'action', 'enabled', 'message', True, 'pool.set_enabled', 'Runtime pool ', 'BẬT — chỉ active set nhận job.', 'TẮT — mọi account Live đều nhận job.', '_start_settings_action', 'Updating runtime pool...', 'work'
        pass

    def setRuntimePoolSize(self, size: 'int') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'get_runtime_pool_policy', 'set_max_active', 'ok', 'action', 'maxActive', 'message', True, 'pool.set_size', 'max_active', 'Runtime pool → tối đa ', ' account chạy cùng lúc.', '_start_settings_action', 'Updating runtime pool size...', 'work', 'refresh_accounts'
        pass

    def startPoolSweep(self) -> 'None':
        # [PyArmor BCC constants]: 'get_runtime_pool_policy', 'drain_candidates', 'Exception', 'CAPABILITY_READMIT_SECONDS', 0, '_account_service', 'check_account', 'email', 1, 'int', 'get', 'credits', 'get_account', 'bool', 'enabled'
        pass

    def _apply_pool_sweep_payload(self, payload: 'dict[str, Any]') -> 'None':
        pass

    def updateAccount(self, account_id: 'str', original_email: 'str', name: 'str', email: 'str', status: 'str', credits: 'str', tier: 'str', account_type: 'str', cookie_type: 'str', browser_type: 'str', tag: 'str', totp_secret: 'str' = '') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_account_service', 'update_account', 'account_id', 'email', 'updates', 'name', 'status', 'credits', 'tier', 'account_type', 'cookie_type', 'browser_type', 'tag', 'totp_secret', 'dict'
        pass

    def deleteAccount(self, account_id: 'str', email: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_account_service', 'delete_account', 'account_id', 'email', 'dict', 'setdefault', 'ok', False, 'message', 'Account delete completed', 'get', '_reload_dispatcher_accounts', '_start_settings_action', 'action', 'account.delete'
        pass

    def checkAccounts(self) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_account_check', 'get', 'running', 'ok', False, 'action', 'account.check_all', 'error', 'account_check_already_running', 'message', 'Account health check already running', '_set_status', '_accounts', 'str', 'email'
        pass

    def requestAddAccount(self) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_interactive_browser_action_running', '_browser_action_busy_payload', 'account.add_account', 'account-', 'uuid', 'uuid4', 'hex', 12, '_browser_manager', 'getattr', 'start_login_browser', 'callable', 'start_browser', 'bool', 'headless'
        pass

    def requestOpenBrowser(self, account_id: 'str', email: 'str') -> 'dict[str, Any]':
        pass

    def requestRelogin(self, account_id: 'str', email: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_interactive_browser_action_running', '_browser_action_busy_payload', 'account.relogin', '_request_existing_account_browser', 'login_flow', True
        pass

    def _request_existing_account_browser(self, account_id: 'str', email: 'str', *, login_flow: 'bool') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'account.relogin', 'account.open_browser', '_interactive_browser_action_running', '_browser_action_busy_payload', 'str', '', '_account_service', 'open_login_browser', 'open_browser', 'account_id', 'email', 'ok', 'action', 'error', 'message'
        pass

    def requestRefreshCookies(self, account_id: 'str', email: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'str', '', '_account_service', 'check_account', 'account_id', 'email', 'ok', 'action', 'error', 'message', False, 'account.refresh_cookies', 'type', '__name__', 'Account refresh failed: '
        pass

    def _browser_login_expired(self, flow: 'dict[str, Any] | None' = None, *, poll_count: 'int | None' = None) -> 'bool':
        # [PyArmor BCC constants]: 'isinstance', 'dict', '_browser_login', 'float', 'get', 'deadlineAt', 0.0, 'TypeError', 'ValueError', 'time', 'monotonic', 'int', 'pollCount', 0, '_MAX_BROWSER_LOGIN_POLLS'
        pass

    def _close_labs_login_transaction(self, profile_name: 'str') -> 'None':
        # [PyArmor BCC constants]: 'str', '', 'strip', '_browser_manager', False, 'stop_browser', 'RuntimeError', 'login_browser_close_failed', 'getattr', 'end_login_transaction', 'callable'
        pass

    def _delete_uncommitted_labs_profile(self, profile_name: 'str') -> 'None':
        # [PyArmor BCC constants]: 'str', '', 'strip', '_browser_manager', 'getattr', 'delete_profile', 'callable', '_close_labs_login_transaction', 'bool', 'chrome', 'RuntimeError', 'uncommitted_login_profile_delete_failed', 'end_login_transaction'
        pass

    def _browser_login_timeout_result(self, flow: 'dict[str, Any]', *, poll_count: 'int | None' = None) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'dict', 'str', 'get', 'profileName', '', '_close_labs_login_transaction', 'Exception', 'int', 'pollCount', 0, 'Google login timed out. Please try again.', 'ok', 'action', 'error', 'message'
        pass

    def pollBrowserLogin(self) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_browser_login', 'get', 'active', 'ok', True, 'action', 'account.browser_login_poll', 'idle', 'pending', False, 'message', 'No browser login flow is active', 'stage', 'closing_login_browser', 'commitComplete'
        pass

    def startLocalTtsInstall(self) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'ok', False, 'action', 'resource.local_tts.install', 'error', 'local_tts_removed', 'message', 'Local TTS has been removed. Use Gemini TTS.', '_set_status'
        pass

    def uninstallLocalTts(self) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'ok', False, 'action', 'resource.local_tts.uninstall', 'error', 'local_tts_removed', 'message', 'Local TTS has been removed.', '_set_status'
        pass

    def requestMoveDatabase(self) -> 'dict[str, Any]':
        pass

    def moveDatabaseTo(self, path: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_account_service', 'move_database', 'ok', 'action', 'error', 'message', 'path', False, 'resource.move_database', 'type', '__name__', 'Database move failed: ', 'str', '', 'Exception'
        pass

    def requestMoveLocalTts(self) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'ok', False, 'action', 'resource.move_local_tts', 'error', 'local_tts_removed', 'message', 'Local TTS has been removed.'
        pass

    def moveLocalTtsTo(self, path: 'str') -> 'dict[str, Any]':
        pass

    def updateResourceInstallDir(self, path: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'ok', False, 'action', 'resource.update_install_dir', 'error', 'local_tts_removed', 'message', 'Local TTS path settings have been removed.'
        pass

    def setLocalTtsAutoStart(self, enabled: 'bool') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'ok', False, 'action', 'resource.local_tts.auto_start', 'error', 'local_tts_removed', 'message', 'Local TTS has been removed.'
        pass

    def requestBrowserProfileCleanup(self) -> 'dict[str, Any]':
        pass

    def runBrowserProfileCleanup(self) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_account_service', 'browser_profile_cleanup', '_start_settings_action', 'action', 'account.browser_profile_cleanup', 'message', 'Cleaning browser profiles...', 'work', 'refresh_accounts', True, 'apply_native'
        pass

    def requestOpenDatabasePath(self) -> 'dict[str, Any]':
        pass

    def requestOpenResourcesPath(self) -> 'dict[str, Any]':
        pass

    def requestOpenLocalTtsPath(self) -> 'dict[str, Any]':
        pass

    def markAccountActionBlocked(self, action: 'str') -> 'None':
        pass

    def addProxies(self, raw_text: 'str', rotate_url: 'str' = '') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'str', '', 'splitlines', 'strip', 'ok', False, 'message', 'No proxy input', 'count', 0, '_set_status', '_account_service', 'add_proxies', 'rotate_url', '_start_settings_action'
        pass

    def proxyChoices(self, email: 'str') -> 'list[dict[str, Any]]':
        # [PyArmor BCC constants]: '_account_service', 'proxy_choices', 'list', 'get', 'choices', 'Exception'
        pass

    def removeProxy(self, proxy_key: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'str', '', '_account_service', 'remove_proxy', '_start_settings_action', 'action', 'proxy.remove', 'message', 'Removing proxy...', 'work', 'refresh_accounts', True, 'refresh_proxies'
        pass

    def removeDeadProxies(self) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_account_service', 'remove_dead_proxies', 'dict', 'setdefault', 'ok', True, 'action', 'proxy.remove_dead', 'message', 'str', 'get', 'Removed dead proxy item(s)', '_start_settings_action', 'Removing dead proxies...', 'work'
        pass

    def checkProxies(self) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_proxy_check', 'get', 'running', 'ok', False, 'action', 'proxy_check.start', 'error', 'proxy_check_already_running', 'message', 'Proxy check already running', '_set_status', '_account_service', 'list_proxies', 'proxy_check_start_failed'
        pass

    def assignProxy(self, email: 'str', proxy_key: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'str', '', 'strip', '_account_service', 'assign_proxy', 'get', 'ok', '_resume_after_ip_block', '_start_settings_action', 'action', 'proxy.assign', 'message', 'Assigning proxy...', 'work', 'refresh_accounts'
        pass

    @staticmethod
    def _resume_after_ip_block() -> 'None':
        # [PyArmor BCC constants]: 'get_ip_block_state', 'force_resume', 'Exception', 'get_dispatcher', 'resume_after_ip_block'
        pass

    def setProxyRotateUrl(self, proxy_key: 'str', rotate_url: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_account_service', 'set_proxy_rotate_url', '_start_settings_action', 'action', 'proxy.set_rotate_url', 'message', 'Saving rotate URL...', 'work', 'refresh_proxies', True
        pass

    def rotateProxyIp(self, proxy_key: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_account_service', 'rotate_proxy_ip', '_start_settings_action', 'action', 'proxy.rotate_ip', 'message', 'Rotating proxy IP...', 'work', 'refresh_proxies', False
        pass

    def clearAccountProxies(self) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_account_service', 'clear_account_proxies', 'dict', 'setdefault', 'ok', True, 'action', 'account.clear_proxy', 'message', 'str', 'get', 'Cleared account proxy mappings', '_start_settings_action', 'Clearing account proxy mappings...', 'work'
        pass

    def addApiKey(self, provider: 'str', api_key: 'str', label: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_api_keys_service', 'add_key', '_start_settings_action', 'action', 'api_key.add', 'message', 'Saving API key...', 'work', 'refresh_api_keys', True
        pass

    def removeApiKey(self, key_id: 'int') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_api_keys_service', 'remove_key', 'int', '_start_settings_action', 'action', 'api_key.remove', 'message', 'Removing API key...', 'work', 'refresh_api_keys', True
        pass

    def setApiMode(self, mode: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_set_api_mode', '_api_mode', '_api_keys_service', 'update_mode', '_start_settings_action', 'action', 'api_key.mode', 'message', 'Updating API mode...', 'work', 'refresh_api_keys', True
        pass

    def providerTests(*args, **kwargs):
        pass

    def testProvider(self, mode: 'str') -> 'dict[str, Any]':
        """Small live probe (off GUI thread). mode = studio|server|personal."""
        # [PyArmor BCC constants]: 'running', 'ok', 'message', 'ms'
        pass

    def _run_provider_test(self, mode: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'studio', 'prewarm_aistudio', 'bool', 'ok', True, 'message', 'AI Studio runtime đã warm thật (không gửi nội dung thử)', False, 'AI Studio runtime không warm được — hãy đăng nhập lại profile AI', 'str', 160, 'Exception', 'server', 'get_ai_server_url', ''
        pass

    def _apply_provider_test_payload(self, payload: 'dict') -> 'None':
        # [PyArmor BCC constants]: 'str', 'get', 'mode', '', '_provider_tests', '_provider_test_inflight', 'discard', 'running', 'ok', 'message', 'ms', False, 'bool', 'int', 0
        pass

    def applyProviderMix(self, studio: 'bool', server: 'bool', personal: 'bool') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'get_json_settings_manager', 'bool', True, 'sum', 1, 'ok', False, 'error', 'exactly_one_provider_required', 'message', 'Chỉ được chọn một nguồn AI.', 'aistudio', 'server', 'personal', 'studio'
        pass

    def providerMix(self) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_read_api_mode', 'studio', 'server', 'personal', 'api_mode', 'aistudio', True, False, 'Exception'
        pass

    @staticmethod
    def _read_api_mode() -> 'str':
        # [PyArmor BCC constants]: 'get_json_settings_manager', 'str', 'get_setting', 'main', 'api_mode', '', 'strip', 'lower', 'aistudio', 'server', 'personal', 'set_setting', 'aistudio_web', True, 'Exception'
        pass

    @staticmethod
    def _read_allowed_modes() -> 'dict[str, bool]':
        # [PyArmor BCC constants]: True, 'get_json_settings_manager', 'str', 'get_setting', 'main', 'allowed_ai_modes', '', 'strip', 'loads', 'isinstance', 'dict', 'bool', 'Exception', 'any', 'values'
        pass

    def _apply_allowed_modes(self, value: 'Any') -> 'None':
        """
        Persist + apply the admin allow-list pushed from the gateway (verify /
                api-keys payload). Coerces the user's current mode away if it just got disabled.
                This is a RESTRICTION, not a preference override, so it may change api_mode even
                though normal server syncs are client-authoritative.
        """
        # [PyArmor BCC constants]: 'action', 'message', 'work', 'refresh_api_keys'
        pass

    @staticmethod
    def _read_aistudio_web() -> 'bool':
        # [PyArmor BCC constants]: 'get_json_settings_manager', 'bool', 'get_setting', 'main', 'aistudio_web', True, False, 'Exception'
        pass

    def markResourceActionBlocked(self, action: 'str') -> 'None':
        pass

    def reloadDispatcher(self) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_reload_dispatcher_accounts', 'ok', False, 'action', 'account.dispatcher.reload', 'message', 'Dispatcher is not running yet; accounts will load on first job.', 'count', True, 'Reloaded ', ' account(s) into dispatcher.', '_start_settings_action', 'Reloading dispatcher accounts...', 'work', 'Dispatcher chưa khởi động — sẽ tự nạp tài khoản khi job đầu chạy.'
        pass

    def restartAppAfterDbMove(self) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'ok', True, 'action', 'account.app.restart', 'message', 'App restart requested — relaunch manually if needed', '_set_status', 'execv', 'executable', 'argv', 'error', False, 'type', '__name__', 'str'
        pass

    def pollAccountRecoveryStatus(self, account_id: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'ok', 'account_id', 'status', 'alive', 'action', 'message'
        pass

    def onAccountDeleteFinished(self, account_id: 'str', success: 'bool', message: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'ok', 'account_id', 'action', 'message', 'bool', 'account.delete.finished', 'str', 'Account deleted', 'Delete failed', 'refresh', '_set_status'
        pass

    def onAccountCheckFinished(self, account_id: 'str', success: 'bool', status: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'ok', 'account_id', 'check_success', 'status', 'action', 'message', True, 'bool', 'str', '', 'account.check.finished', 'Account ', ' check: ', 'refresh', '_set_status'
        pass

    def onSilentCheckFinished(self, account_id: 'str', healthy: 'bool', details: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'ok', 'account_id', 'healthy', 'details', 'action', 'message', True, 'bool', 'str', '', 'account.silent_check.finished', 'Silent check ', ': ', 'unhealthy', '_set_status'
        pass

    def proactiveCreditFetch(self) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_accounts', 'str', 'get', 'email', '', 'ok', False, 'action', 'account.credits.fetch', 'message', 'Chưa có tài khoản để lấy credits.', '_set_status', '_run_silent_credential_check', 'count', True
        pass

    def _setup_periodic_credential_check(self) -> 'None':
        # [PyArmor BCC constants]: 'QTimer', '_credential_check_timer', 'setInterval', 1800000, 'timeout', 'connect', '_run_silent_credential_check', 'singleShot', 300000, '_start_credential_check_timer'
        pass

    def _start_credential_check_timer(self) -> 'None':
        pass

    def _run_silent_credential_check(self) -> 'None':
        # [PyArmor BCC constants]: 'getLogger', '__name__', '_accounts', 'str', 'get', 'email', '', 'id', 'debug', 'periodic credential check: no accounts, skipping', 'periodic credential check: checking %d account(s)', 'len', '_account_service', 'check_account', 'account_id'
        pass

    @staticmethod
    def _tier_label(row: 'dict[str, Any]') -> 'str':
        pass

    def _normalize_account(self, row: 'dict[str, Any]', ultra_mode: 'bool' = False) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'str', 'get', 'email', 'account_email', '', 'name', 'profile_name', 'status', 'has_credentials', 'ready', 'missing', '_proxy_display_for_account', 'proxy', 'id', 'displayName'
        pass

    def _normalize_proxy(self, proxy: 'Any') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'isinstance', 'dict', 'key', 'host', 'port', 'type', 'status', 'responseTime', 'assignedAccount', 'failCount', 'lastError', 'message', 'str', 'get', ''
        pass

    def _normalize_api_key(self, row: 'dict[str, Any]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'id', 'provider', 'label', 'maskedKey', 'createdAt', 'int', 'get', 0, 'str', '', 'masked_key', 'created_at'
        pass

    def _load_resources(self) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'databasePath', '', 'databaseDir', 'databaseExists', False, 'databaseSize', 'databaseMode', 'resourcePath', 'resourcePathExists', 'localTtsInstallPath', 'localTtsInstalled', 'localTtsRunning', 'localTtsRunningKnown', 'localTtsStatus', 'missing'
        pass

    def _rebuild_stats(self) -> 'None':
        # [PyArmor BCC constants]: 'accounts', 'enabledAccounts', 'healthyAccounts', 'proxies', 'liveProxies', 'deadProxies', 'assignedProxies', 'apiKeys'
        pass

    def _run_proxy_check(self, proxy_keys: 'list[str]', initial_rows: 'list[dict[str, Any]]') -> 'None':
        # [PyArmor BCC constants]: 'running', 'current', 'total', 'live', 'dead', 'rows', 'message', '_refreshProxies', '_statusMessage'
        pass

    def _run_account_health_check(self, targets: 'list[dict[str, Any]]') -> 'None':
        # [PyArmor BCC constants]: 0, 'len', 'enumerate', 'start', 1, 'str', 'get', 'email', '', 'id', '_account_service', 'check_account', 'account_id', 'ok', 'healthy'
        pass

    def _apply_proxy_check_payload(self, payload: 'dict[str, Any]') -> 'None':
        # [PyArmor BCC constants]: 'bool', 'pop', '_refreshProxies', False, 'str', '_statusMessage', '', '_set_proxy_check', 'refreshProxies', '_set_status'
        pass

    def _apply_account_check_payload(self, payload: 'dict[str, Any]') -> 'None':
        # [PyArmor BCC constants]: 'bool', 'pop', '_refreshAccounts', False, 'str', '_statusMessage', '', '_set_account_check', 'refreshAccounts', '_set_status'
        pass

    def _apply_browser_login_payload(self, payload: 'dict[str, Any]') -> 'None':
        # [PyArmor BCC constants]: 'str', 'pop', '_statusMessage', '', '_set_browser_login', '_set_status'
        pass

    def _apply_browser_login_poll_payload(self, event: 'dict[str, Any]') -> 'None':
        # [PyArmor BCC constants]: False, '_browser_login_poll_inflight', 'str', 'get', 'profileName', '', '_browser_login', 'active', 'result', 'dict', 'isinstance', 'bool', 'isRunning', 'status', 'strip'
        pass

    def _abort_browser_login(self, *, error: 'str', stage: 'str', message: 'str', poll_count: 'int | None' = None) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'str', '_browser_login', 'get', 'profileName', '', '_close_labs_login_transaction', 'Exception', 'threading', 'Thread', 'target', 'daemon', True, 'start', 'active', 'loggedIn'
        pass

    def _apply_local_tts_install_payload(self, payload: 'dict[str, Any]') -> 'None':
        # [PyArmor BCC constants]: 'bool', 'pop', '_refreshResources', False, 'str', '_statusMessage', '', '_set_local_tts_install', 'refreshResources', '_set_status'
        pass

    def _set_proxy_check(self, payload: 'dict[str, Any]') -> 'None':
        # [PyArmor BCC constants]: 'dict', '_proxy_check', 'proxyCheckChanged', 'emit'
        pass

    def _set_account_check(self, payload: 'dict[str, Any]') -> 'None':
        # [PyArmor BCC constants]: 'dict', '_account_check', 'accountCheckChanged', 'emit'
        pass

    def _set_browser_login(self, payload: 'dict[str, Any]') -> 'None':
        # [PyArmor BCC constants]: 'dict', '_browser_login', 'browserLoginChanged', 'emit'
        pass

    def _set_local_tts_install(self, payload: 'dict[str, Any]') -> 'None':
        # [PyArmor BCC constants]: 'dict', '_local_tts_install', 'localTtsInstallChanged', 'emit'
        pass

    def _proxy_display_for_account(self, email: 'str', raw_proxy: 'str') -> 'str':
        # [PyArmor BCC constants]: '_account_service', 'proxy_choices', 'str', 'get', 'currentProxy', '', 'Exception'
        pass

    def _reload_dispatcher_accounts(self) -> 'int | None':
        # [PyArmor BCC constants]: 'get_dispatcher', 'int', 'reload_accounts', 0
        pass

    def _apply_native_action(self, payload: 'dict[str, Any]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'dict', '_native_action', 'nativeActionChanged', 'emit', '_set_status', 'str', 'get', 'message', 'Native action blocked'
        pass

    def _apply_open_path_action(self, payload: 'dict[str, Any]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'dict', '_native_action', 'nativeActionChanged', 'emit', '_set_status', 'str', 'get', 'message', 'Resource open request completed', 'ok', 'path', 'openPathRequested', ''
        pass

    def _set_status(self, message: 'str') -> 'None':
        pass

    def _set_api_mode(self, mode: 'str', *, from_server: 'bool' = False) -> 'None':
        # [PyArmor BCC constants]: 'str', 'aistudio', 'strip', 'lower', 'server', 'personal', '_AI_MODE_UI_KEYS', '_allowed_modes', 'get', True, '_set_status', "Chế độ '", "' đang bị quản trị tắt", 'apiModeChanged', 'emit'
        pass

    def _browser_manager(self) -> 'Any':
        # [PyArmor BCC constants]: '_browser_manager_override', '_account_service', '_browser_manager', 'get_browser_manager', 'Exception'
        pass

    def _account_manager(self) -> 'Any':
        # [PyArmor BCC constants]: '_account_manager_override', '_account_service', '_account_manager', 'Exception', 'get_account_manager'
        pass

    def _local_tts_manager(self) -> 'Any':
        """Local TTS removed — stub for legacy QML slots."""
        pass

    def _account_session_provider(self):
        # [PyArmor BCC constants]: 'getattr', '_account_session_provider_override', 'get_account_session_provider'
        pass

    def _schedule_farm_prewarm(self, account_id: 'str') -> 'bool':
        # [PyArmor BCC constants]: 'get_captcha_token_manager', 'prewarm_account', 'account_id', 'reason', 'post_login', 'replace_existing', True, 'bool', 'get', 'success'
        pass

    def _create_project_for_account(self) -> 'Callable[..., Any]':
        pass

    def _local_tts_install_dir_path(self) -> 'Path | None':
        pass

    def _begin_browser_login_import(self, poll_payload: 'dict[str, Any]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'dict', '_browser_login', 'bool', 'get', 'stage', 'closing_login_browser', 'commitComplete', True, 'waiting_for_account_metadata', 'capturing_account_metadata', 'capturing_session', 'Closing the login browser...', 'Retrying account plan and credits...', 'Verifying Google session and account plan...', '_set_browser_login'
        pass

    def _complete_post_login_project_setup(self, account_name: 'str', email: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '', False, '_account_session_provider', 'resolve_identity', 'account_name', 'account_email', '_account_service', 'get_account', 'email', 'str', 'get', 'project_id', 'list_projects', 'tool_name', 'PINHOLE'
        pass

    def _schedule_post_login_project_setup(self, account_name: 'str', email: 'str') -> 'None':
        # [PyArmor BCC constants]: 'str', '', 'strip', '_complete_post_login_project_setup', 'ok', 'action', 'email', 'projectError', 'message', False, 'account.browser_login_project_setup', 'project_setup_failed:', 300, 'Account imported, but project discovery was not completed.', 'Exception'
        pass

    def _finalize_committed_browser_login(self, flow: 'dict[str, Any]', profile_name: 'str', email: 'str', account_name: 'str', display_name: 'str', avatar_url: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'commitComplete', 'committedAccountName', 'committedEmail', 'committedDisplayName', 'committedAvatarUrl', 'dict', True, '_close_labs_login_transaction', 'Account saved. Waiting for the login browser to close...', 'ok', 'pending', 'action', 'message', 'error', '_browserLogin'
        pass

    def _complete_browser_login(self, poll_payload: 'dict[str, Any]', flow: 'dict[str, Any]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'active', 'loggedIn', 'stage', 'message', 'pollCount'
        pass

    def accountProjects(self, email: 'str') -> 'list':
        # [PyArmor BCC constants]: '_account_session_provider', 'resolve_identity', 'account_email', 'str', '', 'list_projects', 'tool_name', 'PINHOLE', 'print', '[SESSION] accountProjects failed for ', ': ', 'Exception'
        pass

    def requestAccountProjects(self, email: 'str') -> 'dict':
        # [PyArmor BCC constants]: 'str', '', '_account_session_provider', 'resolve_identity', 'account_email', 'list_projects', 'tool_name', 'PINHOLE', 'ok', 'action', 'email', 'projects', True, 'account.list_projects', 'list'
        pass

    def useExistingProject(self, email: 'str', project_id: 'str') -> 'dict':
        # [PyArmor BCC constants]: 'str', '', '_account_session_provider', 'resolve_identity', 'account_email', 'set_project', 'ok', 'action', 'email', 'projectId', True, 'account.use_project', 'print', '[SESSION] useExistingProject failed for ', ': '
        pass

    def createNewProject(self, email: 'str') -> 'dict':
        # [PyArmor BCC constants]: 'str', '', '_account_session_provider', 'resolve_identity', 'account_email', '_account_service', 'get_account', 'email', 'get', 'id', '_account_manager', 'update_account', 'int', 'project_id', 'Exception'
        pass


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


# --- Class: AutomationCenterHost ---
class AutomationCenterHost(QObject):
    """One-process Automation Center facade and embedded-workspace owner."""
    staticMetaObject = PySide6.QtCore.QMetaObject("AutomationCenterHost" inherits "QObject":
Properties:
  #1 "runModel", QObject* [constant] [...

    busyChanged = Signal()
    initializedChanged = Signal()
    statsChanged = Signal()
    statusChanged = Signal()
    activeStateKnownChanged = Signal()
    capabilitiesChanged = Signal()
    executionChanged = Signal()
    selectedOrderChanged = Signal()
    profilePageChanged = Signal()
    publishAttemptPageChanged = Signal()
    schedulePageChanged = Signal()
    planDraftChanged = Signal()
    copilotChanged = Signal()
    localTimezoneChanged = Signal()
    workspaceActiveChanged = Signal()
    darkModeChanged = Signal()
    embeddedWorkspaceChanged = Signal()
    workspaceMountedChanged = Signal()
    workOrderCreated = Signal()
    socialProfileCreated = Signal()
    socialProfilesCreated = Signal()
    channelProfileSaved = Signal()
    referencePackSaved = Signal()
    operationCompleted = Signal()
    operationFailed = Signal()
    exitGuardRequested = Signal()
    _operationReady = Signal()
    _jobStorePush = Signal()
    _workspaceBridgeReady = Signal()
    _copilotStreamEvent = Signal()
    def __init__(self, service_factory: 'Callable[[], Any] | None' = None, qml_path: 'str | Path | None' = None, parent: 'QObject | None' = None) -> 'None':
        # [PyArmor BCC constants]: 'all', 'running', 'logged_in', 'attention'
        pass

    def runModel(*args, **kwargs):
        pass

    def orderModel(*args, **kwargs):
        pass

    def stepModel(*args, **kwargs):
        pass

    def allStepModel(*args, **kwargs):
        pass

    def profileModel(*args, **kwargs):
        pass

    def channelProfileModel(*args, **kwargs):
        pass

    def referencePackModel(*args, **kwargs):
        pass

    def publishAttemptModel(*args, **kwargs):
        pass

    def profilePage(*args, **kwargs):
        pass

    def publishAttemptPage(*args, **kwargs):
        pass

    def scheduleCapacityModel(*args, **kwargs):
        pass

    def scheduleRecurrenceModel(*args, **kwargs):
        pass

    def scheduleOccurrenceModel(*args, **kwargs):
        pass

    def attentionModel(*args, **kwargs):
        pass

    def scheduleOccurrencePage(*args, **kwargs):
        pass

    def attentionPage(*args, **kwargs):
        pass

    def copilotProjectModel(*args, **kwargs):
        pass

    def copilotMessageModel(*args, **kwargs):
        pass

    def copilotContentModel(*args, **kwargs):
        pass

    def copilotSourceModel(*args, **kwargs):
        pass

    def selectedOrderId(*args, **kwargs):
        pass

    def selectedOrder(*args, **kwargs):
        pass

    def planDraft(*args, **kwargs):
        pass

    def selectedCopilotProjectId(*args, **kwargs):
        pass

    def selectedCopilotProject(*args, **kwargs):
        pass

    def copilotStrategy(*args, **kwargs):
        pass

    def copilotRevision(*args, **kwargs):
        pass

    def localTimezone(*args, **kwargs):
        pass

    def workspaceActive(*args, **kwargs):
        pass

    def darkMode(*args, **kwargs):
        pass

    def embeddedWorkspace(*args, **kwargs):
        pass

    def workspaceMounted(*args, **kwargs):
        pass

    def busy(*args, **kwargs):
        pass

    def initialized(*args, **kwargs):
        pass

    def activeCount(*args, **kwargs):
        pass

    def totalCount(*args, **kwargs):
        pass

    def succeededCount(*args, **kwargs):
        pass

    def failedCount(*args, **kwargs):
        pass

    def statusMessage(*args, **kwargs):
        pass

    def activeStateKnown(*args, **kwargs):
        pass

    def capabilities(*args, **kwargs):
        pass

    def canSubmit(*args, **kwargs):
        pass

    def runActive(*args, **kwargs):
        pass

    def execution(*args, **kwargs):
        pass

    def attachEngine(self, engine: 'QObject', appController: 'QObject') -> 'None':
        # [PyArmor BCC constants]: '_engine', 'rootContext', 'setContextProperty', 'automationCenterHost', '_set_status', 'Không thể gắn Automation Center vào QML: ', 'Exception', '_app_controller', 'getattr', 'darkModeChanged', 'disconnect', '_sync_dark_mode', 'RuntimeError', 'TypeError', 'connect'
        pass

    def attachMainWindow(self, window: 'QObject') -> 'None':
        # [PyArmor BCC constants]: '_main_window', 'getattr', 'destroyed', 'connect', '_on_main_window_destroyed', 'RuntimeError', 'TypeError'
        pass

    def start(self) -> 'None':
        # [PyArmor BCC constants]: '_shutdown_requested', '_started', True, '_set_status', 'Đang khởi tạo Automation Center…', 'refresh'
        pass

    def activateWorkspaceRoute(self, route: 'str' = '') -> 'None':
        # [PyArmor BCC constants]: '_shutdown_requested', 'str', '', 'strip', '_pending_route', '_ensure_workspace_component', '_started', 'start', '_workspace', '_apply_requested_route'
        pass

    def mountWorkspace(self, parentItem: 'QObject', route: 'str' = '') -> 'None':
        # [PyArmor BCC constants]: '_shutdown_requested', 'isinstance', 'QQuickItem', '_set_status', 'Automation Center cần một QQuickItem để mount', 'str', '', 'strip', '_pending_route', '_set_mount_target', '_workspace_active', True, 'workspaceActiveChanged', 'emit', '_ensure_workspace_component'
        pass

    def unmountWorkspace(self, parentItem: 'QObject') -> 'None':
        # [PyArmor BCC constants]: '_mount_target', '_set_mount_target', '_workspace', 'setParentItem', 'setProperty', 'workspaceActive', False, 'RuntimeError', '_workspace_active', 'workspaceActiveChanged', 'emit', '_set_workspace_mounted'
        pass

    def setWorkspaceActive(self, active: 'bool') -> 'None':
        # [PyArmor BCC constants]: 'bool', '_workspace_active', '_workspace', 'setProperty', 'workspaceActive', 'RuntimeError', 'workspaceActiveChanged', 'emit', '_clear_workspace_focus', 'QTimer', 'singleShot', 0
        pass

    def _clear_workspace_focus(self) -> 'None':
        # [PyArmor BCC constants]: '_workspace', 'setFocus', False, 'RuntimeError', '_main_window', 'getattr', 'contentItem', 'callable', 'forceActiveFocus', 'Qt', 'FocusReason', 'OtherFocusReason', 'AttributeError', 'TypeError'
        pass

    def refresh(self) -> 'None':
        # [PyArmor BCC constants]: '_shutdown_requested', '_started', 'start', '_refresh_inflight', True, '_refresh_again', '_submit_operation', 'refresh', '_refresh_worker', False
        pass

    def selectOrder(self, orderId: 'str') -> 'None':
        # [PyArmor BCC constants]: 'str', '', 'strip', '_order_rows_by_id', '_set_selected_order'
        pass

    def createWorkOrder(self, title: 'str', workflow: 'str', inputMode: 'str', content: 'str', autoPublish: 'bool', profileId: 'str', caption: 'str') -> 'bool':
        # [PyArmor BCC constants]: 'str', '', 'strip', 'lower', '_set_status', 'Hãy đặt tên cho work order', False, 'master', 'idea', 'script', 'clone', 'local_video', 'transcript', 'audio_file', 'text'
        pass

    def createWorkOrderV2(self, definition: 'Any') -> 'bool':
        # [PyArmor BCC constants]: 'isinstance', 'Mapping', 'dict', 'str', 'get', 'title', '', 'strip', '_set_status', 'Hãy đặt tên cho work order', False, 'production_control', 'production', 'Work order chưa có cấu hình sản xuất', '_shutdown_requested'
        pass

    def draftAutomationPlan(self, brief: 'str', autoPublish: 'bool', profileId: 'str') -> 'bool':
        # [PyArmor BCC constants]: 'str', '', 'strip', '_set_status', 'Hãy mô tả việc cần AI Studio lập kế hoạch', False, 'bool', 'Bản nháp tự đăng cần một hồ sơ mạng xã hội đã xác minh', '_shutdown_requested', '_started', 'start', '_submit_operation', 'draft_plan', 'partial', '_draft_plan_worker'
        pass

    def clearPlanDraft(self) -> 'None':
        pass

    def createCopilotProject(self, title: 'str', brief: 'str') -> 'bool':
        # [PyArmor BCC constants]: 'str', '', 'strip', '_set_status', 'Hãy mô tả mục tiêu kênh trước', False, '_shutdown_requested', '_started', 'start', '_submit_operation', 'copilot_create_project', 'partial', '_create_copilot_project_worker', 'invalidate_active_state', 'Đang tạo không gian lập kế hoạch kênh…'
        pass

    def importCopilotSources(self, projectId: 'str', sources: 'Any') -> 'bool':
        # [PyArmor BCC constants]: 'str', '', 'strip', 'list', 'isinstance', 'Mapping', 'dict', '_set_status', 'Hãy tạo hoặc chọn một kế hoạch kênh', False, 'Hãy nhập ít nhất một nguồn', '_shutdown_requested', '_started', 'start', '_submit_operation'
        pass

    def configureCopilotDelivery(self, projectId: 'str', delivery: 'Any') -> 'bool':
        # [PyArmor BCC constants]: 'str', '', 'strip', 'isinstance', 'Mapping', 'dict', '_set_status', 'Hãy tạo hoặc chọn một kế hoạch kênh', False, '_shutdown_requested', '_started', 'start', '_submit_operation', 'copilot_configure_delivery', 'partial'
        pass

    def selectCopilotProject(self, projectId: 'str') -> 'bool':
        # [PyArmor BCC constants]: 'str', '', 'strip', '_shutdown_requested', False, '_started', 'start', '_submit_operation', 'copilot_select_project', 'partial', '_select_copilot_project_worker', 'invalidate_active_state'
        pass

    def sendCopilotMessage(self, projectId: 'str', message: 'str') -> 'bool':
        # [PyArmor BCC constants]: 'str', '', 'strip', '_set_status', 'Hãy tạo hoặc chọn một kế hoạch kênh', False, 'Hãy nhập yêu cầu cho Channel Copilot', '_shutdown_requested', '_started', 'start', '_submit_operation', 'copilot_send_message', 'partial', '_send_copilot_message_worker', 'invalidate_active_state'
        pass

    def resumeCopilotConversation(self, projectId: 'str') -> 'bool':
        # [PyArmor BCC constants]: 'str', '', 'strip', '_shutdown_requested', False, '_started', 'start', '_submit_operation', 'copilot_conversation_resume', 'partial', '_resume_copilot_conversation_worker', 'invalidate_active_state', '_set_status', 'Đang xác minh lại đúng account LLM trong browser…'
        pass

    def resetCopilotConversation(self, projectId: 'str') -> 'bool':
        # [PyArmor BCC constants]: 'str', '', 'strip', '_shutdown_requested', False, '_started', 'start', '_submit_operation', 'copilot_conversation_reset', 'partial', '_reset_copilot_conversation_worker', 'invalidate_active_state', '_set_status', 'Đang tạo cuộc trò chuyện mới bằng account LLM đã chọn…'
        pass

    def approveCopilotPlan(self, projectId: 'str', revision: 'int') -> 'bool':
        # [PyArmor BCC constants]: 'str', '', 'strip', 'int', 0, '_set_status', 'Chưa có revision để duyệt', False, '_shutdown_requested', '_started', 'start', '_submit_operation', 'copilot_approve_plan', 'partial', '_approve_copilot_plan_worker'
        pass

    def prepareCopilotAssignments(self, projectId: 'str') -> 'bool':
        # [PyArmor BCC constants]: 'str', '', 'strip', '_shutdown_requested', False, '_started', 'start', '_submit_operation', 'copilot_prepare_assignments', 'partial', '_prepare_copilot_assignments_worker', 'invalidate_active_state', '_set_status', 'Đang biên dịch các mục sẵn sàng sang Assignment V2…'
        pass

    def assignCopilotItem(self, projectId: 'str', contentItemId: 'str') -> 'bool':
        # [PyArmor BCC constants]: 'str', '', 'strip', '_shutdown_requested', False, '_started', 'start', '_submit_operation', 'copilot_assign_item', 'partial', '_assign_copilot_item_worker', '_set_status', 'Đang giao content item vào coordinator tuần tự…'
        pass

    def assignAllCopilotItems(self, projectId: 'str') -> 'bool':
        # [PyArmor BCC constants]: 'str', '', 'strip', '_set_status', 'Hãy tạo hoặc chọn một kế hoạch kênh', False, '_shutdown_requested', '_started', 'start', '_submit_operation', 'copilot_assign_all', 'partial', '_assign_all_copilot_items_worker', 'Đang xếp toàn bộ kế hoạch vào coordinator tuần tự…'
        pass

    def startOrder(self, orderId: 'str') -> 'bool':
        pass

    def pauseOrder(self, orderId: 'str') -> 'bool':
        pass

    def resumeOrder(self, orderId: 'str') -> 'bool':
        pass

    def retryOrder(self, orderId: 'str') -> 'bool':
        pass

    def cancelOrder(self, orderId: 'str') -> 'bool':
        pass

    def resolveOrderAttention(self, orderId: 'str', stepId: 'str', resolution: 'str', evidence: 'dict[str, Any]') -> 'bool':
        # [PyArmor BCC constants]: 'str', '', 'strip', 'lower', '_set_status', 'Chọn đúng bước cần đối soát trước', False, 'published', 'not_published', 'failed', 'Kết quả đối soát không hợp lệ', '_shutdown_requested', '_submit_operation', 'resolve_attention', 'partial'
        pass

    def createSocialProfile(self, platform: 'str', label: 'str') -> 'bool':
        # [PyArmor BCC constants]: 'str', '', 'strip', 'lower', 'facebook', 'youtube', 'tiktok', '_set_status', 'Chỉ hỗ trợ TikTok, YouTube và Facebook', False, 'Hãy đặt tên cho hồ sơ đăng', '_shutdown_requested', '_started', 'start', '_submit_operation'
        pass

    def saveChannelProductionProfile(self, value: 'Any') -> 'bool':
        # [PyArmor BCC constants]: 'isinstance', 'Mapping', 'dict', 'str', 'get', 'social_profile_id', 'profile_id', '', 'strip', '_set_status', 'Hãy chọn hồ sơ đăng cần lưu cấu hình kênh', False, '_shutdown_requested', '_started', 'start'
        pass

    def captureChannelProductionProfile(self, profileId: 'str', overrides: 'Any') -> 'bool':
        # [PyArmor BCC constants]: 'str', '', 'strip', '_set_status', 'Hãy chọn hồ sơ đăng cần chụp cấu hình', False, 'isinstance', 'Mapping', 'dict', '_shutdown_requested', '_started', 'start', '_submit_operation', 'capture_channel_profile', 'partial'
        pass

    def cloneChannelProductionProfile(self, value: 'Any') -> 'bool':
        # [PyArmor BCC constants]: 'isinstance', 'Mapping', 'dict', 'str', 'get', 'source_channel_profile_id', '', 'strip', '_set_status', 'Hãy chọn bộ cấu hình nguồn cần nhân bản', False, 'target_social_profile_id', 'Hãy chọn kênh đích cần nhận cấu hình', '_shutdown_requested', '_started'
        pass

    def loadChannelDevelopmentKit(self, channelProfileId: 'str', version: 'int') -> 'bool':
        # [PyArmor BCC constants]: 'str', '', 'strip', '_set_status', 'Hãy chọn cấu hình kênh cần mở', False, '_shutdown_requested', '_started', 'start', '_submit_operation', 'load_channel_kit', 'partial', '_load_channel_kit_worker', 'max', 0
        pass

    def captureChannelWorkflowConfig(self, channelProfileId: 'str', workflow: 'str', expectedVersion: 'int', expectedHash: 'str') -> 'bool':
        # [PyArmor BCC constants]: 'str', '', 'strip', 'lower', 'master', 'timemachine', 'transcript', 'clone', 'affiliate', '_set_status', 'Hãy chọn kênh và feature Tool 1 cần capture', False, '_shutdown_requested', '_started', 'start'
        pass

    def saveChannelWorkflowConfig(self, channelProfileId: 'str', workflow: 'str', config: 'Any', expectedVersion: 'int', expectedHash: 'str') -> 'bool':
        # [PyArmor BCC constants]: 'str', '', 'strip', 'lower', 'isinstance', 'Mapping', 'dict', 'master', 'timemachine', 'transcript', 'clone', 'affiliate', '_set_status', 'Hãy chọn kênh và feature Tool 1 cần lưu', False
        pass

    def diffChannelProfileVersions(self, channelProfileId: 'str', beforeVersion: 'int', afterVersion: 'int') -> 'bool':
        # [PyArmor BCC constants]: 'str', '', 'strip', 'int', 0, '_set_status', 'Hãy chọn hai revision cấu hình kênh để so sánh', False, '_shutdown_requested', '_started', 'start', '_submit_operation', 'diff_channel_profile', 'partial', '_diff_channel_profile_worker'
        pass

    def bindCopilotChannelProfile(self, projectId: 'str', channelProfileId: 'str') -> 'bool':
        # [PyArmor BCC constants]: 'str', '', 'strip', '_set_status', 'Hãy chọn kế hoạch và cấu hình kênh', False, '_shutdown_requested', '_started', 'start', '_submit_operation', 'copilot_bind_channel_profile', 'partial', '_bind_copilot_channel_profile_worker', 'invalidate_active_state', 'Đang gắn kế hoạch với cấu hình sản xuất của kênh…'
        pass

    def saveReferencePack(self, value: 'Any') -> 'bool':
        # [PyArmor BCC constants]: 'isinstance', 'Mapping', 'dict', 'str', 'get', 'title', '', 'strip', 'reference_pack_id', '_set_status', 'Hãy đặt tên cho Reference Pack', False, '_shutdown_requested', '_started', 'start'
        pass

    def bindCopilotReferencePack(self, projectId: 'str', referencePackId: 'str') -> 'bool':
        # [PyArmor BCC constants]: 'str', '', 'strip', '_set_status', 'Hãy chọn một kế hoạch kênh', False, '_shutdown_requested', '_started', 'start', '_submit_operation', 'copilot_bind_reference_pack', 'partial', '_bind_copilot_reference_pack_worker', 'invalidate_active_state', 'Đang gắn Reference Pack cho revision kế hoạch tiếp theo…'
        pass

    def requestProfilePage(self, query: 'dict[str, Any]') -> 'bool':
        # [PyArmor BCC constants]: 'dict', 'str', 'get', 'platform', '', 'strip', 'lower', 'facebook', 'youtube', 'tiktok', '_set_status', 'Nền tảng này chưa có Publish Executor', False, 'view', 'all'
        pass

    def requestPublishAttemptPage(self, query: 'dict[str, Any]') -> 'bool':
        # [PyArmor BCC constants]: 'dict', 'str', 'get', 'platform', '', 'strip', 'lower', 'facebook', 'youtube', 'tiktok', '_set_status', 'Nền tảng này chưa có Publish Executor', False, 'int', 'limit'
        pass

    def requestScheduleOccurrencePage(self, query: 'dict[str, Any]') -> 'bool':
        # [PyArmor BCC constants]: 'dict', 'int', 'get', 'limit', 100, 'offset', 'cursor', 0, '_set_status', 'Trang lịch đăng không hợp lệ', False, 'TypeError', 'ValueError', 1, 500
        pass

    def requestAttentionPage(self, query: 'dict[str, Any]') -> 'bool':
        # [PyArmor BCC constants]: 'dict', 'int', 'get', 'limit', 100, 'offset', 'cursor', 0, '_set_status', 'Trang cần xử lý không hợp lệ', False, 'TypeError', 'ValueError', 1, 500
        pass

    def saveScheduleCapacityPolicy(self, value: 'dict[str, Any]') -> 'bool':
        # [PyArmor BCC constants]: 'dict', 'str', 'get', 'channel_id', '', 'strip', '_set_status', 'Hãy chọn kênh cần giới hạn lịch đăng', False, '_submit_operation', 'save_schedule_capacity', 'partial', '_save_schedule_capacity_worker', 'invalidate_active_state', 'Đang lưu phiên bản công suất kênh…'
        pass

    def saveScheduleRecurrence(self, value: 'dict[str, Any]', assignmentDefinition: 'dict[str, Any]') -> 'bool':
        # [PyArmor BCC constants]: 'dict', '_set_status', 'Lịch lặp cần rule và Assignment V2 đã review', False, '_submit_operation', 'save_schedule_recurrence', 'partial', '_save_schedule_recurrence_worker', 'invalidate_active_state', 'Đang đóng băng lịch lặp…'
        pass

    def previewScheduleConflict(self, value: 'dict[str, Any]') -> 'bool':
        pass

    def previewScheduleRecurrence(self, value: 'dict[str, Any]') -> 'bool':
        # [PyArmor BCC constants]: 'dict', 'str', 'get', 'recurrence_id', 'recurrence_key', '', 'strip', 'window_start_utc', 'window_start', 'window_end_utc', 'window_end', '_set_status', 'Xem trước lịch lặp cần quy tắc và cửa sổ UTC', False, 'update'
        pass

    def materializeScheduleRecurrence(self, value: 'dict[str, Any]') -> 'bool':
        # [PyArmor BCC constants]: 'dict', 'str', 'get', 'recurrence_id', '', 'strip', '_set_status', 'Hãy chọn lịch lặp cần tạo work order', False, '_submit_operation', 'materialize_schedule_recurrence', 'partial', '_materialize_schedule_recurrence_worker', 'Đang kiểm tra xung đột và tạo occurrence…'
        pass

    def setScheduleRecurrenceState(self, recurrenceId: 'str', state: 'str') -> 'bool':
        # [PyArmor BCC constants]: 'str', '', 'strip', 'lower', 'active', 'paused', '_set_status', 'Lịch lặp hoặc trạng thái không hợp lệ', False, '_submit_operation', 'set_schedule_recurrence_state', 'partial', '_set_schedule_recurrence_state_worker', 'invalidate_active_state'
        pass

    def createSocialProfiles(self, platform: 'str', rowsText: 'str') -> 'bool':
        # [PyArmor BCC constants]: 'str', '', 'strip', 'lower', 'facebook', 'youtube', 'tiktok', '_set_status', 'Chỉ hỗ trợ TikTok, YouTube và Facebook', False, 'Hãy nhập ít nhất một dòng ID | tên hồ sơ', '_shutdown_requested', '_started', 'start', '_submit_operation'
        pass

    def previewSocialProfileImport(self, payload: 'dict[str, Any]') -> 'bool':
        # [PyArmor BCC constants]: 'dict', 'get', 'csv_content', '_set_status', 'Hãy nhập nội dung CSV hồ sơ', False, '_shutdown_requested', '_started', 'start', '_submit_operation', 'preview_profile_import', 'partial', '_preview_social_profile_import_worker', 'Đang kiểm tra CSV hồ sơ trên worker cục bộ…'
        pass

    def executeSocialProfileImport(self, importId: 'str') -> 'bool':
        # [PyArmor BCC constants]: 'str', '', 'strip', '_set_status', 'Thiếu import_id đã được xác nhận', False, '_shutdown_requested', '_started', 'start', '_submit_operation', 'execute_profile_import', 'partial', '_execute_social_profile_import_worker', 'Đang tạo hồ sơ từ bản preview đã đóng băng…'
        pass

    def openSocialProfile(self, profileId: 'str') -> 'bool':
        pass

    def closeSocialProfile(self, profileId: 'str') -> 'bool':
        pass

    def verifySocialProfile(self, profileId: 'str') -> 'bool':
        pass

    def preflightSocialProfile(self, profileId: 'str') -> 'bool':
        pass

    def _submit_order_action(self, action: 'str', order_id: 'str') -> 'bool':
        # [PyArmor BCC constants]: 'str', '', 'strip', '_set_status', 'Chọn một work order trước', False, '_shutdown_requested', '_submit_operation', 'partial', '_order_action_worker', 'Đang cập nhật work order…'
        pass

    def _submit_profile_action(self, action: 'str', profile_id: 'str') -> 'bool':
        # [PyArmor BCC constants]: 'str', '', 'strip', '_set_status', 'Chọn một hồ sơ đăng trước', False, '_shutdown_requested', '_submit_operation', 'partial', '_profile_action_worker', 'open_social_profile', 'Đang mở browser đăng nhập…', 'verify_social_profile', 'Đang kiểm tra đăng nhập và trang upload…', 'preflight_social_profile'
        pass

    def requestWindowClose(self, window: 'QObject') -> 'bool':
        # [PyArmor BCC constants]: '_active_state_known', True, 'runActive', 'execution', 'str', 'get', 'owner_workflow', 'automation', 'owner_state', 'unknown', '_active_count', 0, 'VeoFlow còn ', ' job đang chạy. Giữ Tool 1 mở cho đến khi các tác vụ provider kết thúc.', 'VeoFlow còn workflow '
        pass

    def setDarkMode(self, value: 'bool') -> 'None':
        # [PyArmor BCC constants]: 'bool', 'getattr', '_app_controller', 'setDarkMode', 'callable', '_set_status', 'Không thể đổi giao diện: ', 'Exception', '_sync_dark_mode', '_set_dark_mode'
        pass

    def shutdown(self) -> 'None':
        # [PyArmor BCC constants]: '_shutdown_requested', '_started', '_initialized', '_pending_count', 0, True, False, '_refresh_again', '_workspace_active', '_scheduled_wake_timer', 'stop', 'getattr', '_app_controller', 'darkModeChanged', 'disconnect'
        pass

    def _build_default_service_worker(self) -> 'Any':
        pass

    def _ensure_service_worker(self) -> 'Any':
        # [PyArmor BCC constants]: '_service', '_service_factory', '_build_default_service_worker'
        pass

    def _refresh_worker(self) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_uses_default_service', 'get_prompt_queue_service', '_ensure_service_worker', '_snapshot_from_service_worker'
        pass

    def _snapshot_from_service_worker(self, service: 'Any', copilot_project_id: 'str' = '') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'dict', 'refresh_runs', 'str', 'get', 'local_timezone', '', 'strip', 'get_localzone_name', 'UTC', 'Exception', 'getattr', 'capabilities', 'callable', 'list', 'list_work_orders'
        pass

    def _create_work_order_worker(self, title: 'str', workflow: 'str', mode: 'str', content: 'str', auto_publish: 'bool', profile_id: 'str', caption: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_ensure_service_worker', 'getattr', 'create_work_order', 'callable', 'RuntimeError', 'Work-order coordinator chưa được nạp', 'title', 'workflow', 'input_mode', 'content', 'options', 'config', 'auto_publish', 'profile_id', 'caption'
        pass

    def _create_work_order_v2_worker(self, definition: 'Mapping[str, Any]', order_id: 'str', submission_key: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_ensure_service_worker', 'getattr', 'create_work_order_v2', 'callable', 'assignment_definition', 'dict', 'auto_start', True, 'order_id', 'str', '', 'submission_key', 'create_work_order', 'RuntimeError', 'Coordinator chưa hỗ trợ contract giao việc V2'
        pass

    def _acknowledge_assignment_create_worker(self, assignment_request_key: 'str', order_id: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_ensure_service_worker', 'getattr', 'acknowledge_assignment_create', 'callable', 'RuntimeError', 'Coordinator chưa hỗ trợ xác nhận giao việc bền vững', 'bool', 'Không thể xác nhận receipt giao việc bền vững', '_snapshot_from_service_worker'
        pass

    def _draft_plan_worker(self, brief: 'str', auto_publish: 'bool', profile_id: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_ensure_service_worker', 'getattr', 'draft_automation_plan', 'callable', 'draft_plan', 'RuntimeError', 'AI Studio planner chưa được nạp', 'auto_publish', 'profile_id', '_snapshot_from_service_worker', 'isinstance', 'Mapping', 'dict', 'plan_draft'
        pass

    def _create_copilot_project_worker(self, title: 'str', brief: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_ensure_service_worker', 'getattr', 'create_copilot_project', 'callable', 'RuntimeError', 'Channel Copilot store chưa được nạp', 'str', 'isinstance', 'Mapping', 'get', 'selected_project_id', '', '_snapshot_from_service_worker', 'copilot_project_id'
        pass

    def _select_copilot_project_worker(self, project_id: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_ensure_service_worker', 'getattr', 'copilot_snapshot', 'callable', 'RuntimeError', 'Channel Copilot store chưa được nạp', '_snapshot_from_service_worker', 'copilot_project_id'
        pass

    def _import_copilot_sources_worker(self, project_id: 'str', sources: 'list[dict[str, Any]]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_ensure_service_worker', 'getattr', 'import_copilot_sources', 'callable', 'RuntimeError', 'Channel Copilot source intake chưa được nạp', '_snapshot_from_service_worker', 'isinstance', 'Mapping', 'dict', 'get', 'source_import', 'copilot_project_id'
        pass

    def _configure_copilot_delivery_worker(self, project_id: 'str', delivery: 'dict[str, Any]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_ensure_service_worker', 'getattr', 'configure_copilot_delivery', 'callable', 'RuntimeError', 'Channel Copilot delivery store chưa được nạp', '_snapshot_from_service_worker', 'copilot_project_id'
        pass

    def _bind_copilot_channel_profile_worker(self, project_id: 'str', channel_profile_id: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_ensure_service_worker', 'getattr', 'bind_copilot_channel_profile', 'callable', 'RuntimeError', 'Channel production profile binder chưa được nạp', '_snapshot_from_service_worker', 'copilot_project_id'
        pass

    def _bind_copilot_reference_pack_worker(self, project_id: 'str', reference_pack_id: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_ensure_service_worker', 'getattr', 'bind_copilot_reference_pack', 'callable', 'RuntimeError', 'Reference Pack binder chưa được nạp', '_snapshot_from_service_worker', 'copilot_project_id'
        pass

    def _send_copilot_message_worker(self, project_id: 'str', message: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_ensure_service_worker', 'getattr', 'send_copilot_message', 'callable', 'RuntimeError', 'Channel Copilot AI Studio chưa được nạp', '_copilotStreamEvent', 'emit', 'dict', 'on_stream', '_snapshot_from_service_worker', 'copilot_project_id'
        pass

    def _resume_copilot_conversation_worker(self, project_id: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_ensure_service_worker', 'getattr', 'resume_copilot_conversation', 'callable', 'RuntimeError', 'Channel Copilot reconnect chưa được nạp', '_snapshot_from_service_worker', 'copilot_project_id'
        pass

    def _reset_copilot_conversation_worker(self, project_id: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_ensure_service_worker', 'getattr', 'reset_copilot_conversation', 'callable', 'RuntimeError', 'Channel Copilot reset chưa được nạp', '_snapshot_from_service_worker', 'copilot_project_id'
        pass

    def _approve_copilot_plan_worker(self, project_id: 'str', revision: 'int') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_ensure_service_worker', 'getattr', 'approve_copilot_plan', 'callable', 'RuntimeError', 'Channel Copilot approval store chưa được nạp', '_snapshot_from_service_worker', 'copilot_project_id'
        pass

    def _prepare_copilot_assignments_worker(self, project_id: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_ensure_service_worker', 'getattr', 'prepare_copilot_assignments', 'callable', 'RuntimeError', 'Channel Copilot Assignment V2 compiler chưa được nạp', '_snapshot_from_service_worker', 'copilot_project_id'
        pass

    def _assign_copilot_item_worker(self, project_id: 'str', content_item_id: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_ensure_service_worker', 'getattr', 'assign_copilot_item', 'callable', 'RuntimeError', 'Channel Copilot assignment adapter chưa được nạp', '_snapshot_from_service_worker', 'isinstance', 'Mapping', 'get', 'order', 'str', 'order_id', 'orderId', ''
        pass

    def _assign_all_copilot_items_worker(self, project_id: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_ensure_service_worker', 'getattr', 'assign_all_copilot_items', 'callable', 'RuntimeError', 'Channel Copilot batch assignment chưa được nạp', '_snapshot_from_service_worker', 'isinstance', 'Mapping', 'list', 'get', 'order_ids', 'str', 'created_order_ids', 'int'
        pass

    def _order_action_worker(self, action: 'str', order_id: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_ensure_service_worker', 'start_order', 'start_work_order', 'pause_order', 'pause_work_order', 'resume_order', 'resume_work_order', 'retry_order', 'retry_work_order', 'cancel_order', 'cancel_work_order', 'get', 'getattr', 'callable', 'RuntimeError'
        pass

    def _profile_page_worker(self, request: 'Mapping[str, Any]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_ensure_service_worker', 'getattr', 'list_profiles_page', 'callable', 'RuntimeError', 'Publish Executor chưa hỗ trợ phân trang hồ sơ', 'profile_page', 'dict'
        pass

    def _publish_attempt_page_worker(self, request: 'Mapping[str, Any]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_ensure_service_worker', 'getattr', 'list_publish_attempts_page', 'callable', 'RuntimeError', 'Publish Executor chưa hỗ trợ lịch sử phân trang', 'publish_attempt_page', 'dict'
        pass

    def _schedule_occurrence_page_worker(self, request: 'Mapping[str, Any]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_ensure_service_worker', 'getattr', 'list_schedule_occurrences_page', 'callable', 'RuntimeError', 'Scheduler cục bộ chưa hỗ trợ phân trang occurrence', 'schedule_occurrence_page', 'dict'
        pass

    def _attention_page_worker(self, request: 'Mapping[str, Any]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_ensure_service_worker', 'getattr', 'list_attention_page', 'callable', 'RuntimeError', 'Automation Center chưa có attention query', 'attention_page', 'dict'
        pass

    def _save_schedule_capacity_worker(self, value: 'Mapping[str, Any]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_ensure_service_worker', 'getattr', 'save_schedule_capacity_policy', 'callable', 'RuntimeError', 'Scheduler cục bộ chưa hỗ trợ capacity policy', 'dict', '_snapshot_from_service_worker', 'schedule_capacity_result'
        pass

    def _save_schedule_recurrence_worker(self, value: 'Mapping[str, Any]', assignment: 'Mapping[str, Any]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_ensure_service_worker', 'getattr', 'save_schedule_recurrence', 'callable', 'RuntimeError', 'Scheduler cục bộ chưa hỗ trợ recurrence', 'dict', '_snapshot_from_service_worker', 'schedule_recurrence_result'
        pass

    def _preview_schedule_conflict_worker(self, value: 'Mapping[str, Any]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_ensure_service_worker', 'getattr', 'preview_schedule_conflict', 'callable', 'RuntimeError', 'Scheduler cục bộ chưa hỗ trợ conflict preview', 'platform', 'str', 'get', '', 'channel_id', 'scheduled_at_utc', 'timezone', 'duration_seconds', 'int'
        pass

    def _preview_schedule_recurrence_worker(self, value: 'Mapping[str, Any]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_ensure_service_worker', 'getattr', 'preview_schedule_recurrence', 'callable', 'RuntimeError', 'Scheduler cục bộ chưa hỗ trợ recurrence preview', 'str', 'get', 'recurrence_id', '', 'window_start_utc', 'window_end_utc', 'int', 'limit', 100
        pass

    def _materialize_schedule_recurrence_worker(self, value: 'Mapping[str, Any]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_ensure_service_worker', 'getattr', 'materialize_schedule_recurrence', 'callable', 'RuntimeError', 'Scheduler cục bộ chưa hỗ trợ materialize', 'str', 'get', 'recurrence_id', '', 'window_start_utc', 'window_end_utc', 'int', 'limit', 100
        pass

    def _set_schedule_recurrence_state_worker(self, recurrence_id: 'str', state: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_ensure_service_worker', 'getattr', 'set_schedule_recurrence_state', 'callable', 'RuntimeError', 'Scheduler cục bộ chưa hỗ trợ pause/resume', '_snapshot_from_service_worker', 'dict', 'schedule_recurrence_result'
        pass

    def _resolve_attention_worker(self, order_id: 'str', step_id: 'str', resolution: 'str', evidence: 'Mapping[str, Any]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_ensure_service_worker', 'getattr', 'resolve_work_order_attention', 'callable', 'resolve_order_attention', 'RuntimeError', 'Coordinator chưa hỗ trợ đối soát needs_attention', 'dict', '_snapshot_from_service_worker', 'selected_order_id'
        pass

    def _profile_action_worker(self, action: 'str', *args: 'Any') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_ensure_service_worker', 'getattr', 'callable', 'RuntimeError', 'Publish Executor chưa được nạp', '_snapshot_from_service_worker', 'isinstance', 'Mapping', 'dict', 'profile_result'
        pass

    def _save_channel_profile_worker(self, payload: 'Mapping[str, Any]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_ensure_service_worker', 'getattr', 'save_channel_production_profile', 'callable', 'RuntimeError', 'Channel production profile store chưa được nạp', 'dict', '_snapshot_from_service_worker', 'channel_profile_result', 'get_channel_development_kit', 'str', 'isinstance', 'Mapping', 'get', 'channel_profile_id'
        pass

    def _capture_channel_profile_worker(self, social_profile_id: 'str', overrides: 'Mapping[str, Any]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_ensure_service_worker', 'getattr', 'capture_channel_production_profile', 'callable', 'RuntimeError', 'Channel production profile capture chưa được nạp', 'dict', '_snapshot_from_service_worker', 'channel_profile_result', 'get_channel_development_kit', 'str', 'isinstance', 'Mapping', 'get', 'channel_profile_id'
        pass

    def _clone_channel_profile_worker(self, payload: 'Mapping[str, Any]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_ensure_service_worker', 'getattr', 'clone_channel_production_profile', 'callable', 'RuntimeError', 'Tiện ích nhân bản Channel Production Kit chưa được nạp', 'dict', '_snapshot_from_service_worker', 'isinstance', 'Mapping', 'get', 'profile', 'channel_profile_result', 'channel_profile_clone_result', 'str'
        pass

    def _load_channel_kit_worker(self, channel_profile_id: 'str', version: 'int') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_ensure_service_worker', 'getattr', 'get_channel_development_kit', 'callable', 'RuntimeError', 'Channel Production Kit V2 chưa được nạp', 'version', '_snapshot_from_service_worker', 'dict', 'channel_development_kit_result'
        pass

    def _capture_channel_workflow_worker(self, channel_profile_id: 'str', workflow: 'str', expected_version: 'int', expected_hash: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_ensure_service_worker', 'getattr', 'capture_channel_workflow_config', 'callable', 'RuntimeError', 'Capture cấu hình theo feature chưa được nạp', 'expected_version', 'expected_hash', '_snapshot_from_service_worker', 'isinstance', 'Mapping', 'get', 'profile', 'dict', 'channel_profile_result'
        pass

    def _save_channel_workflow_worker(self, channel_profile_id: 'str', workflow: 'str', config: 'Mapping[str, Any]', expected_version: 'int', expected_hash: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_ensure_service_worker', 'getattr', 'save_channel_workflow_config', 'callable', 'RuntimeError', 'Lưu cấu hình theo feature chưa được nạp', 'dict', 'expected_version', 'expected_hash', '_snapshot_from_service_worker', 'isinstance', 'Mapping', 'get', 'profile', 'channel_profile_result'
        pass

    def _diff_channel_profile_worker(self, channel_profile_id: 'str', before_version: 'int', after_version: 'int') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_ensure_service_worker', 'getattr', 'diff_channel_profile_versions', 'callable', 'RuntimeError', 'So sánh revision cấu hình kênh chưa được nạp', '_snapshot_from_service_worker', 'dict', 'channel_profile_diff_result'
        pass

    def _save_reference_pack_worker(self, payload: 'Mapping[str, Any]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_ensure_service_worker', 'getattr', 'save_reference_pack', 'callable', 'RuntimeError', 'Reference Pack store chưa được nạp', 'dict', '_snapshot_from_service_worker', 'reference_pack_result'
        pass

    def _create_social_profiles_text_worker(self, platform: 'str', rows_text: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'splitlines', 'strip', 'RuntimeError', 'Hãy nhập ít nhất một dòng ID | tên hồ sơ', 'len', '_MAX_PROFILE_IMPORT_ROWS', 'Mỗi lần chỉ nhập tối đa 1.000 hồ sơ', 'enumerate', 'start', 1, 'partition', '|', 'Dòng ', ' phải có định dạng ID ổn định | tên hồ sơ', 'append'
        pass

    def _preview_social_profile_import_worker(self, payload: 'Mapping[str, Any]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'profile_id', 'platform', 'label', 'browser_key'
        pass

    def _execute_social_profile_import_worker(self, import_id: 'str') -> 'dict[str, Any]':
        pass

    def _remember_profile_import(self, frozen: 'dict[str, Any]') -> 'None':
        # [PyArmor BCC constants]: 'len', '_profile_imports', '_MAX_FROZEN_PROFILE_IMPORTS', 'next', 'iter', '_forget_profile_import', 'str', 'get', 'id', '', 'idempotency_key', '_profile_import_keys'
        pass

    def _forget_profile_import(self, import_id: 'str') -> 'None':
        # [PyArmor BCC constants]: '_profile_imports', 'pop', 'str', 'get', 'idempotency_key', '', '_profile_import_keys'
        pass

    @staticmethod
    def _profile_import_summary(frozen: 'Mapping[str, Any]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'id', 'import_id', 'kind', 'state', 'total', 'valid', 'invalid', 'str', 'get', '', 'browser', 'preview', 'int', 0
        pass

    def _close_service_worker(self) -> 'None':
        # [PyArmor BCC constants]: '_profile_imports', 'clear', '_profile_import_keys', '_service', 'getattr', 'close', 'callable'
        pass

    @staticmethod
    def _coerce_snapshot(value: 'Any') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'isinstance', 'Mapping', 'get', 'rows', 'stats', 'orders', 'profiles', 'channel_profiles', 'reference_packs', 'publish_attempts', 'schedule_capacities', 'schedule_recurrences', 'schedule_occurrences', 'attention_cases', 'steps_by_order'
        pass

    def _submit_operation(self, name: 'str', work: 'Callable[[], Any]', invalidate_active_state: 'bool' = True) -> 'bool':
        # [PyArmor BCC constants]: '_set_active_state_known', False, 1, '_next_token', '_pending_count', '_pending_names', '_set_busy', True, '_executor', 'submit', 'max', 0, 'pop', '_set_status', 'Automation Center không thể nhận thêm việc: '
        pass

    def _future_done(self, token: 'int', name: 'str', future: 'Future[Any]') -> 'None':
        # [PyArmor BCC constants]: 'result', 'ok', 'data', True, 'error', 'message', False, 'type', '__name__', 'str', 'Exception', '_operationReady', 'emit', 'RuntimeError'
        pass

    def _apply_operation_result(self, token: 'int', name: 'str', payload: 'Any') -> 'None':
        # [PyArmor BCC constants]: 'max', 0, '_pending_count', 1, '_pending_names', 'pop', 'refresh', False, '_refresh_inflight', '_set_busy', '_shutdown_requested', 'isinstance', 'Mapping', 'dict', 'get'
        pass

    def _apply_snapshot(self, value: 'Any') -> 'None':
        # [PyArmor BCC constants]: 'items', 'total', 'limit', 'offset', 'has_more'
        pass

    def _apply_profile_page(self, value: 'Any') -> 'None':
        # [PyArmor BCC constants]: 'isinstance', 'Mapping', 'dict', 'list', 'get', 'items', '_normalise_profile_row', 'view_counts', 'total', 'limit', 'offset', 'has_more', 'query', 'platform', 'status'
        pass

    def _apply_publish_attempt_page(self, value: 'Any') -> 'None':
        # [PyArmor BCC constants]: 'isinstance', 'Mapping', 'dict', 'list', 'get', 'items', '_normalise_publish_attempt_row', 'total', 'limit', 'offset', 'has_more', 'query', 'platform', 'profile_id', 'status'
        pass

    def _apply_schedule_occurrence_page(self, value: 'Any') -> 'None':
        # [PyArmor BCC constants]: 'isinstance', 'Mapping', 'dict', 'list', 'get', 'items', '_normalise_schedule_occurrence_row', 'total', 'limit', 'offset', 'has_more', 'query', 'platform', 'channel_id', 'status'
        pass

    def _apply_attention_page(self, value: 'Any') -> 'None':
        # [PyArmor BCC constants]: 'isinstance', 'Mapping', 'dict', 'list', 'get', 'items', '_normalise_attention_row', 'total', 'limit', 'offset', 'has_more', 'query', 'platform', 'channel_id', 'case_type'
        pass

    def _apply_copilot_stream_event(self, value: 'Any') -> 'None':
        # [PyArmor BCC constants]: 'isinstance', 'Mapping', 'dict', 'str', 'get', 'project_id', '', '_selected_copilot_project_id', '_shutdown_requested', 'phase', 'strip', 'lower', 'started', '_copilot_message_model', 'upsert_row'
        pass

    def _apply_copilot_snapshot(self, value: 'Mapping[str, Any]') -> 'None':
        # [PyArmor BCC constants]: 'list', 'get', 'projects', 'isinstance', 'Mapping', '_normalise_copilot_project_row', 'messages', '_normalise_copilot_message_row', 'content_items', '_normalise_copilot_content_row', 'sources', '_normalise_copilot_source_row', 'selected_project', 'str', 'selected_project_id'
        pass

    def _arm_scheduled_wake(self, value: 'Any') -> 'None':
        # [PyArmor BCC constants]: '_scheduled_wake_timer', 'stop', 'str', '', 'strip', '_shutdown_requested', '_started', 'datetime', 'fromisoformat', 'replace', 'Z', '+00:00', 'tzinfo', 'astimezone', 'UTC'
        pass

    def _on_scheduled_wake(self) -> 'None':
        pass

    def _connect_queue_bridge(self) -> 'None':
        # [PyArmor BCC constants]: '_uses_default_service', '_started', '_queue_bridge_connected', '_queue_push_bridge', 'connect_store', True, '_job_store_connected', 'get_job_store', '_job_store', 'getattr', 'connect', '_relay_job_store_changed', 'Exception'
        pass

    def _on_queue_push(self) -> 'None':
        pass

    def _relay_job_store_changed(self, job: 'object') -> 'None':
        pass

    def _on_job_store_changed(self, job: 'object') -> 'None':
        # [PyArmor BCC constants]: '_started', '_shutdown_requested', 'getattr', 'meta', 'isinstance', 'Mapping', 'dict', 'str', 'get', 'master_prompt_job_id', 'clone_job_id', 'transcript_job_id', 'affiliate_queue_row_id', 'timemachine_job_id', ''
        pass

    def _flush_job_store_refresh(self) -> 'None':
        # [PyArmor BCC constants]: False, '_job_refresh_pending', '_started', '_shutdown_requested', 'refresh'
        pass

    @staticmethod
    def _load_workspace_bridge_types_worker() -> 'tuple[type, type]':
        pass

    def _ensure_workspace_component(self) -> 'None':
        # [PyArmor BCC constants]: '_shutdown_requested', '_workspace', '_component', '_bridge_load_inflight', '_engine', '_set_status', 'Automation Center chưa được gắn vào QML engine', '_bridge_types', True, '_executor', 'submit', '_load_workspace_bridge_types_worker', False, 'Không thể chuẩn bị Automation Center: ', 'RuntimeError'
        pass

    def _relay_workspace_bridge_ready(self, future: 'Future[Any]') -> 'None':
        # [PyArmor BCC constants]: True, 'result', False, 'str', 'Exception', '_workspaceBridgeReady', 'emit', 'RuntimeError'
        pass

    def _on_workspace_bridge_ready(self, payload: 'object') -> 'None':
        # [PyArmor BCC constants]: False, '_bridge_load_inflight', '_shutdown_requested', 'isinstance', 'tuple', '_set_status', 'Không thể chuẩn bị Automation Center: ', '_bridge_types', '_load_workspace_component'
        pass

    def _load_workspace_component(self) -> 'None':
        # [PyArmor BCC constants]: '_shutdown_requested', '_workspace', '_component', '_qml_path', 'is_file', '_set_status', 'Không tìm thấy giao diện VeoFlow OS: ', '_prepare_vendor_qml_context', 'QQmlComponent', '_engine', 'statusChanged', 'connect', '_on_component_status_changed', 'loadUrl', 'QUrl'
        pass

    def _prepare_vendor_qml_context(self) -> 'None':
        # [PyArmor BCC constants]: '_qml_context', '_engine', 'RuntimeError', 'QML engine is not attached', '_bridge_types', 'workspace bridge types are not loaded', '_control_plane', '_appearance_proxy', 'QtQml', 'QQmlContext', 'rootContext', 'setContextProperty', 'controlPlane', 'appearance'
        pass

    def _dispose_qml_context(self) -> 'None':
        # [PyArmor BCC constants]: '_qml_context', 'deleteLater', 'AttributeError', 'RuntimeError'
        pass

    def _on_component_status_changed(self, status: 'Any') -> 'None':
        # [PyArmor BCC constants]: '_component', '_workspace', 'QQmlComponent', 'Status', 'Loading', 'Error', 'errors', 'toString', 'Exception', '; ', 'join', 3, 'QML component error', '_dispose_qml_context', 'deleteLater'
        pass

    def _set_mount_target(self, target: 'QQuickItem | None') -> 'None':
        # [PyArmor BCC constants]: '_mount_target', 'destroyed', 'disconnect', '_on_mount_target_destroyed', 'AttributeError', 'RuntimeError', 'TypeError', 'connect'
        pass

    def _mount_workspace(self) -> 'None':
        # [PyArmor BCC constants]: '_workspace', '_mount_target', 'setParentItem', 'setProperty', 'workspaceActive', '_workspace_active', '_set_status', 'Không thể mount Automation Center: ', 'RuntimeError', '_set_workspace_mounted', True
        pass

    def _apply_requested_route(self) -> 'None':
        # [PyArmor BCC constants]: '_workspace', 'str', '_pending_route', 'today', 'strip', 'lower', 'replace', '-', '_', '_ROUTE_ALIASES', 'get', 'getattr', 'activateRoute', 'callable', 'bool'
        pass

    def _on_workspace_destroyed(self, destroyed_object: 'QObject | None' = None) -> 'None':
        # [PyArmor BCC constants]: '_workspace', 'embeddedWorkspaceChanged', 'emit', '_component', 'deleteLater', 'RuntimeError', '_dispose_qml_context', '_set_workspace_mounted', False
        pass

    def _on_mount_target_destroyed(self, destroyed_object: 'QObject | None' = None) -> 'None':
        # [PyArmor BCC constants]: '_mount_target', '_workspace', 'setParentItem', 'setProperty', 'workspaceActive', False, 'RuntimeError', '_workspace_active', '_set_workspace_mounted'
        pass

    def _sync_dark_mode(self) -> 'None':
        # [PyArmor BCC constants]: 'getattr', '_app_controller', 'darkMode', '_dark_mode', 'callable', 'Exception', '_set_dark_mode', 'bool'
        pass

    def _on_main_window_destroyed(self, destroyed_object: 'QObject | None' = None) -> 'None':
        pass

    def _set_selected_order(self, order_id: 'str') -> 'None':
        # [PyArmor BCC constants]: 'str', '', 'strip', 'dict', '_order_rows_by_id', 'get', '_selected_order_id', '_selected_order', '_step_model', 'setRows', '_steps_by_order', 'selectedOrderChanged', 'emit'
        pass

    def _set_plan_draft(self, value: 'Any') -> 'None':
        # [PyArmor BCC constants]: 'isinstance', 'Mapping', 'dict', '_plan_draft', 'planDraftChanged', 'emit'
        pass

    def _set_busy(self, value: 'bool') -> 'None':
        # [PyArmor BCC constants]: 'bool', '_busy', 'busyChanged', 'emit'
        pass

    def _set_initialized(self, value: 'bool') -> 'None':
        # [PyArmor BCC constants]: 'bool', '_initialized', 'initializedChanged', 'emit'
        pass

    def _set_status(self, value: 'str') -> 'None':
        # [PyArmor BCC constants]: 'str', '', '_status_message', 'statusChanged', 'emit'
        pass

    def _set_dark_mode(self, value: 'bool') -> 'None':
        # [PyArmor BCC constants]: 'bool', '_dark_mode', 'darkModeChanged', 'emit'
        pass

    def _set_workspace_mounted(self, value: 'bool') -> 'None':
        # [PyArmor BCC constants]: 'bool', '_workspace_mounted', 'workspaceMountedChanged', 'emit'
        pass

    def _set_execution(self, value: 'Any') -> 'None':
        # [PyArmor BCC constants]: '_normalise_execution', '_execution', 'executionChanged', 'emit'
        pass

    def _set_active_state_known(self, value: 'bool') -> 'None':
        # [PyArmor BCC constants]: 'bool', '_active_state_known', 'activeStateKnownChanged', 'emit', 'executionChanged'
        pass


# --- Class: HomeController ---
class HomeController(QObject):
    """Expose legacy HomeTab content as a headless QML data/action model."""
    _COMPLETED_STATUSES = frozenset({'done', 'complete', 'completed'})
    _FAILED_STATUSES = frozenset({'error', 'failed'})
    _LIVE_STATUSES = frozenset({'pending', 'processing', 'queued', 'retrying', 'preparing', 'running'})
    staticMetaObject = PySide6.QtCore.QMetaObject("HomeController" inherits "QObject":
Properties:
  #1 "summary", QVariantMap [designable], no...

    summaryChanged = Signal()
    contentChanged = Signal()
    actionsChanged = Signal()
    lifecycleChanged = Signal()
    statusMessageChanged = Signal()
    navigationRequested = Signal()
    externalOpenRequested = Signal()
    _homeContentReady = Signal()
    _summaryDataReady = Signal()
    def __init__(self, timer_factory: 'type[QTimer]' = <class 'PySide6.QtCore.QTimer'>) -> 'None':
        # [PyArmor BCC constants]: 'ok', 'blocked', 'actionId', 'message'
        pass

    def summary(*args, **kwargs):
        pass

    def dashboard(*args, **kwargs):
        pass

    def hero(*args, **kwargs):
        pass

    def heroBadges(*args, **kwargs):
        pass

    def features(*args, **kwargs):
        pass

    def readiness(*args, **kwargs):
        pass

    def quickActions(*args, **kwargs):
        pass

    def blockers(*args, **kwargs):
        pass

    def lastAction(*args, **kwargs):
        pass

    def announcements(*args, **kwargs):
        pass

    def news(*args, **kwargs):
        pass

    def tips(*args, **kwargs):
        pass

    def socialLinks(*args, **kwargs):
        pass

    def promotions(*args, **kwargs):
        pass

    def banners(*args, **kwargs):
        pass

    def tutorials(*args, **kwargs):
        pass

    def statusMessage(*args, **kwargs):
        pass

    def autoRefreshActive(*args, **kwargs):
        pass

    def onShown(self) -> 'None':
        # [PyArmor BCC constants]: '_is_visible', True, '_start_refresh_timers', 'lifecycleChanged', 'emit', '_shown_bg_running', 'threading', 'Thread', 'target', '_on_shown_bg', 'daemon', 'start'
        pass

    def _on_shown_bg(self) -> 'None':
        # [PyArmor BCC constants]: 'DEFAULT_CONTENT', 'get_home_content_service', 'dict', 'get_content', 'Exception', 'get_home_readiness_manifest', 'content', 'readiness', '_homeContentReady', 'emit', False, '_shown_bg_running'
        pass

    def _apply_home_content_payload(self, payload: 'dict') -> 'None':
        # [PyArmor BCC constants]: 'get', 'content', 'readiness', '_server_content', '_normalize_hero', 'hero', '_hero', '_normalize_feature_badges', 'feature_badges', '_feature_badges', '_normalize_hero_badges', '_hero_badges', '_normalize_feed', 'announcements', 'icon'
        pass

    def onHidden(self) -> 'None':
        # [PyArmor BCC constants]: '_is_visible', False, '_stop_refresh_timers', 'lifecycleChanged', 'emit'
        pass

    def refresh(self) -> 'None':
        # [PyArmor BCC constants]: '_refresh_readiness', '_load_content', '_summary_inflight', True, 'ok', 'accounts', 'history', 'headless_jobs', 'master_stats', 'list', 'get_account_service', 'list_accounts', 'include_inactive', 'get_history_service', 'query_runs'
        pass

    def _apply_summary_data(self, data: 'dict[str, Any]') -> 'None':
        pass

    def _build_dashboard(self, history: 'list[dict[str, Any]]', headless_jobs: 'list[dict[str, Any]]', master_queued: 'int') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'jobId', 'title', 'thumbnail', 'route', 'ago'
        pass

    def _build_queue_counts(self, headless_jobs: 'list[dict[str, Any]]', master_queued: 'int') -> 'dict[str, int]':
        # [PyArmor BCC constants]: 'SOURCE_ROUTES', 'str', 'get', 'status', '', 'lower', '_LIVE_STATUSES', 'tab_source', 0, 1, 'master', 'int'
        pass

    @staticmethod
    def _row_timestamp(value: 'Any') -> 'float':
        # [PyArmor BCC constants]: 'isinstance', 'int', 'float', 'str', '', 'strip', 0.0, 'ValueError', 'endswith', 'Z', 'replace', '+00:00', 'datetime', 'fromisoformat', 'timestamp'
        pass

    @staticmethod
    def _format_age(age_seconds: 'float') -> 'str':
        # [PyArmor BCC constants]: 'max', 0, 'int', 3600, 1, 60, 'm', 86400, 'h', 'd'
        pass

    def refreshRuntime(self) -> 'None':
        # [PyArmor BCC constants]: '_summary', 'get_headless_job_store', 'list_jobs', 'limit', 1000, 'get_master_queue_service', 'get_stats', 'int', 'get', 'queued', 'pending', 0, 'Exception', 'masterQueued', 'jobsInMemory'
        pass

    def _license_snapshot(self) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'get_license_manager', 'get_license_info', 'Exception', 'isinstance', 'get', 'data', 'dict', 'credits', 'licenseType', 'licenseExpiresAt', 'freeCredits', 'paidCredits', 'str', 'license_type', 'tier'
        pass

    @staticmethod
    def _format_license_expiry(info: 'dict[str, Any]') -> 'str':
        # [PyArmor BCC constants]: 'str', 'get', 'license_type', 'tier', '', 'upper', 'LIFETIME', '∞', 'expires_at', 'expires', '-', 'isinstance', 'endswith', 'Z', 'replace'
        pass

    def openUrl(self, url: 'str') -> 'None':
        pass

    def triggerCta(self, action: 'str', value: 'str') -> 'None':
        # [PyArmor BCC constants]: 'str', '', 'strip', 'lower', 'route', 'navigationRequested', 'emit', 'dialog', '_set_status', 'Dialog requested: ', '_request_external_url', 'home.cta'
        pass

    def triggerAction(self, action_id: 'str') -> 'None':
        # [PyArmor BCC constants]: 'str', '', 'strip', '_find_action', '_set_action_blocked', 'unknown_home_action', 'Home action is not registered.', 'bool', 'get', 'enabled', True, 'state', 'ready', 'blocked', 'isinstance'
        pass

    def _load_content(self) -> 'None':
        # [PyArmor BCC constants]: 'DEFAULT_CONTENT', 'get_home_content_service', 'dict', 'get_content', 'Exception', '_server_content', '_normalize_hero', 'get', 'hero', '_hero', '_normalize_feature_badges', 'feature_badges', '_feature_badges', '_normalize_hero_badges', '_hero_badges'
        pass

    @staticmethod
    def _normalize_cta(value: 'Any') -> 'dict[str, str]':
        # [PyArmor BCC constants]: 'isinstance', 'dict', 'str', 'get', 'label', 'text', '', 'strip', 'action', 'external_url', 'lower', 'value', 'tone', 'url', 'route'
        pass

    @classmethod
    def _normalize_hero(cls, value: 'Any') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'isinstance', 'dict', 'title', 'subtitle', 'body', 'mediaUrl', 'cta', 'str', 'get', 'VEOFLOW.DEV', 'AI automation workspace', 'description', 'Master Prompt - Clone - Audio To Video - Research - Voice Studio', 'bg_image_url', 'image_url'
        pass

    @classmethod
    def _normalize_promotions(cls, value: 'Any') -> 'list[dict[str, Any]]':
        # [PyArmor BCC constants]: 'isinstance', 'list', 'enumerate', 8, 'dict', 'str', 'get', 'title', '', 'strip', 'append', 'id', 'desc', 'imageUrl', 'badge'
        pass

    @classmethod
    def _normalize_banners(cls, value: 'Any') -> 'list[dict[str, Any]]':
        # [PyArmor BCC constants]: 'isinstance', 'list', 'enumerate', 8, 'dict', 'str', 'get', 'image_url', 'imageUrl', '', 'strip', 'title', '_normalize_cta', 'cta', 'link_url'
        pass

    @classmethod
    def _normalize_tutorials(cls, value: 'Any') -> 'list[dict[str, Any]]':
        # [PyArmor BCC constants]: 'isinstance', 'list', 'enumerate', 100, 'dict', 'str', 'get', 'title', '', 'strip', 'tag', 'youtube_id', 'youtubeId', 'video_id', 'url'
        pass

    @staticmethod
    def _normalize_feature_badges(value: 'Any') -> 'dict[str, dict[str, Any]]':
        # [PyArmor BCC constants]: 'isinstance', 'dict', 'items', 'str', 'get', 'text', '', 'credit', 'lower', 'color', 'enabled', 'icon', '#3B82F6', 'bool', True
        pass

    def _normalize_hero_badges(self) -> 'list[dict[str, str]]':
        # [PyArmor BCC constants]: 'isinstance', '_server_content', 'get', 'hero', 'dict', 'badges', 'list', 4, 'str', 'label', 'text', '', 'strip', 'append', 'icon'
        pass

    @staticmethod
    def _normalize_feed(value: 'Any', fallback: 'list[dict[str, str]]') -> 'list[dict[str, str]]':
        # [PyArmor BCC constants]: 'isinstance', 'list', 8, 'dict', 'append', 'icon', 'text', 'color', 'str', 'get', '*', 'title', '', '#3B82F6'
        pass

    def _normalize_social_links(self, value: 'Any') -> 'list[dict[str, Any]]':
        # [PyArmor BCC constants]: 'icon', 'FB', 'name', 'Facebook', 'url', 'https://www.facebook.com/dev.veoflowtool', 'color', '#1877F2', 'YT', 'YouTube', 'https://www.youtube.com/@veoflowdotdev', '#EF4444', 'WEB', 'VeoFlow', 'https://veoflow.dev'
        pass

    def _refresh_readiness(self) -> 'None':
        # [PyArmor BCC constants]: 'get_home_readiness_manifest', '_readiness', 'surface', 'summary', 'navigationActions', 'quickActions', 'structuredBlockers', 'actionCounts', 'qml_home', 'ready', 0, 'partial', 'blocked', 1, 'code'
        pass

    def _build_features(self) -> 'list[dict[str, Any]]':
        # [PyArmor BCC constants]: '_readiness', 'get', 'navigationActions', 'isinstance', 'dict', '_action_available', 'enabled', '_badge_for_action', 'str', 'text', '', 'badge', 'color', '#3B82F6', 'badgeColor'
        pass

    def _build_quick_actions(self) -> 'list[dict[str, Any]]':
        # [PyArmor BCC constants]: '_readiness', 'get', 'quickActions', 'isinstance', 'dict', '_action_available', 'enabled', 'append'
        pass

    def _action_available(self, action: 'dict[str, Any]') -> 'bool':
        # [PyArmor BCC constants]: 'str', 'get', 'state', 'ready', 'blocked', False, 'capability', '', 'strip', '_GATED_CAPABILITIES', True, 'get_license_manager', 'getattr', 'feature_gate', 'callable'
        pass

    def _badge_for_action(self, action: 'dict[str, Any]') -> 'dict[str, Any] | None':
        # [PyArmor BCC constants]: 'str', 'get', 'capability', '', 'strip', 'route', 'append', 'master', 'master_panel', 'clone', 'clone_panel', 'transcript', 'transcript_panel', 'normal', 'normal_panel'
        pass

    def _find_action(self, action_id: 'str') -> 'dict[str, Any] | None':
        # [PyArmor BCC constants]: '_features', '_quick_actions', '_social_links', 'str', 'get', 'actionId', ''
        pass

    def _request_external_url(self, action_id: 'str', url: 'str') -> 'None':
        # [PyArmor BCC constants]: 'str', '', 'strip', '_set_action_blocked', 'missing_external_url', 'External URL is empty.', 'urlparse', 'scheme', 'https', 'http', 'netloc', 'invalid_external_url', 'Invalid external URL: ', '_is_allowed_external_host', 'external_host_not_allowlisted'
        pass

    @staticmethod
    def _is_allowed_external_host(host: 'str') -> 'bool':
        # [PyArmor BCC constants]: 'veoflow.dev', 'facebook.com', 'youtube.com', 'zalo.me'
        pass

    def _set_action_ok(self, action_id: 'str', message: 'str') -> 'None':
        # [PyArmor BCC constants]: 'ok', 'blocked', 'actionId', 'message', True, False, '_last_action', '_set_status', 'actionsChanged', 'emit'
        pass

    def _set_action_blocked(self, action_id: 'str', blocker: 'str', message: 'str') -> 'None':
        # [PyArmor BCC constants]: 'ok', 'blocked', 'actionId', 'blocker', 'message', False, True, '_last_action', '_set_status', 'Blocked: ', 'actionsChanged', 'emit'
        pass

    def _set_status(self, message: 'str') -> 'None':
        pass

    def _start_refresh_timers(self) -> 'None':
        # [PyArmor BCC constants]: 2, '_remaining_delayed_refreshes', '_arm_delayed_refresh_timer', '_auto_refresh_timer', 'start', '_runtime_refresh_timer', 1, 'autoRefreshStartCount'
        pass

    def _stop_refresh_timers(self) -> 'None':
        # [PyArmor BCC constants]: 0, '_remaining_delayed_refreshes', '_delayed_refresh_timer', 'stop', 1, 'delayedRefreshStopCount', '_auto_refresh_timer', '_runtime_refresh_timer', 'autoRefreshStopCount'
        pass

    def _arm_delayed_refresh_timer(self) -> 'None':
        # [PyArmor BCC constants]: '_is_visible', '_remaining_delayed_refreshes', 0, '_delayed_refresh_timer', 'start', 1, 'delayedRefreshStartCount'
        pass

    def _on_delayed_refresh_timeout(self) -> 'None':
        # [PyArmor BCC constants]: '_remaining_delayed_refreshes', 0, 1, 'refresh', '_arm_delayed_refresh_timer'
        pass


# --- Class: HeaderController ---
class HeaderController(QObject):
    """Expose header status and dialog payloads without importing PyQt UI."""
    staticMetaObject = PySide6.QtCore.QMetaObject("HeaderController" inherits "QObject":
Properties:
  #1 "summary", QVariantMap [designable], ...

    summaryChanged = Signal()
    _summaryReady = Signal()
    dialogChanged = Signal()
    dialogRequested = Signal()
    statusMessageChanged = Signal()
    busyChanged = Signal()
    actionChanged = Signal()
    currentActionChanged = Signal()
    actionProgressValueChanged = Signal()
    actionProgressTextChanged = Signal()
    actionProgressIndeterminateChanged = Signal()
    paymentPollingChanged = Signal()
    featureEntitlementsUpdated = Signal()
    def __init__(self) -> 'None':
        pass

    def summary(*args, **kwargs):
        pass

    def dialog(*args, **kwargs):
        pass

    def licenseStatus(*args, **kwargs):
        pass

    def creditsText(*args, **kwargs):
        pass

    def creditsTooltip(*args, **kwargs):
        pass

    def consumedText(*args, **kwargs):
        pass

    def consumedTooltip(*args, **kwargs):
        pass

    def statusMessage(*args, **kwargs):
        pass

    def browserHealthText(*args, **kwargs):
        pass

    def browserHealthTooltip(*args, **kwargs):
        pass

    def browserHealthTone(*args, **kwargs):
        pass

    def busy(*args, **kwargs):
        pass

    def lastAction(*args, **kwargs):
        pass

    def currentAction(*args, **kwargs):
        pass

    def actionProgressValue(*args, **kwargs):
        pass

    def actionProgressText(*args, **kwargs):
        pass

    def actionProgressIndeterminate(*args, **kwargs):
        pass

    def paymentPolling(*args, **kwargs):
        pass

    def refresh(self) -> 'None':
        # [PyArmor BCC constants]: '_refresh_inflight', True, '_refresh_pending', False, '_service', 'ok', 'summary', 'snapshot', 'error', 'type', '__name__', 'Exception', '_summaryReady', 'emit', 'threading'
        pass

    def _apply_summary(self, payload: 'dict[str, Any]') -> 'None':
        # [PyArmor BCC constants]: False, '_refresh_inflight', 'get', 'ok', 'summary', '_summary', '_set_status', 'Header state refreshed', 'browser_health_text', 'browser_health_tooltip', 'browser_health_tone', 'license_status', 'credits_text', 'error', ''
        pass

    def _on_refresh_tick(self) -> 'None':
        pass

    def _poll_balance(self) -> 'None':
        # [PyArmor BCC constants]: '_balance_poll_worker', 'isRunning', '_BalancePollWorker', 'finishedPayload', 'connect', '_on_balance_polled', 'finished', '_cleanup_balance_worker', 'register', 'start'
        pass

    def _on_balance_polled(self, data: 'dict[str, Any]') -> 'None':
        # [PyArmor BCC constants]: '_service', 'set_live_balance', 'dict', 'Exception', 'refresh'
        pass

    def _cleanup_balance_worker(self) -> 'None':
        # [PyArmor BCC constants]: 'sender', '_balance_poll_worker', 'deleteLater'
        pass

    def openDialog(self, mode: 'str') -> 'None':
        # [PyArmor BCC constants]: 'str', '', 'strip', 'lower', 'media_library', 'styles', 'mode', 'title', '_dialog', '_set_status', ' opened', 'dialogChanged', 'emit', 'dialogRequested', '_service'
        pass

    def openNestedDialog(self, mode: 'str') -> 'None':
        pass

    def openFeaturePurchase(self, route: 'str') -> 'None':
        # [PyArmor BCC constants]: 'str', '', 'strip', 'lower', '_feature_purchase_route', True, '_feature_purchase_active', '_feature_purchase_visible', '_active_payment_data', '_service', 'feature_purchase_dialog', '_commerce_store_data', '_dialog', 'dialogChanged', 'emit'
        pass

    def dismissFeaturePurchase(self) -> 'None':
        # [PyArmor BCC constants]: False, '_feature_purchase_visible', '_busy', '_payment_polling', '_feature_purchase_active', '', '_feature_purchase_route'
        pass

    def executeAction(self, action: 'str', value: 'str' = '') -> 'None':
        # [PyArmor BCC constants]: '_busy', '_set_status', 'Header action already running', 'str', '', '_set_busy', True, '_set_current_action', 'update_check', 'Checking for updates...', 'update_download', 'Downloading update...', 'update_apply', 'Installing update...', 'Header action running: '
        pass

    def buyFeatureDays(self, feature_code: 'str', days: 'int', payment_method: 'str') -> 'None':
        # [PyArmor BCC constants]: 'str', '', 'strip', 'upper', 'max', 1, 'min', 'int', 30, 'BANK_TRANSFER', 'tuple', '_purchase_intent', 'get', 'fingerprint', 'state'
        pass

    def notifyShellReady(self) -> 'None':
        # [PyArmor BCC constants]: '_boot_update_armed', '_boot_update_done', True, 'print', '[AutoUpdate][boot] shell ready, checking in 2.5s', 'QTimer', 'singleShot', 2500, '_auto_update_on_boot_once'
        pass

    def checkAndDownloadUpdate(self) -> 'None':
        # [PyArmor BCC constants]: '_busy', '_set_status', 'Header action already running', 'check', '_auto_update_flow', '_service', 'dialog', 'update', '_commerce_store_data', '_dialog', 'Checking for a newer app build...', 'subtitle', 'dialogChanged', 'emit', 'dialogRequested'
        pass

    def _auto_update_on_boot_once(self) -> 'None':
        # [PyArmor BCC constants]: '_boot_update_done', '_busy', 'QTimer', 'singleShot', 8000, '_auto_update_on_boot_once', True, 'autoUpdateOnBoot'
        pass

    def autoUpdateOnBoot(self) -> 'None':
        # [PyArmor BCC constants]: '_busy', 'print', '[AutoUpdate][boot] version check starting', True, '_silent_update', 'check', '_auto_update_flow', 'executeAction', 'update_check', ''
        pass

    def pollPaymentInfo(self, order_code: 'str') -> 'None':
        # [PyArmor BCC constants]: 'str', '', 'strip', '_set_status', 'Payment status refresh skipped: missing order code', '_payment_poll_worker', 'isRunning', '_set_payment_polling', True, '_PaymentInfoPollWorker', '_commerce_store_data', 'finishedPayload', 'connect', '_on_payment_poll_finished', 'finished'
        pass

    def _on_action_finished(self, action: 'str', result: 'dict[str, Any]') -> 'None':
        # [PyArmor BCC constants]: 'dict', 'setdefault', 'action', 'bool', 'get', 'ok', 'cancelled', 'isinstance', 'data', 'str', 'error', 'reason', '', '_auto_update_flow', 'update_download'
        pass

    def _on_action_progress(self, percent: 'int', status: 'str', indeterminate: 'bool') -> 'None':
        # [PyArmor BCC constants]: 'int', 'str', '', 'bool', 0, 2, '_action_progress_indeterminate', 'time', 'monotonic', '_progress_last_emit', 0.1, '_progress_pending', '_progress_flush_timer', 'isActive', 'start'
        pass

    def _flush_action_progress(self) -> 'None':
        # [PyArmor BCC constants]: '_progress_pending', 'time', 'monotonic', '_progress_last_emit', '_set_action_progress'
        pass

    def _on_payment_poll_finished(self, order_code: 'str', result: 'dict[str, Any]') -> 'None':
        # [PyArmor BCC constants]: '_set_payment_polling', False, 'dict', 'setdefault', 'action', 'commerce_payment_info', 'isinstance', 'get', 'data', 'bool', 'ok', '_current_dialog_order_code', 'str', '_dialog', 'mode'
        pass

    def _cleanup_worker(self) -> 'None':
        # [PyArmor BCC constants]: 'sender', '_worker', 'deleteLater'
        pass

    def _cleanup_payment_poll_worker(self) -> 'None':
        # [PyArmor BCC constants]: 'sender', '_payment_poll_worker', 'deleteLater'
        pass

    def _start_entitlement_refresh(self, feature_code: 'str', order_code: 'str') -> 'None':
        # [PyArmor BCC constants]: '_entitlement_refresh_worker', 'isRunning', '_current_dialog_order_code', 'str', '', '_EntitlementRefreshWorker', 'finishedPayload', 'connect', '_on_entitlement_refresh_finished', 'finished', '_cleanup_entitlement_refresh_worker', 'register', 'start'
        pass

    def _on_entitlement_refresh_finished(self, ok: 'bool', payload: 'dict[str, Any]') -> 'None':
        # [PyArmor BCC constants]: 'dict', 'str', '_active_payment_data', 'get', 'feature_code', '', 'bool', 'feature_active', 0, '_entitlement_refresh_retry_count', 'ready', '_purchase_intent', 'state', 'entitlement_refresh_status', 'featureEntitlementsUpdated'
        pass

    def _cleanup_entitlement_refresh_worker(self) -> 'None':
        # [PyArmor BCC constants]: 'sender', '_entitlement_refresh_worker', 'deleteLater'
        pass

    def cancelCurrentAction(self) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'str', '_current_action', '', 'strip', 'ok', False, 'cancelled', 'action', 'error', 'no_active_header_action', 'message', 'No active header action to cancel.', '_last_action', 'actionChanged', 'emit'
        pass

    def _set_status(self, message: 'str') -> 'None':
        pass

    def _set_busy(self, value: 'bool') -> 'None':
        pass

    def _set_payment_polling(self, value: 'bool') -> 'None':
        # [PyArmor BCC constants]: 'bool', '_payment_polling', 'paymentPollingChanged', 'emit'
        pass

    def _current_dialog_order_code(self) -> 'str':
        # [PyArmor BCC constants]: 'str', '_dialog', 'get', 'mode', '', 'feature_purchase', 'payment', 'isinstance', 'dict', 'order_code', 'code', 'strip', 'sections', 'list', 'rows'
        pass

    def _set_current_action(self, action: 'str') -> 'None':
        # [PyArmor BCC constants]: 'str', '', '_current_action', 'currentActionChanged', 'emit'
        pass

    def _set_action_progress(self, value: 'int', text: 'str', indeterminate: 'bool') -> 'None':
        # [PyArmor BCC constants]: 'max', 0, 'min', 'int', 100, 'str', '', 'bool', '_action_progress_value', 'actionProgressValueChanged', 'emit', '_action_progress_text', 'actionProgressTextChanged', '_action_progress_indeterminate', 'actionProgressIndeterminateChanged'
        pass


# --- Class: HistoryController ---
class HistoryController(QObject):
    staticMetaObject = PySide6.QtCore.QMetaObject("HistoryController" inherits "QObject":
Properties:
  #1 "runsModel", QObject* [constant] [de...

    filtersChanged = Signal()
    loadingChanged = Signal()
    statsChanged = Signal()
    selectedRunIdChanged = Signal()
    selectedDetailChanged = Signal()
    statusMessageChanged = Signal()
    actionResult = Signal()
    openTargetRequested = Signal()
    _listPayload = Signal()
    _detailPayload = Signal()
    _actionPayload = Signal()
    _storeChanged = Signal()
    def __init__(self, service: 'HistoryService | None' = None) -> 'None':
        pass

    def _get_service(self) -> 'HistoryService':
        # [PyArmor BCC constants]: '_service', '_service_lock', 'get_history_service'
        pass

    def runsModel(*args, **kwargs):
        pass

    def itemsModel(*args, **kwargs):
        pass

    def sources(*args, **kwargs):
        pass

    def stateFilters(*args, **kwargs):
        pass

    def source(*args, **kwargs):
        pass

    def state(*args, **kwargs):
        pass

    def search(*args, **kwargs):
        pass

    def stats(*args, **kwargs):
        pass

    def listLoading(*args, **kwargs):
        pass

    def detailLoading(*args, **kwargs):
        pass

    def actionLoading(*args, **kwargs):
        pass

    def actionsLocked(*args, **kwargs):
        pass

    def canLoadMore(*args, **kwargs):
        pass

    def selectedRunId(*args, **kwargs):
        pass

    def selectedDetail(*args, **kwargs):
        pass

    def statusMessage(*args, **kwargs):
        pass

    def _set_status(self, value: 'str') -> 'None':
        # [PyArmor BCC constants]: 'str', '', '_status_message', 'statusMessageChanged', 'emit'
        pass

    def setActive(self, active: 'bool') -> 'None':
        # [PyArmor BCC constants]: 'bool', '_active', '_connect_store_listener', '_runs_model', 'rows', 'refresh'
        pass

    def _connect_store_listener(self) -> 'None':
        # [PyArmor BCC constants]: '_store_listener', '_get_service', 'store', '_storeChanged', 'emit', 'str', '', 'add_listener', 'Exception'
        pass

    def setSource(self, value: 'str') -> 'None':
        # [PyArmor BCC constants]: 'str', 'all', 'SOURCE_FILTERS', 'key', '_source', 'filtersChanged', 'emit', 'refresh'
        pass

    def setState(self, value: 'str') -> 'None':
        # [PyArmor BCC constants]: 'str', 'all', 'STATE_FILTERS', 'key', '_state', 'filtersChanged', 'emit', 'refresh'
        pass

    def setSearch(self, value: 'str') -> 'None':
        # [PyArmor BCC constants]: 'str', '', 'strip', '_search', 'filtersChanged', 'emit', 'refresh'
        pass

    def _request(self, cursor: 'str' = '') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'source', 'state', 'search', 'cursor', 'pageSize', '_source', '_state', '_search', 50
        pass

    def refresh(self) -> 'None':
        # [PyArmor BCC constants]: '_active', '_list_loading', True, '_refresh_pending', False, 1, '_list_token', '_request', 'loadingChanged', 'emit', '_get_service', 'query_runs', 'ok', 'token', 'append'
        pass

    def loadMore(self) -> 'None':
        # [PyArmor BCC constants]: 'canLoadMore', '_list_token', '_request', '_next_cursor', True, '_list_loading', 'loadingChanged', 'emit', '_get_service', 'query_runs', 'ok', 'token', 'append', 'error', False
        pass

    def _apply_list_payload(self, payload: 'dict[str, Any]') -> 'None':
        # [PyArmor BCC constants]: 'int', 'get', 'token', 1, '_list_token', False, '_list_loading', 'ok', 'list', 'rows', 'append', '_runs_model', 'appendRows', 'setRows', 'dict'
        pass

    def selectRun(self, run_id: 'str') -> 'None':
        # [PyArmor BCC constants]: 'str', '', 1, '_detail_token', '_selected_run_id', '_selected_detail', '_items_model', 'setRows', 'bool', '_detail_loading', 'selectedRunIdChanged', 'emit', 'selectedDetailChanged', 'loadingChanged', '_get_service'
        pass

    def _apply_detail_payload(self, payload: 'dict[str, Any]') -> 'None':
        # [PyArmor BCC constants]: 'int', 'get', 'token', 1, '_detail_token', 'str', 'runId', '', '_selected_run_id', False, '_detail_loading', 'ok', 'dict', 'detail', '_selected_detail'
        pass

    def _target_for(self, action: 'str') -> 'tuple[str, str]':
        # [PyArmor BCC constants]: 'dict', '_selected_detail', 'get', 'actionTargets', 'open_output', 'open_video', 'str', 'outputKind', '', 'output', 'path', 'openable_target', 'open_folder', 'folderKind', 'folder'
        pass

    def _target_for_item(self, item_id: 'str', action: 'str') -> 'tuple[str, str]':
        # [PyArmor BCC constants]: 'open_output', 'list', '_selected_detail', 'get', 'items', 'str', 'itemId', '', 'openKind', 'openTarget', 'path', 'openable_target', 'output', 'thumbnail'
        pass

    def _emit_open_target(self, kind: 'str', target: 'str', *, missing: 'str') -> 'bool':
        # [PyArmor BCC constants]: 'str', '', 'strip', '_set_status', False, 'openable_target', 'openTargetRequested', 'emit', 'path', 'Đang mở…', True
        pass

    def executeAction(self, action_id: 'str') -> 'None':
        # [PyArmor BCC constants]: 'str', '', 'strip', 'actionsLocked', '_target_for', 'open_output', 'open_video', '_emit_open_target', 'missing', 'Chưa có file output trên máy.', 'open_folder', 'Chưa có thư mục output.', 'delete_permanently', 'retry_failed', 'archive'
        pass

    def executeItemAction(self, item_id: 'str', action_id: 'str') -> 'None':
        # [PyArmor BCC constants]: 'str', '', 'strip', 'actionsLocked', '_target_for_item', 'open_output', '_emit_open_target', 'missing', 'Job con này chưa có file output.', 'recreate_item', '_set_status', 'Action job con không được hỗ trợ.', '_selected_run_id', True, '_action_loading'
        pass

    def openArtifact(self, target: 'str') -> 'None':
        # [PyArmor BCC constants]: 'str', '', 'strip', 'openable_target', '_set_status', 'Không mở được file này.', 'openTargetRequested', 'emit', 'path'
        pass

    def _apply_action_payload(self, payload: 'dict[str, Any]') -> 'None':
        # [PyArmor BCC constants]: False, '_action_loading', 'loadingChanged', 'emit', 'dict', 'get', 'result', 'actionResult', 'ok', '_set_status', 'str', 'error', 'Action thất bại', 'action', ''
        pass

    def _on_store_changed(self, run_id: 'str') -> 'None':
        # [PyArmor BCC constants]: '_active', '_refresh_debounce', 'start', '_selected_run_id', '_detail_loading', 'selectRun'
        pass

    def shutdown(self) -> 'None':
        # [PyArmor BCC constants]: '_store_listener', '_get_service', 'store', 'remove_listener', 'Exception'
        pass


# --- Class: I18nController ---
class I18nController(QObject):
    """Expose existing JSON translations to QML without duplicating locale files."""
    staticMetaObject = PySide6.QtCore.QMetaObject("I18nController" inherits "QObject":
Properties:
  #1 "locale", QString [designable], notify=...

    localeChanged = Signal()
    revisionChanged = Signal()
    def __init__(self, default_locale: 'str' = 'vi') -> 'None':
        pass

    def locale(*args, **kwargs):
        pass

    def revision(*args, **kwargs):
        pass

    def t(self, key: 'str', fallback: 'str' = '') -> 'str':
        # [PyArmor BCC constants]: 'tr', 'replace', '&&', '&'
        pass

    def availableLocales(self) -> 'list[str]':
        pass

    def setLocale(self, locale: 'str') -> 'None':
        # [PyArmor BCC constants]: 'get_language', 'set_language', 1, '_revision', 'localeChanged', 'emit', 'revisionChanged'
        pass


# --- Class: MasterController ---
class MasterController(QObject):
    """
    QML adapter for Master queue state.
    
        This is intentionally thin. Long-running generation must stay in the
        backend/application layer, not in this QObject.
    """
    staticMetaObject = PySide6.QtCore.QMetaObject("MasterController" inherits "QObject":
Properties:
  #1 "queueRows", QVariantList [designable...

    queueRowsChanged = Signal()
    statsChanged = Signal()
    statusMessageChanged = Signal()
    actionResultChanged = Signal()
    authPauseRequiredChanged = Signal()
    openPathRequested = Signal()
    parsedIdeasReady = Signal()
    def __init__(self) -> 'None':
        # [PyArmor BCC constants]: 'tab_sources', 'light_getter', 'projection', 'full_loader', 'filter_fn', 'store', 'parent'
        pass

    def queueRows(*args, **kwargs):
        pass

    def jobPanelRows(*args, **kwargs):
        pass

    def jobPanelModel(*args, **kwargs):
        pass

    def jobPanelRow(self, jobId: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_job_panel_model', 'row_by_id', 'str', '', '_job_panel_rows', 'isinstance', 'dict', 'get', 'id', 'row_id', 'job_id', 'batch_id'
        pass

    def stats(*args, **kwargs):
        pass

    def authPauseRequired(*args, **kwargs):
        pass

    def statusMessage(*args, **kwargs):
        pass

    def lastAction(*args, **kwargs):
        pass

    def actionStatus(*args, **kwargs):
        pass

    def refresh(self) -> 'None':
        # [PyArmor BCC constants]: '_refresh_state', 'status_message', 'Ready', 'force', False
        pass

    def _on_queue_push(self) -> 'None':
        # [PyArmor BCC constants]: False, '_queue_dirty', True, '_suppress_jobstore_refresh', '_refresh_queue_and_completion'
        pass

    def _light_master_job(self, job_id: 'str') -> 'dict[str, Any] | None':
        # [PyArmor BCC constants]: '_job_store', 'get_job', '_job_to_light_dict'
        pass

    def _row_passes_master_filter(self, row: 'dict[str, Any]') -> 'bool':
        # [PyArmor BCC constants]: 'str', '_master_resolved_job_id', '', 'strip', True, '_master_job_panel_parent_id'
        pass

    def _resolve_master_job_panel_filter(self, rows: 'list[dict[str, Any]]') -> 'str':
        pass

    def _sync_job_panel_rows_cache(self) -> 'None':
        # [PyArmor BCC constants]: 'rows_signature', '_feed', 'model', 'raw_rows', 'with_progress', False, '_emit_gate', 'changed', 'jobpanel', 'rows', '_job_panel_rows', 'queueRowsChanged', 'emit'
        pass

    def _refresh_state(self, status_message: 'str | None' = None, *, force: 'bool' = True) -> 'None':
        # [PyArmor BCC constants]: 'jank_mark', 'master._refresh_state', '_refresh_state_impl', 'force'
        pass

    def _refresh_state_impl(self, status_message: 'str | None' = None, *, force: 'bool' = True) -> 'None':
        # [PyArmor BCC constants]: '_queue_dirty', False, '_service', 'list_queue', 'list', 'get', 'queue', '_queue_rows', 'dict', 'get_stats', '_stats', '_master_auth_pause_required', '_set_master_auth_pause', '_set_status', 'total'
        pass

    def _job_to_panel_row(self, job: 'Any') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'isinstance', 'dict', 'getattr', 'status', '', 'job_id', 'title', 'prompt', 'progress', 'error_message', 'video_path', 'upscaled_path', 'thumbnail_url', 'thumbnail_path', 'output_path'
        pass

    def _master_job_panel_parent_id(self, row: 'dict[str, Any]') -> 'str':
        # [PyArmor BCC constants]: 'dict', 'get', 'meta', 'str', 'master_prompt_job_id', '', 'strip'
        pass

    def _remove_master_scene_jobs_for_parent_ids(self, row_ids: 'list[str]') -> 'int':
        # [PyArmor BCC constants]: 'list', 'str', '', 'strip', 0, '_job_store', 'list_jobs', 'getattr', 'meta', 'isinstance', 'dict', 'get', 'tab_source', 'master_prompt', 'master_prompt_job_id'
        pass

    def _load_job_panel_rows(self) -> 'list[dict[str, Any]]':
        # [PyArmor BCC constants]: '_job_store', 'list_jobs', 'getattr', 'meta', 'isinstance', 'dict', 'str', 'get', 'tab_source', '', 'strip', 'master_prompt', 'append', '_job_to_panel_row', '_job_to_light_dict'
        pass

    def _has_active_master_queue(self) -> 'bool':
        # [PyArmor BCC constants]: 'list', '_queue_rows', 'str', 'get', 'status', 'status_label', 'job_status', '', 'strip', 'lower', 'polling', 'running', 'generating', 'processing', 'upscaling'
        pass

    def _set_master_auth_pause(self, required: 'bool') -> 'None':
        # [PyArmor BCC constants]: 'bool', '_master_auth_pause_required', 'authPauseRequiredChanged', 'emit'
        pass

    def _connect_runtime_status_signals(self) -> 'None':
        # [PyArmor BCC constants]: '_master_runtime_signals_connected', 'get_instant_upscale_manager', 'prompt_status_updated', 'connect', '_on_runtime_prompt_status', 'Exception', '_job_store', 'job_changed', '_on_jobstore_job_changed', True
        pass

    def _on_runtime_prompt_status(self, prompt_data: 'object', status_msg: 'str') -> 'None':
        # [PyArmor BCC constants]: 'isinstance', 'dict', 'str', 'get', 'feature', '', 'strip', 'lower', 'auth_error', '_has_active_master_queue', 'account_email', 'Unknown', 'Master queue paused: auth expired for ', '_set_master_auth_pause', True
        pass

    def _on_jobstore_job_changed(self, job: 'object') -> 'None':
        # [PyArmor BCC constants]: '_suppress_jobstore_refresh', 'getattr', 'status', '', 'str', 'value', 'strip', 'lower', 'meta', 'isinstance', 'dict', 'get', 'master_prompt_job_id', 'Exception', 'job_id'
        pass

    def _refresh_queue_and_completion(self) -> 'None':
        # [PyArmor BCC constants]: '_service', 'list_queue', 'list', 'get', 'queue', '_queue_rows', 'dict', 'get_stats', '_stats', '_master_auth_pause_required', '_set_master_auth_pause', False, 'Exception', '_emit_gate', 'changed'
        pass

    def _maybe_auto_start_next_master_job(self) -> 'None':
        """
        Chain queued Master rows: when the running batch finishes and rows are
                still PENDING, auto-start the next one so the user only clicks Start once
                and the queue runs sequentially. Mirrors the clone auto-next pattern
                (clone.py:_maybe_auto_start_next_clone_job) — dedup signature plus
                no-running / has-pending / has-completed guards. A FAILED-only state does
                not advance (no completed row), and the signature bounds any failed-row
                retry to a single attempt so we never loop on a persistent failure.
        """
        # [PyArmor BCC constants]: 'row', 'dict[str, Any]', 'return', 'str'
        pass

    def currentConfig(self) -> 'dict[str, Any]':
        pass

    def _queue_config_snapshot(self) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'dict', '_options_service', 'get_config', 'getattr', 'enrich_runtime_config', 'callable'
        pass

    def _submission_config_snapshot(self, extra_text: 'str' = '', save_ai_characters: 'bool' = False) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_queue_config_snapshot', 'str', '', 'strip', 'additional_instructions', 'bool', 'save_ai_characters'
        pass

    def _library_scope_blocker(self, config: 'dict[str, Any]') -> 'dict[str, Any] | None':
        # [PyArmor BCC constants]: 'master_library_scope_block_message', 'ok', 'action', 'code', 'error', 'message', False, 'master.queue.add_to_queue', 'library_scope_no_assets', '_set_status'
        pass

    def _normalize_bulk_input_items(self, items: 'list[Any]') -> 'list[dict[str, Any]]':
        # [PyArmor BCC constants]: 'list', 'parse_prompt_duration_marker', 'str', '', 'strip', 'get', 'prompt', 'duration_seconds', 'append', 'marker', 'int', 0, 'format_duration_marker'
        pass

    def parseIdeasPreview(self, raw_text: 'str') -> 'dict':
        # [PyArmor BCC constants]: 'parse_bulk_items', 'ok', 'items', 'count', True, 'len', 'error', False, 'str', 0, 'Exception'
        pass

    def addIdeas(self, raw_text: 'str') -> 'None':
        # [PyArmor BCC constants]: 'parse_bulk_items', '_set_status', 'No idea text to add', '_service', 'add_to_queue', 'config', 'ideas', '_queue_config_snapshot', '_refresh_state', 'Added ', 'get', 'count', 'len', ' idea(s)'
        pass

    def attachStatusController(self, controller: 'Any') -> 'None':
        pass

    def _account_run_blocker(self, action: 'str') -> 'dict[str, Any] | None':
        # [PyArmor BCC constants]: 'run_blocker', 'feature_blocker', 'alert_payload', 'getattr', '_status_controller', 'hasattr', 'publishRuntimeAlert', True, 'alerted', 'Exception', '_set_action_result', 'master_panel'
        pass

    def addInput(self, raw_text: 'str', input_mode: 'str', extra_text: 'str' = '', save_ai_characters: 'bool' = False) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_account_run_blocker', 'master.queue.add_to_queue', 'str', '', 'strip', 'idea', 'lower', 'ok', False, 'action', 'code', 'empty_master_input', 'error', 'message', 'No Master input text to add'
        pass

    def addInputItems(self, items: 'list[Any]', input_mode: 'str', extra_text: 'str' = '', save_ai_characters: 'bool' = False) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_normalize_bulk_input_items', 'str', 'idea', 'strip', 'lower', '', 'ok', False, 'action', 'master.queue.add_to_queue', 'code', 'empty_master_input', 'error', 'message', 'No Master input text to add'
        pass

    def startQueue(self) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_account_run_blocker', 'master.queue.start_processing', '_set_master_auth_pause', False, '_service', 'start_queue', 'config', 'allow_headless_execution', '_queue_config_snapshot', True, '_track_master_queue_start', '_refresh_state', '_set_action_result', 'success_message', 'Queue start requested: '
        pass

    def _track_master_queue_start(self, result: 'dict[str, Any]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'bool', 'get', 'ok', 'dict', 'str', 'batch_id', 'running_batch_id', '', 'strip', '_master_job_id_filter'
        pass

    def pauseQueue(self) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'list', '_queue_rows', 'str', 'get', 'status', '', 'strip', 'lower', 'running', 'row_id', 'id', 'batch_id', '_service', 'pause_queue', 'ok'
        pass

    def _live_auto_clear_completed(self) -> 'bool':
        # [PyArmor BCC constants]: 'dict', '_options_service', 'get_config', 'auto_clear_completed', True, 'bool', 'get', 'Exception'
        pass

    def pruneOlderCompleted(self) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '', 'list', '_queue_rows', 'str', 'get', 'status', 'strip', 'lower', 'row_id', 'id', 'batch_id', 'done', 'complete', 'completed', '_service'
        pass

    def clearQueue(self) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'list', '_queue_rows', 'str', 'get', 'row_id', 'id', 'batch_id', '', 'strip', '_service', 'clear_queue', 'ok', '_set_master_auth_pause', False, '_remove_master_scene_jobs_for_parent_ids'
        pass

    def removeRow(self, row_id: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'str', '', 'strip', 'list', '_queue_rows', 'get', 'row_id', 'id', 'batch_id', '_service', 'remove_row', 'ok', '_set_master_auth_pause', False, '_remove_master_scene_jobs_for_parent_ids'
        pass

    def approveScript(self, row_id: 'str', script_text: 'str') -> 'dict[str, Any]':
        pass

    def approveScriptWithData(self, row_id: 'str', script_text: 'str', script_data: 'Any' = None) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'ok', False, 'action', 'master.script_approve', 'code', 'row_id_required', 'error', 'message', 'Missing row id', '_set_status', 'prompt', 'name', 'reviewed_script', 'Reviewed Script', True
        pass

    def rewriteScript(self, row_id: 'str', instruction: 'str') -> 'None':
        pass

    def updateRow(self, row_id: 'str', title: 'str', prompt: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'ok', False, 'error', 'missing_row_id', 'message', 'Missing row id', '_set_status', '_service', 'update_row', 'name', 'prompt', 'str', '', 'strip', 'Master Prompt'
        pass

    def updateRowTitle(self, row_id: 'str', title: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'ok', False, 'action', 'master.queue.update_row_title', 'code', 'row_id_required', 'error', 'message', 'Missing row id', '_set_status', '_service', 'update_row_title', '_refresh_state', '_set_action_result', 'success_message'
        pass

    def getSceneEditPayload(self, job_id: 'str', scene_id: 'str' = '', row_id: 'str' = '') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_service', 'get_scene_edit_payload', 'scene_id', 'row_id', '_set_action_result', 'success_message', 'Master scene prompt loaded', 'failure_message', 'str', 'get', 'error', 'Could not load the scene prompt'
        pass

    def updateScenePrompt(self, job_id: 'str', prompt: 'str', scene_id: 'str' = '', row_id: 'str' = '') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_service', 'update_scene_prompt', 'scene_id', 'row_id', '_refresh_state', '_set_action_result', 'success_message', 'Master scene prompt updated', 'failure_message', 'str', 'get', 'error', 'Could not update the scene prompt'
        pass

    def regenSceneJob(self, job_id: 'str', scene_id: 'str' = '', row_id: 'str' = '') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_service', 'regen_scene_job', 'scene_id', 'row_id', '_refresh_state', '_set_action_result', 'success_message', 'Master scene regeneration requested', 'failure_message', 'str', 'get', 'error', 'Could not regenerate the scene'
        pass

    def deleteSceneJob(self, job_id: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_service', 'delete_scene_job', '_refresh_state', '_set_action_result', 'success_message', 'Master scene job deleted', 'failure_message', 'str', 'get', 'error', 'Could not delete the scene'
        pass

    def clearJobPanelCompleted(self) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'get_dispatcher', 0, 'list', '_job_store', 'list_jobs', 'getattr', 'meta', 'isinstance', 'dict', 'str', 'get', 'tab_source', '', 'strip', 'master_prompt'
        pass

    def resumeQueueAfterAuthUpdate(self) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'get_dispatcher', 'get_account_service', 'list_accounts', 'include_inactive', True, 'list', 'str', 'get', 'status', '', 'strip', 'Live', 'bool', 'enabled', 'has_credentials'
        pass

    def applyJobPanelBatchActions(self, payload: 'dict[str, Any]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'dict', 'isinstance', 'get', 'job_ids', 'list', 'str', '', 'strip', 'ok', False, 'action', 'master.job_panel.batch_actions.apply', 'code', 'no_job_panel_jobs_selected', 'error'
        pass

    def setJobPanelReview(self, job_id: 'str', status: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'set_job_panel_review', '_job_store', 'expected_tab_sources', 'master_prompt'
        pass

    def openJobOutput(self, job_id: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'ok', 'action', 'code', 'error', 'message'
        pass

    def retryRow(self, row_id: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'ok', False, 'action', 'master.queue.retry_row', 'code', 'row_id_required', 'error', 'message', 'Missing row id', '_set_status', '_service', 'retry_row', '_refresh_state', '_set_action_result', 'success_message'
        pass

    def updateRowTechnique(self, row_id: 'str', technique_id: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'ok', False, 'action', 'master.queue.update_row_technique', 'code', 'row_id_required', 'error', 'message', 'Missing row id', '_set_status', '_service', 'update_row_technique', '_refresh_state', '_set_action_result', 'success_message'
        pass

    def updateRowMaterial(self, row_id: 'str', material_id: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'ok', False, 'action', 'master.queue.update_row_material', 'code', 'row_id_required', 'error', 'message', 'Missing row id', '_set_status', '_service', 'update_row_material', '_refresh_state', '_set_action_result', 'success_message'
        pass

    def updateRowDuration(self, row_id: 'str', duration_seconds: 'int') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'ok', False, 'action', 'master.queue.update_row_duration', 'code', 'row_id_required', 'error', 'message', 'Missing row id', '_set_status', '_service', 'update_row_duration', '_refresh_state', '_set_action_result', 'success_message'
        pass

    def updateRowLanguage(self, row_id: 'str', language_code: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'ok', False, 'action', 'master.queue.update_row_language', 'code', 'row_id_required', 'error', 'message', 'Missing row id', '_set_status', '_service', 'update_row_language', '_refresh_state', '_set_action_result', 'success_message'
        pass

    def updateRowConfig(self, row_id: 'str', field: 'str', value) -> 'dict':
        # [PyArmor BCC constants]: 'title', 'technique', 'material', 'duration', 'language', 'aspect_ratio', 'idea', 'prompt', 'get', 'ok', True, 'error', 'row_id', 'field', False
        pass

    def updateRowAspect(self, row_id: 'str', aspect_ratio: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'ok', False, 'action', 'master.queue.update_row_aspect', 'code', 'row_id_required', 'error', 'message', 'Missing row id', '_set_status', '_service', 'update_row_aspect', '_refresh_state', '_set_action_result', 'success_message'
        pass

    def retryChargenPolicy(self, row_id: 'str', edited_characters: 'list[Any]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'ok', False, 'action', 'master.queue.retry_chargen_policy', 'code', 'row_id_required', 'error', 'message', 'Missing row id', '_set_status', '_service', 'retry_chargen_policy', 'list', '_refresh_state', '_set_action_result'
        pass

    def skipChargenPolicy(self, row_id: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'ok', False, 'action', 'master.queue.skip_chargen_policy', 'code', 'row_id_required', 'error', 'message', 'Missing row id', '_set_status', '_service', 'skip_chargen_policy', '_refresh_state', '_set_action_result', 'success_message'
        pass

    def recreateRow(self, row_id: 'str', aspect_ratio: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'ok', False, 'action', 'master.queue.recreate_row', 'code', 'row_id_required', 'error', 'message', 'Missing row id', '_set_status', '_service', 'recreate_row', '_set_action_result', 'success_message', 'Recreate requested for aspect '
        pass

    def regenScenes(self, row_id: 'str', scene_ids: 'list[str]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'ok', False, 'action', 'master.queue.regen_scenes', 'code', 'row_id_required', 'error', 'message', 'Missing row id', '_set_status', '_service', 'regen_scenes', '_set_action_result', 'success_message', 'Regen-scenes requested for '
        pass

    def openFolder(self, row_id: 'str', configured_folder: 'str' = '') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_service', 'resolve_output_folder', 'get', 'ok', 'path', 'openPathRequested', 'emit', 'str', '_set_action_result', 'success_message', 'message', 'Opening output folder'
        pass

    def inspectRowAsset(self, row_id: 'str', index: 'int') -> 'None':
        # [PyArmor BCC constants]: 'getRowAssetPreview', 'str', 'get', 'title', 'slot_label', 'asset', 'ok', 'can_reupscale', 're-upscale dry-run ready', 'preview only', '_set_status', 'Asset slot ', 'int', 1, ': '
        pass

    def replaceRowAsset(self, row_id: 'str', slot_index: 'int', media_id: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_service', 'replace_row_asset', 'str', '', 'int', 'isinstance', 'dict', 'get', 'ok', '_refresh_state', '_set_action_result'
        pass

    def getRowAssetPreview(self, row_id: 'str', index: 'int') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'ok', 'row_id', 'slot_index', 'slot_label', 'blocker', 'warnings'
        pass

    def markBlocked(self, action: 'str') -> 'None':
        pass

    def _set_action_result(self, result: 'dict[str, Any]', *, success_message: 'str' = '', failure_message: 'str' = '') -> 'None':
        # [PyArmor BCC constants]: 'isinstance', 'get', 'blocker', 'dict', 'bool', 'ok', False, 'str', 'code', 'error', '', 'message', 'Action completed', 'action', 'blocked'
        pass

    def _connect_master_auto_merge_service(self) -> 'None':
        # [PyArmor BCC constants]: '_master_auto_merge_service_connected', '_try_get_auto_merge_service', 'merge_completed', 'connect', '_on_master_auto_merge_completed', 'Exception', True
        pass

    def _on_master_auto_merge_completed(self, output_folder: 'str', source_tab: 'str', success: 'bool', output_path: 'str', error: 'str') -> 'None':
        # [PyArmor BCC constants]: 'str', '', 'strip', 'lower', 'master_prompt', '_refresh_state', '_set_status', 'Master auto-merge completed: ', 'Master auto-merge failed: '
        pass

    def _set_status(self, message: 'str') -> 'None':
        pass


# --- Class: MasterOptionsController ---
class MasterOptionsController(QObject):
    """Expose persisted Master config and option lists to QML."""
    staticMetaObject = PySide6.QtCore.QMetaObject("MasterOptionsController" inherits "QObject":
Properties:
  #1 "config", QVariantMap [designa...

    configChanged = Signal()
    sharedAutoMergeChanged = Signal()
    optionsChanged = Signal()
    stylesChanged = Signal()
    drawStyleHandBindingsChanged = Signal()
    drawStyleMotionProfilesChanged = Signal()
    _drawBindingsLoaded = Signal()
    _drawBindingsSaved = Signal()
    _optionsDataReady = Signal()
    _styleAiDone = Signal()
    _styleAiPhaseSet = Signal()
    _styleTopicGenDone = Signal()
    _styleTopicProposeDone = Signal()
    _stylePreviewDone = Signal()
    _drawMotionPreviewDone = Signal()
    statusMessageChanged = Signal()
    actionResultChanged = Signal()
    styleAiBusyChanged = Signal()
    styleAiPhaseChanged = Signal()
    styleAiGenerated = Signal()
    styleTopicBusyChanged = Signal()
    styleTopicGenerated = Signal()
    styleTopicProposed = Signal()
    stylePreviewBusyChanged = Signal()
    stylePreviewGenerated = Signal()
    drawMotionPreviewBusyChanged = Signal()
    drawMotionPreviewGenerated = Signal()
    pendingDialogChanged = Signal()
    ideaTextChanged = Signal()
    scriptTextChanged = Signal()
    extraRequirementsTextChanged = Signal()
    _modelsUpdatedSignal = Signal()
    def __init__(self) -> 'None':
        # [PyArmor BCC constants]: 'ok', 'blocked', 'action', 'code', 'message', 'blocker'
        pass

    def _on_models_updated(self) -> 'None':
        pass

    def config(*args, **kwargs):
        pass

    def options(*args, **kwargs):
        pass

    def styles(*args, **kwargs):
        pass

    def drawStyleHandBindings(*args, **kwargs):
        pass

    def drawStyleMotionProfiles(*args, **kwargs):
        pass

    def drawMotionHandOptions(*args, **kwargs):
        pass

    def statusMessage(*args, **kwargs):
        pass

    def lastAction(*args, **kwargs):
        pass

    def actionStatus(*args, **kwargs):
        pass

    def styleAiBusy(*args, **kwargs):
        pass

    def styleAiPhase(*args, **kwargs):
        pass

    def styleTopicBusy(*args, **kwargs):
        pass

    def stylePreviewBusy(*args, **kwargs):
        pass

    def drawMotionPreviewBusy(*args, **kwargs):
        pass

    def pendingDialog(*args, **kwargs):
        pass

    def ideaText(*args, **kwargs):
        pass

    def extraRequirementsText(*args, **kwargs):
        pass

    def setIdeaText(self, text: 'str') -> 'None':
        # [PyArmor BCC constants]: 'str', '', '_idea_text', '_settings', 'set_setting', '_MASTER_WORKSPACE_KEY', 'idea_text', 'ideaTextChanged', 'emit'
        pass

    def scriptText(*args, **kwargs):
        pass

    def setScriptText(self, text: 'str') -> 'None':
        # [PyArmor BCC constants]: 'str', '', '_script_text', '_settings', 'set_setting', '_MASTER_WORKSPACE_KEY', 'script_text', 'scriptTextChanged', 'emit'
        pass

    def setExtraRequirementsText(self, text: 'str') -> 'None':
        # [PyArmor BCC constants]: 'str', '', '_extra_requirements_text', '_settings', 'set_setting', '_MASTER_WORKSPACE_KEY', 'extra_requirements_text', 'extraRequirementsTextChanged', 'emit'
        pass

    def refresh(self) -> 'None':
        # [PyArmor BCC constants]: '_refresh_inflight', True, '_config_revision', '_service', 'get_config', 'get_options', 'list', 'list_styles', 'get', 'styles', 'ok', 'config', 'options', 'config_revision', 'error'
        pass

    def _apply_options_data(self, payload: 'dict[str, Any]') -> 'None':
        # [PyArmor BCC constants]: False, '_refresh_inflight', 'get', 'ok', 'config', 'options', 'list', 'styles', '_set_status', 'Master config loaded', 'Master config failed: ', 'error', 'Error', 'int', 'config_revision'
        pass

    def setOption(self, key: 'str', value: 'Any') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'ok', False, 'blocked', 'action', 'master.config.set_option', 'code', 'master_config_option_key_missing', 'error', 'option_key_missing', 'message', 'Config option key missing', '_set_action_result', '_service', 'save_option', 'get'
        pass

    def setOptions(self, patch: 'dict[str, Any]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_service', 'save_config', 'dict', 'ok', 'blocked', 'action', 'code', 'config', 'message', True, False, 'master.config.set_options', 'master_config_options_saved', 'Master options updated', '_config'
        pass

    def applySharedAutoMerge(self, enabled: 'bool') -> 'None':
        # [PyArmor BCC constants]: 'bool', '_shared_auto_merge_override', '_config', 'get', 'auto_merge_video', 'dict', 'configChanged', 'emit'
        pass

    def setFolder(self, folder: 'str') -> 'dict[str, Any]':
        pass

    def requestFolderPicker(self) -> 'dict[str, Any]':
        pass

    def setCharacterLibrarySelection(self, selection: 'dict[str, Any]', available_items: 'list[Any]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_service', 'set_character_library_selection', 'dict', 'list', 'isinstance', 'get', 'config', 'get_config', '_config', 'get_options', '_options', '_set_action_result', 'ok', 'blocked', 'action'
        pass

    def setLibraryAssetSelection(self, category: 'str', selection: 'dict[str, Any]', available_items: 'list[Any]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_service', 'set_library_asset_selection', 'dict', 'list', 'isinstance', 'get', 'config', 'get_config', '_config', 'get_options', '_options', '_set_action_result', 'ok', 'blocked', 'action'
        pass

    def clearCharacterLibrarySelection(self) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_service', 'clear_character_library_selection', 'dict', 'get', 'config', 'get_config', '_config', 'get_options', '_options', '_set_action_result', 'ok', 'blocked', 'action', 'code', 'error'
        pass

    def moveCharacterLibrarySelection(self, media_id: 'str', offset: 'int') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_service', 'move_character_library_selection', 'dict', 'get', 'config', 'get_config', '_config', 'get_options', '_options', '_set_action_result', 'ok', 'blocked', 'action', 'code', 'error'
        pass

    def removeCharacterLibrarySelection(self, media_id: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_service', 'remove_character_library_selection', 'dict', 'get', 'config', 'get_config', '_config', 'get_options', '_options', '_set_action_result', 'ok', 'blocked', 'action', 'code', 'error'
        pass

    def removeLibraryAssetSelection(self, category: 'str', media_id: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_service', 'remove_library_asset_selection', 'dict', 'get', 'config', 'get_config', '_config', 'get_options', '_options', '_set_action_result', 'ok', 'blocked', 'action', 'code', 'error'
        pass

    def setFlowVoiceSelection(self, selection: 'dict[str, Any]', available_items: 'list[Any]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_service', 'set_flow_voice_selection', 'dict', 'list', 'isinstance', 'get', 'config', 'get_config', '_config', 'get_options', '_options', '_set_action_result', 'ok', 'blocked', 'action'
        pass

    def removeFlowVoiceSelection(self, media_id: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_service', 'remove_flow_voice_selection', 'dict', 'get', 'config', 'get_config', '_config', 'get_options', '_options', '_set_action_result', 'ok', 'blocked', 'action', 'code', 'error'
        pass

    def refreshFlowVoiceSelection(self) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_service', 'refresh_flow_voice_selection', 'dict', 'get', 'config', 'get_config', '_config', 'get_options', '_options', '_set_action_result', 'ok', 'blocked', 'action', 'code', 'error'
        pass

    def requestOpenDialog(self, name: 'str') -> 'None':
        # [PyArmor BCC constants]: 'str', '', 'strip', 'name', '_pending_dialog', 'pendingDialogChanged', 'emit'
        pass

    def consumePendingDialog(self, name: 'str') -> 'bool':
        # [PyArmor BCC constants]: 'str', '', 'strip', '_pending_dialog', 'get', 'name', False, 'pendingDialogChanged', 'emit', True
        pass

    def refreshStyles(self, search: 'str' = '') -> 'None':
        # [PyArmor BCC constants]: '_service', 'list_styles', 'list', 'get', 'styles', '_styles', 'stylesChanged', 'emit', 'error', '_set_status', 'Load styles failed: ', 'Loaded ', 'len', ' style(s)'
        pass

    def _load_draw_bindings_async(self) -> 'None':
        # [PyArmor BCC constants]: 'hands', 'profiles', 'load_draw_style_hand_bindings', 'load_draw_style_motion_profiles', 'run_off_thread', '_draw_binding_load_inflight', '_drawBindingsLoaded', 'name', 'DrawStyleBindingsLoad'
        pass

    def _apply_draw_bindings_loaded(self, payload: 'dict[str, Any]') -> 'None':
        # [PyArmor BCC constants]: '_draw_binding_load_inflight', 'done', 'get', 'ok', '_draw_binding_revision', 0, 'dict', 'data', 'hands', 'items', 'str', '_draw_style_hand_bindings', 'drawStyleHandBindingsChanged', 'emit', 'profiles'
        pass

    def _draw_style_item(self, style_id: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'str', '', 'strip', 'lower', '_styles', 'get', 'id', 'style_id', 'dict'
        pass

    def _draw_style_has_catalog_capability(self, style_id: 'str') -> 'bool':
        # [PyArmor BCC constants]: '_draw_style_item', 'get', 'framework_definition', 'framework', 'resolved', 'dict', 'render_capabilities', 'image_motion', 'renderers', 'str', '', 'strip', 'lower', 'bool', 'enabled'
        pass

    def _draw_style_configured(self, style_id: 'str') -> 'bool':
        # [PyArmor BCC constants]: 'str', '', 'strip', 'lower', 'dict', '_draw_style_motion_profiles', 'get', 'bool', 'enabled', '_draw_style_has_catalog_capability'
        pass

    def _draw_style_supports_hand(self, style_id: 'str') -> 'bool':
        pass

    def isDrawStyleConfigured(self, styleId: 'str') -> 'bool':
        pass

    def setDrawStyleMotionProfile(self, styleId: 'str', actorMode: 'str', assetId: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'str', '', 'strip', 'lower', '_draw_style_item', 'ok', False, 'code', 'draw_style_missing', 'message', 'Style is not available.', 'get', 'framework_definition', 'framework', 'resolved'
        pass

    def setDrawStyleHandBinding(self, styleId: 'str', assetId: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'str', '', 'strip', 'lower', 'normalize_hand_asset_id', '_draw_style_supports_hand', 'ok', False, 'code', 'draw_style_not_hand_renderable', 'message', 'Style is not eligible for hand/pen Draw mode.', 'dict', '_draw_style_hand_bindings', 'auto'
        pass

    def _persist_draw_bindings_async(self) -> 'None':
        # [PyArmor BCC constants]: '_draw_binding_save_pending', 'dict', '_draw_style_hand_bindings', '_draw_style_motion_profiles', 'items', 'int', '_draw_binding_revision', 'save_draw_style_hand_bindings', 'save_draw_style_motion_profiles', 'bindings', 'profiles', 'revision', 'run_off_thread', '_draw_binding_save_inflight', '_drawBindingsSaved'
        pass

    def _apply_draw_bindings_saved(self, payload: 'dict[str, Any]') -> 'None':
        # [PyArmor BCC constants]: '_draw_binding_save_inflight', 'done', 'int', 'get', 'data', 'revision', 1, 'ok', True, '_draw_binding_save_pending', '_set_status', 'Save Draw hand/pen binding failed', '_draw_binding_revision', '_draw_binding_save_timer', 'start'
        pass

    def selectStyle(self, style: 'dict[str, Any]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_service', 'select_style', 'dict', 'get', 'config', 'get_config', '_config', 1, '_config_revision', 'get_options', '_options', '_set_action_result', 'ok', 'blocked', 'action'
        pass

    def selectStyleSelection(self, selection: 'dict[str, Any]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_service', 'select_style_selection', 'dict', 'get', 'config', 'get_config', '_config', 1, '_config_revision', 'get_options', '_options', '_set_action_result', 'ok', 'blocked', 'action'
        pass

    def saveStyle(self, styleId: 'str', name: 'str', prompt: 'str', kind: 'str' = 'style', description: 'str' = '', frameworkJson: 'str' = '') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_service', 'upsert_style', 'refreshStyles', '', 'get', 'created', 'Created', 'Updated', 'dict', 'style', ' style: ', 'id', 'message', '_set_action_result', 'str'
        pass

    def requestStyleAiGeneration(self, payload: 'dict[str, Any]', withPreview: 'bool' = False) -> 'None':
        # [PyArmor BCC constants]: '_style_ai_busy', '_set_action_result', 'ok', False, 'blocked', True, 'action', 'master.config.generate_style_framework', 'code', 'master_config_style_ai_busy', 'message', 'Style AI generation is already running.', 'framework', '_style_ai_phase', 'styleAiBusyChanged'
        pass

    def requestStyleTopicGeneration(self, payload: 'dict[str, Any]') -> 'None':
        # [PyArmor BCC constants]: '_style_topic_busy', '_set_action_result', 'ok', False, 'blocked', True, 'action', 'master.config.generate_style_topic_tree', 'code', 'master_config_style_topic_busy', 'message', 'Style topic tree generation is already running.', 'styleTopicBusyChanged', 'emit', 'run_off_thread'
        pass

    def requestStyleTopicProposal(self, payload: 'dict[str, Any]') -> 'None':
        # [PyArmor BCC constants]: '_style_topic_busy', '_set_action_result', 'ok', False, 'blocked', True, 'action', 'master.config.propose_style_topic', 'code', 'master_config_style_topic_busy', 'message', 'Style topic generation is already running.', 'styleTopicBusyChanged', 'emit', 'run_off_thread'
        pass

    def commitStyleTopic(self, payload: 'dict[str, Any]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_service', 'commit_style_topic', 'get', 'ok', 'refreshStyles', '', '_set_action_result', 'styleTopicGenerated', 'emit', 'Commit topic failed: ', 'type', '__name__', 'blocked', 'action', 'code'
        pass

    def requestStylePreviewGeneration(self, payload: 'dict[str, Any]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_style_preview_busy', 'ok', False, 'blocked', True, 'action', 'master.config.generate_style_preview', 'code', 'master_config_style_preview_busy', 'message', 'Style preview queueing is already running.', '_set_action_result', '_start_style_preview_worker', 'payload', 'bulk'
        pass

    def requestStyleComboPreviewGeneration(self, selection: 'dict[str, Any]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_style_preview_busy', 'ok', False, 'blocked', True, 'action', 'master.config.generate_style_combo_preview', 'code', 'master_config_style_preview_busy', 'message', 'Style preview queueing is already running.', '_set_action_result', '_start_style_preview_worker', 'combo_selection', 'dict'
        pass

    def requestStylePreviewBulk(self, items: 'list[dict[str, Any]]', onlyMissing: 'bool' = True, currentStyleId: 'str' = '') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_style_preview_busy', 'ok', False, 'blocked', True, 'action', 'master.config.generate_style_preview_bulk', 'code', 'master_config_style_preview_busy', 'message', 'Style preview queueing is already running.', '_set_action_result', '_start_style_preview_worker', 'items', 'list'
        pass

    def requestDrawMotionPreview(self, styleId: 'str', actorMode: 'str', handAsset: 'str', force: 'bool' = False) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'str', '', 'strip', '_draw_style_item', 'style', 'id', 'style_id', 'actor_mode', 'hand_asset', 'still_path', 'force', 'auto', 'get', 'preview_path', 'preview_thumb'
        pass

    def _start_draw_motion_preview_worker(self, request: 'dict[str, Any]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'dict', True, '_draw_motion_preview_busy', 'drawMotionPreviewBusyChanged', 'emit', '_service', 'generate_draw_motion_preview', 'int', 'get', 'revision', 0, 'run_off_thread', '_draw_motion_preview_inflight', '_drawMotionPreviewDone', 'name'
        pass

    def _on_draw_motion_preview_done(self, payload: 'dict') -> 'None':
        # [PyArmor BCC constants]: '_draw_motion_preview_inflight', 'done', 'dict', 'get', 'data', 'ok', 'action', 'code', 'exists', 'message', False, 'master.config.generate_draw_motion_preview', 'str', 'error', 'draw_motion_preview_failed'
        pass

    def _start_style_preview_worker(self, *, payload: 'dict[str, Any] | None' = None, items: 'list[dict[str, Any]] | None' = None, only_missing: 'bool' = True, current_style_id: 'str' = '', bulk: 'bool' = False, combo_selection: 'dict[str, Any] | None' = None) -> 'None':
        # [PyArmor BCC constants]: True, '_style_preview_busy', 'stylePreviewBusyChanged', 'emit', '_StylePreviewQueueWorker', '_service', 'payload', 'items', 'only_missing', 'current_style_id', 'bulk', 'combo_selection', 'run_off_thread', '_stylePreviewDone', 'compute'
        pass

    def toggleStyleFavorite(self, styleId: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_service', 'toggle_style_favorite', 'refreshStyles', '', '_set_action_result', 'Toggle style favorite failed: ', 'type', '__name__', 'ok', 'blocked', 'action', 'code', 'error', 'message', False
        pass

    def stylePreview(self, styleId: 'str') -> 'dict[str, Any]':
        pass

    def stylePreviewCampaignProgress(self, campaignId: 'str') -> 'dict[str, Any]':
        pass

    def convertStylePreviewsToWebp(self) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_service', 'convert_style_previews_to_webp', 'ok', 'action', 'code', 'error', 'message', False, 'master.config.convert_style_previews_to_webp', 'type', '__name__', 'str', 'WebP conversion failed: ', 'Exception', '_set_action_result'
        pass

    def deleteStyle(self, styleId: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_service', 'delete_style', 'refreshStyles', '', 'get', 'deleted', 'restored_base', 'Removed custom override: ', 'message', 'Deleted custom style: ', 'Delete skipped: ', 'error', 'not custom', '_set_action_result', 'Delete style failed: '
        pass

    def deleteStyleTopic(self, topicId: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_service', 'delete_style_topic', 'refreshStyles', '', '_set_action_result', 'Delete topic failed: ', 'type', '__name__', 'ok', 'deleted', 'action', 'code', 'error', 'message', False
        pass

    def previewVoice(self, voice_code: 'str') -> 'dict':
        # [PyArmor BCC constants]: 'play_wav_preview', 'get_bundled_resources_dir', 'voices', '.wav', 'dict', 'str', 'setdefault', 'source', 'get', 'ok', 'local', 'none', 'error', False, 'Exception'
        pass

    def markBlocked(self, action: 'str') -> 'None':
        pass

    @staticmethod
    def _unwrap(payload: 'dict', action: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'get', 'ok', 'dict', 'data', 'Worker crashed: ', 'error', 'unknown', 'action', 'code', 'message', False, 'worker_crashed'
        pass

    def _on_style_ai_phase(self, phase: 'str') -> 'None':
        # [PyArmor BCC constants]: 'str', '', 'strip', '_style_ai_phase', 'styleAiPhaseChanged', 'emit'
        pass

    def _on_style_ai_done(self, payload: 'dict') -> 'None':
        # [PyArmor BCC constants]: False, '_style_ai_busy', '', '_style_ai_phase', 'styleAiBusyChanged', 'emit', 'styleAiPhaseChanged', '_unwrap', 'master.config.generate_style_ai', '_set_action_result', 'styleAiGenerated'
        pass

    def _on_style_topic_gen_done(self, payload: 'dict') -> 'None':
        # [PyArmor BCC constants]: False, '_style_topic_busy', 'styleTopicBusyChanged', 'emit', '_unwrap', 'master.config.generate_style_topic_tree', '_set_action_result', 'get', 'ok', 'refreshStyles', '', 'styleTopicGenerated'
        pass

    def _on_style_topic_propose_done(self, payload: 'dict') -> 'None':
        # [PyArmor BCC constants]: False, '_style_topic_busy', 'styleTopicBusyChanged', 'emit', '_unwrap', 'master.config.propose_style_topic', '_set_action_result', 'styleTopicProposed'
        pass

    def _on_style_preview_done(self, payload: 'dict') -> 'None':
        # [PyArmor BCC constants]: False, '_style_preview_busy', 'stylePreviewBusyChanged', 'emit', '_unwrap', 'master.config.generate_style_preview', '_set_action_result', 'stylePreviewGenerated'
        pass

    def _set_action_result(self, result: 'dict[str, Any]') -> 'None':
        # [PyArmor BCC constants]: 'isinstance', 'get', 'blocker', 'dict', 'bool', 'blocked', 'str', 'code', 'error', '', 'message', 'Action blocked', 'Action completed', 'action', 'ok'
        pass

    def _set_status(self, message: 'str') -> 'None':
        pass


# --- Class: MasterVoiceController ---
class MasterVoiceController(QObject):
    """Global TTS config — same pattern as MasterOptionsController."""
    staticMetaObject = PySide6.QtCore.QMetaObject("MasterVoiceController" inherits "QObject":
Properties:
  #1 "providers", QVariantList [desig...

    configChanged = Signal()
    optionsChanged = Signal()
    busyChanged = Signal()
    statusMessageChanged = Signal()
    generateResultChanged = Signal()
    def __init__(self) -> 'None':
        pass

    @staticmethod
    def _get_api() -> 'Any':
        pass

    @staticmethod
    def _t(v: 'Any') -> 'str':
        pass

    def providers(*args, **kwargs):
        pass

    def provider(*args, **kwargs):
        pass

    def voices(*args, **kwargs):
        pass

    def voice(*args, **kwargs):
        pass

    def models(*args, **kwargs):
        pass

    def model(*args, **kwargs):
        pass

    def ttsMode(*args, **kwargs):
        pass

    def sharedTtsConfig(*args, **kwargs):
        pass

    def outputFolder(*args, **kwargs):
        pass

    def providerOptions(*args, **kwargs):
        pass

    def busy(*args, **kwargs):
        pass

    def statusMessage(*args, **kwargs):
        pass

    def lastResult(*args, **kwargs):
        pass

    def setProvider(self, provider: 'str') -> 'None':
        # [PyArmor BCC constants]: '_t', '_api', 'apply_state', 'tts_provider', 'configChanged', 'emit', '_refresh_options', '_set_status', 'Voice provider: '
        pass

    def setVoice(self, voice_id: 'str') -> 'None':
        # [PyArmor BCC constants]: '_t', '_api', 'apply_state', 'tts_voice', 'configChanged', 'emit', '_set_status', 'Voice: '
        pass

    def setModel(self, model: 'str') -> 'None':
        # [PyArmor BCC constants]: '_t', '_api', 'apply_state', 'tts_model', 'configChanged', 'emit', '_set_status', 'TTS model: '
        pass

    def setTtsMode(self, mode: 'str') -> 'None':
        # [PyArmor BCC constants]: '_t', 'lower', 'auto', 'manual', '_api', 'apply_state', 'tts_mode', 'configChanged', 'emit'
        pass

    def setOutputFolder(self, folder: 'str') -> 'None':
        # [PyArmor BCC constants]: '_api', 'apply_state', 'output_folder', '_t', 'configChanged', 'emit', '_set_status', 'Audio output: '
        pass

    def setOption(self, key: 'str', value: 'Any') -> 'None':
        # [PyArmor BCC constants]: '_api', 'apply_state', '_t', 'configChanged', 'emit'
        pass

    def applyState(self, delta: 'dict[str, Any]') -> 'None':
        # [PyArmor BCC constants]: '_api', 'apply_state', 'dict', 'configChanged', 'emit'
        pass

    def refresh(self) -> 'None':
        # [PyArmor BCC constants]: '_refresh_providers', '_refresh_options', 'configChanged', 'emit'
        pass

    def refreshOptions(self) -> 'None':
        pass

    def generateSync(self, text: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'dict', '_api', 'generate', '_t'
        pass

    def generateAsync(self, text: 'str') -> 'None':
        # [PyArmor BCC constants]: '_busy', '_set_busy', True, '_GenerateWorker', '_api', '_t', '_workers', 'append', 'resultReady', 'connect', 'finished', '_release_finished_worker', 'register', 'start'
        pass

    def _release_finished_worker(self) -> 'None':
        # [PyArmor BCC constants]: 'sender', '_workers', 'remove', 'ValueError', 'deleteLater'
        pass

    def getState(self) -> 'dict[str, Any]':
        pass

    def _refresh_providers(self) -> 'None':
        # [PyArmor BCC constants]: 'list', '_api', 'list_providers', '_providers', 'value', 'gemini', 'label', 'Gemini Audio', 'accent', '#3B82F6', 'minimax', 'MiniMax', '#F59E0B', 'elevenlabs', 'ElevenLabs'
        pass

    def _refresh_options(self) -> 'None':
        # [PyArmor BCC constants]: 'provider', '_api', 'list_voices', '_voice_option', 'label', 'Default', 'value', 'default', 'flag', '', '_voices', 'Exception', 'list_models', '_t', 'get'
        pass

    @staticmethod
    def _voice_option(item: 'Any', provider: 'str') -> 'dict[str, str]':
        # [PyArmor BCC constants]: 'isinstance', 'dict', 'label', 'value', 'flag', 'str', '', 'vi', 'vn', 'en', 'us', 'ja', 'jp', 'ko', 'kr'
        pass

    @staticmethod
    def _options_from_state(state: 'dict[str, Any]', provider: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'minimax', 'speed', 'pitch', 'vol', 'emotion', 'audio_format', 'float', 'get', 'minimax_speed', 1.0, 'int', 'minimax_pitch', 0, 'minimax_volume', 'str'
        pass

    def _on_generate_done(self, worker: '_GenerateWorker', result: 'Any') -> 'None':
        # [PyArmor BCC constants]: 'isinstance', 'dict', 'ok', False, 'error', 'invalid_result', '_last_result', '_set_busy', 'generateResultChanged', 'emit', '_set_status', 'get', 'Voice generated.', 'str', 'Voice generation failed'
        pass

    def _set_busy(self, value: 'bool') -> 'None':
        pass

    def _set_status(self, msg: 'str') -> 'None':
        pass


# --- Class: NarratorController ---
class NarratorController(QObject):
    """Shared narrator identity — same controller from master, clone, or future tabs."""
    staticMetaObject = PySide6.QtCore.QMetaObject("NarratorController" inherits "QObject":
Properties:
  #1 "voiceMode", QString [designable], ...

    configChanged = Signal()
    optionsChanged = Signal()
    asrStateChanged = Signal()
    _asrDone = Signal()
    _asrProgress = Signal()
    def __init__(self) -> 'None':
        pass

    def _api(self) -> 'Any':
        pass

    @staticmethod
    def _t(v: 'Any') -> 'str':
        pass

    def _ensure_options(self) -> 'None':
        pass

    def voiceMode(*args, **kwargs):
        pass

    def voice(*args, **kwargs):
        pass

    def emotion(*args, **kwargs):
        pass

    def selectedVoiceValue(*args, **kwargs):
        pass

    def voice2Value(*args, **kwargs):
        pass

    def voiceOptions(*args, **kwargs):
        pass

    def voice2Options(*args, **kwargs):
        pass

    def emotionOptions(*args, **kwargs):
        pass

    def autoVoiceHint(*args, **kwargs):
        pass

    def selectVoiceValue(self, value: 'str') -> 'None':
        # [PyArmor BCC constants]: '_t', '_AUTO', '_api', 'apply_state', 'voice_mode', 'voice', 'manual', 'configChanged', 'emit'
        pass

    def selectVoice2Value(self, value: 'str') -> 'None':
        # [PyArmor BCC constants]: '_t', '_api', 'apply_state', 'voice2', '_VOICE2_OFF', 'configChanged', 'emit'
        pass

    def setEmotion(self, emotion_id: 'str') -> 'None':
        # [PyArmor BCC constants]: '_api', 'apply_state', 'emotion', '_t', 'configChanged', 'emit'
        pass

    def notifyExternalChange(self) -> 'None':
        pass

    @staticmethod
    def _has_nvidia() -> 'bool':
        # [PyArmor BCC constants]: 'bool', 'shutil', 'which', 'nvidia-smi', 'os', 'path', 'exists', 'C:\\Windows\\System32\\nvidia-smi.exe', False, 'Exception'
        pass

    def asrOfferVisible(*args, **kwargs):
        pass

    def asrInstallBusy(*args, **kwargs):
        pass

    def asrStatus(*args, **kwargs):
        pass

    def installAsrEngine(self) -> 'None':
        pass

    def dismissAsrOffer(self) -> 'None':
        # [PyArmor BCC constants]: '_api', 'apply_state', 'asr_offer_dismissed', '1', False, '_asr_offer', 'asrStateChanged', 'emit'
        pass

    def _on_asr_done(self, payload: 'dict') -> 'None':
        # [PyArmor BCC constants]: '_asr_inflight', 'done', False, '_asr_busy', 'isinstance', 'dict', 'get', 'data', 'bool', 'ok', '_asr_offer', 'Đã cài engine chép lời offline ✓ — job dẫn truyện sẽ chép local', '_asr_status', 'Cài engine không thành công — sẽ tiếp tục dùng Gemini', 'asrStateChanged'
        pass

    def _on_asr_progress(self, msg: 'str') -> 'None':
        # [PyArmor BCC constants]: '_t', '_asr_status', 'asrStateChanged', 'emit'
        pass

    def resolveForJob(self, language: 'str', genre_hint: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_api', 'resolve_voices', '_t', 'voices', 'dict', 'name', 'mode', 'reason', 'Charon', '_AUTO', 'fallback:', 'Exception'
        pass

    def previewVoice(self, value: 'str', which: 'int' = 1) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_t', 'ok', False, 'message', 'off', '_AUTO', '_api', 'resolve_voice', '', 'int', 2, 'auto_pick_second_voice', 'get', 'name', 'play_wav_preview'
        pass


# --- Class: NativeShellController ---
class NativeShellController(QObject):
    _HEADER_KEYWORDS = ('idea', 'ý tưởng', 'y tuong', 'script', 'kịch bản', 'kich ban', 'prompt', 'video', 'title', 'tiêu đề', 'tieu de', 'stt'...
    staticMetaObject = PySide6.QtCore.QMetaObject("NativeShellController" inherits "QObject":
Methods:
  #4 type=Signal, signature=error(QStrin...

    error = Signal()
    fileDialogRequested = Signal()
    def __init__(self) -> 'None':
        pass

    def pickFolder(self, title: 'str' = '', start_path: 'str' = '') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_request_file_dialog', 'kind', 'title', 'start_path', 'folder', 'Select Folder'
        pass

    def pickFiles(self, title: 'str' = '', name_filter: 'str' = '', start_path: 'str' = '') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_request_file_dialog', 'kind', 'title', 'name_filter', 'start_path', 'open_files', 'Select Files', 'All Files (*.*)'
        pass

    def saveTextFile(self, title: 'str' = '', default_name: 'str' = '', name_filter: 'str' = '', content: 'str' = '') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_request_file_dialog', 'kind', 'title', 'default_name', 'name_filter', 'save_text', 'Save File', 'All Files (*.*)', 'get', 'ok', 'str', 'path', '', 'selected_filter', 'cancelled'
        pass

    def completeFileDialogRequest(self, request_id: 'str', payload: 'dict[str, Any]') -> 'None':
        # [PyArmor BCC constants]: 'str', '', '_dialog_requests', 'get', '_normalize_dialog_payload', 'dict', '_dialog_results', '_dialog_loops', 'isRunning', 'quit'
        pass

    def readTextFile(self, path: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_normalize_text_path', 'ok', False, 'blocked', 'path', '', 'text', 'message', 'Path is required.', 'Path', 'read_text', 'encoding', 'utf-8', 'utf-8-sig', 'Read failed: '
        pass

    def readSpreadsheetItems(self, path: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'ok', 'blocked', 'path', 'items', 'message'
        pass

    def _read_spreadsheet_rows(self, path: 'str', *, max_rows: 'int' = 0) -> 'tuple[list[list[str]], dict[str, Any] | None]':
        # [PyArmor BCC constants]: '_normalize_text_path', 'ok', False, 'blocked', 'path', '', 'message', 'Path is required.', 'Path', 'suffix', 'lower', '.csv', 'open', 'r', 'encoding'
        pass

    def _looks_like_header(self, cells: 'list[str]', next_row: 'list[str] | None' = None) -> 'bool':
        """
        Heuristic: does row 1 look like a header (vs. real data)?
        
                Keyword match is decisive. Otherwise treat row 1 as a header only when it
                reads like short labels AND the next data row is substantially longer —
                prompts are long, headers are short. Equal-length rows ⇒ row 1 is data
                (never silently drop it). The visible From/To control overrides either way.
        """
        pass

    def readSpreadsheetColumns(self, path: 'str') -> 'dict[str, Any]':
        """
        List columns of a spreadsheet so the UI can let the user pick one.
        
                Returns columns = [{index, value, label, sample, count}] (label = header
                cell or "Cột N"; count = non-empty cells under the header), plus row_count
                and header_detected so the dialog can default the row range sensibly.
        """
        # [PyArmor BCC constants]: 'ok', 'blocked', 'path', 'columns', 'error', 'message'
        pass

    def readSpreadsheetColumn(self, path: 'str', column_index: 'int', start_row: 'int' = 1, end_row: 'int' = 0) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_read_spreadsheet_rows', '_normalize_text_path', 'items', 'max', 0, 'int', 'len', 1, 'str', '', 'strip', 'append', 'ok', 'blocked', 'path'
        pass

    def readProjectTextFile(self, relative_path: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'str', '', 'replace', '\\', '/', 'strip', 'lstrip', 'ok', False, 'blocked', 'path', 'text', 'message', 'Relative path is required.', 'PROJECT_ROOT'
        pass

    def saveBase64TempImage(self, base64_data: 'str', prefix: 'str' = 'veoflow-preview-', suffix: 'str' = '.png') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'str', '', 'strip', 'ok', False, 'blocked', 'path', 'message', 'Image payload is required.', 'startswith', 'data:', 'base64,', 'find', 0, 'len'
        pass

    def pasteImageFromClipboard(self, prefix: 'str' = 'veoflow-clipboard-', suffix: 'str' = '.png') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'QGuiApplication', 'clipboard', 'ok', False, 'blocked', 'path', '', 'source', 'message', 'Clipboard unavailable.', 'QImage', 'mimeData', 'hasImage', 'imageData', 'isinstance'
        pass

    def _clipboard_url_to_image_path(self, url: 'QUrl') -> 'Path | None':
        # [PyArmor BCC constants]: 'isLocalFile', 'Path', 'toLocalFile', 'expanduser', 'Exception', '_is_image_file'
        pass

    def _clipboard_text_to_image_path(self, text: 'str') -> 'Path | None':
        # [PyArmor BCC constants]: 'str', '', 'splitlines', 'strip', '"', "'", 'startswith', 'file:/', 'QUrl', 'toLocalFile', 'Path', 'expanduser', '_is_image_file'
        pass

    def _is_image_file(self, path: 'Path') -> 'bool':
        # [PyArmor BCC constants]: 'is_file', 'suffix', 'lower', '_CLIPBOARD_IMAGE_EXTENSIONS', False, 'Exception'
        pass

    def _save_temp_qimage(self, image: 'QImage', prefix: 'str', suffix: 'str', source: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'tempfile', 'mkstemp', 'prefix', 'str', 'veoflow-clipboard-', 'suffix', '.png', 'os', 'close', 'save', 'PNG', 'Path', 'unlink', 'missing_ok', True
        pass

    def openExternal(self, target: 'str') -> 'None':
        # [PyArmor BCC constants]: 'QDesktopServices', 'openUrl', 'QUrl', 'error', 'emit', 'Could not open URL: '
        pass

    def openPath(self, path: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'ok', False, 'code', 'path_required', 'error', 'message', 'Path is required.', 'path', '', 'Path', 'expanduser', 'exists', 'Path does not exist: ', 'emit', 'path_missing'
        pass

    def setClipboardText(self, text: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'QGuiApplication', 'clipboard', 'ok', False, 'message', 'Clipboard unavailable.', 'text', '', 'setText', 'str', True, 'Clipboard updated.'
        pass

    def getClipboardText(self) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'QGuiApplication', 'clipboard', 'ok', False, 'message', 'Clipboard unavailable.', 'text', '', True, 'Clipboard loaded.', 'str'
        pass

    def _request_file_dialog(self, request: 'dict[str, Any]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'uuid4', 'hex', 'str', 'get', 'kind', 'open_files', 'request_id', 'name_filters', 'start_url', 'default_url', '_name_filters', 'name_filter', '', '_folder_url', 'start_path'
        pass

    def _normalize_dialog_payload(self, request: 'dict[str, Any]', payload: 'dict[str, Any]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'str', 'get', 'kind', '', 'selected_filter', 'cancelled', 'ok', False, '_dialog_cancelled', 'folder', '_normalize_text_path', 'path', 'blocked', 'paths', 'message'
        pass

    def _dialog_cancelled(self, kind: 'str', selected_filter: 'str' = '') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'folder', 'Folder selection cancelled.', 'save_text', 'Save cancelled.', 'File selection cancelled.', 'ok', 'cancelled', 'blocked', 'path', 'paths', 'selected_filter', 'message', False, True, ''
        pass

    def _name_filters(self, raw_filter: 'str') -> 'list[str]':
        # [PyArmor BCC constants]: 'str', '', 'split', ';;', 'strip', 'All Files (*)'
        pass

    def _folder_url(self, path: 'str') -> 'str':
        # [PyArmor BCC constants]: '_dialog_start_path', 'QUrl', 'fromLocalFile', 'toString', ''
        pass

    def _file_url(self, path: 'str') -> 'str':
        # [PyArmor BCC constants]: 'str', '', 'strip', 'Path', 'expanduser', 'is_absolute', 'cwd', 'QUrl', 'fromLocalFile', 'toString'
        pass

    def _dialog_start_path(self, path: 'str') -> 'str':
        # [PyArmor BCC constants]: '', 'Path', 'expanduser', 'is_file', 'parent', 'exists', 'str'
        pass

    def _normalize_text_path(self, path: 'str') -> 'str':
        # [PyArmor BCC constants]: 'str', '', 'strip', 'QUrl', 'isValid', 'scheme', 'file', 'toLocalFile'
        pass


# --- Class: ResearchController ---
class ResearchController(QObject):
    """QML adapter for the headless research service."""
    staticMetaObject = PySide6.QtCore.QMetaObject("ResearchController" inherits "QObject":
Properties:
  #1 "queueRows", QVariantList [designab...

    queueRowsChanged = Signal()
    statsChanged = Signal()
    historyChanged = Signal()
    schedulesChanged = Signal()
    suggestionsChanged = Signal()
    plannerTemplatesChanged = Signal()
    plannerIdeasChanged = Signal()
    plannerTemplateChanged = Signal()
    previewChanged = Signal()
    reportChanged = Signal()
    assetPackChanged = Signal()
    statusMessageChanged = Signal()
    actionResultChanged = Signal()
    assessmentChanged = Signal()
    assessingChanged = Signal()
    activeContentChanged = Signal()
    evidenceChanged = Signal()
    metadataChanged = Signal()
    plannerGeneratingChanged = Signal()
    activeRunningChanged = Signal()
    audiosChanged = Signal()
    seriesChanged = Signal()
    creatingSeriesChanged = Signal()
    _assessDone = Signal()
    _scheduleDone = Signal()
    _plannerIdeasDone = Signal()
    _audiosReady = Signal()
    _seriesReady = Signal()
    _seriesCreateDone = Signal()
    _refreshReady = Signal()
    def __init__(self) -> 'None':
        # [PyArmor BCC constants]: 'ok', 'blocked', 'action', 'code', 'message', 'blocker'
        pass

    def shutdown(self) -> 'None':
        # [PyArmor BCC constants]: '_shutdown_done', True, 'getattr', '_schedule_timer', 'isActive', 'stop', 'Exception', 'timeout', 'disconnect', '_on_schedule_timer', '_app', 'aboutToQuit', 'shutdown'
        pass

    def queueRows(*args, **kwargs):
        pass

    def stats(*args, **kwargs):
        pass

    def history(*args, **kwargs):
        pass

    def schedules(*args, **kwargs):
        pass

    def queueRowsModel(*args, **kwargs):
        pass

    def historyModel(*args, **kwargs):
        pass

    def schedulesModel(*args, **kwargs):
        pass

    def suggestions(*args, **kwargs):
        pass

    def plannerTemplates(*args, **kwargs):
        pass

    def plannerIdeas(*args, **kwargs):
        pass

    def plannerTemplateId(*args, **kwargs):
        pass

    def plannerTemplate(*args, **kwargs):
        pass

    def plannerStorePath(*args, **kwargs):
        pass

    def previewPrompt(*args, **kwargs):
        pass

    def assessment(*args, **kwargs):
        pass

    def assessing(*args, **kwargs):
        pass

    def planMarkdown(*args, **kwargs):
        pass

    def scriptText(*args, **kwargs):
        pass

    def evidenceMarkdown(*args, **kwargs):
        pass

    def metadataMap(*args, **kwargs):
        pass

    def reportMarkdown(*args, **kwargs):
        pass

    def assetPack(*args, **kwargs):
        pass

    def assetPackText(*args, **kwargs):
        pass

    def lastJobId(*args, **kwargs):
        pass

    def statusMessage(*args, **kwargs):
        pass

    def lastAction(*args, **kwargs):
        pass

    def actionStatus(*args, **kwargs):
        pass

    def refresh(self) -> 'None':
        # [PyArmor BCC constants]: 'str', '_planner_template_id', '', '_service', 'queue', 'stats', 'history', 'schedules', 'planner', 'list_queue', 'get_stats', 'list_history', 'list_schedules', 'get_content_planner_state', 'run_off_thread'
        pass

    def _apply_refresh(self, payload: 'dict') -> 'None':
        # [PyArmor BCC constants]: '_refresh_inflight', 'done', 'get', 'ok', 'dict', 'data', '_coerce_rows', 'queue', 'stats', 'history', 'schedules', 'planner', 'templates', 'ideas', 'str'
        pass

    def audioLibraryModel(*args, **kwargs):
        pass

    def audioCount(*args, **kwargs):
        pass

    def currentAccount(*args, **kwargs):
        pass

    def refreshAudios(self) -> 'None':
        # [PyArmor BCC constants]: 'run_off_thread', '_audios_inflight', '_audiosReady', 'name', 'ResearchAudios'
        pass

    def _apply_audios(self, payload: 'dict') -> 'None':
        # [PyArmor BCC constants]: '_audios_inflight', 'done', 'get', 'ok', 'data', 'audios', 'isinstance', 'dict', '_audios', '_audios_model', 'setRows', 'audiosChanged', 'emit'
        pass

    def sendAudioToVideo(self, job_id: 'str', notes: 'str' = '') -> 'None':
        # [PyArmor BCC constants]: '_service', 'send_audio_to_transcript', 'str', '', '_set_action_result', 'action', 'research.audio.send_to_video', 'success_message', 'Đã đẩy audio sang Audio-to-Video', 'refreshAudios'
        pass

    def deleteAudio(self, job_id: 'str', delete_file: 'bool' = False) -> 'None':
        # [PyArmor BCC constants]: '_service', 'delete_audio', 'str', '', 'bool', '_set_action_result', 'action', 'research.audio.delete', 'success_message', 'Đã xoá audio khỏi kho', 'refreshAudios'
        pass

    def openAudioPath(self, path: 'str') -> 'None':
        # [PyArmor BCC constants]: 'str', '', 'strip', '_open_local_path'
        pass

    def seriesModel(*args, **kwargs):
        pass

    def seriesCount(*args, **kwargs):
        pass

    def creatingSeries(*args, **kwargs):
        pass

    def createSeries(self, job_id: 'str', count: 'int' = 8) -> 'None':
        # [PyArmor BCC constants]: 'str', '_last_job_id', '', 'strip', True, '_creating_series', 'creatingSeriesChanged', 'emit', 'run_off_thread', '_series_create_inflight', '_seriesCreateDone', 'name', 'CreateSeries', False
        pass

    def _on_series_created(self, payload: 'dict') -> 'None':
        # [PyArmor BCC constants]: '_series_create_inflight', 'done', False, '_creating_series', 'creatingSeriesChanged', 'emit', 'get', 'ok', 'data', '_set_action_result', 'dict', 'action', 'research.series.create', 'success_message', 'Đã tạo series — lịch các tập sẵn sàng'
        pass

    def refreshSeries(self) -> 'None':
        # [PyArmor BCC constants]: 'run_off_thread', '_series_inflight', '_seriesReady', 'name', 'ResearchSeries'
        pass

    def _apply_series(self, payload: 'dict') -> 'None':
        # [PyArmor BCC constants]: '_series_inflight', 'done', 'get', 'ok', 'data', 'series', 'isinstance', 'dict', '_series', '_series_model', 'setRows', 'seriesChanged', 'emit'
        pass

    def runSeriesEpisode(self, series_id: 'str', episode_no: 'int' = 0) -> 'None':
        # [PyArmor BCC constants]: '_service', 'run_series_episode', 'str', '', 'int', 0, '_apply_report_result', '_set_action_result', 'action', 'research.series.run_episode', 'success_message', 'Đang chạy tập…', 'refreshSeries'
        pass

    def suggestTopics(self, topic: 'str', count: 'int' = 5, creativity_level: 'str' = 'medium') -> 'None':
        # [PyArmor BCC constants]: '_service', 'suggest_topic', 'get', 'topics', 'str', '_suggestions', 'suggestionsChanged', 'emit', '_set_status', 'Suggested ', 'len', ' topic(s)'
        pass

    def previewTopic(self, topic: 'str', tone: 'str' = 'professional', audience: 'str' = 'general audience') -> 'None':
        # [PyArmor BCC constants]: '_service', 'preview_prompt', 'tone', 'audience', 'str', 'get', 'prompt', '', '_preview_prompt', 'strip', '_last_topic', 'previewChanged', 'emit', '_set_status', 'Research prompt preview updated'
        pass

    def refreshPlanner(self, template_id: 'str' = '') -> 'None':
        # [PyArmor BCC constants]: 'str', '_planner_template_id', '', 'plannerTemplateChanged', 'emit', 'getattr', '_planner_notice', 'plannerGeneratingChanged', 'refresh'
        pass

    def _feature_blocked(self, action: 'str') -> 'dict[str, Any] | None':
        # [PyArmor BCC constants]: 'feature_blocker', 'deep_research', '_set_status', 'str', 'get', 'message', ''
        pass

    def generatePlannerIdeas(self, template_id: 'str', seed_topic: 'str' = '', count: 'int' = 5) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_feature_blocked', 'research.planner_ideas', '_service', 'generate_content_plan_ideas', '_planner_template_id', '_load_planner_state', 'str', 'get', 'template_id', 'plannerIdeasChanged', 'emit', 'plannerTemplateChanged', 'dict', 'setdefault', 'message'
        pass

    def addPlannerIdea(self, template_id: 'str', topic: 'str') -> 'None':
        # [PyArmor BCC constants]: '_service', 'add_content_plan_ideas', '_planner_template_id', '_load_planner_state', 'str', 'get', 'template_id', 'plannerIdeasChanged', 'emit', '_set_status', 'ok', 'Planner idea added', 'error', 'Planner add failed'
        pass

    def applyPlannerIdea(self, template_id: 'str', idea_id: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_service', 'apply_content_plan_idea', '_planner_template_id', '_load_planner_state', 'str', 'get', 'template_id', 'plannerIdeasChanged', 'emit', 'dict', 'ok', 'setdefault', 'message', 'Planner idea applied', '_set_status'
        pass

    def deletePlannerIdea(self, template_id: 'str', idea_id: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_service', 'delete_content_plan_idea', '_planner_template_id', '_load_planner_state', 'str', 'get', 'template_id', 'plannerIdeasChanged', 'emit', 'dict', 'setdefault', 'message', 'ok', 'Planner idea deleted', 'Planner idea not found'
        pass

    def saveTemplate(self, payload: 'dict[str, Any]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'dict', '_service', 'save_content_template', 'str', 'get', 'template_id', '_planner_template_id', '_load_planner_state', 'plannerTemplatesChanged', 'emit', 'plannerTemplateChanged', 'plannerIdeasChanged', '_set_status', 'message', 'error'
        pass

    def deleteTemplate(self, template_id: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'dict', '_service', 'delete_content_template', '_load_planner_state', '', 'plannerTemplatesChanged', 'emit', 'plannerTemplateChanged', 'plannerIdeasChanged', '_set_status', 'str', 'get', 'message', 'error', 'Template delete finished'
        pass

    def generateAiTemplate(self, description: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_feature_blocked', 'research.ai_template', 'dict', '_service', 'generate_content_template', 'str', 'get', 'template_id', '_planner_template_id', '_load_planner_state', 'plannerTemplatesChanged', 'emit', 'plannerTemplateChanged', 'plannerIdeasChanged', '_set_status'
        pass

    def sendToTranscript(self, topic: 'str' = '', notes: 'str' = '') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_report_markdown', '_preview_prompt', 'dict', '_service', 'send_to_transcript', 'job_id', 'topic', 'prompt', 'notes', '_last_job_id', 'setdefault', 'action', 'research.transcript.send', 'message', 'get'
        pass

    def generateAssetPack(self, topic: 'str', notes: 'str' = '') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_feature_blocked', 'research.asset_pack', 'dict', '_service', 'generate_asset_pack', 'topic', 'notes', 'get', 'asset_pack', '_asset_pack', 'format_asset_pack', '', '_asset_pack_text', 'assetPackChanged', 'emit'
        pass

    def copyAssetPack(self) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_asset_pack_text', 'ok', False, 'blocked', 'action', 'research.asset_pack.copy', 'error', 'asset_pack_empty', 'code', 'message', 'Asset pack is empty', '_set_action_result', 'failure_message', 'QGuiApplication', 'clipboard'
        pass

    def exportAssetPack(self, format: 'str' = 'md') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'dict', '_service', 'export_asset_pack', '_asset_pack', 'format', 'setdefault', 'action', 'research.asset_pack.export', 'message', 'str', 'get', 'path', 'error', 'Asset pack export requested', '_set_action_result'
        pass

    def captureContextFiles(self, paths: 'list[Any]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'str', '', 'strip', 'append', 'ok', 'blocked', 'action', 'count', 'paths', 'message', True, False, 'research.context_files.capture', 'len', 'Captured '
        pass

    def generateEvidencePack(self, topic: 'str', report: 'str' = '', notes: 'str' = '', language: 'str' = 'vi') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_feature_blocked', 'research.evidence_pack', 'dict', '_service', 'generate_evidence_pack', 'job_id', 'topic', 'report', 'notes', 'language', 'metadata_prompt', '_last_job_id', '_report_markdown', '_preview_prompt', 'str'
        pass

    def extractMetadata(self, topic: 'str', report: 'str' = '', notes: 'str' = '', language: 'str' = 'vi') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'dict', '_service', 'extract_metadata', 'job_id', 'topic', 'report', 'notes', 'language', '_last_job_id', '_report_markdown', '_preview_prompt', 'str', '', 'strip', '_last_topic'
        pass

    def saveMetadataKit(self, titles_text: 'str', descriptions_text: 'str', thumbnail_prompts_text: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'str', '', 'split', '\n', 'strip', '\n\n', '_metadata', 'titles', 'descriptions', 'thumbnail_prompts', '_last_action', 'isinstance', 'dict', 'setdefault', 'metadata'
        pass

    def approveContent(self, topic: 'str' = '', notes: 'str' = '') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'dict', '_service', 'approve_content', 'job_id', 'topic', 'report', 'notes', '_last_job_id', '_last_topic', '_report_markdown', '_preview_prompt', 'str', '', 'strip', '_apply_report_result'
        pass

    def requestMoreResearch(self, topic: 'str' = '', notes: 'str' = '') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'dict', '_service', 'request_more_research', 'job_id', 'topic', 'report', 'notes', '_last_job_id', '_last_topic', '_report_markdown', '_preview_prompt', 'str', '', 'strip', '_apply_report_result'
        pass

    def sendChat(self, message: 'str', view: 'str' = '', topic: 'str' = '', notes: 'str' = '') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'report', 'str', '', 'strip', 'lower', 'script', 'plan', 'dict', '_service', 'send_chat', 'job_id', 'topic', 'message', 'target', 'source_text'
        pass

    def runAuto(self, topic: 'str', language: 'str' = 'vi', duration: 'str' = 'auto', tone: 'str' = 'professional') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'runAutoConfigured', 'language', 'duration', 'tone'
        pass

    def runAutoConfigured(self, topic: 'str', config: 'dict[str, Any]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'dict', 'topic', '_service', 'run_auto', 'str', '', 'strip', '_last_topic', '_apply_report_result', '_set_action_result', 'action', 'research.auto.run', 'success_message', 'get', 'summary'
        pass

    def runStep(self, job_id: 'str', step: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_service', 'run_step', '_last_job_id', '_apply_report_result', '_set_action_result', 'action', 'research.step.run', 'success_message', "Step '", "' completed", 'failure_message', 'Step failed', 'refresh'
        pass

    def runStepForTopic(self, topic: 'str', step: 'str', language: 'str' = 'vi', duration: 'str' = 'auto', tone: 'str' = 'professional') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'runStepForTopicConfigured', 'job_id', 'language', 'duration', 'tone', '_last_job_id'
        pass

    def runStepForTopicConfigured(self, topic: 'str', step: 'str', config: 'dict[str, Any]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'dict', 'setdefault', 'job_id', '_last_job_id', '_service', 'run_step_for_topic', 'str', '', 'strip', '_last_topic', '_apply_report_result', '_set_action_result', 'action', 'research.step.run_for_topic', 'success_message'
        pass

    def addToQueue(self, topic: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'str', '', 'strip', '_last_topic', 'ok', False, 'blocked', 'action', 'research.queue.add', 'error', 'topic_required', 'code', 'message', 'Research topic is required', '_set_action_result'
        pass

    def startQueue(self) -> 'None':
        # [PyArmor BCC constants]: '_service', 'start_queue', '_apply_report_result', 'get', 'completed', 'queue_', 1, '_last_job_id', 'format_report', 'str', 'report', '_report_markdown', 'reportChanged', 'emit', '_set_action_result'
        pass

    def pollScheduler(self) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'dict', '_service', 'process_due_schedules', 'int', 'get', 'started', 0, 'failed', '_apply_report_result', '_set_action_result', 'action', 'research.schedule.process_due', 'success_message', 'Research scheduler started ', ' job(s)'
        pass

    def activeJobRunning(*args, **kwargs):
        pass

    def activeJobStatus(*args, **kwargs):
        pass

    def _set_active_running(self, running: 'bool') -> 'None':
        # [PyArmor BCC constants]: 'bool', 'getattr', '_active_running', False, 'activeRunningChanged', 'emit'
        pass

    def _set_active_status(self, status: 'str') -> 'bool':
        # [PyArmor BCC constants]: 'str', '', 'strip', 'lower', 'running', '_active_status', '_active_running', 'activeRunningChanged', 'emit', True, '_set_active_running', False
        pass

    def syncActive(self) -> 'None':
        # [PyArmor BCC constants]: 'str', '_last_job_id', '', 'strip', '_set_active_status', '_service', 'get_history_entry', 'get', 'ok', 'dict', 'entry', 'plan', False, '_plan_markdown', True
        pass

    def pauseQueue(self) -> 'None':
        # [PyArmor BCC constants]: '_service', 'pause_queue', '_set_action_result', 'action', 'research.queue.pause', 'success_message', 'Research queue paused (', 'get', 'paused', 0, ' pending)', 'failure_message', 'Research queue pause failed', 'refresh'
        pass

    def clearQueue(self) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'dict', '_service', 'clear_queue', 'setdefault', 'action', 'research.queue.clear', 'message', 'Research queue cleared', '_set_action_result', 'success_message', 'failure_message', 'Research queue clear failed', 'refresh'
        pass

    def removeRow(self, row_id: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'str', '', 'strip', 'ok', False, 'blocked', 'action', 'research.queue.remove_row', 'error', 'missing_row_id', 'code', 'message', 'Missing research row id', '_set_action_result', 'failure_message'
        pass

    def saveAudio(self, job_id: 'str' = '') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_service', 'save_audio', '_last_job_id', 'dict', 'setdefault', 'action', 'research.audio.save', 'message', 'str', 'get', 'path', 'error', 'Audio save requested', '_set_action_result', 'success_message'
        pass

    def saveReport(self, job_id: 'str' = '', format: 'str' = 'txt') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'str', '_last_job_id', '', 'strip', '_service', 'save_report', 'format', 'save_report_markdown', '_report_markdown', '_preview_prompt', 'topic', '_last_topic', 'get', 'ok', 'job_id'
        pass

    def copyReport(self) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_report_markdown', '_preview_prompt', 'ok', False, 'blocked', 'action', 'research.report.copy', 'error', 'report_content_empty', 'code', 'message', 'No report content to copy', '_set_action_result', 'failure_message', 'QGuiApplication'
        pass

    def loadHistory(self, job_id: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_service', 'get_history_entry', 'get', 'ok', 'str', '', '_last_job_id', 'report', '_report_markdown', 'reportChanged', 'emit', 'dict', 'entry', '_set_active_status', 'status'
        pass

    def copyHistory(self, job_id: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_service', 'get_history_entry', 'get', 'ok', 'dict', 'setdefault', 'action', 'research.history.copy', 'message', 'str', 'error', 'History entry not found', '_set_action_result', 'failure_message', 'QGuiApplication'
        pass

    def copyScriptHistory(self, job_id: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_service', 'get_history_entry', 'get', 'ok', 'dict', 'setdefault', 'action', 'research.history.copy_script', 'message', 'str', 'error', 'History entry not found', '_set_action_result', 'failure_message', 'entry'
        pass

    def loadScriptHistory(self, job_id: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_service', 'get_history_entry', 'get', 'ok', 'dict', 'setdefault', 'action', 'research.history.load_script', 'message', 'str', 'error', 'History entry not found', '_set_action_result', 'failure_message', 'entry'
        pass

    def openHistoryFolder(self, job_id: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_service', 'get_history_entry', 'get', 'ok', 'dict', 'setdefault', 'action', 'research.history.open_folder', 'message', 'str', 'error', 'History entry not found', '_set_action_result', 'failure_message', 'entry'
        pass

    def deleteHistory(self, job_id: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'dict', '_service', 'delete_history', 'setdefault', 'action', 'research.history.delete', 'message', 'get', 'ok', 'Research history deleted', 'str', 'error', 'History entry not found', '_set_action_result', 'success_message'
        pass

    def playAudio(self, job_id: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'dict', '_service', 'play_audio', '_last_job_id', 'str', 'get', 'audio_path', '', 'strip', 'ok', '_open_local_path', True, 'opened', 'message', 'blocked'
        pass

    def addSchedule(self, topic: 'str', cron: 'str') -> 'dict[str, Any]':
        pass

    def addScheduleConfigured(self, topic: 'str', cron: 'str', config: 'dict') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'str', '', 'strip', 'ok', False, 'blocked', 'action', 'research.schedule.add', 'error', 'topic_required', 'code', 'message', 'Schedule topic is required', '_set_action_result', 'failure_message'
        pass

    def addScheduleAdvanced(self, topic: 'str', cron: 'str', quality_mode: 'bool', auto_director_notes: 'bool', auto_import: 'bool') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'str', '', 'strip', 'ok', False, 'blocked', 'action', 'research.schedule.add', 'error', 'topic_required', 'code', 'message', 'Schedule topic is required', '_set_action_result', 'failure_message'
        pass

    def runScheduleNow(self, schedule_id: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'dict', '_service', 'run_schedule_now', 'setdefault', 'action', 'research.schedule.run_now', 'message', 'get', 'ok', 'Schedule executed', 'str', 'error', 'Schedule failed', '_set_action_result', 'success_message'
        pass

    def toggleSchedule(self, schedule_id: 'str', enabled: 'bool') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'dict', '_service', 'toggle_schedule', 'setdefault', 'action', 'research.schedule.toggle', 'message', 'get', 'ok', 'Schedule updated', 'str', 'error', 'Schedule failed', '_set_action_result', 'success_message'
        pass

    def resetSchedule(self, schedule_id: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'dict', '_service', 'reset_schedule', 'setdefault', 'action', 'research.schedule.reset', 'message', 'get', 'ok', 'Schedule reset', 'str', 'error', 'Schedule failed', '_set_action_result', 'success_message'
        pass

    def removeSchedule(self, schedule_id: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'dict', '_service', 'remove_schedule', 'setdefault', 'action', 'research.schedule.remove', 'message', 'get', 'ok', 'Schedule removed', 'str', 'error', 'Schedule not found', '_set_action_result', 'success_message'
        pass

    def generateScript(self, format: 'str' = 'monologue', speakers: 'str' = '', duration: 'str' = 'auto') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_feature_blocked', 'research.script.generate', '_service', 'run_step', '_last_job_id', 'script', '_apply_report_result', 'setdefault', 'action', 'message', 'str', 'get', 'summary', 'error', 'Script generation started'
        pass

    def generateScriptForTopic(self, topic: 'str', format: 'str' = 'monologue') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_feature_blocked', 'research.script.generate_for_topic', '_service', 'run_step_for_topic', 'script', 'job_id', 'script_format', 'script_prompt', '_last_job_id', 'str', '_planner_template', 'get', '', '_last_topic', 'strip'
        pass

    def generateTts(self, voice: 'str' = '', model: 'str' = '') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_feature_blocked', 'research.tts.generate', '_service', 'run_step', '_last_job_id', 'tts', '_apply_report_result', 'setdefault', 'action', 'message', 'str', 'get', 'summary', 'error', 'TTS generation started'
        pass

    def generateDirectorNotes(self, topic: 'str' = '', script: 'str' = '', language: 'str' = 'vi') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_service', 'run_step_for_topic', '_last_topic', 'director_notes', 'job_id', 'script', 'language', '_last_job_id', '_report_markdown', '_apply_report_result', 'setdefault', 'action', 'research.director_notes.generate', 'message', 'str'
        pass

    def getState(self) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'ok', 'job_id', 'topic', 'report', 'preview', 'planner_template_id', 'planner_template', True, '_last_job_id', '_last_topic', '_report_markdown', '_preview_prompt', '_planner_template_id', '_planner_template'
        pass

    def applyState(self, state: 'dict[str, Any]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'str', 'get', 'job_id', '', 'strip', '_last_job_id', 'topic', '_last_topic', 'report', '_report_markdown', 'reportChanged', 'emit', 'preview', '_preview_prompt', 'previewChanged'
        pass

    def generateScriptQuality(self, topic: 'str' = '') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_service', 'run_step', '_last_job_id', 'script_quality', '_apply_report_result', 'setdefault', 'action', 'research.script.quality', 'message', 'str', 'get', 'summary', 'Script quality generation started', '_set_action_result', 'success_message'
        pass

    def buildTtsPrompt(self, voice: 'str' = '', model: 'str' = '') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'DeepResearchService', '_report_markdown', '_preview_prompt', 'hasattr', 'build_tts_prompt', '', 'ok', 'prompt', 'voice', 'model', 'action', 'message', True, 'str', 'research.tts.build_prompt'
        pass

    def _apply_assessment_result(self, result: 'dict[str, Any]') -> 'None':
        # [PyArmor BCC constants]: 'get', 'ok', 'dict', 'assessment', '_assessment', 'str', 'recommended_pipeline', '', 'tool_preset', 'bool', 'needs_visualization', 'assessmentChanged', 'emit', 'summary', '_preview_prompt'
        pass

    def assessTopic(self, topic: 'str', language: 'str' = 'vi') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'dict', '_service', 'assess_topic', 'topic', 'language', '_last_topic', 'str', '', 'strip', '_apply_assessment_result', 'setdefault', 'action', 'research.topic.assess', 'message', 'get'
        pass

    def plannerGenerating(*args, **kwargs):
        pass

    def plannerNotice(*args, **kwargs):
        pass

    def generatePlannerIdeasAsync(self, template_id: 'str', seed_topic: 'str' = '', count: 'int' = 5) -> 'None':
        # [PyArmor BCC constants]: 'getattr', '_planner_generating', False, '_feature_blocked', 'research.planner_ideas', 'str', 'get', 'message', 'Planner bị khoá theo license', '_planner_notice', 'plannerGeneratingChanged', 'emit', True, '', '_service'
        pass

    def _on_planner_ideas_done(self, result: 'object') -> 'None':
        # [PyArmor BCC constants]: False, '_planner_generating', 'isinstance', 'dict', 'get', 'ok', '', '_planner_notice', 'Đã tạo ', 'int', 'added', 0, ' ý tưởng', 'str', 'message'
        pass

    def assessTopicAsync(self, topic: 'str', language: 'str' = 'vi') -> 'None':
        # [PyArmor BCC constants]: 'str', '', 'strip', '_assessing', True, 'assessingChanged', 'emit', '_service', '_last_topic', 'dict', 'assess_topic', 'topic', 'language', 'ok', 'error'
        pass

    def _on_assess_done(self, result: 'object') -> 'None':
        # [PyArmor BCC constants]: False, '_assessing', 'assessingChanged', 'emit', 'isinstance', 'dict', 'str', 'get', 'topic', '_last_topic', '', 'strip', '_apply_assessment_result', '_set_action_result', 'action'
        pass

    def runFastContent(self, topic: 'str', config: 'dict[str, Any]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'dict', 'setdefault', 'job_id', '_last_job_id', '_service', 'run_step_for_topic', '_last_topic', 'fast_content', 'str', '', 'strip', '_apply_report_result', '_set_action_result', 'action', 'research.fast_content.run'
        pass

    def runRecommended(self, topic: 'str', config: 'dict[str, Any]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'str', '_assessment', 'get', 'recommended_pipeline', '', 'strip', 'dict', 'setdefault', 'job_id', '_last_job_id', 'fast_content', 'runFastContent', 'web', 'tool_preset', '_service'
        pass

    def cancelCurrent(self) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'str', '_last_job_id', '', 'strip', 'ok', True, 'action', 'research.job.cancel', 'message', 'No active research job.', '_set_action_result', 'success_message', 'dict', '_service', 'cancel_job'
        pass

    def markBlocked(self, action: 'str') -> 'None':
        pass

    def _load_planner_store_path(self) -> 'str':
        # [PyArmor BCC constants]: 'str', '_service', 'content_planner_store_path', '', 'Exception'
        pass

    def _load_planner_state(self, template_id: 'str' = '') -> 'None':
        # [PyArmor BCC constants]: '_service', 'get_content_planner_state', '_coerce_rows', 'templates', '_planner_templates', 'ideas', '_planner_ideas', 'str', 'get', 'selected_template_id', '', '_planner_template_id', 'selected_template', 'isinstance', 'dict'
        pass

    def _apply_report_result(self, result: 'dict[str, Any]') -> 'None':
        # [PyArmor BCC constants]: 'str', 'get', 'job_id', '', '_last_job_id', 'historyChanged', 'emit', 'prompt', '_preview_prompt', 'previewChanged', 'report', '_report_markdown', 'reportChanged', 'status', 'strip'
        pass

    def _set_action_result(self, result: 'dict[str, Any]', *, action: 'str', success_message: 'str' = '', failure_message: 'str' = '') -> 'None':
        # [PyArmor BCC constants]: 'isinstance', 'get', 'blocker', 'dict', 'bool', 'blocked', 'str', 'code', 'error', '', 'message', 'ok', 'Research action completed', 'action', '_last_action'
        pass

    def _set_status(self, message: 'str') -> 'None':
        pass

    def _open_local_path(self, path: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'Path', 'str', '', 'expanduser', 'exists', 'ok', 'code', 'error', 'message', 'path', False, 'path_missing', 'Path does not exist: ', 'os', 'name'
        pass

    def _on_schedule_timer(self) -> 'None':
        # [PyArmor BCC constants]: '_schedule_poll_inflight', True, '_service', 'dict', 'process_due_schedules', 'ok', 'error', 'message', False, 'type', '__name__', 'Research scheduler poll failed: ', 'Exception', '_scheduleDone', 'emit'
        pass

    def _on_schedule_done(self, result: 'object') -> 'None':
        # [PyArmor BCC constants]: False, '_schedule_poll_inflight', 'isinstance', 'dict', 'get', 'ok', 'error', '_set_status', 'str', 'message', 'Research scheduler poll failed', 'int', 'started', 0, 'failed'
        pass


# --- Class: SequenceGraphicsController ---
class SequenceGraphicsController(QObject):
    staticMetaObject = PySide6.QtCore.QMetaObject("SequenceGraphicsController" inherits "QObject":
Properties:
  #1 "presetModel", QObject* [co...

    draftChanged = Signal()
    routeChanged = Signal()
    statusChanged = Signal()
    openRequested = Signal()
    profileApplied = Signal()
    previewImageChanged = Signal()
    autosaveChanged = Signal()
    _previewReady = Signal()
    def __init__(self, settings_manager: 'Any' = None) -> 'None':
        pass

    def _saved_routes(self) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_settings', 'get_setting', 'sequence_graphics', 'routes', 'isinstance', 'dict'
        pass

    def _save_route(self, route: 'str', profile: 'dict[str, Any]') -> 'bool':
        # [PyArmor BCC constants]: '_saved_routes', 'str', '', 'strip', 'lower', '_SUPPORTED_ROUTES', False, 'deepcopy', 'bool', '_settings', 'set_setting', 'sequence_graphics', 'routes'
        pass

    @staticmethod
    def _profile_fingerprint(profile: 'dict[str, Any]') -> 'str':
        # [PyArmor BCC constants]: 'json', 'dumps', 'ensure_ascii', False, 'sort_keys', True, 'separators'
        pass

    def _set_autosave_status(self, value: 'str') -> 'None':
        # [PyArmor BCC constants]: 'str', '', '_autosave_status', 'autosaveChanged', 'emit'
        pass

    def _refresh_subtitle_preview(self) -> 'None':
        # [PyArmor BCC constants]: '_subtitle_preview_contract', '_subtitle_context', 'route', '_route', 'platform_override', 'str', '_draft', 'get', 'platform_safe_zone', 'inherit', '_subtitle_preview'
        pass

    def _queue_autosave(self) -> 'None':
        # [PyArmor BCC constants]: 1, '_autosave_revision', '_set_autosave_status', 'Đang tự lưu…', 'QCoreApplication', 'instance', '_autosave_timer', 'start'
        pass

    def _emit_route_profile(self, *, force: 'bool' = False) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_normalize_studio_profile', '_draft', 'route', '_route', '_profile_fingerprint', '_last_applied_fingerprint', 'get', 'profileApplied', 'emit', '_set_autosave_status', 'Đã tự lưu lựa chọn.'
        pass

    def _flush_autosave(self) -> 'None':
        pass

    def presetModel(*args, **kwargs):
        pass

    def signatureModel(*args, **kwargs):
        pass

    def fontModel(*args, **kwargs):
        pass

    def signatureSelectOptions(*args, **kwargs):
        pass

    def signatureCount(*args, **kwargs):
        pass

    def densityModel(*args, **kwargs):
        pass

    def modeModel(*args, **kwargs):
        pass

    def previewPreset(*args, **kwargs):
        pass

    def variationSeed(*args, **kwargs):
        pass

    def variationLabel(*args, **kwargs):
        pass

    def waveformSeed(*args, **kwargs):
        pass

    def waveformLabel(*args, **kwargs):
        pass

    def signatureLabel(*args, **kwargs):
        pass

    def mapCapability(*args, **kwargs):
        pass

    def activeRoute(*args, **kwargs):
        pass

    def draft(*args, **kwargs):
        pass

    def subtitlePreview(*args, **kwargs):
        pass

    def waveformLayout(*args, **kwargs):
        pass

    def timelineLayout(*args, **kwargs):
        pass

    def statusText(*args, **kwargs):
        pass

    def autosaveStatus(*args, **kwargs):
        pass

    def previewImageUrl(*args, **kwargs):
        pass

    def setPreviewProgress(self, value: 'float') -> 'None':
        # [PyArmor BCC constants]: 'max', 0.0, 'min', 1.0, 'float', '_preview_progress'
        pass

    def _schedule_preview(self) -> 'None':
        # [PyArmor BCC constants]: True, '_preview_pending', '_preview_timer', 'start'
        pass

    def _kick_preview(self) -> 'None':
        # [PyArmor BCC constants]: 'native_backend_ready', False, '_preview_pending', '_preview_url', '', 'previewImageChanged', 'emit', 'deepcopy', '_draft', '_preview_progress', 'dict', 'previewPreset', 'timelineLayout', 'sequence_layout', 'run_off_thread'
        pass

    def _apply_preview(self, payload: 'dict[str, Any]') -> 'None':
        # [PyArmor BCC constants]: '_preview_inflight', 'done', 'get', 'ok', 'dict', 'data', 'str', 'url', '', '_preview_url', 'previewImageChanged', 'emit', '_preview_pending', '_preview_timer', 'start'
        pass

    def openForRoute(self, route: 'str', route_profile: 'dict[str, Any]') -> 'dict[str, Any]':
        pass

    def openForRouteContext(self, route: 'str', route_profile: 'dict[str, Any]', subtitle_context: 'dict[str, Any]') -> 'dict[str, Any]':
        pass

    def _open_for_route(self, route: 'str', route_profile: 'dict[str, Any]', subtitle_context: 'dict[str, Any]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'str', 'timemachine', 'strip', 'lower', '_SUPPORTED_ROUTES', 'Sequence Graphics chỉ hỗ trợ Time Machine và Audio to Video.', '_status', 'statusChanged', 'emit', 'ok', 'route', 'message', False, '_saved_routes', 'get'
        pass

    def patchDraft(self, path: 'str', value: 'Any') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'str', '', 'split', '.', 'ok', False, 'message', 'Thiếu đường dẫn cấu hình.', 'maps', 'enabled', 'bool', '_MAP_UNAVAILABLE_MESSAGE', '_status', 'statusChanged', 'emit'
        pass

    def setPlatformSafeZone(self, safe_zone: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'normalize_platform_safe_zone', 'deepcopy', '_draft', 'platform_safe_zone', '_normalize_studio_profile', 'route', '_route', '_refresh_subtitle_preview', 'Đã đổi vùng né social; preview và render dùng cùng cấu hình.', '_status', 'draftChanged', 'emit', 'statusChanged', '_queue_autosave', 'ok'
        pass

    def patchWaveformCustom(self, values: 'dict[str, Any]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'deepcopy', '_draft', 'dict', 'get', 'waveform', 'custom', 'update', True, 'enabled', 'x_norm', 'y_norm', 'float', 1.0, 0.0, 'position'
        pass

    def setWaveformLength(self, length: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'str', 'auto', 'strip', 'lower', 'full', 'half', 'ok', False, 'message', 'Chiều dài waveform không hợp lệ.', 'deepcopy', '_draft', 'dict', 'get', 'waveform'
        pass

    def resetWaveformCustom(self) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'deepcopy', '_draft', 'dict', 'get', 'waveform', 'default_graphics_profile', '_route', 'custom', 'str', 'position', '', 'auto', '_normalize_studio_profile', 'route', 'Đã trả waveform về biến thể theo seed.'
        pass

    def patchTimelineCustom(self, values: 'dict[str, Any]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'deepcopy', '_draft', 'dict', 'get', 'timeline', 'custom', 'update', True, 'enabled', 'str', 'mode', 'auto', 'strip', 'lower', 'off'
        pass

    def resetTimelineCustom(self) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'deepcopy', '_draft', 'dict', 'get', 'timeline', 'default_graphics_profile', '_route', 'custom', '_normalize_studio_profile', 'route', 'Đã trả thanh timeline về theme mặc định.', '_status', 'draftChanged', 'emit', 'statusChanged'
        pass

    def selectPreset(self, preset_id: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'patchDraft', 'preset_id', 'str', 'auto'
        pass

    def selectSignature(self, signature_id: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'str', 'auto', 'strip', 'deepcopy', '_draft', 'signature_id', 'preset_id', 'mode', 'resolve_signature', 'base_preset_id', 'locked', '_normalize_studio_profile', 'route', '_route', 'AI sẽ chọn trong 10 kiểu thanh timeline.'
        pass

    def rerollVariation(self) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'visual_colorway_index', 'variationSeed', 'secrets', 'randbelow', 2147483647, 1, 'patchDraft', 'variation.seed', 'get', 'ok', 'Đã đổi sang ', 'variationLabel', '.', '_status', 'statusChanged'
        pass

    def rerollWaveform(self) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'waveformSeed', 'secrets', 'randbelow', 2147483647, 1, 'patchDraft', 'waveform.seed', 'get', 'ok', 'Đã tạo biến thể waveform mới. Biên độ vẫn lấy từ audio thật.', '_status', 'statusChanged', 'emit'
        pass

    def resetDraft(self) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_normalize_studio_profile', 'default_graphics_profile', '_route', 'route', '_draft', '_refresh_subtitle_preview', 'Đã khôi phục cấu hình graphics đề xuất.', '_status', 'draftChanged', 'emit', 'statusChanged', '_queue_autosave', 'ok', 'profile', True
        pass

    def applyToRoute(self) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_autosave_timer', 'stop', '_emit_route_profile', 'force', True, '_draft', 'Đã đồng bộ graphics vào cấu hình job.', '_status', 'draftChanged', 'emit', 'statusChanged', 'ok', 'route', 'profile', '_route'
        pass

    def exportProfile(self) -> 'dict[str, Any]':
        pass

    def importJson(self, raw_json: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'json', 'loads', 'str', '', 'ok', 'message', False, 'JSON không hợp lệ: ', 'TypeError', 'ValueError', 'isinstance', 'dict', 'Profile phải là một JSON object.', '_normalize_studio_profile', 'route'
        pass


# --- Class: SubtitleStudioController ---
class SubtitleStudioController(QObject):
    staticMetaObject = PySide6.QtCore.QMetaObject("SubtitleStudioController" inherits "QObject":
Properties:
  #1 "presetModel", QObject* [cons...

    draftChanged = Signal()
    routeChanged = Signal()
    selectionChanged = Signal()
    statusChanged = Signal()
    autosaveChanged = Signal()
    fontCatalogChanged = Signal()
    openRequested = Signal()
    profileApplied = Signal()
    routeProfileAutosaved = Signal()
    routeApplyCompleted = Signal()
    _fontCatalogReady = Signal()
    _fontImportReady = Signal()
    _autosaveLoadReady = Signal()
    _autosaveSaveReady = Signal()
    def __init__(self, settings_manager: 'Any' = None, user_profile_store: 'Any' = None) -> 'None':
        pass

    @staticmethod
    def _auto_font_row() -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'font_id', 'auto', 'source', 'label', 'Tự động theo ngôn ngữ', 'family', 'Auto', 'style', 'Glyph-safe', 'note', 'Renderer chọn font đủ glyph'
        pass

    @staticmethod
    def _preset_row(raw: 'Any') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'dict', 'subtitle_preset_v2_defaults', 'get', 'preset_id', 'caption_styles', 'spoken', 'chrome', 'sample', 'preview_fill', 'preview_accent', 'preview_panel', 'preview_panel_alpha', 'preview_motion', 'preview_effect', 'preview_word_state'
        pass

    def _set_status(self, value: 'str') -> 'None':
        # [PyArmor BCC constants]: 'str', '', '_status', 'statusChanged', 'emit'
        pass

    def _set_autosave_status(self, value: 'str') -> 'None':
        # [PyArmor BCC constants]: 'str', '', '_autosave_status', 'autosaveChanged', 'emit'
        pass

    def _profile_for_context(self, raw: 'Any', *, prefer_saved_aspect: 'bool' = False) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'deepcopy', 'dict', 'str', 'get', 'aspect_ratio', '', 'strip', 'normalize_subtitle_aspect', '_job_context', '16:9', 'default_subtitle_profile_v2', '_route', 'normalize_subtitle_profile_v2', 'route', 'caption'
        pass

    def _restore_selection(self, state: 'Any') -> 'None':
        # [PyArmor BCC constants]: 'dict', 'str', 'get', 'object', 'caption', 'strip', 'lower', 'style', 'spoken', 'OBJECT_IDS', 'overlay', 'bool', '_draft', 'enabled', 'STYLE_IDS'
        pass

    def _autosave_state(self) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'deepcopy', '_draft', False, 'snapshot_locked', 'fingerprint_subtitle_profile_v2', 'fingerprint', 'profile', 'selection', 'object', 'style', '_selected_object', '_selected_style'
        pass

    @staticmethod
    def _route_snapshot(route: 'str', state: 'dict[str, Any]', job_context: 'dict[str, Any]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'resolve_subtitle_profile', 'dict', 'get', 'profile', 'route', 'context', True, 'snapshot_locked', 'fingerprint_subtitle_profile_v2', 'fingerprint'
        pass

    def _queue_autosave(self) -> 'None':
        # [PyArmor BCC constants]: 1, '_autosave_revision', '_route', '_autosave_state', 'revision', 'state', 'route_snapshot', '_route_snapshot', 'deepcopy', '_job_context', '_pending_autosaves', '_set_autosave_status', 'Đang tự lưu…', 'QCoreApplication', 'instance'
        pass

    def _start_autosave_load(self, token: 'int', guard_revision: 'int') -> 'None':
        # [PyArmor BCC constants]: '_route', '_user_profile_store', 'run_off_thread', '_autosaveLoadReady', 'name', 'SubtitleAutosaveLoad'
        pass

    def _flush_autosave(self) -> 'None':
        # [PyArmor BCC constants]: '_pending_autosaves', '_autosave_loading_token', 0, '_autosave_open_token', 'items', '_route', 'QCoreApplication', 'instance', '_autosave_timer', 'start', 120, 'int', 'get', 'revision', 'deepcopy'
        pass

    def _apply_autosave_load(self, payload: 'dict[str, Any]') -> 'None':
        # [PyArmor BCC constants]: 'dict', 'get', 'data', 'int', 'token', 0, '_autosave_open_token', '_autosave_loading_token', 'guard_revision', 'bool', 'ok', 'load_ok', '_set_autosave_status', 'Không thể tải bản tự lưu.', '_autosave_revision'
        pass

    def _apply_autosave_save(self, payload: 'dict[str, Any]') -> 'None':
        # [PyArmor BCC constants]: '_autosave_save_inflight', 'done', 'dict', 'get', 'data', 'int', 'revision', 0, 'str', 'route', '', 'bool', 'ok', 'save_ok', '_pending_autosaves'
        pass

    def _set_draft(self, profile: 'Any', message: 'str' = '', *, autosave: 'bool' = True) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_canonicalize_profile_geometry', 'route', '_route', '_draft', False, 'snapshot_locked', 'fingerprint_subtitle_profile_v2', 'fingerprint', 'compile_paint_plan', '_paint_plan', 'draftChanged', 'emit', 'selectionChanged', '_queue_autosave', '_set_status'
        pass

    def _selected_style_map(self) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'deepcopy', 'dict', '_draft', '_selected_object', 'styles', '_selected_style'
        pass

    def _selected_geom_map(self) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'deepcopy', 'dict', '_draft', '_selected_object', 'geom'
        pass

    def _authored_preset_overrides(self) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'apply_subtitle_preset_v2', '_draft', 'get', 'preset_id', 'route', '_route', 'OBJECT_IDS', 'dict', 'styles', 'STYLE_IDS', '_STYLE_PATCH_KEYS', 'deepcopy', 'chrome', '_CHROME_PATCH_KEYS'
        pass

    @staticmethod
    def _apply_authored_overrides(profile: 'dict[str, Any]', overrides: 'dict[str, Any]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'deepcopy', 'dict', 'get', 'styles', 'items', 'OBJECT_IDS', 'STYLE_IDS', 'update', 'chrome'
        pass

    def presetModel(*args, **kwargs):
        pass

    def presetCategoryModel(*args, **kwargs):
        pass

    def fontModel(*args, **kwargs):
        pass

    def draft(*args, **kwargs):
        pass

    def paintPlan(*args, **kwargs):
        pass

    def jobContext(*args, **kwargs):
        pass

    def selectedStyleData(*args, **kwargs):
        pass

    def selectedGeomData(*args, **kwargs):
        pass

    def activePreviewCue(*args, **kwargs):
        pass

    def activeRoute(*args, **kwargs):
        pass

    def contentMode(*args, **kwargs):
        pass

    def overlayEnabled(*args, **kwargs):
        pass

    def effectiveLearningLanguage(*args, **kwargs):
        pass

    def subtitlesEnabled(*args, **kwargs):
        pass

    def selectedObject(*args, **kwargs):
        pass

    def selectedStyle(*args, **kwargs):
        pass

    def statusMessage(*args, **kwargs):
        pass

    def autosaveStatus(*args, **kwargs):
        pass

    def fontCatalogBusy(*args, **kwargs):
        pass

    def fontCount(*args, **kwargs):
        pass

    def systemFontsLoaded(*args, **kwargs):
        pass

    def presetCount(*args, **kwargs):
        pass

    def readingSystems(*args, **kwargs):
        pass

    def translationLanguages(*args, **kwargs):
        pass

    def learningLanguages(*args, **kwargs):
        pass

    def platformSafeZoneOptions(*args, **kwargs):
        pass

    def openForRoute(self, route: 'str', route_profile: 'dict[str, Any]', job_context: 'dict[str, Any]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'str', 'master', 'strip', 'lower', '_route', 'dict', 'get', 'content_language', 'vi', 'normalize_subtitle_aspect', 'aspect_ratio', '_job_context', '_profile_for_context', '_route_snapshot', 'profile'
        pass

    def setEnabled(self, enabled: 'bool') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'deepcopy', '_draft', 'bool', 'enabled', 'ok', 'profile', True, '_set_draft'
        pass

    def setCaptionMode(self, mode: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'str', 'subtitle', 'strip', 'lower', 'CAPTION_MODES', 'ok', False, 'message', 'Chế độ caption không hợp lệ.', 'deepcopy', '_draft', 'caption', 'mode', '_selected_object', 'spoken'
        pass

    def setOverlayEnabled(self, enabled: 'bool') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'deepcopy', '_draft', 'bool', 'overlay', 'enabled', '_selected_object', 'lemma', '_selected_style', 'caption', 'spoken', '_set_draft', 'selectionChanged', 'emit', 'ok', 'profile'
        pass

    def setReadingSystem(self, reading_system: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'str', 'auto', 'strip', 'lower', 'READING_SYSTEMS', 'ok', False, 'message', 'Hệ chữ đọc không hợp lệ.', 'deepcopy', '_draft', 'overlay', 'reading_system', 'profile', True
        pass

    def setTargetLanguage(self, language: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'str', 'en', 'strip', 'lower', '_LANGUAGE_LABELS', 'ok', False, 'message', 'Ngôn ngữ B không hợp lệ.', 'deepcopy', '_draft', 'caption', 'target_language', 'profile', True
        pass

    def setLearningTargetLanguage(self, language: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'str', 'auto', 'strip', 'lower', 'SUBTITLE_LANGUAGE_CODES', 'ok', False, 'message', 'Ngôn ngữ học không hợp lệ.', 'deepcopy', '_draft', 'overlay', 'target_language', 'profile', True
        pass

    def setSelected(self, object_id: 'str', style_id: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'str', 'caption', 'strip', 'lower', '', 'OBJECT_IDS', 'ok', False, 'message', 'Object phụ đề không hợp lệ.', 'overlay', '_draft', 'enabled', 'Lớp từ + phiên âm đang tắt.', 'STYLE_IDS'
        pass

    def setObjectPosition(self, object_id: 'str', x: 'float', y: 'float') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'str', '', 'strip', 'lower', 'OBJECT_IDS', 'ok', False, 'message', 'Object phụ đề không hợp lệ.', 'deepcopy', '_draft', 'geom', 'update', 'x', 'y'
        pass

    def setLearningLayerOffset(self, object_id: 'str', style_id: 'str', offset_x: 'float', offset_y: 'float') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'str', '', 'strip', 'lower', 'OBJECT_IDS', 'STYLE_IDS', 'ok', False, 'message', 'Lớp học ngôn ngữ không hợp lệ.', 'deepcopy', '_draft', 'styles', 'update', 'offset_x'
        pass

    def setLearningRowGap(self, row_gap: 'float') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'deepcopy', '_draft', 'dict', 'get', 'learning_stack', 'float', 'row_gap', 'ok', 'profile', True, '_set_draft'
        pass

    def setObjectAlign(self, object_id: 'str', align: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'str', '', 'strip', 'lower', 'center', 'OBJECT_IDS', 'right', 'left', 'ok', False, 'message', 'Căn chỉnh không hợp lệ.', 'deepcopy', '_draft', 'geom'
        pass

    def setObjectBoxWidth(self, object_id: 'str', box_width: 'float') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'str', '', 'strip', 'lower', 'OBJECT_IDS', 'ok', False, 'message', 'Object phụ đề không hợp lệ.', 'deepcopy', '_draft', 'float', 'geom', 'box_width', True
        pass

    def patchStyle(self, object_id: 'str', style_id: 'str', key: 'str', value: 'Any') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'str', '', 'strip', 'lower', 'OBJECT_IDS', 'STYLE_IDS', '_STYLE_PATCH_KEYS', 'ok', False, 'message', 'Style patch không hợp lệ.', 'deepcopy', '_draft', 'styles', 'profile'
        pass

    def patchChrome(self, key: 'str', value: 'Any') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'str', '', 'strip', '_CHROME_PATCH_KEYS', 'ok', False, 'message', 'Chrome patch không hợp lệ.', 'deepcopy', '_draft', 'chrome', 'profile', True, '_set_draft'
        pass

    def selectPreset(self, preset_id: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_authored_preset_overrides', 'apply_subtitle_preset_v2', '_draft', 'route', '_route', '_apply_authored_overrides', 'ok', 'profile', True, '_set_draft'
        pass

    def setAspectRatio(self, aspect_ratio: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'deepcopy', '_draft', 'normalize_subtitle_aspect', 'aspect_ratio', 'bool', 'caption', 'get', 'geom_user_set', 'recommended_caption_geometry', 'platform_safe_zone', 'geom', 'ok', 'profile', True, '_set_draft'
        pass

    def setPlatformSafeZone(self, safe_zone: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'normalize_platform_safe_zone', 'deepcopy', '_draft', 'platform_safe_zone', 'bool', 'caption', 'get', 'geom_user_set', 'recommended_caption_geometry', 'aspect_ratio', 'geom', 'auto', 'str', '', '9:16'
        pass

    def resetDraft(self) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'default_subtitle_profile_v2', '_route', 'str', '_job_context', 'get', 'aspect_ratio', '16:9', 'caption', '_selected_object', 'spoken', '_selected_style', '_set_draft', 'Đã khôi phục đề xuất.', 'selectionChanged', 'emit'
        pass

    def persistDraft(self) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_autosave_timer', 'stop', '_flush_autosave', 'ok', 'profile', 'autosave_status', True, 'draft', '_autosave_status'
        pass

    def applyToRoute(self) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'resolve_subtitle_profile', '_draft', 'route', '_route', 'context', '_job_context', 'int', 'get', 'revision', 1, True, 'snapshot_locked', 'fingerprint_subtitle_profile_v2', 'fingerprint', 'deepcopy'
        pass

    def confirmRouteApply(self, route: 'str', result: 'dict[str, Any]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'str', '_route', 'master', 'dict', 'bool', 'get', 'ok', 'message', '', 'strip', 'Cấu hình phụ đề đã áp dụng cho job mới · ', 'Không thể áp dụng cấu hình phụ đề cho route ', '_set_status', 'routeApplyCompleted', 'emit'
        pass

    def confirmRouteAutosave(self, route: 'str', fingerprint: 'str', result: 'dict[str, Any]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'str', '_route', 'master', '', '_autosave_sync_fingerprints', 'get', 'ok', False, 'stale', True, 'message', 'Bỏ qua xác nhận cũ.', 'dict', 'bool', 'strip'
        pass

    def _apply_preset_filter(self) -> 'int':
        # [PyArmor BCC constants]: 'label', 'description', 'recommended_for', 'category', 'tags', 'sample'
        pass

    def setPresetFilter(self, category: 'str', search_text: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'str', 'all', 'strip', 'lower', '_PRESET_CATEGORIES', 'value', '_preset_category', '', '_preset_search', 'ok', 'count', True, '_apply_preset_filter'
        pass

    def _apply_font_filter(self) -> 'int':
        # [PyArmor BCC constants]: 'label', 'family', 'style', 'source'
        pass

    def _preview_font_row(self, font_id: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'ja', 'ko', 'zh', 'ar', 'ur', 'hi', 'th', 'bn'
        pass

    def _font_catalog_row(self, font_id: 'str') -> 'dict[str, Any] | None':
        pass

    def fontDisplayName(self, font_id: 'str') -> 'str':
        # [PyArmor BCC constants]: 'str', 'auto', 'strip', '_font_catalog_row', 'get', 'family', 'label', 'Tự động theo ngôn ngữ', 'split', ':', 1, 0, 'lower', '_FONT_SOURCE_LABELS', '_font_busy'
        pass

    def fontSourceLabel(self, font_id: 'str') -> 'str':
        # [PyArmor BCC constants]: 'str', 'auto', 'strip', '_font_catalog_row', 'get', 'source', '', 'lower', ':', 'split', 1, 0, '_FONT_SOURCE_LABELS'
        pass

    def previewFontFamily(self, font_id: 'str') -> 'str':
        # [PyArmor BCC constants]: '_preview_font_row', 'str', 'get', 'family', 'label', '', 'strip', 'Auto', 'Segoe UI'
        pass

    def previewFontUrl(self, font_id: 'str') -> 'str':
        # [PyArmor BCC constants]: 'str', '_preview_font_row', 'get', 'url', ''
        pass

    def previewFontNeedsLoader(self, font_id: 'str') -> 'bool':
        # [PyArmor BCC constants]: '_preview_font_row', 'str', 'get', 'source', '', 'strip', 'lower', 'path', 'system', False, 'bundled', 'replace', '\\', '/', 'rsplit'
        pass

    def fontRoleDisplayName(self, font_role: 'str') -> 'str':
        # [PyArmor BCC constants]: 'str', 'display', 'strip', 'lower', '_FONT_ROLE_LABELS', 'get'
        pass

    def fontRoleSourceLabel(self, font_role: 'str') -> 'str':
        # [PyArmor BCC constants]: 'str', 'display', 'strip', 'lower', '_FONT_ROLE_LABELS', '_FONT_SOURCE_LABELS', 'bundled', 'auto'
        pass

    def _start_font_catalog(self, include_system: 'bool') -> 'bool':
        # [PyArmor BCC constants]: '_font_busy', False, True, 'fontCatalogChanged', 'emit', 'run_off_thread', '_font_inflight', '_fontCatalogReady', 'name', 'SubtitleFontCatalog'
        pass

    def refreshBundledFontCatalog(self) -> 'bool':
        pass

    def refreshFontCatalog(self) -> 'bool':
        pass

    def _apply_font_catalog(self, payload: 'dict[str, Any]') -> 'None':
        # [PyArmor BCC constants]: '_font_inflight', 'done', False, '_font_busy', 'get', 'ok', 'list', 'data', 'dict', '_auto_font_row', '_font_catalog', '_apply_font_filter', '_set_status', 'Không tải được thư viện font; preview dùng font an toàn.', 'fontCatalogChanged'
        pass

    def setFontFilter(self, source: 'str', search_text: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'str', 'all', 'strip', 'lower', 'bundled', 'system', 'auto', 'custom', '_font_source', '', '_font_search', 'ok', 'count', True, '_apply_font_filter'
        pass

    def selectFont(self, font_id: 'str') -> 'dict[str, Any]':
        pass

    def importCustomFont(self, url_or_path: 'str') -> 'bool':
        # [PyArmor BCC constants]: 'str', '', 'startswith', 'file:', 'QUrl', 'toLocalFile', True, '_font_busy', 'fontCatalogChanged', 'emit', 'run_off_thread', '_font_import_inflight', '_fontImportReady', 'name', 'SubtitleFontImport'
        pass

    def _apply_font_import(self, payload: 'dict[str, Any]') -> 'None':
        # [PyArmor BCC constants]: '_font_import_inflight', 'done', False, '_font_busy', 'get', 'ok', 'dict', 'data', '_font_catalog', 'str', 'font_id', '', 'append', '_apply_font_filter', 'selectFont'
        pass


# --- Class: StatusController ---
class StatusController(QObject):
    """Shell-level status state shared by all QML tabs."""
    _QUEUE_HISTORY_SESSIONS = (('clone_video', 'clone_video'), ('master_prompt', 'master_prompt'), ('transcript_video', 'transcript_video'))
    staticMetaObject = PySide6.QtCore.QMetaObject("StatusController" inherits "QObject":
Properties:
  #1 "statusMessage", QString [designable]...

    stateChanged = Signal()
    statusMessageChanged = Signal()
    logPanelVisibleChanged = Signal()
    tokenMonitorChanged = Signal()
    jobMonitorChanged = Signal()
    errorLogChanged = Signal()
    logEntriesChanged = Signal()
    tokenDialogRequested = Signal()
    jobMonitorDialogRequested = Signal()
    errorLogDialogRequested = Signal()
    runtimeAlertChanged = Signal()
    runtimeAlertRequested = Signal()
    systemLogDialogRequested = Signal()
    ipBlockChanged = Signal()
    ipBlockRouteRequested = Signal()
    def __init__(self) -> 'None':
        pass

    def statusMessage(*args, **kwargs):
        pass

    def ipBlocked(*args, **kwargs):
        pass

    def ipBlockMessage(*args, **kwargs):
        pass

    def _poll_ip_block(self) -> 'None':
        # [PyArmor BCC constants]: 'get_ip_block_state', 'bool', 'is_blocked', 'Exception', '_ip_blocked', False, '_ip_block_dismissed', 'message', '_ip_block_message', 'ipBlockChanged', 'emit'
        pass

    def dismissIpBlock(self) -> 'None':
        # [PyArmor BCC constants]: '_ip_block_dismissed', True, 'ipBlockChanged', 'emit'
        pass

    def retryIpBlock(self) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'get_ip_block_state', 'force_resume', 'Exception', 'get_dispatcher', 'resume_after_ip_block', False, '_ip_blocked', '_ip_block_dismissed', 'ipBlockChanged', 'emit', 'ok', True, 'message', 'Đang thử lại — nếu IP đã sạch, job sẽ chạy tiếp.'
        pass

    def openAccountSettings(self) -> 'None':
        pass

    def dispatcherLabel(*args, **kwargs):
        pass

    def serverQueueLabel(*args, **kwargs):
        pass

    def activeAccounts(*args, **kwargs):
        pass

    def deadAccounts(*args, **kwargs):
        pass

    def errorCount(*args, **kwargs):
        pass

    def logPanelVisible(*args, **kwargs):
        pass

    def tokenSummary(*args, **kwargs):
        pass

    def tokenEntries(*args, **kwargs):
        pass

    def tokenModels(*args, **kwargs):
        pass

    def tokenMonitorDays(*args, **kwargs):
        pass

    def tokenMonitorModel(*args, **kwargs):
        pass

    def jobRows(*args, **kwargs):
        pass

    def jobSummary(*args, **kwargs):
        pass

    def historyRows(*args, **kwargs):
        pass

    def dispatcherRunning(*args, **kwargs):
        pass

    def accountRows(*args, **kwargs):
        pass

    def errorRows(*args, **kwargs):
        pass

    def errorLogText(*args, **kwargs):
        pass

    def logEntries(*args, **kwargs):
        pass

    def runtimeAlert(*args, **kwargs):
        pass

    def refresh(self) -> 'None':
        # [PyArmor BCC constants]: '_job_monitor_snapshot', 'limit', 500, '_account_summary', '_dispatcher_summary', '_server_queue_summary', '_failed_job_count', '_dispatcher_label', '_server_queue_label', 'active', '_active_accounts', 'dead', '_dead_accounts', '_error_count', 'stateChanged'
        pass

    def openTokenMonitor(self) -> 'None':
        # [PyArmor BCC constants]: 'refreshTokenMonitor', 'tokenDialogRequested', 'emit', '_set_status', 'Token Monitor opened'
        pass

    def openJobMonitor(self) -> 'None':
        # [PyArmor BCC constants]: 'refreshJobMonitor', 'jobMonitorDialogRequested', 'emit', '_set_status', 'Job Monitor opened'
        pass

    def openErrorLog(self) -> 'None':
        # [PyArmor BCC constants]: 'refreshErrorLog', 'errorLogDialogRequested', 'emit', '_set_status', 'Error Log opened'
        pass

    def toggleLogPanel(self) -> 'None':
        # [PyArmor BCC constants]: '_log_panel_visible', 'refreshLogEntries', 'logPanelVisibleChanged', 'emit', 'shown', 'hidden', '_set_status', 'System log panel '
        pass

    def dismissRuntimeAlert(self) -> 'None':
        # [PyArmor BCC constants]: '_runtime_alert', 'runtimeAlertChanged', 'emit', '_pending_runtime_alert', 'runtimeAlertRequested'
        pass

    def handleRuntimePromptStatus(self, prompt_data: 'object', status_msg: 'str') -> 'None':
        # [PyArmor BCC constants]: 'source_label', 'output_aspect', 'source_orientation', 'source_size'
        pass

    def refreshTokenMonitor(self) -> 'None':
        # [PyArmor BCC constants]: 'get_token_monitor_service', 'snapshot', 'days', '_token_monitor_days', 'model', '_token_monitor_model', 'dict', 'get', 'summary', '_token_summary', 'list', 'entries', '_token_entries', 'models', '_token_models'
        pass

    def setTokenMonitorDays(self, days: 'int') -> 'None':
        # [PyArmor BCC constants]: 'int', 1, 'TypeError', 'ValueError', 'max', 'min', 7, '_token_monitor_days', 'refreshTokenMonitor'
        pass

    def setTokenMonitorModel(self, model: 'str') -> 'None':
        # [PyArmor BCC constants]: 'str', '', '_token_monitor_model', 'refreshTokenMonitor'
        pass

    def clearTokenHistory(self) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'get_token_monitor_service', 'clear_history', 'ok', True, 'action', 'token_monitor.clear', 'message', 'Usage history cleared', 'error', False, 'token_history_clear_failed', 'Clear token history failed: ', 'type', '__name__', 'Exception'
        pass

    def exportTokenHistoryCsv(self) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'get_token_monitor_service', 'export_csv', 'days', '_token_monitor_days', 'model', '_token_monitor_model', '_set_status', 'Prepared token export (', 'int', 'get', 'row_count', 0, ' row(s))', 'dict', 'Token export failed: '
        pass

    def refreshJobMonitor(self) -> 'None':
        # [PyArmor BCC constants]: '_job_monitor_snapshot', 'limit', 500, 'list', 'get', 'jobs', '_job_rows', 'dict', 'summary', '_job_summary', '_job_history_rows', '_history_rows', 'accounts', '_account_rows', 'get_account_service'
        pass

    def startJobDispatcher(self) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_active_smart_dispatcher', 'hasattr', 'start_dispatcher', 'ok', False, 'action', 'job_monitor.start', 'error', 'dispatcher_start_unavailable', 'message', 'Job dispatcher start unavailable in this QML session', '_set_status', True, 'Job dispatcher started', 'dispatcher_start_failed'
        pass

    def stopJobDispatcher(self) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_active_smart_dispatcher', 'hasattr', 'stop_dispatcher', 'ok', False, 'action', 'job_monitor.stop', 'error', 'dispatcher_stop_unavailable', 'message', 'Job dispatcher stop unavailable in this QML session', '_set_status', True, 'Job dispatcher stopped', 'dispatcher_stop_failed'
        pass

    def cancelAllActiveJobs(self) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 0, '_job_monitor_snapshot', 'limit', 500, '_active_cancel_dispatcher', 'hasattr', 'cancel_job', 'ok', False, 'action', 'job_monitor.cancel_all', 'cancelled', 'error', 'cancel_all_unavailable', 'message'
        pass

    def cancelJob(self, job_id: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'str', '', 'strip', 'ok', False, 'action', 'job_monitor.cancel_job', 'error', 'missing_job_id', 'message', 'Missing job id', '_set_status', '_active_cancel_dispatcher', 'hasattr', 'cancel_job'
        pass

    def copyJobPrompt(self, prompt: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'QGuiApplication', 'clipboard', 'ok', False, 'action', 'job_monitor.copy_prompt', 'error', 'clipboard_unavailable', 'message', 'Clipboard unavailable', '_set_status', 'setText', 'str', '', True
        pass

    def copyJobId(self, job_id: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'QGuiApplication', 'clipboard', 'ok', False, 'action', 'job_monitor.copy_job_id', 'error', 'clipboard_unavailable', 'message', 'Clipboard unavailable', '_set_status', 'setText', 'str', '', 'job_id'
        pass

    def regenJob(self, job_id: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'str', '', 'strip', 'ok', False, 'action', 'job_monitor.regen_job', 'error', 'missing_job_id', 'message', 'Missing job id', '_set_status', '_active_smart_dispatcher', 'hasattr', 'regen_job'
        pass

    def refreshErrorLog(self) -> 'None':
        # [PyArmor BCC constants]: '_job_monitor_snapshot', 'limit', 500, '_failed_rows', '_error_rows', '_format_error_log', '_error_log_text', 'errorLogChanged', 'emit'
        pass

    def clearErrorLog(self) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'ok', 'action', 'removed', 'message'
        pass

    def refreshLogEntries(self) -> 'None':
        # [PyArmor BCC constants]: 'get_unified_logger', 'get_entries', 300, 'isinstance', 'dict', 'Exception', 'timestamp', '', 'source', 'system', 'message', 'No system log entries captured in this QML session.', '_log_entries', 'logEntriesChanged', 'emit'
        pass

    def clearLogEntries(self) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'get_unified_logger', 'clear', 'ok', 'action', 'error', 'message', False, 'system_log.clear', 'system_log_clear_failed', 'System log clear failed: ', 'type', '__name__', 'Exception', True, 'System log cleared'
        pass

    def copyLogEntries(self) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_log_entries', 'str', 'get', 'timestamp', '', 'source', 'message', '[', '] ', ' ', 'append', 'strip', 'QGuiApplication', 'clipboard', 'setText'
        pass

    def openSystemLog(self) -> 'None':
        pass

    def refreshSystemLog(self, filter_text: 'str' = '', source_filter: 'str' = 'all') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'get_unified_logger', 'list', 'get_entries', 'Exception', 'len', 'strip', 'lower', 'isinstance', 'dict', 'all', 'str', 'get', 'source', '', 'message'
        pass

    def _system_log_lines(self) -> 'list[str]':
        # [PyArmor BCC constants]: 'get_unified_logger', 'list', 'get_entries', 'Exception', 'isinstance', 'dict', 'str', 'get', 'timestamp', '', 'source', 'message', '[', '] ', ' '
        pass

    def copySystemLog(self) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_system_log_lines', 'QGuiApplication', 'clipboard', 'ok', 'action', 'error', 'line_count', 'message', False, 'system_log.copy', 'clipboard_unavailable', 'len', 'System log copy unavailable in this session', 'setText', '\n'
        pass

    def exportSystemLog(self) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_system_log_lines', 'ok', False, 'content', '', 'filename', 'message', 'No log entries to export', 'datetime', 'now', 'strftime', '%Y%m%d_%H%M%S', True, '\n', 'join'
        pass

    def setStatusMessage(self, message: 'str') -> 'None':
        pass

    def _set_status(self, message: 'str') -> 'None':
        pass

    def _active_smart_dispatcher(self) -> 'Any | None':
        pass

    def _connect_runtime_feedback(self) -> 'None':
        # [PyArmor BCC constants]: '_runtime_feedback_connected', 'get_instant_upscale_manager', 'prompt_status_updated', 'connect', 'handleRuntimePromptStatus', 'Exception', True
        pass

    def _publish_runtime_alert(self, payload: 'dict[str, Any]') -> 'None':
        # [PyArmor BCC constants]: 'dict', '_runtime_alert', '_pending_runtime_alert', 'runtimeAlertChanged', 'emit', 'runtimeAlertRequested'
        pass

    def publishRuntimeAlert(self, payload: 'dict[str, Any]') -> 'None':
        pass

    def _active_cancel_dispatcher(self) -> 'Any | None':
        # [PyArmor BCC constants]: '_active_smart_dispatcher', 'hasattr', 'cancel_job', 'get_headless_dispatcher', 'Exception'
        pass

    def _job_monitor_snapshot(self, *, limit: 'int | None' = None) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_active_smart_dispatcher', 'hasattr', 'get_monitor_snapshot', 'list', 'get', 'jobs', '_job_row', 'accounts', '_account_row', 'dict', 'summary', '_job_summary_from_rows', 'smart_dispatcher', 'source', 'cooldowns'
        pass

    def _headless_snapshot(self, *, limit: 'int | None' = None, blocker: 'str' = '') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'get_headless_job_store', 'list_jobs', 'limit', '_job_row', 'Exception', '_job_summary_from_rows', 'headless_job_store', 'source', 'jobs', 'accounts', 'summary', 'blockers'
        pass

    def _account_summary(self, snapshot: 'dict[str, Any] | None' = None) -> 'dict[str, int]':
        pass

    def _dispatcher_summary(self, accounts: 'dict[str, int]', snapshot: 'dict[str, Any]') -> 'str':
        # [PyArmor BCC constants]: 'dict', 'get', 'summary', '_safe_int', 'generating', 'processing', 'polling', 'upscaling', 'retrying', 'queued', 'pending', 'waiting', 'failed', 'complete', 'total'
        pass

    def _server_queue_summary(self) -> 'str':
        # [PyArmor BCC constants]: 'str', 'get_server_job_tracker', 'get_summary', '', 'Exception'
        pass

    def _failed_job_count(self, snapshot: 'dict[str, Any] | None' = None) -> 'int':
        # [PyArmor BCC constants]: 'len', '_failed_rows', '_job_monitor_snapshot', 'limit', 500
        pass

    def _failed_rows(self, snapshot: 'dict[str, Any]') -> 'list[dict[str, Any]]':
        # [PyArmor BCC constants]: 'list', 'get', 'jobs', 'str', 'status', '', 'lower', 'failed', '_job_row', 'id', 'row_id', 'len', '_active_smart_dispatcher', 'getattr', 'failed_jobs'
        pass

    def _job_row(self, job: 'dict[str, Any]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'dict', 'isinstance', 'get', 'meta', 'str', 'prompt', '', 'replace', '\n', ' ', '\r', 120, 'setdefault', 'id', 'job_id'
        pass

    def _account_row(self, account: 'dict[str, Any]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'dict', 'str', 'get', 'account_id', 'email', 'name', '', 'bool', 'is_dead', False, 'enabled', 'healthy', 'dead', 'rate_limited', 'cooldown_403'
        pass

    def _job_summary_from_rows(self, rows: 'list[dict[str, Any]]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'pending', 'waiting', 'queued', 'generating', 'polling', 'processing', 'upscaling', 'merging', 'retrying', 'complete', 'failed', 'cancelled'
        pass

    @staticmethod
    def _safe_int(value: 'Any') -> 'int':
        # [PyArmor BCC constants]: 'int', 'float', 0, 'TypeError', 'ValueError'
        pass

    @staticmethod
    def _format_elapsed(value: 'Any') -> 'str':
        pass

    def _job_history_rows(self, _jobs: 'list[dict[str, Any]]') -> 'list[dict[str, Any]]':
        # [PyArmor BCC constants]: 'set', '_queue_clock_rows', 'str', 'get', 'id', '', 'add', 'append', 'list_job_history', 80, '_job_row', 'sort', 'key', 'reverse', True
        pass

    def _queue_clock_rows(self) -> 'list[dict[str, Any]]':
        # [PyArmor BCC constants]: 'get_prompt_queue_service', 'Exception', '_QUEUE_HISTORY_SESSIONS', 'get_queue', 'list', 'dict', 'getattr', 'meta', 'str', 'get', 'started_at', 'created_at', '', 'strip', 'status'
        pass

    @staticmethod
    def _format_timestamp(value: 'Any') -> 'str':
        # [PyArmor BCC constants]: 'as_unix_seconds', 0, '', 'time', 'strftime', '%H:%M:%S', 'localtime', 'OverflowError', 'OSError', 'ValueError'
        pass

    def _format_error_log(self, rows: 'list[dict[str, Any]]') -> 'str':
        # [PyArmor BCC constants]: '=', 80, 'VeoFlow QML Error Log', '', 'append', 'No failed jobs in the current status monitor snapshot.', '\n', 'join', 'enumerate', 'start', 1, 'str', 'get', 'prompt', 'name'
        pass


# --- Class: TaxonomyController ---
class TaxonomyController(QObject):
    """Expose TaxonomyService contracts to reusable QML edit dialogs."""
    staticMetaObject = PySide6.QtCore.QMetaObject("TaxonomyController" inherits "QObject":
Properties:
  #1 "payload", QVariantMap [designable]...

    payloadChanged = Signal()
    statusMessageChanged = Signal()
    actionChanged = Signal()
    voiceGenBusyChanged = Signal()
    mediaVoiceGenerated = Signal()
    mediaVoiceBindingSynced = Signal()
    _voiceGenDone = Signal()
    _bindPresyncDone = Signal()
    def __init__(self) -> 'None':
        # [PyArmor BCC constants]: 'ok', 'themes', 'strategies', 'total'
        pass

    def payload(*args, **kwargs):
        pass

    def themes(*args, **kwargs):
        pass

    def strategies(*args, **kwargs):
        pass

    def statusMessage(*args, **kwargs):
        pass

    def lastAction(*args, **kwargs):
        pass

    def refresh(self, search: 'str' = '') -> 'None':
        # [PyArmor BCC constants]: '_service', 'taxonomy_payload', '_payload', '_set_status', 'Loaded taxonomy: ', 'get', 'total', 0, ' item(s)', 'ok', 'themes', 'strategies', 'error', False, 'str'
        pass

    def themeDialogPayload(self, themeId: 'str' = '', search: 'str' = '') -> 'dict[str, Any]':
        pass

    def strategyDialogPayload(self, strategyId: 'str' = '', search: 'str' = '') -> 'dict[str, Any]':
        pass

    def managementPayload(self, kind: 'str', search: 'str' = '') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_service', 'management_payload', '_set_action', 'taxonomy.', '.manager'
        pass

    def themeManagementPayload(self, search: 'str' = '') -> 'dict[str, Any]':
        pass

    def strategyManagementPayload(self, search: 'str' = '') -> 'dict[str, Any]':
        pass

    def saveTheme(self, payload: 'dict[str, Any]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_service', 'save_theme_payload', 'dict', '_apply_result', 'theme'
        pass

    def deleteTheme(self, themeId: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_service', 'delete_theme_payload', '_apply_result', 'theme'
        pass

    def saveStrategy(self, payload: 'dict[str, Any]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_service', 'save_strategy_payload', 'dict', '_apply_result', 'strategy'
        pass

    def deleteStrategy(self, strategyId: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_service', 'delete_strategy_payload', '_apply_result', 'strategy'
        pass

    def mediaVoiceLibraryPayload(self, search: 'str' = '') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_media_library', 'media_voice_library_payload', '_set_action', 'media.voice.library'
        pass

    def mediaVoiceBoundCharacters(self, voiceRow: 'dict[str, Any]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_media_library', 'media_voice_bound_characters', 'dict', '_set_action', 'media.voice.bound_characters'
        pass

    def previewMediaVoice(self, voiceRow: 'dict[str, Any]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_media_library', 'preview_media_voice', 'dict', '_set_action', 'media.voice.preview'
        pass

    def bindMediaVoiceToCharacter(self, mediaId: 'str', voiceRow: 'dict[str, Any]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_media_library', 'bind_media_voice_to_character', 'dict', 'presync', False, '_set_action', 'media.voice.bind', 'str', 'get', 'character_id', '', 'ok', '_start_bind_presync'
        pass

    def _start_bind_presync(self, media_id: 'str', character_id: 'str') -> 'None':
        # [PyArmor BCC constants]: '_bind_sync_jobs', 'add', 'str', '', 'run_off_thread', '_bindPresyncDone', 'name', 'VoiceBindPresync'
        pass

    def _on_bind_presync_done(self, payload: 'dict') -> 'None':
        # [PyArmor BCC constants]: 'get', 'ok', 'dict', 'data', 'action', 'code', 'message', False, 'media.voice.bind_sync', 'error', 'worker_crashed', 'Bind presync crashed: ', '', 'str', 'character_id'
        pass

    def createMediaVoice(self, name: 'str', baseVoice: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_media_library', 'create_media_voice', '_set_action', 'media.voice.create'
        pass

    def mediaVoiceBaseOptions(self) -> 'dict[str, Any]':
        pass

    def voiceGenBusy(*args, **kwargs):
        pass

    def generateMediaVoice(self, name: 'str', baseVoice: 'str', speaker: 'str', voicePerformance: 'str', dialog: 'str') -> 'None':
        # [PyArmor BCC constants]: '_voice_gen_busy', True, 'voiceGenBusyChanged', 'emit', '_media_library', 'str', 'run_off_thread', '_voiceGenDone', 'name', 'VoiceGenWorker'
        pass

    def _on_voice_gen_done(self, payload: 'dict') -> 'None':
        # [PyArmor BCC constants]: False, '_voice_gen_busy', 'voiceGenBusyChanged', 'emit', 'get', 'ok', 'dict', 'data', 'action', 'code', 'message', 'media.voice.generate', 'error', 'worker_crashed', 'Voice generation crashed: '
        pass

    def unbindMediaVoiceFromCharacter(self, mediaId: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_media_library', 'unbind_media_voice_from_character', '_set_action', 'media.voice.unbind'
        pass

    def _apply_result(self, result: 'dict[str, Any]', kind: 'str') -> 'None':
        # [PyArmor BCC constants]: '_set_action', 'taxonomy.', '.', 'get', 'action', 'save', 'ok', False, '_set_status', ' failed: ', 'error', 'code', 'unknown', 'refresh', ''
        pass

    def _set_action(self, result: 'dict[str, Any]', fallback_action: 'str') -> 'None':
        # [PyArmor BCC constants]: 'dict', 'setdefault', 'action', 'blocked', 'get', 'ok', False, 'blocker', 'str', 'code', 'error', 'taxonomy_action_failed', 'message', '_last_action', 'actionChanged'
        pass

    def _set_status(self, message: 'str') -> 'None':
        pass


# --- Class: TimeMachineController ---
class TimeMachineController(QObject):
    """Own the project queue and expose only model-backed realtime UI state."""
    staticMetaObject = PySide6.QtCore.QMetaObject("TimeMachineController" inherits "QObject":
Properties:
  #1 "config", QVariantMap [designabl...

    configChanged = Signal()
    optionsChanged = Signal()
    selectionChanged = Signal()
    statusChanged = Signal()
    queueChanged = Signal()
    jobPanelRowsChanged = Signal()
    demoPayloadChanged = Signal()
    draftStateChanged = Signal()
    automationProjectionCommitted = Signal()
    _optionsReady = Signal()
    _planDone = Signal()
    _regressDone = Signal()
    _dispatchDone = Signal()
    _liveChainDone = Signal()
    _stillSlideshowDone = Signal()
    _mergeDone = Signal()
    _publishKitDone = Signal()
    _regenerateDone = Signal()
    _panelRegenDone = Signal()
    _cellReady = Signal()
    _jobEvent = Signal()
    _modelsUpdatedSignal = Signal()
    def __init__(self, settings_manager: 'Any' = None) -> 'None':
        # [PyArmor BCC constants]: 'aspects', 'qualities', 'models', 'image_models', 'styles', 'markets', 'languages', 'graphics_presets', 'graphics_densities', 'intent_templates', 'timelapse_pacing', 'model_durations', 'output_templates'
        pass

    def attachStatusController(self, controller: 'Any') -> 'None':
        pass

    def _account_run_blocker(self, action: 'str') -> 'Dict[str, Any] | None':
        # [PyArmor BCC constants]: 'run_blocker', '_publish_shared_account_alert', True, 'alerted'
        pass

    def _publish_shared_account_alert(self) -> 'bool':
        # [PyArmor BCC constants]: '_status_controller', 'hasattr', 'publishRuntimeAlert', False, 'alert_payload', True, 'Exception'
        pass

    def _consume_worker_account_blocker(self, payload: 'Mapping[str, Any]') -> 'None':
        # [PyArmor BCC constants]: 'bool', 'get', 'blocked', 'str', 'code', '', 'account_not_ready', False, '_run_requested', '_publish_shared_account_alert'
        pass

    def _relay_timemachine_job_event(self, job: 'Any') -> 'None':
        # [PyArmor BCC constants]: 'getattr', 'meta', 'isinstance', 'dict', 'get', '_prompt_data', 'str', 'tab_source', 'route', '', 'strip', 'time_machine', 'timemachine', '_jobEvent', 'emit'
        pass

    def _seed_demo_workspace(self) -> 'None':
        # [PyArmor BCC constants]: 'Path', '__file__', 'resolve', 'parents', 2, 'assets', 'demo', 'timemachine_treehouse', 'is_dir', 0, 'enumerate', 'range', 'round', 'len', 1
        pass

    def _on_models_updated(self) -> 'None':
        pass

    def config(*args, **kwargs):
        pass

    def options(*args, **kwargs):
        pass

    def demoPayload(*args, **kwargs):
        pass

    def gridModel(*args, **kwargs):
        pass

    def chapterModel(*args, **kwargs):
        pass

    def stageModel(*args, **kwargs):
        pass

    def viewModel(*args, **kwargs):
        pass

    def timelineModel(*args, **kwargs):
        pass

    def motionModel(*args, **kwargs):
        pass

    def queueModel(*args, **kwargs):
        pass

    def jobPanelModel(*args, **kwargs):
        pass

    def jobPanelRows(*args, **kwargs):
        pass

    def selectedJobId(*args, **kwargs):
        pass

    def selectedJob(*args, **kwargs):
        pass

    def draftReady(*args, **kwargs):
        pass

    def draftBusy(*args, **kwargs):
        pass

    def statusMessage(*args, **kwargs):
        pass

    def queueStats(*args, **kwargs):
        pass

    def _load_runtime_options(self) -> 'None':
        # [PyArmor BCC constants]: 'max_live_account_credits', 'video_quality_options', 'resolve_active_mode', 'ModelConfig', 'mode_to_tier_mode', 'tier_mode', 'str', '_config', 'get', 'model_key', '', 'qualities', '_available_fl_model_options', 'models', 'image_model_options'
        pass

    def _apply_runtime_options(self, payload: 'Dict[str, Any]') -> 'None':
        # [PyArmor BCC constants]: False, 'str', 'get', 'tier_mode', '_tier_mode', 'list', 'models', '_all_fl_model_options', '_filter_video_models', '_options', True, 'qualities', 'value', '', '_config'
        pass

    def _filter_video_models(self) -> 'bool':
        # [PyArmor BCC constants]: 'is_portrait', 'profile_from_model_key', 'resolve_runtime_model', '_config', 'get', 'aspect_ratio', '9:16', '16:9', 'VIDEO_ASPECT_RATIO_PORTRAIT', 'VIDEO_ASPECT_RATIO_LANDSCAPE', '_all_fl_model_options', 'list', 'aspects', 'deepcopy', 'str'
        pass

    def _queue_config_persist(self, *, immediate: 'bool' = False) -> 'None':
        # [PyArmor BCC constants]: '_persist_timer', 'stop', '_begin_config_persist', 'start'
        pass

    def _begin_config_persist(self) -> 'None':
        # [PyArmor BCC constants]: 'deepcopy', '_config', 'getattr', '_user_templates', 'saved_output_templates', '_persist_lock', '_persist_pending', '_persist_worker_running', True, False, 'dict', '_settings', 'get_category_settings', '_TIMEMACHINE_SETTINGS_KEY', 'update'
        pass

    def setOption(self, key: 'str', value: 'Any') -> 'Dict[str, Any]':
        # [PyArmor BCC constants]: 'str', '', 'strip', '_config', 'ok', 'message', False, 'Unknown Time Machine option: ', 'aspect_ratio', 'normalize_timemachine_aspect', 'output_folder', '"', "'", 'inherit_master_output_folder', 'market'
        pass

    def _refresh_output_templates(self) -> 'None':
        # [PyArmor BCC constants]: 'template_option_rows', 'getattr', '_user_templates', '_options', 'get', 'output_templates', 'optionsChanged', 'emit'
        pass

    def applyOutputTemplate(self, template_id: 'str') -> 'Dict[str, Any]':
        # [PyArmor BCC constants]: 'apply_template_payload', 'find_template', 'getattr', '_user_templates', 'ok', False, 'message', 'Không tìm thấy mẫu Time Machine.', '_config', 'update', 'configChanged', 'emit', '_queue_config_persist', 'template', 'label'
        pass

    def saveCurrentOutputTemplate(self, name: 'str') -> 'Dict[str, Any]':
        # [PyArmor BCC constants]: 'make_user_template', 'normalize_user_templates', 'template_option_rows', 'getattr', '_user_templates', 'str', '', 'strip', 'Mẫu ', 'len', 1, '_config', 'append', 'id', 'output_template'
        pass

    def setGraphicsEnabled(self, enabled: 'bool') -> 'Dict[str, Any]':
        # [PyArmor BCC constants]: 'dict', '_config', 'get', 'sequence_graphics', 'str', 'signature_id', 'auto', 'bool', 'locked', 'off', 'timeline', 'enabled', 'maps', False, 'update'
        pass

    def setStyleSelection(self, selection: 'Dict[str, Any]') -> 'Dict[str, Any]':
        # [PyArmor BCC constants]: 'dict', 'str', 'get', 'style_id', '', 'strip', 'structural_style_id', 'surface_style_id', 'camera_id', 'structural_camera_id', 'surface_camera_id', '_config', 'update', 'style_selection_mode', 'inherit_master_style'
        pass

    def _accept_automation_request(self, request: 'Dict[str, Any]') -> 'Dict[str, Any]':
        # [PyArmor BCC constants]: 'dict', 'isinstance', 'get', 'input', 'config', 'list', 'inputs', 'str', 'idea', '', 'strip', '_create_job_snapshot', 'intent_template', 'auto', 'tts_config'
        pass

    def createJob(self, paths: 'list[Any]', intent: 'str') -> 'Dict[str, Any]':
        # [PyArmor BCC constants]: 'enqueueJob', 'str', '_config', 'get', 'intent_template', 'auto'
        pass

    def enqueueJob(self, paths: 'list[Any]', intent: 'str', intent_template: 'str', tts_snapshot: 'Dict[str, Any]') -> 'Dict[str, Any]':
        pass

    def _create_job_snapshot(self, paths: 'list[Any]', intent: 'str', intent_template: 'str', tts_snapshot: 'Dict[str, Any]', *, draft_mode: 'bool', config_override: 'Dict[str, Any] | None' = None, job_id_override: 'str' = '', automation_request_id: 'str' = '') -> 'Dict[str, Any]':
        # [PyArmor BCC constants]: 'input_id', 'input_kind', 'path', 'media_id', 'label', 'media_name', 'visual_description', 'source'
        pass

    def restoreHistoryProject(self, payload: 'Dict[str, Any]') -> 'Dict[str, Any]':
        # [PyArmor BCC constants]: 'dict', 'isinstance', 'get', 'domain_snapshot', 'config', 'deepcopy', 'str', 'base_output_folder', 'output_folder', '', 'strip', 'session_folder', 'plan', 'fact_grounding', 'truth_policy'
        pass

    def prepareDraft(self, paths: 'list[Any]', intent: 'str', intent_template: 'str', tts_snapshot: 'Dict[str, Any]') -> 'Dict[str, Any]':
        # [PyArmor BCC constants]: '_active_job_id', 'ok', False, 'message', 'Hãy chờ bước chuẩn bị hoặc job hiện tại hoàn tất.', '_draft_job_id', '_jobs', 'get', '_schedule_workdir_cleanup', 'str', 'work_dir', '', 15, 60, 'pop'
        pass

    def lockDraftJob(self) -> 'Dict[str, Any]':
        # [PyArmor BCC constants]: '_jobs', 'get', '_draft_job_id', 'ok', False, 'message', 'Chưa có workspace đã phân tích để khóa.', 'bool', 'prepared', 'str', 'phase', '', 'draft_ready', 'Workspace vẫn đang chuẩn bị; hãy chờ keyframe hoàn tất.', 'update'
        pass

    def runAll(self) -> 'Dict[str, Any]':
        # [PyArmor BCC constants]: '_timemachine_license_blocker', 'timemachine.job.run_all', '_jobs', 'values', 'get', 'status', 'queued', 'paused', '_active_job_id', 'ok', False, 'message', 'Hàng chờ chưa có ý tưởng cần chạy.', True, '_run_requested'
        pass

    def selectJob(self, job_id: 'str') -> 'None':
        # [PyArmor BCC constants]: 'str', '', '_jobs', '_focus_job'
        pass

    def pauseJob(self, job_id: 'str') -> 'Dict[str, Any]':
        # [PyArmor BCC constants]: '_jobs', 'get', 'str', '', 'ok', False, 'message', 'Không tìm thấy job.', True, 'paused', 'status', 'Đã tạm dừng; bước đang chạy sẽ hoàn tất rồi dừng.', '_refresh_queue', '_emit_selection_if', 'id'
        pass

    def resumeJob(self, job_id: 'str') -> 'Dict[str, Any]':
        # [PyArmor BCC constants]: '_timemachine_license_blocker', 'timemachine.job.resume', '_jobs', 'get', 'str', '', 'ok', False, 'message', 'Không tìm thấy job.', 'paused', 'id', '_regress_inflight', 'running', 'status'
        pass

    def updateStage(self, stage: 'int', name: 'str', visible: 'str') -> 'Dict[str, Any]':
        # [PyArmor BCC constants]: '_jobs', 'get', '_selected_job_id', 'plan', 'ladder', 0, 'int', 'len', 'ok', False, 'message', 'Stage không hợp lệ.', 'str', '', 'strip'
        pass

    def updateCellPrompt(self, view_id: 'str', stage: 'int', prompt: 'str') -> 'Dict[str, Any]':
        # [PyArmor BCC constants]: '_jobs', 'get', '_selected_job_id', 'plan', '_find_cell', 'ok', False, 'message', 'Không tìm thấy ô keyframe.', 'str', '', 'strip', 'Prompt trạng thái không được để trống.', 'bool', 'locked'
        pass

    def updateMotionPrompt(self, motion_key: 'str', prompt: 'str') -> 'Dict[str, Any]':
        # [PyArmor BCC constants]: '_jobs', 'get', '_selected_job_id', 'ok', False, 'message', 'Chưa chọn job.', 'str', '', 'strip', 'Thiếu mã cặp Start–End.', 'Prompt video không được để trống.', 'isinstance', 'plan', 'dict'
        pass

    def regenerateCell(self, view_id: 'str', stage: 'int') -> 'Dict[str, Any]':
        # [PyArmor BCC constants]: '_timemachine_license_blocker', 'timemachine.keyframe.regenerate', '_jobs', 'get', '_selected_job_id', '_find_cell', 'ok', False, 'message', 'Không tìm thấy ô keyframe.', 'bool', 'locked', 'Không thể tạo lại ảnh neo của người dùng.', '_start_regeneration', 'str'
        pass

    def regenerateStage(self, stage: 'int') -> 'Dict[str, Any]':
        # [PyArmor BCC constants]: '_timemachine_license_blocker', 'timemachine.stage.regenerate', '_jobs', 'get', '_selected_job_id', 'plan', 'list', 'grid', 'views', 'bool', '_find_cell', 'view_id', 'locked', 'str', ''
        pass

    def rebuildVideo(self) -> 'Dict[str, Any]':
        # [PyArmor BCC constants]: '_timemachine_license_blocker', 'timemachine.video.rebuild', '_jobs', 'get', '_selected_job_id', 'ok', False, 'message', 'Chưa chọn job.', '_active_job_id', 'id', 'Một job khác đang chạy.', 'str', 'phase', ''
        pass

    def jobPanelPromptPayload(self, dispatch_job_id: 'str') -> 'Dict[str, Any]':
        # [PyArmor BCC constants]: '_job_panel_model', 'row_by_id', 'str', '', 'ok', False, 'message', 'Không tìm thấy clip trong Job Panel.', 'list', 'get', 'assets', 'start_image_path', 'end_image_path', 0, 'path'
        pass

    def jobPanelViewPayload(self, dispatch_job_id: 'str') -> 'Dict[str, Any]':
        # [PyArmor BCC constants]: '_job_panel_model', 'row_by_id', 'str', '', 'ok', False, 'message', 'Không tìm thấy clip trong Job Panel.', 'get', 'timemachine_job_id', 'strip', '_jobs', 'output_path', 'Clip chưa có file video để xem.', 'path'
        pass

    def setJobPanelReview(self, job_id: 'str', status: 'str') -> 'Dict[str, Any]':
        # [PyArmor BCC constants]: 'set_job_panel_review', '_job_store', 'core_store', 'expected_tab_sources', 'timemachine'
        pass

    def regeneratePanelJob(self, dispatch_job_id: 'str') -> 'Dict[str, Any]':
        # [PyArmor BCC constants]: '_timemachine_license_blocker', 'timemachine.clip.regenerate', 'str', '', 'strip', '_job_panel_model', 'row_by_id', 'ok', False, 'message', 'Không tìm thấy clip cần tạo lại.', 'get', 'timemachine_job_id', '_jobs', '_active_job_id'
        pass

    def _apply_panel_regen_result(self, payload: 'Dict[str, Any]') -> 'None':
        # [PyArmor BCC constants]: 'isinstance', 'get', 'data', 'dict', '_jobs', 'str', 'parent_job_id', 'job_id', '', '_job_feed', 'reload', 'ok', '_set_status', 'error', 'Không thể tạo lại clip.'
        pass

    def moveTimeline(self, from_index: 'int', to_index: 'int') -> 'Dict[str, Any]':
        # [PyArmor BCC constants]: '_jobs', 'get', '_selected_job_id', 'plan', 'deepcopy', 'list', 'edit_timeline', 'timeline', 'int', 'max', 0, 'min', 'len', 1, 'ok'
        pass

    @staticmethod
    def _find_cell(job: 'Dict[str, Any] | None', view_id: 'Any', stage: 'Any') -> 'Dict[str, Any] | None':
        # [PyArmor BCC constants]: 'get', 'plan', 'grid', 'str', '', 'int', 'list', 'cells', 'view_id', 'stage', 0
        pass

    def _start_regeneration(self, job: 'Dict[str, Any] | None', targets: 'list[tuple[str, int]]', *, label: 'str') -> 'Dict[str, Any]':
        # [PyArmor BCC constants]: 'status', 'phase', 'progress', 'message'
        pass

    @staticmethod
    def _schedule_workdir_cleanup(work_dir: 'str', delay_s: 'float' = 0.0) -> 'None':
        # [PyArmor BCC constants]: 'str', '', 'strip', 'cleanup_time_machine_workdir', 'threading', 'Timer', 'max', 0.0, 'float', True, 'daemon', 'TimeMachineTempCleanup', 'name', 'start'
        pass

    def _run_worker(self, *, name: 'str', job_id: 'str', work: 'Callable[[], Dict[str, Any]]', signal: 'Any') -> 'None':
        # [PyArmor BCC constants]: 'ok', 'job_id', 'data', True, 'blocked', 'error', 'code', False, 'Không có tài khoản sẵn sàng để chuẩn bị ảnh.', 'account_not_ready', '_TimeMachineAccountUnavailable', 'print', '[TimeMachine][Worker] job_id=', '\n', 'traceback'
        pass

    def _start_next(self) -> 'None':
        # [PyArmor BCC constants]: 'status', 'phase', 'progress', 'message'
        pass

    def _begin_planning(self, job: 'Dict[str, Any]') -> 'None':
        # [PyArmor BCC constants]: 'status', 'phase', 'progress', 'message'
        pass

    def _apply_plan_result(self, payload: 'Dict[str, Any]') -> 'None':
        # [PyArmor BCC constants]: 'repairable', 'error_code', 'chapter_id', 'error_path'
        pass

    def _launch_regress(self, job_id: 'str') -> 'None':
        # [PyArmor BCC constants]: 'status', 'phase', 'progress', 'message', 'product_completion', 'product_ready'
        pass

    def _apply_cell_progress(self, payload: 'Dict[str, Any]') -> 'None':
        # [PyArmor BCC constants]: '_jobs', 'get', 'str', 'job_id', '', 'isinstance', 'cell', 'dict', 'active_view_id', 'view_id', 'strip', 'int', 'active_stage', 'stage', 0
        pass

    def _apply_regress_result(self, payload: 'Dict[str, Any]') -> 'None':
        # [PyArmor BCC constants]: 'prepared', 'status', 'phase', 'progress', 'message'
        pass

    def _apply_regenerate_result(self, payload: 'Dict[str, Any]') -> 'None':
        # [PyArmor BCC constants]: '_jobs', 'get', 'str', 'job_id', '', 'ok', '_consume_worker_account_blocker', '_fail_job', 'error', 'Regenerate failed', 'data', 'plan', 'output_dir', 'dict', 'motion_prompts'
        pass

    def _build_current_i2v(self, job: 'Dict[str, Any]') -> 'Dict[str, Any]':
        # [PyArmor BCC constants]: 'build_i2v_plan', 'ladder_for_view', 'resource_timeline_for_plan', 'PIPELINE_CONSTRUCTION', 'is_start_only_i2v', 'pipeline_kind_for_plan', 'plan', 'dict', 'get', 'config', '_config', 'list', 'grid', 'views', 'str'
        pass

    def _start_picture_output(self, job_id: 'str') -> 'None':
        # [PyArmor BCC constants]: '_jobs', 'get', 'is_images_narration', 'config', '_launch_still_slideshow', '_launch_dispatch'
        pass

    def _launch_still_slideshow(self, job_id: 'str') -> 'None':
        # [PyArmor BCC constants]: '_jobs', 'get', 'update', 'status', 'running', 'phase', 'still_slideshow', 'progress', 'max', 67, 'int', 0, 'message', 'Đang xuất ảnh mốc và dựng slideshow lời dẫn', '_refresh_queue'
        pass

    def _apply_still_slideshow_result(self, payload: 'Dict[str, Any]') -> 'None':
        # [PyArmor BCC constants]: 'str', 'get', 'job_id', '', '_jobs', 'ok', '_fail_job', 'error', 'Không xuất được slideshow ảnh.', 'dict', 'data', 'list', 'rendered_clips', 'Slideshow ảnh không có clip nào.', 'deepcopy'
        pass

    def _launch_dispatch(self, job_id: 'str') -> 'None':
        # [PyArmor BCC constants]: '_jobs', 'get', '_dispatch_inflight', 'update', 'status', 'running', 'phase', 'dispatching', 'message', 'Worker dispatch đang tiếp tục; không submit I2V trùng.', '_refresh_queue', 'next_child_i2v_plan', 'i2v', 'rendered_clips', '_fail_job'
        pass

    def _apply_dispatch_result(self, payload: 'Dict[str, Any]') -> 'None':
        # [PyArmor BCC constants]: 'str', 'get', 'job_id', '', '_dispatch_inflight', 'discard', '_jobs', 'ok', '_fail_job', 'error', 'Dispatch failed', 'data', 'i2v', 'list', 'submitted_job_ids'
        pass

    def _on_job_event(self, dispatch_job_id: 'str') -> 'None':
        # [PyArmor BCC constants]: '_jobs', 'get', '_active_job_id', 'dispatch_job_ids', '_check_render_jobs', 'id'
        pass

    def _check_render_jobs(self, job_id: 'str') -> 'None':
        # [PyArmor BCC constants]: 'parent_job_id', 'stage', 'from_seq', 'to_seq', 'elapsed_ms', 'child_job_id', 'status'
        pass

    def _dispatch_remaining_or_merge(self, job_id: 'str') -> 'None':
        # [PyArmor BCC constants]: '_jobs', 'get', 'first_unrendered_job', 'list', 'rendered_clips', '_build_current_i2v', '_fail_job', 'Không kiểm tra được cảnh I2V cuối: ', 'Exception', 'i2v', 'str', 'clip_kind', '', 'final_reveal', 'update'
        pass

    def _continue_after_clip(self, job_id: 'str') -> 'None':
        # [PyArmor BCC constants]: '_jobs', 'get', 'resource_timeline_for_plan', 'next_continuous_pair', 'uses_live_last_frame', 'PIPELINE_LIVE_WINDOW', 'pipeline_kind_for_plan', 'str', 'pipeline_kind', '', 'plan', '_dispatch_remaining_or_merge', 'list', 'rendered_clips', 1
        pass

    def _launch_live_chain(self, job_id: 'str', previous_clip: 'Mapping[str, Any]', start_node: 'Mapping[str, Any]', end_node: 'Mapping[str, Any]') -> 'None':
        # [PyArmor BCC constants]: 'status', 'phase', 'message', 'live_chain_stage'
        pass

    def _apply_live_chain_result(self, payload: 'Dict[str, Any]') -> 'None':
        # [PyArmor BCC constants]: 'str', 'get', 'job_id', '', '_jobs', 'ok', '_fail_job', 'error', 'Live chain failed', 'dict', 'data', 'metrics', 'start_cell', 'end_cell', '_live_chain_metric'
        pass

    def _launch_merge(self, job_id: 'str', clips: 'list[Dict[str, Any]]', *, message: 'str' = 'Đang ghép video') -> 'None':
        # [PyArmor BCC constants]: 'phase', 'status', 'progress', 'message'
        pass

    @staticmethod
    def _clips_for_timeline(job: 'Dict[str, Any]', timeline: 'list[Dict[str, Any]]') -> 'tuple[list[Dict[str, Any]], list[tuple[str, int, int]]]':
        # [PyArmor BCC constants]: 'list', 'get', 'rendered_clips', 'str', 'view_id', '', 'int', 'start_stage', 0, 'end_stage', 'enumerate', 1, 'edge_to_next', 'continuous', 'stage'
        pass

    def _apply_merge_result(self, payload: 'Dict[str, Any]') -> 'None':
        # [PyArmor BCC constants]: '_jobs', 'get', 'str', 'job_id', '', 'ok', 'error', 'Merge failed', 'mark_product_stage', 'product_completion', 'merge', 'failed', '_fail_job', 'data', 'isinstance'
        pass

    def _launch_publish_kit(self, job: 'Dict[str, Any]') -> 'None':
        # [PyArmor BCC constants]: 'bool', 'get', '_publish_kit_started', 'require_checkpoint', 'causal_state', 'publish_kit', True, 'mark_product_stage', 'product_completion', 'running', 'thumbnail', 'update', 'phase', 'progress', 'max'
        pass

    def _apply_publish_kit_result(self, payload: 'Dict[str, Any]') -> 'None':
        # [PyArmor BCC constants]: '_jobs', 'get', 'str', 'job_id', '', 'isinstance', 'result', 'dict', 'mark_publish_kit_result', 'mark_checkpoint', 'causal_state', 'publish_kit', 'ok', 'publish_info_path', 'thumbnail_path'
        pass

    def _finalize_timemachine_product(self, job: 'Dict[str, Any]') -> 'None':
        # [PyArmor BCC constants]: 'project_product_readiness', 'bool', 'get', 'product_ready', 'str', 'product_status', 'running', 'product_phase', 'phase', '', 'list', 'pending_product_stages', 'dict', 'product_completion', 'stages'
        pass

    def _project_dispatch_job(self, raw: 'Dict[str, Any]') -> 'Dict[str, Any]':
        # [PyArmor BCC constants]: 'dict', 'get', 'meta', '_prompt_data', '_regen_prompt_data', 'isinstance', 'str', 'timemachine_clip_kind', 'transition', 'start_image_path', '', 'strip', 'end_image_path', 'append', 'path'
        pass

    def _public_job(self, job: 'Dict[str, Any]') -> 'Dict[str, Any]':
        # [PyArmor BCC constants]: 'isinstance', 'get', 'plan', 'dict', '_active_view_projection', 'causal_graph', 'final_reveal', 'phase_projection', 'str', 'phase', '', 'int', 'progress', 0, 'causal_projection'
        pass

    def _refresh_queue(self) -> 'None':
        pass

    def _schedule_automation_projection(self) -> 'None':
        pass

    def _flush_automation_projections(self) -> 'None':
        # [PyArmor BCC constants]: 'tuple', '_automation_parent_ids', '_jobs', 'get', 'append', 'str', '_automation_request_id', '', 'strip', 'target_run_id', 'automation_request_id', 'status', 'phase', 'progress', 'paused'
        pass

    def shutdown(self) -> 'None':
        # [PyArmor BCC constants]: 'getattr', '_automation_bridge', 'shutdown', '_automation_projection_timer', 'stop'
        pass

    @staticmethod
    def _runtime_status(state: 'Any') -> 'tuple[str, int]':
        # [PyArmor BCC constants]: 'str', 'getattr', 'status', 'value', '', 'lower', 'max', 0, 'min', 100, 'int', 'float', 'progress', 'complete', 'completed'
        pass

    def _live_chain_runtime(self, job: 'Mapping[str, Any]') -> 'Dict[str, Any]':
        # [PyArmor BCC constants]: 'project_live_chain_runtime', 'isinstance', 'get', 'plan', 'Mapping', 'list', 'resource_timeline', 'timeline', 'dict', 'child_job_ids_by_pair', 'items', 'str', 'split', ':', 1
        pass

    def _motion_runtime_by_key(self, job: 'Mapping[str, Any]') -> 'Dict[str, Dict[str, Any]]':
        # [PyArmor BCC constants]: 'dict', 'get', 'child_job_ids_by_pair', 'list', 'rendered_clips', 'isinstance', 'Mapping', 'from_seq', 'to_seq', 'int', 'enumerate', 'TypeError', 'ValueError', 'str', 'view_id'
        pass

    def _refresh_motion_runtime(self, job: 'Mapping[str, Any]') -> 'None':
        # [PyArmor BCC constants]: 'str', 'get', 'id', '', '_selected_job_id', '_motion_runtime_by_key', 'enumerate', '_motion_model', 'rows', 'motionKey', 'update_row'
        pass

    def _load_selected_models(self) -> 'None':
        # [PyArmor BCC constants]: 'rowIdx', 'viewId', 'viewLabel', 'stageIdx', 'status', 'imagePath', 'locked', 'onTimeline', 'edgeToNext', 'seqBadge', 'source', 'regressPrompt'
        pass

    def _fail_job(self, job: 'Dict[str, Any]', message: 'str', repairable: 'bool' = False, error_code: 'str' = '', chapter_id: 'str' = '', error_path: 'str' = '') -> 'None':
        # [PyArmor BCC constants]: 'str', '', 'strip', '_timemachine_user_error', 'bool', '_timemachine_repairable_error', 'print', '[TimeMachine][TechnicalError] job=', 'get', 'id', ': ', 'flush', True, 'update', 'status'
        pass

    def _focus_job(self, job_id: 'str') -> 'None':
        # [PyArmor BCC constants]: 'str', '', '_jobs', '_selected_job_id', '_load_selected_models', 'selectionChanged', 'emit'
        pass

    def _emit_selection_if(self, job_id: 'str') -> 'None':
        pass

    def _set_status(self, value: 'str') -> 'None':
        # [PyArmor BCC constants]: 'str', '', '_status', 'statusChanged', 'emit'
        pass


# --- Class: VoiceController ---
class VoiceController(QObject):
    """Thin Qt adapter — exposes VoiceAPI + VoiceStudioService to QML."""
    _LOCAL_PRESET_KEY = 'voice_studio_local_presets'
    staticMetaObject = PySide6.QtCore.QMetaObject("VoiceController" inherits "QObject":
Properties:
  #1 "provider", QString [designable], noti...

    providerChanged = Signal()
    optionsChanged = Signal()
    queueRowsChanged = Signal()
    statsChanged = Signal()
    historyChanged = Signal()
    settingsChanged = Signal()
    providerOptionsChanged = Signal()
    ttsModeChanged = Signal()
    sharedTtsConfigChanged = Signal()
    _sharedTtsReady = Signal()
    _localTtsReady = Signal()
    _engineHardwareReady = Signal()
    _runtimeTelemetryReady = Signal()
    runtimeTelemetryChanged = Signal()
    _omniProfilesReady = Signal()
    ttsSchemaChanged = Signal()
    localTtsChanged = Signal()
    busyChanged = Signal()
    playbackChanged = Signal()
    localTtsBusyChanged = Signal()
    lastJobIdChanged = Signal()
    statusMessageChanged = Signal()
    actionResultChanged = Signal()
    outputModeChanged = Signal()
    videoConfigChanged = Signal()
    videoRowsChanged = Signal()
    localVoicePresetsChanged = Signal()
    omniProfileOptionsChanged = Signal()
    omniCandidateChanged = Signal()
    omniProfileBusyChanged = Signal()
    omniProfileApproved = Signal()
    voiceConfigPresetsChanged = Signal()
    voiceConfigPresetBusyChanged = Signal()
    _workerResultReady = Signal()
    ttsPickerRequested = Signal()
    narrationSelectionChanged = Signal()
    narrationSelectionBusyChanged = Signal()
    def __init__(self) -> 'None':
        # [PyArmor BCC constants]: 'ok', 'blocked', 'action', 'code', 'message', 'blocker'
        pass

    def _initial_load(self) -> 'None':
        # [PyArmor BCC constants]: '_refresh_providers', '_load_settings', 'refreshOptions', 'refresh', 'refreshHistory', 'refreshLocalTts', 'refreshVideo'
        pass

    @staticmethod
    def _get_vs() -> 'Any':
        pass

    def provider(*args, **kwargs):
        pass

    def providers(*args, **kwargs):
        pass

    def voices(*args, **kwargs):
        pass

    def models(*args, **kwargs):
        pass

    def ttsPresets(*args, **kwargs):
        pass

    def directorStyles(*args, **kwargs):
        pass

    def directorPaces(*args, **kwargs):
        pass

    def directorAccents(*args, **kwargs):
        pass

    def ttsRoutes(*args, **kwargs):
        pass

    def listEngineVoices(self, engine: 'str') -> 'list[dict[str, str]]':
        # [PyArmor BCC constants]: 'get_engine', 'list', 'list_voices', 'Exception'
        pass

    def listEngineStyles(self, engine: 'str') -> 'list[dict[str, str]]':
        # [PyArmor BCC constants]: 'get_engine', 'list', 'list_styles', 'Exception'
        pass

    def engineStatus(self, engine: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'engine_status', 'dict', 'state', 'installed', 'progress', 'message', 'error', False, 0, 'str', 120, 'Exception'
        pass

    def runtimeTelemetry(*args, **kwargs):
        pass

    def setRuntimeTelemetryActive(self, active: 'bool', engine: 'str') -> 'None':
        # [PyArmor BCC constants]: '_t', 'lower', 'omnivoice', 'vieneu', 'moss', 'moss_nano', '_runtime_telemetry_timer', 'stop', '', '_runtime_telemetry_engine', '_runtime_telemetry', 'runtimeTelemetryChanged', 'emit', 'isActive', 'start'
        pass

    def _sample_runtime_telemetry(self) -> 'None':
        # [PyArmor BCC constants]: '_runtime_telemetry_inflight', '_runtime_telemetry_engine', True, 'sample_runtime_telemetry', '_runtimeTelemetryReady', 'emit', 'threading', 'Thread', 'target', 'daemon', 'name', 'TtsRuntimeTelemetry', 'start'
        pass

    def _apply_runtime_telemetry(self, payload: 'dict[str, Any]') -> 'None':
        # [PyArmor BCC constants]: False, '_runtime_telemetry_inflight', '_t', 'get', 'engine', 'lower', '_runtime_telemetry_engine', 'dict', '_runtime_telemetry', 'runtimeTelemetryChanged', 'emit'
        pass

    def _prewarm_engine_hardware(self) -> 'None':
        # [PyArmor BCC constants]: 'prewarm_engine_tts_verdicts', 'print', '⚠️ [Voice] hardware probe failed: ', 'Exception', '_engineHardwareReady', 'emit'
        pass

    def _start_engine_hardware_probe(self) -> 'None':
        # [PyArmor BCC constants]: 'threading', 'Thread', 'target', '_prewarm_engine_hardware', 'daemon', True, 'name', 'TtsHardwareProbe', 'start'
        pass

    def _apply_engine_hardware_ready(self) -> 'None':
        pass

    def omniProfileOptions(*args, **kwargs):
        pass

    def omniRecipeOptions(*args, **kwargs):
        pass

    def omniProfileModel(*args, **kwargs):
        pass

    def omniCandidate(*args, **kwargs):
        pass

    def omniProfileBusy(*args, **kwargs):
        pass

    def voiceConfigPresetModel(*args, **kwargs):
        pass

    def voiceConfigPresetCount(*args, **kwargs):
        pass

    def voiceConfigPresetBusy(*args, **kwargs):
        pass

    def _set_voice_config_preset_busy(self, value: 'bool') -> 'None':
        # [PyArmor BCC constants]: 'bool', '_voice_config_preset_busy', 'voiceConfigPresetBusyChanged', 'emit'
        pass

    def _set_voice_config_presets(self, rows: 'list[dict[str, Any]]') -> 'None':
        # [PyArmor BCC constants]: 'isinstance', 'dict', '_t', 'get', 'id', '_voice_config_presets', '_voice_config_preset_model', 'setRows', 'voiceConfigPresetsChanged', 'emit'
        pass

    def refreshVoiceConfigPresets(self) -> 'None':
        # [PyArmor BCC constants]: '_voice_config_preset_busy', '_set_voice_config_preset_busy', True, '_start_worker', 'voice_config_preset_list'
        pass

    def saveVoiceConfigPreset(self, name: 'str', provider: 'str', config: 'dict[str, Any]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_voice_config_preset_busy', 'ok', False, 'message', 'Thư viện cấu hình đang được cập nhật.', '_t', 'Hãy đặt tên cho cấu hình.', '_set_voice_config_preset_busy', True, '_start_worker', 'voice_config_preset_save', 'name', 'provider', 'config', 'gemini'
        pass

    def renameVoiceConfigPreset(self, preset_id: 'str', name: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_voice_config_preset_busy', 'ok', False, 'message', 'Thư viện cấu hình đang được cập nhật.', '_t', 'Thiếu cấu hình hoặc tên mới.', '_set_voice_config_preset_busy', True, '_start_worker', 'voice_config_preset_rename', 'preset_id', 'name', 'Đang đổi tên cấu hình…'
        pass

    def updateVoiceConfigPreset(self, preset_id: 'str', provider: 'str', config: 'dict[str, Any]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_voice_config_preset_busy', 'ok', False, 'message', 'Thư viện cấu hình đang được cập nhật.', '_t', 'Chưa chọn cấu hình cần cập nhật.', '_set_voice_config_preset_busy', True, '_start_worker', 'voice_config_preset_update', 'preset_id', 'provider', 'config', 'gemini'
        pass

    def removeVoiceConfigPreset(self, preset_id: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_voice_config_preset_busy', 'ok', False, 'message', 'Thư viện cấu hình đang được cập nhật.', '_t', 'Chưa chọn cấu hình cần xóa.', '_set_voice_config_preset_busy', True, '_start_worker', 'voice_config_preset_delete', 'preset_id', 'Đang xóa cấu hình…'
        pass

    def voiceConfigPreset(self, preset_id: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_t', '_voice_config_presets', 'get', 'id', 'ok', True, 'dict', False, 'message', 'Không tìm thấy cấu hình đã lưu.'
        pass

    def _set_omni_profile_busy(self, value: 'bool') -> 'None':
        # [PyArmor BCC constants]: 'bool', '_omni_profile_busy', 'omniProfileBusyChanged', 'emit'
        pass

    def _set_omni_profiles(self, rows: 'list[dict[str, Any]]') -> 'None':
        # [PyArmor BCC constants]: 'isinstance', 'dict', '_t', 'get', 'value', 'id', '_omni_profile_options', '_omni_profile_model', 'setRows', 'omniProfileOptionsChanged', 'emit'
        pass

    def refreshOmniProfiles(self, server_url: 'str') -> 'None':
        # [PyArmor BCC constants]: '_omni_profile_busy', '_set_omni_profile_busy', True, '_start_worker', 'omni_profile_list', 'server_url', 'start', '_t', False
        pass

    def activateOmniProfileLibrary(self, server_url: 'str') -> 'None':
        # [PyArmor BCC constants]: '_omni_profile_busy', '_set_omni_profile_busy', True, '_start_worker', 'omni_profile_list', 'server_url', 'start', '_t', False
        pass

    def syncOmniProfiles(self, server_url: 'str') -> 'None':
        # [PyArmor BCC constants]: '_omni_profile_busy', '_set_omni_profile_busy', True, '_start_worker', 'omni_profile_list', 'server_url', 'start', '_t'
        pass

    def _apply_omni_profiles(self, payload: 'dict[str, Any]') -> 'None':
        # [PyArmor BCC constants]: 'int', 'get', 'generation', 0, '_omni_profiles_generation', False, '_omni_profiles_inflight', 'ok', '_set_omni_profiles', 'list', 'profiles', 'print', '🎙️ [OmniVoice] profiles count=', 'len', '_omni_profile_options'
        pass

    def ensureEngine(self, engine: 'str') -> 'None':
        # [PyArmor BCC constants]: 'ensure_engine_async', 'str', '', 'print', '⚠️ [Voice] ensureEngine(', ') failed: ', 'Exception'
        pass

    def ttsPresetPayload(self, preset_id: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'get_preset', 'ok', 'id', False, '_t', 'enumerate', 'speakers', 2, '_speaker_row', 'name', 'scene', 'sample_context', 'dialogue_enabled', 'voice', True
        pass

    def applyTtsPreset(self, preset_id: 'str') -> 'None':
        # [PyArmor BCC constants]: 'ttsPresetPayload', 'get', 'ok', 'dict', '_provider_options', 'list', 'speakers', 'update', 'scene', 'sample_context', 'dialogue_enabled', 'preset_id', 'audio_profile', 'director_notes', ''
        pass

    def queueRows(*args, **kwargs):
        pass

    def jobPanelRows(*args, **kwargs):
        pass

    def stats(*args, **kwargs):
        pass

    def history(*args, **kwargs):
        pass

    def queueRowsModel(*args, **kwargs):
        pass

    def historyModel(*args, **kwargs):
        pass

    def outputFolder(*args, **kwargs):
        pass

    def providerOptions(*args, **kwargs):
        pass

    def ttsMode(*args, **kwargs):
        pass

    def sharedTtsConfig(*args, **kwargs):
        pass

    def ttsSchema(*args, **kwargs):
        pass

    def localTts(*args, **kwargs):
        pass

    def busy(*args, **kwargs):
        pass

    def playbackPath(*args, **kwargs):
        pass

    def playbackTitle(*args, **kwargs):
        pass

    def playbackDuration(*args, **kwargs):
        pass

    def playbackStartedAt(*args, **kwargs):
        pass

    def playbackActive(*args, **kwargs):
        pass

    def localTtsBusy(*args, **kwargs):
        pass

    def lastJobId(*args, **kwargs):
        pass

    def statusMessage(*args, **kwargs):
        pass

    def lastAction(*args, **kwargs):
        pass

    def actionStatus(*args, **kwargs):
        pass

    def outputMode(*args, **kwargs):
        pass

    def videoConfig(*args, **kwargs):
        pass

    def videoJobRows(*args, **kwargs):
        pass

    def videoJobModel(*args, **kwargs):
        pass

    def imageModelOptions(*args, **kwargs):
        pass

    def setOutputMode(self, mode: 'str') -> 'None':
        # [PyArmor BCC constants]: '_vs', 'set_mode', '_t', 'outputModeChanged', 'emit', 'videoConfigChanged', '_set_status', 'Output mode: ', 'upper'
        pass

    def setVideoOption(self, key: 'str', value: 'Any') -> 'None':
        # [PyArmor BCC constants]: '_vs', 'get_config', 'output_mode', 'set_mode_option', '_t', 'videoConfigChanged', 'emit'
        pass

    def modeConfig(self, mode: 'str') -> 'dict[str, Any]':
        pass

    def setModeOption(self, mode: 'str', key: 'str', value: 'Any') -> 'None':
        # [PyArmor BCC constants]: '_vs', 'set_mode_option', '_t', 'videoConfigChanged', 'emit'
        pass

    def referenceLimits(self) -> 'dict[str, int]':
        pass

    def _feature_blocked(self, action: 'str') -> 'dict[str, Any] | None':
        # [PyArmor BCC constants]: 'feature_blocker', 'voice_studio', '_set_action_result', 'action', 'fallback', 'str', 'get', 'message', ''
        pass

    def submitStoryVideo(self, text: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_feature_blocked', 'voice.submit', '_vs', 'submit', '_t', 'refreshVideo', '_set_action_result', 'action', 'fallback', 'str', 'get', 'message', 'Submitted'
        pass

    def refreshVideo(self) -> 'None':
        # [PyArmor BCC constants]: '_vs', 'list_job_panel_rows', '_video_rows', '_set_status', 'Video refresh failed: ', 'type', '__name__', 'Exception', 'sync_job_panel_rows', '_video_job_panel_model', 'qml_rows', '_video_job_panel_rows', '_emit_gate', 'changed', 'video'
        pass

    def startVideoQueue(self) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_feature_blocked', 'voice.video.start', '_vs', 'start_queue', '_set_action_result', 'action', 'fallback', 'Queue started', 'refreshVideo'
        pass

    def pauseVideoQueue(self) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_vs', 'pause_queue', '_set_action_result', 'action', 'voice.video.pause', 'fallback', 'Queue paused', 'refreshVideo'
        pass

    def clearVideoQueue(self) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_vs', 'clear_queue', '_set_action_result', 'action', 'voice.video.clear', 'fallback', 'Queue cleared', 'refreshVideo'
        pass

    def removeVideoRow(self, row_id: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_vs', 'remove_job', '_t', '_set_action_result', 'action', 'voice.video.remove', 'fallback', 'Row removed', 'refreshVideo'
        pass

    def retryVideoRow(self, row_id: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_vs', 'retry_job', '_t', '_set_action_result', 'action', 'voice.video.retry', 'fallback', 'Row retried', 'refreshVideo'
        pass

    def _video_batch_full_loader(self) -> 'list[dict[str, Any]]':
        # [PyArmor BCC constants]: '_vs', 'list_jobs', 'get', 'rows', 'isinstance', 'dict', '_t', 'mode', 'video'
        pass

    def _connect_auto_merge_service(self) -> 'None':
        # [PyArmor BCC constants]: '_auto_merge_connected', 'get_auto_merge_service', 'merge_completed', 'connect', '_on_auto_merge_completed', True, 'print', '[VoiceStudio] auto-merge wiring failed: ', 'flush', 'Exception'
        pass

    def _on_auto_merge_completed(self, output_folder: 'str', source_tab: 'str', success: 'bool', output_path: 'str', error: 'str') -> 'None':
        # [PyArmor BCC constants]: '_t', 'voice_studio', '_vs', 'record_auto_merge_completion', 'bool', 'Exception', 'refreshVideo'
        pass

    def setProvider(self, provider: 'str') -> 'None':
        # [PyArmor BCC constants]: '_normalize_provider', '_provider', '_flush_pending_options', 'providerChanged', 'emit', '_svc', 'apply_state', 'tts_provider', '_load_provider_options', '_refresh_tts_schema', '_refresh_shared_tts_config', 'refreshOptions', '_set_status', 'Voice provider: '
        pass

    def setTtsMode(self, mode: 'str') -> 'None':
        # [PyArmor BCC constants]: '_t', 'lower', 'auto', 'manual', '_tts_mode', '_svc', 'apply_state', 'tts_mode', 'ttsModeChanged', 'emit', '_refresh_shared_tts_config', '_set_status', 'TTS mode: ', 'upper'
        pass

    def setVoice(self, voice_id: 'str') -> 'None':
        # [PyArmor BCC constants]: '_t', '_svc', 'apply_state', 'tts_voice', '_refresh_shared_tts_config', 'settingsChanged', 'emit'
        pass

    def setModel(self, model: 'str') -> 'None':
        # [PyArmor BCC constants]: '_t', '_svc', 'apply_state', 'tts_model', '_refresh_shared_tts_config', 'settingsChanged', 'emit'
        pass

    def getSharedTtsConfig(self) -> 'dict[str, Any]':
        pass

    def getTtsConfigSchema(self, provider: 'str' = '') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'dict', '_svc', 'tts_config_schema', '_provider', 'ok', 'error', 'message', False, 'type', '__name__', 'str', 200, 'Exception'
        pass

    def refresh(self) -> 'None':
        # [PyArmor BCC constants]: '_coerce_rows', '_svc', 'list_queue', 'queue', '_queue_rows', 'dict', 'get_stats', '_stats', 'total', 0, 'pending', 'failed', 'Exception', '_queue_rows_model', 'setRows'
        pass

    def refreshHistory(self) -> 'None':
        # [PyArmor BCC constants]: '_svc', 'list_history', '_coerce_rows', 'history', '_history', '_t', 'get', 'folder', '_output_folder', 'settingsChanged', 'emit', 'Exception', '_history_model', 'setRows', 'historyChanged'
        pass

    def refreshLocalTts(self) -> 'None':
        # [PyArmor BCC constants]: '_local_tts_inflight', True, 'ok', 'status', 'dict', '_svc', 'local_tts_status', False, 'Exception', '_localTtsReady', 'emit', 'Thread', 'target', 'daemon', 'name'
        pass

    def _apply_local_tts(self, payload: 'dict[str, Any]') -> 'None':
        # [PyArmor BCC constants]: False, '_local_tts_inflight', 'get', 'ok', 'status', '_local_tts', 'installed', 'running', 'version', '', 'device', 'localTtsChanged', 'emit'
        pass

    def refreshOptions(self) -> 'None':
        # [PyArmor BCC constants]: '_refresh_providers', '_start_worker', 'refresh_options', 'provider', '_provider'
        pass

    def _apply_options(self, payload: 'dict[str, Any]') -> 'None':
        # [PyArmor BCC constants]: '_provider', 'get', 'voices', '_voice_option', 'label', 'Default', 'value', 'default', 'flag', '', 'secondary', '_voices', 'models', '_model_option', '_models'
        pass

    def generateSingle(self, text: 'str', voice_id: 'str' = 'default', model: 'str' = 'default') -> 'None':
        # [PyArmor BCC constants]: '_feature_blocked', 'voice.generate_single', '_busy', '_set_status', 'Voice generation is already running', '_t', 'No voice text', '_execution_provider_options_payload', 'default', '_provider', 'omnivoice', 'get', 'omni_voice', '_set_busy', True
        pass

    def addToQueue(self, text: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_t', 'splitlines', 'strip', 'ok', False, 'blocked', 'action', 'add_to_queue', 'error', 'no_voice_text', 'code', 'message', 'No voice text', '_set_action_result', 'fallback'
        pass

    def addBlockToQueue(self, text: 'str', title: 'str' = '') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_t', 'strip', 'ok', False, 'blocked', 'action', 'add_to_queue', 'error', 'no_voice_text', 'code', 'message', 'No voice text', '_set_action_result', 'fallback', '_execution_provider_options_payload'
        pass

    def importText(self, source: 'str') -> 'str':
        # [PyArmor BCC constants]: '_svc', 'import_script', 'source', 'get', 'ok', '_set_status', '_t', 'message', 'error', 'Import failed', '', 'text', 'Imported ', 'line_count', 0
        pass

    def startQueue(self) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_busy', 'ok', False, 'blocked', 'action', 'start_queue', 'error', 'voice_generation_busy', 'code', 'message', 'Voice generation is already running', '_set_action_result', 'fallback', '_set_busy', True
        pass

    def pauseQueue(self) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_svc', 'pause_queue', '_set_action_result', 'action', 'fallback', 'Voice queue pause requested', 'refresh'
        pass

    def clearQueue(self) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_svc', 'clear_queue', '_set_action_result', 'action', 'fallback', 'Voice queue cleared', 'refresh'
        pass

    def clearCompletedQueue(self) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'dict', '_svc', 'clear_completed_queue', '_set_action_result', 'action', 'fallback', 'Cleared completed rows', 'refresh'
        pass

    def stopCurrentGeneration(self) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'dict', '_svc', 'cancel_current_generation', '_set_action_result', 'action', 'fallback', 'Stop requested'
        pass

    def skipCurrentQueueRow(self, row_id: 'str' = '') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'dict', '_svc', 'skip_current_voice_row', '_t', '_set_action_result', 'action', 'fallback', 'Skip requested'
        pass

    def removeRow(self, row_id: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_t', 'ok', False, 'blocked', 'action', 'remove_row', 'error', 'missing_row_id', 'message', 'Missing row id', 'dict', '_svc', 'setdefault', 'Voice row removed', '_set_action_result'
        pass

    def retryRow(self, row_id: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_t', 'ok', False, 'action', 'retry_row', 'error', 'missing_row_id', 'message', 'Missing row id', 'dict', '_svc', 'setdefault', '_set_action_result', 'fallback', 'Voice row retried'
        pass

    def mergeAudio(self, paths: 'Any') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'str', '', 'strip', 'dict', '_svc', 'merge_audio', '_output_folder', 'ok', 'message', False, 'type', '__name__', ': ', 'Exception', '_set_action_result'
        pass

    def skipRow(self, row_id: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_t', 'ok', False, 'action', 'skip_row', 'error', 'missing_row_id', 'message', 'Missing row id', 'dict', '_svc', 'setdefault', '_set_action_result', 'fallback', 'Voice row skipped'
        pass

    def previewVoice(self, voice_id: 'str') -> 'None':
        # [PyArmor BCC constants]: '_voice_sample_path', 'startPlayback', 'str', 'Nghe thử — ', '_t', '_flush_pending_options', '_svc', 'preview_voice', 'provider', '_provider', 'job_id', '_last_job_id', '_set_action_result', 'action', 'fallback'
        pass

    @staticmethod
    def _voice_sample_path(voice_id: 'str'):
        pass

    def previewQueuedRow(self, row_id: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'dict', '_svc', 'preview_queue_row', '_t', 'get', 'job_id', 'ok', '_last_job_id', 'lastJobIdChanged', 'emit', '_set_action_result', 'action', 'fallback', 'Preview ready'
        pass

    def saveAudio(self, job_id: 'str' = '') -> 'None':
        # [PyArmor BCC constants]: '_svc', 'save_audio', '_last_job_id', '_set_action_result', 'action', 'fallback', 'Audio save requested'
        pass

    def playAudio(self, path: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'Path', 'startPlayback', '_t', 'name'
        pass

    @staticmethod
    def _ffplay_exe() -> 'str':
        # [PyArmor BCC constants]: 'Path', 'str', 'ffmpeg_binary', 'ffplay', 'exists', 'Exception'
        pass

    @staticmethod
    def _audio_duration_s(path) -> 'float':
        # [PyArmor BCC constants]: 'open', 'str', 'getframerate', 1, 'getnframes', 'float', 'Exception', 'name', 'nt', 'CREATE_NO_WINDOW', 0, 'run', 'ffmpeg_binary', 'ffprobe', '-v'
        pass

    def startPlayback(self, path: 'str', title: 'str' = '') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'Path', 'stopPlayback', '_t', 'expanduser', 'exists', 'ok', 'code', 'message', False, 'audio_path_missing', 'Not found: ', '_set_action_result', 'action', 'voice.play_audio', 'fallback'
        pass

    def stopPlayback(self) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_playback_proc', '_playback_timer', 'stop', 'poll', 'kill', 'Exception', 'playbackChanged', 'emit', 'ok', True
        pass

    def _poll_playback(self) -> 'None':
        # [PyArmor BCC constants]: '_playback_proc', 'poll', '_playback_timer', 'stop', 'playbackChanged', 'emit'
        pass

    def stopAudio(self) -> 'dict[str, Any]':
        pass

    def playQueuedRowAudio(self, row_id: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'dict', '_svc', 'preview_queue_row', '_last_job_id', '_t', 'get', 'path', 'audio_path', 'ok', 'playAudio', '_set_action_result', 'action', 'voice.play_queued', 'fallback', 'Audio not ready'
        pass

    def configureProviderOptions(self, options: 'dict[str, Any]') -> 'None':
        # [PyArmor BCC constants]: 'dict', 'normalize_omni_state', '_options_to_state_delta', '_provider_options', 'providerOptionsChanged', 'emit', '_pending_state_delta', 'update', '_persist_timer', 'start', '_shared_cfg_timer'
        pass

    def narrationProviderOptions(*args, **kwargs):
        pass

    def narrationSelectionBusy(*args, **kwargs):
        pass

    def _set_narration_selection_busy(self, value: 'bool') -> 'None':
        # [PyArmor BCC constants]: 'bool', '_narration_selection_busy', 'narrationSelectionBusyChanged', 'emit'
        pass

    def requestSharedTtsPicker(self, context: 'str' = '') -> 'None':
        # [PyArmor BCC constants]: 'ttsPickerRequested', 'emit', '_t', 'shared'
        pass

    def omniProfileSamplePath(self, profile_id: 'str') -> 'str':
        # [PyArmor BCC constants]: '_t', '', '_omni_profile_options', 'get', 'id', 'value', 'audio_path', 'len', 3, 1, ':', 'startswith', '\\\\', '/'
        pass

    def omniVoiceLabel(self, selection: 'str') -> 'str':
        # [PyArmor BCC constants]: '_t', '_omni_profile_options', 'get', 'value', 'id', 'label', 'name', 'builtin_omni_voices'
        pass

    def setOmniProfileFilter(self, query: 'str', mode: 'str', selected_id: 'str') -> 'None':
        pass

    def omniSampleText(self, language: 'str', locale: 'str') -> 'str':
        # [PyArmor BCC constants]: 'sample_text', '_t', 'lower', 'auto', 'vi', 'replace', '_', '-', 'split', 1, 0
        pass

    def discardOmniCandidate(self) -> 'None':
        # [PyArmor BCC constants]: 1, '_omni_candidate_generation', '_omni_candidate', 'omniCandidateChanged', 'emit'
        pass

    def applyNarrationSelection(self, provider: 'str', config: 'dict[str, Any]') -> 'None':
        # [PyArmor BCC constants]: '_t', 'gemini', 'lower', 'dict', 'stage_consumer_narration_draft', '_provider_options', 'omnivoice', 'bool', 'get', 'omni_consumer_only', 'OMNI_CONSUMER_SETTING_KEYS', 'omni_voice', 'omni_consumer_voice', '', 'update'
        pass

    def narrationExecutionSnapshot(self, provider: 'str', config: 'dict[str, Any]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'get_voice_api', 'dict', 'build_narration_snapshot', '_t', 'gemini'
        pass

    def previewNarrationSelection(self, provider: 'str', config: 'dict[str, Any]', text: 'str' = '') -> 'None':
        # [PyArmor BCC constants]: '_narration_selection_busy', '_busy', '_t', 'Xin chào, đây là bản nghe thử giọng dẫn truyện của VeoFlow.', '_set_narration_selection_busy', True, '_start_worker', 'preview_narration_selection', 'provider', 'config', 'text', 'gemini', 'dict'
        pass

    def selectNarrationRoute(self, route: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_t', 'lower', 'gateway', 'omnivoice', 'moss', 'vieneu', 'aistudio', 'auto', 'ok', 'message', False, 'Route TTS không hợp lệ: ', 'dict', '_provider_options', 'tts_route'
        pass

    def selectOmniProfile(self, profile_id: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'dict', '_provider_options', '_t', 'omnivoice', 'tts_route', 'omni_voice', 'omni_consumer_voice', 'profile', 'new', 'omni_mode', 'normalize_omni_state', 'configureProviderOptions', '_flush_pending_options', 'print', '🎙️ [VoiceStudio] Omni selection selection='
        pass

    def previewOmniCandidate(self, config: 'dict[str, Any]', locale: 'str', steps: 'int') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_omni_profile_busy', '_narration_selection_busy', 'ok', False, 'message', 'OmniVoice đang xử lý tác vụ khác.', '_busy', 'code', 'voice_generation_busy', 'Đang tạo audio — hãy dừng hoặc chờ hoàn tất trước khi tạo mẫu giọng.', 'dict', '_t', 'get', 'omni_language', 'vi'
        pass

    def approveOmniCandidate(self, name: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_omni_profile_busy', 'ok', False, 'message', 'OmniVoice đang xử lý tác vụ khác.', 'dict', '_omni_candidate', '_t', 'get', 'audio_path', 'path', 'Hãy tạo và nghe mẫu trước khi lưu.', 'Hãy đặt tên cho giọng.', '_set_omni_profile_busy', True
        pass

    def renameOmniProfile(self, profile_id: 'str', name: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_omni_profile_busy', 'ok', False, 'message', 'OmniVoice đang xử lý tác vụ khác.', '_t', 'Thiếu profile hoặc tên mới.', '_set_omni_profile_busy', True, '_start_worker', 'omni_profile_rename', 'profile_id', 'name', 'Đang đổi tên giọng…'
        pass

    def removeOmniProfile(self, profile_id: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_omni_profile_busy', 'ok', False, 'message', 'OmniVoice đang xử lý tác vụ khác.', '_set_omni_profile_busy', True, '_start_worker', 'omni_profile_delete', 'profile_id', '_t', 'Đang xóa giọng…'
        pass

    def previewOmniProfile(self, profile_id: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_omni_profile_busy', 'ok', False, 'message', 'OmniVoice đang xử lý tác vụ khác.', '_set_omni_profile_busy', True, '_start_worker', 'omni_profile_audio', 'profile_id', '_t', 'Đang tải audio mẫu…'
        pass

    def _flush_pending_options(self) -> 'None':
        # [PyArmor BCC constants]: '_persist_timer', 'isActive', 'stop', '_pending_state_delta', '_svc', 'apply_state', 'isinstance', 'get', 'state', 'dict', 'get_state', '_options_from_state', '_provider_options', 'providerOptionsChanged', 'emit'
        pass

    def listTtsApiKeys(self, provider: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'dict', '_svc', 'list_tts_api_keys', 'ok', 'provider', 'error', 'message', 'keys', 'count', False, 'type', '__name__', 'str', 200, 0
        pass

    def addTtsApiKey(self, provider: 'str', api_key: 'str', label: 'str' = '') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'dict', '_svc', 'add_tts_api_key', 'ok', 'provider', 'error', 'message', False, 'type', '__name__', 'str', 200, 'Exception', '_set_action_result', 'action'
        pass

    def removeTtsApiKey(self, provider: 'str', key_id: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'dict', '_svc', 'remove_tts_api_key', 'ok', 'provider', 'error', 'message', False, 'type', '__name__', 'str', 200, 'Exception', '_set_action_result', 'action'
        pass

    def testTtsApiKey(self, provider: 'str', api_key: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'dict', '_svc', 'test_tts_api_key', 'ok', 'provider', 'error', 'message', False, 'type', '__name__', 'str', 200, 'Exception', '_set_action_result', 'action'
        pass

    def setOutputFolder(self, folder: 'str') -> 'None':
        # [PyArmor BCC constants]: '_t', '_svc', 'apply_state', 'output_folder', 'isinstance', 'get', 'state', 'dict', '_output_folder', 'settingsChanged', 'emit', 'refreshHistory', '_set_status', 'Voice output folder: '
        pass

    def buildInstruct(self, gender: 'str', age: 'str', style: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_svc', 'build_local_tts_instruct', 'gender', 'age', 'style', '_set_action_result', 'action', 'voice.build_instruct', 'fallback', 'Instruction built'
        pass

    def _load_voice_presets(self) -> 'None':
        # [PyArmor BCC constants]: 'get_json_settings_manager', 'get', '_LOCAL_PRESET_KEY', '', 'loads', 'isinstance', 'list', '_local_voice_presets', 'Exception'
        pass

    def _save_voice_presets(self) -> 'None':
        # [PyArmor BCC constants]: 'get_json_settings_manager', 'set', '_LOCAL_PRESET_KEY', 'dumps', '_local_voice_presets', 'Exception'
        pass

    def localVoicePresets(*args, **kwargs):
        pass

    def saveVoicePreset(self, name: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'ok', False, 'code', 'voice_approval_required', 'message', 'Hãy dùng Tạo thử → nghe mẫu → đặt tên → lưu thành giọng.', '_set_action_result', 'action', 'voice.preset.save', 'fallback'
        pass

    def applyVoicePreset(self, preset_id: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_t', '_local_voice_presets', 'str', 'get', 'id', 'dict', 'options', 'omnivoice', 'tts_route', 'configureProviderOptions', '_flush_pending_options', 'ok', 'message', True, "Đã áp giọng '"
        pass

    def removeVoicePreset(self, preset_id: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_t', 'len', '_local_voice_presets', 'str', 'get', 'id', '_save_voice_presets', 'localVoicePresetsChanged', 'emit', 'ok', True, False
        pass

    def importFromPaste(self) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'QGuiApplication', 'clipboard', 'text', '', '_t', 'ok', False, 'code', 'clipboard_empty', 'message', 'Clipboard is empty', 'dict', '_svc', 'add_to_queue', 'get'
        pass

    def importCsv(self, path: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'provider', 'output_folder', 'provider_options', 'tts_config'
        pass

    def importTextFile(self, path: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'Path', '_t', 'expanduser', 'exists', 'ok', False, 'code', 'file_missing', 'message', 'Text file not found', 'read_text', 'encoding', 'utf-8', 'text', True
        pass

    def installLocalTts(self) -> 'None':
        pass

    def startLocalTts(self) -> 'None':
        pass

    def stopLocalTts(self) -> 'None':
        pass

    def _refresh_providers(self) -> 'None':
        # [PyArmor BCC constants]: '_svc', 'list_providers', 'get', 'providers', 'isinstance', 'dict', 'Exception', 'value', 'gemini', 'label', 'Gemini Audio', 'accent', '#3B82F6', 'minimax', 'MiniMax'
        pass

    def _normalize_provider(self, provider: 'str') -> 'str':
        # [PyArmor BCC constants]: '_t', 'local', 'omnivoice', 'localtts', 'local-tts', 'local_tts', '_providers', 'get', 'value', 'gemini'
        pass

    def _load_settings(self) -> 'None':
        # [PyArmor BCC constants]: '_svc', 'get_state', '_normalize_provider', '_t', 'get', 'provider', 'gemini', '_provider', 'providerChanged', 'emit', 'tts_mode', 'manual', 'lower', 'auto', '_tts_mode'
        pass

    def _load_provider_options(self) -> 'None':
        # [PyArmor BCC constants]: '_options_from_state', '_svc', 'get_state', '_provider_options', 'providerOptionsChanged', 'emit', '_refresh_shared_tts_config'
        pass

    def _refresh_tts_schema(self) -> 'None':
        # [PyArmor BCC constants]: 'dict', '_svc', 'tts_config_schema', '_provider', '_tts_schema', 'ok', 'error', 'message', False, 'type', '__name__', 'str', 200, 'Exception', 'ttsSchemaChanged'
        pass

    def _refresh_shared_tts_config(self) -> 'None':
        # [PyArmor BCC constants]: '_shared_tts_inflight', True, '_tts_mode', '_provider', 'provider_options', '_provider_options_payload', 'ok', 'cfg', 'dict', '_svc', 'shared_tts_config', 'mode', 'provider', 'overrides', 'error'
        pass

    def _apply_shared_tts_config(self, payload: 'dict[str, Any]') -> 'None':
        # [PyArmor BCC constants]: False, '_shared_tts_inflight', 'get', 'ok', 'cfg', '_shared_tts_config', 'error', 'message', 'Error', '', 'sharedTtsConfigChanged', 'emit'
        pass

    def _shared_tts_payload(self, *, voice_id: 'str' = '', model: 'str' = '', provider_options: 'dict[str, Any] | None' = None) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'dict', '_provider_options_payload', '_provider', 'omnivoice', '_t', 'get', 'omni_voice', '_svc', 'shared_tts_config', 'mode', '_tts_mode', 'provider', 'overrides', 'voice_id', 'model'
        pass

    def _options_from_state(self, state: 'dict[str, Any]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'normalize_omni_mode', 'normalize_omni_state', '_provider', 'minimax', 'speed', 'pitch', 'vol', 'emotion', 'audio_format', 'sample_rate', 'bitrate', 'channel', 'language_boost', 'float', 'get'
        pass

    def _options_to_state_delta(self, options: 'dict[str, Any]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_provider', 'minimax', 'minimax_speed', 'minimax_pitch', 'minimax_volume', 'minimax_emotion', 'minimax_audio_format', 'minimax_sample_rate', 'minimax_bitrate', 'minimax_channel', 'minimax_language_boost', 'get', 'speed', 1.0, 'pitch'
        pass

    def _provider_options_payload(self) -> 'dict[str, Any]':
        pass

    def _execution_provider_options_payload(self) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_provider_options_payload', '_provider', 'omnivoice', 'normalize_omni_consumer_state'
        pass

    @staticmethod
    def _pin_first(lst: 'list[dict]', key: 'str', value: 'str') -> 'list[dict]':
        # [PyArmor BCC constants]: 'enumerate', '_t', 'get', 1
        pass

    def _start_worker(self, action: 'str', payload: 'dict[str, Any]') -> 'None':
        # [PyArmor BCC constants]: '_VoiceWorker', '_svc', '_workers', 'append', 'resultReady', 'connect', 'finished', '_release_finished_worker', 'register', 'start'
        pass

    def _release_finished_worker(self) -> 'None':
        # [PyArmor BCC constants]: 'sender', '_workers', 'remove', 'ValueError', 'deleteLater'
        pass

    def _on_worker_done(self, worker: '_VoiceWorker', action: 'str', result: 'object') -> 'None':
        # [PyArmor BCC constants]: 'isinstance', 'dict', 'ok', False, 'error', 'invalid_result', 'refresh_options', '_apply_options', 'generate_single', '_set_busy', '_handle_generate_result', 'apply_narration_selection', '_set_narration_selection_busy', 'get', 'state'
        pass

    def _handle_generate_result(self, result: 'dict[str, Any]') -> 'None':
        # [PyArmor BCC constants]: '_set_action_result', 'action', 'generate_single', 'fallback', 'Voice generation finished', '_t', 'get', 'job_id', '_last_job_id', 'lastJobIdChanged', 'emit', 'ok', '_history', 'insert', 0
        pass

    def _start_local_tts_action(self, action: 'str') -> 'None':
        # [PyArmor BCC constants]: '_local_tts_busy', '_set_local_tts_busy', True, '_start_worker', 'local_tts_action', 'action'
        pass

    def _set_busy(self, value: 'bool') -> 'None':
        # [PyArmor BCC constants]: '_busy', 'busyChanged', 'emit', '_queue_refresh_timer', 'start', 'stop', 'refresh'
        pass

    def _set_local_tts_busy(self, value: 'bool') -> 'None':
        pass

    def _set_status(self, message: 'str') -> 'None':
        pass

    def _set_action_result(self, result: 'dict[str, Any]', *, action: 'str', fallback: 'str' = '') -> 'None':
        # [PyArmor BCC constants]: 'isinstance', 'get', 'blocker', 'dict', 'bool', 'blocked', '_t', 'code', 'error', 'message', 'ok', 'Voice action completed', 'action', '_last_action', '_result_message'
        pass


# --- Class: WorkPanelController ---
class WorkPanelController(QObject, WorkPanelControllerExtendAiMixin):
    """Thin QML adapter shared by Normal/Extend/Clone/Transcript/Batch routes."""
    _ROUTE_TAB_SOURCES = {'normal': 'normal_panel', 'extend': 'extend_panel', 'clone': 'clone_video', 'transcript': 'transcript_video', 'batch': ...
    _QUEUE_PUSH_ROUTES = ('clone', 'transcript', 'normal', 'extend', 'batch', 'affiliate')
    _CARD_ROUTES = ('clone', 'transcript')
    _clone_angle_suggestions = ()
    _clone_angle_suggestions_busy = False
    _ROUTE_OPTION_INT_KEYS = {'clip_duration_seconds', 'duration', 'output_count'}
    _CLONE_FETCH_RETRY_DELAYS = (2.0, 5.0, 10.0)
    _AFF_IMAGE_EXTS = {'.jpg', '.bmp', '.jpeg', '.webp', '.png'}
    staticMetaObject = PySide6.QtCore.QMetaObject("WorkPanelController" inherits "QObject":
Properties:
  #1 "route", QString [designable], not...

    routeChanged = Signal()
    screenMetaChanged = Signal()
    cardsChanged = Signal()
    queueRowsChanged = Signal()
    jobPanelRowsChanged = Signal()
    statsChanged = Signal()
    statusMessageChanged = Signal()
    mediaLibraryChanged = Signal()
    _mediaLibraryInvalidated = Signal()
    productLibraryChanged = Signal()
    charactersChanged = Signal()
    selectedRouteCharactersChanged = Signal()
    selectedCloneVoicesChanged = Signal()
    selectedCloneLibraryAssetsChanged = Signal()
    assetPreviewChanged = Signal()
    extendSessionsChanged = Signal()
    routeConfigChanged = Signal()
    _modelCatalogUpdated = Signal()
    sharedAutoMergeChanged = Signal()
    actionResultChanged = Signal()
    cloneAuthPauseRequiredChanged = Signal()
    cloneNoLiveAccountsPauseRequiredChanged = Signal()
    transcriptQueuePausedChanged = Signal()
    cloneNoLiveAccountsPauseDialogRequested = Signal()
    cloneTerminalPauseDialogRequested = Signal()
    openPathRequested = Signal()
    transcriptStyleRequired = Signal()
    affiliateScriptReady = Signal()
    affiliateScriptFailed = Signal()
    affiliateQueueActionFinished = Signal()
    _affiliateQueueActionEvent = Signal()
    _affiliateCampaignFinishedEvent = Signal()
    _affiliateLifecycleEvent = Signal()
    transcriptCharactersMissingBase64 = Signal()
    transcriptLinkDownloadChanged = Signal()
    _transcriptLinkPayload = Signal()
    transcriptPipelineChanged = Signal()
    transcriptTextsGenerated = Signal()
    _transcriptTtsPayload = Signal()
    _transcriptLinkMetaPayload = Signal()
    _mediaLibraryPayload = Signal()
    transcriptAiPreviewReady = Signal()
    _transcriptAiPreviewPayload = Signal()
    _cloneAutoFetchVideoPayload = Signal()
    _cloneAutoFetchDonePayload = Signal()
    _cloneAutoFetchStatusPayload = Signal()
    _localFileMetadataPayload = Signal()
    queueCostChanged = Signal()
    _queueCostPayload = Signal()
    cloneLinksFetchingChanged = Signal()
    activeCloneCardChanged = Signal()
    activeTranscriptCardChanged = Signal()
    cloneAngleSuggestionsChanged = Signal()
    affiliateImageBusyChanged = Signal()
    affiliateImportLibraryBusyChanged = Signal()
    affiliateImportLibraryMessageChanged = Signal()
    affiliateImageImportFinished = Signal()
    _affiliateImagePayload = Signal()
    _affiliateImportLibraryPayload = Signal()
    _affiliateImportLibraryCleanupPayload = Signal()
    _affiliateReimportPayload = Signal()
    _affiliateOverlayProduct = Signal()
    affiliateOverlayProductReady = Signal()
    affiliateImportRowsReady = Signal()
    _affiliatePrepEvent = Signal()
    def __init__(self) -> 'None':
        # [PyArmor BCC constants]: 'tab_sources', 'light_getter', 'projection', 'full_loader', 'filter_fn', 'store', 'parent'
        pass

    def route(*args, **kwargs):
        pass

    def affiliateUiPreview(*args, **kwargs):
        pass

    def screenMeta(*args, **kwargs):
        pass

    def cards(*args, **kwargs):
        pass

    def cardModel(*args, **kwargs):
        pass

    def queueRows(*args, **kwargs):
        pass

    def jobPanelRows(*args, **kwargs):
        pass

    def jobPanelModel(*args, **kwargs):
        pass

    def queueModel(*args, **kwargs):
        pass

    def extendIdeaQueueModel(*args, **kwargs):
        pass

    def affiliateLifecycleModel(*args, **kwargs):
        pass

    def affiliateImportLibraryModel(*args, **kwargs):
        pass

    def jobPanelRow(self, jobId: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_job_panel_model', 'row_by_id', 'str', '', '_job_panel_rows', 'isinstance', 'dict', 'get', 'id', 'row_id', 'job_id', 'batch_id'
        pass

    def _tab_sources_for_route(self, route: 'str') -> 'set[str]':
        # [PyArmor BCC constants]: '_ROUTE_TAB_SOURCES', 'get', 'str', '', 'set'
        pass

    def _mark_queue_dirty_for_job(self, job: 'Any' = None) -> 'None':
        # [PyArmor BCC constants]: 'JobPanelFeed', '_tab_source', 'clone', 'clone_video', '_tab_sources_for_route', '_route', True, '_queue_dirty'
        pass

    def _extend_session_row_ids(self) -> 'set[str]':
        # [PyArmor BCC constants]: 'set', '_queue_rows', 'isinstance', 'dict', 'str', 'get', '', 'strip', 'add', 'dispatcher_job_ids'
        pass

    def _row_passes_work_filter(self, row: 'dict[str, Any]') -> 'bool':
        # [PyArmor BCC constants]: '_route', 'extend', 'str', 'get', 'id', 'job_id', 'row_id', '', 'strip', True, '_extend_session_row_ids', 'normal', '_normal_job_feature_type', '_normal_feature_type', 'clone'
        pass

    def _sync_job_panel_rows_cache(self) -> 'None':
        # [PyArmor BCC constants]: '_affiliate_ui_preview', '_route', 'affiliate', 'rows_signature', '_feed', 'model', 'raw_rows', 'with_progress', False, '_emit_gate', 'changed', 'jobpanel', 'rows', '_job_panel_rows', 'jobPanelRowsChanged'
        pass

    def _emit_queue_stats_if_changed(self) -> 'None':
        # [PyArmor BCC constants]: '_emit_gate', 'changed', 'queue_model', 'rows_signature', '_queue_rows', '_queue_model', 'apply_rows', '_route', 'batch', 'queue_legacy', 'with_progress', 'queueRowsChanged', 'emit', 'stats', 'stats_signature'
        pass

    def _transcript_batch_full_loader(self) -> 'list[dict[str, Any]]':
        # [PyArmor BCC constants]: '_transcript', 'list_queue', 'get', 'rows', 'isinstance', 'dict'
        pass

    def _transcript_batch_row_loader(self, batch_id: 'str') -> 'dict[str, Any] | None':
        pass

    def _on_transcript_batch_rows_changed(self) -> 'None':
        # [PyArmor BCC constants]: '_route', 'transcript', '_transcript_batch_feed', 'rows', '_queue_rows', '_load_stats', '_stats', '_emit_queue_stats_if_changed'
        pass

    def _clone_batch_full_loader(self) -> 'list[dict[str, Any]]':
        # [PyArmor BCC constants]: '_clone', 'list_queue', 'get', 'rows', 'isinstance', 'dict'
        pass

    def _clone_batch_row_loader(self, batch_id: 'str') -> 'dict[str, Any] | None':
        pass

    def _affiliate_queue_session_key(self) -> 'str':
        # [PyArmor BCC constants]: '_route_configs', 'get', 'affiliate', 'str', '_queue_session_key', 'affiliate:', 'getattr', '_affiliate_workspace_session_id', '', 'runtime'
        pass

    def _affiliate_batch_full_loader(self) -> 'list[dict[str, Any]]':
        # [PyArmor BCC constants]: '_affiliate', 'list_queue', '_affiliate_queue_session_key', 'get', 'queue', 'isinstance', 'dict'
        pass

    def _affiliate_batch_row_loader(self, batch_id: 'str') -> 'dict[str, Any] | None':
        pass

    @staticmethod
    def _affiliate_variant_row_id(row: 'dict[str, Any] | None') -> 'str':
        # [PyArmor BCC constants]: 'isinstance', 'dict', 'str', 'get', 'id', 'row_id', 'batch_id', '', 'strip'
        pass

    def _ensure_affiliate_variant_focus(self, rows: 'list[dict[str, Any]]') -> 'bool':
        """Keep Job Panel on active production unless the user pinned a row."""
        pass

    def _focus_affiliate_variant(self, row_id: 'str') -> 'bool':
        pass

    def _focus_affiliate_product(self, product_id: 'str') -> 'bool':
        # [PyArmor BCC constants]: 'str', '', 'strip', False, '_queue_rows', 'isinstance', 'dict', 'get', 'meta', 'source', 'product_id', 'append', '_affiliate_focus_user_pinned', '_affiliate_focused_batch_id', '_route_configs'
        pass

    def _on_affiliate_batch_rows_changed(self) -> 'None':
        """Push parent aggregate progress/assets to the Production queue only."""
        # [PyArmor BCC constants]: 'ok', 'blocked', 'route', 'action', 'code', 'error', 'message', 'row_id'
        pass

    def _on_affiliate_queue_action_event(self, payload: 'dict[str, Any]') -> 'None':
        # [PyArmor BCC constants]: 'dict', 'setdefault', 'route', 'affiliate', 'action', 'affiliate.production', 'ok', False, 'blocked', 'bool', 'get', 'code', 'affiliate_action_completed', 'affiliate_action_failed', 'error'
        pass

    def _refresh_affiliate_lifecycle_model(self) -> 'None':
        """
        GUI-thread atomic projection of preparation + production.
        
                SQLite and provider work stay in workers.  This method only merges small
                in-memory snapshots and diffs a QAbstractListModel.
        """
        # [PyArmor BCC constants]: '_lifecycle_preparing', '_lifecycle_package_ready', '_lifecycle_failed', '_lifecycle_total'
        pass

    def _on_affiliate_lifecycle_event(self, data: 'dict[str, Any]') -> 'None':
        # [PyArmor BCC constants]: 'dict', 'str', 'get', 'variant_run_id', 'column_id', 'product_id', '', 'strip', '_affiliate_lifecycle_events', 'update', '_refresh_affiliate_lifecycle_model'
        pass

    def _seed_affiliate_ui_preview(self) -> 'None':
        # [PyArmor BCC constants]: '_affiliate_ui_preview', '_route', 'affiliate', 'build_affiliate_ui_preview', 'Path', '__file__', 'resolve', 'parents', 2, 'get', 'cards', 'dict', '_cards_by_route', '_route_configs', 'setdefault'
        pass

    def _extend_batch_full_loader(self) -> 'list[dict[str, Any]]':
        # [PyArmor BCC constants]: '_extend_uc', '_ensure_extend_session_key', 'str', 'getattr', '_extend_session_key', '', 'Exception', '_extend', 'list_queue', 'get', 'rows', 'isinstance', 'dict'
        pass

    def _extend_batch_row_loader(self, batch_id: 'str') -> 'dict[str, Any] | None':
        # [PyArmor BCC constants]: '_extend_uc', '_ensure_extend_session_key', 'str', 'getattr', '_extend_session_key', '', 'Exception', '_extend', 'aggregate_batch_row'
        pass

    def _on_extend_batch_rows_changed(self) -> 'None':
        # [PyArmor BCC constants]: '_route', 'extend', '_extend_uc', '_ensure_extend_session_key', 'list', '_extend', 'list_queue', 'get', 'rows', 'isinstance', 'dict', '_queue_rows', '_extend_batch_feed', 'Exception', '_load_stats'
        pass

    def _on_queue_push(self) -> 'None':
        # [PyArmor BCC constants]: '_route', '_QUEUE_PUSH_ROUTES', 'clone', '_clone_batch_feed', 'reload', 'transcript', '_transcript_batch_feed', 'extend', '_extend_batch_feed', 'affiliate', '_affiliate_ui_preview', '_ensure_affiliate_auto_merge_connected', '_affiliate_batch_feed', True, '_queue_dirty'
        pass

    def _on_clone_batch_rows_changed(self) -> 'None':
        # [PyArmor BCC constants]: '_route', 'clone', '_clone_batch_feed', 'rows', '_queue_rows', '_load_stats', '_stats', '_set_clone_no_live_accounts_pause', '_clone_has_no_live_accounts_pause', '_clone_terminal_alert_payload', '_set_clone_terminal_pause_dialog', '_clone_no_live_accounts_pause_required', '', '_last_clone_completion_signature', '_last_clone_auto_next_signature'
        pass

    def stats(*args, **kwargs):
        pass

    def currentBatchConfig(*args, **kwargs):
        pass

    def _route_card_cfgs(self, route: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_', '_card_configs_map', 'hasattr', 'setattr', 'getattr'
        pass

    def _active_route_card(self, route: 'str') -> 'str':
        # [PyArmor BCC constants]: 'str', 'getattr', '_active_', '_card_id_v', ''
        pass

    def _set_active_route_card(self, route: 'str', card_id: 'str') -> 'None':
        # [PyArmor BCC constants]: 'setattr', '_active_', '_card_id_v', 'str', ''
        pass

    def _promote_active_card_config_to_shared(self, route: 'str') -> 'None':
        # [PyArmor BCC constants]: '_active_route_card', 'dict', '_route_card_cfgs', 'get', 'pop', '_explicit_override_keys', '_route_configs', '_effective_route_config_cache'
        pass

    def _clone_card_cfgs(self) -> 'dict[str, Any]':
        pass

    def _active_clone_card(self) -> 'str':
        pass

    def currentRouteConfig(*args, **kwargs):
        pass

    def currentRouteOptions(*args, **kwargs):
        """
        Dropdown option lists (models, durations, voice-lock capability, ...)
                computed FROM the current route's effective config, so per-route picks
                (model/aspect/clip) drive their own option lists instead of the master's.
                Reuses MasterOptionsService.get_options — the single options builder.
        """
        pass

    def _on_models_updated(self) -> 'None':
        pass

    def _on_model_catalog_updated(self) -> 'None':
        pass

    def cloneAuthPauseRequired(*args, **kwargs):
        pass

    def cloneNoLiveAccountsPauseRequired(*args, **kwargs):
        pass

    def transcriptQueuePaused(*args, **kwargs):
        pass

    def _sync_transcript_queue_paused(self, result: 'dict[str, Any] | None' = None) -> 'None':
        # [PyArmor BCC constants]: 'dict', 'bool', 'queue_paused', 'get', '_transcript', 'is_queue_paused', '_transcript_queue_paused', 'transcriptQueuePausedChanged', 'emit'
        pass

    def cloneDialogueLanguageOptions(*args, **kwargs):
        pass

    def imageMotionHandOptions(*args, **kwargs):
        pass

    def applyCloneBulkConfig(self, links_with_config: 'list', common_config: 'dict') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_route', 'clone', 'setRoute', '_selected_character_payload', '_selected_clone_voice_payload', 'dict', '_effective_route_config', 'items', 'route', 'str', 'get', 'url', '', 'strip', 'append'
        pass

    def activeCloneCardId(*args, **kwargs):
        pass

    def setActiveCloneCard(self, card_id: 'str') -> 'None':
        # [PyArmor BCC constants]: 'str', '', '_active_clone_card_id_v', '_clone_card_cfgs', 'dict', '_effective_route_config', 'clone', 'activeCloneCardChanged', 'emit', 'routeConfigChanged'
        pass

    def clearActiveCloneCard(self) -> 'None':
        # [PyArmor BCC constants]: '', '_active_clone_card_id_v', 'activeCloneCardChanged', 'emit', 'routeConfigChanged'
        pass

    def cloneAngleSuggestions(*args, **kwargs):
        pass

    def cloneAngleSuggestionsBusy(*args, **kwargs):
        pass

    def requestCloneAngleSuggestions(self) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_clone_angle_suggestions_busy', 'ok', False, 'message', 'Đang gợi ý, chờ chút...', 'str', '_active_clone_card', '', '_current_cards', 'get', 'id', 'dict', 'selected', 'Chưa có video nguồn — dán link hoặc thêm file trước đã.', '_state'
        pass

    def applyCloneCardConfigToAll(self, card_ids: 'list') -> 'None':
        # [PyArmor BCC constants]: '_active_clone_card', 'dict', '_clone_card_cfgs', 'get', '_effective_route_config', 'clone', 'str', '', 'routeConfigChanged', 'emit'
        pass

    def _clone_remix_guard(self) -> 'dict[str, Any] | None':
        pass

    def queueCost(*args, **kwargs):
        pass

    def requestQueueCost(self, route: 'str') -> 'None':
        # [PyArmor BCC constants]: 'str', '', 'strip', 'lower', '_queue_cost', 'queueCostChanged', 'emit', '_current_cards', 'isinstance', 'dict', 'get', 'selected', False, 'url', 'prompt'
        pass

    def _apply_queue_cost_payload(self, payload: 'dict') -> 'None':
        # [PyArmor BCC constants]: 'dict', '_queue_cost', 'queueCostChanged', 'emit'
        pass

    def submitCloneCardsWithConfig(self, cards: 'list') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_account_run_blocker', 'queue.submit_cards', '_clone_remix_guard', '_clone_card_cfgs', '_current_cards', 'str', 'get', 'id', '', 'dict', 'url', 'strip', 'append', 'title', 'duration_seconds'
        pass

    def _card_config_summary(self, route: 'str', card_id: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'str', '', '_route_card_cfgs', 'isinstance', 'get', 'dict', '_effective_route_config', 'selected_style_name', 'strip', 'use_ai_style', 'AI', '—', '_clone_display_model', 'video_model_key', 'model_key'
        pass

    def cloneCardConfigSummary(self, card_id: 'str') -> 'dict[str, Any]':
        pass

    def activeTranscriptCardId(*args, **kwargs):
        pass

    def setActiveTranscriptCard(self, card_id: 'str') -> 'None':
        # [PyArmor BCC constants]: 'str', '', '_set_active_route_card', 'transcript', '_route_card_cfgs', 'dict', '_effective_route_config', 'activeTranscriptCardChanged', 'emit', 'routeConfigChanged'
        pass

    def clearActiveTranscriptCard(self) -> 'None':
        # [PyArmor BCC constants]: '_set_active_route_card', 'transcript', '', 'activeTranscriptCardChanged', 'emit', 'routeConfigChanged'
        pass

    def transcriptCardConfigSummary(self, card_id: 'str') -> 'dict[str, Any]':
        pass

    def mediaLibraryItems(*args, **kwargs):
        pass

    def mediaLibraryStats(*args, **kwargs):
        pass

    def mediaLibrarySettings(*args, **kwargs):
        pass

    def productLibraryItems(*args, **kwargs):
        pass

    def productLibraryStats(*args, **kwargs):
        pass

    def characters(*args, **kwargs):
        pass

    def selectedRouteCharacters(*args, **kwargs):
        pass

    def selectedCloneVoices(*args, **kwargs):
        pass

    def selectedCloneObjects(*args, **kwargs):
        pass

    def selectedCloneBackgrounds(*args, **kwargs):
        pass

    def cloneFlowVoiceOptions(*args, **kwargs):
        pass

    def cloneFlowVoiceReferenceLimit(*args, **kwargs):
        pass

    def cloneFlowVoiceReferencesSupported(*args, **kwargs):
        pass

    def cloneFlowVoiceLockSupported(*args, **kwargs):
        pass

    def cloneSkipLabel(*args, **kwargs):
        pass

    def cloneHasCharacters(*args, **kwargs):
        """True when the current clone session has character data selected."""
        pass

    def cloneIsManualCharMode(*args, **kwargs):
        pass

    def clonePendingNextJob(*args, **kwargs):
        """True when current job finished but auto_next is off (waiting for user to click Next)."""
        pass

    def cloneAudioVoiceOptions(*args, **kwargs):
        pass

    def cloneAudioModelOptions(*args, **kwargs):
        pass

    def cloneVideoModelOptions(*args, **kwargs):
        pass

    def cloneAudioPresetOptions(*args, **kwargs):
        pass

    def assetPreview(*args, **kwargs):
        pass

    def extendSessions(*args, **kwargs):
        pass

    def extendSessionState(*args, **kwargs):
        pass

    def statusMessage(*args, **kwargs):
        pass

    def lastAction(*args, **kwargs):
        pass

    def actionStatus(*args, **kwargs):
        pass

    def setRoute(self, route: 'str') -> 'None':
        # [PyArmor BCC constants]: 'time', 'perf_counter', 'str', '', 'ROUTE_META', 1000, '_log_work_panel_perf', 'setRoute.ignored_non_work', '_route', 'route_arg', 'force', '_WORK_PANEL_PERF_VERBOSE', '_state', 'setRoute.same_route', 'extend'
        pass

    def _reload_queue_and_stats(self, steps: 'list[tuple[str, float]]', *, force: 'bool') -> 'None':
        # [PyArmor BCC constants]: '_route', 'transcript', 'extend', '_queue_dirty', False, 'time', 'perf_counter', 'thread_time', '_extend_batch_feed', 'reload', 'Exception', 'list', 'rows', '_queue_rows', '_load_queue_rows'
        pass

    def refresh(self) -> 'None':
        # [PyArmor BCC constants]: 'time', 'perf_counter', '_route', 'extend', '_timed_step', 'save_extend_cards', '_save_extend_session_cards', '_reload_queue_and_stats', 'force', True, 'affiliate', 'sync_affiliate_variant_focus', '', 'clone', 'clone_no_live_check'
        pass

    def refreshQueueAndStats(self) -> 'None':
        # [PyArmor BCC constants]: 'time', 'perf_counter', '_route', 'extend', '_timed_step', 'save_extend_cards', '_save_extend_session_cards', 'emit_queue_stats', '_emit_queue_stats_if_changed', 1000, '_log_work_panel_perf', 'refreshQueueAndStats rows=', 'len', '_queue_rows', '_reload_queue_and_stats'
        pass

    def refreshMasterRouteConfig(self) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_emit_route_config_changed', '_route', 'clone', 'selectedCloneVoicesChanged', 'emit', 'ok', 'blocked', 'route', 'action', 'message', True, False, 'work_panel.master_config.refresh', 'Master-driven route config refreshed', '_state'
        pass

    @staticmethod
    def _route_resolution_for_quality(quality: 'Any', model_key: 'str' = '') -> 'tuple[str, bool]':
        # [PyArmor BCC constants]: 'video_output_contract', 'str', 'resolution', 'bool', 'enable_upscale'
        pass

    @staticmethod
    def _route_model_key(config: 'dict[str, Any]') -> 'str':
        # [PyArmor BCC constants]: 'str', 'get', 'model_key', 'video_model_key', ''
        pass

    @staticmethod
    def _snap_route_quality(quality: 'Any', model_key: 'str', account_tier: 'str' = '') -> 'str':
        pass

    @staticmethod
    def _clone_image_resolution_for_quality(quality: 'Any') -> 'str':
        pass

    def _apply_route_patch(self, route: 'str', patch: 'dict[str, Any]') -> 'dict[str, Any]':
        pass

    def _persist_route_config(self, route: 'str') -> 'None':
        # [PyArmor BCC constants]: '_defer_route_config_flush', 'batch', '_batch_uc', '_persist_batch_route_config', 'extend', '_persist_extend_route_config', 'affiliate', '_affiliate_uc', '_persist_affiliate_route_config', 'Exception'
        pass

    def setRouteOption(self, route: 'str', key: 'str', value: 'Any') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_apply_route_patch', 'str', '_route', '', 'strip', 'transcript', 'clone', 'image_rhythm_target', 'image_target_count', 'image_pacing', 'image_rhythm_mode', 'image_count_mode', '_active_route_card', '_route_card_cfgs', 'get'
        pass

    def setRouteOptions(self, route: 'str', patch: 'dict[str, Any]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'dict', '_apply_route_patch', 'str', '_route', '', 'strip', 'image_rhythm_target', 'image_target_count', 'image_pacing', 'image_rhythm_mode', 'image_count_mode', 'intersection', 'transcript', 'clone', '_active_route_card'
        pass

    def _connect_runtime_feedback(self) -> 'None':
        # [PyArmor BCC constants]: '_runtime_feedback_connected', 'get_instant_upscale_manager', 'getattr', '_prompt_status_max_gen_cb', '_prompt_status_clone_auth_cb', 'prompt_status_updated', 'connect', 'Exception', True
        pass

    def _on_all_completed(self) -> 'None':
        pass

    def addBlankCard(self) -> 'None':
        # [PyArmor BCC constants]: '_route', 'extend', '_ensure_extend_session', '_current_cards', 'append', '_make_card', '', '_emit_cards_changed', '_save_extend_session_cards', '_state', 'set_status', 'Added card to '
        pass

    def addCardsFromText(self, raw_text: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'parse_bulk_items', '_route', 'clone', '_add_clone_links_via_auto_fetch', 'action', 'work_panel.bulk_import.add_cards', 'addBlankCard', 'ok', 'blocked', 'count', 'blank_added', 'message', True, False, 1
        pass

    def addCardsFromItems(self, items: 'list[Any]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_route', 'batch', '_add_batch_import_cards', 'list', 'action', 'work_panel.bulk_import.add_cards', 'str', '', 'strip', 'append', 'ok', False, 'blocked', 'code', 'empty_workpanel_input_items'
        pass

    def _on_token_count_progress(self, current: 'int', total: 'int', status: 'str') -> 'None':
        # [PyArmor BCC constants]: '_state', 'set_status', '[', '/', '] '
        pass

    def addLocalFiles(self, paths: 'list[Any]', kind: 'str' = '') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'ok', 'blocked', 'action', 'code', 'error', 'message', 'route', 'count'
        pass

    def _start_local_file_metadata_probe(self, batch_id: 'str', route_name: 'str', kind: 'str', rows: 'list[dict[str, Any]]') -> 'None':
        # [PyArmor BCC constants]: 'str', '', '_local_file_probe_latest_by_route', 'threading', 'Thread', 'target', '_run_local_file_metadata_batch', 'args', 'dict', '_localFileMetadataPayload', 'emit', 'name', 'LocalMediaProbeBatch-', 8, 'daemon'
        pass

    def _apply_local_file_metadata_payload(self, payload: 'dict[str, Any]') -> 'None':
        # [PyArmor BCC constants]: 'str', 'get', 'route', '', 'strip', 'list', 'rows', '_cards_by_route', 'isinstance', 'dict', 'id', 0, 'card_id', 'bool', 'exists'
        pass

    def addLocalFolder(self, folder: 'str', kind: 'str' = '') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'work_panel.local_folder.add', 'Path', 'str', '', 'expanduser', 'is_dir', 'ok', 'blocked', 'action', 'code', 'error', 'message', 'folder', 'count', False
        pass

    def _format_uploaded_at(self, value: 'str') -> 'str':
        # [PyArmor BCC constants]: 'str', '', 'strip', 'datetime', 'fromisoformat', 'strftime', '%Y-%m-%d %H:%M', 'ValueError'
        pass

    def duplicateCard(self, card_id: 'str') -> 'None':
        # [PyArmor BCC constants]: '_find_card', '_state', 'set_status', 'Card not found', 'dict', 'str', 'uuid4', 'id', 'get', 'title', 'Card', ' Copy', 'draft', 'status', '_current_cards'
        pass

    def deleteCard(self, card_id: 'str') -> 'None':
        # [PyArmor BCC constants]: '_current_cards', 'len', 'str', 'get', 'id', '_cards_by_route', '_route', '_emit_cards_changed', '_save_extend_session_cards', '_state', 'set_status', 'Deleted card', 'Card not found'
        pass

    def updateCard(self, card_id: 'str', title: 'str', prompt: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_find_card', 'ok', False, 'error', 'card_not_found', 'message', 'Card not found', '_state', 'set_status', 'str', '', 'strip', 'get', 'title', 'Prompt Card'
        pass

    def updateCardOrRow(self, row_id: 'str', title: 'str', prompt: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_find_card', 'updateCard', 'updateRow'
        pass

    def updateMultiAssetCardOrRow(self, row_id: 'str', text: 'str', advanced_mode: 'bool') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'str', '', 'strip', 'ok', False, 'error', 'missing_multi_asset_item_id', 'message', 'Missing multi-asset item id', '_state', 'set_status', '_find_card', '_build_multi_asset_update', 'invalid_multi_asset_json', 'Invalid multi-asset JSON'
        pass

    def updateRow(self, row_id: 'str', title: 'str', prompt: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'str', '', 'strip', 'ok', False, 'error', 'missing_row_id', 'message', 'Missing row id', '_state', 'set_status', 'title', 'name', 'prompt', 'text'
        pass

    def _on_insert_after_requested(self, after_card: 'dict[str, Any]', extend_type: 'str' = 'extend') -> 'dict[str, Any]':
        pass

    def insert_child_after(self, after_card: 'dict[str, Any]', extend_type: 'str' = 'extend') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'ok', 'blocked', 'action', 'error', 'code', 'message'
        pass

    def retryRow(self, row_id: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'str', '', 'strip', 'ok', False, 'blocked', 'action', 'work_panel.queue.retry_row', 'error', 'missing_row_id', 'code', 'message', 'Missing row id', '_state', 'set_status'
        pass

    def inspectRowAsset(self, row_id: 'str', index: 'int') -> 'None':
        # [PyArmor BCC constants]: 'getRowAssetPreview', 'dict', '_asset_preview', 'assetPreviewChanged', 'emit', 'str', 'get', 'title', 'slot_label', 'asset', 'ok', 'can_reupscale', 're-upscale dry-run ready', 'preview only', '_state'
        pass

    def getRowAssetPreview(self, row_id: 'str', index: 'int') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_find_queue_row', '_job_panel_model', 'row_by_id', 'str', '', 'ok', 'row_id', 'slot_index', 'slot_label', 'blocker', 'warnings', False, 'int', 0, 'Asset '
        pass

    def submitReupscaleDryRun(self, payload: 'dict[str, Any]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'dict', True, 'dry_run', '_reupscale', 'start', 'get', 'ok', 'validation', 'plan', 'str', 'resolution', '1080p', 'output_policy', '_state', 'set_status'
        pass

    def submitReupscaleStart(self, payload: 'dict[str, Any]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'dict', False, 'dry_run', '_reupscale', 'start', 'get', 'ok', 'accepted', 'str', 'resolution', '1080p', '_state', 'set_status', 'Re-upscale started: ', 'blocker'
        pass

    def prepareVideoPreview(self, path: 'str', title: 'str' = '', index: 'int' = 0, total: 'int' = 0) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_reupscale', 'video_preview', 'get', 'ok', '_state', 'set_status', 'Video preview ready: ', 'name', 'local video', 'errors', 0, 'code', 'video_preview_unavailable', 'Video preview blocked: '
        pass

    def _voice_preview_path(self, voice_name: 'str') -> 'Path':
        # [PyArmor BCC constants]: 'str', '', 'strip', 'lower', 'Path', '__file__', 'resolve', 'parents', 2, 'resources', 'voices', '.wav'
        pass

    def _play_voice(self, voice_name: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'str', '', 'strip', 'lower', 'ok', False, 'error', 'affiliate_voice_preview_missing_voice', 'message', 'Select a voice first.', 'voice_name', '_state', 'set_status', '_voice_preview_path', 'is_file'
        pass

    def executeAffiliateQueueAction(self, action_id: 'str', payload: 'dict[str, Any]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'str', '', 'strip', 'dict', '_affiliate_actions', 'is_production_action', 'ok', 'blocked', 'route', 'action', 'code', 'error', 'message', False, True
        pass

    def executePrimitiveAction(self, action_id: 'str', payload: 'dict[str, Any]') -> 'bool':
        # [PyArmor BCC constants]: 'str', '', 'strip', 'dict', 'get', 'row_id', 'card_id', 'id', 'work_panel.import_from_batch_image', 'importFromBatchImage', True, 'work_panel.mode_toggle', 'mode', 'feature', '_route_configs'
        pass

    def executeRouteTool(self, action: 'str') -> 'None':
        # [PyArmor BCC constants]: 'str', '', 'strip', 'clone_analyze_scenes', 'analyzeFirstQueueRow', 'transcript_audio_files', 'requestTranscriptAudioFiles', 'transcript_audio_folder', 'requestTranscriptAudioFolder', 'batch_reference_images', '_batch', 'browse_reference_images', 'get', 'blocked', '_state'
        pass

    def transcriptLinkBusy(*args, **kwargs):
        pass

    def transcriptLinkStatus(*args, **kwargs):
        pass

    def transcriptLinksFetching(*args, **kwargs):
        pass

    def cloneLinksFetching(*args, **kwargs):
        pass

    def transcriptLinksFetchCount(*args, **kwargs):
        pass

    def transcriptInputMode(*args, **kwargs):
        pass

    def transcriptPipelineBusy(*args, **kwargs):
        pass

    def transcriptPipelineStatus(*args, **kwargs):
        pass

    def transcriptKnowledgeCategories(*args, **kwargs):
        pass

    def transcriptLengthOptions(*args, **kwargs):
        pass

    def transcriptToneOptions(*args, **kwargs):
        pass

    def transcriptTemplateOptions(*args, **kwargs):
        pass

    def transcriptAiGenerating(*args, **kwargs):
        pass

    def transcriptDefaultVoice(*args, **kwargs):
        pass

    def transcriptVoiceOptions(*args, **kwargs):
        pass

    def transcriptEmotionProvider(*args, **kwargs):
        pass

    def transcriptEmotionOptions(*args, **kwargs):
        pass

    def submitCard(self, card_id: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'str', '', 'strip', '_find_card', 'ok', 'blocked', 'action', 'card_id', 'error', 'code', 'message', False, 'work_panel.prompt_card.submit', 'card_not_found', 'Card not found'
        pass

    def submitAllCards(self) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'ok', 'blocked', 'route', 'action', 'code', 'error', 'message', 'count'
        pass

    def clearJobPanelCompleted(self) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_route', 'normal', 'clone', 'transcript', 'affiliate', 'ok', 'route', 'action', 'error', 'message', False, '.job_panel.clear_completed', 'job_panel_clear_unsupported', 'Job-panel clear is not available for ', '_state'
        pass

    def clearCompleted(self) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'clear_completed_queue', 'ok', 'route', 'action', 'error', 'message', False, '_route', '.queue.clear_completed', 'type', '__name__', 'Clear completed failed: ', 'Exception', '_state', 'set_status'
        pass

    def _cancel_dispatch_job(self, job_id: 'str') -> 'None':
        # [PyArmor BCC constants]: 'str', '', 'strip', 'get_dispatcher', 'hasattr', 'cancel_job', 'Exception'
        pass

    def removeRow(self, row_id: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'ok', 'route', 'action', 'code', 'error', 'message', False, '_route', '.queue.remove_row', 'missing_row_id', 'Missing row id', '_state', 'set_status', 'normal', '_cancel_dispatch_job'
        pass

    def markBlocked(self, action: 'str') -> 'None':
        # [PyArmor BCC constants]: '_state', 'set_blocked_status', 'blocked', 'route', 'action', 'code', 'error', 'blocker', 'message', True, '_route', 'str', '', 'legacy_mark_blocked_call', 'A legacy QML fallback attempted to mark a route action as blocked.'
        pass

    def _load_persisted_route_configs(self) -> 'dict[str, dict[str, Any]]':
        # [PyArmor BCC constants]: 'normal', 'extend', 'batch', 'clone', 'affiliate', 'transcript', '_load_normal_route_config', '_load_extend_route_config', '_batch_uc', '_load_batch_route_config', '_load_clone_route_config', '_load_affiliate_route_config', '_load_transcript_route_config', 'apply_shared_auto_merge', 'read_shared_auto_merge'
        pass

    def _set_shared_auto_merge(self, enabled: 'bool', *, notify_master: 'bool') -> 'None':
        # [PyArmor BCC constants]: 'bool', '_CARD_ROUTES', '_route_card_cfgs', 'apply_shared_auto_merge', '_route_configs', 'per_card_configs', '_master_options', 'save_option', 'auto_merge_video', '_effective_route_config_cache', '_emit_route_config_changed', 'sharedAutoMergeChanged', 'emit'
        pass

    def applySharedAutoMerge(self, enabled: 'bool') -> 'None':
        # [PyArmor BCC constants]: '_set_shared_auto_merge', 'bool', 'notify_master', False
        pass

    def _on_cards_changed_persist(self) -> 'None':
        # [PyArmor BCC constants]: '_batch_cards_view_cache', '_state', '_normal_cards_view_cache'
        pass

    def _emit_cards_changed(self, *, reset_model: 'bool' = False) -> 'None':
        # [PyArmor BCC constants]: '_batch_cards_view_cache', '_state', '_normal_cards_view_cache', '_card_model', 'set_cards', '_cards_for_model', 'Exception', '_sync_card_model', 'cardsChanged', 'emit', 'hasattr', '_affiliate_lifecycle_model', '_refresh_affiliate_lifecycle_model'
        pass

    def _swap_normal_feature_cards(self, old_feature: 'str', new_feature: 'str') -> 'None':
        # [PyArmor BCC constants]: '_normal_feature_cards', '_cards_by_route', 'get', 'normal', '_normal_uc', '_load_normal_cards_for_feature', '_emit_cards_changed', 'reset_model', True, 'refresh'
        pass

    def _reload_normal_route_config(self, feature_type: 'str') -> 'None':
        # [PyArmor BCC constants]: 'dict', '_route_configs', 'get', 'normal', 'str', 'aspect_ratio', '', 'strip', '_normal_uc', '_load_normal_route_config', 'feature_type', 'aspect', '_effective_route_config_cache', '_state'
        pass

    def _switch_normal_aspect(self, new_aspect: 'str') -> 'None':
        # [PyArmor BCC constants]: '_route_configs', 'setdefault', 'normal', 'str', 'get', 'aspect_ratio', '', 'strip', '_normal_feature_type', '_persist_normal_route_config', '_normal_uc', '_load_normal_route_config', 'feature_type', 'aspect', '_effective_route_config_cache'
        pass

    def _clone_debug_log(self, message: 'str') -> 'None':
        # [PyArmor BCC constants]: 'Path', '__file__', 'resolve', 'parents', 2, '_clone_autofetch.log', 'open', 'a', 'encoding', 'utf-8', 'write', 'datetime', 'now', 'isoformat', ' '
        pass

    def _add_clone_links_via_auto_fetch(self, lines: 'list[str]', *, action: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_clone_uc', '_clone_url_structurally_ok', 'len', 'ok', 'blocked', 'action', 'code', 'error', 'message', 'count', False, True, 'clone_no_valid_url', 'Không có link video hợp lệ — clone chỉ nhận URL video (không channel/playlist).', 0
        pass

    def _start_clone_auto_fetch(self, raw_input: 'str', video_type: 'str') -> 'None':
        # [PyArmor BCC constants]: '_clone_uc', 'parse_clone_auto_fetch_entries', '_clone_debug_log', '_start_clone_auto_fetch entries=', 'len', ' type=', ' input=', 120, '_state', 'set_status', 'No URL to fetch', '_route', 'clone', 'setRoute', 'normalize_clone_video_type'
        pass

    def _emit_clone_fetch_status(self, seq: 'int', message: 'str') -> 'None':
        # [PyArmor BCC constants]: '_cloneAutoFetchStatusPayload', 'emit', '_seq', 'message'
        pass

    def _emit_clone_fetch_video(self, payload: 'dict[str, Any]') -> 'None':
        pass

    def _emit_clone_fetch_done(self, payload: 'dict[str, Any]') -> 'None':
        pass

    def _clone_fetch_sleep(self, seconds: 'float', seq: 'int') -> 'bool':
        # [PyArmor BCC constants]: 'time', 'monotonic', 'max', 0.0, 'float', '_clone_auto_fetch_seq', False, 'sleep', 0.1
        pass

    def _fetch_clone_entry_with_retry(self, entry: 'str', filter_mode: 'str', seq: 'int') -> 'tuple[list[dict[str, Any]] | None, str]':
        """
        Fetch 1 entry, tự thử lại lỗi tạm theo _CLONE_FETCH_RETRY_DELAYS.
                Trả (videos, last_error); videos=None nghĩa là seq bị vượt → caller dừng.
        """
        pass

    def _run_clone_auto_fetch(self, entries: 'list[str]', filter_mode: 'str', seq: 'int', existing: 'set[str]') -> 'None':
        # [PyArmor BCC constants]: 'set', 0, '', '_clone_auto_fetch_seq', '_clone_debug_log', 'seq ', ' superseded, abort', '_fetch_clone_entry_with_retry', ' superseded mid-retry, abort', 1, 'entry=', 80, ' -> ', 'len', ' video(s)'
        pass

    def _on_clone_auto_fetch_video(self, payload: 'dict[str, Any]') -> 'None':
        # [PyArmor BCC constants]: 'int', 'get', '_seq', 0, '_clone_auto_fetch_seq', '_clone_uc', 'build_clone_card_from_video', '_state', '_cards_by_route', 'setdefault', 'clone', 'str', 'url', '', 'strip'
        pass

    def _on_clone_auto_fetch_status(self, payload: 'dict[str, Any]') -> 'None':
        # [PyArmor BCC constants]: 'int', 'get', '_seq', 0, '_clone_auto_fetch_seq', 'str', 'message', '', '_state', 'set_status'
        pass

    def _on_clone_auto_fetch_done(self, payload: 'dict[str, Any]') -> 'None':
        # [PyArmor BCC constants]: 'int', 'get', '_seq', 0, '_clone_auto_fetch_seq', False, '_clone_links_fetching', 'cloneLinksFetchingChanged', 'emit', 'count', 'invalid', 'failed', 'login_platforms', 'str', 'error'
        pass

    def _mark_clone_batch_source(self, card_id: 'str', batch_config: 'dict[str, Any]') -> 'bool':
        # [PyArmor BCC constants]: '_find_card', 'str', '', False, 'dict', 'int', 'get', 'variations', 0, '_batch_config', 'Batch x', 'status', '_emit_cards_changed', '_state', 'set_status'
        pass

    def _delete_clone_source_card(self, card_id: 'str') -> 'bool':
        # [PyArmor BCC constants]: 'str', '', 'strip', False, '_state', '_cards_by_route', 'get', 'clone', 'enumerate', 'id', '_emit_cards_changed', True
        pass

    def markCloneBatchSource(self, card_id: 'str', config: 'dict[str, Any]') -> 'bool':
        pass

    def _serialize_card_assets(self, assets: 'Any') -> 'list[dict[str, Any]]':
        # [PyArmor BCC constants]: 'isinstance', 'dict', 'items', 'append'
        pass

    def _restore_card_assets(self, assets: 'Any') -> 'list[dict[str, Any]]':
        # [PyArmor BCC constants]: 'isinstance', 'dict', 'str', 'get', 'media_id', 'id', '', 'strip', '_media_library', 'get_media', 'Exception', '_media_asset_payload', 'cropped_image_path', 'path', 'preview_path'
        pass

    def _normal_cards_for_view(self, cards: 'list[dict[str, Any]]') -> 'list[dict[str, Any]]':
        # [PyArmor BCC constants]: 'getattr', '_normal_cards_view_cache', 'isinstance', 'dict', '_restore_card_assets', 'get', 'assets', '_serialize_card_assets', '_strip_heavy_inplace', 'append', '_state'
        pass

    def _cards_for_model(self) -> 'list[dict[str, Any]]':
        # [PyArmor BCC constants]: '_current_cards', '_route', 'batch', 'isinstance', 'dict', '_batch_uc', '_enrich_batch_reference_payload', 'normal', '_normal_cards_for_view'
        pass

    def _sync_card_model(self) -> 'None':
        # [PyArmor BCC constants]: '_card_model', 'apply_rows', '_cards_for_model', 'Exception'
        pass

    def _effective_route_config(self, route: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'getattr', '_effective_route_config_cache', '_compute_effective_route_config', 'isinstance', 'dict', 'coerce_model_to_dropdown_base', 'Exception'
        pass

    @staticmethod
    def _resolve_extend_source_model_key(root_model_key: 'str', aspect_ratio: 'str', tier_mode: 'str') -> 'str':
        # [PyArmor BCC constants]: 'str', '', 'strip', 'startswith', 'speed:', 'split', ':', 1, 'fast', 'upper', 'ModelConfig', 'get_model_by_type_and_speed', 'text_to_video', 'is_portrait', 'endswith'
        pass

    def _derive_extend_model_key(self, root_model_key: 'str', aspect_ratio: 'str', tier_mode: 'str') -> 'str':
        # [PyArmor BCC constants]: 'resolve_credit_matched_i2v_model', 'WorkPanelController', '_resolve_extend_source_model_key', 'ModelConfig', 'get_model_duration_seconds', 8, 'key', '', 'Exception'
        pass

    def _derive_native_extend_model_key(self, root_model_key: 'str', aspect_ratio: 'str', tier_mode: 'str') -> 'str':
        # [PyArmor BCC constants]: 'resolve_native_extend_model', 'WorkPanelController', '_resolve_extend_source_model_key', 'ModelConfig', 'get_model_duration_seconds', 8, 'key', '', 'Exception'
        pass

    def _derive_zero_credit_i2v_model_key(self, root_model_key: 'str', aspect_ratio: 'str', tier_mode: 'str') -> 'str':
        # [PyArmor BCC constants]: 'resolve_zero_credit_i2v_model', 'WorkPanelController', '_resolve_extend_source_model_key', 'ModelConfig', 'get_model_duration_seconds', 8, 'key', '', 'Exception'
        pass

    def _compute_effective_route_config(self, route: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'resolution', 'enable_upscale', 'video_model_key', 'target_market', 'selected_style_name', 'selected_style', 'camera_prompt'
        pass

    def _add_prompt_cards(self, prompts: 'list[str]', *, action: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_current_cards', 0, False, 'enumerate', '_prompt_import_entry', 'str', 'get', 'prompt', 'text', '', 'strip', 'bool', 'assets', 54, 'title'
        pass

    def _add_batch_import_cards(self, items: 'list[Any]', *, action: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_current_cards', 0, False, 'enumerate', '_batch_import_entry', 'str', 'get', 'prompt', 'text', '', 'strip', 'bool', 'assets', 'reference_previews', 'reference_images'
        pass

    def _batch_import_entry(self, item: 'Any') -> 'tuple[str, list[str], list[str], list[str], int]':
        # [PyArmor BCC constants]: 'isinstance', 'dict', 'str', 'get', 'prompt', 'text', 'idea', 'description', '', 'strip', 'parse_prompt_duration_marker', 'int', 'duration_seconds', 0, '_append_batch_reference_values'
        pass

    def _append_batch_reference_values(self, target: 'list[str]', values: 'Any', *, prefer_id: 'bool') -> 'None':
        # [PyArmor BCC constants]: 'isinstance', 'dict', 'list', 'values', 'tuple', 'set', '_append_batch_reference_value', 'prefer_id'
        pass

    def _append_batch_reference_value(self, target: 'list[str]', value: 'Any', *, prefer_id: 'bool') -> 'None':
        # [PyArmor BCC constants]: 'isinstance', 'dict', 'str', 'get', 'media_id', 'mediaId', 'id', '', 'strip', 'path', 'source_path', 'file_path', 'url', 'append'
        pass

    def _dedupe_limited_strings(self, values: 'list[str]', *, limit: 'int') -> 'list[str]':
        # [PyArmor BCC constants]: 'set', 'str', '', 'strip', 'lower', 'add', 'append', 'len'
        pass

    def _prompt_import_entry(self, value: 'Any') -> 'dict[str, Any] | None':
        # [PyArmor BCC constants]: 'str', '', 'strip', 'parse_prompt_duration_marker', 'prompt', 'duration_seconds', 0, 'duration_marker', 'duration', 'marker', 'format_duration_marker'
        pass

    def _find_card(self, card_id: 'str') -> 'dict[str, Any] | None':
        pass

    def _find_queue_row(self, row_id: 'str') -> 'dict[str, Any] | None':
        pass

    def _multi_asset_editor_source(self, source: 'dict[str, Any] | None') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'dict', 'get', 'meta', 'isinstance', 'items', 'setdefault'
        pass

    def _parse_multi_asset_json_text(self, raw_text: 'Any') -> 'dict[str, Any] | None':
        # [PyArmor BCC constants]: 'str', '', 'strip', 'startswith', '{', 'json', 'loads', 'Exception', 'isinstance', 'dict'
        pass

    def _extract_multi_asset_prompt(self, payload: 'dict[str, Any] | None') -> 'str':
        # [PyArmor BCC constants]: 'dict', 'get', 'scene', 'isinstance', 'str', 'visual', 'veo3_prompt', '', 'strip', 'prompt'
        pass

    def _build_multi_asset_update(self, source: 'dict[str, Any] | None', text: 'str', advanced_mode: 'bool') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'str', '', 'strip', 'ValueError', 'empty_multi_asset_content', '_multi_asset_editor_source', '_parse_multi_asset_json_text', 'invalid_multi_asset_json', 'get', 'full_json_text', 'json', 'prompt', 'text', 'isinstance', 'scene'
        pass

    def _looks_like_base64(self, value: 'str') -> 'bool':
        pass

    def _image_mime_from_base64(self, value: 'str', fallback: 'str' = 'image/png') -> 'str':
        # [PyArmor BCC constants]: 'str', '', 'strip', 'startswith', 'data:image/', 'split', ';', 1, 0, 'replace', 'data:', ',', 'base64', 'b64decode', 64
        pass

    def _thumbnail_source(self, value: 'str') -> 'str':
        # [PyArmor BCC constants]: 'str', '', 'strip', 'startswith', 'data:image', 'file:', 'qrc:', 'http://', 'https://', '_looks_like_base64', 'data:', '_image_mime_from_base64', ';base64,', '_local_preview_payload', 'get'
        pass

    def _light_thumbnail_source(self, *values: 'Any') -> 'str':
        # [PyArmor BCC constants]: 'str', '', 'strip', '_looks_like_base64', '_thumbnail_source'
        pass

    def _encode_file_base64(self, path_value: 'str') -> 'str':
        # [PyArmor BCC constants]: 'str', '', 'strip', 'base64', 'b64encode', 'Path', 'read_bytes', 'decode', 'ascii', 'Exception'
        pass

    def attachStatusController(self, controller: 'Any') -> 'None':
        pass

    def replaceRowAsset(self, row_id: 'str', slot_index: 'int', media_id: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'replace_job_asset', 'str', '', 'int', 'isinstance', 'dict', 'get', 'ok', 'refresh'
        pass

    def _account_run_blocker(self, action: 'str', route: 'str' = '') -> 'dict[str, Any] | None':
        # [PyArmor BCC constants]: 'run_blocker', 'feature_blocker', 'feature_for_route', 'alert_payload', 'str', '_route', 'strip', 'lower', '.', 'route', 'getattr', '_status_controller', 'hasattr', 'publishRuntimeAlert', True
        pass

    def _credit_gate_blocker(self, full_action: 'str', route: 'str' = '') -> 'dict[str, Any] | None':
        # [PyArmor BCC constants]: 'ModelConfig', 'resolve_active_mode', 'get_account_manager', 'str', '_route', 'strip', 'lower', 'dict', '_effective_route_config', '_credit_gate_model_selection', 'print', '[CreditGate] skip: no ', ' model_key in route config', 'get', 'account_tier'
        pass

    def _submit_cards(self, cards: 'list[dict[str, Any]]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'time', 'perf_counter', '_timed_step', 'preflight', 'copy_cards', '_route', 'extend', 'str', 'get', 'prompt', 'text', '', 'strip', 'ok', 'route'
        pass

    def _create_blocked_jobs(self, cards: 'list[dict[str, Any]]', *, blocker: 'str' = 'workpanel_submit_contract_missing', message: 'str' = 'Submit contract is not registered for this route.') -> 'int':
        # [PyArmor BCC constants]: 'enumerate', '_job_store', 'create_job', 'feature', '_route', 'prompt', 'str', 'get', '', 'title', ' ', 1, 'status', 'failed', 'error_message'
        pass

    def _format_blocked_status(self, result: 'dict[str, Any]') -> 'str':
        # [PyArmor BCC constants]: '_normalize_action_result', 'force_blocked', True, '_format_action_status'
        pass

    def _load_stats(self, rows: 'list[dict[str, Any]]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_route', 'extend', 'dict', '_extend', 'get_stats', '_ensure_extend_session_key', 'clone', '_clone', 'transcript', '_transcript', 'batch', '_stats_from_rows', 'affiliate'
        pass

    def _normalize_job_store_asset_item(self, item: 'Any', index: 'int') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'id', 'media_id', 'name', 'path', 'file_path', 'source_path', 'preview_path', 'thumbnail_url', 'thumbnail_path', 'exists'
        pass

    def _job_store_asset_items(self, row: 'dict[str, Any]') -> 'list[dict[str, Any]]':
        # [PyArmor BCC constants]: 'value', 'Any', 'return', 'tuple[str, ...]'
        pass

    def _job_store_thumbnail(self, row: 'dict[str, Any]') -> 'str':
        pass

    def _log_thumb_cache(self, cache: 'dict[str, Any]') -> 'None':
        # [PyArmor BCC constants]: 'getattr', '_thumb_cache_hits', 0, '_thumb_cache_misses', 200, 'print', '[PERF][ThumbCache] lookups=', ' hits=', ' misses=', ' miss_rate=', '.0%', ' cached_jobs=', 'len'
        pass

    def _job_to_row(self, job: 'dict[str, Any]', resolve_previews: 'bool' = True) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'dict', 'get', 'meta', 'str', 'tab_source', '', 'strip', 'feature', 'dispatch_feature', 'batch_image_generation', 'image_generation', 'transcript_image', 'clone_image', 'isinstance', 'list'
        pass

    def _current_cards(self) -> 'list[dict[str, Any]]':
        pass

    def _make_card(self, prompt: 'str') -> 'dict[str, Any]':
        pass

    def _normalize_local_paths(self, paths: 'list[Any]', kind: 'str' = '') -> 'list[str]':
        pass

    def _emit_route_config_changed(self) -> 'None':
        pass

    def _defer_route_config_flush(self, route: 'str') -> 'None':
        # [PyArmor BCC constants]: 'str', '_route', '', 'strip', '_pending_route_config_flush_routes', 'add', '_route_config_flush_scheduled', True, 'QTimer', 'singleShot', '_ROUTE_CONFIG_FLUSH_DEBOUNCE_MS', '_flush_route_config_updates', 'Exception'
        pass

    def _flush_route_config_updates(self) -> 'None':
        # [PyArmor BCC constants]: 'set', 'getattr', '_pending_route_config_flush_routes', 'clear', False, '_route_config_flush_scheduled', 'sorted', 'normal', '_persist_normal_route_config', 'clone', '_clone_uc', '_persist_clone_route_config', 'transcript', '_transcript_uc', '_persist_transcript_route_config'
        pass

    def _local_preview_payload(self, path_value: 'str') -> 'dict[str, Any]':
        pass

    def _load_job_panel_rows(self) -> 'list[dict[str, Any]]':
        pass

    def _cards_for_view(self) -> 'list[dict[str, Any]]':
        # [PyArmor BCC constants]: '_current_cards', '_route', 'batch', 'getattr', '_batch_cards_view_cache', 'isinstance', 'dict', '_batch_uc', '_enrich_batch_reference_payload', 'normal', '_normal_cards_for_view', 'extend', '_decorate_extend_cards'
        pass

    def _get_session_generation_count(self) -> 'int':
        # [PyArmor BCC constants]: 'str', '_extend_session_key', '', '_session_service', 'get_session', 'get_current_session', 'isinstance', 'dict', 0, 'max', 'int', 'get', 'generation_count', 'TypeError', 'ValueError'
        pass

    def _get_max_generations(self) -> 'int':
        # [PyArmor BCC constants]: 'dict', '_effective_route_config', 'extend', 'max', 10, 'int', 'get', 'max_generations', '_EXTEND_ROUTE_DEFAULTS', 'TypeError', 'ValueError'
        pass

    def _create_new_project_chain(self) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'dict', '_route_configs', 'get', 'extend', 'createExtendSession', 'str', 'session_key', '', 'ok', 'route', 'action', 'error', 'message', False, 'extend.project_chain.create'
        pass

    def _on_prompt_status_for_max_generations(self, prompt_data: 'dict', status: 'str') -> 'None':
        # [PyArmor BCC constants]: 'str', '', 'MAX_GENERATIONS', 'isinstance', 'dict', 'bool', 'get', 'max_generations_reached', 'feature', 'strip', 'lower', 'tab_source', 'extend', 'extend_work_panel', 'extend_panel'
        pass

    def _normalize_action_result(self, result, *, success_message='', failure_message='', force_blocked=False):
        # [PyArmor BCC constants]: '_state', '_normalize_action_result', 'success_message', 'failure_message', 'force_blocked'
        pass

    def _format_action_status(self, payload: 'dict[str, Any]') -> 'str':
        pass

    def _open_existing_folder(self, folder: 'str', *, empty_message: 'str', missing_prefix: 'str') -> 'None':
        # [PyArmor BCC constants]: 'str', '', 'strip', '_state', 'set_status', 'Path', 'expanduser', 'exists', 'is_dir', ': ', 'openPathRequested', 'emit', 'Opening folder: '
        pass

    def _local_path_from_open_candidate(self, value: 'Any') -> 'str':
        # [PyArmor BCC constants]: 'str', '', 'strip', 'startswith', 'data:', 'http://', 'https://', 'file:', 'QUrl', 'toLocalFile'
        pass

    def _batch_image_output_candidate(self, row: 'dict[str, Any]') -> 'str':
        # [PyArmor BCC constants]: 'dict', 'get', 'meta', 'result_data', 'result', 'images', 'isinstance', 'list', 'extend', 'str', 'thumbnail_url', 'thumbnail_path', 'file_path', 'output_path', 'preview_path'
        pass

    def openBatchImageJobOutput(self, job_id: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'str', '', 'strip', 'list', '_job_panel_rows', 'isinstance', 'dict', 'extend', '_job_store', 'list_jobs', 'tab_source', 'batch_image_generation', 'limit', 500, '_job_to_row'
        pass

    def skipOrNextJob(self) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_invoke_route_queue', 'cancel_job', 'setdefault', 'action', '_route', '.queue.skip_or_next', '_state', 'set_action_result', 'success_message', 'Job skipped', 'failure_message', 'Skip failed'
        pass

    def setManualMode(self, enabled: 'bool') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_route_configs', 'setdefault', '_route', 'bool', 'manual_mode', '_emit_route_config_changed', 'ok', 'route', 'action', 'message', True, '.manual_mode', 'Manual mode ', 'on', 'off'
        pass

    def isManualMode(self) -> 'bool':
        # [PyArmor BCC constants]: 'bool', '_route_configs', 'get', '_route', 'manual_mode', False
        pass

    def loginPlatform(self, platform: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'str', '', 'strip', 'lower', 'get_account_manager', 'youtube', 'tiktok', 'ok', 'platform', 'action', 'message', True, 'clone.platform.login', 'title', ' login initiated — complete in browser'
        pass

    def deleteSelectedVideos(self, video_ids: 'list') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'str', 'ok', False, 'code', 'no_ids', 'message', 'No video IDs provided', 0, '_cards_by_route', 'get', '_route', 'len', 'id', 'video_id', ''
        pass

    def countTokensAuto(self) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'ok', 'token_count', 'card_count', 'action', 'message'
        pass

    def regenerateJobPanelJob(self, job_id: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'regenerate_job_panel_job', '_ROUTE_TAB_SOURCES', 'get', '_route', '', '_job_store', 'expected_tab_sources', 'action', '.job_panel.regenerate', 'source', '_state', 'set_action_result', 'success_message', 'Scene regeneration queued', 'failure_message'
        pass

    def regenJobFromPanel(self, job_id: 'str') -> 'dict[str, Any]':
        pass

    def deleteJobFromPanel(self, job_id: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_invoke_route_action', 'delete_scene_job', 'job_id', 'setdefault', 'action', '_route', '.job.delete', '_state', 'set_action_result', 'success_message', 'Job deleted', 'failure_message', 'Delete failed'
        pass

    def setJobPanelReview(self, job_id: 'str', status: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'set_job_panel_review', '_ROUTE_TAB_SOURCES', 'get', '_route', '', '_job_store', 'expected_tab_sources'
        pass

    def updateJobPanelPrompt(self, job_id: 'str', new_prompt: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'update_job_panel_prompt', '_ROUTE_TAB_SOURCES', 'get', '_route', '', '_job_store', 'expected_tab_sources', 'action', '.job_panel.update_prompt', '_state', 'set_action_result', 'success_message', 'Scene prompt updated', 'failure_message', 'Scene prompt update failed'
        pass

    def editJobFromPanel(self, job_id: 'str', new_prompt: 'str') -> 'dict[str, Any]':
        pass

    def _invoke_route_action(self, method_name: 'str', payload: 'dict') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'normal', 'extend', 'clone', 'transcript', 'batch', 'affiliate', '_normal', '_extend', '_clone', '_transcript', '_batch', '_affiliate', 'get', '_route', 'hasattr'
        pass

    def pollAccountCredits(self) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'get_account_manager', 'get_all_accounts_dict', 'ok', 'account_count', 'action', 'message', True, 'len', 'account.credits.poll', 'Polled ', ' account(s)', 'code', False, 'poll_failed', 'str'
        pass

    def recoverDeadAccount(self, account_id: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'get_account_manager', 'ok', 'account_id', 'action', 'message', True, 'account.dead.recover', 'Recovery initiated for ', 'code', False, 'recovery_failed', 'str', 'Exception', '_state', 'set_action_result'
        pass

    def onDispatcherJobCompleted(self, job_id: 'str', success: 'bool', output_path: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'str', '', 'strip', 'ok', 'job_id', 'success', 'output_path', 'action', 'message', True, 'bool', '_route', '.dispatcher.job_completed', 'Job ', ' '
        pass

    def toggleFrameSlicing(self, enabled: 'bool') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_route_configs', 'setdefault', 'clone', 'bool', 'frame_slicing', '_emit_route_config_changed', 'ok', 'route', 'action', 'message', True, 'clone.config.frame_slicing', 'Frame slicing ', 'enabled', 'disabled'
        pass

    def canRetryJob(self, job_id: 'str') -> 'bool':
        # [PyArmor BCC constants]: 'str', '', 'strip', False, 'get_job_store', 'get_job', 'getattr', 'status', 'upper', 'ERROR', 'STOPPED', 'FAILED', 'CANCELLED', 'Exception'
        pass

    def pollJobCompletion(self, job_id: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'str', '', 'strip', 'ok', False, 'code', 'job_id_required', 'get_job_store', 'job_store_unavailable', 'get_job', 'job_id', 'job_not_found', 'getattr', 'status', 'upper'
        pass

    def pollUpscaleStatus(self, job_id: 'str') -> 'dict[str, Any]':
        pass

    def setMultiAssetMode(self, enabled: 'bool') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_route_configs', 'setdefault', '_route', 'bool', 'multi_asset_mode', '_emit_route_config_changed', 'ok', 'route', 'action', 'message', True, '.config.multi_asset_mode', 'Multi-asset mode ', 'enabled', 'disabled'
        pass

    def refreshMultiAssetCapability(self) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'get_account_manager', 'get_all_accounts_dict', 'bool', 'ok', 'has_multi_asset', 'action', 'message', True, '_route', '.multi_asset.refresh', 'Multi-asset capability: ', 'available', 'unavailable', 'error', False
        pass

    def setCharConsistencyMode(self, enabled: 'bool') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_route_configs', 'setdefault', '_route', 'bool', 'char_consistency', '_emit_route_config_changed', 'ok', 'route', 'action', 'message', True, '.config.char_consistency', 'Character consistency ', 'enabled', 'disabled'
        pass

    def setSceneConsistencyMode(self, enabled: 'bool') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'sync_scene_consistency_with_library_control', '_route_configs', 'setdefault', '_route', 'scene_keys', '_emit_route_config_changed', 'ok', 'route', 'scene_consistency', 'action', 'message', True, 'bool', 'get', '.config.scene_consistency'
        pass

    def pollChargenStatus(self, job_id: 'str') -> 'dict[str, Any]':
        pass

    def validateNormalCards(self) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_cards_by_route', 'get', 'normal', 'str', 'prompt', 'text', '', 'strip', 'ok', False, 'valid', 'action', 'normal.validate', 'error', 'no_valid_cards'
        pass

    def detectActiveJob(self) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'get_job_store', 'ok', False, 'active', 'code', 'job_store_unavailable', 'RUNNING', 'PROCESSING', 'QUEUED', 'GENERATING', 'PENDING', 'hasattr', 'list_jobs', 'str', 'getattr'
        pass

    def handleTwoPhaseImageCallback(self, phase: 'str', job_id: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'str', '1', 'strip', '', 'get_job_store', 'get_job', 'getattr', 'status', 'unknown', 'upper', 'COMPLETED', 'COMPLETE', 'ok', 'phase', 'job_id'
        pass

    def setResearchModel(self, model_id: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_route_configs', 'setdefault', 'research', 'str', '', 'strip', 'research_model', '_emit_route_config_changed', 'ok', 'route', 'model', 'action', 'message', True, 'research.config.model'
        pass

    def setResearchAgentConfig(self, agent_id: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_route_configs', 'setdefault', 'research', 'str', '', 'strip', 'agent_id', '_emit_route_config_changed', 'ok', 'route', 'action', 'message', True, 'research.config.agent', 'Research agent set: '
        pass

    def checkUpscaleTierGate(self) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'account_mode', 'ModelConfig', 'feature_enabled', 'isFlowUpsamplingEnabled', 'resolve_active_mode', 'MODE_ULTRA', 'Upscale đang tắt (isFlowUpsamplingEnabled=false)', '4K upscale available (ULTRA mode)', '4K upscale chỉ có ở ULTRA mode (PRO tối đa 2K ảnh / 1080p video)', 'ok', 'upscale_4k_allowed', 'upscale_enabled', 'mode', 'action', 'message'
        pass

    def analyzeQueueRow(self, row_id: 'str') -> 'dict[str, Any]':
        pass

    def analyzeFirstQueueRow(self) -> 'dict[str, Any]':
        pass

    def enqueueApprovedScripts(self, items: 'list[Any]', voice_id: 'str' = '', category_id: 'str' = '', emotion: 'str' = '') -> 'None':
        pass

    def clearQueue(self) -> 'dict[str, Any]':
        pass

    def startQueue(self) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_queue_uc', 'startQueue', '_route', 'transcript', '_sync_transcript_queue_paused'
        pass

    def continueQueue(self) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_queue_uc', 'continueQueue', '_route', 'transcript', '_sync_transcript_queue_paused'
        pass

    def pauseQueue(self) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_queue_uc', 'pauseQueue', '_route', 'transcript', '_sync_transcript_queue_paused'
        pass

    def skipTranscriptJob(self) -> 'dict[str, Any]':
        pass

    def _queue_row_identity(self, row: 'dict[str, Any] | None') -> 'str':
        pass

    def _queue_row_status(self, row: 'dict[str, Any] | None') -> 'str':
        pass

    def _auto_generate_after_queue_load(self) -> 'dict[str, Any]':
        pass

    def _check_queue_after_session_complete(self) -> 'bool':
        pass

    def _ai_director_queue_selected(self, selected_index: 'int') -> 'dict[str, Any]':
        pass

    def clear_completed_queue(self) -> 'dict[str, Any]':
        pass

    def _invoke_route_queue(self, method_name: 'str') -> 'dict[str, Any]':
        pass

    def _call_route_queue(self, method_name: 'str', success_message: 'str') -> 'None':
        pass

    def _load_queue_rows(self) -> 'list[dict[str, Any]]':
        pass

    def normalMultiAssetCapabilities(self) -> 'dict[str, Any]':
        pass

    def scanNormalImageFolder(self, folder: 'str') -> 'dict[str, Any]':
        pass

    def addNormalImageImportItems(self, items: 'list[Any]', card_mode: 'str' = 'image', assets_per_card: 'int' = 7) -> 'dict[str, Any]':
        pass

    def importFromBatchImage(self) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_normal_feature_type', 'image', 'interpolation', 'multi_asset', 'executePrimitiveAction', 'work_panel.mode_toggle', 'mode', 1, 'int', '_normal_multi_asset_capabilities', 0, 2, '_normal_uc', 'importFromBatchImage'
        pass

    def addNormalImageCards(self, paths: 'list[Any]') -> 'dict[str, Any]':
        pass

    def addNormalSingleImagePromptCards(self, prompts: 'list[Any]', image_paths: 'list[Any]') -> 'dict[str, Any]':
        pass

    def addNormalSharedPromptImageCards(self, prompts: 'list[Any]', image_paths: 'list[Any]') -> 'dict[str, Any]':
        pass

    def addNormalInterpolationCards(self, paths: 'list[Any]') -> 'dict[str, Any]':
        pass

    def addNormalSinglePairInterpolationCards(self, prompts: 'list[Any]', image_paths: 'list[Any]') -> 'dict[str, Any]':
        pass

    def addNormalSharedPromptInterpolationCards(self, prompts: 'list[Any]', image_paths: 'list[Any]') -> 'dict[str, Any]':
        pass

    def addNormalMultiAssetCards(self, paths: 'list[Any]', assets_per_card: 'int' = 7) -> 'dict[str, Any]':
        pass

    def addNormalSingleSetMultiAssetCards(self, prompts: 'list[Any]', image_paths: 'list[Any]', assets_per_card: 'int' = 7) -> 'dict[str, Any]':
        pass

    def addNormalSharedPromptMultiAssetCards(self, prompts: 'list[Any]', image_paths: 'list[Any]', assets_per_card: 'int' = 7) -> 'dict[str, Any]':
        pass

    def addNormalNamedRefImageCards(self, prompts: 'list[Any]', image_paths: 'list[Any]') -> 'dict[str, Any]':
        pass

    def addNormalNamedRefMultiAssetCards(self, prompts: 'list[Any]', image_paths: 'list[Any]', assets_per_card: 'int' = 7) -> 'dict[str, Any]':
        pass

    def setNormalAspectRatio(self, ratio: 'str') -> 'dict[str, Any]':
        pass

    def generateNormalFlowVoice(self, card_id: 'str') -> 'dict[str, Any]':
        pass

    def _load_normal_cards(self) -> 'list[dict[str, Any]]':
        pass

    def _persist_normal_cards(self) -> 'None':
        pass

    def _load_normal_route_config(self) -> 'dict[str, Any]':
        pass

    def _persist_normal_route_config(self) -> 'None':
        pass

    def _normal_voice_lock_supported(self) -> 'bool':
        pass

    def _normal_multi_asset_capabilities(self) -> 'tuple[int, int]':
        pass

    def _normal_feature_type(self) -> 'str':
        pass

    def _normal_dispatcher_feature(self, feature_type: 'str') -> 'str':
        pass

    def _normal_payload_for_card(self, card: 'dict[str, Any]', feature_type: 'str', aspect_ratio: 'str' = '16:9') -> 'dict[str, Any] | None':
        pass

    def _normal_style_prefix(self, master_config: 'dict[str, Any]') -> 'str':
        pass

    def _on_media_library_invalidated(self, _reason: 'str' = '') -> 'None':
        # [PyArmor BCC constants]: 'QTimer', 'singleShot', 500, '_media_uc', 'refreshMediaLibrary'
        pass

    def refreshMediaLibrary(self, search: 'str' = '', asset_type: 'str' = '') -> 'None':
        pass

    def _apply_media_library_payload(self, payload: 'dict[str, Any]') -> 'None':
        # [PyArmor BCC constants]: 'dict', 'list', 'get', 'payload', 'items', 'len', '_media_uc', '_s', '_media_items', '_MEDIA_LIBRARY_PROGRESSIVE_THRESHOLD', '_start_media_library_progressive_apply', 1, '_media_library_progressive_token', 'applyMediaLibraryPayload'
        pass

    def _build_media_library_progressive_envelope(self, rows: 'list[Any]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'dict', '_media_library_progressive_envelope', 'get', 'payload', 'list', 'items', 'shown', 'total', 'len', '_media_library_progressive_rows', 'progressive'
        pass

    def _start_media_library_progressive_apply(self, envelope: 'dict[str, Any]', rows: 'list[Any]') -> 'None':
        # [PyArmor BCC constants]: 1, '_media_library_progressive_token', 'dict', '_media_library_progressive_envelope', 'list', '_media_library_progressive_rows', 'min', 'len', '_MEDIA_LIBRARY_PROGRESSIVE_CHUNK_SIZE', '_media_library_progressive_index', '_media_uc', 'applyMediaLibraryPayload', '_build_media_library_progressive_envelope', 'QTimer', 'singleShot'
        pass

    def _flush_media_library_progressive_chunk(self, token: 'int') -> 'None':
        # [PyArmor BCC constants]: '_media_library_progressive_token', '_media_library_progressive_rows', '_media_library_progressive_index', 'len', 'min', '_MEDIA_LIBRARY_PROGRESSIVE_CHUNK_SIZE', '_media_uc', 'applyMediaLibraryPayload', '_build_media_library_progressive_envelope', 'QTimer', 'singleShot', '_MEDIA_LIBRARY_PROGRESSIVE_DELAY_MS'
        pass

    def importMediaPaths(self, raw_paths: 'str', tags: 'str' = '', asset_type: 'str' = '') -> 'dict[str, Any]':
        pass

    def requestMediaFilePicker(self) -> 'None':
        pass

    def requestMediaFolderPicker(self) -> 'None':
        pass

    def prepareOpenMediaSource(self, media_id: 'str') -> 'dict[str, Any]':
        pass

    def prepareMediaPreview(self, media_id: 'str') -> 'dict[str, Any]':
        pass

    def prepareMediaCrop(self, payload: 'dict[str, Any]') -> 'dict[str, Any]':
        pass

    def deleteMedia(self, media_id: 'str') -> 'dict':
        pass

    def deleteMediaItems(self, media_ids: 'list[Any]') -> 'dict[str, Any]':
        pass

    def renameMedia(self, media_id: 'str', new_name: 'str') -> 'dict[str, Any]':
        pass

    def updateMediaAssetType(self, media_id: 'str', asset_type: 'str') -> 'dict[str, Any]':
        pass

    def attachMediaToCard(self, card_id: 'str', media_id: 'str') -> 'dict[str, Any]':
        pass

    def attachMediaSelection(self, card_id: 'str', selection: 'dict[str, Any]') -> 'dict[str, Any]':
        pass

    def _media_asset_payload(self, media: 'dict[str, Any]', preview_payload: 'dict[str, Any] | None' = None) -> 'dict[str, Any]':
        pass

    def _resolve_media_payload(self, media_id: 'str', fallback: 'dict[str, Any] | None' = None) -> 'dict[str, Any]':
        pass

    def refreshProductLibrary(self, search: 'str' = '', category: 'str' = '') -> 'None':
        pass

    def addBlankProduct(self) -> 'dict[str, Any]':
        pass

    def saveProduct(self, payload: 'dict[str, Any]') -> 'dict[str, Any]':
        pass

    def importProductCsv(self, path: 'str') -> 'None':
        pass

    def previewProductCsv(self, path: 'str') -> 'dict[str, Any]':
        pass

    def importProductCsvRows(self, rows: 'list[Any]') -> 'dict[str, Any]':
        pass

    def downloadProductCsvTemplate(self) -> 'dict[str, Any]':
        pass

    def attachProductMainImagePaths(self, product_id: 'str', paths: 'list[Any]') -> 'dict[str, Any]':
        pass

    def attachProductMainImageSelection(self, product_id: 'str', selection: 'dict[str, Any]') -> 'dict[str, Any]':
        pass

    def attachProductExtraImagePaths(self, product_id: 'str', paths: 'list[Any]') -> 'dict[str, Any]':
        pass

    def attachProductExtraImageSelection(self, product_id: 'str', selection: 'dict[str, Any]') -> 'dict[str, Any]':
        pass

    def deleteProduct(self, product_id: 'str') -> 'dict[str, Any]':
        pass

    def refreshCharacters(self, search: 'str' = '') -> 'None':
        pass

    def createRouteCharacter(self, name: 'str', description: 'str') -> 'None':
        pass

    def selectRouteCharacter(self, character: 'dict[str, Any]') -> 'dict[str, Any]':
        pass

    def saveRouteCharacter(self, payload: 'dict[str, Any]') -> 'dict[str, Any]':
        pass

    def removeRouteCharacter(self, character_id: 'str') -> 'dict[str, Any]':
        pass

    def replaceRouteCharacterImage(self, character_id: 'str', media_id: 'str') -> 'dict[str, Any]':
        pass

    def replaceRouteCharacterImageSelection(self, character_id: 'str', selection: 'dict[str, Any]') -> 'dict[str, Any]':
        pass

    def setRouteCharacterSelection(self, selection: 'dict[str, Any]', available_items: 'list[Any]') -> 'dict[str, Any]':
        pass

    def setCloneLibraryAssetSelection(self, category: 'str', selection: 'dict[str, Any]', available_items: 'list[Any]') -> 'dict[str, Any]':
        pass

    def removeCloneLibraryAssetSelection(self, category: 'str', media_id: 'str') -> 'dict[str, Any]':
        pass

    def setRouteLibraryAssetSelection(self, category: 'str', selection: 'dict[str, Any]', available_items: 'list[Any]') -> 'dict[str, Any]':
        pass

    def removeRouteLibraryAssetSelection(self, category: 'str', media_id: 'str') -> 'dict[str, Any]':
        pass

    def moveRouteCharacterSelection(self, media_id: 'str', offset: 'int') -> 'dict[str, Any]':
        pass

    def removeRouteCharacterSelection(self, media_id: 'str') -> 'dict[str, Any]':
        pass

    def manageJobCharacters(self, job_id: 'str') -> 'dict[str, Any]':
        pass

    def _selected_character_payload(self) -> 'dict[str, Any]':
        pass

    def updateTranscriptInstruction(self, card_id: 'str', instruction: 'str') -> 'dict[str, Any]':
        pass

    def setTranscriptCardInstruction(self, card_id: 'str', instruction: 'str') -> 'None':
        pass

    def updateTranscriptJobPrompt(self, job_id: 'str', prompt: 'str') -> 'dict[str, Any]':
        pass

    def regenTranscriptJob(self, job_id: 'str') -> 'dict[str, Any]':
        pass

    def deleteTranscriptJob(self, job_id: 'str') -> 'dict[str, Any]':
        pass

    def openTranscriptJobOutput(self, job_id: 'str') -> 'dict[str, Any]':
        pass

    def requestTranscriptAudioFiles(self) -> 'None':
        pass

    def requestTranscriptAudioFolder(self) -> 'None':
        pass

    def addTranscriptAudioFromLink(self, url: 'str') -> 'None':
        pass

    def fetchTranscriptLinks(self, blob: 'str') -> 'None':
        pass

    def _apply_transcript_link_meta_payload(self, items: 'list[Any]') -> 'None':
        pass

    def setTranscriptInputMode(self, mode: 'str') -> 'None':
        pass

    def transcriptAspectsFor(self, category_id: 'str') -> 'list[dict[str, Any]]':
        pass

    def transcriptContentHistory(self, category_id: 'str') -> 'list[dict[str, Any]]':
        pass

    def removeTranscriptHistoryEntry(self, category_id: 'str', key: 'str') -> 'list[dict[str, Any]]':
        pass

    def clearTranscriptContentHistory(self, category_id: 'str') -> 'list[dict[str, Any]]':
        pass

    def previewTranscriptAiContent(self, config: 'dict[str, Any]') -> 'None':
        pass

    def _apply_transcript_ai_preview(self, payload: 'dict[str, Any]') -> 'None':
        pass

    def pollTranscriptJobStatus(self, row_id: 'str') -> 'dict[str, Any]':
        pass

    def submitTranscriptFromApi(self, payload: 'dict') -> 'dict[str, Any]':
        pass

    def buildAndDispatchTranscriptJobs(self, files: 'list', config: 'dict') -> 'dict[str, Any]':
        pass

    def onTranscriptChargenCompleted(self, job_id: 'str', success: 'bool') -> 'dict[str, Any]':
        pass

    def triggerTranscriptAutoMerge(self, row_id: 'str') -> 'dict[str, Any]':
        pass

    def saveTranscriptJobSnapshot(self, row_id: 'str') -> 'dict[str, Any]':
        pass

    def _connect_transcript_auto_merge_service(self) -> 'None':
        pass

    def _on_transcript_auto_merge_completed(self, output_folder: 'str', source_tab: 'str', success: 'bool', output_path: 'str', error: 'str') -> 'None':
        pass

    def _transcript_audio_cards(self) -> 'list[dict[str, Any]]':
        pass

    def _load_transcript_job_panel_rows(self) -> 'list[dict[str, Any]]':
        pass

    def _sync_transcript_job_panel_filter_lifecycle(self) -> 'None':
        pass

    def set_transcript_job_id_filter(self, transcript_job_id: 'str | None') -> 'None':
        pass

    def _remove_transcript_audio_file(self, card_id: 'str') -> 'bool':
        pass

    def _clear_transcript_audio_files(self) -> 'int':
        pass

    def _set_transcript_feature_config(self, data: 'dict[str, Any]') -> 'None':
        pass

    def _enqueue_transcript_spec(self, files: 'list[dict[str, Any]]', config_overrides: 'dict[str, Any] | None' = None) -> 'dict[str, Any]':
        pass

    def _handle_transcript_enqueue(self, res: 'dict[str, Any]', ok_message: 'str') -> 'bool':
        pass

    def _transcript_selected_characters(self) -> 'list[dict[str, Any]]':
        pass

    def _load_transcript_route_config(self) -> 'dict[str, Any]':
        pass

    def _persist_transcript_route_config(self) -> 'None':
        pass

    def _transcript_master_overlay(self) -> 'dict[str, Any]':
        pass

    def _track_transcript_queue_start(self, result: 'dict[str, Any]') -> 'dict[str, Any]':
        pass

    def addAffiliateProductCard(self, product: 'dict[str, Any]') -> 'dict[str, Any]':
        pass

    def addAffiliateProductCards(self, products: 'list[Any]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_affiliate_uc', 'addAffiliateProductCards', 'get', 'product_ids', 'str', '', 'strip', '_start_affiliate_prep', 'force', False
        pass

    def saveAffiliateProductFromImage(self, payload: 'dict[str, Any]') -> 'dict[str, Any]':
        pass

    def affiliateImageBusy(*args, **kwargs):
        pass

    def affiliateImportLibraryBusy(*args, **kwargs):
        pass

    def affiliateImportLibraryMessage(*args, **kwargs):
        pass

    def refreshAffiliateImportLibrary(self, search: 'str' = '') -> 'None':
        # [PyArmor BCC constants]: 'str', '', '_affiliate_import_library_search', 1, '_affiliate_import_library_seq', '_affiliate_import_library_busy', True, 'affiliateImportLibraryBusyChanged', 'emit', 'list_import_library', 'ok', 'seq', 'rows', 'error', False
        pass

    def _on_affiliate_import_library_payload(self, payload: 'dict[str, Any]') -> 'None':
        # [PyArmor BCC constants]: 'int', 'get', 'seq', 0, '_affiliate_import_library_seq', '_affiliate_import_library_model', 'setRows', 'list', 'rows', False, '_affiliate_import_library_busy', 'affiliateImportLibraryBusyChanged', 'emit'
        pass

    def _affiliate_import_library_protected_ids(self) -> 'list[str]':
        # [PyArmor BCC constants]: 'set', '_affiliate_prep_lock', 'update', '_affiliate_prep_active', '_affiliate_prep_queued', '_cards_by_route', 'get', 'affiliate', 'isinstance', 'dict', 'product', 'str', 'product_id', '', 'strip'
        pass

    def cleanupAffiliateImportLibrary(self, action: 'str', product_ids: 'list[Any]', preserve_product_ids: 'list[Any]') -> 'None':
        """Run destructive catalog/staging work off the GUI thread."""
        pass

    def _on_affiliate_import_library_cleanup_payload(self, payload: 'dict[str, Any]') -> 'None':
        # [PyArmor BCC constants]: 'int', 'get', 'cleanup_seq', 0, '_affiliate_import_library_cleanup_seq', 'ok', '_affiliate_import_library_model', 'setRows', 'list', 'rows', 'removed_products', 'deleted_staging_files', 'blocked_count', 'float', 'freed_bytes'
        pass

    def _reimport_affiliate_products_async(self, product_ids: 'list[str]') -> 'None':
        pass

    def _on_affiliate_reimport_payload(self, payload: 'dict[str, Any]') -> 'None':
        # [PyArmor BCC constants]: 'int', 'get', 'seq', 0, '_affiliate_reimport_seq', 'products', 'isinstance', 'dict', 'ok', '_state', 'set_status', 'Không mở lại được sản phẩm đã chọn từ kho.', 'source_paths', 'str', ''
        pass

    def importAffiliateImagesAsync(self, paths: 'list[Any]') -> 'None':
        # [PyArmor BCC constants]: 'str', '', 'strip', 1, '_affiliate_image_seq', True, '_affiliate_image_busy', 'affiliateImageBusyChanged', 'emit', '_state', 'set_status', 'Đang phân tích ', 'len', ' ảnh sản phẩm…', 'threading'
        pass

    def addAffiliateProductMultiAngle(self, paths: 'list[Any]', name: 'str' = '', category: 'str' = '') -> 'None':
        # [PyArmor BCC constants]: 'str', '', 'strip', 1, '_affiliate_image_seq', True, '_affiliate_image_busy', 'affiliateImageBusyChanged', 'emit', '_state', 'set_status', 'Đang chuẩn hoá ', 'len', ' ảnh sản phẩm…', 'threading'
        pass

    def _run_affiliate_multiangle_import(self, paths: 'list[str]', name: 'str', category: 'str', seq: 'int') -> 'None':
        # [PyArmor BCC constants]: '_affiliate_uc', 'normalizeAndPrepareProduct', 'ok', 'error', 'payload', 'analysis', False, 'str', 'Exception', '_affiliate_image_seq', '_affiliateImagePayload', 'emit', '_seq', 'done', 'count'
        pass

    def _run_affiliate_image_import(self, paths: 'list[str]', seq: 'int') -> 'None':
        # [PyArmor BCC constants]: 'name', 'price', 'paths', '', '_run_affiliate_products_import'
        pass

    def scanAffiliateImportFolder(self, parent_folder: 'str') -> 'list':
        """
        Quét folder CHA cho dialog import: mỗi thư mục con (có ảnh) = 1 SP dự kiến
                [{name, paths, count}]; không có thư mục con → chính folder = 1 SP. Chỉ
                listdir nông 2 cấp (không đọc nội dung file), one-shot lúc user chọn folder
                — đủ nhẹ cho slot sync (folder mạng chậm là ca chấp nhận, xử riêng nếu kêu).
        """
        # [PyArmor BCC constants]: 'folder', 'str', 'return', 'list[str]'
        pass

    def importAffiliateProductsAsync(self, items: 'list[Any]') -> 'None':
        """
        MỘT ĐƯỜNG IMPORT DUY NHẤT (dialog Import SP): mỗi item {name, price, paths[]}
                = 1 SP — TẤT CẢ đều qua chuẩn hoá (upload → AI vision → nano-banana sheet),
                pool 3 luồng, card về GUI qua queued signal (Law 1 + Law 3).
        """
        # [PyArmor BCC constants]: 'rating_count', 'stock', 'discount', 'tiktok_product_id', 'browser_account'
        pass

    def _start_next_affiliate_import_batch(self) -> 'None':
        # [PyArmor BCC constants]: '_affiliate_image_busy', '_affiliate_import_backlog', 'popleft', 1, '_affiliate_image_seq', True, 'affiliateImageBusyChanged', 'emit', '_state', 'set_status', 'Đang chuẩn hoá ', 'len', ' sản phẩm…', 'threading', 'Thread'
        pass

    def startAffiliatePrep(self, product_id: 'str') -> 'None':
        pass

    def importTikTokShowcaseAsync(self, limit: 'int' = 50, account: 'str' = '') -> 'None':
        # [PyArmor BCC constants]: 'str', '', 'strip', 'affiliateOverlayProductReady', 'emit', 'dict', 'Exception', '_state', 'set_status', 'TikTok ', '/', ': ', 40, '…', 'harvest_showcase'
        pass

    def affiliateBrowserAccounts(self) -> 'list[Any]':
        # [PyArmor BCC constants]: 'list_accounts', 'dict', 'key', 'affiliate', 'label', 'Kênh chính', 'Exception'
        pass

    def affiliateChannelStatus(self) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'channels_status', 'items', 'bool', 'Exception'
        pass

    def openAffiliateChannelBrowser(self, account: 'str') -> 'None':
        # [PyArmor BCC constants]: 'str', '', 'strip', 'MARKETPLACE_URLS', 'start_browse', 'initial_url', 'tiktok', 'account', '_state', 'set_status', "Đã mở browser kênh '", "'", "Không mở được browser kênh '", 'Lỗi mở browser kênh: ', 'type'
        pass

    def addAffiliateBrowserAccount(self, label: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'add_account', 'dict', 'ok', 'error', False, 'type', '__name__', 'Exception', 'get', 'existed', '_state', 'set_status', "Đã thêm kênh '", 'label', "' — lần đầu dùng sẽ cần đăng nhập sàn trên browser mới."
        pass

    def forgetTikTokHarvested(self) -> 'int':
        # [PyArmor BCC constants]: 'forget_harvested', 'int', 0, 'Exception', '_state', 'set_status', 'Đã quên ', ' SP TikTok đã lấy — lần sau sẽ lấy lại từ đầu.'
        pass

    def fetchAffiliateLinks(self, force: 'bool' = False) -> 'None':
        # [PyArmor BCC constants]: '_affiliate_uc', 'fetchAffiliateLinksSync', 'bool', 'ok', 'message', False, 'Lỗi lấy link: ', 'type', '__name__', 'Exception', '_state', 'set_status', 'str', 'get', ''
        pass

    def reprepAffiliateProduct(self, product_id: 'str') -> 'None':
        pass

    def _ensure_affiliate_prep_pool(self) -> 'None':
        # [PyArmor BCC constants]: '_affiliate_prep_pool', 'ThreadPoolExecutor', 'register_executor', 'max_workers', 2, 'thread_name_prefix', 'AffPrep', 'work-panel-affiliate-prep'
        pass

    def _ensure_affiliate_aux_pool(self) -> 'None':
        # [PyArmor BCC constants]: '_affiliate_prep_lock', '_affiliate_aux_pool', 'ThreadPoolExecutor', 'register_executor', 'max_workers', 2, 'thread_name_prefix', 'AffAux', 'work-panel-affiliate-aux'
        pass

    def _drain_affiliate_prep_queue_locked(self) -> 'None':
        # [PyArmor BCC constants]: '_ensure_affiliate_prep_pool', 'len', '_affiliate_prep_active', 2, '_affiliate_prep_pending', 'popleft', '_affiliate_prep_queued', 'discard', 'add', '_affiliate_prep_pool', 'submit', '_run_affiliate_prep_worker', 'bool'
        pass

    def _start_affiliate_prep(self, product_id: 'str', *, force: 'bool', preflight_checked: 'bool' = False) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'ok', 'blocked', 'route', 'action', 'code', 'error', 'message'
        pass

    def _ensure_affiliate_prep_ready(self, product_id: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'str', '', 'strip', 'ok', False, 'error', 'product_id_missing', 'get_affiliate_product_store', 'get_product', 'isinstance', 'get', 'prep_sheets', 'dict', '_route_configs', 'affiliate'
        pass

    def _run_affiliate_prep_worker(self, pid: 'str', force: 'bool') -> 'None':
        # [PyArmor BCC constants]: 'product_id', 'stage', 'str', '', 'update', '_affiliatePrepEvent', 'emit', 'ok', False, 'error', 'prep_failed', 'dict', '_affiliate_uc', 'runAffiliatePrepSync', 'status_cb'
        pass

    def _on_affiliate_prep_event(self, data: 'dict[str, Any]') -> 'None':
        # [PyArmor BCC constants]: 'str', 'get', 'product_id', '', 'stage', 'dict', 'setdefault', '_on_affiliate_lifecycle_event', 'variants', 'isinstance', 'list', '_route_configs', 'affiliate', 'campaign_plan', '_affiliate_uc'
        pass

    def _affiliate_ready_card_count(self) -> 'int':
        # [PyArmor BCC constants]: 0, '_cards_by_route', 'get', 'affiliate', 'isinstance', 'dict', 'selected', False, 'product', 'str', 'prep_status', '', 'strip', 'lower', 'ready'
        pass

    def _schedule_affiliate_auto_pool(self, product_id: 'str' = '', *, manual: 'bool' = False) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_affiliate_pool_orchestrating', 'ok', False, 'blocked', True, 'route', 'affiliate', 'action', 'affiliate.queue.manual_enqueue', 'code', 'affiliate_pool_busy', 'error', 'message', 'Affiliate đang chốt một sản phẩm khác; hãy đợi tác vụ hiện tại hoàn tất.', '_route_configs'
        pass

    def _run_affiliate_auto_pool_turn(self) -> 'None':
        # [PyArmor BCC constants]: '_affiliate_run_generate_script', '_affiliate_run_cards_snapshot', 0, 'str', 'get', 'id', '', '_affiliateCampaignFinishedEvent', 'emit', 'campaign_id', 'queued_variants', 'successful_column_ids', 'failed_products', 'error', 'column_id'
        pass

    def _on_affiliate_campaign_finished(self, data: 'dict[str, Any]') -> 'None':
        """
        GUI thread: keep source cards visible and mark durable queue admission.
        
                A ``batch_id`` means the variant was accepted by the queue; it does not
                mean its scenes rendered, merged, or published. Removing the product here
                destroyed the only visible preparation state while the jobs were still
                running.
        """
        # [PyArmor BCC constants]: 'preparation', 'planning', 'package', 'queue'
        pass

    def startAffiliateBrowseImport(self, target: 'str' = 'shopee', account: 'str' = '') -> 'None':
        # [PyArmor BCC constants]: 'DEFAULT_ACCOUNT', 'resolve_marketplace_url', 'str', '', 'strip', 'open_import_browse', 'panel_enabled', '_emit_overlay_product', 'initial_url', 'account', 'on_message', 'use_side_panel', 'get', 'ok', '_state'
        pass

    def _on_overlay_message(self, account: 'str', msg_type: 'str', payload: 'dict[str, Any]', push) -> 'None':
        # [PyArmor BCC constants]: 'str', '', 'isinstance', 'dict', 'AFFILIATE_ALLOW_REIMPORT', 'getattr', '_overlay_reimport_running', False, 'TOAST', 'message', 'Đang mở lại sản phẩm để làm video', True, 'threading', 'Thread', 'target'
        pass

    def _overlay_run_allow_reimport(self, payload: 'dict[str, Any]', push) -> 'None':
        """
        Bỏ gate ĐÃ LÀM bền vững; giữ nguyên History và video cũ.
        
                SQLite + policy aggregation run on this daemon worker, never on the
                browser poll/UI thread. The panel receives one atomic policy snapshot.
        """
        # [PyArmor BCC constants]: 'ok', 'platform', 'item_ids', 'count', 'message'
        pass

    def _overlay_run_harvest(self, account: 'str', push, skip_known: 'bool' = True) -> 'None':
        # [PyArmor BCC constants]: 'list', 'get', 'image_urls', 'name', 'price', 'id', 'count', 'image', 'status', 'str', '', 'tiktok_product_id', 'len', 0, 'done'
        pass

    def _overlay_run_tiktok_catalog(self, account: 'str', push) -> 'None':
        # [PyArmor BCC constants]: 'TIKTOK_CATALOG_PROGRESS', 'running', True, 'message', 'Đang đồng bộ showcase TikTok…', '_tiktok_showcase_policy', 'MAX_SHOWCASE_PRODUCTS', 'fetch_showcase_products', 'account', 'get', 'ok', 'rows', 'TIKTOK_CATALOG_DATA', 'products', 'count'
        pass

    def _overlay_run_tiktok_preview(self, account: 'str', payload: 'dict[str, Any]', push) -> 'None':
        # [PyArmor BCC constants]: 'isinstance', 'get', 'product', 'dict', 'str', 'tiktok_product_id', 'product_id', '', 'request_id', 'TIKTOK_PRODUCT_PREVIEW_DATA', 'ok', 'item_id', 'error', False, 'missing_product_id'
        pass

    def _overlay_run_tiktok_import(self, account: 'str', payload: 'dict[str, Any]', push) -> 'None':
        """Lô TikTok → PDP detail trên một tab, chia chunk có backpressure."""
        # [PyArmor BCC constants]: 'running', 'done', 'total', 'current'
        pass

    def _overlay_run_tiktok_action(self, account: 'str', payload: 'dict[str, Any]', push) -> 'None':
        # [PyArmor BCC constants]: 'str', 'get', 'action', '', 'strip', 'lower', 'product_ids', 100, 'TIKTOK_ACTION_PROGRESS', 'running', 'count', True, 'len', '_tiktok_showcase_policy', 'current_page'
        pass

    def _overlay_run_links(self, push) -> 'None':
        # [PyArmor BCC constants]: '_affiliate_uc', 'fetchAffiliateLinksSync', False, 'TOAST', 'message', 'Lấy link lỗi: ', 'type', '__name__', 'Exception', 'isinstance', 'get', 'links', 'dict', 'items', 'name'
        pass

    def _overlay_run_shopee_catalog(self, account: 'str', payload: 'dict[str, Any]', push) -> 'None':
        # [PyArmor BCC constants]: 'SHOPEE_CATALOG_PROGRESS', 'running', True, 'message', 'Đang tải toàn bộ catalog từ Shopee…', 'current_page', '_shopee_offer_policy', 'fetch_offer_catalog', 'account', 'list_api_url', 'str', 'get', '', 'page_url', 'keyword'
        pass

    def _overlay_run_shopee_preview(self, account: 'str', payload: 'dict[str, Any]', push) -> 'None':
        # [PyArmor BCC constants]: 'isinstance', 'get', 'product', 'dict', 'str', 'offer_item_id', '', 'request_id', 'SHOPEE_OFFER_PREVIEW_DATA', 'ok', 'item_id', 'error', False, 'missing_item_id', 'current_page'
        pass

    def _overlay_run_shopee_offers(self, account: 'str', payload: 'dict[str, Any]', push) -> 'None':
        """Product Offer → chunk detail/link trên một tab, ngoài GUI thread."""
        # [PyArmor BCC constants]: 'running', 'done', 'total', 'current'
        pass

    def _emit_overlay_product(self, data: 'dict[str, Any]') -> 'None':
        # [PyArmor BCC constants]: 'print', "📤 [AFF.overlay] marshal SP về GUI thread: '", 'str', 'get', 'name', '', 40, "'", 'flush', True, '_affiliateOverlayProduct', 'emit', 'dict', '⚠️ [AFF.overlay] marshal lỗi: ', 'Exception'
        pass

    @staticmethod
    def _overlay_product_row(data: 'dict[str, Any]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'dict', 'get', 'price', 'isinstance', 'int', 'float', ',', 'replace', '.', 'đ', 'image_urls', 'str', '', 'strip', 'name'
        pass

    def _emit_overlay_products(self, products: 'list[dict[str, Any]]') -> 'None':
        # [PyArmor BCC constants]: 'isinstance', 'dict', '_overlay_product_row', 'print', '📤 [AFF.overlay] marshal lô ', 'len', ' SP về GUI thread', 'flush', True, 'affiliateImportRowsReady', 'emit'
        pass

    def _on_affiliate_overlay_product(self, data: 'dict[str, Any]') -> 'None':
        # [PyArmor BCC constants]: '_overlay_product_row', 'str', 'get', 'name', '', 'print', "🧲 [AFF.overlay] GUI nhận SP: '", 40, "' (", 'count', ' ảnh URL) → affiliateOverlayProductReady (UI quyết: bảng dialog hay thẳng KHO)', 'flush', True, '_state', 'set_status'
        pass

    def importAffiliateLinksAsync(self, links_text: 'str') -> 'None':
        # [PyArmor BCC constants]: 'str', '', 'splitlines', 'strip', 'startswith', 'http', '_state', 'set_status', 'Không có link hợp lệ (mỗi dòng 1 link Shopee/TikTok).', True, '_affiliate_image_busy', 'affiliateImageBusyChanged', 'emit', 'Đang lấy ', 'len'
        pass

    def _affiliate_prepare_import_item(self, item: 'dict[str, Any]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'list', 'get', 'paths', 'image_urls', 'str', 'browser_account', '', 'strip', 'len', 10, 'current_page', 'fetch_images_from_browser', 'account', 'limit', 'set'
        pass

    def _run_affiliate_products_import(self, items: 'list[dict[str, Any]]', seq: 'int') -> 'None':
        # [PyArmor BCC constants]: 'ThreadPoolExecutor', 'as_completed', 'len', 0, 'max_workers', 3, 'thread_name_prefix', 'AffImport', 'submit', '_affiliate_prepare_import_item', '_affiliate_image_seq', 'print', 'ℹ️ [AFF.import] batch import bị thay bởi batch mới (seq đổi) — dừng batch cũ', 'flush', True
        pass

    def _on_affiliate_image_payload(self, msg: 'dict[str, Any]') -> 'None':
        # [PyArmor BCC constants]: 'int', 'get', '_seq', 0, '_affiliate_image_seq', '_affiliate_uc', 'applyAffiliateImportResult', 'str', '_import_token', '', 'dict', 'result', 'isinstance', 'ok', 'print'
        pass

    def previewAffiliateVoice(self, voice_name: 'str' = '') -> 'dict[str, Any]':
        pass

    def affiliateVoiceConfig(self) -> 'dict[str, Any]':
        pass

    def saveAffiliateVoiceConfig(self, payload: 'dict[str, Any]') -> 'dict[str, Any]':
        pass

    def autoFillAffiliateStartImages(self) -> 'dict[str, Any]':
        pass

    def clearAffiliateStartImages(self) -> 'dict[str, Any]':
        pass

    def removeAffiliateStartImage(self, slot_index: 'int') -> 'dict[str, Any]':
        pass

    def addAffiliateStartImageSelection(self, slot_index: 'int', selection: 'dict[str, Any]') -> 'dict[str, Any]':
        pass

    def affiliateTemplates(self) -> 'list[dict[str, Any]]':
        pass

    def affiliateTemplateConfig(self) -> 'dict[str, Any]':
        pass

    def saveAffiliateTemplate(self, template_key: 'str') -> 'dict[str, Any]':
        pass

    def saveAffiliateMode(self, mode: 'str') -> 'None':
        pass

    def generateAffiliateAsset(self, asset_type: 'str', product_brief: 'str', style: 'str') -> 'None':
        pass

    def generateAffiliateAssetContract(self, payload: 'dict[str, Any]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'dict', '_route_configs', 'get', 'affiliate', 'str', 'market', '', 'strip', 'vietnam', 'voice_language', 'prompt', True, 'ai_compose', 'isinstance', 'product'
        pass

    def selectAffiliateAssetContract(self, payload: 'dict[str, Any]') -> 'dict[str, Any]':
        pass

    def saveAffiliateAssetContract(self, payload: 'dict[str, Any]') -> 'dict[str, Any]':
        pass

    def addAffiliateRouteAssetSelection(self, asset_type: 'str', selection: 'dict[str, Any]') -> 'dict[str, Any]':
        pass

    def addAffiliateRouteAssetFromSaved(self, asset_type: 'str', payload: 'dict[str, Any]') -> 'dict[str, Any]':
        pass

    def removeAffiliateRouteAsset(self, asset_type: 'str', asset_id: 'str') -> 'dict[str, Any]':
        pass

    def removeAffiliateRouteAssetFromColumn(self, asset_type: 'str', asset_id: 'str', column_id: 'str') -> 'dict[str, Any]':
        pass

    def toggleAffiliateRouteAssetAuto(self, asset_type: 'str', enabled: 'bool') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_affiliate_ui_preview', 'ok', False, 'preview', True, 'message', 'Affiliate UI Preview chỉ dùng để xem giao diện.', '_affiliate_uc', 'toggleAffiliateRouteAssetAuto'
        pass

    def affiliateBriefField(self, key: 'str') -> 'str':
        pass

    def affiliateJobEstimate(self) -> 'str':
        pass

    def affiliateModelBudget(self, model_key: 'str' = '') -> 'dict[str, Any]':
        pass

    def affiliateSalesKit(self, product_id: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_affiliate_ui_preview', 'dict', '_route_configs', 'get', 'affiliate', '_preview_sales_kits', 'str', '', 'isinstance', 'get_affiliate_product_store', 'sales_kit_for_product', 'get_product', '_affiliate_queue_config', 'video_model_key', 'prep_checklist'
        pass

    def affiliateMaxVariants(self) -> 'int':
        pass

    def affiliatePreviewScenes(self) -> 'list':
        pass

    def affiliatePreviewSceneCount(self) -> 'int':
        pass

    def affiliateGeneratingStatusText(self) -> 'str':
        pass

    def generateAffiliateAssetByType(self, asset_type: 'str', product_id: 'str') -> 'dict[str, Any]':
        pass

    def autoFillAffiliateProductSlots(self, product_id: 'str') -> 'dict[str, Any]':
        pass

    def onAffiliateJobCompleted(self, job_id: 'str', success: 'bool', output_path: 'str') -> 'dict[str, Any]':
        pass

    def onAffiliateSceneUpscaleCompleted(self, job_id: 'str', scene_index: 'int', success: 'bool') -> 'dict[str, Any]':
        pass

    def _load_affiliate_route_config(self) -> 'dict[str, Any]':
        pass

    def _affiliate_queue_config(self) -> 'dict[str, Any]':
        pass

    def _affiliate_run_generate_script(self) -> 'None':
        pass

    def addBatchReferenceImages(self, paths: 'list[Any]') -> 'dict[str, Any]':
        pass

    def addBatchMediaReferences(self, selection: 'dict[str, Any]') -> 'dict[str, Any]':
        pass

    def attachBatchReferenceImagesToTarget(self, target_id: 'str', paths: 'list[Any]') -> 'dict[str, Any]':
        pass

    def attachBatchMediaReferencesToTarget(self, target_id: 'str', selection: 'dict[str, Any]') -> 'dict[str, Any]':
        pass

    def removeBatchReferenceImageFromTarget(self, target_id: 'str', ref_index: 'int') -> 'dict[str, Any]':
        pass

    def setBatchConfig(self, variations: 'int', anti_duplicate: 'bool', instructions: 'str', character_strategy: 'str', variation_strength: 'str', aspect_ratio: 'str' = '', model: 'str' = '') -> 'dict[str, Any]':
        pass

    def startCloneBatchGeneration(self, row_id: 'str') -> 'dict[str, Any]':
        pass

    def executeBatchAction(self, action: 'str') -> 'None':
        pass

    def applyBatchActions(self, payload: 'dict[str, Any]') -> 'dict[str, Any]':
        pass

    def applyJobPanelBatchActions(self, payload: 'dict[str, Any]') -> 'dict[str, Any]':
        pass

    def pollBatchTranscriptCompletion(self, row_ids: 'list') -> 'dict[str, Any]':
        pass

    def updateBatchJobInSession(self, job_id: 'str', updates: 'dict') -> 'dict[str, Any]':
        pass

    def onBatchImageGenerated(self, job_id: 'str', success: 'bool', output_path: 'str') -> 'dict[str, Any]':
        pass

    def matchBatchReferencesByName(self, prompts: 'list') -> 'dict[str, Any]':
        pass

    def _normalize_batch_reference_media_selection(self, selection: 'dict[str, Any]') -> 'list[dict[str, Any]]':
        pass

    def _process_events(self) -> 'None':
        pass

    def _clipboard(self):
        pass

    def _qurl(self, text: 'str'):
        pass

    def prepareCloneVoicePicker(self) -> 'dict[str, Any]':
        pass

    def _connect_clone_auto_merge_service(self) -> 'None':
        pass

    def _set_clone_auth_pause(self, required: 'bool') -> 'None':
        pass

    def _set_clone_no_live_accounts_pause(self, required: 'bool') -> 'None':
        pass

    def _set_clone_terminal_pause_dialog(self, code: 'str', detail: 'str' = '') -> 'None':
        pass

    def _clone_has_no_live_accounts_pause(self, rows: 'list[dict[str, Any]]') -> 'bool':
        pass

    def _clone_terminal_alert_payload(self, rows: 'list[dict[str, Any]]') -> 'tuple[str, str, str]':
        pass

    def _on_prompt_status_for_clone_auth(self, prompt_data: 'object', status_msg: 'str') -> 'None':
        pass

    def _clone_queue_all_completed(self, rows: 'list[dict[str, Any]]') -> 'bool':
        pass

    def _maybe_auto_start_next_clone_job(self, rows: 'list[dict[str, Any]]') -> 'None':
        pass

    def _on_clone_auto_merge_completed(self, output_folder: 'str', source_tab: 'str', success: 'bool', output_path: 'str', error: 'str') -> 'None':
        pass

    def _ensure_affiliate_auto_merge_connected(self) -> 'None':
        # [PyArmor BCC constants]: '_affiliate_auto_merge_service_connected', '_try_get_auto_merge_service', 'merge_completed', 'connect', '_on_affiliate_auto_merge_completed', 'Exception', True
        pass

    def _on_affiliate_auto_merge_completed(self, output_folder: 'str', source_tab: 'str', success: 'bool', output_path: 'str', error: 'str') -> 'None':
        # [PyArmor BCC constants]: 'str', '', 'strip', 'lower', 'affiliate', '_route', True, '_queue_dirty', 'refreshQueueAndStats', '_state', 'set_status', 'Affiliate: đã ghép 1 video sản phẩm → '
        pass

    def addClonePipelineUrls(self, urls: 'list[Any]') -> 'dict[str, Any]':
        pass

    def previewClonePipeline(self, inputs: 'list[Any]', video_type: 'str', min_views: 'int') -> 'dict[str, Any]':
        pass

    def _toggle_transcript_audio_card(self, card_id: 'str', selected: 'bool') -> 'bool':
        # [PyArmor BCC constants]: 'str', '', 'strip', False, '_current_cards', 'isinstance', 'dict', 'get', 'id', 'row_id', 'batch_id', 'source_type', 'transcript_audio', 'bool', 'selected'
        pass

    def _set_transcript_audio_selected(self, selected: 'bool') -> 'int':
        # [PyArmor BCC constants]: 0, '_current_cards', 'isinstance', 'dict', 'str', 'get', 'source_type', '', 'transcript_audio', 'bool', 'selected', 1, '_emit_cards_changed'
        pass

    def _set_clone_source_selected(self, selected: 'bool') -> 'int':
        pass

    def _toggle_clone_source_card(self, card_id: 'str', selected: 'bool') -> 'bool':
        pass

    def _selected_clone_source_cards(self) -> 'list[dict[str, Any]]':
        pass

    def _set_clone_upload_selected(self, selected: 'bool') -> 'int':
        pass

    def _toggle_clone_upload_file(self, card_id: 'str', selected: 'bool') -> 'bool':
        pass

    def _remove_clone_upload_file(self, card_id: 'str') -> 'bool':
        pass

    def _clear_clone_upload_files(self) -> 'int':
        pass

    def _pending_selected_clone_upload_cards(self) -> 'list[dict[str, Any]]':
        pass

    def _find_clone_upload_card(self, card_id: 'str') -> 'dict[str, Any] | None':
        pass

    def _patch_clone_upload_card(self, card_id: 'str', patch: 'dict[str, Any]') -> 'bool':
        pass

    def _selected_clone_upload_cards_for_queue(self) -> 'list[dict[str, Any]]':
        pass

    def _clone_target_queue_row(self, row_id: 'str' = '') -> 'dict[str, Any] | None':
        pass

    def _clone_skip_candidate(self) -> 'dict[str, Any] | None':
        pass

    def _clone_upload_cache(self):
        pass

    def _coerce_clone_drop_paths(self, values: 'Any') -> 'list[str]':
        pass

    def recentCloneUploads(self) -> 'list[dict[str, Any]]':
        pass

    def cloneUploadCachePath(self) -> 'str':
        pass

    def useCachedCloneUpload(self, file_path: 'str') -> 'dict[str, Any]':
        pass

    def _load_clone_job_panel_rows(self) -> 'list[dict[str, Any]]':
        pass

    def set_clone_job_id_filter(self, clone_job_id: 'str | None') -> 'None':
        pass

    def _set_clone_feature_config(self, action_key: 'str', data: 'dict[str, Any]') -> 'None':
        pass

    def syncCloneDialogueLanguageForMarket(self, market_code: 'str') -> 'dict[str, Any]':
        pass

    def updateCloneJobPrompt(self, job_id: 'str', prompt: 'str') -> 'dict[str, Any]':
        pass

    def regenCloneJob(self, job_id: 'str') -> 'dict[str, Any]':
        pass

    def deleteCloneJob(self, job_id: 'str') -> 'dict[str, Any]':
        pass

    def openCloneJobOutput(self, job_id: 'str') -> 'dict[str, Any]':
        pass

    def copyCloneQueueRowJson(self, row_id: 'str') -> 'dict[str, Any]':
        pass

    def updateCloneScene(self, scene_id: 'str', title: 'str', prompt: 'str', notes: 'str') -> 'dict[str, Any]':
        pass

    def previewCloneClearQueue(self) -> 'dict[str, Any]':
        pass

    def resumeCloneQueueAfterAuthUpdate(self) -> 'dict[str, Any]':
        pass

    def refreshCloneVoiceReferences(self) -> 'dict[str, Any]':
        pass

    def setCloneVoiceSelection(self, selection: 'dict[str, Any]', available_items: 'list[Any]') -> 'dict[str, Any]':
        pass

    def removeCloneVoiceSelection(self, media_id: 'str') -> 'dict[str, Any]':
        pass

    def applyCloneStyleToAll(self, style: 'dict[str, Any]') -> 'dict[str, Any]':
        pass

    def _normalize_clone_voice_lock_config(self, config: 'dict[str, Any]') -> 'dict[str, Any]':
        pass

    def _clone_voice_lock_supported_cached(self) -> 'bool':
        pass

    def _clone_voice_reference_limit(self) -> 'int':
        pass

    def _invalidate_clone_flow_voice_cache(self) -> 'None':
        pass

    def _clone_flow_voice_options(self) -> 'list[dict[str, Any]]':
        pass

    def _restore_clone_voice_selection_from_config(self) -> 'None':
        pass

    def _selected_clone_voice_payload(self) -> 'dict[str, Any]':
        pass

    def _clone_audio_model_options(self) -> 'list[dict[str, Any]]':
        pass

    def _clone_audio_voice_options(self) -> 'list[dict[str, Any]]':
        pass

    def _clone_audio_preset_options(self) -> 'list[dict[str, Any]]':
        pass

    def _load_clone_route_config(self) -> 'dict[str, Any]':
        pass

    def _clone_master_overlay(self) -> 'dict[str, Any]':
        pass

    def _track_clone_queue_start(self, result: 'dict[str, Any]') -> 'dict[str, Any]':
        pass

    def _launch_clone_platform_login(self, text: 'str') -> 'None':
        pass

    def startCloneVideoPolling(self, job_id: 'str') -> 'dict[str, Any]':
        pass

    def retryFailedCloneScenes(self, session_key: 'str') -> 'dict[str, Any]':
        pass

    def processNextCloneJob(self) -> 'dict[str, Any]':
        pass

    def toggleAudioClone(self, enabled: 'bool') -> 'dict[str, Any]':
        pass

    def setCloneModel(self, model_key: 'str') -> 'dict[str, Any]':
        pass

    def commitExtendCardPrompt(self, card_id: 'str', prompt: 'str') -> 'dict[str, Any]':
        pass

    def extendCard(self, card_id: 'str') -> 'dict[str, Any]':
        pass

    def insertExtendAfter(self, card_id: 'str') -> 'dict[str, Any]':
        pass

    def toggleExtendTimeline(self, card_id: 'str') -> 'dict[str, Any]':
        pass

    def generateExtendForCard(self, card_id: 'str') -> 'dict[str, Any]':
        pass

    def importExtendBulk(self, raw_text: 'str', as_chain: 'bool') -> 'None':
        pass

    def importExtendItems(self, items: 'list[Any]', queue_mode: 'bool' = False) -> 'dict[str, Any]':
        pass

    def queueExtendIdea(self, idea: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_queue_extend_idea', 'ok', 'code', 'error', 'message', False, 'extend_idea_queue_failed', 'type', '__name__', 'Không thể thêm ý tưởng: ', '_state', 'set_action_result', 'set_status', 'Exception'
        pass

    def replaceExtendCards(self, items: 'list[Any]') -> 'dict[str, Any]':
        pass

    def importExtendGeneratedTimeline(self) -> 'dict[str, Any]':
        pass

    def extendGeneratedTimeline(self) -> 'list[dict[str, Any]]':
        # [PyArmor BCC constants]: '_extend_uc', '_extend_generated_timeline', 'print', '[ExtendStash] Bulk Preview read: ', 'len', ' beat(s)', 'flush', True
        pass

    def previewExtendRenderFolder(self, source_folder: 'str') -> 'dict[str, Any]':
        pass

    def loadExtendRules(self) -> 'str':
        pass

    def saveExtendRules(self, text: 'str') -> 'dict[str, Any]':
        pass

    def addExtendRootAssetSelection(self, slot_index: 'int', selection: 'dict[str, Any]') -> 'dict[str, Any]':
        pass

    def removeExtendRootAsset(self, slot_index: 'int') -> 'dict[str, Any]':
        pass

    def clearExtendRootAssets(self) -> 'dict[str, Any]':
        pass

    def useCurrentExtendRootSource(self) -> 'dict[str, Any]':
        pass

    def setExtendMode(self, mode: 'str') -> 'dict[str, Any]':
        pass

    def buildTimelapseKeyframes(self, final_image_path: 'str', stage_count: 'int', idea: 'str') -> 'dict[str, Any]':
        pass

    def analyzeExtendSource(self, idea: 'str') -> 'dict[str, Any]':
        pass

    def applySelectedExtendBeat(self, selected_index: 'int') -> 'dict[str, Any]':
        pass

    def queueSelectedExtendBeat(self, selected_index: 'int') -> 'dict[str, Any]':
        pass

    def regenerateSelectedExtendBeat(self, selected_index: 'int', idea: 'str' = '') -> 'dict[str, Any]':
        pass

    def previewExtendSessionTimeline(self) -> 'dict[str, Any]':
        pass

    def generateExtendTimeline(self, idea: 'str') -> 'dict[str, Any]':
        pass

    def startExtendRender(self, payload: 'dict[str, Any]') -> 'dict[str, Any]':
        pass

    def getExtendRenderTrackingStatus(self, tracking_job_id: 'str') -> 'dict[str, Any]':
        pass

    def cancelExtendRender(self, tracking_job_id: 'str') -> 'dict[str, Any]':
        pass

    def extendAvailableAccounts(self) -> 'list[dict[str, Any]]':
        pass

    def createExtendSession(self) -> 'dict[str, Any]':
        pass

    def createExtendSessionForAccount(self, account: 'dict[str, Any]') -> 'dict[str, Any]':
        pass

    def openExtendSession(self, session_key: 'str') -> 'dict[str, Any]':
        pass

    def deleteExtendSession(self, session_key: 'str') -> 'dict[str, Any]':
        pass

    def validateExtendCards(self) -> 'dict[str, Any]':
        pass

    def checkExtendChains(self) -> 'dict[str, Any]':
        pass

    def ensureExtendVeoContext(self, session_key: 'str') -> 'dict[str, Any]':
        pass

    def _pending_extend_queue_row(self, rows: 'list[dict[str, Any]]') -> 'dict[str, Any] | None':
        pass

    def _track_extend_queue_start(self, result: 'dict[str, Any] | None') -> 'dict[str, Any]':
        pass

    def _normalize_extend_items(self, items: 'list[Any]', *, append: 'bool', queued: 'bool') -> 'list[dict[str, Any]]':
        # [PyArmor BCC constants]: '_extend_uc', '_normalize_extend_items', 'append', 'queued'
        pass

    def _extend_rules_path(self) -> 'Path':
        pass

    def _extend_ai_root_assets(self) -> 'list[dict[str, Any]]':
        pass

    def _persist_extend_ai_state(self) -> 'None':
        pass

    def _extend_generated_timeline(self) -> 'list[dict[str, Any]]':
        pass

    def _set_extend_generated_timeline(self, items: 'list[dict[str, Any]]', message: 'str' = '', selected_index: 'int' = 0) -> 'list[dict[str, Any]]':
        pass

    def _extend_generated_scene(self, selected_index: 'int') -> 'dict[str, Any] | None':
        pass

    def _extend_generated_scene_to_item(self, scene: 'dict[str, Any]', fallback_index: 'int') -> 'dict[str, Any]':
        pass

    def _extend_source_analysis_media_payload(self) -> 'tuple[str, str]':
        pass

    def _extend_source_analysis_lines(self, analysis: 'dict[str, Any] | None' = None) -> 'list[str]':
        pass

    def _normalize_extend_root_asset(self, payload: 'dict[str, Any]', index: 'int') -> 'dict[str, Any]':
        pass

    def _extend_root_reference_images(self) -> 'list[dict[str, Any]]':
        pass

    def _extend_root_assets_from_card(self, card: 'dict[str, Any]') -> 'list[dict[str, Any]]':
        pass

    def _restore_extend_job_from_history(self, snapshot: 'dict[str, Any]') -> 'dict[str, Any]':
        pass

    def _load_extend_route_config(self) -> 'dict[str, Any]':
        pass

    def _persist_extend_route_config(self) -> 'None':
        pass

    def _decorate_extend_cards(self, cards: 'list[dict[str, Any]]') -> 'list[dict[str, Any]]':
        pass

    def _extend_chain_key(self, card: 'dict[str, Any]') -> 'str':
        pass

    def _ensure_extend_chain_index(self, root: 'dict[str, Any]') -> 'int':
        pass

    def _resolve_extend_root(self, card: 'dict[str, Any]') -> 'dict[str, Any] | None':
        pass

    def _extend_chain_cards(self, root: 'dict[str, Any]') -> 'list[dict[str, Any]]':
        pass

    def _last_extend_card(self, root: 'dict[str, Any]') -> 'dict[str, Any]':
        pass

    def _next_extend_position(self, root: 'dict[str, Any]') -> 'int':
        pass

    def _extend_root_has_output(self, root: 'dict[str, Any]') -> 'bool':
        pass

    def _extend_card_submitted(self, card: 'dict[str, Any]') -> 'bool':
        pass

    def _pending_extend_children(self, root: 'dict[str, Any]') -> 'list[dict[str, Any]]':
        pass

    def _increment_extend_generation_count(self, count: 'int' = 1) -> 'int':
        pass

    def _apply_extend_session_route_config(self, session: 'dict[str, Any] | None') -> 'None':
        pass

    def _ensure_extend_session_key(self) -> 'str':
        pass

    def _ensure_extend_session(self) -> 'dict[str, Any]':
        pass

    def _load_active_extend_session(self, *, defer_refresh: 'bool' = False) -> 'None':
        pass

    def _save_extend_session_cards(self, allow_empty: 'bool' = False) -> 'None':
        pass

    def _refresh_extend_sessions(self) -> 'None':
        pass

    @property
    def _settings(self):
        pass

    @property
    def _master_options(self):
        pass

    @property
    def _normal(self):
        pass

    @property
    def _extend(self):
        pass

    @property
    def _clone(self):
        pass

    @property
    def _transcript(self):
        pass

    @property
    def _batch(self):
        pass

    @property
    def _affiliate(self):
        pass

    @property
    def _job_store(self):
        pass

    @property
    def _session_service(self):
        pass

    @property
    def _media_library(self):
        pass

    @property
    def _product_library(self):
        pass

    @property
    def _asset_generation(self):
        pass

    @property
    def _reupscale(self):
        pass

    @property
    def _render(self):
        pass

    @property
    def _route(self):
        pass

    @property
    def _cards_by_route(self):
        pass

    @property
    def _normal_feature_cards(self):
        pass

    @property
    def _route_configs(self):
        pass

    @property
    def _queue_rows(self):
        pass

    @property
    def _job_panel_rows(self):
        pass

    @property
    def _stats(self):
        pass

    @property
    def _media_items(self):
        pass

    @property
    def _media_stats(self):
        pass

    @property
    def _media_settings(self):
        pass

    @property
    def _product_items(self):
        pass

    @property
    def _product_stats(self):
        pass

    @property
    def _batch_cards_view_cache(self):
        pass

    @property
    def _normal_cards_view_cache(self):
        pass

    @property
    def _characters(self):
        pass

    @property
    def _selected_characters_by_route(self):
        pass

    @property
    def _hidden_characters_by_route(self):
        pass

    @property
    def _selected_clone_voices_by_route(self):
        pass

    @property
    def _selected_clone_library_assets_by_route(self):
        pass

    @property
    def _asset_preview(self):
        pass

    @property
    def _transcript_link_busy(self):
        pass

    @property
    def _transcript_link_status(self):
        pass

    @property
    def _transcript_pipeline_busy(self):
        pass

    @property
    def _transcript_pipeline_status(self):
        pass

    @property
    def _transcript_input_mode(self):
        pass

    @property
    def _transcript_links_fetching(self):
        pass

    @property
    def _transcript_links_fetch_count(self):
        pass

    @property
    def _transcript_ai_generating(self):
        pass

    @property
    def _transcript_ai_style_snapshot(self):
        pass

    @property
    def _transcript_job_id_filter(self):
        pass

    @property
    def _transcript_queue_tracking_active(self):
        pass

    @property
    def _transcript_auto_merge_service_connected(self):
        pass

    @property
    def _extend_session_key(self):
        pass

    @property
    def _extend_cards_by_session(self):
        pass

    @property
    def _extend_sessions(self):
        pass

    @property
    def _extend_session_state(self):
        pass

    @property
    def _last_extend_running_batch_id(self):
        pass

    @property
    def _last_extend_auto_loaded_batch_id(self):
        pass

    @property
    def _extend_queue_autoprocessing(self):
        pass

    @property
    def _clone_upload_busy(self):
        pass

    @property
    def _clone_auto_merge_service_connected(self):
        pass

    @property
    def _clone_auth_pause_required(self):
        pass

    @property
    def _clone_no_live_accounts_pause_required(self):
        pass

    @property
    def _clone_terminal_pause_code(self):
        pass

    @property
    def _clone_terminal_pause_detail(self):
        pass

    @property
    def _clone_job_id_filter(self):
        pass

    @property
    def _last_clone_completion_signature(self):
        pass

    @property
    def _last_clone_auto_next_signature(self):
        pass

    @property
    def _effective_route_config_cache(self):
        pass

    @property
    def _clone_voice_cap_cache(self):
        pass

    @property
    def _clone_flow_voice_options_cache(self):
        pass

    @property
    def _clone_master_overlay_cache(self):
        pass

    @property
    def _runtime_feedback_connected(self):
        pass

    @property
    def _ai_analysis_worker(self):
        pass


# --- Class: RuntimeOptions ---
class RuntimeOptions:
    """RuntimeOptions(route: 'str' = 'home', width: 'int' = 900, height: 'int' = 560)"""
    route = 'home'
    width = 900
    height = 560

    def __init__(self, route: 'str' = 'home', width: 'int' = 900, height: 'int' = 560) -> None:
        pass

    def __repr__(self):
        pass


# --- Top-Level Functions ---
def _apply_default_font(app: 'QGuiApplication') -> 'None':
    # [PyArmor BCC constants]: 'QFont', 'exactMatch', 'Arial', 'setHintingPreference', 'HintingPreference', 'PreferFullHinting', 'setFont'
    pass

def configure_stdio() -> 'None':
    # [PyArmor BCC constants]: 'getattr', 'sys', 'hasattr', 'reconfigure', 'encoding', 'utf-8', 'errors', 'replace', 'Exception'
    pass

def parse_runtime_options(argv: 'list[str]') -> 'tuple[RuntimeOptions, list[str]]':
    # [PyArmor BCC constants]: 'home', 900, 560, 0, 'veoflow-qml', 1, 'len', '--route', 2, '--width', 'int', 'ValueError', '--height', 'append', 'RuntimeOptions'
    pass

def build_engine(initial_route: 'str' = 'home') -> 'tuple[QQmlApplicationEngine, dict[str, object]]':
    # [PyArmor BCC constants]: 'configure_stdio', 'configure_qt_runtime_env', 'QQmlApplicationEngine', 'addImportPath', 'str', 'QML_ROOT', 'install_qml_image_provider', 'QtQml', 'JobPanelPageProxy', 'cast', 'Any', 'qmlRegisterType', 'VeoFlow', 1, 0
    pass

def reset_startup_workspace_state() -> 'None':
    # [PyArmor BCC constants]: 'get_json_settings_manager', 'set_setting', 'master_workspace', 'idea_text', '', 'script_text', 'extra_requirements_text', 'normal_panel', 'workspace_cards', '_NORMAL_FEATURES', '_normal_feature_settings_key', 'print', 'Warning: failed to clear per-feature normal cards: ', 'Exception', 'app_shell'
    pass

def _wire_cross_controller_actions(controllers: 'dict[str, object]') -> 'None':
    # [PyArmor BCC constants]: 'get', 'statusController', 'getattr', 'attachStatusController', 'callable', 'timemachineController', 'automationCenterHost', 'automationProjectionCommitted', 'refresh', 'connect', 'appController', 'homeController', 'featureStatesChanged', 'headerController', 'masterOptionsController'
    pass

def shutdown_qml_runtime(qthread_timeout_ms: 'int' = 3000, force_exit_after_seconds: 'float' = 12.0) -> 'dict[str, object]':
    # [PyArmor BCC constants]: 'begin_process_shutdown', 'dict', 'close_aistudio_fork_runtime', 'timeout', 3.0, 'aistudio_forks_closed', 'type', '__name__', 'aistudio_fork_cleanup_error', 'Exception', 'deauthorize_and_clear_runtime_packs', 'bool', 'state', 'revoked', 'feature_packs_cleared'
    pass

def main(argv: 'list[str] | None' = None, pre_exec_hook: 'PreExecHook | None' = None) -> 'int':
    # [PyArmor BCC constants]: 'list', 'sys', 'argv', 'parse_runtime_options', 'configure_stdio', 'configure_qt_runtime_env', 'reset_startup_workspace_state', 'QGuiApplication', 'instance', 'cast', 'setQuitOnLastWindowClosed', True, 'os', 'environ', 'get'
    pass
