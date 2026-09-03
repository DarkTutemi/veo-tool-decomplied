"""
Decompiled / Reconstructed Module: application.job_asset_replace
Source PyC: job_asset_replace.pyc

Docstring:
Thay/gắn ảnh asset cho 1 slot của job — DÙNG CHUNG cho mọi tab có job panel.

Logic generic theo get_job_store(): slotIndex khớp strip card (thứ tự
multi_asset_info.assets). Object/ảnh ref và CHAR không entity: ghi library id.
CHAR đã voice-lock (flow_character_ids): trỏ sang MEDIA_<library_id> — account
lúc request ensure entity (chưa có thì tạo). KHÔNG auto-regen.

Job không có multi_asset_info (vd clone/transcript thuần) -> trả 'empty_slot'
một cách an toàn, không crash.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
_ACTION = 'queue.replace_asset'

# --- Top-Level Functions ---
def replace_job_asset(row_id: 'str', slot_index: 'int', media_id: 'str') -> 'Dict[str, Any]':
    pass

def _media_has_flow_voice(media: 'dict') -> 'bool':
    pass

def _is_character_library_item(media: 'dict') -> 'bool':
    pass

def _materialize_voice_locked_library_character(media_id: 'str', media: 'dict') -> 'dict[str, Any]':
    pass

def _kick_character_presync(flow_id: 'str') -> 'None':
    pass

def _is_flow_entity_character(meta: 'dict', logical_id: 'str') -> 'bool':
    pass

def _patch_list(values: 'list', index: 'int', item) -> 'list':
    pass

def _patch_replay_library_intent(meta: 'dict', index: 'int', library_id: 'str', path: 'str', logical_id: 'str' = '') -> 'None':
    pass

def _flow_id_matches_logical(flow_id: 'str', logical_id: 'str') -> 'bool':
    pass

def _patch_replay_character_pointer(meta: 'dict', logical_id: 'str', *, flow_id: 'str', library_id: 'str', path: 'str') -> 'None':
    pass
