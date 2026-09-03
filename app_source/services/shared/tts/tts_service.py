"""
Decompiled / Reconstructed Module: services.shared.tts.tts_service
Source PyC: tts_service.pyc

Docstring:
TTS Service — Gemini Text-to-Speech only (MiniMax / ElevenLabs / Local TTS removed).
Single + multi speaker (max 2), PCM → WAV.

Two separate routes, see ``TTSService.generate_and_save``:
  - "aistudio" — free AI Studio path, structured Composer prompt, local chunking
  - "gateway"  — paid ``tts_long`` job queue, server-side chunking, file_uri
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
Dict = typing.Dict
List = typing.List
Optional = typing.Optional
Tuple = typing.Tuple
_SENTENCE_RE = re.compile('(?<=[.!?…])\\s+')
_GEMINI_BARE_PAUSE_RE = re.compile('\\[\\s*pause\\s*\\]', re.IGNORECASE)
AVAILABLE_VOICES = [{'name': 'Zephyr', 'style': 'Bright', 'gender': 'M', 'lang': 'en', 'director': 'Speak with bright, clear energy. Maintain an uplifting and engaging tone throughout.'}, {'name': 'Puck', 'style': 'Upbe... [truncated]
VOICE_PRESETS = {'warm_narrator': {'label': 'Warm Narrator', 'director': "### DIRECTOR'S NOTES\nStyle:\n* Warm, deep resonance. The voice of a trusted guide.\n* Measured gravitas — never rushed, never monotone. Each ... [truncated]
TTS_MODELS = ['gemini-3.1-flash-tts-preview', 'gemini-2.5-flash-preview-tts', 'gemini-2.5-pro-preview-tts']
MODEL_DISPLAY_NAMES = {'gemini-3.1-flash-tts-preview': 'TTS 3.1 Flash (new)', 'gemini-2.5-flash-preview-tts': 'TTS Flash (fast)', 'gemini-2.5-pro-preview-tts': 'TTS Pro (quality)'}

# --- Class: TTSService ---
class TTSService:
    """Service cho Gemini TTS: text → PCM → WAV"""
    SAMPLE_RATE = 24000
    SAMPLE_WIDTH = 2
    CHANNELS = 1
    ai_provider = <property object at 0x00000264E482F2E0>
    TTS_FALLBACK = {'gemini-3.1-flash-tts-preview': 'gemini-2.5-flash-preview-tts', 'gemini-2.5-flash-preview-tts': 'gemini-2.5-pro-preview...
    FREE_CHUNK_CHARS = 800

    def __init__(self, settings=None):
        pass

    @classmethod
    def model_fallback_chain(cls, model: str, *, enabled: bool = True) -> List[str]:
        pass

    def _generate_tts_with_model_fallback(self, kwargs: Dict, *, allow_model_fallback: bool) -> bytes:
        pass

    def generate_speech(self, text: str, voice_name: str = 'Kore', model: str = 'gemini-2.5-flash-preview-tts', _skip_credit_hooks: bool = False, allow_model_fallback: bool = True, scene: str = '', sample_context: str = '', audio_profile: str = '', director_notes: str = '', **kwargs) -> bytes:
        pass

    def generate_multi_speaker(self, text: str, speakers: List[Dict], model: str = 'gemini-2.5-flash-preview-tts', _skip_credit_hooks: bool = False, allow_model_fallback: bool = True, scene: str = '', sample_context: str = '', audio_profile: str = '', director_notes: str = '', **kwargs) -> bytes:
        pass

    def save_wav(self, pcm_bytes: bytes, output_path: str) -> str:
        pass

    def _generate_tts(self, text: str, voice_name: str, model: str, multi_speaker_config: list = None, director_prefix: str = '', progress_callback=None, voice_consistency: bool = False, chunk_target: int = 0) -> Tuple[bytes, Optional[str]]:
        pass

    @staticmethod
    def resolve_tts_route(tts_route: str = 'auto', provider=None) -> str:
        pass

    def _generate_free_pcm(self, text: str, voice_name: str, model: str, multi_speaker_config: List[Dict] = None, audio_profile: str = '', scene: str = '', sample_context: str = '', director_notes: str = '', progress_callback=None, cancel_checker=None) -> bytes:
        """AI Studio free path → raw PCM, chunking long scripts locally.

        Every chunk carries the same style fields, so the Composer prompt (and
        therefore the voice persona) stays identical across chunks. PCM is raw
        L16 mono 24 kHz, so chunks concatenate byte-wise with no re-encoding."""
        pass

    def generate_and_save(self, text: str, output_path: str, voice_name: str = 'Kore', model: str = 'gemini-2.5-flash-preview-tts', multi_speaker_config: List[Dict] = None, audio_profile: str = '', scene: str = '', sample_context: str = '', director_notes: str = '', progress_callback=None, cancel_checker=None, tts_provider: str = 'gemini', tts_route: str = 'auto', engine_voice: str = '', engine_style: str = '', engine_ref_audio: str = '', engine_url: str = '', engine_options: Optional[Dict] = None, **_legacy_kwargs) -> Tuple[str, Optional[str]]:
        """Generate Gemini TTS (or server-tts) and save WAV.

        MiniMax / ElevenLabs / Local TTS providers have been removed.

        Two fully separate routes, picked by ``tts_route``:

        ``"aistudio"`` — free path. Goes through ``generate_speech`` /
          ``generate_multi_speaker`` → ``ai_provider.generate_tts``, which
          ``_AiStudioRouter`` sends to the AI Studio DirectProvider. Keeps
          audio_profile / scene / sample_context / director_notes STRUCTURED so
          ``tts_api.build_prompt`` renders the real Composer prompt. Chunks long
          scripts locally and concatenates PCM. Returns no ``file_uri`` (nothing
          is uploaded to the Files API).

        ``"gateway"`` — paid path. Unchanged: ``submit_job("tts_long")`` with
          server-side chunking, R2/base64 delivery and a ``file_uri``. Style
          fields are flattened into ``director_prefix``.

        ``"auto"`` (default) — follow the app-wide axis via
          ``ai_providers.is_aistudio_route()``, i.e. the same ``aistudio_web`` /
          ``api_mode`` / account-availability decision every other feature uses."""
        pass

    @staticmethod
    def get_available_voices() -> List[Dict]:
        pass

    @staticmethod
    def get_available_models() -> List[str]:
        pass

    @staticmethod
    def get_voice_presets() -> Dict:
        pass

    @staticmethod
    def get_voice_director(voice_name: str) -> str:
        pass

    @staticmethod
    def get_preset(preset_key: str) -> Optional[Dict]:
        pass


# --- Top-Level Functions ---
def normalize_gemini_audio_tags(text: str) -> str:
    pass

def is_tts_quota_error(error: BaseException) -> bool:
    """True when the exhausted Gemini TTS model chain ended on quota/rate limit."""
    pass

def is_tts_missing_audio_error(error: BaseException) -> bool:
    pass

def split_for_tts(text: str, budget: int) -> List[str]:
    pass
