"""
Decompiled / Reconstructed Module: core.labs_api.capability
Source PyC: capability.pyc

Docstring:
core/labs_api/capability.py — generation capability gate.

Single source of truth for WHAT each generation type requires and WHICH models can
serve it, so the call-logic never drives the Flow UI (or builds a payload) with an
unsupported combo.

Why this exists (verified live against labs.google 2026-06-11): the Flow prompt box
maps {mode + frame/reference ingredients} → a specific ``batchAsyncGenerateVideo*``
endpoint, but the END frame is only honoured by an FL ("first+last") model. Driving
``VIDEO_FRAMES`` with FIRST_FRAME+LAST_FRAME on a non-FL model (e.g. ``abra_i2v``)
silently DROPS the end frame → wrong output. The capability DATA already lives in
``ModelConfig`` (``video_models.json``): every model entry carries ``type``
(text_to_video / image_to_video / ...) and ``variant`` (``'fl'`` = interpolation).
This module maps generation intent → those requirements + the Flow mode / ingredient
types / videoApi, and repairs an out-of-spec model choice.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['GenerationCapability', 'get_capability', 'ensure_capable_model', 'model_is_fl', 'tier_mode_from_paygate', 'FLOW_MODE_REFERENCES', 'FLOW_MODE_FRAMES', 'INGREDIENT_FIRST_FRAME', 'INGREDIENT_LAST_FRAME', 'INGREDIENT_REFERENCE']

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Optional = typing.Optional
FLOW_MODE_REFERENCES = 'VIDEO_REFERENCES'
FLOW_MODE_FRAMES = 'VIDEO_FRAMES'
INGREDIENT_FIRST_FRAME = 'FIRST_FRAME'
INGREDIENT_LAST_FRAME = 'LAST_FRAME'
INGREDIENT_REFERENCE = 'REFERENCE'
_SPECS = {'text_to_video': GenerationCapability(gen_type='text_to_video', flow_mode='VIDEO_REFERENCES', video_api='batchAsyncGenerateVideoText', model_variant=None, repair_default_type='text_to_video'), 'image... [truncated]
__all__ = ['GenerationCapability', 'get_capability', 'ensure_capable_model', 'model_is_fl', 'tier_mode_from_paygate', 'FLOW_MODE_REFERENCES', 'FLOW_MODE_FRAMES', 'INGREDIENT_FIRST_FRAME', 'INGREDIENT_LAST_FRAME... [truncated]

# --- Class: GenerationCapability ---
class GenerationCapability:
    """What a generation intent needs from the Flow UI + the model catalog."""
    def __init__(self, gen_type: 'str', flow_mode: 'str', video_api: 'str', model_variant: 'Optional[str]', repair_default_type: 'str') -> None:
        pass

    def __repr__(self):
        pass


# --- Top-Level Functions ---
def get_capability(gen_type: 'str') -> 'Optional[GenerationCapability]':
    pass

def model_is_fl(model_key: 'str') -> 'bool':
    pass

def ensure_capable_model(gen_type: 'str', model_key: 'str', tier_mode: 'str' = 'ultra') -> 'str':
    pass

def tier_mode_from_paygate(user_tier: 'str') -> 'str':
    pass
