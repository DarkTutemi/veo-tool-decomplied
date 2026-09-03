"""
Decompiled / Reconstructed Module: core.browser.proxy_utils
Source PyC: proxy_utils.pyc

Docstring:
Proxy parsing helpers for the browser runtime.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Optional = typing.Optional
SUPPORTED_PROXY_SCHEMES = {'socks5h', 'http', 'socks5', 'socks4', 'https'}
SOCKS_PROXY_SCHEMES = {'socks5h', 'socks5', 'socks4'}

# --- Class: NormalizedProxy ---
class NormalizedProxy:
    """NormalizedProxy(scheme: 'str', host: 'str', port: 'int', username: 'Optional[str]' = None, password: 'Optional[str]' = None)"""
    username = None
    password = None
    is_socks = <property object at 0x00000264DA577A10>
    browser_scheme = <property object at 0x00000264DA590680>

    def _host_for_url(self) -> 'str':
        pass

    def to_url(self) -> 'str':
        pass

    def to_playwright_proxy(self) -> 'dict[str, Any]':
        pass

    def __init__(self, scheme: 'str', host: 'str', port: 'int', username: 'Optional[str]' = None, password: 'Optional[str]' = None) -> None:
        pass

    def __repr__(self):
        pass


# --- Top-Level Functions ---
def parse_proxy_value(proxy: 'Any', default_scheme: 'str' = 'http') -> 'Optional[NormalizedProxy]':
    pass

def normalize_proxy_url(proxy: 'Any', default_scheme: 'str' = 'http') -> 'Optional[str]':
    pass

def build_playwright_proxy_config(proxy: 'Any', default_scheme: 'str' = 'http') -> 'Optional[dict[str, Any]]':
    pass

def build_chrome_proxy_arg(proxy: 'Any', default_scheme: 'str' = 'http') -> 'Optional[str]':
    pass

def proxy_route_for_log(proxy: 'Any', default_scheme: 'str' = 'http') -> 'str':
    pass

def mask_proxy_url(proxy: 'Any', default_scheme: 'str' = 'http') -> 'str':
    pass

def _parse_host_port(value: 'str') -> 'tuple[str, int]':
    pass

def _parse_colon_proxy(value: 'str') -> 'tuple[str, int, Optional[str], Optional[str]]':
    pass
