"""
Decompiled / Reconstructed Module: core.captcha.account_normalizer
Source PyC: account_normalizer.pyc

Docstring:
Normalize AccountManager account objects for captcha runtimes.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Optional = typing.Optional
_ACCOUNT_FIELDS = ('id', 'name', 'email', 'project_id', 'tier', 'auth_cookies', 'proxy', 'proxy_country', 'country', 'proxy_country_code', 'token_expires', 'status', 'enabled', 'profile_name')

# --- Top-Level Functions ---
def account_to_dict(account: 'Any') -> 'dict':
    pass

def resolve_account(identifier: 'Optional[str]', fallback: 'Any' = None) -> 'dict':
    pass

def account_key(account: 'Any') -> 'str':
    pass

def account_runtime_eligible(account: 'Any') -> 'bool':
    pass
