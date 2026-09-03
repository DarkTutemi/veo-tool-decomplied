"""
Decompiled / Reconstructed Module: qml_app.controllers.timemachine_controller

Docstring:
QML controller for the dedicated Time Machine tab.
"""

from __future__ import annotations
import sys, os, typing
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['TimeMachineController']

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Callable = typing.Callable
Dict = typing.Dict
Mapping = typing.Mapping
_TIMEMACHINE_REVIEW_GATE_OPEN = False
_TIMEMACHINE_FL_DURATION_SECONDS = 8
_TIMEMACHINE_SETTINGS_KEY = 'timemachine'
__all__ = ['TimeMachineController']

# --- Class: TimeMachineAutomationControllerBridge ---
class TimeMachineAutomationControllerBridge(QObject):
    """
    Claim on a worker, then apply the detached request on the GUI thread.
    
        The process-local producer receives only ``_push.emit``.  It never receives
        the controller callback and cannot call or mutate the controller QObject.
        Every SQLite operation runs through ``run_off_thread``.
    """
    staticMetaObject = PySide6.QtCore.QMetaObject("TimeMachineAutomationControllerBridge" inherits "QObject":
Methods:
  #4 type=Signal, signat...

    _push = Signal()
    _claimDone = Signal()
    _handoffDone = Signal()
    _projectionDone = Signal()
    projectionCommitted = Signal()
    def __init__(self, *, database_path: 'str | Path', accept_request: 'Callable[[dict[str, Any]], Mapping[str, Any]]', parent: 'QObject | None' = None) -> 'None':
        pass

    @property
    def consumer_token(self):
        pass

    def shutdown(self) -> 'None':
        # [PyArmor BCC constants]: '_closed', True, 'unregister_timemachine_consumer', '_database_path', '_consumer_token', '_pending_projection'
        pass

    def project(self, rows: 'Sequence[Mapping[str, Any]]') -> 'None':
        # [PyArmor BCC constants]: '_closed', 'dict', '_projection_inflight', 'begin', '_pending_projection', '_database_path', 'TimeMachineAutomationStore', 'update_projections', 'run_off_thread', '_projectionDone', 'name', 'TimeMachineAutomationProjection'
        pass

    def _schedule_claim(self) -> 'None':
        # [PyArmor BCC constants]: '_closed', '_claim_inflight', 'begin', True, '_claim_again', '_database_path', '_consumer_token', 'TimeMachineAutomationStore', 'claim_next', 'run_off_thread', '_claimDone', 'name', 'TimeMachineAutomationClaim'
        pass

    def _apply_claim(self, payload: 'Mapping[str, Any]') -> 'None':
        # [PyArmor BCC constants]: '_claim_inflight', 'done', '_closed', 'bool', 'get', 'ok', 'data', 'isinstance', 'Mapping', '_claim_again', False, '_schedule_claim', 'dict', 'str', 'target_run_id'
        pass

    def _write_handoff_result(self, target: 'str', accepted: 'Mapping[str, Any]') -> 'None':
        # [PyArmor BCC constants]: '_handoff_inflight', 'begin', True, '_claim_again', '_database_path', 'dict', 'TimeMachineAutomationStore', 'bool', 'get', 'ok', 'acknowledge', 'reject', 'str', 'code', 'TIMEMACHINE_HANDOFF_REJECTED'
        pass

    def _apply_handoff_result(self, payload: 'Mapping[str, Any]') -> 'None':
        # [PyArmor BCC constants]: '_handoff_inflight', 'done', '_closed', False, '_claim_again', '_schedule_claim'
        pass

    def _apply_projection_result(self, payload: 'Mapping[str, Any]') -> 'None':
        # [PyArmor BCC constants]: '_projection_inflight', 'done', '_closed', 'bool', 'get', 'ok', 'max', 0, 'int', 'data', 'TypeError', 'ValueError', 'projectionCommitted', 'emit', '_pending_projection'
        pass


# --- Class: QueueListModel ---
class QueueListModel(QAbstractListModel):
    """
    Incremental queue-row model. Same ``apply_rows`` diff contract as
        ``JobPanelListModel``: identical id-set → per-row ``dataChanged``; a different
        id-set (add/remove/reorder) → one ``beginResetModel`` reset.
    """
    _ROLE_BY_NAME = {'qrow': 257, 'rowId': 258}
    _NAME_BY_ROLE = {257: 'qrow', 258: 'rowId'}
    _ALL_ROLES = [257, 258]
    staticMetaObject = PySide6.QtCore.QMetaObject("QueueListModel" inherits "QAbstractListModel":
)

    def __init__(self, parent: 'QtCore.QObject | None' = None) -> 'None':
        pass

    def rowCount(self, parent: 'QtCore.QModelIndex' = <PySide6.QtCore.QModelIndex(-1,-1,0x0,QObject(0x0)) at 0x0000021AD008F800>) -> 'int':
        # [PyArmor BCC constants]: 'isValid', 0, 'len', '_rows'
        pass

    def data(self, index: 'QtCore.QModelIndex', role: 'int' = 0) -> 'Any':
        # [PyArmor BCC constants]: 'isValid', 'int', 'row', 0, 'len', '_rows', '_NAME_BY_ROLE', 'get', 'qrow', 'dict', 'rowId', '_row_id'
        pass

    def roleNames(self) -> "dict[int, __assert_armored__((QtCore, b'\\x81\\xb4\\xb9\\x0cH\\xb4\\xdfT\\xa5(\\xb4'))]":
        # [PyArmor BCC constants]: '_ROLE_BY_NAME', 'items', 'QtCore', 'QByteArray', 'encode', 'utf-8'
        pass

    def set_rows(self, rows: 'list[dict[str, Any]]') -> 'None':
        # [PyArmor BCC constants]: 'warn_if_off_gui', 'QueueListModel.set_rows', 'beginResetModel', 'list', 'isinstance', 'dict', '_rows', 'endResetModel'
        pass

    def apply_rows(self, rows: 'list[dict[str, Any]]') -> 'None':
        # [PyArmor BCC constants]: 'warn_if_off_gui', 'QueueListModel.apply_rows', 'list', 'isinstance', 'dict', '_rows', '_row_id', 'set_rows', 'enumerate', 'index', 0, 'dataChanged', 'emit', '_ALL_ROLES'
        pass

    def rows(self) -> 'list[dict[str, Any]]':
        pass


# --- Class: TimeMachineChapterModel ---
class TimeMachineChapterModel(_RoleListModel):
    ROLE_NAMES = ('rowIdx', 'viewId', 'label', 'storyOrder', 'contextFromPrevious', 'stageCount', 'clipCount', 'completedClipCount', 'gen...
    staticMetaObject = PySide6.QtCore.QMetaObject("TimeMachineChapterModel" inherits "_RoleListModel":
)

    def __init__(self, parent: 'QtCore.QObject | None' = None) -> 'None':
        pass

    def set_chapters(self, rows: 'Iterable[dict[str, Any]]') -> 'None':
        pass

    def update_cell(self, view_id: 'str', stage: 'int', patch: 'dict[str, Any]') -> 'bool':
        # [PyArmor BCC constants]: '_cells_by_view', 'get', 'str', False, 'enumerate', '_rows', 'int', 'stageIdx', 0, 'update_row'
        pass


# --- Class: TimeMachineGridModel ---
class TimeMachineGridModel(_RoleListModel):
    ROLE_NAMES = ('rowIdx', 'viewId', 'viewLabel', 'stageIdx', 'status', 'imagePath', 'locked', 'onTimeline', 'edgeToNext', 'seqBadge', '...
    staticMetaObject = PySide6.QtCore.QMetaObject("TimeMachineGridModel" inherits "_RoleListModel":
)

    def __init__(self, parent: 'QtCore.QObject | None' = None) -> 'None':
        pass

    def set_rows(self, rows: 'Iterable[dict[str, Any]]') -> 'None':
        pass

    def update_cell(self, view_id: 'str', stage: 'int', patch: 'dict[str, Any]') -> 'bool':
        # [PyArmor BCC constants]: '_cell_index', 'get', 'str', 'int', False, 'update_row'
        pass


# --- Class: TimeMachineMotionModel ---
class TimeMachineMotionModel(_RoleListModel):
    ROLE_NAMES = ('rowIdx', 'promptIdx', 'motionKey', 'viewId', 'viewLabel', 'fromStage', 'toStage', 'fromSeq', 'toSeq', 'editSeq', 'stat...
    staticMetaObject = PySide6.QtCore.QMetaObject("TimeMachineMotionModel" inherits "_RoleListModel":
)


# --- Class: TimeMachineStageModel ---
class TimeMachineStageModel(_RoleListModel):
    ROLE_NAMES = ('stageIdx', 'name', 'visibleDescription')
    staticMetaObject = PySide6.QtCore.QMetaObject("TimeMachineStageModel" inherits "_RoleListModel":
)


# --- Class: TimeMachineTimelineModel ---
class TimeMachineTimelineModel(_RoleListModel):
    ROLE_NAMES = ('seq', 'viewId', 'viewLabel', 'stageIdx', 'edgeToNext', 'badge')
    staticMetaObject = PySide6.QtCore.QMetaObject("TimeMachineTimelineModel" inherits "_RoleListModel":
)


# --- Class: TimeMachineViewModel ---
class TimeMachineViewModel(_RoleListModel):
    ROLE_NAMES = ('rowIdx', 'viewId', 'label', 'anchorPath')
    staticMetaObject = PySide6.QtCore.QMetaObject("TimeMachineViewModel" inherits "_RoleListModel":
)


# --- Class: _TimeMachineAccountUnavailable ---
class _TimeMachineAccountUnavailable(RuntimeError):
    """Recoverable account gate raised after a queued job already started."""
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


# --- Top-Level Functions ---
def _factual_timeline_locked(plan: 'Mapping[str, Any]') -> 'bool':
    # [PyArmor BCC constants]: 'get', 'fact_grounding', 'str', 'truth_policy', '', 'strip', 'knowledge_guided', 'historical_strict'
    pass

def _global_fixed_viewport(plan: 'Mapping[str, Any]') -> 'bool':
    # [PyArmor BCC constants]: 'dict', 'get', 'temporal_brief', 'world_anchor', 'str', 'camera_contract', '', 'strip', 'lower', 'global_fixed_viewport'
    pass

def _single_line_summary(value: 'Any', *, limit: 'int') -> 'str':
    # [PyArmor BCC constants]: ' ', 'join', 'str', '', 'split', 'len', 'max', 1, 'rstrip', 'rsplit', 0, '…'
    pass

def _live_chain_metric(*, parent_job_id: 'str', stage: 'str', from_seq: 'Any' = '', to_seq: 'Any' = '', elapsed_ms: 'Any' = '', **fields: 'Any') -> 'None':
    # [PyArmor BCC constants]: '[TimeMachine][LiveChainMetric]', 'parent=', 'str', '', 'stage=', 'append', 'from_seq=', 'to_seq=', 'elapsed_ms=', 'max', 0, 'int', 'float', 'items', 'replace'
    pass

def _timemachine_user_error(value: 'Any') -> 'str':
    """Keep provider diagnostics in logs while showing an actionable UI error."""
    # [PyArmor BCC constants]: 'media_id_expired', 'requested entity was not found', 'entity was not found', 'http 404'
    pass

def _timemachine_repairable_error(value: 'Any') -> 'bool':
    # [PyArmor BCC constants]: 'media_id_expired', 'requested entity was not found', 'http 404', 'recaptcha', 'unusual_activity', 'browser_api', 'storyarchitectureerror', 'story_architecture', 'story blueprint', 'timeline_interval_coverage', 'complete ledger'
    pass

def _active_view_projection(job: 'Mapping[str, Any]') -> 'tuple[str, int]':
    # [PyArmor BCC constants]: 'isinstance', 'get', 'plan', 'Mapping', 'grid', 'list', 'views', 'enumerate', 'str', 'view_id', '', 'active_view_id', 'strip', 'int', 'cells'
    pass

def _require_renderable_motion(result: 'Mapping[str, Any]') -> 'None':
    pass

def _freeze_tts_output_language(tts_snapshot: 'Dict[str, Any] | None', language: 'str') -> 'Dict[str, Any]':
    # [PyArmor BCC constants]: 'deepcopy', 'dict', 'str', 'vi', 'strip', 'lower', 'provider', 'preferred_provider', 'model', 'voice_id', 'output_language', 'provider_options', 'gemini', 'get', 'gemini-3.1-flash-tts-preview'
    pass

def _local_input_path(value: 'Any') -> 'str':
    # [PyArmor BCC constants]: 'str', '', 'strip', 'lower', 'startswith', 'file:///', 'unquote', 8, 'file://', 7, 'os', 'name', 'nt', 'replace', '/'
    pass

def _timemachine_license_blocker(action: 'str') -> 'Dict[str, Any] | None':
    # [PyArmor BCC constants]: '_TIMEMACHINE_REVIEW_GATE_OPEN', 'feature_blocker', 'time_machine'
    pass

def _account_identity(account: 'Dict[str, Any]') -> 'str':
    # [PyArmor BCC constants]: 'str', 'get', 'email', 'name', '', 'strip'
    pass

def _select_asset_owner_account(accounts: 'list[Dict[str, Any]]', preferred_identity: 'str' = '') -> 'Dict[str, Any]':
    # [PyArmor BCC constants]: 'list', 'dict', 'str', '', 'strip', 'get', 'email', 'name', 'RuntimeError', 'Asset-owner account của job không còn hoạt động; không tự chuyển account để tránh mất continuity/media ID.', '_TimeMachineAccountUnavailable', 'Time Machine cần ít nhất một account khả dụng để chuẩn bị ảnh.', 0
    pass

def _evidence_context_for_chapter(plan: 'Mapping[str, Any]', chapter: 'Mapping[str, Any]') -> 'Dict[str, Any]':
    # [PyArmor BCC constants]: 'dict', 'get', 'fact_grounding', 'list', 'events', 'str', 'event_id', '', 'deepcopy', 'evidence_event_ids', 'strip', 'evidence_boundary_event_id', 'fromkeys', 'visual_state_map', 'nodes'
    pass

def _available_fl_model_options(model_config: 'Any', tier_mode: 'str', max_credits: 'int | None') -> 'list[Dict[str, Any]]':
    # [PyArmor BCC constants]: 'set', 'ultra', 'advanced', 'intermediate', 'get_models_by_type', 'video_type', 'image_to_video', 'tier_mode', 'variant', 'fl', 'duration_seconds', '_TIMEMACHINE_FL_DURATION_SECONDS', 'str', 'get', 'key'
    pass
