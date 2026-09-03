"""
Decompiled / Reconstructed Module: qml_app.controllers.master_controller

Docstring:
Master prompt controller for QML.
"""

from __future__ import annotations
import sys, os, typing
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)

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


# --- Top-Level Functions ---
def _try_get_auto_merge_service() -> 'tuple[Any | None, str | None]':
    # [PyArmor BCC constants]: 'get_auto_merge_service', 'unsupported: auto merge service is not available on import: ', 'Exception', 'unsupported: auto merge service is not available: '
    pass
