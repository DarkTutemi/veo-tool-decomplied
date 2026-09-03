"""
Decompiled / Reconstructed Module: services.prompts.narrative_comprehension
Source PyC: narrative_comprehension.pyc

Docstring:
Shared "understand the whole, then interpret" brain for audio→video tabs.

The recurring failure this fixes: the system used to tell the model to walk the
audio window-by-window and NOT look ahead, so it turned narration into literal
pictures — "hello everyone, today I'll tell a family story" became a person
waving, silences went blank, and lead-ins/sign-offs got drawn word-for-word.
That is not the model being dumb; it was never taught the CONTEXT — only fed a
rule that forces documentary-style literalism.

This block teaches the opposite as a way of REASONING (never a topic list):
1) grasp the whole first, then let every image serve what the audio MEANS and
   where it is GOING;
2) place each moment on three axes (word↔image, tempo, continuity) and let that —
   not a memorised genre table — decide the visual, so it covers ANY audio.

It is deliberately theme-agnostic — the few examples are labelled as demonstrations
of the reasoning, not rules about any subject.

Single source of truth: the transcript single-pass prompt, the block-gen base
prompt, and the Pass-0 global-map prompt all pull THIS brain, and the mechanics
guides (per-window map fields, visualization types) defer to it rather than
repeating a conflicting "one window at a time / literal" instruction.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)

# --- Top-Level Functions ---
def build_narrative_comprehension_block(source: 'str' = 'transcript') -> 'str':
    pass
