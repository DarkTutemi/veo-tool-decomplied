"""
Decompiled / Reconstructed Module: services.video_core.anchor_policy
Source PyC: anchor_policy.pyc

Docstring:
Anchor Consistency flag parsing (generation logic).

The anchor *prompt* block moved to ``services/prompts/anchor_policy.py`` (all
prompt text lives under ``services/prompts``). It is re-exported here so existing
``from services.video_core.anchor_policy import anchor_policy_prompt_block``
importers keep working. This module owns the runtime flag-parsing logic that
reads which BG/SET/OBJ entries truly need a generated reusable reference image.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
Dict = typing.Dict
List = typing.List
Optional = typing.Optional
ANCHOR_POLICY_PROMPT_BLOCK = '## Anchor Consistency Policy - Input Contract\n\nAn anchor is NOT a label, and it is NOT a measure of how "important" or how "often-seen" an entity is. An anchor means the backend generates ONE reusa... [truncated]
ANCHOR_FLAG_FIELDS = ('anchor_ref', 'needs_anchor', 'use_anchor_ref', 'identity_anchor', 'requires_reference', 'anchor_consistency')
TRUE_FLAG_VALUES = {'true', 'y', 'important', 'locked', 'reference_image', 'reference', 'on', 'ref', 'high', 'identity anchor', '1', 'lock', 'anchor', 'yes', 'identity_anchor'}
FALSE_FLAG_VALUES = {'one_off', 'one off', 'prompt only', '0', 'minor', 'no', 'none', 'n', 'false', 'ambient', 'single_use', 'text_only', 'single use', 'text only', 'prompt_only', 'off', 'generic', 'null', 'low'}

# --- Top-Level Functions ---
def normalize_anchor_flag(value: Any) -> Optional[bool]:
    pass

def get_anchor_flag(item: Dict) -> Optional[bool]:
    pass

def missing_anchor_decision_ids(entity_library: Dict) -> List[str]:
    pass
