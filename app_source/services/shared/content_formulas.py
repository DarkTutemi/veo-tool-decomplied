"""
Decompiled / Reconstructed Module: services.shared.content_formulas
Source PyC: content_formulas.pyc

Docstring:
Shared content/sales formulas that teach the LLM HOW to sell.

Extracted as a shared module (pattern mirrors master's content-type success
formulas) so the affiliate sales architect — and any future route — imports ONE
source instead of re-embedding selling logic in each prompt builder.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['ADVERTISEMENT_FORMULA', 'CATEGORY_ANGLES', 'advertisement_formula_block']

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
List = typing.List
ADVERTISEMENT_FORMULA = ["PAIN HOOK (scene 1, first ~2s): open ONLY on the audience's raw pain / frustration (e.g. moldy chopsticks, a cracked bowl, wasted money). The PRODUCT MUST NOT appear, be shown, or be named in this s... [truncated]
CATEGORY_ANGLES = {'cosmetics': 'Open on the skin frustration (dull/spots/aging); reveal = the product; proof = before/after glow.', 'beauty': 'Open on the beauty pain point; reveal = the product; proof = before/after ... [truncated]
__all__ = ['ADVERTISEMENT_FORMULA', 'CATEGORY_ANGLES', 'advertisement_formula_block']

# --- Top-Level Functions ---
def advertisement_formula_block(category: 'str' = '', product_pain: 'str' = '') -> 'str':
    """Render the PAIN-FIRST sales-formula prompt block, tuned by product category.

    ``product_pain`` (optional) is the specific pain this product solves — when given,
    the hook is anchored to it instead of a generic frustration."""
    pass
