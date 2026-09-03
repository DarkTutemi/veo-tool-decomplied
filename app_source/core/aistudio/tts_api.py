"""
Decompiled / Reconstructed Module: core.aistudio.tts_api
Source PyC: tts_api.pyc

Docstring:
AI Studio free-path TTS — standardized API surface.

Wire verified live Playwright 2026-07-11 on
https://aistudio.google.com/generate-speech?model=gemini-3.1-flash-tts-preview

Modes
-----
1. **Single speaker** — one prebuilt voice; transcript + optional style sections.
2. **Multi speaker** — max 2 speakers; dialogue lines ``Name: text`` in transcript;
   speech_config maps each speaker alias → prebuilt voice.
3. **Audio tags** — inline ``[laughs]``, ``[whispers]``, … inside transcript lines
   (prefer English tags even for non-English speech).
4. **Director prompt** — Scene / Sample Context / Audio Profile / Director Notes
   as markdown sections **before** ``## Transcript:``.

Envelope (MakerSuite GenerateContent, compact TTS):
  [model, contents, safety=null, genConfig, snapshot]
genConfig:
  [4]=temp 1, [5]=top_p 0.95, [6]=top_k 64,
  [14]=[3] AUDIO,
  [15]= single [[[Voice]]] | multi [null,null,[null,[[name,[[Voice]]],...]]]
Response: audio/L16; rate=24000; channels=1  (raw PCM, not WAV)

Limits (docs + playground practice)
-----------------------------------
- Speakers: 1 or 2 only
- Voices: 30 prebuilt names (case-sensitive product IDs)
- Input: text-only; output: audio-only
- Context window ~32k tokens (Gemini API TTS); quality drifts after a few minutes —
  chunk long scripts client-side
- Cloud TTS hard caps (~4k/8k bytes, ~655s) apply to paid Cloud/Vertex, not identical
  to playground free path, but treat long audio as chunked anyway
- Tags: no exhaustive list; English tags recommended for all languages
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Iterable = typing.Iterable
Mapping = typing.Mapping
Optional = typing.Optional
Sequence = typing.Sequence
Union = typing.Union
SAMPLE_RATE_HZ = 24000
SAMPLE_WIDTH = 2
CHANNELS = 1
AUDIO_MIME = 'audio/l16; rate=24000; channels=1'
DEFAULT_MODEL = 'gemini-3.1-flash-tts-preview'
FALLBACK_MODELS = ('gemini-3.1-flash-tts-preview', 'gemini-2.5-flash-preview-tts', 'gemini-2.5-pro-preview-tts')
MAX_SPEAKERS = 2
RECOMMENDED_MAX_CHARS = 12000
RECOMMENDED_MAX_AUDIO_SECONDS = 180
VOICES = ({'name': 'Zephyr', 'style': 'Bright', 'gender': 'F', 'pitch': 'Higher pitch'}, {'name': 'Puck', 'style': 'Upbeat', 'gender': 'M', 'pitch': 'Middle pitch'}, {'name': 'Charon', 'style': 'Informative', ... [truncated]
VOICE_TRAITS = ('Breathy', 'Breezy', 'Bright', 'Casual', 'Clear', 'Easy-going', 'Even', 'Excitable', 'Firm', 'Forward', 'Friendly', 'Gentle', 'Gravelly', 'Informative', 'Knowledgeable', 'Lively', 'Mature', 'Smooth',... [truncated]
VOICE_PITCHES = ('Higher pitch', 'Middle pitch', 'Lower middle pitch', 'Lower pitch')
DIRECTOR_STYLES = ('Vocal Smile', 'Newscaster', 'Whisper', 'Empathetic', 'Promo/Hype', 'Deadpan')
DIRECTOR_PACES = ('Natural', 'Rapid Fire', 'The Drift', 'Staccato')
DIRECTOR_ACCENTS = ('Neutral', 'American (Gen)', 'American (Valley)', 'American (South)', 'British (RP)', 'British (Brixton)', 'Transatlantic', 'Australian')
QUICK_TAGS = ('admiration', 'adoration', 'aggression', 'agitation', 'amusement', 'anger', 'annoyance', 'awe', 'confusion', 'curiosity', 'determination', 'enthusiasm', 'excitement', 'frustration', 'hope', 'interest... [truncated]
BUILTIN_PRESETS = ({'id': 'everyday_assistant', 'name': 'The Everyday Assistant', 'summary': 'A helpful and professional personal assistant.', 'scene': 'A quiet, professional remote workspace.', 'sample_context': 'Stea... [truncated]
_PRESET_BY_ID = {'everyday_assistant': {'id': 'everyday_assistant', 'name': 'The Everyday Assistant', 'summary': 'A helpful and professional personal assistant.', 'scene': 'A quiet, professional remote workspace.', '... [truncated]
VOICE_NAMES = frozenset({'Puck', 'Vindemiatrix', 'Laomedeia', 'Zubenelgenubi', 'Kore', 'Erinome', 'Charon', 'Gacrux', 'Iapetus', 'Sulafat', 'Enceladus', 'Achird', 'Fenrir', 'Algieba', 'Rasalgethi', 'Orus', 'Callirr... [truncated]
_VOICE_BY_LOWER = {'zephyr': 'Zephyr', 'puck': 'Puck', 'charon': 'Charon', 'kore': 'Kore', 'fenrir': 'Fenrir', 'leda': 'Leda', 'orus': 'Orus', 'aoede': 'Aoede', 'callirrhoe': 'Callirrhoe', 'autonoe': 'Autonoe', 'encela... [truncated]
COMMON_AUDIO_TAGS = ('amazed', 'amused', 'bored', 'crying', 'curious', 'excited', 'excitedly', 'gasp', 'giggles', 'laughs', 'mischievously', 'panicked', 'reluctantly', 'sarcastic', 'sarcastically', 'serious', 'shouting',... [truncated]
_TAG_RE = re.compile('\\[([^\\]]{1,80})\\]')
PROMPT_LEAD_IN = "Read the following transcript based on the audio profile and director's note."

# --- Class: Speaker ---
class Speaker:
    """One dialogue participant (multi-speaker, max 2).

    ``name`` must match the label used in the transcript (``Name: line``).
    ``voice`` is a prebuilt voice id (e.g. Zephyr, Puck).

    ``audio_profile`` / ``style`` / ``pace`` / ``accent`` mirror AI Studio's
    per-speaker "Speaker settings" panel and are rendered into the prompt as
    ``For <name>: …`` rows under ``# Audio Profile`` / ``# Director's note``."""
    voice = 'Kore'
    lines = ()
    audio_profile = ''
    style = ''
    pace = ''
    accent = ''

    def normalized_voice(self) -> 'str':
        pass

    def director_note(self) -> 'str':
        pass

    def __init__(self, name: 'str', voice: 'str' = 'Kore', lines: 'tuple[str, ...]' = (), audio_profile: 'str' = '', style: 'str' = '', pace: 'str' = '', accent: 'str' = '') -> None:
        pass

    def __repr__(self):
        pass


