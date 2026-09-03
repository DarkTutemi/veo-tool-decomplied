"""
Decompiled / Reconstructed Module: services.shared.publishing.publish_kit
Source PyC: publish_kit.pyc

Docstring:
Publish Kit — bộ quy tắc CHUNG sinh tiêu đề / mô tả / thumbnail cho mọi pipeline.

Contract (Master / Clone / Audio-to-Video / Affiliate / Time Machine):

- INJECT — `build_publish_kit_rules(placement_line, style_hint=...)` chèn vào PROMPT
  CỦA CALL 1, tức call duy nhất đã XEM/NGHE TOÀN BỘ nội dung (master: architect
  nghiên cứu xong kịch bản; clone: xem cả video nguồn; transcript: Pass-0/unified
  nghe cả audio). Model trả `publish_kit` {title, description, thumbnail_prompt}
  ngay trong response chính — KHÔNG có call phụ tóm-tắt-lại (call phụ mất context
  là chính nội dung, ra metadata sơ sài).
- EXTRACT — `extract_publish_kit(result_data)` đọc kit ở top-level hoặc trong
  `content_profile` (clone/transcript đặt trong content_profile vì key này sống
  qua gateway Phase-0/block-merge; master đặt top-level trong RESOURCE_PLAN_JSON).
- FINALIZE — `save_publish_kit_async(result_data, session_folder, ...)` chỉ được gọi
  sau khi route có output thật. Publish Director đọc draft + scene/timestamp + refs
  consistency + video cuối; LLM đặt concept mạnh nhất trước và tự chọn chính xác
  reference cần dùng. Backend gửi nguyên prompt/reference đó sang image model, không
  tự chọn asset, chấm nội dung hay đổi concept. Trạng thái nằm trong
  `publish_kit_status.json` để retry.
- GENERATE — Google Labs đi trước; gateway trả phí chỉ là fallback.
  Character/product/hook-frame refs được upload/reuse tối đa ba ingredient. Image
  model tạo cả hình lẫn chữ; app không render hoặc sửa typography cục bộ.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['PUBLISH_INFO_FILENAME', 'THUMBNAIL_BASENAME', 'build_publish_kit_rules', 'ensure_publish_kit', 'extract_publish_kit', 'normalize_publish_kit', 'normalize_publish_aspect_ratio', 'resolve_publish_aspect_ratio', 'resolve_publish_style_hint', 'save_publish_kit', 'save_publish_kit_result', 'save_publish_kit_async', 'style_hint_from_package']

# --- Module Constants & Globals ---
Callable = typing.Callable
Dict = typing.Dict
Mapping = typing.Mapping
_KIT_FIELDS = ('title', 'description', 'thumbnail_prompt')
_KIT_LIST_FIELDS = ('title_candidates', 'hashtags', 'youtube_tags', 'primary_keywords', 'chapters', 'thumbnail_candidates')
_KIT_MAPPING_FIELDS = ('publish_brief', 'thumbnail', 'thumbnail_validation', 'quality_scores')
PUBLISH_INFO_FILENAME = 'publish_info.txt'
PUBLISH_JSON_FILENAME = 'publish_kit.json'
PUBLISH_STATUS_FILENAME = 'publish_kit_status.json'
THUMBNAIL_BASENAME = 'thumbnail'
_IMAGE_ASPECT_BY_RATIO = {'16:9': 'IMAGE_ASPECT_RATIO_LANDSCAPE', '4:3': 'IMAGE_ASPECT_RATIO_LANDSCAPE_FOUR_THREE', '1:1': 'IMAGE_ASPECT_RATIO_SQUARE', '3:4': 'IMAGE_ASPECT_RATIO_PORTRAIT_THREE_FOUR', '9:16': 'IMAGE_ASPECT_RA... [truncated]
_RATIO_BY_ASPECT_ALIAS = {'16:9': '16:9', '4:3': '4:3', '1:1': '1:1', '3:4': '3:4', '9:16': '9:16', 'IMAGE_ASPECT_RATIO_LANDSCAPE': '16:9', 'IMAGE_ASPECT_RATIO_LANDSCAPE_FOUR_THREE': '4:3', 'IMAGE_ASPECT_RATIO_SQUARE': '1:1',... [truncated]
__all__ = ['PUBLISH_INFO_FILENAME', 'THUMBNAIL_BASENAME', 'build_publish_kit_rules', 'ensure_publish_kit', 'extract_publish_kit', 'normalize_publish_kit', 'normalize_publish_aspect_ratio', 'resolve_publish_aspe... [truncated]

# --- Top-Level Functions ---
def _safe_print(*values: Any, **kwargs: Any) -> None:
    """Logging must never abort a publishing job on a legacy Windows codepage."""
    pass

def print(*values: Any, **kwargs: Any) -> None:
    """Logging must never abort a publishing job on a legacy Windows codepage."""
    pass

def normalize_publish_aspect_ratio(value: Any, default: str = '') -> str:
    pass

def resolve_publish_aspect_ratio(data: Any, explicit_ratio: Any = '') -> str:
    pass

def _clean_text_list(value: Any) -> list[str]:
    pass

def normalize_publish_kit(raw: Any) -> Dict[str, Any]:
    pass

def style_hint_from_package(style_package: Any) -> str:
    pass

def resolve_publish_style_hint(data: Any, *, explicit_hint: str = '') -> str:
    """Resolve the real production style without inventing a thumbnail default.

    The final director is shared by several routes whose snapshots store style
    evidence under different compatibility keys. Prefer resolved packages, then
    resolve stored ids/config, and use the caller's text only as a final piece of
    evidence. Empty means "derive from actual source/scene references", never
    "apply generic cinematic editorial styling"."""
    pass

def ensure_publish_kit(data: Any, *, seed_text: str = '', default_title: str = 'VeoFlow Video') -> Dict[str, Any]:
    pass

def build_publish_kit_rules(placement_line: str, style_hint: str = '', language_hint: str = '', reference_thumbnail: bool = False, rich_contract: bool = True) -> str:
    pass

def extract_publish_kit(data: Any) -> Dict[str, Any]:
    """Đọc publish_kit từ result_data của bất kỳ route nào.

    Ưu tiên top-level `publish_kit`, rồi `content_profile.publish_kit`.
    Trả {} khi không có gì dùng được (thiếu cả 3 field)."""
    pass

def _normalize_source_ref(source_image_ref: Any, source_image_path: str) -> Dict[str, Any]:
    pass

def _normalize_source_refs(source_image_ref: Any = None, source_image_refs: Any = None) -> list[typing.Dict[str, typing.Any]]:
    pass

def _source_path(source_ref: Optional[Mapping[str, Any]]) -> str:
    pass

def _source_mime_type(source_ref: Optional[Mapping[str, Any]]) -> str:
    pass

def save_publish_kit_result(data: Any, session_folder: str, *, generate_thumbnail: bool = True, aspect_ratio: str = '', source_image_path: str = '', source_image_ref: Any = None, source_account_name: str = '', image_model: str = '') -> Dict[str, Any]:
    """Persist the kit; route every thumbnail build through one final director."""
    pass

def save_publish_kit(data: Any, session_folder: str, *, generate_thumbnail: bool = True, aspect_ratio: str = '', source_image_path: str = '', source_image_ref: Any = None, source_account_name: str = '', image_model: str = '') -> bool:
    pass

def _labs_aspect(aspect_ratio: str) -> str:
    pass

def _image_ext(data: bytes) -> str:
    pass

def _is_policy_block(err: str) -> bool:
    pass

def _select_reference_account(source_ref: Mapping[str, Any], preferred_account_name: str) -> Dict[str, Any]:
    pass

def _resolve_labs_reference(source_ref: Mapping[str, Any], preferred_account_name: str) -> tuple[typing.Dict[str, typing.Any], str]:
    pass

def _gen_image_labs(prompt: str, aspect_ratio: str, *, source_image_ref: Optional[Mapping[str, Any]] = None, source_image_refs: list[typing.Mapping[str, typing.Any]] | None = None, source_account_name: str = '', image_model: str = '') -> tuple:
    pass

def _gateway_reference_payload(source_image_ref: Optional[Mapping[str, Any]], source_image_refs: list[typing.Mapping[str, typing.Any]] | None = None) -> tuple[list[typing.Dict[str, str]], list[str]]:
    pass

def _gen_image_gateway(prompt: str, aspect_ratio: str, *, source_image_ref: Optional[Mapping[str, Any]] = None, source_image_refs: list[typing.Mapping[str, typing.Any]] | None = None) -> bytes:
    pass

def _sanitize_thumbnail_prompt(prompt: str, error_message: str = '') -> str:
    pass

def _generate_thumbnail(prompt: str, folder: str, *, aspect_ratio: str = '16:9', max_safety_retries: int = 2, source_image_ref: Optional[Mapping[str, Any]] = None, source_image_refs: list[typing.Mapping[str, typing.Any]] | None = None, source_account_name: str = '', image_model: str = '', output_basename: str = 'thumbnail') -> str:
    pass

def save_publish_kit_async(data: Any, session_folder: str, *, generate_thumbnail: bool = True, aspect_ratio: str = '', source_image_path: str = '', source_image_ref: Any = None, source_account_name: str = '', image_model: str = '', seed_text: str = '', language_hint: str = '', style_hint: str = '', force: bool = False, on_complete: Optional[Callable[[Dict[str, Any]], NoneType]] = None) -> None:
    pass
