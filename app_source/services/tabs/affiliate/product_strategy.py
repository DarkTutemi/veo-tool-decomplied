"""
Decompiled / Reconstructed Module: services.tabs.affiliate.product_strategy
Source PyC: product_strategy.pyc

Docstring:
Product-first strategy contract for Affiliate.

The LLM is the creative director.  This module does not map categories to
scripts; it gives the model a durable vocabulary for understanding what a
product *can do*, what the buyer must believe, what can be shown as evidence and
which render path can express the idea safely.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['STRATEGY_PROFILE_VERSION', 'normalize_product_strategy_profile', 'strategy_profile_errors', 'strategy_profile_prompt_block', 'normalize_creative_strategy', 'normalize_campaign_strategies', 'scene_requires_composite_start_frame', 'product_strategy_input_signature', 'late_bound_resource_changes']

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
List = typing.List
STRATEGY_PROFILE_VERSION = 1
_PRODUCT_NATURES = {'displayed', 'operated', 'set', 'physical', 'unknown', 'digital', 'assembled', 'wearable', 'applied', 'consumed', 'service', 'installed'}
_IDENTITY_MODES = {'wearable', 'coordinated_set', 'interface', 'single_sku', 'service_evidence', 'unknown'}
_OFFER_MODES = {'primary_with_accessories', 'multipack', 'variant_family', 'single', 'coordinated_set', 'unknown', 'bundle'}
_OFFER_COVERAGE_POLICIES = {'representative', 'hero_only', 'all_items'}
_OFFER_ITEM_RELATIONS = {'hero', 'accessory', 'alternative', 'included', 'coordinated', 'unknown', 'identical_unit'}
_WEARER_GENDERS = {'male', 'female', 'neutral', 'mixed', 'unknown'}
_WEARER_LIFE_STAGES = {'child', 'mixed', 'young_adult', 'adult', 'older_adult', 'teen', 'unknown'}
_ROLE_FUNCTIONS = {'operator', 'expert', 'caregiver', 'wearer', 'user', 'beneficiary', 'presenter', 'buyer'}
_ROLE_CAMERA_POLICIES = {'required', 'optional', 'forbidden'}
_ROLE_SPEECH_POLICIES = {'allowed', 'silent', 'adaptive'}
_RENDER_MODES = {'r2v_references', 'text_led', 'product_only'}
_HUMAN_PRESENCE_MODES = {'hands_only', 'speaking_presenter', 'none', 'silent_actor', 'adaptive'}
_SPEECH_STRATEGIES = {'narration', 'ambient', 'mixed', 'dialogue', 'adaptive'}
_DIFFICULTIES = {'medium', 'low', 'high'}
_RISK_LEVELS = {'medium', 'low', 'high', 'restricted'}
_PROOF_COVERAGE_SCOPES = {'campaign', 'every_variant'}
_PREP_SIGNATURE_FIELDS = ('name', 'render_name', 'brand', 'category', 'price', 'description', 'function', 'uses', 'pain_point', 'target_audience', 'sell_angle', 'key_features', 'main_image_media_id', 'extra_image_ids', 'sourc... [truncated]
_COVERAGE_GENERIC_TOKENS = {'cảnh', 'show', 'product', 'the', 'một', 'and', 'người', 'được', 'cho', 'hiện', 'this', 'của', 'trong', 'với', 'sản', 'thể'}
__all__ = ['STRATEGY_PROFILE_VERSION', 'normalize_product_strategy_profile', 'strategy_profile_errors', 'strategy_profile_prompt_block', 'normalize_creative_strategy', 'normalize_campaign_strategies', 'scene_re... [truncated]

# --- Top-Level Functions ---
def _text(value: 'Any') -> 'str':
    pass

def strategy_profile_uses_wearable_look(value: 'Any') -> 'bool':
    pass

def _string_list(value: 'Any', limit: 'int' = 8) -> 'List[str]':
    pass

def _dict_list(value: 'Any', limit: 'int' = 8) -> 'List[Dict[str, Any]]':
    pass

def _positive_int_list(value: 'Any', limit: 'int' = 10) -> 'List[int]':
    pass

def _positive_int(value: 'Any', default: 'int' = 1, maximum: 'int' = 99) -> 'int':
    pass

def _confidence(value: 'Any') -> 'float':
    pass

def product_strategy_input_signature(product: 'Dict[str, Any] | None', aspect_ratio: 'str' = '', market: 'str' = '', voice_language: 'str' = '') -> 'str':
    """Fingerprint every factual/visual input consumed by Affiliate Call 1.

    Source files carry size + nanosecond mtime so replacing an image in-place
    invalidates preparation without hashing multi-megabyte files on the UI
    thread. Market + spoken language are included so changing locale re-preps
    hook/CTA copy. This helper is called by the background prep worker."""
    pass

def _fallback_profile(product: 'Dict[str, Any]') -> 'Dict[str, Any]':
    pass

def normalize_product_strategy_profile(value: 'Any', product: 'Dict[str, Any] | None' = None) -> 'Dict[str, Any]':
    """Clamp an LLM strategy profile without choosing its creative direction."""
    pass

def strategy_profile_errors(profile: 'Any') -> 'List[str]':
    pass

def strategy_profile_prompt_block(profile: 'Any') -> 'str':
    pass

def normalize_creative_strategy(value: 'Any', profile: 'Dict[str, Any]') -> 'Dict[str, Any]':
    pass

def _coverage_tokens(value: 'Any') -> 'set[str]':
    pass

def _repair_required_proof_coverage(variant: 'Dict[str, Any]', visible_proofs: 'List[Dict[str, Any]]', required_proof_ids: 'List[str]') -> 'List[Dict[str, Any]]':
    """Attach an omitted proof id only to a scene that visibly executes it.

    This repairs metadata, not creative content. If no scene text overlaps the
    requested belief/evidence strongly enough, the id stays missing and the
    downstream contract validator still fails closed."""
    pass

def _scene_proof_ids(variant: 'Dict[str, Any]', allowed_ids: 'set[str]') -> 'List[str]':
    """Return required proof ids the model already assigned to this variant."""
    pass

def _variant_proof_match_score(variant: 'Dict[str, Any]', opportunity: 'Dict[str, Any]', proof: 'Dict[str, Any]') -> 'float':
    """Score a legacy proof-to-variant match without inventing scene content.

    New Call-1 profiles explicitly map opportunity ``proof_ids``.  Persisted v1
    profiles do not, so retry/reopen must infer ownership from the chosen
    strategy and the concrete Call-2 timeline.  The score is used only to pick
    which variant owns a campaign proof; the existing semantic repair and hard
    validator still require the scene to visibly execute that evidence."""
    pass

def _assign_campaign_proofs(variants: 'List[Dict[str, Any]]', opportunities: 'List[Dict[str, Any]]', visible_proofs: 'List[Dict[str, Any]]', required_proof_ids: 'List[str]', every_variant_proof_ids: 'List[str]') -> 'None':
    """Scope campaign proofs to their strategy instead of every A/B variant."""
    pass

def normalize_campaign_strategies(plan_data: 'Dict[str, Any]', profile: 'Any', product: 'Dict[str, Any] | None' = None) -> 'Dict[str, Any]':
    """Attach the durable profile and normalize per-variant/scene render choices."""
    pass

def scene_requires_composite_start_frame(scene: 'Any') -> 'bool':
    pass

def _resource_identity(item: 'Any') -> 'Dict[str, Any]':
    pass

def late_bound_resource_changes(plan_data: 'Dict[str, Any]', character_slots: 'List[Dict[str, Any]] | None', background_slots: 'List[Dict[str, Any]] | None') -> 'List[Dict[str, Any]]':
    pass

def _safe_resource_list(value: 'Any') -> 'List[Dict[str, Any]]':
    pass
