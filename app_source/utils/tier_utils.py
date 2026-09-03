"""
Decompiled / Reconstructed Module: utils.tier_utils

Docstring:
Tier Utilities - Single Source of Truth for Account Tier Management
Centralized tier detection and Ultra account validation
"""

from __future__ import annotations
import sys, os, typing
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['TIER_ULTRA', 'TIER_PRO', 'TIER_FREE', 'is_free_account', 'has_paid_tier_evidence', 'PAYGATE_TIER_LABELS', 'SKU_TIER_LABELS', 'SERVICE_TIER_LABELS', 'classify_account_tier', 'get_account_tier', 'is_ultra_account', 'is_premium_account', 'can_generate_video', 'get_user_tier_for_api', 'resolve_account_tier_by_identity', 'get_ultra_accounts', 'get_premium_accounts', 'get_live_ultra_accounts', 'get_live_premium_accounts', 'validate_account_for_generation', 'TierRefreshManager', 'start_tier_refresh_manager', 'stop_tier_refresh_manager']

# --- Module Constants & Globals ---
Dict = typing.Dict
Optional = typing.Optional
List = typing.List
DUAL_TIER_ENABLED = False
TIER_ULTRA = 'ULTRA'
TIER_PRO = 'PRO'
TIER_FREE = 'FREE'
PAYGATE_TIER_LABELS = {'PAYGATE_TIER_TWO': 'ULTRA', 'PAYGATE_TIER_ONE': 'PRO', 'PAYGATE_TIER_NOT_PAID': 'FREE'}
SKU_TIER_LABELS = {'G1_TIER2': 'ULTRA', 'WS_ULTRA': 'ULTRA', 'G1_TIER1': 'PRO', 'G1_TIER1P5': 'PRO', 'WS_PRO': 'PRO', 'WS_GEMNOVA': 'PRO', 'G1_TIER0': 'FREE', 'WS_FREEMIUM': 'FREE'}
SERVICE_TIER_LABELS = {'SERVICE_TIER_ADVANCED': 'ULTRA', 'SERVICE_TIER_INTERMEDIATE': 'PRO', 'SERVICE_TIER_ENTRY': 'FREE'}
_PAID_SKU_SIGNALS = frozenset({'WS_PRO', 'G1_TIER1P5', 'WS_GEMNOVA', 'WS_ULTRA', 'G1_TIER2', 'G1_TIER1'})
_PAID_SERVICE_TIER_SIGNALS = frozenset({'SERVICE_TIER_ADVANCED', 'SERVICE_TIER_INTERMEDIATE'})
_tier_refresh_manager = None
__all__ = ['TIER_ULTRA', 'TIER_PRO', 'TIER_FREE', 'is_free_account', 'has_paid_tier_evidence', 'PAYGATE_TIER_LABELS', 'SKU_TIER_LABELS', 'SERVICE_TIER_LABELS', 'classify_account_tier', 'get_account_tier', 'is_u... [truncated]

# --- Class: TierRefreshManager ---
class TierRefreshManager:
    """
    Background manager to periodically refresh account tiers
        Ensures tier information stays up-to-date
    """
    def __init__(self, main_window, refresh_interval: int = 1800):
        # [PyArmor BCC constants]: 'main_window', 'refresh_interval', False, 'running', 'thread'
        pass

    def start(self):
        # [PyArmor BCC constants]: 'running', 'print', '⚠️ [TIER_REFRESH] Already running', True, 'threading', 'Thread', 'target', '_refresh_loop', 'daemon', 'thread', 'start', '🔄 [TIER_REFRESH] Started (interval: ', 'refresh_interval', 's)'
        pass

    def stop(self):
        # [PyArmor BCC constants]: False, 'running', 'print', '🛑 [TIER_REFRESH] Stopped'
        pass

    def _refresh_loop(self):
        # [PyArmor BCC constants]: 'running', 'time', 'sleep', 'refresh_interval', '_refresh_all_tiers'
        pass

    def _refresh_all_tiers(self):
        # [PyArmor BCC constants]: 'hasattr', 'main_window', 'accounts', 'get', 'status', 'Live', 'enabled', True, 'is_free_account', 'print', '🔄 [TIER_REFRESH] Refreshing ', 'len', ' Live accounts...', 0, '_refresh_tier'
        pass

    def _refresh_tier(self, account: Dict) -> bool:
        # [PyArmor BCC constants]: 'get_credits', 'get', 'name', 'email', False, 'account_name', 'userPaygateTier', 'PAYGATE_TIER_TWO', 'is_ultra_account', 'credits', 'unknown', 'print', '🔄 [TIER_REFRESH] ', ': ', ' → '
        pass


# --- Top-Level Functions ---
def classify_account_tier(account: Dict) -> str:
    # [PyArmor BCC constants]: 'str', 'get', 'userPaygateTier', 'tier', '', 'strip', 'upper', 'PAYGATE_TIER_LABELS', 'sku', 'SKU_TIER_LABELS', 'serviceTier', 'service_tier', 'SERVICE_TIER_LABELS', 'ULTRA', 'TIER_ULTRA'
    pass

def is_free_account(account: Dict) -> bool:
    pass

def has_paid_tier_evidence(account: Dict) -> bool:
    # [PyArmor BCC constants]: 'str', 'get', 'sku', '', 'strip', 'upper', '_PAID_SKU_SIGNALS', True, 'serviceTier', 'service_tier', '_PAID_SERVICE_TIER_SIGNALS', 'userPaygateTier', 'tier'
    pass

def get_account_tier(account: Dict, check_api: bool = False) -> str:
    # [PyArmor BCC constants]: 'get', 'userPaygateTier', 'get_credits', 'name', 'email', 'account_name', 'PAYGATE_TIER_TWO', True, 'is_ultra_account', 'print', '⚠️ [TIER_UTILS] Error checking API for tier: ', 'Exception', 'PAYGATE_TIER_ONE'
    pass

def is_ultra_account(account: Dict, check_api: bool = False) -> bool:
    # [PyArmor BCC constants]: 'get', 'userPaygateTier', '', 'PAYGATE_TIER_TWO', True, 'is_ultra_account', 'get_account_tier', 'check_api', False
    pass

def is_premium_account(account: Dict) -> bool:
    # [PyArmor BCC constants]: 'is_free_account', False, 'get', 'sku', '', 'serviceTier', 'userPaygateTier', 'WS_FREEMIUM', 'SERVICE_TIER_ENTRY', 'PAYGATE_TIER_TWO', True
    pass

def can_generate_video(account: Dict) -> bool:
    pass

def get_user_tier_for_api(account: Dict) -> str:
    # [PyArmor BCC constants]: 'is_ultra_account', 'PAYGATE_TIER_TWO', 'is_premium_account', 'PAYGATE_TIER_NOT_PAID', 'get', 'userPaygateTier'
    pass

def resolve_account_tier_by_identity(account_name: Optional[str] = None, account_email: Optional[str] = None) -> str:
    # [PyArmor BCC constants]: 'get_account_manager', 'get_account_by_email_dict', 'get_account_by_name_dict', 'hasattr', 'getattr', 'get_user_tier_for_api', 'dict', '', 'Exception'
    pass

def get_premium_accounts(accounts: List[Dict]) -> List[Dict]:
    pass

def get_live_premium_accounts(accounts: List[Dict]) -> List[Dict]:
    # [PyArmor BCC constants]: 'get', 'status', 'Live', 'enabled', True, 'is_premium_account'
    pass

def get_ultra_accounts(accounts: List[Dict], check_api: bool = False) -> List[Dict]:
    pass

def get_live_ultra_accounts(accounts: List[Dict], check_api: bool = False) -> List[Dict]:
    # [PyArmor BCC constants]: 'get', 'status', 'Live', 'enabled', True, 'is_ultra_account', 'check_api'
    pass

def validate_account_for_generation(account: Dict) -> tuple[bool, str]:
    # [PyArmor BCC constants]: 'get', 'status', 'Live', False, 'Account status: ', ' (not Live)', 'can_generate_video'
    pass

def start_tier_refresh_manager(main_window, refresh_interval: int = 1800):
    # [PyArmor BCC constants]: '_tier_refresh_manager', 'print', '⚠️ [TIER_REFRESH] Manager already exists', 'TierRefreshManager', 'start'
    pass

def stop_tier_refresh_manager():
    pass
