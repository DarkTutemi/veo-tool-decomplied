"""
Decompiled / Reconstructed Module: core.tier
Source PyC: tier.pyc

Docstring:
core/tier.py — SoT DUY NHẤT cho chuyển đổi "tier" của model.

Trước đây mỗi chỗ map tier 1 kiểu (≈8 mapper rải 6 file) → gốc của bug 0cr /
duration-mix / ultra-leak. Module này gom hết về 1 nơi. 4 cách biểu diễn tier:

- PAYGATE string : PAYGATE_TIER_TWO / PAYGATE_TIER_ONE / PAYGATE_TIER_NOT_PAID
                   (credits API + wire clientContext.userPaygateTier)
- MODE           : "ultra" / "pro"            (core/account_mode — pool + picker)
- tier_mode      : "ultra" / "premium"        (ModelConfig query)
- credit_key     : "advanced"/"intermediate"/"entry" (cột creditMapping trong model)

Quy ước: ULTRA = advanced; PRO/premium = intermediate; free/entry = entry.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
PAYGATE_ULTRA = 'PAYGATE_TIER_TWO'
PAYGATE_PRO = 'PAYGATE_TIER_ONE'
PAYGATE_FREE = 'PAYGATE_TIER_NOT_PAID'
MODE_ULTRA = 'ultra'
MODE_PRO = 'pro'
TIER_MODE_ULTRA = 'ultra'
TIER_MODE_PREMIUM = 'premium'
CREDIT_ADVANCED = 'advanced'
CREDIT_INTERMEDIATE = 'intermediate'
CREDIT_ENTRY = 'entry'
_TO_CREDIT_KEY = {'ultra': 'advanced', 'advanced': 'advanced', 'paygate_tier_two': 'advanced', 'service_tier_advanced': 'advanced', 'premium': 'intermediate', 'intermediate': 'intermediate', 'pro': 'intermediate', 'pa... [truncated]

# --- Top-Level Functions ---
def paygate_to_tier_mode(paygate: 'str') -> 'str':
    pass

def mode_to_tier_mode(mode: 'str') -> 'str':
    pass

def to_credit_key(tier: 'str') -> 'str':
    pass

def credit_key_to_service_tier(credit_key: 'str') -> 'str':
    pass
