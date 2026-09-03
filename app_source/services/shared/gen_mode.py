"""
Decompiled / Reconstructed Module: services.shared.gen_mode
Source PyC: gen_mode.pyc

Docstring:
services/shared/gen_mode.py — Single Source of Truth cho 3-state sinh video.

Hai toggle UI quyết định mode sinh video:
  * ``char_consistency`` (đồng bộ nhân vật)
  * ``voice_lock``        (đồng bộ giọng nói)

Ba trạng thái:
  * char OFF                       -> T2V (text-to-video, không nhân vật)
  * char ON, voice OFF             -> R2V (referenceImages — ảnh nhân vật)
  * char ON, voice ON (+model OK)  -> R2V_VOICE (referenceEntities — ảnh + giọng)

Module THUẦN: không I/O, không trạng thái. Chỉ (1) quyết định mode và (2) gắn
đúng key vào ``prompt_dict``; router cuối ``core/dispatch/classifier.py`` route
dựa trên các key đó (``character_metadata`` -> R2V_CHARACTER,
``flow_character_specs`` -> R2V entity). Mọi tab (clone/master/transcript/normal)
gọi chung 2 hàm này thay vì tự quyết.

Xem docs/VIDEO_GEN_MODE_SOT.md.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Callable = typing.Callable
Dict = typing.Dict
Optional = typing.Optional
Tuple = typing.Tuple

# --- Class: GenMode ---
class GenMode(str, Enum):
    _use_args_ = True
    _member_names_ = ['T2V', 'R2V', 'R2V_VOICE']
    _member_map_ = {'T2V': <GenMode.T2V: 't2v'>, 'R2V': <GenMode.R2V: 'r2v'>, 'R2V_VOICE': <GenMode.R2V_VOICE: 'r2v_voice'>}
    _value2member_map_ = {'t2v': <GenMode.T2V: 't2v'>, 'r2v': <GenMode.R2V: 'r2v'>, 'r2v_voice': <GenMode.R2V_VOICE: 'r2v_voice'>}
    _unhashable_values_ = []
    T2V = <GenMode.T2V: 't2v'>
    R2V = <GenMode.R2V: 'r2v'>
    R2V_VOICE = <GenMode.R2V_VOICE: 'r2v_voice'>

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
        """str(object='') -> str
str(bytes_or_buffer[, encoding[, errors]]) -> str

Create a new string object from the given object. If encoding or
errors is specified, then the object must expose a data buffer
that will be decoded using the given encoding and error handler.
Otherwise, returns the result of object.__str__() (if defined)
or repr(object).
encoding defaults to sys.getdefaultencoding().
errors defaults to 'strict'."""
        pass

    def _value_repr_(self, /):
        """Return repr(self)."""
        pass

    def __repr__(self):
        pass

    def __str__(self):
        pass


# --- Top-Level Functions ---
def resolve_video_gen_mode(*, char_consistency: 'bool', voice_lock: 'bool', model_key: 'str', aspect_ratio: 'str' = '', clip_duration_seconds: 'Optional[int]' = None) -> 'Tuple[GenMode, str]':
    pass

def attach_char_refs(prompt_dict: 'Dict[str, Any]', *, mode: 'GenMode', scene_character_metadata: 'Dict[str, Any]', flow_specs_builder: 'Optional[Callable[[], list]]' = None) -> 'GenMode':
    pass
