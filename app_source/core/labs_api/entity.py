"""
Decompiled / Reconstructed Module: core.labs_api.entity
Source PyC: entity.pyc

Docstring:
core/labs_api/entity.py — Flow character entity creation, patching, image upload.

Entity lifecycle:
  1. create_entity → TRPC flow.createEntity (projectId) → entityId
  2. patch_entity → PATCH /v1/flow/entities (token + entity payload) → updated state
  3. upload_character_image → upload base64/media to entity image slot
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
Optional = typing.Optional

# --- Top-Level Functions ---
def create_entity(*, account_name: 'Optional[str]' = None, account_email: 'Optional[str]' = None, project_id: 'Optional[str]' = None, tool_name: 'str' = 'PINHOLE') -> 'Dict[str, Any]':
    pass

def _create_entity_via_httpx(account_key: 'str', url: 'str', payload: 'Dict[str, Any]') -> 'Dict[str, Any]':
    pass

def patch_entity(*, payload: 'Dict[str, Any]', account_name: 'Optional[str]' = None, account_email: 'Optional[str]' = None) -> 'Dict[str, Any]':
    pass

def upload_character_image(*, account: 'Dict[str, Any]', entity_id: 'str', media_id: 'str' = '', base64_data: 'str' = '', mime_type: 'str' = '', filename: 'str' = '', slot_index: 'int' = 0) -> 'Dict[str, Any]':
    pass

def copy_project_media(*, media_id: 'str', destination_project_id: 'str', destination_entity_id: 'str', image_reference_index: 'int' = 0, account_name: 'Optional[str]' = None, account_email: 'Optional[str]' = None) -> 'Dict[str, Any]':
    pass
