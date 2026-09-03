"""
Decompiled / Reconstructed Module: qml_app.controllers.work_panel.extend_ai_mixin

Docstring:
WorkPanelController Extend AI-Director mixin (extracted from the god-controller).
Plain methods resolved via MRO on WorkPanelController; same `self`, same behaviour.
"""

from __future__ import annotations
import sys, os, typing
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
TYPE_CHECKING = False
_MAX_EXTEND_ROOT_ASSETS = 7

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


# --- Class: EmbeddedAITimelineWorker ---
class EmbeddedAITimelineWorker(QThread):
    """
    Runs the extend ROOT→EXTEND timeline AI generation OFF the GUI thread.
    
        ``generate_scenes`` is network-bound (5-60s); calling it on the GUI thread freezes the
        app (qml-patterns Law 1). ``resultReady(dict)`` carries the raw generate_scenes result
        (scenes + process_summary); the controller marshals it back to build cards + summary.
    """
    staticMetaObject = PySide6.QtCore.QMetaObject("EmbeddedAITimelineWorker" inherits "QThread":
Methods:
  #12 type=Signal, signature=resultRe...

    resultReady = Signal()
    error = Signal()
    def __init__(self, kwargs: 'dict') -> 'None':
        pass

    def run(self) -> 'None':
        # [PyArmor BCC constants]: 'get_extend_prompt_service', 'generate_scenes', '_kwargs', 'resultReady', 'emit', 'dict', 'error', 'type', '__name__', ': ', 'Exception'
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


# --- Top-Level Functions ---
def _extend_config_option_label(options: 'list[dict[str, Any]]', value: 'str') -> 'str':
    # [PyArmor BCC constants]: 'str', '', 'strip', 'dict', 'get', 'model_key', 'value', 'id', 'label', 'display_name', 'name'
    pass

def _extend_video_model_label(config: 'dict[str, Any]', model_key: 'str', *, options: 'list[dict[str, Any]] | None' = None) -> 'str':
    # [PyArmor BCC constants]: 'str', '', 'strip', '_extend_config_option_label', 'list', 'Tự động', 'ModelConfig', 'dict', 'get_model_info', 'get', 'display_name', 'tier_mode', 'account_tier', 'ultra', 'int'
    pass

def _extend_market_label(config: 'dict[str, Any]') -> 'str':
    # [PyArmor BCC constants]: 'str', 'get', 'target_market', 'market', 'global', 'strip', 'get_available_markets', 'dict', 'code', '', 'name', 'Exception'
    pass

def _extend_idea_config_snapshot(config: 'dict[str, Any]', session_key: 'str', session: 'dict[str, Any] | None' = None) -> 'dict[str, Any]':
    # [PyArmor BCC constants]: 'dict', 'str', 'get', 'model_key', 'video_model_key', '', 'strip', 'extend_model_key', 'selected_style_name', 'selected_style_id', 'selected_style', 'title', 'name', 'split', ':'
    pass
