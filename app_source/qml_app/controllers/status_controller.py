"""
Decompiled / Reconstructed Module: qml_app.controllers.status_controller

Docstring:
Application status bar controller for QML.

This mirrors the legacy MainWindow status bar without importing PyQt widgets.
The controller exposes QML-ready snapshots for token usage, job monitoring,
failed jobs, and the system log panel.
"""

from __future__ import annotations
import sys, os, typing
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)

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

