"""
Decompiled / Reconstructed Module: core.aistudio.direct.wire
Source PyC: wire.pyc

Docstring:
core/aistudio/direct/wire.py — AI Studio wire (protobuf-JSON positional) codec.

Pure data logic — no browser. Builds the GenerateContent request body and parses
the streamed response. All positions verified live 2026-07-09; see
docs/AISTUDIO_DIRECT_API_DESIGN.md.

Envelope (top-level array):
  [0]  model            "models/<name>"
  [1]  contents         [[[part,...], role], ...]
  [2]  safety_settings  [[null,null,cat,thr], ...]
  [3]  generation_config (positional, see GenerationConfig)
  [4]  snapshot         "!<botguard token>"  (injected by gateway per request)
  [5]  system_instruction  [[[null,text]], "user"] or null
  [6]  tools            or null
  [10] request_flag     1
  [13] timezone         [[null,null,"<tz>"]]  (mainly when tools present)
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Optional = typing.Optional
MODEL_INDEX = 0
CONTENTS_INDEX = 1
SAFETY_INDEX = 2
GEN_CONFIG_INDEX = 3
SNAPSHOT_INDEX = 4
SYSTEM_INSTRUCTION_INDEX = 5
TOOLS_INDEX = 6
REQUEST_FLAG_INDEX = 10
TIMEZONE_INDEX = 13
SAFETY_CATEGORIES = (7, 8, 9, 10)
SAFETY_BLOCK_NONE = 5
TOOL_GOOGLE_SEARCH = [None, None, None, [None, [[]]]]
_SCHEMA_TYPE = {'string': 1, 'number': 2, 'integer': 3, 'boolean': 4, 'array': 5, 'object': 6}
RESPONSE_MODALITY_AUDIO = 3

# --- Class: ThinkingLevel ---
class ThinkingLevel(IntEnum):
    _use_args_ = True
    _member_names_ = ['LOW', 'MEDIUM', 'HIGH', 'MINIMAL']
    _member_map_ = {'LOW': <ThinkingLevel.LOW: 1>, 'MEDIUM': <ThinkingLevel.MEDIUM: 2>, 'HIGH': <ThinkingLevel.HIGH: 3>, 'MINIMAL': <Thinki...
    _value2member_map_ = {1: <ThinkingLevel.LOW: 1>, 2: <ThinkingLevel.MEDIUM: 2>, 3: <ThinkingLevel.HIGH: 3>, 4: <ThinkingLevel.MINIMAL: 4>}
    _unhashable_values_ = []
    LOW = <ThinkingLevel.LOW: 1>
    MEDIUM = <ThinkingLevel.MEDIUM: 2>
    HIGH = <ThinkingLevel.HIGH: 3>
    MINIMAL = <ThinkingLevel.MINIMAL: 4>

    @staticmethod
    def _generate_next_value_(name, start, count, last_values):
        """Generate the next value when not given.

        name: the name of the member
        start: the initial start value or None
        count: the number of existing members
        last_values: the list of values assigned"""
        pass

    def _new_member_(*args, **kwargs):
        """Create and return a new object.  See help(type) for accurate signature."""
        pass

    def _member_type_(*args, **kwargs):
        """int([x]) -> integer
int(x, base=10) -> integer

Convert a number or string to an integer, or return 0 if no arguments
are given.  If x is a number, return x.__int__().  For floating-point
numbers, this truncates towards zero.

If x is not a number or if base is given, then x must be a string,
bytes, or bytearray instance representing an integer literal in the
given base.  The literal can be preceded by '+' or '-' and be surrounded
by whitespace.  The base defaults to 10.  Valid bases are 0 and 2-36.
Base 0 means to interpret the base from the string as an integer literal.
>>> int('0b100', base=0)
4"""
        pass

    def _value_repr_(self, /):
        """Return repr(self)."""
        pass


# --- Class: MediaResolution ---
class MediaResolution(IntEnum):
    _use_args_ = True
    _member_names_ = ['LOW', 'MEDIUM', 'HIGH']
    _member_map_ = {'LOW': <MediaResolution.LOW: 1>, 'MEDIUM': <MediaResolution.MEDIUM: 2>, 'HIGH': <MediaResolution.HIGH: 3>}
    _value2member_map_ = {1: <MediaResolution.LOW: 1>, 2: <MediaResolution.MEDIUM: 2>, 3: <MediaResolution.HIGH: 3>}
    _unhashable_values_ = []
    LOW = <MediaResolution.LOW: 1>
    MEDIUM = <MediaResolution.MEDIUM: 2>
    HIGH = <MediaResolution.HIGH: 3>

    @staticmethod
    def _generate_next_value_(name, start, count, last_values):
        """Generate the next value when not given.

        name: the name of the member
        start: the initial start value or None
        count: the number of existing members
        last_values: the list of values assigned"""
        pass

    def _new_member_(*args, **kwargs):
        """Create and return a new object.  See help(type) for accurate signature."""
        pass

    def _member_type_(*args, **kwargs):
        """int([x]) -> integer
int(x, base=10) -> integer

Convert a number or string to an integer, or return 0 if no arguments
are given.  If x is a number, return x.__int__().  For floating-point
numbers, this truncates towards zero.

