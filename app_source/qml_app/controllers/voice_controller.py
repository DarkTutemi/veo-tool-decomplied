"""
Decompiled / Reconstructed Module: qml_app.controllers.voice_controller

Docstring:
Voice Studio controller — thin Qt adapter.

All config logic → services/tabs/voice_studio/voice_studio_service.py
All TTS state    → services/shared/voice/voice_api.py (via application/voice_service)
This file only translates between Qt signals/slots and the two services above.
"""

from __future__ import annotations
import sys, os, typing
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
_SPEAKER_KEYS = ('name', 'voice', 'audio_profile', 'style', 'pace', 'accent')

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


# --- Class: OmniProfileFilterModel ---
class OmniProfileFilterModel(QSortFilterProxyModel):
    """Filter a DictListModel without copying it back into a QVariantList."""
    staticMetaObject = PySide6.QtCore.QMetaObject("OmniProfileFilterModel" inherits "QSortFilterProxyModel":
Methods:
  #101 type=Slot, signatu...

    def __init__(self, parent: 'Any' = None) -> 'None':
        pass

    def setFilter(self, query: 'str', mode: 'str', selected_id: 'str') -> 'None':
        # [PyArmor BCC constants]: 'str', '', 'strip', 'casefold', 'lower', 'selected', '_query', '_selection_only', '_selected_id', 'getattr', 'beginFilterChange', 'endFilterChange', 'QtCore', 'QSortFilterProxyModel', 'Direction'
        pass

    def filterAcceptsRow(self, source_row: 'int', source_parent: 'QtCore.QModelIndex') -> 'bool':
        # [PyArmor BCC constants]: 'name', 'label', 'kind', 'quality', 'language'
        pass


# --- Class: JobPanelListModel ---
class JobPanelListModel(QAbstractListModel):
    """Expose lightweight job-panel rows to QML as stable roles."""
    RowRole = 257
    _ROLE_BY_NAME = {'row': 257, 'jobId': 258, 'sequenceNumber': 259, 'route': 260, 'kind': 261, 'title': 262, 'subtitle': 263, 'status': 26...
    _NAME_BY_ROLE = {257: 'row', 258: 'jobId', 259: 'sequenceNumber', 260: 'route', 261: 'kind', 262: 'title', 263: 'subtitle', 264: 'status...
    _ALL_ROLES = [257, 258, 259, 260, 261, 262, 263, 264, 265, 266, 267, 268, 269, 270, 271, 272, 273, 274, 275, 276, 277, 278, 279, 280,...
    _RUNTIME_ROLES = [264, 265, 266, 267, 263, 288]
    _NON_ASSET_ROLES = [257, 258, 259, 260, 261, 262, 263, 264, 265, 266, 267, 268, 269, 272, 273, 274, 275, 276, 277, 278, 279, 280, 281, 282,...
    _RESULT_ROLES = [258, 259, 260, 261, 262, 263, 264, 265, 266, 267, 268, 269, 272, 273, 274, 275, 276, 277, 278, 279, 280, 281, 282, 283,...
    _VALID_KINDS = {'R2V', 'IMG', 'T2V', 'EXT', 'I2V'}
    staticMetaObject = PySide6.QtCore.QMetaObject("JobPanelListModel" inherits "QAbstractListModel":
Methods:
  #76 type=Signal, signature=stat...

    statusesPatched = Signal()
    pageRefreshRequested = Signal()
    def _roles_for_change(self, changed: 'set[str]') -> 'list[int]':
        # [PyArmor BCC constants]: '_RUNTIME_ONLY_KEYS', '_RUNTIME_ROLES', '_INPUT_ASSET_KEYS', '_ALL_ROLES', '_RESULT_ONLY_KEYS', '_RESULT_ROLES', '_NON_ASSET_ROLES'
        pass

    def __init__(self, parent: 'QtCore.QObject | None' = None) -> 'None':
        pass

    def set_hot_window(self, start: 'int', end: 'int') -> 'None':
        pass

    def clear_hot_window(self) -> 'None':
        pass

    def is_on_page(self, job_id: 'str') -> 'bool':
        # [PyArmor BCC constants]: '_hot_end', 0, True, '_id_to_row', 'get', 'str', '', '_hot_start'
        pass

    def begin_batch(self) -> 'None':
        # [PyArmor BCC constants]: True, '_batch_mode', 1, '_batch_lo', '_batch_hi', '_batch_roles_set', 'clear'
        pass

    def end_batch(self) -> 'None':
        # [PyArmor BCC constants]: '_batch_mode', False, '_batch_lo', 0, '_batch_hi', '_batch_roles_set', 'list', '_ALL_ROLES', 'dataChanged', 'emit', 'index', 1, 'clear'
        pass

    def patch_fields_silent(self, job_id: 'str', updates: 'dict') -> 'None':
        # [PyArmor BCC constants]: '_id_to_row', 'get', 'str', '', 0, 'len', '_rows', 'items', '_role_memo', 'pop'
        pass

    def request_page_refresh(self) -> 'None':
        pass

    def rowCount(self, parent: 'QtCore.QModelIndex' = <PySide6.QtCore.QModelIndex(-1,-1,0x0,QObject(0x0)) at 0x000001DFC1CC9880>) -> 'int':
        # [PyArmor BCC constants]: 'isValid', 0, 'len', '_rows'
        pass

    def data(self, index: 'QtCore.QModelIndex', role: 'int' = 0) -> 'Any':
        # [PyArmor BCC constants]: 'isValid', 'int', 'row', 0, 'len', '_rows', '_NAME_BY_ROLE', 'get', '_role_value'
        pass

    def roleNames(self) -> "dict[int, __assert_armored__((QtCore, b'\\x81\\xb4\\xb9\\x0cH\\xb4\\xdfT\\xa5(\\xb4'))]":
        # [PyArmor BCC constants]: '_ROLE_BY_NAME', 'items', 'QtCore', 'QByteArray', 'encode', 'utf-8'
        pass

    def set_rows(self, rows: 'list[dict[str, Any]]') -> 'None':
        # [PyArmor BCC constants]: 'warn_if_off_gui', 'JobPanelListModel.set_rows', '_crumb', 'jobmodel', 'set_rows(reset)', 'n', 'len', '_role_memo', 'clear', 'beginResetModel', 'list', 'isinstance', 'dict', '_rows', '_rebuild_index'
        pass

    def apply_rows(self, rows: 'list[dict[str, Any]]') -> 'None':
        # [PyArmor BCC constants]: 'warn_if_off_gui', 'JobPanelListModel.apply_rows', 'list', 'isinstance', 'dict', '_rows', '_job_id', 'set_rows', 0, 'enumerate', '_changed_keys', '_invalidate_memo', '_roles_for_change', 'index', 'dataChanged'
        pass

    @staticmethod
    def _changed_keys(prev: 'dict[str, Any]', nxt: 'dict[str, Any]') -> 'set[str]':
        pass

    def upsert_row(self, row: 'dict[str, Any]') -> 'None':
        # [PyArmor BCC constants]: 'isinstance', 'dict', 'warn_if_off_gui', 'JobPanelListModel.upsert_row', '_job_id', '_id_to_row', 'get', 0, 'len', '_rows', '_changed_keys', '_invalidate_memo', '_roles_for_change', '_hot_end', '_hot_start'
        pass

    def remove_job(self, job_id: 'str') -> 'bool':
        # [PyArmor BCC constants]: '_id_to_row', 'get', 'str', '', 0, 'len', '_rows', False, '_role_memo', 'pop', 'beginRemoveRows', 'QtCore', 'QModelIndex', '_rebuild_index', 'endRemoveRows'
        pass

    def rows(self) -> 'list[dict[str, Any]]':
        pass

    def qml_rows(self) -> 'list[dict[str, Any]]':
        # [PyArmor BCC constants]: 'enumerate', '_rows', '_cached_role', '_job_id', 'row'
        pass

    def raw_rows(self) -> 'list[dict[str, Any]]':
        pass

    def row_by_id(self, job_id: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_id_to_row', 'get', 'str', '', 0, 'len', '_rows', 'dict'
        pass

    def _rebuild_index(self) -> 'None':
        # [PyArmor BCC constants]: '_id_to_row', 'enumerate', '_rows', '_job_id'
        pass

    def _role_value(self, row: 'dict[str, Any]', row_index: 'int', role_name: 'str') -> 'Any':
        # [PyArmor BCC constants]: 'row', '_cached_role', '_job_id', 'jobId', 'sequenceNumber', 'int', 'get', 'sequence_number', 1, 'route', '_text', 'tab_source', 'feature', 'kind', '_kind'
        pass

    def assetSlotsForJob(self, job_id: 'str') -> 'list[dict[str, Any]]':
        # [PyArmor BCC constants]: 'str', '', 'strip', '_rows', '_job_id', '_cached_role', 'assetSlots', 'list'
        pass

    def reviewPayloadAt(self, row_index: 'int') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'int', 0, 'len', '_rows', 'jobId', 'title', 'prompt', 'thumbnailUrl', 'videoPath', 'outputPath', 'kind', 'status', 'reviewStatus', 'reviewGen', 'canEdit'
        pass

    def _review_status(self, row: 'dict[str, Any]') -> 'str':
        # [PyArmor BCC constants]: '_text', 'get', 'review_status', 'lower', 'pass', 'unseen', 'flagged', '_meta', 'isinstance', 'review', 'dict', 'status', 'ok', 'good', 'passed'
        pass

    def _review_gen(self, row: 'dict[str, Any]') -> 'int':
        # [PyArmor BCC constants]: '_meta', 'get', 'review', 'review_gen', 'isinstance', 'dict', 'gen', 'max', 0, 'int', 'TypeError', 'ValueError'
        pass

    def _job_id(self, row: 'dict[str, Any]') -> 'str':
        # [PyArmor BCC constants]: '_text', 'get', 'id', 'row_id', 'job_id', 'batch_id'
        pass

    def _cached_role(self, job_id: 'str', role_name: 'str', builder) -> 'Any':
        pass

    def _invalidate_memo(self, job_id: 'str', changed: 'set[str]') -> 'None':
        # [PyArmor BCC constants]: '_role_memo', 'get', '_INPUT_ASSET_KEYS', 'pop', 'assetSlots', 'assetPreviews', 'row'
        pass

    def _qml_row(self, row: 'dict[str, Any]', row_index: 'int') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_QML_ROW_KEYS', 'get', '_is_qml_scalar', '_job_id', 'setdefault', 'id', 'row_id', 'job_id', 'sequence_number', 'int', 'sequenceNumber', 1, '_text', 'route', 'tab_source'
        pass

    def _is_qml_scalar(self, value: 'Any') -> 'bool':
        # [PyArmor BCC constants]: True, 'isinstance', 'bool', 'int', 'float', 'str', '_looks_like_inline_blob', False
        pass

    def _looks_like_inline_blob(self, value: 'str') -> 'bool':
        pass

    def _display_text(self, value: 'Any') -> 'str':
        pass

    def _kind(self, row: 'dict[str, Any]') -> 'str':
        # [PyArmor BCC constants]: '_text', 'get', 'feature', 'type', 'tab_source', 'route', 'lower', 'card_type', 'job_type', 'upper', '_is_image_gen_row', 'image_upscale', 'IMG', 'extend', 'is_extend'
        pass

    def _transcript_has_refs(self, row: 'dict[str, Any]') -> 'bool':
        # [PyArmor BCC constants]: '_meta', '_text', 'get', 'dispatch_feature', 'lower', 'asset', 'clone', 'reference', '_multi_asset_items', True, 'config', 'source', 'isinstance', 'dict', 'selected_character_ids'
        pass

    def _title(self, row: 'dict[str, Any]') -> 'str':
        # [PyArmor BCC constants]: '_text', 'get', 'name', 'title', 'idea', 'prompt', 'text', '_job_id', 'Queue row'
        pass

    def _subtitle(self, row: 'dict[str, Any]') -> 'str':
        pass

    def _status_key(self, row: 'dict[str, Any]') -> 'str':
        # [PyArmor BCC constants]: '_text', 'get', 'status', 'state', 'status_label', 'pending', 'lower'
        pass

    def _progress(self, row: 'dict[str, Any]') -> 'int':
        # [PyArmor BCC constants]: 'max', 0, 'min', 100, '_int', 'get', 'job_progress', 'progress'
        pass

    def _is_batch_image_row(self, row: 'dict[str, Any]') -> 'bool':
        # [PyArmor BCC constants]: 'batch_image', 'image_generation', 'transcript_image', 'clone_image', 'image_upscale'
        pass

    def _status_text(self, row: 'dict[str, Any]') -> 'str':
        # [PyArmor BCC constants]: '_status_key', '_text', 'get', 'status_label', 'status', 'lower', 'complete', 'done', 'Completed', 'fail', 'error', 'cancel', 'Failed', 'upscal', 'Upscaling'
        pass

    def _status_chip_text(self, row: 'dict[str, Any]') -> 'str':
        # [PyArmor BCC constants]: '_progress', '%', '_is_batch_image_row', '_status_key', 'upscal', 'Upscale ', 'generat', 'process', 'poll', 'Gen ', 'complete', 'done', 'Done ', 'fail', 'error'
        pass

    def _thumbnail_placeholder(self, row: 'dict[str, Any]') -> 'str':
        # [PyArmor BCC constants]: '_status_key', 'bool', '_thumbnail_url', '_is_batch_image_row', 'complete', 'done', 'FINALIZING PREVIEW', '', 'generat', 'process', 'upscal', 'GENERATING...', '_video_path', 'VIDEO READY', 'UPSCALING...'
        pass

    def _meta(self, row: 'dict[str, Any]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'isinstance', 'get', 'meta', 'dict'
        pass

    def _result_data(self, row: 'dict[str, Any]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_meta', 'isinstance', 'get', 'result_data', 'dict', 'result'
        pass

    def _images(self, row: 'dict[str, Any]') -> 'list[Any]':
        # [PyArmor BCC constants]: '_meta', '_result_data', 'get', 'images', 'generated_images', 'isinstance', 'list'
        pass

    def _primary_image(self, row: 'dict[str, Any]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_images', 'isinstance', 0, 'dict'
        pass

    def _first_value(self, row: 'dict[str, Any]', keys: 'list[str]') -> 'str':
        # [PyArmor BCC constants]: '_primary_image', '_result_data', '_meta', 'isinstance', 'dict', 'get', '_text', ''
        pass

    def _thumbnail_url(self, row: 'dict[str, Any]') -> 'str':
        # [PyArmor BCC constants]: 'thumbnail_url', 'thumbnail_path', 'thumb_path', 'thumbnail', 'preview_image', 'preview_path', 'image_path', 'get', '_text', '_primary_image', 'path', 'file_path', 'local_path', 'fife_url', '_first_value'
        pass

    def _asset_previews(self, row: 'dict[str, Any]') -> 'list[dict[str, Any]]':
        # [PyArmor BCC constants]: '_asset_sources', 'isinstance', 'list', 'max', 7, '_max_refs', 'enumerate', '_asset_display_payload', 'setdefault', 'slot_index', 'append'
        pass

    def _multi_asset_items(self, row: 'dict[str, Any]') -> 'list[Any]':
        # [PyArmor BCC constants]: '_meta', 'get', 'multi_asset_info', 'isinstance', 'dict', 'assets', 'list'
        pass

    def _asset_sources(self, row: 'dict[str, Any]') -> 'list[Any]':
        # [PyArmor BCC constants]: '_meta', '_multi_asset_items', 'get', 'assets', 'reference_previews', 'input_asset_items', 'input_assets', 'start_images', 'reference_images', 'reference_paths', 'asset_paths', 'reference_image_ids', 'reference_ids', 'refs', 'isinstance'
        pass

    def _asset_preview_source(self, asset: 'Any') -> 'str':
        # [PyArmor BCC constants]: 'isinstance', 'str', '_display_text', 'dict', '', 'get'
        pass

    def _asset_path(self, asset: 'Any') -> 'str':
        # [PyArmor BCC constants]: 'isinstance', 'str', '_display_text', 'dict', '', 'get'
        pass

    def _asset_media_id(self, asset: 'Any') -> 'str':
        # [PyArmor BCC constants]: 'isinstance', 'dict', '', '_display_text', 'get'
        pass

    def _asset_label(self, asset: 'Any', index: 'int') -> 'str':
        # [PyArmor BCC constants]: 'isinstance', 'str', 'replace', '\\', '/', 'split', 1, 'A', 4, 'upper', 'dict', '_text', 'get', 'name', 'strip'
        pass

    def _asset_slot_type(self, asset: 'Any') -> 'str':
        # [PyArmor BCC constants]: 'isinstance', 'dict', '_text', 'get', 'asset_type', 'type', 'kind', 'lower', 'character', 'object'
        pass

    def _asset_display_payload(self, asset: 'Any', index: 'int') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'isinstance', 'str', '_display_text', 'dict', '_DISPLAY_ASSET_KEYS', 'get', '_is_qml_scalar', '_asset_preview_source', '_asset_path', '_asset_media_id', '_asset_label', '_asset_slot_type', 'path', 'previewSrc', 'preview_src'
        pass

    def _asset_slots(self, row: 'dict[str, Any]') -> 'list[dict[str, Any]]':
        # [PyArmor BCC constants]: 'slotType', 'slotIndex', 'asset', 'filled', 'previewSrc', 'path', 'mediaId', 'label', 'entityLocked'
        pass

    def _is_image_gen_row(self, row: 'dict[str, Any]') -> 'bool':
        # [PyArmor BCC constants]: '_text', 'get', 'feature', 'type', 'tab_source', 'route', 'mode_key', 'lower', 'isinstance', 'meta', 'dict', 'dispatch_feature', 'upscale', False, 'image_generation'
        pass

    def _max_refs(self, row: 'dict[str, Any]', assets: 'list[Any]') -> 'int':
        # [PyArmor BCC constants]: 'isinstance', 'get', 'config', 'dict', '_text', 'feature', 'type', 'tab_source', 'route', 'lower', 'voice', 'audio', 0, '_is_image_gen_row', 10
        pass

    def _aspect_ratio(self, row: 'dict[str, Any]') -> 'str':
        # [PyArmor BCC constants]: 'isinstance', 'get', 'meta', 'dict', '_text', 'aspect_ratio', 'aspect', 'output_aspect_ratio'
        pass

    def _video_path(self, row: 'dict[str, Any]') -> 'str':
        # [PyArmor BCC constants]: 'isinstance', 'get', 'meta', 'dict', 'result_data', '_text', 'upscaled_path', 'video_path', 'merged_output_path', 'merged_video_path', 'output_path'
        pass

    def _media_id(self, row: 'dict[str, Any]') -> 'str':
        # [PyArmor BCC constants]: '_is_batch_image_row', '_source_media_name', '_source_media_id', '_primary_image', 'get', 'imported_media_id', '_text', 'media_id', 'mediaId', '_first_value', 'video_media_id', 'veo_media_id', 'google_media_id'
        pass

    def _source_media_id(self, row: 'dict[str, Any]') -> 'str':
        # [PyArmor BCC constants]: '_first_value', 'source_media_id', 'veo_media_id', 'mediaId', 'google_media_id'
        pass

    def _source_media_name(self, row: 'dict[str, Any]') -> 'str':
        # [PyArmor BCC constants]: '_first_value', 'mediaName', 'media_name', 'veo_media_name', 'google_media_name', 'upscale_media_id'
        pass

    def _current_resolution(self, row: 'dict[str, Any]') -> 'str':
        # [PyArmor BCC constants]: '_first_value', 'upscale_resolution', 'resolution', 'target_resolution', 'quality'
        pass

    def _output_path(self, row: 'dict[str, Any]') -> 'str':
        # [PyArmor BCC constants]: '_first_value', 'image_path', 'file_path', 'path', 'thumbnail_path', 'thumbnail_url', 'output_path', 'video_path'
        pass

    def _output_folder(self, row: 'dict[str, Any]') -> 'str':
        # [PyArmor BCC constants]: '_first_value', 'output_folder', 'download_folder', 'folder'
        pass

    def _tier_mode(self, row: 'dict[str, Any]') -> 'str':
        # [PyArmor BCC constants]: '_first_value', 'tier_mode', 'account_tier_mode', 'ultra', 'lower'
        pass

    def _optional_bool(self, row: 'dict[str, Any]', keys: 'list[str]') -> 'bool | None':
        pass

    def _text(self, value: 'Any') -> 'str':
        pass

    def _int(self, value: 'Any', default: 'int' = 0) -> 'int':
        pass


# --- Class: _VoiceWorker ---
class _VoiceWorker(QThread):
    staticMetaObject = PySide6.QtCore.QMetaObject("_VoiceWorker" inherits "QThread":
Methods:
  #12 type=Signal, signature=resultReady(QString,...

    resultReady = Signal()
    def __init__(self, service: 'Any', action: 'str', payload: 'dict[str, Any]') -> 'None':
        pass

    def run(self) -> 'None':
        # [PyArmor BCC constants]: '_action', 'generate_single', '_service', 'generate_audio', '_payload', 'apply_narration_selection', 'get_voice_api', 'str', 'get', 'provider', 'gemini', 'dict', 'config', 'preview_narration_selection', 'preview_narration'
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


# --- Top-Level Functions ---
def _t(v: 'Any') -> 'str':
    pass

def _coerce_rows(payload: 'dict[str, Any]', key: 'str') -> 'list[dict[str, Any]]':
    pass

def _flag_for_language(value: 'Any') -> 'str':
    # [PyArmor BCC constants]: 'vi', 'vn', 'en', 'us', 'uk', 'gb', 'zh', 'cn', 'ja', 'jp', 'ko', 'kr', 'es', 'fr', 'de'
    pass

def _voice_option(item: 'Any', provider: 'str') -> 'dict[str, str]':
    # [PyArmor BCC constants]: 'label', 'value', 'flag', 'secondary'
    pass

def _speaker_row(raw: 'Any', index: 'int') -> 'dict[str, str]':
    # [PyArmor BCC constants]: 'isinstance', 'dict', '_SPEAKER_KEYS', '_t', 'get', 'name', 'Speaker ', 1, 'voice', 0, 'Kore', 'Puck'
    pass

def _speakers_from_json(raw: 'Any') -> 'list[dict[str, str]]':
    # [PyArmor BCC constants]: 'isinstance', 'str', 'strip', 'loads', 'Exception', 'list', 'tuple', '_speaker_row', 0, 'enumerate', 2
    pass

def _speakers_to_json(raw: 'Any') -> 'str':
    # [PyArmor BCC constants]: 'isinstance', 'str', 'list', 'tuple', '', 'enumerate', 2, '_speaker_row', 'dumps', 'ensure_ascii', False
    pass

def _model_option(item: 'Any') -> 'dict[str, str]':
    # [PyArmor BCC constants]: 'isinstance', 'dict', 'label', 'value', '_t', 'get', 'name', 'id'
    pass

def _audio_job_panel_row(row: 'dict[str, Any]') -> 'dict[str, Any]':
    # [PyArmor BCC constants]: 'dict', '_t', 'get', 'id', 'row_id', 'batch_id', 'job_id', 'status', 'state', 'pending', 'lower', 'generated', 'complete', 'audio_path', 'saved_audio_path'
    pass

def _result_message(result: 'dict[str, Any]', fallback: 'str') -> 'str':
    # [PyArmor BCC constants]: 'get', 'message', '_t', 'ok', 'path', 'isinstance', 'blocker', 'dict', 'error'
    pass
