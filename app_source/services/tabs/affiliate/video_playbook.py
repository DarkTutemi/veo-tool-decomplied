"""
Decompiled / Reconstructed Module: services.tabs.affiliate.video_playbook
Source PyC: video_playbook.pyc

Docstring:
Affiliate VIDEO PLAYBOOK — the data backbone of the variation engine.

Strategy (validated against current short-form/UGC affiliate practice): a seller
does NOT need one perfect video — they need MANY variations per product to test,
then scale the winners. So the tool must turn 1 product into N scripts by rotating
a small matrix of axes:

    SẢN PHẨM  ×  LOẠI VIDEO  ×  HOOK  ×  (CTA)

This module is PURE DATA + helpers (no UI, no Qt) — mirrors
``services.shared.routing.cultural_contexts``. The sales architect imports it to
build a type-specific, pain-first prompt per variant; the QML surfaces the
recommended types + variation count per industry.

- ``VIDEO_TYPES``       : the 7 reusable affiliate video formats (each = a beat skeleton).
- ``INDUSTRY_PLAYBOOK`` : per-industry recommended types + a Vietnamese hook bank + CTA bank.
- ``build_variation_set`` : (category, selected_types, count) → N {video_type, hook, cta} combos,
  rotating ONE axis at a time so each rendered video isolates a clean test variable.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['VIDEO_TYPES', 'INDUSTRY_PLAYBOOK', 'industry_key', 'get_industry_playbook', 'recommended_types', 'hook_bank', 'cta_bank', 'industry_guard_block', 'sales_kit_for_product', 'video_type_block', 'build_variation_set', 'ai_variation_plan', 'ai_campaign_plan', 'CAMPAIGN_CHUNK_SIZE']

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
List = typing.List
Optional = typing.Optional
VIDEO_TYPES = {'problem_solution': {'label': 'Nỗi đau → Giải pháp', 'beats': ['PAIN', 'AGITATE', 'REVEAL', 'PROOF', 'CTA'], 'desc': 'Mở bằng nỗi đau (chưa lộ SP) → khoét → SP xuất hiện giải quyết → bằng chứng → CTA... [truncated]
INDUSTRY_PLAYBOOK = {'cosmetics': {'label': 'Mỹ phẩm / Làm đẹp', 'types': ['before_after', 'testimonial', 'problem_solution', 'demo_review'], 'hooks': ['Da xỉn, lỗ chân lông to, makeup mãi không ăn?', 'Tôi từng giấu mặt ... [truncated]
_CATEGORY_TO_INDUSTRY = {'cosmetics': 'cosmetics', 'beauty': 'cosmetics', 'fashion': 'fashion', 'home': 'home', 'electronics': 'electronics', 'food': 'food_health', 'health': 'food_health', 'baby': 'baby', 'sports': 'generic... [truncated]
CAMPAIGN_CHUNK_SIZE = 5
__all__ = ['VIDEO_TYPES', 'INDUSTRY_PLAYBOOK', 'industry_key', 'get_industry_playbook', 'recommended_types', 'hook_bank', 'cta_bank', 'industry_guard_block', 'sales_kit_for_product', 'video_type_block', 'build_... [truncated]

# --- Top-Level Functions ---
def industry_key(category: 'str') -> 'str':
    pass

def get_industry_playbook(category: 'str') -> 'Dict[str, Any]':
    pass

def recommended_types(category: 'str') -> 'List[str]':
    pass

def hook_bank(category: 'str') -> 'List[str]':
    pass

def cta_bank(category: 'str') -> 'List[str]':
    pass

def industry_guard_block(category: 'str') -> 'str':
    pass

def sales_kit_for_product(product: 'Dict[str, Any]', model_key: 'str' = '') -> 'Dict[str, Any]':
    pass

def video_type_block(video_type: 'str') -> 'str':
    pass

def build_variation_set(category: 'str', count: 'int' = 5, selected_types: 'Optional[List[str]]' = None, product_pain: 'str' = '') -> 'List[Dict[str, str]]':
    pass

def ai_variation_plan(product: 'Dict[str, Any]', market: 'str' = '', voice_language: 'str' = 'vi', count: 'int' = 5, selected_types: 'Optional[List[str]]' = None) -> 'List[Dict[str, str]]':
    """AI đề xuất ``count`` biến thể đa dạng cho 1 SP — mỗi biến thể = {video_type,
    motif, hook, cta}. AI nhìn ngành + nỗi đau + USP + thị trường để chọn loại + nghĩ
    motif (mô-típ kể) + viết hook mở đầu theo ngôn ngữ. Fallback build_variation_set
    nếu AI lỗi (không bao giờ chặn luồng). count<=0 → AI TỰ QUYẾT số lượng (3-8) dựa
    trên sản phẩm (AUTO)."""
    pass

def _normalize_variant_list(raw: 'Any', allowed: 'List[str]', category: 'str', pain: 'str', n_default: 'int' = 4) -> 'List[Dict[str, str]]':
    pass

def _ai_campaign_plan_chunk(products: 'List[Dict[str, Any]]', market: 'str' = '', voice_language: 'str' = 'vi') -> 'Dict[str, List[Dict[str, str]]]':
    """One bounded campaign-planning call.

    Five products can already yield up to 40 variants. Keeping this helper bounded
    prevents media/input limits and truncated JSON when automation selects hundreds."""
    pass

def ai_campaign_plan(products: 'List[Dict[str, Any]]', market: 'str' = '', voice_language: 'str' = 'vi') -> 'Dict[str, List[Dict[str, str]]]':
    pass
