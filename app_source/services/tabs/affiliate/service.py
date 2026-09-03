"""
Decompiled / Reconstructed Module: services.tabs.affiliate.service
Source PyC: service.pyc

Docstring:
Affiliate video service — single backend file for the affiliate_video tab.

Consolidates:
  - core/affiliate/job.py          → AffiliateJob, constants
  - core/affiliate/job_manager.py  → AffiliateJobManager
  - core/affiliate/product_store.py → AffiliateProductStore, PRODUCT_CATEGORIES
  - templates.py                   → template definitions + helpers
  - ai_caller.py                   → call_ai_for_plan()
  - prompt_engine.py               → prompt builders (ingredient / image-first)
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
Dict = typing.Dict
List = typing.List
Optional = typing.Optional
MODE_INGREDIENT = 'ingredient'
MODE_NANOBANANA = 'nanobanana'
MODE_DIRECT = 'direct'
VALID_MODES = {'direct', 'nanobanana', 'ingredient'}
WORK_MODE_INGREDIENT_ADS = 'ingredient_ads'
WORK_MODE_IMAGE_FIRST = 'image_first_ads'
VALID_WORK_MODES = {'ingredient_ads', 'image_first_ads'}
OUTPUT_VIDEO = 'video'
OUTPUT_IMAGE = 'image'
PRODUCT_CATEGORIES = [('cosmetics', 'Mỹ phẩm'), ('fashion', 'Thời trang'), ('electronics', 'Điện tử'), ('home', 'Gia dụng'), ('food', 'Thực phẩm'), ('sports', 'Thể thao'), ('beauty', 'Làm đẹp'), ('health', 'Sức khỏe'), ('... [truncated]
_store = None
AFFILIATE_TEMPLATES = {'ai_auto': AffiliateTemplate(key='ai_auto', label='AI tự chọn template', icon='robot', description='Để AI phân tích sản phẩm và chọn template phù hợp nhất (hook · review · reveal · demo · unboxing · ... [truncated]
LANG_FULL_NAMES = {'vi': 'Vietnamese (Tiếng Việt)', 'en': 'English', 'ja': 'Japanese (日本語)', 'ko': 'Korean (한국어)', 'zh': 'Chinese (中文)', 'es': 'Spanish (Español)', 'fr': 'French (Français)', 'de': 'German (Deutsch)', '... [truncated]
LANG_NAMES = {'vi': 'Vietnamese', 'en': 'English', 'ja': 'Japanese', 'ko': 'Korean', 'zh': 'Chinese', 'es': 'Spanish', 'fr': 'French', 'de': 'German', 'pt': 'Portuguese', 'ru': 'Russian', 'ar': 'Arabic', 'hi': 'Hi... [truncated]
LANGUAGE_EXAMPLES = {'vi': {'dialogue': 'Medium shot of a warm room with soft afternoon light. Alex steps closer to Maya, looks straight into their eyes. Alex says, "Tôi sẽ không bao giờ bỏ cuộc!" Maya smiles softly, nod... [truncated]
MAX_SCENES_PER_PRODUCT = 8
MIN_SCENES_PER_PRODUCT = 2

# --- Class: AffiliateJobStatus ---
class AffiliateJobStatus(Enum):
    _use_args_ = False
    _member_names_ = ['PENDING', 'RUNNING', 'COMPLETED', 'FAILED']
    _member_map_ = {'PENDING': <AffiliateJobStatus.PENDING: 'pending'>, 'RUNNING': <AffiliateJobStatus.RUNNING: 'running'>, 'COMPLETED': <A...
    _value2member_map_ = {'pending': <AffiliateJobStatus.PENDING: 'pending'>, 'running': <AffiliateJobStatus.RUNNING: 'running'>, 'completed': <A...
    _unhashable_values_ = []
    _value_repr_ = None
    PENDING = <AffiliateJobStatus.PENDING: 'pending'>
    RUNNING = <AffiliateJobStatus.RUNNING: 'running'>
    COMPLETED = <AffiliateJobStatus.COMPLETED: 'completed'>
    FAILED = <AffiliateJobStatus.FAILED: 'failed'>

    @staticmethod
    def _generate_next_value_(name, start, count, last_values):
        """Generate the next value when not given.

        name: the name of the member
        start: the initial start value or None
        count: the number of existing members
        last_values: the list of values assigned"""
        pass

    def _new_member_(*args, **kwargs):
        """Create and return a new object.  See help(type) for accurate signature."""
        pass

    def _member_type_():
        """The base class of the class hierarchy.

