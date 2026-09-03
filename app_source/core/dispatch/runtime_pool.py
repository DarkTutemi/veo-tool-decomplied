"""
Decompiled / Reconstructed Module: core.dispatch.runtime_pool
Source PyC: runtime_pool.pyc

Docstring:
core/dispatch/runtime_pool.py — RuntimePoolPolicy

Giới hạn số account được phép chạy job đồng thời ("runtime set") và XOAY VÒNG
khi account hết khả năng TẠO VIDEO (Google từ chối job video: user_quota_reached
/ credits), không phải khi đếm hết credit local. Account drained rời active set,
vẫn Live: ảnh/char-gen + locked extend/upscale về đúng nhà.

Vì sao filter nằm ở pick thay vì ở roster (build_account_slots):
- Roster giữ ĐỦ account Live+enabled → locked_account_key (extend/upscale, media
  gắn project của account đó) vẫn pick được account của nó kể cả khi account đang
  standby / drained — nếu lọc ở roster, job locked sẽ chờ account không bao giờ
  vào pool.
- Job video paid bị chặn ở pick_account/pick_alternative → hàng chờ không bao
  giờ bị kéo standby vào chạy ngầm qua MIGRATE hay preferred_key.

Trạng thái persist qua JSONSettingsManager (category "runtime_pool") nên restart
app không reset về account đầu danh sách. `drained` là sổ "hết khả năng video":
sweep chỉ revive account đang disabled (0cr path cũ) hoặc drained đã già hơn
CAPABILITY_READMIT_SECONDS; leftover credit không được coi là đã hồi.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
List = typing.List
Optional = typing.Optional
CATEGORY = 'runtime_pool'
STATE_KEY = 'state'
MIN_ACTIVE = 1
MAX_ACTIVE_LIMIT = 5
DEFAULT_MAX_ACTIVE = 2
HISTORY_MAX = 20
VIDEO_CAPABILITY_LOSS_CATEGORIES = frozenset({'credits', 'user_quota_reached'})
_FREE_IMAGE_FEATURES = frozenset({'character_generation', 'image_generation'})
CAPABILITY_READMIT_SECONDS = 21600
_INSTANCE = None
_INSTANCE_LOCK = <unlocked _thread.lock object at 0x00000264DB255F00>

# --- Class: RuntimePoolPolicy ---
class RuntimePoolPolicy:
    """Active-set cap + rotation state. Thread-safe (dispatch + AM + controller threads)."""
    def __init__(self, settings_manager: 'Any' = None) -> 'None':
        pass

    def _load(self) -> 'None':
        pass

    def _persist_locked(self) -> 'None':
        pass

    def _note_locked(self, text: 'str') -> 'None':
        pass

    def is_enabled(self) -> 'bool':
        pass

    def set_enabled(self, on: 'bool') -> 'None':
        pass

    def max_active(self) -> 'int':
        pass

    def set_max_active(self, n: 'int') -> 'None':
        pass

    def allowed_keys(self, universe: 'List[str]') -> 'Optional[set]':
        pass

    def _next_candidate_locked(self, eligible: 'List[str]') -> 'Optional[str]':
        pass

    def mark_drained(self, email: 'str', reason: 'str' = '') -> 'None':
        pass

    def drain_candidates(self) -> 'List[str]':
        pass

    def drain_age_seconds(self, email: 'str') -> 'float':
        pass

    def clear_drained(self, email: 'str') -> 'None':
        pass

    def snapshot(self) -> 'Dict[str, Any]':
        pass

    def pool_state_for(self, email: 'str') -> 'str':
        pass


# --- Top-Level Functions ---
def get_runtime_pool_policy() -> 'RuntimePoolPolicy':
    pass

def should_drain_for_video_loss(category: 'str', feature: 'str' = '', is_ultra: 'bool' = False) -> 'bool':
    pass

def note_video_capability_loss(account: 'Any', handle: 'Any', category: 'str') -> 'bool':
    pass
