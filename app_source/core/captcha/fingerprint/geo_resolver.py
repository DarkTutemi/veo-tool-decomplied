"""
Decompiled / Reconstructed Module: core.captcha.fingerprint.geo_resolver
Source PyC: geo_resolver.pyc

Docstring:
Resolve timezone and locale from proxy country code.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
COUNTRY_TO_TZ = {'VN': 'Asia/Ho_Chi_Minh', 'US': 'America/New_York', 'GB': 'Europe/London', 'DE': 'Europe/Berlin', 'FR': 'Europe/Paris', 'JP': 'Asia/Tokyo', 'KR': 'Asia/Seoul', 'SG': 'Asia/Singapore', 'AU': 'Australi... [truncated]
COUNTRY_TO_LOCALE = {'VN': 'vi-VN', 'US': 'en-US', 'GB': 'en-GB', 'DE': 'de-DE', 'FR': 'fr-FR', 'JP': 'ja-JP', 'KR': 'ko-KR', 'SG': 'en-SG', 'AU': 'en-AU', 'CA': 'en-CA', 'TH': 'th-TH', 'CN': 'zh-CN', 'ES': 'es-ES', 'NZ'... [truncated]

# --- Top-Level Functions ---
def resolve_from_proxy(proxy_country: 'str | None') -> 'tuple[str, str]':
    pass

def locale_to_languages(locale: 'str | None') -> 'list[str]':
    pass

def build_accept_language(languages: 'list[str] | tuple[str, ...] | None') -> 'str':
    pass

def infer_country_from_timezone(timezone: 'str | None') -> 'str | None':
    pass

def detect_local_geo() -> 'tuple[str, str]':
    pass
