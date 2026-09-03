"""
Decompiled / Reconstructed Module: services.tabs.affiliate.source_image_store
Source PyC: source_image_store.pyc

Docstring:
Private staging for raw Affiliate commerce images.

Raw PDP/gallery photos are working inputs, not reusable user assets.  Keep them
outside Media Library and expose only the generated ``SHEET_IDENTITY`` there.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['stage_product_sources']

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Iterable = typing.Iterable
List = typing.List
_IMAGE_SUFFIXES = {'.png', '.jpg', '.gif', '.bmp', '.jpeg', '.webp'}
_MAX_SOURCE_IMAGES = 10
__all__ = ['stage_product_sources']

# --- Top-Level Functions ---
def _clean_source_paths(paths: 'Iterable[Any]') -> 'List[Path]':
    pass

def stage_product_sources(paths: 'Iterable[Any]', *, group_id: 'str' = '') -> 'List[str]':
    """Copy raw inputs into Affiliate-private durable staging.

    This function deliberately does not call ``MediaAPI``.  The staged files
    remain available for retries/aspect-ratio rebuilds but never appear in the
    user's reusable Media Library."""
    pass
