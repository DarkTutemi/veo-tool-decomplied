"""
Decompiled / Reconstructed Module: services.shared.narration.__init__
Source PyC: __init__.pyc

Docstring:
Narration timeline backend — Phase 1 of ``docs/NARRATOR_TIMELINE_SPEC.md``.

Tab-agnostic engine (like ``AutoMergeService`` / ``MasterVoiceController``): takes
a scene list + a voice config, returns a narration track + a timeline. It must not
know whether the scenes came from a master script or a cloned video.

Core principle (the whole design rests on it):

    Nobody estimates time. Time is either MEASURED (from real audio) or FIXED
    (clip grid). The LLM only owns words, order, and meaning.

Pipeline:  collect script → TTS one take → transcribe → forced-align (QA gate,
per-chunk regen) → energy-verified cut plan → sample-exact track + timeline → SRT.

Entry point: ``narration_service.build_narration_timeline``.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
AUDIO_MODE_AMBIENT = 'ambient'
AUDIO_MODE_DIALOGUE = 'dialogue'
AUDIO_MODE_NARRATION = 'narration'
