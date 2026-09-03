"""
Decompiled / Reconstructed Module: services.tabs.home.home_content_service
Source PyC: home_content_service.pyc

Docstring:
HomeContentService — Fetches home page content from server, caches locally.

Usage:
    from services.tabs.home.home_content_service import get_home_content_service
    svc = get_home_content_service()
    data = svc.get_content()  # dict with hero, banners, announcements, news, tips, social_links
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
Optional = typing.Optional
DEFAULT_CONTENT = {'hero': {'title': 'VeoFlow', 'subtitle': 'AI Video Generation Platform', 'bg_image_url': None}, 'banners': [], 'announcements': [{'text': 'Welcome to VeoFlow!', 'color': '#3b82f6', 'icon': 'info'}, {... [truncated]
_instance = None

# --- Class: HomeContentService ---
class HomeContentService:
    """Fetch + cache home content from server."""
    CACHE_FILE = 'home_content_cache.json'
    CACHE_TTL = 60

    def __init__(self):
        pass

    def get_content(self) -> dict:
        pass

    def get_content_blocking(self, timeout: int = 5) -> dict:
        pass

    def _fetch_background(self):
        pass

    def _fetch_from_server(self, timeout: int = 8) -> Optional[dict]:
        pass

    def _get_cache_path(self) -> str:
        pass

    def _load_cache(self) -> Optional[dict]:
        pass

    def _save_cache(self, data: dict):
        pass


# --- Top-Level Functions ---
def get_home_content_service() -> services.tabs.home.home_content_service.HomeContentService:
    pass
