"""
Decompiled / Reconstructed Module: core.account_session.models
Source PyC: models.pyc
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)

# --- Class: AccountIdentity ---
class AccountIdentity:
    """AccountIdentity(account_id: 'int | None', name: 'str', email: 'str')"""
    key = <property object at 0x00000264D8ED6CA0>

    def __init__(self, account_id: 'int | None', name: 'str', email: 'str') -> None:
        pass

    def __repr__(self):
        pass


# --- Class: SessionSnapshot ---
class SessionSnapshot:
    """SessionSnapshot(identity: 'AccountIdentity', auth_cookies: 'list[dict[str, Any]]', access_token: 'str' = '', token_expires_at: 'float' = 0.0, project_id: 'str' = '', user_tier: 'str' = '', credits: 'int | None' = None, sku: 'str' = '', service_tier: 'str' = '', source: 'str' = 'db')"""
    access_token = ''
    token_expires_at = 0.0
    project_id = ''
    user_tier = ''
    credits = None
    sku = ''
    service_tier = ''
    source = 'db'
    has_token = <property object at 0x00000264D8ED6DE0>
    has_project = <property object at 0x00000264D8ED7BF0>

    def __init__(self, identity: 'AccountIdentity', auth_cookies: 'list[dict[str, Any]]', access_token: 'str' = '', token_expires_at: 'float' = 0.0, project_id: 'str' = '', user_tier: 'str' = '', credits: 'int | None' = None, sku: 'str' = '', service_tier: 'str' = '', source: 'str' = 'db') -> None:
        pass

    def __repr__(self):
        pass


# --- Class: AuthDecision ---
class AuthDecision:
    """AuthDecision(mark_dead: 'bool', rotate_browser: 'bool', retryable: 'bool', reason: 'str')"""
    def __init__(self, mark_dead: 'bool', rotate_browser: 'bool', retryable: 'bool', reason: 'str') -> None:
        pass

    def __repr__(self):
        pass