When called, it accepts no arguments and returns a new featureless
instance that has no instance attributes and cannot be given any."""
        pass


# --- Class: AffiliateStage ---
class AffiliateStage(Enum):
    _use_args_ = False
    _member_names_ = ['QUEUED', 'ANALYZE', 'PLAN', 'START_IMAGES', 'DISPATCH', 'GENERATING', 'MERGING', 'DONE', 'FAILED']
    _member_map_ = {'QUEUED': <AffiliateStage.QUEUED: 'queued'>, 'ANALYZE': <AffiliateStage.ANALYZE: 'analyze'>, 'PLAN': <AffiliateStage.PL...
    _value2member_map_ = {'queued': <AffiliateStage.QUEUED: 'queued'>, 'analyze': <AffiliateStage.ANALYZE: 'analyze'>, 'plan': <AffiliateStage.PL...
    _unhashable_values_ = []
    _value_repr_ = None
    QUEUED = <AffiliateStage.QUEUED: 'queued'>
    ANALYZE = <AffiliateStage.ANALYZE: 'analyze'>
    PLAN = <AffiliateStage.PLAN: 'plan'>
    START_IMAGES = <AffiliateStage.START_IMAGES: 'start_images'>
    DISPATCH = <AffiliateStage.DISPATCH: 'dispatch'>
    GENERATING = <AffiliateStage.GENERATING: 'generating'>
    MERGING = <AffiliateStage.MERGING: 'merging'>
    DONE = <AffiliateStage.DONE: 'done'>
    FAILED = <AffiliateStage.FAILED: 'failed'>

    @staticmethod
    def _generate_next_value_(name, start, count, last_values):
        """Generate the next value when not given.

        name: the name of the member
        start: the initial start value or None
        count: the number of existing members
        last_values: the list of values assigned"""
        pass

    def _new_member_(*args, **kwargs):
        """Create and return a new object.  See help(type) for accurate signature."""
        pass

    def _member_type_():
        """The base class of the class hierarchy.

