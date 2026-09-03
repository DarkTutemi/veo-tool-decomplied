"""
Decompiled / Reconstructed Module: core.labs_api.projects
Source PyC: projects.pyc

Docstring:
core/labs_api/projects.py — Flow project list/create over httpx (cookie-auth).

The labs.google tRPC project endpoints (``project.searchUserProjects`` /
``project.createProject``) are plain NextAuth cookie-authed GET/POST — no
reCAPTCHA, no browser required. This replaces the old session-probe browser path
(open Chrome → ``page.evaluate(fetch(...))`` → read cookies from the on-disk
profile), which hinged on a fragile Windows profile-dir rename right after login
and routinely 401'd on a fresh/empty profile.

Mirrors the proven httpx pattern in ``api_client.call_flow_create_entity_api``:
``trpc_cookie_dict`` cookies + ``get_httpx_proxy`` + ``httpx.Client(proxy=...)``.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
List = typing.List
Optional = typing.Optional
Tuple = typing.Tuple
_TRPC_BASE = 'https://labs.google/fx/api/trpc'
_TIMEOUT = 30.0
_HEADERS = {'Content-Type': 'application/json', 'origin': 'https://labs.google', 'referer': 'https://labs.google/'}

# --- Top-Level Functions ---
def list_projects(cookies: 'Dict[str, str]', *, tool_name: 'str' = 'PINHOLE', page_size: 'int' = 20, account_email: 'Optional[str]' = None) -> 'Tuple[int, List[Dict[str, Any]]]':
    pass

def _parse_create_project(response_json: 'Any') -> 'str':
    pass

def create_project(cookies: 'Dict[str, str]', *, tool_name: 'str' = 'PINHOLE', title: 'Optional[str]' = None, account_email: 'Optional[str]' = None) -> 'Tuple[int, str]':
    pass
