"""
Decompiled / Reconstructed Module: services.tabs.affiliate.product_context
Source PyC: product_context.pyc

Docstring:
Canonical product facts shared by Affiliate planning and production.

Marketplace imports carry three very different kinds of data:

* facts that help the sales planner understand and sell the product;
* operational ranking data such as commission and stock;
* private/runtime material such as source paths, image bytes and preparation
  caches.

Passing the raw product dict to an LLM either drops useful fields at an ad-hoc
call site or leaks a large amount of image/cache noise.  This module creates one
small, deterministic snapshot that both Affiliate AI calls and the immutable
production package can share.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['PRODUCT_CONTEXT_SCHEMA_VERSION', 'build_product_content_context', 'product_content_prompt_block', 'product_context_fingerprint']

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
PRODUCT_CONTEXT_SCHEMA_VERSION = 1
_MAX_TEXT_CHARS = 12000
_MAX_LIST_ITEMS = 40
__all__ = ['PRODUCT_CONTEXT_SCHEMA_VERSION', 'build_product_content_context', 'product_content_prompt_block', 'product_context_fingerprint']

# --- Top-Level Functions ---
def _text(value: 'Any', *, limit: 'int' = 12000) -> 'str':
    pass

def _number_or_text(value: 'Any') -> 'Any':
    pass

def _clean_list(value: 'Any') -> 'list[Any]':
    pass

def _pick_scalars(product: 'Dict[str, Any]', keys: 'tuple[str, ...]') -> 'Dict[str, Any]':
    pass

def _pick_lists(product: 'Dict[str, Any]', keys: 'tuple[str, ...]') -> 'Dict[str, Any]':
    pass

def build_product_content_context(product: 'Dict[str, Any] | None') -> 'Dict[str, Any]':
    pass

def product_context_fingerprint(context: 'Dict[str, Any]') -> 'str':
    pass

def product_content_prompt_block(product: 'Dict[str, Any] | None') -> 'str':
    pass