# --- Class: TtsRequest ---
class TtsRequest:
    """Canonical free-path TTS request.

    Provide either:
      - ``text`` alone (single speaker, or multi if text already has ``Name:`` lines), or
      - ``speakers`` with ``lines`` (multi) / optional ``text`` override for full transcript."""
    text = ''
    voice = 'Zephyr'
    speakers = None
    scene = ''
    sample_context = ''
    audio_profile = ''
    director_notes = ''
    model = 'gemini-3.1-flash-tts-preview'
    temperature = 1.0
    top_p = 0.95
    top_k = 64
    ensure_speaker_labels = True

    def is_multi(self) -> 'bool':
        pass

    def __init__(self, text: 'str' = '', voice: 'str' = 'Zephyr', speakers: 'Optional[Sequence[Speaker]]' = None, scene: 'str' = '', sample_context: 'str' = '', audio_profile: 'str' = '', director_notes: 'str' = '', model: 'str' = 'gemini-3.1-flash-tts-preview', temperature: 'float' = 1.0, top_p: 'float' = 0.95, top_k: 'int' = 64, ensure_speaker_labels: 'bool' = True) -> None:
        pass

    def __repr__(self):
        pass


# --- Class: TtsLimits ---
class TtsLimits:
    """TtsLimits(max_speakers: 'int' = 2, sample_rate_hz: 'int' = 24000, sample_width: 'int' = 2, channels: 'int' = 1, audio_mime: 'str' = 'audio/l16; rate=24000; channels=1', recommended_max_chars: 'int' = 12000, recommended_max_audio_seconds: 'int' = 180, voices: 'int' = 30, models: 'tuple[str, ...]' = ('gemini-3.1-flash-tts-preview', 'gemini-2.5-flash-preview-tts', 'gemini-2.5-pro-preview-tts'))"""
    max_speakers = 2
    sample_rate_hz = 24000
    sample_width = 2
    channels = 1
    audio_mime = 'audio/l16; rate=24000; channels=1'
    recommended_max_chars = 12000
    recommended_max_audio_seconds = 180
    voices = 30
    models = ('gemini-3.1-flash-tts-preview', 'gemini-2.5-flash-preview-tts', 'gemini-2.5-pro-preview-tts')

    def __init__(self, max_speakers: 'int' = 2, sample_rate_hz: 'int' = 24000, sample_width: 'int' = 2, channels: 'int' = 1, audio_mime: 'str' = 'audio/l16; rate=24000; channels=1', recommended_max_chars: 'int' = 12000, recommended_max_audio_seconds: 'int' = 180, voices: 'int' = 30, models: 'tuple[str, ...]' = ('gemini-3.1-flash-tts-preview', 'gemini-2.5-flash-preview-tts', 'gemini-2.5-pro-preview-tts')) -> None:
        pass

    def __repr__(self):
        pass


