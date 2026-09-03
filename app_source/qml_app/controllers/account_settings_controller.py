"""
Decompiled / Reconstructed Module: qml_app.controllers.account_settings_controller

Docstring:
QML controller for Account & Settings.

This controller exposes the existing non-UI services/managers to QML. It does
not import legacy PyQt widgets.
"""

from __future__ import annotations
import sys, os, typing
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Callable = typing.Callable
logger = <Logger qml_app.controllers.account_settings_controller (WARNING)>
_AI_MODE_UI_KEYS = ('aistudio', 'server', 'personal')

# --- Class: DictListModel ---
class DictListModel(QAbstractListModel):
    _ROLE = 257
    staticMetaObject = PySide6.QtCore.QMetaObject("DictListModel" inherits "QAbstractListModel":
Methods:
  #76 type=Slot, signature=setRows(QV...

    def __init__(self, parent: 'Any' = None) -> 'None':
        pass

    def roleNames(self):
        pass

    def rowCount(self, parent=<PySide6.QtCore.QModelIndex(-1,-1,0x0,QObject(0x0)) at 0x000001DFC1CE90C0>) -> 'int':
        # [PyArmor BCC constants]: 'isValid', 0, 'len', '_rows'
        pass

    def data(self, index, role=0):
        # [PyArmor BCC constants]: 'isValid', 0, 'row', 'len', '_rows'
        pass

    def setRows(self, rows: 'Any') -> 'None':
        # [PyArmor BCC constants]: 'isinstance', 'dict', '_rows', 'len', 'beginInsertRows', 'QtCore', 'QModelIndex', 1, 'endInsertRows', 'beginRemoveRows', 'endRemoveRows', 0, 'dataChanged', 'emit', 'index'
        pass

    def rows(self) -> 'list[dict]':
        pass


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


# --- Top-Level Functions ---
def _merge_health_row(rows: 'list[dict[str, Any]]', incoming: 'dict[str, Any]') -> 'list[dict[str, Any]]':
    # [PyArmor BCC constants]: 'str', 'get', 'id', '', False, 'append', 'busy', 'bool', True, 'dict'
    pass

def _enum_value(value: 'Any', default: 'str' = '') -> 'str':
    pass

def _relative_time(value: 'Any') -> 'str':
    # [PyArmor BCC constants]: 'float', 0, '', 'TypeError', 'ValueError', 'max', 'time', 60, 'now', 3600, 'int', 'm', 86400, 'h', 'd'
    pass

def _safe_int(value: 'Any') -> 'int':
    # [PyArmor BCC constants]: 'int', 'float', 0, 'TypeError', 'ValueError'
    pass

def _expired_accounts_message(accounts: 'list[str]') -> 'str':
    # [PyArmor BCC constants]: 'str', '', 'strip', ', ', 'join', 5, 'len', 'tr', 'account.and_more', 'count', 'account.need_relogin_list', 'list'
    pass
