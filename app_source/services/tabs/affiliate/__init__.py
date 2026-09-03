"""
Decompiled / Reconstructed Module: services.tabs.affiliate.__init__
Source PyC: __init__.pyc

Docstring:
Affiliate services for the affiliate video tab.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['AFFILIATE_TEMPLATES', 'MODE_DIRECT', 'MODE_INGREDIENT', 'MODE_NANOBANANA', 'OUTPUT_IMAGE', 'OUTPUT_VIDEO', 'PRODUCT_CATEGORIES', 'VALID_MODES', 'VALID_WORK_MODES', 'WORK_MODE_IMAGE_FIRST', 'WORK_MODE_INGREDIENT_ADS', 'AffiliateJob', 'AffiliateJobManager', 'AffiliateJobStatus', 'AffiliateProductStore', 'AffiliatePromptCallError', 'AffiliateStage', 'AffiliateTemplate', 'SceneBeat', '_scenes_from_duration', 'aspect_to_image_aspect', 'build_image_first_prompts', 'build_image_prompt', 'build_ingredient_video_prompt', 'build_plan_prompt_for_job', 'call_ai_for_plan', 'fit_beats_to_count', 'get_affiliate_product_store', 'get_all_templates', 'get_default_template_key', 'get_template', 'get_templates_for_niche']

# --- Module Constants & Globals ---
AFFILIATE_TEMPLATES = {'ai_auto': AffiliateTemplate(key='ai_auto', label='AI tự chọn template', icon='robot', description='Để AI phân tích sản phẩm và chọn template phù hợp nhất (hook · review · reveal · demo · unboxing · ... [truncated]
MODE_DIRECT = 'direct'
MODE_INGREDIENT = 'ingredient'
MODE_NANOBANANA = 'nanobanana'
OUTPUT_IMAGE = 'image'
OUTPUT_VIDEO = 'video'
PRODUCT_CATEGORIES = [('cosmetics', 'Mỹ phẩm'), ('fashion', 'Thời trang'), ('electronics', 'Điện tử'), ('home', 'Gia dụng'), ('food', 'Thực phẩm'), ('sports', 'Thể thao'), ('beauty', 'Làm đẹp'), ('health', 'Sức khỏe'), ('... [truncated]
VALID_MODES = {'direct', 'nanobanana', 'ingredient'}
VALID_WORK_MODES = {'ingredient_ads', 'image_first_ads'}
WORK_MODE_IMAGE_FIRST = 'image_first_ads'
WORK_MODE_INGREDIENT_ADS = 'ingredient_ads'
__all__ = ['AFFILIATE_TEMPLATES', 'MODE_DIRECT', 'MODE_INGREDIENT', 'MODE_NANOBANANA', 'OUTPUT_IMAGE', 'OUTPUT_VIDEO', 'PRODUCT_CATEGORIES', 'VALID_MODES', 'VALID_WORK_MODES', 'WORK_MODE_IMAGE_FIRST', 'WORK_MOD... [truncated]
