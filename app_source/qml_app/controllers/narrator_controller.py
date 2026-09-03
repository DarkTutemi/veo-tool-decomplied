"""
Decompiled / Reconstructed Module: qml_app.controllers.narrator_controller

Docstring:
Narrator control controller — shared narrator voice config for any tab.

Registered as `narratorController` in main.py. Backed by the Qt-free
services/shared/narration/narrator_prefs.py singleton (persisted), so the
pipeline reads the SAME state without Qt.

Per-tab ON/OFF is NOT here — each tab owns its toggle (master:
`enable_narrator` in master options; clone: its own key later). This controller
owns only the shared narrator identity: voice 1, optional voice 2 (Gemini
multi-speaker TTS caps at 2), emotion — and voice preview, which plays the
BUNDLED sample WAVs (resources/voices/<name>.wav, same source as
masterOptionsController.previewVoice) instead of spending a TTS call.
"""

from __future__ import annotations
import sys, os, typing
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Optional = typing.Optional
_VOICE2_OFF = ''
_AUTO = 'auto'

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


# --- Class: NarratorController ---
class NarratorController(QObject):
    """Shared narrator identity — same controller from master, clone, or future tabs."""
    staticMetaObject = PySide6.QtCore.QMetaObject("NarratorController" inherits "QObject":
Properties:
  #1 "voiceMode", QString [designable], ...

    configChanged = Signal()
    optionsChanged = Signal()
    asrStateChanged = Signal()
    _asrDone = Signal()
    _asrProgress = Signal()
    def __init__(self) -> 'None':
        pass

    def _api(self) -> 'Any':
        pass

    @staticmethod
    def _t(v: 'Any') -> 'str':
        pass

    def _ensure_options(self) -> 'None':
        pass

    def voiceMode(*args, **kwargs):
        pass

    def voice(*args, **kwargs):
        pass

    def emotion(*args, **kwargs):
        pass

    def selectedVoiceValue(*args, **kwargs):
        pass

    def voice2Value(*args, **kwargs):
        pass

    def voiceOptions(*args, **kwargs):
        pass

    def voice2Options(*args, **kwargs):
        pass

    def emotionOptions(*args, **kwargs):
        pass

    def autoVoiceHint(*args, **kwargs):
        pass

    def selectVoiceValue(self, value: 'str') -> 'None':
        # [PyArmor BCC constants]: '_t', '_AUTO', '_api', 'apply_state', 'voice_mode', 'voice', 'manual', 'configChanged', 'emit'
        pass

    def selectVoice2Value(self, value: 'str') -> 'None':
        # [PyArmor BCC constants]: '_t', '_api', 'apply_state', 'voice2', '_VOICE2_OFF', 'configChanged', 'emit'
        pass

    def setEmotion(self, emotion_id: 'str') -> 'None':
        # [PyArmor BCC constants]: '_api', 'apply_state', 'emotion', '_t', 'configChanged', 'emit'
        pass

    def notifyExternalChange(self) -> 'None':
        pass

    @staticmethod
    def _has_nvidia() -> 'bool':
        # [PyArmor BCC constants]: 'bool', 'shutil', 'which', 'nvidia-smi', 'os', 'path', 'exists', 'C:\\Windows\\System32\\nvidia-smi.exe', False, 'Exception'
        pass

    def asrOfferVisible(*args, **kwargs):
        pass

    def asrInstallBusy(*args, **kwargs):
        pass

    def asrStatus(*args, **kwargs):
        pass

    def installAsrEngine(self) -> 'None':
        pass

    def dismissAsrOffer(self) -> 'None':
        # [PyArmor BCC constants]: '_api', 'apply_state', 'asr_offer_dismissed', '1', False, '_asr_offer', 'asrStateChanged', 'emit'
        pass

    def _on_asr_done(self, payload: 'dict') -> 'None':
        # [PyArmor BCC constants]: '_asr_inflight', 'done', False, '_asr_busy', 'isinstance', 'dict', 'get', 'data', 'bool', 'ok', '_asr_offer', 'Đã cài engine chép lời offline ✓ — job dẫn truyện sẽ chép local', '_asr_status', 'Cài engine không thành công — sẽ tiếp tục dùng Gemini', 'asrStateChanged'
        pass

    def _on_asr_progress(self, msg: 'str') -> 'None':
        # [PyArmor BCC constants]: '_t', '_asr_status', 'asrStateChanged', 'emit'
        pass

    def resolveForJob(self, language: 'str', genre_hint: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_api', 'resolve_voices', '_t', 'voices', 'dict', 'name', 'mode', 'reason', 'Charon', '_AUTO', 'fallback:', 'Exception'
        pass

    def previewVoice(self, value: 'str', which: 'int' = 1) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_t', 'ok', False, 'message', 'off', '_AUTO', '_api', 'resolve_voice', '', 'int', 2, 'auto_pick_second_voice', 'get', 'name', 'play_wav_preview'
        pass


# --- Top-Level Functions ---
def get_narrator_controller() -> 'NarratorController':
    pass
