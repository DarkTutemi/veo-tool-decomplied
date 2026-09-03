"""
Decompiled / Reconstructed Module: services.tabs.affiliate.sales_architect
Source PyC: sales_architect.pyc

Docstring:
AffiliateSalesArchitect — single Affiliate-owned sales plan builder.

Replaces the two historical Affiliate prompt paths (dispatch and preview) with
one route-owned entry that:

  - builds an Affiliate-only commerce prompt and scene schema,
  - calls the common AI transport without importing the Master/Clone prompt contract,
  - normalizes the response into Affiliate campaign/variant data for packaging.

Output ``plan_data`` dict::

    {"scenes": [...timeline scenes...], "asset_library": {...}, "metadata": {...},
     "global_plan": {...}, "entity_library": {...}}

Both dispatch and preview consume this result. The common video gateway remains
transport and lifecycle infrastructure only; Affiliate owns the planning contract
and the model-facing cleanup policy. The architect is PURE — the route maps its
config to ``AffiliateArchitectRequest`` before calling.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['AffiliateArchitectRequest', 'build_affiliate_architect_prompt', 'run_affiliate_sales_architect']

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
List = typing.List
MAX_AFFILIATE_VARIANTS_PER_PRODUCT = 5
_UNCLASSIFIED = {'', 'uncategorized', 'other', 'unknown', 'misc'}
__all__ = ['AffiliateArchitectRequest', 'build_affiliate_architect_prompt', 'run_affiliate_sales_architect']

# --- Class: AffiliateArchitectRequest ---
class AffiliateArchitectRequest:
    """Unified input that supersedes both the dispatch job and the preview request."""
    template_key = ''
    work_mode = ''
    brief_audience = ''
    brief_problem = ''
    brief_offer = ''
    brief_product_pain = ''
    brief_tone = 'warm_friendly'
    market = 'global'
    voice_language = 'vi'
    technique = ''
    material = ''
    duration_seconds = 0
    clip_duration_seconds = 8
    aspect_ratio = '9:16'
    ai_decides_scene_count = True
    additional_instructions = ''
    video_model_key = ''
    video_type = ''
    motif = ''
    hook = ''
    cta = ''
    enable_narrator = False
    enable_flow_voice_lock = False
    campaign_mode = False
    prep_mode = False
    prep_done = False

    def __init__(self, product: 'Dict[str, Any]', template_key: 'str' = '', work_mode: 'str' = '', brief_audience: 'str' = '', brief_problem: 'str' = '', brief_offer: 'str' = '', brief_product_pain: 'str' = '', brief_tone: 'str' = 'warm_friendly', market: 'str' = 'global', voice_language: 'str' = 'vi', char_assets: 'List[Dict[str, Any]]' = <factory>, bg_assets: 'List[Dict[str, Any]]' = <factory>, technique: 'str' = '', material: 'str' = '', duration_seconds: 'int' = 0, clip_duration_seconds: 'int' = 8, aspect_ratio: 'str' = '9:16', ai_decides_scene_count: 'bool' = True, additional_instructions: 'str' = '', video_model_key: 'str' = '', video_type: 'str' = '', motif: 'str' = '', hook: 'str' = '', cta: 'str' = '', enable_narrator: 'bool' = False, enable_flow_voice_lock: 'bool' = False, library_policy: 'Dict[str, Any]' = <factory>, image_parts: 'List[Dict[str, Any]]' = <factory>, campaign_mode: 'bool' = False, variants_plan: 'List[Dict[str, Any]]' = <factory>, prep_mode: 'bool' = False, prep_done: 'bool' = False) -> None:
        pass

    def __repr__(self):
        pass


# --- Top-Level Functions ---
def _text(value: 'Any') -> 'str':
    pass

def _lang_name(code: 'str') -> 'str':
    pass

def _as_list(value: 'Any') -> 'List[Any]':
    pass

def _asset_summary(item: 'Dict[str, Any]') -> 'str':
    pass

def _copy_entity_identity(target: 'Dict[str, Any]', source: 'Dict[str, Any]') -> 'None':
    """Preserve structured identity fields carried by a selected library asset."""
    pass

def _entity_library(req: 'AffiliateArchitectRequest') -> 'Dict[str, List[Dict[str, Any]]]':
    pass

def _entity_library_block(entity_library: 'Dict[str, List[Dict[str, Any]]]') -> 'str':
    """Provided-asset listing chuẩn master (_format_user_assets_for_prompt port):
    asset có media_id = ĐÃ CÓ ảnh reference — giữ exact id, viết chuyện QUANH nó."""
    pass

def _duration_block(req: "'AffiliateArchitectRequest'") -> 'str':
    pass

def _character_contract_block(req: "'AffiliateArchitectRequest'") -> 'str':
    pass

def _background_contract_block(req: "'AffiliateArchitectRequest'") -> 'str':
    pass

def _anchor_contract_block() -> 'str':
    pass

def _voice_lock_block(req: "'AffiliateArchitectRequest'") -> 'str':
    pass

def _library_control_block(req: "'AffiliateArchitectRequest'") -> 'str':
    pass

def _scene_item_schema(req: "'AffiliateArchitectRequest'") -> 'str':
    pass

def _identity_sheet_layout(req: "'AffiliateArchitectRequest'") -> 'tuple[str, str]':
    """Return orientation + natural layout for the selected video canvas."""
    pass

def _identity_sheet_prompt_example(req: "'AffiliateArchitectRequest'") -> 'str':
    pass

def _narrator_content_profile_schema(req: 'AffiliateArchitectRequest') -> 'str':
    pass

def _campaign_output_contract_block(req: "'AffiliateArchitectRequest'") -> 'str':
    pass

def _output_contract_block(req: "'AffiliateArchitectRequest'") -> 'str':
    pass

def _product_block(product: 'Dict[str, Any]') -> 'str':
    pass

def _brief_block(req: 'AffiliateArchitectRequest') -> 'str':
    pass

def _template_block(req: 'AffiliateArchitectRequest', scene_count: 'int') -> 'str':
    pass

def _market_voice_block(req: 'AffiliateArchitectRequest') -> 'str':
    pass

def _audience_market_block(req: 'AffiliateArchitectRequest') -> 'str':
    pass

def _narrator_voice_casting_block(req: 'AffiliateArchitectRequest') -> 'str':
    pass

def _narrator_contract_block(req: 'AffiliateArchitectRequest') -> 'str':
    pass

def _affiliate_scene_authoring_block(req: "'AffiliateArchitectRequest'") -> 'str':
    pass

def _audio_safety_block(req: "'AffiliateArchitectRequest'") -> 'str':
    pass

def _image_input_block(req: 'AffiliateArchitectRequest') -> 'str':
    pass

def _product_identity_block(req: 'AffiliateArchitectRequest') -> 'str':
    pass

def _prep_output_contract_block(req: 'AffiliateArchitectRequest') -> 'str':
    pass

def _strategy_profile_from_req(req: 'AffiliateArchitectRequest') -> 'Dict[str, Any]':
    pass

def _strategy_profile_block(req: 'AffiliateArchitectRequest') -> 'str':
    pass

def _universal_product_strategy_block(*, preparation: 'bool') -> 'str':
    pass

def _legacy_video_type_block(video_type: 'Any') -> 'str':
    pass

def _campaign_variants_block(req: 'AffiliateArchitectRequest') -> 'str':
    pass

def _scene_count_hint(req: 'AffiliateArchitectRequest') -> 'int':
    pass

def build_affiliate_architect_prompt(req: 'AffiliateArchitectRequest') -> 'str':
    """Assemble the full Affiliate-owned sales-architect prompt.

    V5 (spec 2e): prep_mode → CALL 1 gọn (chuẩn bị tài nguyên, không scenes);
    campaign_mode → CALL 2 (scenes; prep_done bỏ khối chuẩn bị, thêm sheets có sẵn)."""
    pass

def _maybe_auto_detect_product(req: 'AffiliateArchitectRequest') -> 'None':
    pass

def run_affiliate_sales_architect(req: 'AffiliateArchitectRequest') -> 'Dict[str, Any]':
    pass

def _merge_entity_libraries(provided: 'Dict[str, List[Dict[str, Any]]]', plan_data: 'Dict[str, Any]') -> 'Dict[str, List[Dict[str, Any]]]':
    pass
