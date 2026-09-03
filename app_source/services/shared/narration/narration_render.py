"""
Decompiled / Reconstructed Module: services.shared.narration.narration_render
Source PyC: narration_render.pyc

Docstring:
Stage B — one-take TTS render (§6.2), chunk-on-paragraph, per-chunk regen.

ONE take for the whole narrator script — never TTS per cue (rejected alt #2:
"nếu tạo lẻ mỗi lần → nó sẽ bị lệch seed + tone giọng"). Long scripts are chunked
LOCALLY on paragraph boundaries with IDENTICAL style fields per chunk, so any
residual tone step lands in a natural pause instead of mid-sentence, and the
alignment QA gate (narration_align) can regenerate exactly one bad chunk.

Audio contract (matches ``TTSService.save_wav``): raw L16 PCM, 24000 Hz, 16-bit,
mono — chunks concatenate byte-wise with no re-encoding. ALL sample math uses 24000.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Callable = typing.Callable
Dict = typing.Dict
List = typing.List
Optional = typing.Optional
Tuple = typing.Tuple
PARAGRAPH_JOIN = '\n\n[pause 0.35s]\n\n'
SAMPLE_RATE = 24000
SAMPLE_WIDTH = 2
CHANNELS = 1
DEFAULT_CHUNK_CHARS = 600
SINGLE_REQUEST_SAFE_CHARS = 600
DEFAULT_TTS_MODEL = 'gemini-2.5-flash-preview-tts'
DEFAULT_NARRATION_PROVIDER_PAUSE_CAP_SECONDS = 0.35
VERBATIM_NOTE = 'Read the text EXACTLY as written, word for word, in its original language(s). Never translate, paraphrase, summarize, skip, or add anything. Square-bracket tags such as [pause 0.35s] are silent deliv... [truncated]
ONE_VOICE_NOTE = 'Perform the ENTIRE text as ONE narrator with ONE voice: the same speaker identity, pitch range, age and gender from the first word to the last. Quoted, reported or imagined speech — what someone says... [truncated]
NARRATION_AUDIO_PROFILE = 'Solo studio voiceover: one narrator at a constant microphone distance, consistent loudness and tone from start to finish. Keep sentences connected and conversational: ordinary punctuation gets only a... [truncated]
_LANG_LABELS = {'vi': 'Vietnamese', 'en': 'English', 'th': 'Thai', 'id': 'Indonesian', 'hi': 'Hindi', 'ar': 'Arabic', 'pt': 'Portuguese', 'ru': 'Russian', 'es': 'Spanish', 'fr': 'French', 'de': 'German', 'ja': 'Japa... [truncated]
_ACCENT_HINTS = {'vi': 'Northern Vietnamese (Hà Nội), standard broadcast', 'en': 'American (Gen)', 'pt': 'Brazilian Portuguese', 'zh': 'Standard Mandarin (Putonghua)'}
_DEFAULT_PACE = 'Natural'
_SPEECH_CHARS_PER_SECOND = 16.0
_MIN_DURATION_RATIO = 0.5
_CHUNK_RENDER_RETRIES = 2
_LEVEL_SPEECH_FLOOR = 800.0
_LEVEL_WINDOW_S = 0.05
_LEVEL_MAX_WINDOWS = 400
_LEVEL_MIN_GAIN = 0.5
_LEVEL_MAX_GAIN = 2.0
_LEVEL_PEAK_CEILING = 32000
_LEVEL_DEADBAND = 0.02

# --- Class: RenderChunk ---
class RenderChunk:
    """RenderChunk(index: 'int', paragraph_indices: 'List[int]', text: 'str', pcm: 'bytes' = b'', spoken_text: 'str' = '')"""
    pcm = b''
    spoken_text = ''
    samples = <property object at 0x00000264E41BFE70>

    def __init__(self, index: 'int', paragraph_indices: 'List[int]', text: 'str', pcm: 'bytes' = b'', spoken_text: 'str' = '') -> None:
        pass

    def __repr__(self):
        pass


# --- Class: RenderedTake ---
class RenderedTake:
    """RenderedTake(wav_path: 'str', voice_name: 'str', model: 'str', route: 'str', chunks: 'List[RenderChunk]', style_kwargs: 'Dict[str, str]' = <factory>, sample_rate: 'int' = 24000, render_strategy: 'str' = 'chunked', voice_state: 'Dict[str, Any]' = <factory>, max_pause_seconds: 'float' = 0.0)"""
    sample_rate = 24000
    render_strategy = 'chunked'
    max_pause_seconds = 0.0
    pcm = <property object at 0x00000264E41DD760>
    total_samples = <property object at 0x00000264E41DD6C0>
    duration_s = <property object at 0x00000264E41DC6D0>

    def __init__(self, wav_path: 'str', voice_name: 'str', model: 'str', route: 'str', chunks: 'List[RenderChunk]', style_kwargs: 'Dict[str, str]' = <factory>, sample_rate: 'int' = 24000, render_strategy: 'str' = 'chunked', voice_state: 'Dict[str, Any]' = <factory>, max_pause_seconds: 'float' = 0.0) -> None:
        pass

    def __repr__(self):
        pass


# --- Top-Level Functions ---
def _voice_profile(voice_name: 'str') -> 'Dict[str, str]':
    pass

def _casting_intent(profile: 'Dict[str, Any]') -> 'Dict[str, str]':
    pass

def _identity_profile(profile: 'Dict[str, Any]', language: 'str') -> 'str':
    """The '# Audio Profile' section: WHO is speaking, stated concretely.
    Persona only — delivery (style/pace/accent) belongs to the Director's-note
    axes (`_direction_note`), mirroring AI Studio's own Speaker settings split."""
    pass

