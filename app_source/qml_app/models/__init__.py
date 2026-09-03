"""
Decompiled / Reconstructed Module: qml_app.models.__init__

Docstring:
QML-facing Python models.
"""

from __future__ import annotations
import sys, os, typing
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['JobPanelListModel', 'JobPanelPageProxy', 'PromptCardListModel', 'QueueListModel', 'HistoryRunListModel', 'HistoryItemListModel', 'sync_job_panel_rows', 'TimeMachineGridModel', 'TimeMachineChapterModel', 'TimeMachineMotionModel', 'TimeMachineStageModel', 'TimeMachineTimelineModel', 'TimeMachineViewModel']

# --- Module Constants & Globals ---
__all__ = ['JobPanelListModel', 'JobPanelPageProxy', 'PromptCardListModel', 'QueueListModel', 'HistoryRunListModel', 'HistoryItemListModel', 'sync_job_panel_rows', 'TimeMachineGridModel', 'TimeMachineChapterMod... [truncated]

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
    _VALID_KINDS = {'R2V', 'T2V', 'IMG', 'I2V', 'EXT'}
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

    def rowCount(self, parent: 'QtCore.QModelIndex' = <PySide6.QtCore.QModelIndex(-1,-1,0x0,QObject(0x0)) at 0x0000021AD007D480>) -> 'int':
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


# --- Class: JobPanelPageProxy ---
class JobPanelPageProxy(QAbstractListModel):
    staticMetaObject = PySide6.QtCore.QMetaObject("JobPanelPageProxy" inherits "QAbstractListModel":
Properties:
  #1 "sourceModel", QObject* [...

    pageChanged = Signal()
    sourceModelChanged = Signal()
    def __init__(self, parent: 'QtCore.QObject | None' = None) -> 'None':
        pass

    def _get_source(self):
        pass

    def setSourceModel(self, model) -> 'None':
        # [PyArmor BCC constants]: '_source', 'beginResetModel', '_source_connections', 'disconnect', 'Exception', '_status_role', 'connect', 0, '_active_page', '_rebuild_index', '_apply_follow_target', '_compute_count', '_count', '_sync_hot_window', 'endResetModel'
        pass

    def _source_connections(self, model):
        # [PyArmor BCC constants]: 'dataChanged', '_on_source_data_changed', 'rowsInserted', '_on_source_count_changed', 'rowsRemoved', 'layoutChanged', 'modelReset', '_on_source_reset', 'hasattr', 'statusesPatched', '_on_statuses_patched'
        pass

    def sourceModel(*args, **kwargs):
        pass

    def rowCount(self, parent=<PySide6.QtCore.QModelIndex(-1,-1,0x0,QObject(0x0)) at 0x0000021ACFFCB5C0>) -> 'int':
        # [PyArmor BCC constants]: 'isValid', '_source', 0, '_count'
        pass

    def data(self, index: 'QtCore.QModelIndex', role: 'int' = 0):
        # [PyArmor BCC constants]: '_source', 'isValid', 'row', 0, '_count', '_source_row_for_slot', 'index', 'data'
        pass

    def roleNames(self):
        pass

    def _offset(self) -> 'int':
        pass

    def _source_total(self) -> 'int':
        # [PyArmor BCC constants]: '_filter', 'len', '_index', '_source', 'int', 'rowCount', 0
        pass

    def _source_row_for_slot(self, slot: 'int') -> 'int':
        # [PyArmor BCC constants]: '_offset', 'int', '_filter', 0, 'len', '_index', 1, '_source', 'rowCount'
        pass

    def _row_status(self, src_row: 'int') -> 'str':
        # [PyArmor BCC constants]: '_source', '_status_role_id', 0, '', 'str', 'data', 'index', 'strip', 'lower'
        pass

    def _rebuild_index(self) -> 'None':
        # [PyArmor BCC constants]: '_filter', '_source', '_index', 'failed', '_FAILED', 'range', 'int', 'rowCount', '_row_status', 'append'
        pass

    def _compute_count(self, page: 'int') -> 'int':
        # [PyArmor BCC constants]: '_source_total', '_page_size', 0, 'max', 'min'
        pass

    def _relayout(self, new_page: 'int', new_following: 'bool') -> 'None':
        # [PyArmor BCC constants]: '_active_page', '_count', '_compute_count', 'beginInsertRows', 'QtCore', 'QModelIndex', 1, '_following', 'endInsertRows', 'beginRemoveRows', 'endRemoveRows', '_sync_hot_window', '_source', 'hasattr', 'request_page_refresh'
        pass

    def _sync_hot_window(self, page: 'int', count: 'int') -> 'None':
        # [PyArmor BCC constants]: '_source', 'hasattr', 'set_hot_window', '_page_size', 0, 'clear_hot_window', '_filter', '_index', 'min', 'max', 1
        pass

    def _on_source_data_changed(self, top_left, bottom_right, roles=None) -> 'None':
        # [PyArmor BCC constants]: '_refreshing_page', '_filter', 'list', '_index', '_rebuild_index', '_relayout', '_clamped_page', False, '_offset', '_count', 'range', 'int', 'row', 1, 'index'
        pass

    def _on_source_count_changed(self, *args) -> 'None':
        # [PyArmor BCC constants]: '_filter', '_rebuild_index', '_clamped_page', '_following', '_live_page', '_relayout'
        pass

    def _on_source_reset(self, *args) -> 'None':
        # [PyArmor BCC constants]: 'beginResetModel', '_rebuild_index', '_clamped_page', '_active_page', '_apply_follow_target', '_compute_count', '_count', '_sync_hot_window', 'endResetModel', 'pageChanged', 'emit'
        pass

    def _status_role_id(self):
        # [PyArmor BCC constants]: '_status_role', '_source', 'roleNames', 'items', 'bytes', 'decode', 'utf-8', 'ignore', 'status', 'int'
        pass

    def _first_active_source_row(self) -> 'int':
        # [PyArmor BCC constants]: '_source', '_status_role_id', 1, 'range', 'rowCount', 'str', 'data', 'index', 0, '', 'strip', 'lower', '_TERMINAL'
        pass

    def _live_page(self):
        # [PyArmor BCC constants]: '_page_size', 0, '_first_active_source_row', 'pageCount', 'max', 'min', 1
        pass

    def _apply_follow_target(self) -> 'None':
        # [PyArmor BCC constants]: '_following', '_live_page', '_active_page'
        pass

    def following(*args, **kwargs):
        pass

    def livePage(*args, **kwargs):
        pass

    def goLive(self) -> 'None':
        # [PyArmor BCC constants]: '_live_page', '_relayout', '_active_page', True
        pass

    def statusFilter(*args, **kwargs):
        pass

    def pageSize(*args, **kwargs):
        pass

    def activePage(*args, **kwargs):
        pass

    def setActivePage(self, p: 'int') -> 'None':
        pass

    def nextPage(self) -> 'None':
        pass

    def prevPage(self) -> 'None':
        pass

    def totalCount(*args, **kwargs):
        pass

    def pageCount(*args, **kwargs):
        pass

    def _user_goto(self, p: 'int') -> 'None':
        # [PyArmor BCC constants]: '_relayout', 'max', 0, 'min', 'int', 'pageCount', 1, False
        pass

    def _clamped_page(self) -> 'int':
        # [PyArmor BCC constants]: 'max', 0, 'min', '_active_page', 'pageCount', 1
        pass

    def _on_statuses_patched(self) -> 'None':
        # [PyArmor BCC constants]: '_following', '_live_page', '_active_page', '_relayout', True
        pass


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

    def rowCount(self, parent: 'QtCore.QModelIndex' = <PySide6.QtCore.QModelIndex(-1,-1,0x0,QObject(0x0)) at 0x0000021AD008E040>) -> 'int':
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


# --- Class: HistoryItemListModel ---
class HistoryItemListModel(DictListModel):
    staticMetaObject = PySide6.QtCore.QMetaObject("HistoryItemListModel" inherits "DictListModel":
)


# --- Class: HistoryRunListModel ---
class HistoryRunListModel(DictListModel):
    staticMetaObject = PySide6.QtCore.QMetaObject("HistoryRunListModel" inherits "DictListModel":
)

    def appendRows(self, rows: 'Any') -> 'None':
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

