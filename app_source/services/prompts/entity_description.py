"""
Decompiled / Reconstructed Module: services.prompts.entity_description
Source PyC: entity_description.pyc

Docstring:
Shared entity-description contract for ALL video tabs (clone / transcript / master).

One source of truth for HOW to describe an entity_library entry — the field checklists,
the "describe the real subject, not a template" (anthropomorphic) rule, the
character-vs-not-a-character definition, object continuity, and the celebrity-name ban.

It is deliberately NEUTRAL about WHERE the entity comes from: clone OBSERVES it in a
source video, transcript IMAGINES it from audio, master INVENTS it from an idea. Each
tab keeps its own "how to read the input" guidance; this module only governs the QUALITY
and SHAPE of the resulting entity description, so all three tabs stay consistent.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)

# --- Top-Level Functions ---
def build_entity_description_block(source: 'str' = 'video') -> 'str':
    pass
