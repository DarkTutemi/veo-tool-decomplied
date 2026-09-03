"""
Decompiled / Reconstructed Module: qml_app.controllers.header_controller

Docstring:
QML controller for the shared application header.
"""

from __future__ import annotations
import sys, os, typing
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)

# --- Class: _HeaderActionWorker ---
class _HeaderActionWorker(QThread):
    staticMetaObject = PySide6.QtCore.QMetaObject("_HeaderActionWorker" inherits "QThread":
Methods:
  #12 type=Signal, signature=finishedPaylo...

    finishedPayload = Signal()
    progressUpdated = Signal()
    def __init__(self, action: 'str', value: 'str', store_data: 'dict[str, Any]') -> 'None':
        pass

    def run(self) -> 'None':
        # [PyArmor BCC constants]: 'get_header_service', 'execute_action', '_action', '_value', '_store_data', 'progress_callback', '_emit_progress', 'ok', 'action', 'error', 'data', False, 'str', 'type', '__name__'
        pass

    def _emit_progress(self, percent: 'int', status: 'str', indeterminate: 'bool' = False) -> 'None':
        # [PyArmor BCC constants]: 'progressUpdated', 'emit', 'int', 'str', '', 'bool'
        pass


# --- Class: _PaymentInfoPollWorker ---
class _PaymentInfoPollWorker(QThread):
    staticMetaObject = PySide6.QtCore.QMetaObject("_PaymentInfoPollWorker" inherits "QThread":
Methods:
  #12 type=Signal, signature=finishedPa...

    finishedPayload = Signal()
    def __init__(self, order_code: 'str', store_data: 'dict[str, Any]') -> 'None':
        pass

    def run(self) -> 'None':
        # [PyArmor BCC constants]: 'get_header_service', 'execute_action', 'commerce_payment_info', '_order_code', '_store_data', 'ok', 'action', 'error', 'data', False, 'str', 'type', '__name__', 'exception_type', 'Exception'
        pass


# --- Class: _BalancePollWorker ---
class _BalancePollWorker(QThread):
    """Fetch the live wallet balance from the gateway off the UI thread."""
    staticMetaObject = PySide6.QtCore.QMetaObject("_BalancePollWorker" inherits "QThread":
Methods:
  #12 type=Signal, signature=finishedPayloa...

    finishedPayload = Signal()
    def run(self) -> 'None':
        # [PyArmor BCC constants]: 'get_ai_provider', 'auto', 'get_credit_balance', 'Exception', 'get_license_manager', 'hasattr', 'get_credit_usage_dashboard', 'timeout', 10, 'isinstance', 'dict', '_usage_dashboard', 'str', 'type', '__name__'
        pass


# --- Class: _EntitlementRefreshWorker ---
class _EntitlementRefreshWorker(QThread):
    """Re-verify the license after a completed payment, off the GUI thread."""
    staticMetaObject = PySide6.QtCore.QMetaObject("_EntitlementRefreshWorker" inherits "QThread":
Methods:
  #12 type=Signal, signature=finishe...

    finishedPayload = Signal()
    def __init__(self, feature_code: 'str') -> 'None':
        pass

    def run(self) -> 'None':
        # [PyArmor BCC constants]: 'get_license_manager', 'refresh_features', 'timeout', 15, 'dict', '_feature_code', 'getattr', 'feature_gate', 'lower', 'resolve_feature_ui', 'feature_code', 'bool', 'get', 'enabled', 'feature_active'
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


# --- Top-Level Functions ---
def should_chain_download_after_check(flow: 'str') -> 'bool':
    pass

def should_suppress_update_dialog(*, silent_update: 'bool', action: 'str', ok: 'bool', update_available: 'bool') -> 'bool':
    pass
