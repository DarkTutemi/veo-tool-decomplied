"""
Decompiled / Reconstructed Module: services.shared.composition.learning_reading
Source PyC: learning_reading.pyc

Docstring:
Offline target-language reading helpers for language-learning overlays.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['english_ipa', 'generate_learning_reading', 'is_known_english_term']

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
_ENGLISH_IPA_FALLBACKS = {'blow': 'bloʊ', 'carrot': 'ˈkærət', 'crosswalk': 'ˈkrɑsˌwɑk', 'danger': 'ˈdeɪnʤər', 'green light': 'grin laɪt', 'helmet': 'ˈhɛlmət', 'high five': 'haɪ faɪv', 'hot': 'hɑt', 'look left': 'lʊk lɛft', 'l... [truncated]
english_ipa = <functools._lru_cache_wrapper object at 0x00000264E15F5380>
is_known_english_term = <functools._lru_cache_wrapper object at 0x00000264E15F5430>
__all__ = ['english_ipa', 'generate_learning_reading', 'is_known_english_term']

# --- Top-Level Functions ---
def _text(value: 'Any') -> 'str':
    pass

def _english_key(value: 'Any') -> 'str':
    pass

def generate_learning_reading(lemma: 'Any', *, learning_language: 'Any', reading_system: 'Any') -> 'str':
    pass
