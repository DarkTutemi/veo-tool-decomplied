"""
Decompiled / Reconstructed Module: application.upscale_budget
Source PyC: upscale_budget.pyc

Docstring:
application/upscale_budget.py — Whole-run uniform 4K video-output clamp.

Problem solved: mỗi scene/clip là một dispatched task độc lập, được credit-gate
riêng lẻ (CooldownGate.can_afford chỉ nhìn model gen; ULTRA còn bị short-circuit).
Một job dài chọn 4K có thể cạn balance giữa chừng → nửa đầu 4K, phần còn lại chết
ở tầng upscale thay vì đồng bộ về mức rẻ hơn.

Contract here: quyết định MỘT LẦN cho cả run tại seam submit duy nhất
(JobSubmissionGateway.dispatch_scene_prompts). Nếu không có account ULTRA nào
trong pool đủ `clip_count × cost(upscale_4k)` credits → hạ TOÀN BỘ run xuống
1080p (creditMapping: 1080p = 0cr cho cả hai tier nên upscale vẫn chạy tiếp).
fail-open mọi hướng dữ liệu thiếu (catalog/balance unknown → giữ nguyên 4K,
server Google vẫn là rào cuối cùng).

Video-vs-image disambiguation: ảnh batch/image-story đi cùng seam nhưng submit
với feature không phải video ('image_generation', ...) — chỉ feature VIDEO mới
được clamp. Ảnh dùng resolution 2K/4K IMAGE upsampling, nghĩa hoàn toàn khác.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['RUN_CLIP_TOTAL_KEY', 'clamp_uniform_4k_run', 'is_video_feature', 'upscale_4k_unit_cost']

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
Iterable = typing.Iterable
List = typing.List
RUN_CLIP_TOTAL_KEY = '_run_clip_total'
_VIDEO_4K_TOKENS = {'4k', '2160p', '4kuhd', 'uhd'}
_VIDEO_FEATURES = {'text_video', 'multi_asset_video', 'portrait_video', 'extend_video', 'image_video'}
_4K_QUALITY_KEYS = ('quality', 'resolution')
__all__ = ['RUN_CLIP_TOTAL_KEY', 'clamp_uniform_4k_run', 'is_video_feature', 'upscale_4k_unit_cost']

# --- Top-Level Functions ---
def is_video_feature(feature: 'Any') -> 'bool':
    pass

def _text_lower(value: 'Any') -> 'str':
    pass

def upscale_4k_unit_cost() -> 'int | None':
    pass

def _has_video_4k_intent(values: 'Iterable[Any]') -> 'bool':
    pass

def clamp_uniform_4k_run(config: 'Dict[str, Any]', cards: 'List[Dict[str, Any]]', feature: 'str' = '') -> 'bool':
    """Hạ TOÀN BỘ run video 4K → 1080p khi pool ULTRA không đủ trả `clip_count × cost`.

    Mutates `config` (config keys) và `cards` (card-level stamps thắng config khi
    flatten vào prompt — smart_dispatcher_port là card-wins) nên phải ghi đè CẢ HAI.
    Chỉ áp dụng cho feature VIDEO; feature ảnh (vd 'image_generation') bỏ qua.
    Returns True khi đã clamp."""
    pass
