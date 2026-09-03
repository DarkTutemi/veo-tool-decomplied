"""
Decompiled / Reconstructed Module: services.shared.style.style_prompt_safety
Source PyC: style_prompt_safety.pyc

Docstring:
Safety helpers for custom style prompt wording.

Custom style generation should describe the finished visual surface, not a
real-world creation process. Words like "hand-painted", "marker", "drawn", or
"brush strokes" often make video models render a human hand/tool entering the
frame. These helpers rewrite that language into material/surface terms.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
FINISHED_SURFACE_RULE = 'Completed visual surface only: describe final linework, pigment texture, material grain, color fields, gilding, composition, and screen-space motion.'
STYLE_LANGUAGE_SYSTEM_PROMPT = "# SYSTEM STYLE LANGUAGE RULES\n\nAlways convert user style ideas into final-image surface language before writing any framework field.\n\nCore rule:\n- Describe the completed visual surface only: fin... [truncated]
_PHRASE_REPLACEMENTS = (('\\bvisible\\s+(?:human\\s+)?hand\\s+holding\\s+(?:a\\s+)?(?:black\\s+)?marker(?:\\s+and\\s+drawing)?\\b', 'black linework surface'), ('\\bhuman\\s+hand\\s+holding\\s+(?:a\\s+)?(?:pen|brush|marker|p... [truncated]
_MEDIUM_REPLACEMENTS = (('\\bwatercolor\\b', 'translucent pigment wash'), ('\\boil\\s+paint\\b', 'dense pigment texture'), ('\\bacrylic\\s+paint\\b', 'opaque pigment texture'), ('\\bcharcoal\\s+drawing\\b', 'charcoal-grain ... [truncated]
_PROMPT_KEYS = {'knowledge_brief', 'global_style_override', 'summary', 'intent', 'dispatch_style_override', 'veo3_prompt', 'asset_generation_style', 'additional_context', 'master_prompt_guideline'}

# --- Top-Level Functions ---
def sanitize_style_prompt_text(text: 'Any') -> 'Any':
    pass

def style_language_system_prompt() -> 'str':
    pass

def sanitize_style_payload(value: 'Any', *, key: 'str' = '') -> 'Any':
    pass

def add_finished_surface_rule(framework: 'Dict[str, Any]') -> 'Dict[str, Any]':
    pass
