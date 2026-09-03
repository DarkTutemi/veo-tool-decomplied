"""
Decompiled / Reconstructed Module: services.prompts.anchor_policy
Source PyC: anchor_policy.pyc

Docstring:
Anchor Consistency prompt block (model-facing input contract).

PROMPT TEXT ONLY — the runtime anchor-flag parsing logic
(normalize_anchor_flag / get_anchor_flag / flag value sets) stays in
``services/video_core/anchor_policy.py`` because it is generation logic, not a
prompt. This module is the single home for the anchor *prompt*.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
ANCHOR_POLICY_PROMPT_BLOCK = '## Anchor Consistency Policy - Input Contract\n\nAn anchor is NOT a label, and it is NOT a measure of how "important" or how "often-seen" an entity is. An anchor means the backend generates ONE reusa... [truncated]

# --- Top-Level Functions ---
def anchor_policy_prompt_block() -> str:
    pass