If x is not a number or if base is given, then x must be a string,
bytes, or bytearray instance representing an integer literal in the
given base.  The literal can be preceded by '+' or '-' and be surrounded
by whitespace.  The base defaults to 10.  Valid bases are 0 and 2-36.
Base 0 means to interpret the base from the string as an integer literal.
>>> int('0b100', base=0)
4"""
        pass

    def _value_repr_(self, /):
        """Return repr(self)."""
        pass


# --- Class: Part ---
class Part:
    """A single content part. Exactly one kind is populated."""
    text = None
    inline_data = None
    file_id = None
    file_uri = None
    start_offset = None
    end_offset = None
    fps = None
    thought = False
    thought_signature = None

    def hash_repr(self) -> 'str':
        pass

    def _attach_video_meta(self, part: 'list') -> 'None':
        pass

    def to_wire(self) -> 'list':
        pass

    def __init__(self, text: 'Optional[str]' = None, inline_data: 'Optional[tuple[str, str]]' = None, file_id: 'Optional[str]' = None, file_uri: 'Optional[tuple[str, str]]' = None, start_offset: 'Optional[int]' = None, end_offset: 'Optional[int]' = None, fps: 'Optional[int]' = None, thought: 'bool' = False, thought_signature: 'Optional[str]' = None) -> None:
        pass

    def __repr__(self):
        pass


# --- Class: Content ---
class Content:
    """Content(role: 'str', parts: 'list[Part]')"""
    def to_wire(self) -> 'list':
        pass

    def __init__(self, role: 'str', parts: 'list[Part]') -> None:
        pass

    def __repr__(self):
        pass


# --- Class: GenerationConfig ---
class GenerationConfig:
    """All the "gateway knobs". None = omit (leave server default)."""
    max_output_tokens = 65536
    temperature = None
    top_p = None
    top_k = None
    stop_sequences = None
    response_mime_type = None
    response_schema = None
    presence_penalty = None
    frequency_penalty = None
    thinking_config = None
    media_resolution = None
    response_modalities = None
    speech_config = None

    def configure_thinking(self, *, enabled: 'bool', style: 'str' = 'none', budget: 'Optional[int]' = None, level: 'ThinkingLevel' = <ThinkingLevel.HIGH: 3>) -> 'None':
        pass

    def configure_tts(self, voice_name: 'str' = 'Zephyr', *, multi_speaker: 'Optional[list]' = None, temperature: 'float' = 1.0, top_p: 'float' = 0.95, top_k: 'int' = 64) -> 'None':
        pass

    def to_wire(self) -> 'list':
        pass

    def __init__(self, max_output_tokens: 'Optional[int]' = 65536, temperature: 'Optional[float]' = None, top_p: 'Optional[float]' = None, top_k: 'Optional[int]' = None, stop_sequences: 'Optional[list[str]]' = None, response_mime_type: 'Optional[str]' = None, response_schema: 'Optional[Any]' = None, presence_penalty: 'Optional[float]' = None, frequency_penalty: 'Optional[float]' = None, thinking_config: 'Optional[list]' = None, media_resolution: 'Optional[int]' = None, response_modalities: 'Optional[list]' = None, speech_config: 'Optional[Any]' = None) -> None:
        pass

    def __repr__(self):
        pass


# --- Class: ModelRules ---
class ModelRules:
    """ModelRules(thinking_style: 'str' = 'none', default_tools: 'tuple[str, ...]' = (), is_image_model: 'bool' = False, disable_safety: 'bool' = False, compact_envelope: 'bool' = False)"""
    thinking_style = 'none'
    default_tools = ()
    is_image_model = False
    disable_safety = False
    compact_envelope = False

    def __init__(self, thinking_style: 'str' = 'none', default_tools: 'tuple[str, ...]' = (), is_image_model: 'bool' = False, disable_safety: 'bool' = False, compact_envelope: 'bool' = False) -> None:
        pass

    def __repr__(self):
        pass


# --- Class: WireCodec ---
class WireCodec:
    """Build request bodies and parse responses."""
    @staticmethod
    def build_body(*, model: 'str', contents: 'list[Content]', gen_config: 'GenerationConfig', system_instruction: 'Optional[str]' = None, tools: 'Optional[list]' = None, snapshot: 'Optional[str]' = None, timezone: 'str' = 'Asia/Bangkok') -> 'list':
        pass

    @staticmethod
    def content_hash_input(contents: 'list[Content]') -> 'str':
        pass

    @staticmethod
    def parse_answer(raw: 'str') -> 'str':
        pass

    @staticmethod
    def parse_audio(raw: 'str') -> 'bytes':
        pass

    @staticmethod
    def parse_images(raw: 'str') -> 'list[tuple[str, bytes]]':
        pass

    @staticmethod
    def parse_usage(raw: 'str') -> 'Optional[dict]':
        pass

    @staticmethod
    def parse_error(raw: 'str') -> 'Optional[tuple[int, str]]':
        pass


# --- Top-Level Functions ---
def encode_schema(js: 'Any') -> 'list':
    pass

def resolve_model_rules(model: 'str') -> 'ModelRules':
    pass

def _loads_sparse(raw: 'str') -> 'Any':
    pass

def _collect(data: 'Any', out: 'list[str]') -> 'None':
    pass

def _grow(arr: 'list', size: 'int') -> 'None':
    pass