# --- Class: TtsResult ---
class TtsResult:
    """TtsResult(pcm: 'bytes', model: 'str', mime: 'str' = 'audio/l16; rate=24000; channels=1', sample_rate: 'int' = 24000, channels: 'int' = 1, sample_width: 'int' = 2, usage: 'Optional[dict]' = None, prompt: 'str' = '', multi: 'bool' = False)"""
    mime = 'audio/l16; rate=24000; channels=1'
    sample_rate = 24000
    channels = 1
    sample_width = 2
    usage = None
    prompt = ''
    multi = False
    duration_seconds = <property object at 0x00000264D96FBC40>

    def __init__(self, pcm: 'bytes', model: 'str', mime: 'str' = 'audio/l16; rate=24000; channels=1', sample_rate: 'int' = 24000, channels: 'int' = 1, sample_width: 'int' = 2, usage: 'Optional[dict]' = None, prompt: 'str' = '', multi: 'bool' = False) -> None:
        pass

    def __repr__(self):
        pass


# --- Class: TtsApiError ---
class TtsApiError(ValueError):
    """Invalid TTS request (client-side)."""
    pass


# --- Top-Level Functions ---
def list_presets() -> 'list[dict[str, Any]]':
    pass

def get_preset(preset_id: 'str') -> 'Optional[dict[str, Any]]':
    pass

def is_known_voice(name: 'str') -> 'bool':
    pass

def normalize_voice(name: 'str', default: 'str' = 'Zephyr') -> 'str':
    pass

def list_voices() -> 'list[dict[str, str]]':
    pass

def extract_audio_tags(text: 'str') -> 'list[str]':
    pass

def strip_audio_tags(text: 'str') -> 'str':
    pass

def build_transcript(text: 'str' = '', speakers: 'Optional[Sequence[Speaker]]' = None, *, ensure_speaker_labels: 'bool' = True) -> 'str':
    """Build the body under ``## Transcript:`` (no header)."""
    pass

def _looks_like_dialogue(text: 'str', names: 'Sequence[str]') -> 'bool':
    pass

def build_director_note(style: 'str' = '', pace: 'str' = '', accent: 'str' = '') -> 'str':
    pass

def _speaker_scoped(sps: 'Sequence[Speaker]', pick) -> 'str':
    pass

def build_prompt(*, transcript: 'str', scene: 'str' = '', sample_context: 'str' = '', audio_profile: 'str' = '', director_notes: 'str' = '', speakers: 'Optional[Sequence[Union[Speaker, Mapping[str, Any]]]]' = None) -> 'str':
    """Compose full user text for GenerateContent (AI Studio speech playground).

    Format verified live against the playground's own "Get code" output
    (2026-07-19). Section order is fixed:

      lead-in → # Audio Profile → # Director's note → ## Scene: →
      ## Sample Context: → ## Transcript:

    Single speaker renders Audio Profile / Director's note as a bare line;
    multi-speaker scopes each row as ``For <speaker name>: …``. Empty sections
    are omitted. Passing ``speakers`` with per-speaker ``audio_profile`` /
    ``style`` / ``pace`` / ``accent`` produces the scoped form; the global
    ``audio_profile`` / ``director_notes`` act as the fallback for speakers
    that define none."""
    pass

def build_prompt_from_request(req: 'TtsRequest') -> 'str':
    pass

def build_speech_config_wire(voice: 'str' = 'Zephyr', speakers: 'Optional[Sequence[Union[Speaker, Mapping[str, Any]]]]' = None) -> 'list':
    pass

def _normalize_speakers(speakers: 'Optional[Sequence[Union[Speaker, Mapping[str, Any]]]]') -> 'list[Speaker]':
    pass

def parse_speakers_config(raw: 'Any') -> 'list[Speaker]':
    pass

def validate_request(req: 'TtsRequest') -> 'None':
    pass

def limits() -> 'TtsLimits':
    pass

def describe_capabilities() -> 'dict[str, Any]':
    pass

def request_from_legacy(text: 'str', voice_name: 'str' = 'Zephyr', multi_speaker_config: 'Optional[Sequence[Mapping[str, Any]]]' = None, *, scene: 'str' = '', sample_context: 'str' = '', audio_profile: 'str' = '', director_notes: 'str' = '', model: 'str' = 'gemini-3.1-flash-tts-preview') -> 'TtsRequest':
    pass
