"""
Decompiled / Reconstructed Module: qml_app.controllers.master_options_controller

Docstring:
QML controller for Master Prompt configuration.
"""

from __future__ import annotations
import sys, os, typing
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
_MASTER_WORKSPACE_KEY = 'master_workspace'

# --- Class: Inflight ---
class Inflight:
    """A 1-slot coalescing guard: refuses a new run while one is pending."""
    _busy = <member '_busy' of 'Inflight' objects>

    def __init__(self) -> 'None':
        pass

    def begin(self) -> 'bool':
        pass

    def done(self) -> 'None':
        pass


# --- Class: _StyleAiWorker ---
class _StyleAiWorker:
    def __init__(self, service, payload: 'dict[str, Any]', with_preview: 'bool', on_phase=None) -> 'None':
        # [PyArmor BCC constants]: '_service', 'dict', '_payload', '_with_preview', '_on_phase'
        pass

    def _phase(self, key: 'str') -> 'None':
        # [PyArmor BCC constants]: '_on_phase', 'str', '', 'Exception'
        pass

    def compute(self) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_phase', 'framework', '_service', 'generate_style_framework', '_payload', 'get', 'ok', '_with_preview', 'preview', 'dict', 'style', 'generate_style_preview', 'preview_result', 'preview_state', False
        pass


# --- Class: _StyleTopicAiWorker ---
class _StyleTopicAiWorker:
    def __init__(self, service, payload: 'dict[str, Any]') -> 'None':
        pass

    def compute(self) -> 'dict[str, Any]':
        pass


# --- Class: _StyleTopicProposeWorker ---
class _StyleTopicProposeWorker:
    """
    Curator v2: propose a topic's styles (with rationale) WITHOUT saving.
        The UI reviews + commits the chosen ones via commitStyleTopic().
    """
    def __init__(self, service, payload: 'dict[str, Any]') -> 'None':
        pass

    def compute(self) -> 'dict[str, Any]':
        pass


# --- Class: _StylePreviewQueueWorker ---
class _StylePreviewQueueWorker:
    def __init__(self, service, *, payload: 'dict[str, Any] | None' = None, items: 'list[dict[str, Any]] | None' = None, only_missing: 'bool' = True, current_style_id: 'str' = '', bulk: 'bool' = False, combo_selection: 'dict[str, Any] | None' = None) -> 'None':
        # [PyArmor BCC constants]: '_service', 'dict', '_payload', 'list', '_items', 'bool', '_only_missing', 'str', '', '_current_style_id', '_bulk', '_combo_selection'
        pass

    def compute(self) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_combo_selection', '_service', 'generate_style_combo_preview', '_bulk', 'start_style_preview_campaign', '_items', 'only_missing', '_only_missing', '_current_style_id', 'style_preview', 'refreshed_preview', 'generate_style_preview', '_payload', 'master.config.generate_style_combo_preview', 'master.config.generate_style_preview_bulk'
        pass


