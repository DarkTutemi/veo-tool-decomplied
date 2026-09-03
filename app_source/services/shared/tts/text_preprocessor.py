"""
Decompiled / Reconstructed Module: services.shared.tts.text_preprocessor
Source PyC: text_preprocessor.pyc

Docstring:
Safe, engine-boundary text preparation for local narration TTS.

The displayed narration/SRT must keep the author's original spelling.  This
module therefore only transforms the copy sent to a TTS engine.  It deliberately
does not split text or call a model: one narration take remains one request.

OmniVoice accepts one language for an utterance and has no native per-word
Vietnamese/English code-switch contract.  A small pronunciation lexicon is the
least destructive workaround: common technical terms can be respelled for the
Vietnamese voice while the source text remains unchanged elsewhere.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
_ZERO_WIDTH_RE = re.compile('[\\u200b\\u200c\\u200d\\u2060\\ufeff]')
_CONTROL_RE = re.compile('[\\x00-\\x08\\x0b\\x0c\\x0e-\\x1f\\x7f]')
_INLINE_OVERRIDE_RE = re.compile('\\[\\[([^\\]]{0,256})\\]\\]')
_VI_CODE_SWITCH_DEFAULTS = {'AI': 'ây ai', 'API': 'ây pi ai', 'CPU': 'xi pi diu', 'GPU': 'gi pi diu', 'UI': 'diu ai', 'URL': 'diu a eo', 'JSON': 'giây sần', 'SRT': 'ét a ti', 'TTS': 'ti ti ét'}
_FALSE_VALUES = {'false', 'disabled', 'off', 'no', '0'}

# --- Top-Level Functions ---
def _truthy(value: 'Any', *, default: 'bool' = True) -> 'bool':
    pass

def _language_prefix(language: 'Any') -> 'str':
    pass

def parse_pronunciation_lexicon(raw: 'Any') -> 'dict[str, str]':
    pass

def _apply_inline_overrides(text: 'str') -> 'str':
    pass

def _apply_lexicon(text: 'str', lexicon: 'Mapping[str, str]') -> 'tuple[str, int]':
    pass

def prepare_local_tts_text(text: 'Any', *, language: 'Any' = '', pronunciation_lexicon: 'Any' = None, auto_pronunciation: 'Any' = True) -> 'tuple[str, dict[str, Any]]':
    pass