When called, it accepts no arguments and returns a new featureless
instance that has no instance attributes and cannot be given any."""
        pass


# --- Class: AffiliateJob ---
class AffiliateJob:
    """AffiliateJob(id: str = <factory>, title: str = '', product: Dict[str, Any] = <factory>, template_key: str = 'hook_demo_cta', mode: str = 'direct', scene_count: int = 3, start_image_media_ids: List[str] = <factory>, character_ref_media_id: str = '', background_ref_media_id: str = '', work_mode: str = 'ingredient_ads', ai_decides_scene_count: bool = True, output_mode: str = 'video', aspect_ratio: str = '16:9', voice_language: str = 'vi', voice_character: str = '', voice_per_scene: List[str] = <factory>, market: str = 'global', auto_merge: bool = True, char_consistency: bool = False, duration_seconds: int = 0, technique: str = '', material: str = '', additional_instructions: str = '', account_tier: str = 'ultra', video_model_key: Optional[str] = None, enable_upscale: bool = False, resolution: str = '720p', output_folder: str = '', status: services.tabs.affiliate.service.AffiliateJobStatus = <AffiliateJobStatus.PENDING: 'pending'>, stage: services.tabs.affiliate.service.AffiliateStage = <AffiliateStage.QUEUED: 'queued'>, progress: int = 0, error_message: str = '', created_at: float = <factory>, started_at: Optional[float] = None, completed_at: Optional[float] = None, plan_data: Optional[Dict[str, Any]] = None, start_images: Optional[Dict[str, Dict[str, str]]] = None, scene_count_dispatched: int = 0, video_count: int = 0, upscale_count: int = 0, failed_count: int = 0, upscale_enabled: bool = False)"""
    title = ''
    template_key = 'hook_demo_cta'
    mode = 'direct'
    scene_count = 3
    character_ref_media_id = ''
    background_ref_media_id = ''
    work_mode = 'ingredient_ads'
    ai_decides_scene_count = True
    output_mode = 'video'
    aspect_ratio = '16:9'
    voice_language = 'vi'
    voice_character = ''
    market = 'global'
    auto_merge = True
    char_consistency = False
    duration_seconds = 0
    technique = ''
    material = ''
    additional_instructions = ''
    account_tier = 'ultra'
    video_model_key = None
    enable_upscale = False
    resolution = '720p'
    output_folder = ''
    status = <AffiliateJobStatus.PENDING: 'pending'>
    stage = <AffiliateStage.QUEUED: 'queued'>
    progress = 0
    error_message = ''
    started_at = None
    completed_at = None
    plan_data = None
    start_images = None
    scene_count_dispatched = 0
    video_count = 0
    upscale_count = 0
    failed_count = 0
    upscale_enabled = False
    product_id = <property object at 0x00000264E57C8360>
    product_name = <property object at 0x00000264E57C86D0>
    product_category = <property object at 0x00000264E57C8810>

    def start(self) -> None:
        pass

    def set_stage(self, stage: services.tabs.affiliate.service.AffiliateStage, progress: Optional[int] = None) -> None:
        pass

    def fail(self, message: str) -> None:
        pass

    def complete(self, output_folder: str = '') -> None:
        pass

    def is_terminal(self) -> bool:
        pass

    def __init__(self, id: str = <factory>, title: str = '', product: Dict[str, Any] = <factory>, template_key: str = 'hook_demo_cta', mode: str = 'direct', scene_count: int = 3, start_image_media_ids: List[str] = <factory>, character_ref_media_id: str = '', background_ref_media_id: str = '', work_mode: str = 'ingredient_ads', ai_decides_scene_count: bool = True, output_mode: str = 'video', aspect_ratio: str = '16:9', voice_language: str = 'vi', voice_character: str = '', voice_per_scene: List[str] = <factory>, market: str = 'global', auto_merge: bool = True, char_consistency: bool = False, duration_seconds: int = 0, technique: str = '', material: str = '', additional_instructions: str = '', account_tier: str = 'ultra', video_model_key: Optional[str] = None, enable_upscale: bool = False, resolution: str = '720p', output_folder: str = '', status: services.tabs.affiliate.service.AffiliateJobStatus = <AffiliateJobStatus.PENDING: 'pending'>, stage: services.tabs.affiliate.service.AffiliateStage = <AffiliateStage.QUEUED: 'queued'>, progress: int = 0, error_message: str = '', created_at: float = <factory>, started_at: Optional[float] = None, completed_at: Optional[float] = None, plan_data: Optional[Dict[str, Any]] = None, start_images: Optional[Dict[str, Dict[str, str]]] = None, scene_count_dispatched: int = 0, video_count: int = 0, upscale_count: int = 0, failed_count: int = 0, upscale_enabled: bool = False) -> None:
        pass

    def __repr__(self):
        pass


# --- Class: AffiliateJobManager ---
class AffiliateJobManager:
    def __init__(self) -> None:
        pass

    def create_job(self, *, product, template_key, mode='direct', scene_count=3, start_image_media_ids=None, character_ref_media_id='', background_ref_media_id='', work_mode='ingredient_ads', ai_decides_scene_count=True, output_mode='video', title='', aspect_ratio='16:9', voice_language='vi', voice_per_scene=None, market='global', auto_merge=True, char_consistency=False, duration_seconds=0, technique='', material='', additional_instructions='', account_tier='ultra', video_model_key=None, enable_upscale=False, resolution='720p') -> services.tabs.affiliate.service.AffiliateJob:
        pass

    def list_jobs(self) -> List[services.tabs.affiliate.service.AffiliateJob]:
        pass

    def get_job(self, job_id: str) -> Optional[services.tabs.affiliate.service.AffiliateJob]:
        pass

    def get_pending_jobs(self) -> List[services.tabs.affiliate.service.AffiliateJob]:
        pass

    def get_running_jobs(self) -> List[services.tabs.affiliate.service.AffiliateJob]:
        pass

    def remove_job(self, job_id: str) -> bool:
        pass

    def clear(self) -> None:
        pass


# --- Class: AffiliateProductStore ---
class AffiliateProductStore:
    EXTRA_SALES_FIELDS = ('function', 'uses', 'target_audience', 'pain_point', 'sell_angle', 'summary')
    LINK_FIELDS = ('product_url', 'affiliate_link', 'tiktok_product_id', 'browser_account', 'shopee_item_id', 'platform')
    OFFER_FIELDS = ('commission_rate', 'sold', 'shopee_category_id', 'shop_id', 'shop_name', 'rating', 'rating_count', 'stock', 'discount')
    PREP_FIELDS = ('prep_status',)
    SOURCE_FIELDS = ('source_paths',)

    def __init__(self):
        pass

    def _store_lock(self) -> <function RLock at 0x00000264D2775620>:
        pass

    def _load(self) -> dict:
        pass

    def _save(self):
        pass

    def add_product(self, name, brand, category, price, description, key_features, main_image_media_id='', extra_image_ids=None, **extra_fields) -> str:
        pass

    def get_product(self, product_id: str) -> Optional[dict]:
        pass

    def get_all_products(self, category_filter=None, search_text=None) -> List[dict]:
        pass

    def update_product(self, product_id: str, **kwargs) -> bool:
        pass

    def delete_product(self, product_id: str) -> bool:
        pass

    def import_products(self, products_list: list) -> int:
        pass


# --- Class: SceneBeat ---
class SceneBeat:
    """SceneBeat(role: str, beat_description: str, voice_intent: str = 'neutral')"""
    voice_intent = 'neutral'

    def __init__(self, role: str, beat_description: str, voice_intent: str = 'neutral') -> None:
        pass

    def __repr__(self):
        pass


# --- Class: AffiliateTemplate ---
class AffiliateTemplate:
    """AffiliateTemplate(key: str, label: str, icon: str, description: str, default_scene_count: int, default_chain: bool, beats: List[services.tabs.affiliate.service.SceneBeat], suited_niches: List[str] = <factory>, pacing_hint: str = '')"""
    pacing_hint = ''

    def __init__(self, key: str, label: str, icon: str, description: str, default_scene_count: int, default_chain: bool, beats: List[services.tabs.affiliate.service.SceneBeat], suited_niches: List[str] = <factory>, pacing_hint: str = '') -> None:
        pass

    def __repr__(self):
        pass


# --- Class: AffiliatePromptCallError ---
class AffiliatePromptCallError(RuntimeError):
    pass


# --- Top-Level Functions ---
def get_affiliate_product_store() -> services.tabs.affiliate.service.AffiliateProductStore:
    pass

def get_template(key: str) -> Optional[services.tabs.affiliate.service.AffiliateTemplate]:
    pass

def get_all_templates() -> List[services.tabs.affiliate.service.AffiliateTemplate]:
    pass

def get_default_template_key() -> str:
    pass

def get_templates_for_niche(niche: str) -> List[services.tabs.affiliate.service.AffiliateTemplate]:
    pass

def fit_beats_to_count(template: services.tabs.affiliate.service.AffiliateTemplate, scene_count: int) -> List[services.tabs.affiliate.service.SceneBeat]:
    pass

def call_ai_for_plan(prompt: str, *, max_output_tokens: int = 32000, temperature: Optional[float] = None, parts: Optional[List[Dict[str, Any]]] = None, required_keys: Optional[List[str]] = None, intelligence: str = '', max_parts: int = 1, completion_retries: int = 0) -> Dict[str, Any]:
    """One bounded Affiliate AI-plan call.

    ``max_parts=1`` and ``completion_retries=0`` are intentional: an Affiliate
    product has exactly Call 1 (raw-image analysis) and Call 2 (final campaign).
    Provider continuation/retry must not silently turn either logical boundary
    into several paid generations. The caller receives a hard contract error and
    the durable product stage remains retryable by the user.

    ``intelligence``: ép tier model cho call này (bố 22/7: call full phân tích ảnh
    PHẢI đi model xịn — flash35/flash36/pro, cấm lite/flash). Gateway nhận thẳng
    knob ``intelligence``; free path (aistudio direct/web) không có knob đó →
    truyền ``model`` id cụ thể qua ``tier_model``."""
    pass

def _extract_json(response: str) -> Optional[Dict[str, Any]]:
    pass

def _try_loads(s: str) -> Optional[Dict[str, Any]]:
    pass

def _clean_json(s: str) -> str:
    pass

def _desc_from_meta(meta: Optional[Dict[str, Any]], fallback: str = '') -> str:
    pass

def aspect_to_image_aspect(aspect_ratio: str) -> str:
    pass

def _system_role() -> str:
    pass

def _product_block(product: Dict[str, Any]) -> str:
    pass

def _shared_assets_block(bg_desc: str, char_desc: str, product_name: str) -> str:
    pass

def _style_block(technique: str, material: str) -> str:
    pass

def _cultural_block(market: str) -> str:
    pass

def _scenes_from_duration(duration_seconds: int) -> int:
    pass

def _scene_count_directive(duration_hint: int, ai_decides: bool) -> str:
    pass

def _product_image_meta_block(image_meta: Optional[List[Dict[str, Any]]]) -> str:
    pass

def _template_block(template: Optional[services.tabs.affiliate.service.AffiliateTemplate]) -> str:
    pass

def _language_rules(lang: str) -> str:
    pass

def _anti_hallucination() -> str:
    pass

def _additional(instructions: str) -> str:
    pass

def build_ingredient_video_prompt(*, product: Dict[str, Any], background_ref_meta: Optional[Dict[str, Any]] = None, character_ref_meta: Optional[Dict[str, Any]] = None, product_image_meta: Optional[List[Dict[str, Any]]] = None, template_key: str = 'promo_demo', technique: str = '', material: str = '', market: str = 'global', voice_language: str = 'vi', duration_hint: int = 0, ai_decides_scene_count: bool = True, additional_instructions: str = '') -> str:
    pass

def _ingredient_voice_block(lang: str, lang_name: str, no_voice: bool) -> str:
    pass

def _ingredient_scene_format(no_voice: bool = False, lang_name: str = 'Vietnamese') -> str:
    pass

def _ingredient_scene_rules(no_voice: bool = False, lang_name: str = 'Vietnamese') -> str:
    pass

def _ingredient_output_format(no_voice: bool = False) -> str:
    pass

def build_image_first_prompts(*, product: Dict[str, Any], background_ref_meta: Optional[Dict[str, Any]] = None, character_ref_meta: Optional[Dict[str, Any]] = None, product_image_meta: Optional[List[Dict[str, Any]]] = None, template_key: str = 'promo_demo', voice_language: str = 'vi', technique: str = '', material: str = '', market: str = 'global', duration_hint: int = 0, ai_decides_scene_count: bool = True, additional_instructions: str = '') -> str:
    pass

def _image_first_scene_format(lang_name: str) -> str:
    pass

def _image_first_scene_rules(lang_name: str) -> str:
    pass

def _image_first_output_format() -> str:
    pass

def build_image_prompt(*, product: Dict[str, Any], scene: Dict[str, Any], bg_desc: str = '', char_desc: str = '', technique: str = '', material: str = '', aspect_ratio: str = '9:16') -> str:
    pass

def build_plan_prompt_for_job(job) -> str:
    pass
