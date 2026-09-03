"""
Decompiled / Reconstructed Module: qml_app.controllers.master_voice_controller

Docstring:
Master Voice Config controller — global TTS config accessible from any tab.

Registered as `masterVoiceController` in main.py.
Backed by services/shared/voice/voice_api.py (process-wide singleton).

Any tab can:
  - Read: masterVoiceController.provider / voice / model / sharedTtsConfig
  - Write: masterVoiceController.setOption("tts_provider", "gemini")
  - Generate: masterVoiceController.generate(text) → {ok, audio_path, duration}
"""

from __future__ import annotations
import sys, os, typing
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)

# --- Class: _GenerateWorker ---
class _GenerateWorker(QThread):
    staticMetaObject = PySide6.QtCore.QMetaObject("_GenerateWorker" inherits "QThread":
Methods:
  #12 type=Signal, signature=resultReady(PyObj...

    resultReady = Signal()
    def __init__(self, api: 'Any', text: 'str', config: 'dict[str, Any]') -> 'None':
        pass

    def run(self) -> 'None':
        # [PyArmor BCC constants]: '_api', 'generate', '_text', '_config', 'ok', 'error', False, 'str', 'Exception', 'resultReady', 'emit'
        pass


# --- Class: MasterVoiceController ---
class MasterVoiceController(QObject):
    """Global TTS config — same pattern as MasterOptionsController."""
    staticMetaObject = PySide6.QtCore.QMetaObject("MasterVoiceController" inherits "QObject":
Properties:
  #1 "providers", QVariantList [desig...

    configChanged = Signal()
    optionsChanged = Signal()
    busyChanged = Signal()
    statusMessageChanged = Signal()
    generateResultChanged = Signal()
    def __init__(self) -> 'None':
        pass

    @staticmethod
    def _get_api() -> 'Any':
        pass

    @staticmethod
    def _t(v: 'Any') -> 'str':
        pass

    def providers(*args, **kwargs):
        pass

    def provider(*args, **kwargs):
        pass

    def voices(*args, **kwargs):
        pass

    def voice(*args, **kwargs):
        pass

    def models(*args, **kwargs):
        pass

    def model(*args, **kwargs):
        pass

    def ttsMode(*args, **kwargs):
        pass

    def sharedTtsConfig(*args, **kwargs):
        pass

    def outputFolder(*args, **kwargs):
        pass

    def providerOptions(*args, **kwargs):
        pass

    def busy(*args, **kwargs):
        pass

    def statusMessage(*args, **kwargs):
        pass

    def lastResult(*args, **kwargs):
        pass

    def setProvider(self, provider: 'str') -> 'None':
        # [PyArmor BCC constants]: '_t', '_api', 'apply_state', 'tts_provider', 'configChanged', 'emit', '_refresh_options', '_set_status', 'Voice provider: '
        pass

    def setVoice(self, voice_id: 'str') -> 'None':
        # [PyArmor BCC constants]: '_t', '_api', 'apply_state', 'tts_voice', 'configChanged', 'emit', '_set_status', 'Voice: '
        pass

    def setModel(self, model: 'str') -> 'None':
        # [PyArmor BCC constants]: '_t', '_api', 'apply_state', 'tts_model', 'configChanged', 'emit', '_set_status', 'TTS model: '
        pass

    def setTtsMode(self, mode: 'str') -> 'None':
        # [PyArmor BCC constants]: '_t', 'lower', 'auto', 'manual', '_api', 'apply_state', 'tts_mode', 'configChanged', 'emit'
        pass

    def setOutputFolder(self, folder: 'str') -> 'None':
        # [PyArmor BCC constants]: '_api', 'apply_state', 'output_folder', '_t', 'configChanged', 'emit', '_set_status', 'Audio output: '
        pass

    def setOption(self, key: 'str', value: 'Any') -> 'None':
        # [PyArmor BCC constants]: '_api', 'apply_state', '_t', 'configChanged', 'emit'
        pass

    def applyState(self, delta: 'dict[str, Any]') -> 'None':
        # [PyArmor BCC constants]: '_api', 'apply_state', 'dict', 'configChanged', 'emit'
        pass

    def refresh(self) -> 'None':
        # [PyArmor BCC constants]: '_refresh_providers', '_refresh_options', 'configChanged', 'emit'
        pass

    def refreshOptions(self) -> 'None':
        pass

    def generateSync(self, text: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'dict', '_api', 'generate', '_t'
        pass

    def generateAsync(self, text: 'str') -> 'None':
        # [PyArmor BCC constants]: '_busy', '_set_busy', True, '_GenerateWorker', '_api', '_t', '_workers', 'append', 'resultReady', 'connect', 'finished', '_release_finished_worker', 'register', 'start'
        pass

    def _release_finished_worker(self) -> 'None':
        # [PyArmor BCC constants]: 'sender', '_workers', 'remove', 'ValueError', 'deleteLater'
        pass

    def getState(self) -> 'dict[str, Any]':
        pass

    def _refresh_providers(self) -> 'None':
        # [PyArmor BCC constants]: 'list', '_api', 'list_providers', '_providers', 'value', 'gemini', 'label', 'Gemini Audio', 'accent', '#3B82F6', 'minimax', 'MiniMax', '#F59E0B', 'elevenlabs', 'ElevenLabs'
        pass

    def _refresh_options(self) -> 'None':
        # [PyArmor BCC constants]: 'provider', '_api', 'list_voices', '_voice_option', 'label', 'Default', 'value', 'default', 'flag', '', '_voices', 'Exception', 'list_models', '_t', 'get'
        pass

    @staticmethod
    def _voice_option(item: 'Any', provider: 'str') -> 'dict[str, str]':
        # [PyArmor BCC constants]: 'isinstance', 'dict', 'label', 'value', 'flag', 'str', '', 'vi', 'vn', 'en', 'us', 'ja', 'jp', 'ko', 'kr'
        pass

    @staticmethod
    def _options_from_state(state: 'dict[str, Any]', provider: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'minimax', 'speed', 'pitch', 'vol', 'emotion', 'audio_format', 'float', 'get', 'minimax_speed', 1.0, 'int', 'minimax_pitch', 0, 'minimax_volume', 'str'
        pass

    def _on_generate_done(self, worker: '_GenerateWorker', result: 'Any') -> 'None':
        # [PyArmor BCC constants]: 'isinstance', 'dict', 'ok', False, 'error', 'invalid_result', '_last_result', '_set_busy', 'generateResultChanged', 'emit', '_set_status', 'get', 'Voice generated.', 'str', 'Voice generation failed'
        pass

    def _set_busy(self, value: 'bool') -> 'None':
        pass

    def _set_status(self, msg: 'str') -> 'None':
        pass


# --- Top-Level Functions ---
def get_master_voice_controller() -> 'MasterVoiceController':
    pass
