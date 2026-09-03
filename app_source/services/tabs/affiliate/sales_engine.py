"""
Decompiled / Reconstructed Module: services.tabs.affiliate.sales_engine
Source PyC: sales_engine.pyc

Docstring:
Sales Engine — bộ não sinh-content RIÊNG của affiliate (bố chốt 20/7).

Master prompt đa năng; affiliate CHỈ làm 1 việc: video bán hàng + kịch bản tự động.
Engine này là orchestrator riêng để tối ưu thoải mái mà KHÔNG đụng master
(services/script_architect_engine.py). Nó PORT các khối giá trị nhất của master
(audit 20/7) và GIỮ CHUNG mọi thứ thuộc hệ xử lý video:

  PORT từ master (sửa tự do tại đây):
    · output budget theo scene count; Affiliate keeps one provider turn per boundary
    · max_output_tokens theo scene budget (master _max_output_tokens_for_target)
    · normalize/validate entity: CHAR_/OBJ_/BG_ regex, dedup, provided thắng
    · guard chống leak nội bộ (ROUTE_HINT/[REFS:/[MODULES: — master _validate_directive_script)
    · word-budget lời dẫn theo ngôn ngữ (shared narration_script.wps_for/word_budget)
      — tinh cho ADS: cảnh báo khi 1 scene nói vượt ngân sách đọc
  GIỮ CHUNG (KHÔNG copy — sửa ở gốc là mọi tab hưởng):
    · build_affiliate_architect_prompt (sales_architect — advertisement_formula_block,
      module_contract, cultural_injection, anchor_policy đều là shared gateway)
    · call_ai_for_plan (provider + JSON completion_spec + extract robust)
    · normalize_result_scene_contract + 3-seam consistency + compile prompt + dispatch

Entrypoint: ``run_sales_engine(req)`` — chữ ký/kết quả GIỐNG run_affiliate_sales_architect
cũ (plan_data dict); sales_architect.run_affiliate_sales_architect giờ là alias gọi vào
đây (2 call-site queue_service/application không đổi).
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['run_sales_engine', 'validate_sales_plan', 'normalize_entities', 'normalize_affiliate_scene_entities', 'affiliate_scene_human_presence', 'affiliate_scene_uses_character_reference', 'affiliate_scene_uses_background_reference', 'normalize_affiliate_creative_treatment', 'normalize_affiliate_timeline_modules', 'apply_affiliate_narrator_delivery', 'normalize_affiliate_narrator_voice_profile', 'affiliate_narration_wps', 'affiliate_scene_contract_errors', 'narration_budget_violations', 'enforce_affiliate_narration_budget', 'AffiliateNarrationBudgetError', 'AffiliateLateResourceRepairError', 'repair_late_bound_resource_plan', 'SalesRunRecord']

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Callable = typing.Callable
Dict = typing.Dict
List = typing.List
Optional = typing.Optional
MAX_AFFILIATE_VARIANTS_PER_PRODUCT = 5
_ID_RE = {'characters': re.compile('^CHAR_\\d{3}$'), 'products': re.compile('^(OBJ|PROD)_\\d{3}$'), 'locations': re.compile('^BG_\\d{3}$')}
_LEAK_RE = re.compile('ROUTE_HINT|\\[REFS?:|\\[MODULES?:|entity_library|asset_library', re.IGNORECASE)
_VISIBLE_SPEECH_RE = re.compile('\\b(?:speak(?:s|ing)?|talk(?:s|ing)?|say(?:s|ing)?|review(?:s|ing)? verbally|verbally|lip[- ]?sync|nói|đọc lời|thuyết minh trực tiếp)\\b', re.IGNORECASE)
_TIMELINE_START_RE = re.compile('^\\s*(\\d+(?:\\.\\d+)?)\\s*s?', re.IGNORECASE)
MAX_AFFILIATE_SCENES_PER_VARIANT = 8
_AFFILIATE_DELIVERY_TAGS = {'hook': 'speak briskly with high energy and urgency; punch the opening words; sound immediately engaging; no drawn-out syllables', 'proof': 'speak crisp, confident and persuasive; stress the visible ... [truncated]
_AFFILIATE_AUDIO_PROFILE = 'Solo studio commercial voiceover: one narrator at a constant microphone distance with stable identity, loudness and accent. Energetic, bright and forward-moving short-form advertising delivery. Use o... [truncated]
_AFFILIATE_HUMAN_PRESENCE = {'speaking_presenter', 'hands_only', 'silent_actor', 'none'}
_TREATMENT_INTENSITIES = {'expressive', 'moderate', 'subtle', 'none'}
_TVC_PRESENTATION_MODES = {'playful_tvc', 'cinematic_tvc', 'premium_reveal'}
__all__ = ['run_sales_engine', 'validate_sales_plan', 'normalize_entities', 'normalize_affiliate_scene_entities', 'affiliate_scene_human_presence', 'affiliate_scene_uses_character_reference', 'affiliate_scene_u... [truncated]

# --- Class: SalesRunRecord ---
class SalesRunRecord:
    """Telemetry 1 lần chạy engine (port TierRecord tinh gọn)."""
    attempts = 0
    duration_s = 0.0
    scene_count = 0

    def __init__(self, attempts: 'int' = 0, started_at: 'float' = <factory>, duration_s: 'float' = 0.0, scene_count: 'int' = 0, warnings: 'List[str]' = <factory>) -> None:
        pass

    def __repr__(self):
        pass


# --- Class: AffiliateNarrationBudgetError ---
class AffiliateNarrationBudgetError(ValueError):
    """Affiliate narration cannot be made safe for the fixed video grid."""
    pass


# --- Class: AffiliateLateResourceRepairError ---
class AffiliateLateResourceRepairError(ValueError):
    """A late manual CHAR/BG choice could not be reconciled safely."""
    pass


# --- Top-Level Functions ---
def _current_model_knob() -> 'str':
    pass

def _max_output_tokens_for_scenes(n: 'int') -> 'int':
    pass

def _text(v: 'Any') -> 'str':
    pass

def _first_dialogue_start_s(scene: 'Dict[str, Any]') -> 'float | None':
    pass

def normalize_affiliate_narrator_voice_profile(plan_data: 'Dict[str, Any]', req: 'Any' = None, inherited_profile: 'Dict[str, Any] | None' = None) -> 'Dict[str, Any]':
    pass

def _safe_role_items(strategy: 'Any') -> 'List[Dict[str, Any]]':
    pass

def affiliate_narration_wps(language: 'str') -> 'float':
    pass

def apply_affiliate_narrator_delivery(plan_data: 'Dict[str, Any]') -> 'Dict[str, Any]':
    """Compile scene roles into silent Gemini delivery tags.

    Spoken copy remains untouched.  ``narration_script`` exposes these tags only
    to Gemini TTS, while word counting, alignment and SRT continue using the
    clean ``narrator_voice.says`` text."""
    pass

def narration_budget_violations(plan_data: 'Dict[str, Any]', *, language: 'str' = 'vi', default_clip_s: 'float' = 8.0, include_underfill: 'bool' = False) -> 'List[Dict[str, Any]]':
    pass

def enforce_affiliate_narration_budget(plan_data: 'Dict[str, Any]', *, language: 'str' = 'vi', default_clip_s: 'float' = 8.0) -> 'None':
    """Fail before Gemini TTS/Veo when a saved or legacy plan bypassed repair."""
    pass

def repair_late_bound_resource_plan(plan_data: 'Dict[str, Any]', *, character_slots: 'List[Dict[str, Any]] | None', background_slots: 'List[Dict[str, Any]] | None', product: 'Dict[str, Any] | None', language: 'str', call_ai_for_plan: 'Callable[..., Dict[str, Any]]') -> 'Dict[str, Any]':
    """Micro-replan only identity-dependent scene prose after a late slot change.

    Product proof, sales logic, duration, render strategy and scene ordering are
    immutable. The response is validated completely, then timeline/visual prose
    is swapped atomically before narration is generated."""
    pass

def _repair_affiliate_narration_budget(plan_data: 'Dict[str, Any]', req: 'Any') -> 'Dict[str, Any]':
    pass

def _normalize_entity_group(items: 'Any', kind: 'str', seen: 'set') -> 'List[Dict[str, Any]]':
    pass

def normalize_entities(plan_data: 'Dict[str, Any]') -> 'Dict[str, Any]':
    pass

def _affiliate_timed_dialogue_present(scene: 'Any') -> 'bool':
    pass

def affiliate_scene_human_presence(scene: 'Any') -> 'str':
    pass

def affiliate_scene_uses_character_reference(scene: 'Any') -> 'bool':
    pass

def affiliate_scene_uses_background_reference(scene: 'Any') -> 'bool':
    pass

def normalize_affiliate_scene_entities(plan_data: 'Dict[str, Any]', product_object_ids: 'Optional[List[str]]' = None) -> 'Dict[str, Any]':
    """Bridge the Affiliate scene schema to the shared consistency schema.

    The sales architect intentionally authors the compact legacy fields
    ``characters/background/objects``.  The shared reference compiler consumes
    ``scene.entities``.  Keeping both shapes in sync here prevents a perfectly
    valid Affiliate plan from silently losing every CHAR/OBJ/BG reference and
    falling back to T2V.

    ``product_object_ids``: product OBJ entities kept on every scene —
    ``["OBJ_000"]`` (mặc định, hợp đồng cũ) hoặc thêm OBJ_001… cho các board
    tham chiếu phụ lấp slot còn trống (slot budget 26/8)."""
    pass

def _default_creative_treatment(strategy_profile: 'Dict[str, Any] | None' = None) -> 'Dict[str, Any]':
    pass

def normalize_affiliate_creative_treatment(plan_data: 'Dict[str, Any]', product: 'Dict[str, Any] | None' = None) -> 'Dict[str, Any]':
    """Keep product-aware creative treatment explicit and evidence-led.

    The LLM chooses the creative language. This seam preserves that decision,
    supplies a conservative default for resumed/legacy plans, and bounds effect
    intensity from the durable claim-risk profile rather than category keywords.
    For a multi-variant campaign, it also guarantees one native review/proof
    baseline so the whole campaign cannot silently collapse into brand-film TVCs."""
    pass

def _affiliate_timed_effect_present(beat: 'Dict[str, Any]') -> 'bool':
    """Whether a timed beat contains an executable visual-effect instruction."""
    pass

def normalize_affiliate_timeline_modules(plan_data: 'Dict[str, Any]', *, product_name: 'str' = 'Product', narrator_enabled: 'bool | None' = None, speech_enabled: 'bool' = True) -> 'Dict[str, Any]':
    """Upgrade shallow Affiliate beats onto the Affiliate-owned scene contract.

    New prompts should already emit this shape.  This deterministic adapter keeps
    old/resumed plans safe and prevents catch-all ``action`` strings from reaching
    the video model as an under-specified scene."""
    pass

def affiliate_scene_contract_errors(plan_data: 'Dict[str, Any]') -> 'List[str]':
    """Hard dispatch invariants for an Affiliate scene timeline."""
    pass

def affiliate_campaign_contract_errors(plan_data: 'Dict[str, Any]') -> 'List[str]':
    pass

def validate_sales_plan(plan_data: 'Dict[str, Any]', req: 'Any', record: 'SalesRunRecord') -> 'List[str]':
    pass

def run_sales_engine(req: 'Any') -> 'Dict[str, Any]':
    """Orchestrator sinh-content bán hàng: detect → prompt → one AI turn →
    contract → merge entity → normalize → guard. Kết quả = plan_data (shape cũ).

    V4 campaign_mode (bố chốt 22/7 — spec 2c): MỘT call multimodal / SP — parts =
    ảnh gốc, required 'variants'; response trọn bộ brain + image_review +
    normalize_plan + variants (mỗi variant scenes + publish_kit riêng). Skip
    auto-detect vision cũ (brain do chính call này trả)."""
    pass
