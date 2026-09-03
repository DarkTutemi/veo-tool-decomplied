"""
Decompiled / Reconstructed Module: services.prompts.scene_director
Source PyC: scene_director.pyc

Docstring:
Scene-director prompt blocks — shared director knowledge injected into the
script-generation prompt (NOT a runtime stage).

These are PROMPT TEXT fragments only. They teach the script-generating AI how to
direct scenes: anti-hallucination scene-writing rules, cinematography/shot
language, and the character-consistency routing contract (R2V vs T2V). The actual
reference-image generation (chargen) and the dispatch routing happen elsewhere —
this module just shapes how the AI writes the script.

Imported by the per-tab prompt assemblers:
  master    -> services/video_pipeline/scene_prompt_builder.py (PromptBuilderV5)
  clone     -> services/tabs/clone_video/youtube_clone_service.py
  transcript-> services/tabs/transcript_video/transcript_analyzer_service.py

(Renamed from the old ``services/video_core/pipeline_brain.py`` — the "brain" name
read like a pipeline stage when it is only prompt text.)
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
SCENE_WRITING_RULES = '## SCENE WRITING RULES — Preventing Video Hallucination\n\nVideo models generate each frame by predicting from text. They do NOT maintain a persistent world.\nIf the prompt is vague, overloaded, or c... [truncated]
_CINEMATOGRAPHY_CORE = '## CINEMATOGRAPHY GUIDE — Visual Storytelling Through Camera\n\nYou are the Director of Photography. The camera is your language.\nEvery shot choice tells the audience WHERE to look, WHAT matters, an... [truncated]
_CINEMATOGRAPHY_CLONE_ADDON = "### CLONE MODE — Camera Enhancement\n\nYou are recreating video from an existing source. Your camera work should ELEVATE the original:\n\n**ANALYZE THE SOURCE FIRST:**\n  - What shot sizes does the o... [truncated]
_CHAR_CONSISTENCY_PROMPT = "# CHARACTER CONSISTENCY — Routing Contract\n\nEach scene dispatches a real video job. Character reference images are active.\n\n| Mode | Detection | Result |\n|------|-----------|--------|\n| **R2V**... [truncated]

# --- Top-Level Functions ---
def get_scene_writing_rules(include_anchor_policy: bool = True) -> str:
    pass

def get_cinematography_guide(clone_mode: bool = False) -> str:
    pass

def get_char_consistency_prompt(char_consistency: bool) -> str:
    pass
