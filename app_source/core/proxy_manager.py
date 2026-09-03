"""
Decompiled / Reconstructed Module: core.proxy_manager
Source PyC: proxy_manager.pyc

Docstring:
Proxy Manager - Quản lý danh sách proxy cho hệ thống

Hỗ trợ:
- HTTP/HTTPS proxy
- SOCKS4/SOCKS5 proxy
- IPv4/IPv6

Format proxy:
- ip:port
- ip:port:user:pass
- protocol://ip:port
- protocol://user:pass@ip:port

Ví dụ:
- 192.168.1.1:8080
- 192.168.1.1:8080:admin:123456
- socks5://192.168.1.1:1080
- http://admin:123456@192.168.1.1:8080
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
Dict = typing.Dict
List = typing.List
Optional = typing.Optional
Tuple = typing.Tuple

# --- Class: ProxyType ---
class ProxyType(Enum):
    _use_args_ = False
    _member_names_ = ['HTTP', 'HTTPS', 'SOCKS4', 'SOCKS5']
    _member_map_ = {'HTTP': <ProxyType.HTTP: 'http'>, 'HTTPS': <ProxyType.HTTPS: 'https'>, 'SOCKS4': <ProxyType.SOCKS4: 'socks4'>, 'SOCKS5'...
    _value2member_map_ = {'http': <ProxyType.HTTP: 'http'>, 'https': <ProxyType.HTTPS: 'https'>, 'socks4': <ProxyType.SOCKS4: 'socks4'>, 'socks5'...
    _unhashable_values_ = []
    _value_repr_ = None
    HTTP = <ProxyType.HTTP: 'http'>
    HTTPS = <ProxyType.HTTPS: 'https'>
    SOCKS4 = <ProxyType.SOCKS4: 'socks4'>
    SOCKS5 = <ProxyType.SOCKS5: 'socks5'>

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


# --- Class: ProxyStatus ---
class ProxyStatus(Enum):
    _use_args_ = False
    _member_names_ = ['UNKNOWN', 'LIVE', 'DEAD', 'CHECKING']
    _member_map_ = {'UNKNOWN': <ProxyStatus.UNKNOWN: 'unknown'>, 'LIVE': <ProxyStatus.LIVE: 'live'>, 'DEAD': <ProxyStatus.DEAD: 'dead'>, 'C...
    _value2member_map_ = {'unknown': <ProxyStatus.UNKNOWN: 'unknown'>, 'live': <ProxyStatus.LIVE: 'live'>, 'dead': <ProxyStatus.DEAD: 'dead'>, 'c...
    _unhashable_values_ = []
    _value_repr_ = None
    UNKNOWN = <ProxyStatus.UNKNOWN: 'unknown'>
    LIVE = <ProxyStatus.LIVE: 'live'>
    DEAD = <ProxyStatus.DEAD: 'dead'>
    CHECKING = <ProxyStatus.CHECKING: 'checking'>

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


# --- Class: ProxyInfo ---
class ProxyInfo:
    """Thông tin proxy"""
    proxy_type = <ProxyType.HTTP: 'http'>
    username = None
    password = None
    status = <ProxyStatus.UNKNOWN: 'unknown'>
    last_check = 0
    response_time = 0
    assigned_account = None
    fail_count = 0
    last_error = ''
    rotate_url = None
    _server_id = ''
    _display_name = ''
    key = <property object at 0x00000264D8E65300>

    def to_url(self) -> str:
        pass

    def to_requests_format(self) -> Dict[str, str]:
        pass

    def to_playwright_format(self) -> Dict:
        pass

    def to_dict(self) -> Dict:
        pass

    @classmethod
    def from_dict(cls, data: Dict) -> 'ProxyInfo':
        pass

    def __init__(self, host: str, port: int, proxy_type: core.proxy_manager.ProxyType = <ProxyType.HTTP: 'http'>, username: Optional[str] = None, password: Optional[str] = None, status: core.proxy_manager.ProxyStatus = <ProxyStatus.UNKNOWN: 'unknown'>, last_check: float = 0, response_time: float = 0, assigned_account: Optional[str] = None, fail_count: int = 0, last_error: str = '', rotate_url: Optional[str] = None, _server_id: str = '', _display_name: str = '') -> None:
        pass

    def __repr__(self):
        pass


# --- Class: ProxyManager ---
class ProxyManager:
    """Quản lý danh sách proxy"""
    _instance = None
    _lock = <unlocked _thread.lock object at 0x00000264D8E6C640>

    def __init__(self):
        pass

    def load(self) -> None:
        pass

    def save(self) -> None:
        pass

    def rotate_proxy_ip(self, proxy_key: str) -> Tuple[bool, str]:
        pass

    def rotate_all_proxies(self) -> int:
        pass

    def find_proxy_key_for_url(self, proxy_url: str) -> Optional[str]:
        pass

    def set_rotate_url(self, proxy_key: str, rotate_url: str) -> bool:
        pass

    def parse_proxy(self, proxy_str: str) -> Optional[core.proxy_manager.ProxyInfo]:
        pass

    def add_proxy(self, proxy_str: str) -> Optional[core.proxy_manager.ProxyInfo]:
        pass

    def add_proxies(self, proxy_list: List[str]) -> Tuple[int, List[str]]:
        pass

    def remove_proxy(self, proxy_key: str) -> bool:
        pass

    def get_all_proxies(self) -> List[core.proxy_manager.ProxyInfo]:
        pass

    def get_live_proxies(self) -> List[core.proxy_manager.ProxyInfo]:
        pass

    def get_dead_proxies(self) -> List[core.proxy_manager.ProxyInfo]:
        pass

    def _sync_proxy_to_account(self, account_email: str, proxy_url: str) -> None:
        pass

    def _notify_browser_proxy_changed(self, account_email: str, proxy_url: str, reason: str) -> None:
        pass

    def assign_proxy_to_account(self, account_email: str, proxy_key: str) -> bool:
        pass

    def _update_browser_proxy(self, account_email: str, proxy_info: 'ProxyInfo') -> None:
        pass

    def unassign_proxy_from_account(self, account_email: str) -> None:
        pass

    def _clear_browser_proxy(self, account_email: str) -> None:
        pass

    def get_proxy_for_account(self, account_email: str) -> Optional[core.proxy_manager.ProxyInfo]:
        pass

    def get_unassigned_proxies(self) -> List[core.proxy_manager.ProxyInfo]:
        pass

    def check_proxy(self, proxy: core.proxy_manager.ProxyInfo, timeout: int = 15) -> Tuple[bool, float, str]:
        pass

    def probe_proxy_flow_reachability(self, proxy: core.proxy_manager.ProxyInfo, timeout: int = 10) -> Dict[str, Any]:
        pass

    def mark_proxy_checked(self, key: str, is_live: bool, response_time_ms: float = 0.0, message: str = '') -> bool:
        pass

    def probe_proxy_line_autodetect(self, line: str, timeout: int = 10):
        """Probe 1 dòng proxy với Flow. Dòng bare 'ip:port[:user:pass]' (không scheme)
        → tự thử HTTP rồi SOCKS5 trên cùng host:port, trả về biến thể NÀO vào được Flow.

        Returns (verdict_dict, working_ProxyInfo | None). verdict "invalid" nếu parse fail."""
        pass

    def add_proxy_info(self, proxy: core.proxy_manager.ProxyInfo, response_time_ms: float = 0.0) -> bool:
        pass

    def probe_proxies_browser(self, proxy_infos, timeout_ms: int = 20000, max_concurrent: int = 4, on_result=None):
        pass

    def _probe_browser_async(self, proxy_infos, timeout_ms, max_concurrent, on_result=None):
        pass

    def _probe_one_browser(self, browser, info: core.proxy_manager.ProxyInfo, timeout_ms: int):
        pass

    def check_all_proxies(self, callback=None) -> Tuple[int, int]:
        pass

    def mark_proxy_failed(self, proxy_key: str) -> None:
        pass

    def auto_assign_proxies_to_accounts(self) -> int:
        pass

    def health_check_on_startup(self, timeout: int = 10) -> Tuple[int, int]:
        pass

    def get_proxy_usage_stats(self) -> Dict[str, Any]:
        pass

    def log_proxy_usage(self, account_email: str, action: str = 'API_CALL') -> None:
        pass

    def _get_device_id(self) -> str:
        pass

    def fetch_server_proxies(self, api_key: str = None) -> Tuple[bool, int, str]:
        pass

    def get_server_proxies(self) -> List[core.proxy_manager.ProxyInfo]:
        pass

    def get_server_proxy_count(self) -> int:
        pass

    def get_server_proxy_by_index(self, index: int) -> Optional[core.proxy_manager.ProxyInfo]:
        pass

    def get_server_proxy_display_list(self) -> List[Dict[str, str]]:
        pass

    def clear_server_proxies(self) -> None:
        pass

    def get_random_server_proxy(self) -> Optional[core.proxy_manager.ProxyInfo]:
        pass

    def get_next_server_proxy_round_robin(self) -> Optional[core.proxy_manager.ProxyInfo]:
        pass

    def auto_assign_server_proxies_to_accounts(self) -> Tuple[int, str]:
        pass

    def get_server_proxy_for_lite_server(self) -> Optional[str]:
        pass

    def get_display_name_for_proxy_url(self, proxy_url: str) -> Optional[str]:
        pass

    def is_auto_proxy_enabled(self) -> bool:
        pass

    def set_auto_proxy_enabled(self, enabled: bool) -> None:
        pass

    def _load_auto_proxy_setting(self) -> bool:
        pass


# --- Top-Level Functions ---
def get_proxy_manager() -> core.proxy_manager.ProxyManager:
    pass
