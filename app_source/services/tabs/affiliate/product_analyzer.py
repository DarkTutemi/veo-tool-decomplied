"""
Decompiled / Reconstructed Module: services.tabs.affiliate.product_analyzer
Source PyC: product_analyzer.pyc

Docstring:
ProductVisionAnalyzer — affiliate's 'analysis gate'.

Given a product (image + any scraped/typed text), the multimodal LLM determines
what it IS and how to sell it: category + a sales-oriented summary, audience and
angle. The AffiliateSalesArchitect uses this to pick the right sales formula
AUTOMATICALLY instead of relying on a user-supplied category — so a user can drop
in a link OR an image and the system figures out the rest.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['ProductVisionAnalyzer', 'get_product_analyzer', 'analyze_product', 'allowed_categories']

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
List = typing.List
_MIME_BY_EXT = {'.jpg': 'image/jpeg', '.jpeg': 'image/jpeg', '.png': 'image/png', '.webp': 'image/webp', '.gif': 'image/gif', '.bmp': 'image/bmp'}
_analyzer = None
__all__ = ['ProductVisionAnalyzer', 'get_product_analyzer', 'analyze_product', 'allowed_categories']

# --- Class: ProductVisionAnalyzer ---
class ProductVisionAnalyzer:
    """Resolve a product image and ask the multimodal LLM to classify + pitch it."""
    def _image_parts(self, product: 'Dict[str, Any]') -> 'List[Dict[str, str]]':
        pass

    def analyze(self, product: 'Dict[str, Any]') -> 'Dict[str, Any]':
        """Return product facts plus a short physical render name, or {}."""
        pass


# --- Top-Level Functions ---
def _text(value: 'Any') -> 'str':
    pass

def allowed_categories() -> 'List[str]':
    pass

def _part_from_path(path: 'str') -> 'Dict[str, str] | None':
    pass

def get_product_analyzer() -> 'ProductVisionAnalyzer':
    pass

def analyze_product(product: 'Dict[str, Any]') -> 'Dict[str, Any]':
    pass
