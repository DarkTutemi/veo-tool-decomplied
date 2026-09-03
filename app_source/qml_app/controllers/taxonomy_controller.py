"""
Decompiled / Reconstructed Module: qml_app.controllers.taxonomy_controller

Docstring:
QML controller for editable theme and strategy taxonomies.
"""

from __future__ import annotations
import sys, os, typing
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)

# --- Class: TaxonomyController ---
class TaxonomyController(QObject):
    """Expose TaxonomyService contracts to reusable QML edit dialogs."""
    staticMetaObject = PySide6.QtCore.QMetaObject("TaxonomyController" inherits "QObject":
Properties:
  #1 "payload", QVariantMap [designable]...

    payloadChanged = Signal()
    statusMessageChanged = Signal()
    actionChanged = Signal()
    voiceGenBusyChanged = Signal()
    mediaVoiceGenerated = Signal()
    mediaVoiceBindingSynced = Signal()
    _voiceGenDone = Signal()
    _bindPresyncDone = Signal()
    def __init__(self) -> 'None':
        # [PyArmor BCC constants]: 'ok', 'themes', 'strategies', 'total'
        pass

    def payload(*args, **kwargs):
        pass

    def themes(*args, **kwargs):
        pass

    def strategies(*args, **kwargs):
        pass

    def statusMessage(*args, **kwargs):
        pass

    def lastAction(*args, **kwargs):
        pass

    def refresh(self, search: 'str' = '') -> 'None':
        # [PyArmor BCC constants]: '_service', 'taxonomy_payload', '_payload', '_set_status', 'Loaded taxonomy: ', 'get', 'total', 0, ' item(s)', 'ok', 'themes', 'strategies', 'error', False, 'str'
        pass

    def themeDialogPayload(self, themeId: 'str' = '', search: 'str' = '') -> 'dict[str, Any]':
        pass

    def strategyDialogPayload(self, strategyId: 'str' = '', search: 'str' = '') -> 'dict[str, Any]':
        pass

    def managementPayload(self, kind: 'str', search: 'str' = '') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_service', 'management_payload', '_set_action', 'taxonomy.', '.manager'
        pass

    def themeManagementPayload(self, search: 'str' = '') -> 'dict[str, Any]':
        pass

    def strategyManagementPayload(self, search: 'str' = '') -> 'dict[str, Any]':
        pass

    def saveTheme(self, payload: 'dict[str, Any]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_service', 'save_theme_payload', 'dict', '_apply_result', 'theme'
        pass

    def deleteTheme(self, themeId: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_service', 'delete_theme_payload', '_apply_result', 'theme'
        pass

    def saveStrategy(self, payload: 'dict[str, Any]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_service', 'save_strategy_payload', 'dict', '_apply_result', 'strategy'
        pass

    def deleteStrategy(self, strategyId: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_service', 'delete_strategy_payload', '_apply_result', 'strategy'
        pass

    def mediaVoiceLibraryPayload(self, search: 'str' = '') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_media_library', 'media_voice_library_payload', '_set_action', 'media.voice.library'
        pass

    def mediaVoiceBoundCharacters(self, voiceRow: 'dict[str, Any]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_media_library', 'media_voice_bound_characters', 'dict', '_set_action', 'media.voice.bound_characters'
        pass

    def previewMediaVoice(self, voiceRow: 'dict[str, Any]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_media_library', 'preview_media_voice', 'dict', '_set_action', 'media.voice.preview'
        pass

    def bindMediaVoiceToCharacter(self, mediaId: 'str', voiceRow: 'dict[str, Any]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_media_library', 'bind_media_voice_to_character', 'dict', 'presync', False, '_set_action', 'media.voice.bind', 'str', 'get', 'character_id', '', 'ok', '_start_bind_presync'
        pass

    def _start_bind_presync(self, media_id: 'str', character_id: 'str') -> 'None':
        # [PyArmor BCC constants]: '_bind_sync_jobs', 'add', 'str', '', 'run_off_thread', '_bindPresyncDone', 'name', 'VoiceBindPresync'
        pass

    def _on_bind_presync_done(self, payload: 'dict') -> 'None':
        # [PyArmor BCC constants]: 'get', 'ok', 'dict', 'data', 'action', 'code', 'message', False, 'media.voice.bind_sync', 'error', 'worker_crashed', 'Bind presync crashed: ', '', 'str', 'character_id'
        pass

    def createMediaVoice(self, name: 'str', baseVoice: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_media_library', 'create_media_voice', '_set_action', 'media.voice.create'
        pass

    def mediaVoiceBaseOptions(self) -> 'dict[str, Any]':
        pass

    def voiceGenBusy(*args, **kwargs):
        pass

    def generateMediaVoice(self, name: 'str', baseVoice: 'str', speaker: 'str', voicePerformance: 'str', dialog: 'str') -> 'None':
        # [PyArmor BCC constants]: '_voice_gen_busy', True, 'voiceGenBusyChanged', 'emit', '_media_library', 'str', 'run_off_thread', '_voiceGenDone', 'name', 'VoiceGenWorker'
        pass

    def _on_voice_gen_done(self, payload: 'dict') -> 'None':
        # [PyArmor BCC constants]: False, '_voice_gen_busy', 'voiceGenBusyChanged', 'emit', 'get', 'ok', 'dict', 'data', 'action', 'code', 'message', 'media.voice.generate', 'error', 'worker_crashed', 'Voice generation crashed: '
        pass

    def unbindMediaVoiceFromCharacter(self, mediaId: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_media_library', 'unbind_media_voice_from_character', '_set_action', 'media.voice.unbind'
        pass

    def _apply_result(self, result: 'dict[str, Any]', kind: 'str') -> 'None':
        # [PyArmor BCC constants]: '_set_action', 'taxonomy.', '.', 'get', 'action', 'save', 'ok', False, '_set_status', ' failed: ', 'error', 'code', 'unknown', 'refresh', ''
        pass

    def _set_action(self, result: 'dict[str, Any]', fallback_action: 'str') -> 'None':
        # [PyArmor BCC constants]: 'dict', 'setdefault', 'action', 'blocked', 'get', 'ok', False, 'blocker', 'str', 'code', 'error', 'taxonomy_action_failed', 'message', '_last_action', 'actionChanged'
        pass

    def _set_status(self, message: 'str') -> 'None':
        pass


# --- Top-Level Functions ---
def _voice_gen_work(service, name, base_voice, speaker, voice_performance, dialog) -> 'dict[str, Any]':
    # [PyArmor BCC constants]: 'generate_media_voice', 'ok', 'action', 'code', 'error', 'message', False, 'media.voice.generate', 'media_voice_generate_crashed', 'type', '__name__', 'str', 'Exception'
    pass

def _bind_presync_work(media_id: 'str', character_id: 'str') -> 'dict[str, Any]':
    # [PyArmor BCC constants]: 'ok', 'action', 'media_id', 'character_id', 'synced_accounts', 'synced_count', True, 'media.voice.bind_sync', 'str', '', 0, 'FlowCharacterService', 'presync_character_for_available_accounts', 'sorted', 'keys'
    pass
