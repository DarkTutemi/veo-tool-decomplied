"""
Decompiled / Reconstructed Module: qml_app.models.job_panel_list_model

Docstring:
Shared QAbstractListModel projection for Job Panel rows.
"""

from __future__ import annotations
import sys, os, typing
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
_JOB_PANEL_ROLE_NAMES = ('row', 'jobId', 'sequenceNumber', 'route', 'kind', 'title', 'subtitle', 'status', 'statusText', 'statusChipText', 'progress', 'thumbnailUrl', 'thumbnailPlaceholder', 'assetPreviews', 'assetSlots', 'a... [truncated]
_QML_ROW_KEYS = frozenset({'title', 'generation_time_seconds', 'upscale_resolution', 'message', 'downloaded_video_path', 'type', 'resolution', 'output_folder', 'media_name', 'upscaled_path', 'thumbnail_path', 'mode_k... [truncated]
_DISPLAY_ASSET_KEYS = frozenset({'path', 'google_media_id', 'veo_media_id', 'type', 'media_id', 'slot_index', 'label', 'image_path', 'thumbnail_path', 'id', 'previewSrc', 'kind', 'thumbnail_url', 'thumbnail_file_url', 'blo... [truncated]
_BASE_ROLE = 257
_ROLE_BY_NAME = {'row': 257, 'jobId': 258, 'sequenceNumber': 259, 'route': 260, 'kind': 261, 'title': 262, 'subtitle': 263, 'status': 264, 'statusText': 265, 'statusChipText': 266, 'progress': 267, 'thumbnailUrl': 26... [truncated]
_NAME_BY_ROLE = {257: 'row', 258: 'jobId', 259: 'sequenceNumber', 260: 'route', 261: 'kind', 262: 'title', 263: 'subtitle', 264: 'status', 265: 'statusText', 266: 'statusChipText', 267: 'progress', 268: 'thumbnailUrl... [truncated]
_RUNTIME_ONLY_KEYS = frozenset({'updated_at', 'dispatcher_summary', 'message', 'polling_heartbeat_at', 'step_status', 'status_message', 'job_progress', 'meta', 'charcore_status', 'progress_message', 'clone_image_stage', '... [truncated]
_RUNTIME_ROLE_NAMES = ('status', 'statusText', 'statusChipText', 'progress', 'subtitle', 'updatedAt')
_INPUT_ASSET_KEYS = frozenset({'start_images', 'reference_images', 'refs', 'input_assets', 'reference_paths', 'input_asset_items', 'feature', 'asset_paths', 'assets', 'reference_ids', 'max_image_inputs', 'reference_previ... [truncated]
_ASSET_ROLE_NAMES = frozenset({'assetPreviews', 'assetSlots'})
_RESULT_ONLY_KEYS = frozenset({'status', 'generation_time_seconds', 'veo_media_id', 'downloaded_video_path', 'upscaled_path', 'thumbnail_path', 'can_delete', 'merged_video_path', 'thumbnail_url', 'thumb_path', 'generatio... [truncated]

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


# --- Top-Level Functions ---
def sync_job_panel_rows(model: 'Any', rows: 'list[dict[str, Any]]', *, force_reset: 'bool' = False) -> 'str':
    # [PyArmor BCC constants]: 'set_rows', 'reset', 'int', 'rowCount', 0, 'Exception', 'apply_rows', 'apply'
    pass