def _direction_note(profile: 'Dict[str, Any]', language: 'str', direction: 'Optional[Dict[str, str]]' = None) -> 'str':
    pass

def write_wav(path: 'str', pcm: 'bytes', sample_rate: 'int' = 24000) -> 'str':
    pass

def read_wav_pcm(path: 'str') -> 'Tuple[bytes, int]':
    pass

def plan_chunks(script: 'NarrationScript', budget: 'int' = 600) -> 'List[RenderChunk]':
    pass

def _resolve_route(tts: 'Any', tts_route: 'str') -> 'str':
    pass

def _hardware_fallback_route(route: 'str') -> 'str':
    pass

def _local_fallback_engine_id(error: 'BaseException') -> 'str':
    pass

def _whole_voice_on_local_engine(engine_id: 'str', script: 'NarrationScript', **kwargs: 'Any') -> 'RenderedTake':
    pass

def _emotion_director_notes(emotion: 'str') -> 'str':
    pass

def _fallback_model(model: 'str') -> 'str':
    pass

def _render_chunk_pcm(tts: 'Any', chunk: "'RenderChunk'", voice_name: 'str', model: 'str', style_kwargs: 'Dict[str, str]') -> 'bytes':
    pass

def _speech_level(pcm: 'bytes', sample_rate: 'int' = 24000) -> 'float':
    pass

def _peak_abs(pcm: 'bytes') -> 'int':
    pass

def _apply_gain(pcm: 'bytes', gain: 'float') -> 'bytes':
    pass

def compact_long_narration_silences(pcm: 'bytes', sample_rate: 'int' = 24000, max_pause_seconds: 'float' = 0.0) -> 'bytes':
    pass

def _median(values: 'List[float]') -> 'float':
    pass

def match_chunk_levels(chunks: 'List[RenderChunk]', sample_rate: 'int' = 24000, only: 'Optional[set]' = None) -> 'List[RenderChunk]':
    pass

def _voice_state() -> 'Dict[str, Any]':
    pass

def _voice_state_model(state: 'Optional[Dict[str, Any]]' = None) -> 'str':
    pass

def _engine_generate_kwargs(route: 'str', state: 'Dict[str, Any]', *, language: 'str' = '') -> 'Dict[str, Any]':
    pass

def render_take(script: 'NarrationScript', *, output_path: 'str', voice_name: 'str', model: 'str' = '', tts: 'Any' = None, tts_route: 'str' = 'auto', language: 'str' = '', direction: 'Optional[Dict[str, str]]' = None, casting_intent: 'Optional[Dict[str, str]]' = None, director_notes: 'str' = '', audio_profile: 'str' = '', scene_hint: 'str' = '', sample_context: 'str' = '', chunk_budget: 'int' = 600, single_request: 'bool' = False, max_pause_seconds: 'float' = 0.0, voice_state: 'Optional[Dict[str, Any]]' = None, progress_callback: 'Optional[Callable]' = None, cancel_checker: 'Optional[Callable[[], bool]]' = None) -> 'RenderedTake':
    """Render the whole narrator script as ONE take → ``RenderedTake``.

    v1 = one style per take (§4.4): ``director_notes`` comes from the take-level
    emotion via ``emotion_provider_options`` unless the caller passes its own.

    Routes (both acceptable per spec §6.2):
      - "aistudio": per-chunk ``generate_speech`` with IDENTICAL style fields,
        PCM concatenated byte-wise. Keeps per-chunk PCM → per-chunk regen works.
      - "gateway": one ``generate_and_save`` (``tts_long``, voice_consistency,
        server-side chunking). Single chunk record → regen granularity = whole take.

    ``single_request=True`` is for audio-first routes such as clone-image where
    cross-request voice drift is worse than losing per-chunk regeneration. The
    complete script is sent to AI Studio once when it fits the measured safe
    one-shot budget. Known-long scripts are preflighted straight to paragraph
    chunks so no doomed one-minute head is generated. If a safe-sized one-shot
    is unexpectedly truncated, its incomplete PCM is discarded and the WHOLE
    script is rendered again in chunks with the exact same identity/style fields."""
    pass

def rerender_chunks(take: 'RenderedTake', chunk_indices: 'List[int]', *, script: 'NarrationScript', tts: 'Any' = None, progress_callback: 'Optional[Callable]' = None, cancel_checker: 'Optional[Callable[[], bool]]' = None) -> 'RenderedTake':
    pass
