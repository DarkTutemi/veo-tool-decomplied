"""
Decompiled / Reconstructed Module: qml_app.controllers.work_panel_controller

Docstring:
Reusable QML controller for work-panel style tabs.
"""

from __future__ import annotations
import sys, os, typing
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
MAX_AFFILIATE_VARIANTS_PER_PRODUCT = 5
SUPPORTED_VOICE_LANGUAGES = [('none', 'No voice', 'global'), ('vi', 'Tiếng Việt', 'vn'), ('en', 'English', 'us'), ('zh', '中文', 'cn'), ('ja', '日本語', 'jp'), ('ko', '한국어', 'kr'), ('es', 'Español', 'es'), ('fr', 'Français', 'fr'), (... [truncated]
IMAGE_RHYTHM_CONFIG_KEYS = frozenset({'image_rhythm_template_id', 'image_pacing', 'image_target_count', 'image_rhythm_version', 'image_rhythm_mode', 'image_count_mode', 'image_rhythm_target'})
DEFAULT_MULTI_ASSET_REFERENCE_LIMIT = 3
MAX_MULTI_ASSET_CHARACTER_REFERENCE_LIMIT = 3
MAX_MULTI_ASSET_REFERENCE_LIMIT = 7
ROUTE_META = {'normal': {'route': 'normal', 'title': 'Normal Panel', 'titleKey': 'qml.work.normal_title', 'subtitle': 'Single-scene text/image/video prompt cards with service-backed submit.', 'subtitleKey': 'qml.w... [truncated]
LOCAL_FILE_EXTENSIONS = {'transcript_audio': {'.ogg', '.m4a', '.wav', '.mp3'}, 'clone_video': {'.avi', '.mov', '.mp4', '.mkv', '.wmv', '.mpeg', '.webm', '.flv', '.3gpp', '.mpg'}, 'batch_reference_image': {'.jpeg', '.webp', '... [truncated]
TRANSCRIPT_SUBTITLE_EXTENSIONS = {'.srt', '.vtt'}
_NORMAL_ROUTE_DEFAULTS = {'allow_headless_execution': True, 'dry_run': False, 'auto_merge': False, 'feature_type': 'text', 'mode': 'text_16_9', 'clip_duration_seconds': 8, 'output_count': 1}
_NORMAL_ROUTE_SETTINGS_KEY = 'normal_panel'
_CLONE_ROUTE_DEFAULTS = {'mode': 'url', 'aspect_ratio': '16:9', 'quality': '720p', 'resolution': '720p', 'enable_upscale': False, 'model_key': '', 'video_model_key': '', 'market': 'global', 'target_market': 'global', 'output... [truncated]
_CLONE_ROUTE_SETTINGS_KEY = 'clone_video'
_EXTEND_ROUTE_DEFAULTS = {'aspect_ratio': '16:9', 'quality': '720p', 'resolution': '720p', 'enable_upscale': False, 'clip_duration_seconds': 8, 'model_key': '', 'video_model_key': '', 'target_market': 'global', 'output_folder... [truncated]
_EXTEND_ROUTE_SETTINGS_KEY = 'extend_panel'
_NORMAL_FEATURES = ('text', 'image', 'interpolation', 'multi_asset')
_TRANSCRIPT_ROUTE_DEFAULTS = {'mode': 'audio', 'output_mode': 'video', 'image_rhythm_version': 1, 'image_rhythm_mode': 'auto', 'image_rhythm_target': 6, 'image_pacing': 'auto', 'image_count_mode': 'auto', 'image_target_count': 6,... [truncated]
_TRANSCRIPT_ROUTE_SETTINGS_KEY = 'transcript_video'
_BATCH_ROUTE_DEFAULTS = {'allow_headless_execution': True, 'dry_run': False, 'variations': 10, 'anti_duplicate': True, 'instructions': '', 'character_strategy': 'inherit', 'variation_strength': 'balanced', 'save_to_library':... [truncated]
_BATCH_ROUTE_SETTINGS_KEY = 'batch_image'
_WORK_PANEL_PERF_VERBOSE = False
_WORK_PANEL_PERF_SLOW_MS = 80.0
_THUMB_CACHE_LOG_ON = False
_JOB_PROJECTION_CACHE_MAX = 8192
_JOB_PANEL_LIVE_REFRESH_DEBOUNCE_MS = 500
_ROUTE_CONFIG_FLUSH_DEBOUNCE_MS = 80
_MEDIA_LIBRARY_PROGRESSIVE_THRESHOLD = 12
_MEDIA_LIBRARY_PROGRESSIVE_CHUNK_SIZE = 12
_MEDIA_LIBRARY_PROGRESSIVE_DELAY_MS = 12
MAX_AFFILIATE_ACTIVE_PRODUCTS = 50
_HEAVY_ROW_KEYS = ('base64', 'thumbnail_base64', 'image_base64', 'thumbnail_data', 'image_data', 'preview')
_HEAVY_RECURSE_KEYS = ('meta', 'result_data', 'result', 'images', 'assets', 'reference_previews', 'preview')
_LOCAL_FILE_METADATA_WORKERS = 4
_LOCAL_FILE_METADATA_BATCH_SIZE = 12
_WP_BRIDGED_SLOTS = ('_settings', '_master_options', '_normal', '_extend', '_clone', '_transcript', '_batch', '_affiliate', '_job_store', '_session_service', '_media_library', '_product_library', '_asset_generation', '_r... [truncated]

# --- Class: PromptCardListModel ---
class PromptCardListModel(QAbstractListModel):
    """
    Expose prompt cards to QML without copying a QVariantList on every bind.
    
        ARCHITECTURE NOTE:
        Batch workspaces should bind to this model for large prompt-card lists.
        The legacy ``cards`` QVariantList remains for small/old surfaces only; using
        it for 500-1000 batch cards forces large Python->QML list copies.
    """
    CardDataRole = 257
    _ALL_ROLES = [257, 258, 259, 260, 261, 262, 263, 264, 265, 266]
    staticMetaObject = PySide6.QtCore.QMetaObject("PromptCardListModel" inherits "QAbstractListModel":
Properties:
  #1 "count", int [designabl...

    countChanged = Signal()
    def __init__(self, parent: 'QtCore.QObject | None' = None) -> 'None':
        pass

    @staticmethod
    def _card_id(card: 'Any') -> 'str':
        # [PyArmor BCC constants]: 'isinstance', 'dict', '', 'str', 'get', 'id', 'row_id', 'batch_id', 'strip'
        pass

    def _rebuild_index(self) -> 'None':
        # [PyArmor BCC constants]: 'enumerate', '_cards', '_card_id', '_id_to_row'
        pass

    def rowCount(self, parent: 'QtCore.QModelIndex' = <PySide6.QtCore.QModelIndex(-1,-1,0x0,QObject(0x0)) at 0x000001DFC08DED80>) -> 'int':
        # [PyArmor BCC constants]: 'isValid', 0, 'len', '_cards'
        pass

    def count(*args, **kwargs):
        pass

    def data(self, index: 'QtCore.QModelIndex', role: 'int' = 0) -> 'Any':
        # [PyArmor BCC constants]: 'isValid', 'int', 'row', 0, 'len', '_cards', '_NAME_BY_ROLE', 'get', 'cardData', 'cardId', 'str', 'id', 'row_id', 'batch_id', ''
        pass

    def roleNames(self) -> "dict[int, __assert_armored__((QtCore, b'\\x81\\xb4\\xb9\\x0cH\\xb4\\xdfT\\xa5(\\xb4'))]":
        # [PyArmor BCC constants]: '_ROLE_BY_NAME', 'items', 'QtCore', 'QByteArray', 'encode', 'utf-8'
        pass

    def set_cards(self, cards: 'list[dict[str, Any]]') -> 'None':
        # [PyArmor BCC constants]: 'warn_if_off_gui', 'PromptCardListModel.set_cards', 'list', 'isinstance', 'dict', 'len', '_cards', '_crumb', 'cardmodel', 'set_cards(reset)', 'n', 'prev', 'beginResetModel', '_rebuild_index', 'endResetModel'
        pass

    def apply_rows(self, cards: 'list[dict[str, Any]]') -> 'None':
        # [PyArmor BCC constants]: 'warn_if_off_gui', 'PromptCardListModel.apply_rows', 'list', 'isinstance', 'dict', '_cards', '_card_id', 'enumerate', 'index', 0, 'dataChanged', 'emit', '_ALL_ROLES', 'len', 'range'
        pass

    def upsert_row(self, card: 'dict[str, Any]') -> 'None':
        # [PyArmor BCC constants]: 'isinstance', 'dict', 'warn_if_off_gui', 'PromptCardListModel.upsert_row', '_card_id', '_id_to_row', 'get', 0, 'len', '_cards', 'index', 'dataChanged', 'emit', '_ALL_ROLES', 'beginInsertRows'
        pass

    def remove_card(self, card_id: 'str') -> 'bool':
        # [PyArmor BCC constants]: '_id_to_row', 'get', 'str', '', 'strip', 0, 'len', '_cards', False, 'beginRemoveRows', 'QtCore', 'QModelIndex', '_rebuild_index', 'endRemoveRows', 'countChanged'
        pass

    def cards(self) -> 'list[dict[str, Any]]':
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

    def rowCount(self, parent: 'QtCore.QModelIndex' = <PySide6.QtCore.QModelIndex(-1,-1,0x0,QObject(0x0)) at 0x000001DFC1CCFF00>) -> 'int':
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


# --- Class: EmbeddedAISourceAnalysisWorker ---
class EmbeddedAISourceAnalysisWorker(QThread):
    staticMetaObject = PySide6.QtCore.QMetaObject("EmbeddedAISourceAnalysisWorker" inherits "QThread":
Methods:
  #12 type=Signal, signature=re...

    resultReady = Signal()
    error = Signal()
    def __init__(self, idea: 'str', image_b64: 'str' = '', mime_type: 'str' = 'image/png') -> 'None':
        pass

    def run(self) -> 'None':
        # [PyArmor BCC constants]: 'get_ai_provider', 'auto', 'feature', 'extend_video', 'RuntimeError', 'No AI provider available', 'Analyze this reference for an extend-video planning workflow. Return JSON only with keys: subject, material, environment, camera, style, process_type, risks, opportunities. Be concise. Infer what kind of transformation/timelapse/process video this could become. User idea: ', 'idea', '(none)', 'image_b64', 'generate_with_media', 'parts', 'base64_data', 'mime_type', 'light'
        pass


# --- Class: WorkPanelControllerExtendAiMixin ---
class WorkPanelControllerExtendAiMixin:
    def _extend_idea_rows(self, session_key: 'str') -> 'list[dict[str, Any]]':
        # [PyArmor BCC constants]: '_extend_idea_rows_by_session', 'setdefault', 'str', ''
        pass

    def _publish_extend_idea_rows(self, session_key: 'str | None' = None) -> 'None':
        # [PyArmor BCC constants]: 'str', '_extend_session_key', '', '_extend_idea_model', 'apply_rows', '_extend_idea_rows', 'dict'
        pass

    def _discard_extend_idea_workspace(self, session_key: 'str') -> 'None':
        # [PyArmor BCC constants]: 'str', '', '_extend_idea_rows_by_session', 'pop', '_extend_idea_plan_pending', 'get', 'session_key', 'clear', 'extend', '_extend_active_idea_plan', 'isinstance', 'dict', True, 'cancelled'
        pass

    def _update_extend_idea_row(self, session_key: 'str', idea_id: 'str', patch: 'dict[str, Any]') -> 'None':
        # [PyArmor BCC constants]: '_extend_idea_rows', 'enumerate', 'str', 'get', 'id', '', 'dict', 'update', '_publish_extend_idea_rows'
        pass

    def _sync_extend_idea_rows_from_batches(self, session_key: 'str', batch_rows: 'list[dict[str, Any]]') -> 'None':
        # [PyArmor BCC constants]: 'status_key', 'status_label', 'progress', 'scene_count', 'batch_ids', 'output_folder'
        pass

    def _queue_extend_idea(self, idea: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'media_id', 'id', 'path', 'source_path', 'thumbnail_url'
        pass

    def _start_next_extend_idea_plan(self) -> 'None':
        # [PyArmor BCC constants]: '_extend_idea_plan_worker', 'isRunning', '_extend_idea_plan_pending', 'popleft', '_extend_active_idea_plan', 'EmbeddedAITimelineWorker', 'dict', 'get', 'kwargs', 'resultReady', 'connect', '_on_extend_idea_plan_finished', 'error', '_on_extend_idea_plan_error', 'finished'
        pass

    def _on_extend_idea_plan_finished(self, result: 'dict[str, Any]') -> 'None':
        # [PyArmor BCC constants]: '_apply_extend_idea_plan_result', 'dict', '_extend_active_idea_plan', '_update_extend_idea_row', 'str', 'get', 'session_key', '', 'id', 'status_key', 'status_label', 'error_message', 'failed', 'Không thể tạo job', 'type'
        pass

    def _apply_extend_idea_plan_result(self, result: 'dict[str, Any]') -> 'None':
        # [PyArmor BCC constants]: 'dict', '_extend_active_idea_plan', 'get', 'cancelled', 'str', 'session_key', '', 'id', '_extend_uc', '_build_extend_generated_payload', 'list', 'items', '_update_extend_idea_row', 'status_key', 'failed'
        pass

    def _on_extend_idea_plan_error(self, error: 'str') -> 'None':
        # [PyArmor BCC constants]: 'dict', '_extend_active_idea_plan', 'get', 'cancelled', '_update_extend_idea_row', 'str', 'session_key', '', 'id', 'status_key', 'status_label', 'error_message', 'failed', 'AI tạo prompt lỗi', 'Unknown error'
        pass

    def _release_extend_idea_plan_worker(self) -> 'None':
        # [PyArmor BCC constants]: 'sender', '_extend_idea_plan_worker', '_extend_active_idea_plan', 'deleteLater', 'QTimer', 'singleShot', 0, '_start_next_extend_idea_plan'
        pass

    def _ai_director_apply_selected(self, selected_index: 'int') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_extend_generated_scene', 'ok', False, 'action', 'work_panel.extend_apply_selected', 'code', 'extend_generated_selection_missing', 'message', 'Select a generated extend beat before applying it to the session.', '_state', 'set_status', 'importExtendItems', '_extend_generated_scene_to_item', 0, 'setdefault'
        pass

    def _ai_director_regenerate_selected(self, selected_index: 'int', idea: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_extend_generated_timeline', 'ok', False, 'action', 'work_panel.extend_regenerate_selected', 'code', 'extend_generated_timeline_missing', 'message', 'Generate an extend timeline before regenerating a beat.', '_state', 'set_status', 0, 'len', 'extend_generated_selection_missing', 'Select exactly one generated extend beat before regenerating it.'
        pass

    def _ai_director_on_analysis_finished(self, data: 'dict[str, Any]') -> 'None':
        # [PyArmor BCC constants]: 'subject', 'material', 'environment', 'camera', 'style', 'process_type', 'risks', 'opportunities'
        pass

    def _ai_director_on_analysis_error(self, error: 'str') -> 'None':
        # [PyArmor BCC constants]: '_route_configs', 'setdefault', 'extend', 'Source analysis failed: ', 'str', '', 'strip', 'Unknown error', 'extend_source_analysis_status', '_emit_route_config_changed', '_persist_extend_ai_state', '_state', 'set_status', '_extend_pending_generate_idea'
        pass

    def _ai_director_generate_timeline(self, idea: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_route', 'extend', 'ok', False, 'action', 'work_panel.extend_generate_timeline', 'code', 'extend_route_required', 'message', 'Generate Timeline is only available on the extend route.', '_state', 'set_action_result', 'set_status', 'getattr', '_ai_timeline_worker'
        pass

    def _ai_director_release_timeline_worker(self) -> 'None':
        # [PyArmor BCC constants]: 'sender', '_ai_timeline_worker', 'deleteLater'
        pass

    def _ai_director_release_analysis_worker(self) -> 'None':
        # [PyArmor BCC constants]: 'sender', '_ai_analysis_worker', 'deleteLater'
        pass

    def _ai_director_on_timeline_finished(self, result: 'dict[str, Any]') -> 'None':
        # [PyArmor BCC constants]: '_extend_uc', '_apply_extend_generated', 'dict', 'print', '[ExtendStash] _apply_extend_generated FAILED: ', 'type', '__name__', ': ', 'flush', True, 'print_exc', '_state', 'set_status', 'Extend timeline apply failed: ', 'Exception'
        pass

    def _ai_director_on_timeline_error(self, error: 'str') -> 'None':
        # [PyArmor BCC constants]: '_route_configs', 'setdefault', 'extend', '', 'extend_generated_status', '_emit_route_config_changed', '_state', 'set_status', 'Extend timeline generation failed: ', 'str', 'strip', 'Unknown error'
        pass

    def _ai_director_analyze_source(self, idea: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_route', 'extend', 'ok', False, 'blocked', 'action', 'work_panel.extend_analyze_source', 'error', 'extend_route_required', 'code', 'message', 'Analyze Source is only available on extend route.', '_state', 'set_action_result', 'set_status'
        pass

    def _ai_director_analyze_then_generate(self, idea: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'getattr', '_ai_analysis_worker', 'isRunning', 'str', '', '_extend_pending_generate_idea', 'ok', True, 'action', 'work_panel.extend_analyze_source', 'message', 'Source analysis already running; prompts will be created when ready.', '_ai_director_analyze_source', 'isinstance', 'dict'
        pass

    def _ai_director_update_root_asset_slots(self) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'media_id', 'id', 'path', 'source_path', 'thumbnail_url'
        pass

    def _ai_director_select_root_asset(self, index: 'int', selection: 'dict[str, Any] | None' = None) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'media_id', 'path', 'source_path', 'thumbnail_url'
        pass

    def _ai_director_clear_root_assets(self) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_route_configs', 'setdefault', 'extend', 'range', '_MAX_EXTEND_ROOT_ASSETS', 'extend_root_assets', '_ai_director_update_root_asset_slots', 'ok', 'action', 'message', True, 'work_panel.extend_root_assets_clear', 'list', 'get', 'assets'
        pass

    def _ai_director_use_current_root_source(self) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_route', 'extend', 'ok', False, 'action', 'work_panel.extend_root_assets_use_current', 'error', 'extend_route_required', 'message', 'Use Current ROOT is only available on extend route.', '_state', 'set_status', '_cards_by_route', 'get', 'isinstance'
        pass


# --- Class: WorkPanelController ---
class WorkPanelController(QObject, WorkPanelControllerExtendAiMixin):
    """Thin QML adapter shared by Normal/Extend/Clone/Transcript/Batch routes."""
    _ROUTE_TAB_SOURCES = {'normal': 'normal_panel', 'extend': 'extend_panel', 'clone': 'clone_video', 'transcript': 'transcript_video', 'batch': ...
    _QUEUE_PUSH_ROUTES = ('clone', 'transcript', 'normal', 'extend', 'batch', 'affiliate')
    _CARD_ROUTES = ('clone', 'transcript')
    _clone_angle_suggestions = ()
    _clone_angle_suggestions_busy = False
    _ROUTE_OPTION_INT_KEYS = {'clip_duration_seconds', 'output_count', 'duration'}
    _CLONE_FETCH_RETRY_DELAYS = (2.0, 5.0, 10.0)
    _AFF_IMAGE_EXTS = {'.webp', '.png', '.jpeg', '.bmp', '.jpg'}
    is_demo = False
    tier = "PREMIUM"

    def has_feature(self, code: str = 'clone') -> bool:
        return True

    def is_demo_mode(self) -> bool:
        return False
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


# --- Top-Level Functions ---
def _projection_cache_lookup(cache: 'dict[str, Any]', key: 'str', signature: 'Any') -> 'Any':
    # [PyArmor BCC constants]: 'get', 0, 'getattr', 'move_to_end', 'callable'
    pass

def _projection_cache_store(cache: 'dict[str, Any]', key: 'str', value: 'Any') -> 'None':
    # [PyArmor BCC constants]: 'getattr', 'move_to_end', 'callable', 'len', '_JOB_PROJECTION_CACHE_MAX', 'popitem', 'isinstance', 'OrderedDict', 'last', False, 'pop', 'next', 'iter'
    pass

def _timed_step(steps: 'list[tuple[str, float]]', label: 'str', func):
    # [PyArmor BCC constants]: 'time', 'perf_counter', 'append', 1000
    pass

def _log_work_panel_perf(label: 'str', route: 'str', total_ms: 'float', steps: 'list[tuple[str, float]]', *, force: 'bool' = False) -> 'None':
    pass

def _affiliate_variant_focus_target(rows: 'list[dict[str, Any]]', current: 'str' = '', *, user_pinned: 'bool' = False) -> 'str':
    """
    Choose the variant whose scene jobs should be projected in Job Panel.
    
        An automatic focus follows active production.  A user click pins the chosen
        variant so inspecting completed/failed output is not interrupted by another
        row starting in the background.  If that row disappears, focus returns to
        automatic mode at the controller boundary.
    """
    # [PyArmor BCC constants]: 'row', 'dict[str, Any]', 'return', 'str'
    pass

def _affiliate_failure_ui_state(error: 'Any', durable_state: 'Any' = '') -> 'tuple[str, str]':
    """
    Map a durable Affiliate failure to the stage the user can act on.
    
        Call-1/Call-2/package/queue are different gates.  Labelling all of them
        "queue error" made a rejected campaign look like a stuck queue even though
        no queue row existed.
    """
    # [PyArmor BCC constants]: 'affiliate_scene_contract_invalid', 'call-2', 'campaign_missing_variants', 'strategy_profile_invalid', 'json', 'scene plan'
    pass

def _strip_heavy_inplace(obj: 'Any', _depth: 'int' = 0) -> 'Any':
    # [PyArmor BCC constants]: 6, 'isinstance', 'dict', '_HEAVY_ROW_KEYS', 'pop', 'list', 'items', 'str', 'startswith', 'data:', 'len', 500, '', '_HEAVY_RECURSE_KEYS', '_strip_heavy_inplace'
    pass

def _probe_video_duration_with_binary(path: 'Path', ffprobe_path: 'str') -> 'int':
    # [PyArmor BCC constants]: 'str', '', 'strip', 0, 'run', '-v', 'error', '-show_entries', 'format=duration', '-of', 'default=noprint_wrappers=1:nokey=1', 'capture_output', True, 'text', 'encoding'
    pass

def _probe_video_duration(path: 'Path') -> 'int':
    # [PyArmor BCC constants]: 'get_ffmpeg_binary', '_probe_video_duration_with_binary', 'ffprobe', 0, 'Exception'
    pass

def _normalize_local_file_path(value: 'Any') -> 'str':
    # [PyArmor BCC constants]: 'str', '', 'strip', 'lower', 'startswith', 'file:', 'QUrl', 'toLocalFile', 'os', 'path', 'expandvars', 'expanduser', 'abspath', 'normpath'
    pass

def _local_file_path_key(value: 'Any') -> 'str':
    # [PyArmor BCC constants]: 'os', 'path', 'normcase', '_normalize_local_file_path'
    pass

def _pair_transcript_subtitles(cards: 'list[dict[str, Any]]', subtitle_paths: 'list[str]') -> 'tuple[int, list[str]]':
    # [PyArmor BCC constants]: 'isinstance', 'dict', 'str', 'get', 'source_type', '', 'transcript_audio', 'local_path', 'setdefault', 'Path', 'stem', 'casefold', 0, 'append', 'srt_path'
    pass

def _prepare_local_file_candidates(paths: 'list[Any]', kind: 'str' = '') -> 'list[str]':
    # [PyArmor BCC constants]: 'local_file_admission_extensions', 'str', '', 'strip', 'set', '_normalize_local_file_path', '_local_file_path_key', 'Path', 'suffix', 'lower', 'add', 'append'
    pass

def _probe_local_file_metadata_row(row: 'dict[str, Any]', kind: 'str', ffprobe_path: 'str') -> 'dict[str, Any]':
    # [PyArmor BCC constants]: 'Path', 'str', 'get', 'path', '', 'card_id', 'exists', 'file_size', 'duration_seconds', 'metadata_status', False, 0, 'missing', 'is_file', True
    pass

def _run_local_file_metadata_batch(batch_id: 'str', route_name: 'str', kind: 'str', rows: 'list[dict[str, Any]]', emit_payload: 'Any') -> 'None':
    # [PyArmor BCC constants]: 'time', 'perf_counter', 'len', 0, '', 'str', 'transcript_audio', 'clone_video', 'get_ffmpeg_binary', 'ffprobe', 'Exception', 'Queue', 'put', 'dict', True
    pass

def _stats_from_rows(rows: 'list[dict[str, Any]]') -> 'dict[str, int]':
    # [PyArmor BCC constants]: 'total', 'pending', 'queued', 'generating', 'completed', 'failed', 'paused'
    pass

def _credit_gate_model_selection(route: 'str', config: 'dict[str, Any]') -> 'tuple[str, str]':
    # [PyArmor BCC constants]: 'str', '', 'strip', 'lower', 'get', 'output_mode', 'auto', 'transcript', 'clone', 'image', 'image_model', 'ModelConfig', 'is_valid_image_model', 'get_default_image_model', 'video_model_key'
    pass

def _make_wp_state_bridge(_slot):
    # [PyArmor BCC constants]: 'getattr', '_state', 'setattr', '__name__', 'property'
    pass