# --- Class: MasterOptionsController ---
class MasterOptionsController(QObject):
    """Expose persisted Master config and option lists to QML."""
    staticMetaObject = PySide6.QtCore.QMetaObject("MasterOptionsController" inherits "QObject":
Properties:
  #1 "config", QVariantMap [designa...

    configChanged = Signal()
    sharedAutoMergeChanged = Signal()
    optionsChanged = Signal()
    stylesChanged = Signal()
    drawStyleHandBindingsChanged = Signal()
    drawStyleMotionProfilesChanged = Signal()
    _drawBindingsLoaded = Signal()
    _drawBindingsSaved = Signal()
    _optionsDataReady = Signal()
    _styleAiDone = Signal()
    _styleAiPhaseSet = Signal()
    _styleTopicGenDone = Signal()
    _styleTopicProposeDone = Signal()
    _stylePreviewDone = Signal()
    _drawMotionPreviewDone = Signal()
    statusMessageChanged = Signal()
    actionResultChanged = Signal()
    styleAiBusyChanged = Signal()
    styleAiPhaseChanged = Signal()
    styleAiGenerated = Signal()
    styleTopicBusyChanged = Signal()
    styleTopicGenerated = Signal()
    styleTopicProposed = Signal()
    stylePreviewBusyChanged = Signal()
    stylePreviewGenerated = Signal()
    drawMotionPreviewBusyChanged = Signal()
    drawMotionPreviewGenerated = Signal()
    pendingDialogChanged = Signal()
    ideaTextChanged = Signal()
    scriptTextChanged = Signal()
    extraRequirementsTextChanged = Signal()
    _modelsUpdatedSignal = Signal()
    def __init__(self) -> 'None':
        # [PyArmor BCC constants]: 'ok', 'blocked', 'action', 'code', 'message', 'blocker'
        pass

    def _on_models_updated(self) -> 'None':
        pass

    def config(*args, **kwargs):
        pass

    def options(*args, **kwargs):
        pass

    def styles(*args, **kwargs):
        pass

    def drawStyleHandBindings(*args, **kwargs):
        pass

    def drawStyleMotionProfiles(*args, **kwargs):
        pass

    def drawMotionHandOptions(*args, **kwargs):
        pass

    def statusMessage(*args, **kwargs):
        pass

    def lastAction(*args, **kwargs):
        pass

    def actionStatus(*args, **kwargs):
        pass

    def styleAiBusy(*args, **kwargs):
        pass

    def styleAiPhase(*args, **kwargs):
        pass

    def styleTopicBusy(*args, **kwargs):
        pass

    def stylePreviewBusy(*args, **kwargs):
        pass

    def drawMotionPreviewBusy(*args, **kwargs):
        pass

    def pendingDialog(*args, **kwargs):
        pass

    def ideaText(*args, **kwargs):
        pass

    def extraRequirementsText(*args, **kwargs):
        pass

    def setIdeaText(self, text: 'str') -> 'None':
        # [PyArmor BCC constants]: 'str', '', '_idea_text', '_settings', 'set_setting', '_MASTER_WORKSPACE_KEY', 'idea_text', 'ideaTextChanged', 'emit'
        pass

    def scriptText(*args, **kwargs):
        pass

    def setScriptText(self, text: 'str') -> 'None':
        # [PyArmor BCC constants]: 'str', '', '_script_text', '_settings', 'set_setting', '_MASTER_WORKSPACE_KEY', 'script_text', 'scriptTextChanged', 'emit'
        pass

    def setExtraRequirementsText(self, text: 'str') -> 'None':
        # [PyArmor BCC constants]: 'str', '', '_extra_requirements_text', '_settings', 'set_setting', '_MASTER_WORKSPACE_KEY', 'extra_requirements_text', 'extraRequirementsTextChanged', 'emit'
        pass

    def refresh(self) -> 'None':
        # [PyArmor BCC constants]: '_refresh_inflight', True, '_config_revision', '_service', 'get_config', 'get_options', 'list', 'list_styles', 'get', 'styles', 'ok', 'config', 'options', 'config_revision', 'error'
        pass

    def _apply_options_data(self, payload: 'dict[str, Any]') -> 'None':
        # [PyArmor BCC constants]: False, '_refresh_inflight', 'get', 'ok', 'config', 'options', 'list', 'styles', '_set_status', 'Master config loaded', 'Master config failed: ', 'error', 'Error', 'int', 'config_revision'
        pass

    def setOption(self, key: 'str', value: 'Any') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'ok', False, 'blocked', 'action', 'master.config.set_option', 'code', 'master_config_option_key_missing', 'error', 'option_key_missing', 'message', 'Config option key missing', '_set_action_result', '_service', 'save_option', 'get'
        pass

    def setOptions(self, patch: 'dict[str, Any]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_service', 'save_config', 'dict', 'ok', 'blocked', 'action', 'code', 'config', 'message', True, False, 'master.config.set_options', 'master_config_options_saved', 'Master options updated', '_config'
        pass

    def applySharedAutoMerge(self, enabled: 'bool') -> 'None':
        # [PyArmor BCC constants]: 'bool', '_shared_auto_merge_override', '_config', 'get', 'auto_merge_video', 'dict', 'configChanged', 'emit'
        pass

    def setFolder(self, folder: 'str') -> 'dict[str, Any]':
        pass

    def requestFolderPicker(self) -> 'dict[str, Any]':
        pass

    def setCharacterLibrarySelection(self, selection: 'dict[str, Any]', available_items: 'list[Any]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_service', 'set_character_library_selection', 'dict', 'list', 'isinstance', 'get', 'config', 'get_config', '_config', 'get_options', '_options', '_set_action_result', 'ok', 'blocked', 'action'
        pass

    def setLibraryAssetSelection(self, category: 'str', selection: 'dict[str, Any]', available_items: 'list[Any]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_service', 'set_library_asset_selection', 'dict', 'list', 'isinstance', 'get', 'config', 'get_config', '_config', 'get_options', '_options', '_set_action_result', 'ok', 'blocked', 'action'
        pass

    def clearCharacterLibrarySelection(self) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_service', 'clear_character_library_selection', 'dict', 'get', 'config', 'get_config', '_config', 'get_options', '_options', '_set_action_result', 'ok', 'blocked', 'action', 'code', 'error'
        pass

    def moveCharacterLibrarySelection(self, media_id: 'str', offset: 'int') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_service', 'move_character_library_selection', 'dict', 'get', 'config', 'get_config', '_config', 'get_options', '_options', '_set_action_result', 'ok', 'blocked', 'action', 'code', 'error'
        pass

    def removeCharacterLibrarySelection(self, media_id: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_service', 'remove_character_library_selection', 'dict', 'get', 'config', 'get_config', '_config', 'get_options', '_options', '_set_action_result', 'ok', 'blocked', 'action', 'code', 'error'
        pass

    def removeLibraryAssetSelection(self, category: 'str', media_id: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_service', 'remove_library_asset_selection', 'dict', 'get', 'config', 'get_config', '_config', 'get_options', '_options', '_set_action_result', 'ok', 'blocked', 'action', 'code', 'error'
        pass

    def setFlowVoiceSelection(self, selection: 'dict[str, Any]', available_items: 'list[Any]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_service', 'set_flow_voice_selection', 'dict', 'list', 'isinstance', 'get', 'config', 'get_config', '_config', 'get_options', '_options', '_set_action_result', 'ok', 'blocked', 'action'
        pass

    def removeFlowVoiceSelection(self, media_id: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_service', 'remove_flow_voice_selection', 'dict', 'get', 'config', 'get_config', '_config', 'get_options', '_options', '_set_action_result', 'ok', 'blocked', 'action', 'code', 'error'
        pass

    def refreshFlowVoiceSelection(self) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_service', 'refresh_flow_voice_selection', 'dict', 'get', 'config', 'get_config', '_config', 'get_options', '_options', '_set_action_result', 'ok', 'blocked', 'action', 'code', 'error'
        pass

    def requestOpenDialog(self, name: 'str') -> 'None':
        # [PyArmor BCC constants]: 'str', '', 'strip', 'name', '_pending_dialog', 'pendingDialogChanged', 'emit'
        pass

    def consumePendingDialog(self, name: 'str') -> 'bool':
        # [PyArmor BCC constants]: 'str', '', 'strip', '_pending_dialog', 'get', 'name', False, 'pendingDialogChanged', 'emit', True
        pass

    def refreshStyles(self, search: 'str' = '') -> 'None':
        # [PyArmor BCC constants]: '_service', 'list_styles', 'list', 'get', 'styles', '_styles', 'stylesChanged', 'emit', 'error', '_set_status', 'Load styles failed: ', 'Loaded ', 'len', ' style(s)'
        pass

    def _load_draw_bindings_async(self) -> 'None':
        # [PyArmor BCC constants]: 'hands', 'profiles', 'load_draw_style_hand_bindings', 'load_draw_style_motion_profiles', 'run_off_thread', '_draw_binding_load_inflight', '_drawBindingsLoaded', 'name', 'DrawStyleBindingsLoad'
        pass

    def _apply_draw_bindings_loaded(self, payload: 'dict[str, Any]') -> 'None':
        # [PyArmor BCC constants]: '_draw_binding_load_inflight', 'done', 'get', 'ok', '_draw_binding_revision', 0, 'dict', 'data', 'hands', 'items', 'str', '_draw_style_hand_bindings', 'drawStyleHandBindingsChanged', 'emit', 'profiles'
        pass

    def _draw_style_item(self, style_id: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'str', '', 'strip', 'lower', '_styles', 'get', 'id', 'style_id', 'dict'
        pass

    def _draw_style_has_catalog_capability(self, style_id: 'str') -> 'bool':
        # [PyArmor BCC constants]: '_draw_style_item', 'get', 'framework_definition', 'framework', 'resolved', 'dict', 'render_capabilities', 'image_motion', 'renderers', 'str', '', 'strip', 'lower', 'bool', 'enabled'
        pass

    def _draw_style_configured(self, style_id: 'str') -> 'bool':
        # [PyArmor BCC constants]: 'str', '', 'strip', 'lower', 'dict', '_draw_style_motion_profiles', 'get', 'bool', 'enabled', '_draw_style_has_catalog_capability'
        pass

    def _draw_style_supports_hand(self, style_id: 'str') -> 'bool':
        pass

    def isDrawStyleConfigured(self, styleId: 'str') -> 'bool':
        pass

    def setDrawStyleMotionProfile(self, styleId: 'str', actorMode: 'str', assetId: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'str', '', 'strip', 'lower', '_draw_style_item', 'ok', False, 'code', 'draw_style_missing', 'message', 'Style is not available.', 'get', 'framework_definition', 'framework', 'resolved'
        pass

    def setDrawStyleHandBinding(self, styleId: 'str', assetId: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'str', '', 'strip', 'lower', 'normalize_hand_asset_id', '_draw_style_supports_hand', 'ok', False, 'code', 'draw_style_not_hand_renderable', 'message', 'Style is not eligible for hand/pen Draw mode.', 'dict', '_draw_style_hand_bindings', 'auto'
        pass

    def _persist_draw_bindings_async(self) -> 'None':
        # [PyArmor BCC constants]: '_draw_binding_save_pending', 'dict', '_draw_style_hand_bindings', '_draw_style_motion_profiles', 'items', 'int', '_draw_binding_revision', 'save_draw_style_hand_bindings', 'save_draw_style_motion_profiles', 'bindings', 'profiles', 'revision', 'run_off_thread', '_draw_binding_save_inflight', '_drawBindingsSaved'
        pass

    def _apply_draw_bindings_saved(self, payload: 'dict[str, Any]') -> 'None':
        # [PyArmor BCC constants]: '_draw_binding_save_inflight', 'done', 'int', 'get', 'data', 'revision', 1, 'ok', True, '_draw_binding_save_pending', '_set_status', 'Save Draw hand/pen binding failed', '_draw_binding_revision', '_draw_binding_save_timer', 'start'
        pass

    def selectStyle(self, style: 'dict[str, Any]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_service', 'select_style', 'dict', 'get', 'config', 'get_config', '_config', 1, '_config_revision', 'get_options', '_options', '_set_action_result', 'ok', 'blocked', 'action'
        pass

    def selectStyleSelection(self, selection: 'dict[str, Any]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_service', 'select_style_selection', 'dict', 'get', 'config', 'get_config', '_config', 1, '_config_revision', 'get_options', '_options', '_set_action_result', 'ok', 'blocked', 'action'
        pass

    def saveStyle(self, styleId: 'str', name: 'str', prompt: 'str', kind: 'str' = 'style', description: 'str' = '', frameworkJson: 'str' = '') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_service', 'upsert_style', 'refreshStyles', '', 'get', 'created', 'Created', 'Updated', 'dict', 'style', ' style: ', 'id', 'message', '_set_action_result', 'str'
        pass

    def requestStyleAiGeneration(self, payload: 'dict[str, Any]', withPreview: 'bool' = False) -> 'None':
        # [PyArmor BCC constants]: '_style_ai_busy', '_set_action_result', 'ok', False, 'blocked', True, 'action', 'master.config.generate_style_framework', 'code', 'master_config_style_ai_busy', 'message', 'Style AI generation is already running.', 'framework', '_style_ai_phase', 'styleAiBusyChanged'
        pass

    def requestStyleTopicGeneration(self, payload: 'dict[str, Any]') -> 'None':
        # [PyArmor BCC constants]: '_style_topic_busy', '_set_action_result', 'ok', False, 'blocked', True, 'action', 'master.config.generate_style_topic_tree', 'code', 'master_config_style_topic_busy', 'message', 'Style topic tree generation is already running.', 'styleTopicBusyChanged', 'emit', 'run_off_thread'
        pass

    def requestStyleTopicProposal(self, payload: 'dict[str, Any]') -> 'None':
        # [PyArmor BCC constants]: '_style_topic_busy', '_set_action_result', 'ok', False, 'blocked', True, 'action', 'master.config.propose_style_topic', 'code', 'master_config_style_topic_busy', 'message', 'Style topic generation is already running.', 'styleTopicBusyChanged', 'emit', 'run_off_thread'
        pass

    def commitStyleTopic(self, payload: 'dict[str, Any]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_service', 'commit_style_topic', 'get', 'ok', 'refreshStyles', '', '_set_action_result', 'styleTopicGenerated', 'emit', 'Commit topic failed: ', 'type', '__name__', 'blocked', 'action', 'code'
        pass

    def requestStylePreviewGeneration(self, payload: 'dict[str, Any]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_style_preview_busy', 'ok', False, 'blocked', True, 'action', 'master.config.generate_style_preview', 'code', 'master_config_style_preview_busy', 'message', 'Style preview queueing is already running.', '_set_action_result', '_start_style_preview_worker', 'payload', 'bulk'
        pass

    def requestStyleComboPreviewGeneration(self, selection: 'dict[str, Any]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_style_preview_busy', 'ok', False, 'blocked', True, 'action', 'master.config.generate_style_combo_preview', 'code', 'master_config_style_preview_busy', 'message', 'Style preview queueing is already running.', '_set_action_result', '_start_style_preview_worker', 'combo_selection', 'dict'
        pass

    def requestStylePreviewBulk(self, items: 'list[dict[str, Any]]', onlyMissing: 'bool' = True, currentStyleId: 'str' = '') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_style_preview_busy', 'ok', False, 'blocked', True, 'action', 'master.config.generate_style_preview_bulk', 'code', 'master_config_style_preview_busy', 'message', 'Style preview queueing is already running.', '_set_action_result', '_start_style_preview_worker', 'items', 'list'
        pass

    def requestDrawMotionPreview(self, styleId: 'str', actorMode: 'str', handAsset: 'str', force: 'bool' = False) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'str', '', 'strip', '_draw_style_item', 'style', 'id', 'style_id', 'actor_mode', 'hand_asset', 'still_path', 'force', 'auto', 'get', 'preview_path', 'preview_thumb'
        pass

    def _start_draw_motion_preview_worker(self, request: 'dict[str, Any]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'dict', True, '_draw_motion_preview_busy', 'drawMotionPreviewBusyChanged', 'emit', '_service', 'generate_draw_motion_preview', 'int', 'get', 'revision', 0, 'run_off_thread', '_draw_motion_preview_inflight', '_drawMotionPreviewDone', 'name'
        pass

    def _on_draw_motion_preview_done(self, payload: 'dict') -> 'None':
        # [PyArmor BCC constants]: '_draw_motion_preview_inflight', 'done', 'dict', 'get', 'data', 'ok', 'action', 'code', 'exists', 'message', False, 'master.config.generate_draw_motion_preview', 'str', 'error', 'draw_motion_preview_failed'
        pass

    def _start_style_preview_worker(self, *, payload: 'dict[str, Any] | None' = None, items: 'list[dict[str, Any]] | None' = None, only_missing: 'bool' = True, current_style_id: 'str' = '', bulk: 'bool' = False, combo_selection: 'dict[str, Any] | None' = None) -> 'None':
        # [PyArmor BCC constants]: True, '_style_preview_busy', 'stylePreviewBusyChanged', 'emit', '_StylePreviewQueueWorker', '_service', 'payload', 'items', 'only_missing', 'current_style_id', 'bulk', 'combo_selection', 'run_off_thread', '_stylePreviewDone', 'compute'
        pass

    def toggleStyleFavorite(self, styleId: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_service', 'toggle_style_favorite', 'refreshStyles', '', '_set_action_result', 'Toggle style favorite failed: ', 'type', '__name__', 'ok', 'blocked', 'action', 'code', 'error', 'message', False
        pass

    def stylePreview(self, styleId: 'str') -> 'dict[str, Any]':
        pass

    def stylePreviewCampaignProgress(self, campaignId: 'str') -> 'dict[str, Any]':
        pass

    def convertStylePreviewsToWebp(self) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_service', 'convert_style_previews_to_webp', 'ok', 'action', 'code', 'error', 'message', False, 'master.config.convert_style_previews_to_webp', 'type', '__name__', 'str', 'WebP conversion failed: ', 'Exception', '_set_action_result'
        pass

    def deleteStyle(self, styleId: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_service', 'delete_style', 'refreshStyles', '', 'get', 'deleted', 'restored_base', 'Removed custom override: ', 'message', 'Deleted custom style: ', 'Delete skipped: ', 'error', 'not custom', '_set_action_result', 'Delete style failed: '
        pass

    def deleteStyleTopic(self, topicId: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_service', 'delete_style_topic', 'refreshStyles', '', '_set_action_result', 'Delete topic failed: ', 'type', '__name__', 'ok', 'deleted', 'action', 'code', 'error', 'message', False
        pass

    def previewVoice(self, voice_code: 'str') -> 'dict':
        # [PyArmor BCC constants]: 'play_wav_preview', 'get_bundled_resources_dir', 'voices', '.wav', 'dict', 'str', 'setdefault', 'source', 'get', 'ok', 'local', 'none', 'error', False, 'Exception'
        pass

    def markBlocked(self, action: 'str') -> 'None':
        pass

    @staticmethod
    def _unwrap(payload: 'dict', action: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'get', 'ok', 'dict', 'data', 'Worker crashed: ', 'error', 'unknown', 'action', 'code', 'message', False, 'worker_crashed'
        pass

    def _on_style_ai_phase(self, phase: 'str') -> 'None':
        # [PyArmor BCC constants]: 'str', '', 'strip', '_style_ai_phase', 'styleAiPhaseChanged', 'emit'
        pass

    def _on_style_ai_done(self, payload: 'dict') -> 'None':
        # [PyArmor BCC constants]: False, '_style_ai_busy', '', '_style_ai_phase', 'styleAiBusyChanged', 'emit', 'styleAiPhaseChanged', '_unwrap', 'master.config.generate_style_ai', '_set_action_result', 'styleAiGenerated'
        pass

    def _on_style_topic_gen_done(self, payload: 'dict') -> 'None':
        # [PyArmor BCC constants]: False, '_style_topic_busy', 'styleTopicBusyChanged', 'emit', '_unwrap', 'master.config.generate_style_topic_tree', '_set_action_result', 'get', 'ok', 'refreshStyles', '', 'styleTopicGenerated'
        pass

    def _on_style_topic_propose_done(self, payload: 'dict') -> 'None':
        # [PyArmor BCC constants]: False, '_style_topic_busy', 'styleTopicBusyChanged', 'emit', '_unwrap', 'master.config.propose_style_topic', '_set_action_result', 'styleTopicProposed'
        pass

    def _on_style_preview_done(self, payload: 'dict') -> 'None':
        # [PyArmor BCC constants]: False, '_style_preview_busy', 'stylePreviewBusyChanged', 'emit', '_unwrap', 'master.config.generate_style_preview', '_set_action_result', 'stylePreviewGenerated'
        pass

    def _set_action_result(self, result: 'dict[str, Any]') -> 'None':
        # [PyArmor BCC constants]: 'isinstance', 'get', 'blocker', 'dict', 'bool', 'blocked', 'str', 'code', 'error', '', 'message', 'Action blocked', 'Action completed', 'action', 'ok'
        pass

    def _set_status(self, message: 'str') -> 'None':
        pass

