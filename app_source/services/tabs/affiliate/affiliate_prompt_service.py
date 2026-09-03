"""
Decompiled / Reconstructed Module: services.tabs.affiliate.affiliate_prompt_service
Source PyC: affiliate_prompt_service.pyc

Docstring:
Affiliate market → voice/language lookup tables.

Historically this module also held ``AffiliatePromptService`` (the preview-path
prompt builder) and the ``AffiliateScriptRequest/Result/SceneResult`` dataclasses.
That fork was unified into ``services.tabs.affiliate.sales_architect``
(``AffiliateSalesArchitect``) — both the live-dispatch path
(``queue_service._run_live_batch``) and the preview path
(``work_panel/affiliate._affiliate_run_generate_script``) now build their plan
through that single architect. Only the market/language lookup tables remain here.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
List = typing.List
Mapping = typing.Mapping
MARKET_VOICE_MAP = {'vn': 'vi', 'us': 'en', 'uk': 'en', 'jp': 'ja', 'kr': 'ko', 'cn': 'zh', 'tw': 'zh', 'th': 'th', 'id': 'id', 'my': 'id', 'ph': 'en', 'sg': 'en', 'global': 'en'}
MARKET_LABEL_MAP = {'vn': 'Việt Nam', 'us': 'United States', 'uk': 'United Kingdom', 'jp': 'Japan', 'kr': 'Korea', 'cn': 'China', 'tw': 'Taiwan', 'th': 'Thailand', 'id': 'Indonesia', 'my': 'Malaysia', 'ph': 'Philippines... [truncated]
MARKETS = [{'key': 'vn', 'label': 'Việt Nam', 'voice_language': 'vi'}, {'key': 'us', 'label': 'United States', 'voice_language': 'en'}, {'key': 'uk', 'label': 'United Kingdom', 'voice_language': 'en'}, {'key': ... [truncated]
BRIEF_TONES = ['warm_friendly', 'urgent_salesy', 'educational', 'playful', 'premium_luxury', 'casual_ugc']

# --- Top-Level Functions ---
def market_to_voice_language(market: 'str') -> 'str':
    pass

def effective_voice_language(config: 'Mapping[str, Any] | None', market: 'str' = '') -> 'str':
    pass
