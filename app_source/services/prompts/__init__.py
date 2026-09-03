"""
Decompiled / Reconstructed Module: services.prompts.__init__
Source PyC: __init__.pyc

Docstring:
Shared model-facing prompt blocks — one home for reusable prompt TEXT.

Pure prompt fragments only (no generation logic). The per-tab assemblers
(scene_prompt_builder / youtube_clone_service / transcript_analyzer_service) and
the resource/architect prompts import these blocks and stitch them together.

Modules:
  scene_director  — anti-hallucination scene-writing rules, cinematography guide,
                    character-consistency routing prompt (was ``pipeline_brain``).
  anchor_policy   — anchor selection input-contract prompt block.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['ANCHOR_POLICY_PROMPT_BLOCK', 'SCENE_WRITING_RULES', 'anchor_policy_prompt_block', 'get_char_consistency_prompt', 'get_cinematography_guide', 'get_scene_writing_rules']

# --- Module Constants & Globals ---
ANCHOR_POLICY_PROMPT_BLOCK = '## Anchor Consistency Policy - Input Contract\n\nAn anchor is NOT a label, and it is NOT a measure of how "important" or how "often-seen" an entity is. An anchor means the backend generates ONE reusa... [truncated]
SCENE_WRITING_RULES = '## SCENE WRITING RULES — Preventing Video Hallucination\n\nVideo models generate each frame by predicting from text. They do NOT maintain a persistent world.\nIf the prompt is vague, overloaded, or c... [truncated]
__all__ = ['ANCHOR_POLICY_PROMPT_BLOCK', 'SCENE_WRITING_RULES', 'anchor_policy_prompt_block', 'get_char_consistency_prompt', 'get_cinematography_guide', 'get_scene_writing_rules']
