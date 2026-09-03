"""
Decompiled / Reconstructed Module: core.runtime_resources.health
Source PyC: health.pyc

Docstring:
User-facing health suite for every managed runtime resource.

The Settings tab used to show only VeoFlowOS Browser, with raw integrity /
smoke / path dumps. This module is the single check+repair catalog for
FFmpeg, Deno, Browser, local TTS packs, and the resource disk.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Callable = typing.Callable
Optional = typing.Optional
OnProgress = typing.Optional[typing.Callable[[str, int, str], NoneType]]
_LOW_DISK_GB = 8.0
_CRITICAL_DISK_GB = 1.0
_ISSUE_LABELS = {'integrity_files_missing': 'Thiếu file quan trọng', 'integrity_version_mismatch': 'Phiên bản không khớp', 'integrity_manifest_unreadable': 'Không đọc được danh sách file', 'integrity_schema_mismatch'... [truncated]
_STATUS_LABELS = {'unchecked': 'Chưa kiểm tra', 'checking': 'Đang kiểm tra', 'busy': 'Đang xử lý', 'ready': 'Sẵn sàng', 'missing': 'Chưa cài', 'broken': 'Cần sửa', 'warning': 'Cần chú ý'}
_TONE = {'unchecked': 'neutral', 'checking': 'blue', 'busy': 'blue', 'ready': 'green', 'missing': 'neutral', 'broken': 'red', 'warning': 'amber'}
_CATALOG = ({'id': 'ffmpeg', 'toolCode': 'VEOFLOW_FFMPEG', 'title': 'FFmpeg', 'shortTitle': 'FFmpeg', 'purpose': 'Cắt, ghép và xuất video', 'required': True, 'featured': True, 'icon': 'scissors', 'group': 'core'... [truncated]

# --- Top-Level Functions ---
def catalog() -> 'list[dict[str, Any]]':
    pass

def catalog_ids() -> 'list[str]':
    pass

def catalog_tool_codes() -> 'list[str]':
    pass

def check_all(deep: 'bool' = False, on_progress: 'OnProgress' = None) -> 'dict[str, Any]':
    pass

def check_resource(resource_id: 'str', deep: 'bool' = False) -> 'dict[str, Any]':
    pass

def repair_resource(resource_id: 'str', on_progress: 'OnProgress' = None) -> 'dict[str, Any]':
    pass

def summarize(rows: 'list[dict[str, Any]]') -> 'dict[str, Any]':
    pass

def friendly_issue(code: 'str') -> 'str':
    pass

def _annotate_groups(rows: 'list[dict[str, Any]]') -> 'list[dict[str, Any]]':
    pass

def empty_summary() -> 'dict[str, Any]':
    pass

def _spec(resource_id: 'str') -> 'dict[str, Any] | None':
    pass

def _seed_row(spec: 'dict[str, Any]', **overrides: 'Any') -> 'dict[str, Any]':
    pass

def _unknown_row(resource_id: 'str') -> 'dict[str, Any]':
    pass

def _default_action(status: 'str', spec: 'dict[str, Any]') -> 'str':
    pass

def _action_label(action: 'str') -> 'str':
    pass

def _check_managed(spec: 'dict[str, Any]', deep: 'bool' = False) -> 'dict[str, Any]':
    pass

def _check_browser(spec: 'dict[str, Any]', deep: 'bool' = False) -> 'dict[str, Any]':
    pass

def _check_storage(spec: 'dict[str, Any]') -> 'dict[str, Any]':
    pass

def _same_browser_exe(left: 'str | Path', right: 'str | Path') -> 'bool':
    pass

def _browser_version_at(release_dir: 'Path') -> 'str':
    pass

def _repair_browser(on_progress: 'OnProgress' = None) -> 'dict[str, Any]':
    pass

def _probe_version(path: 'Path', kind: 'str') -> 'dict[str, Any]':
    pass

def _parse_version_line(line: 'str', kind: 'str') -> 'str':
    pass

def _declared_size_label(tool_code: 'str') -> 'str':
    pass

def _format_bytes(size: 'int') -> 'str':
    pass

def _humanize_token(code: 'str') -> 'str':
    pass

def _emit(on_progress: 'OnProgress', phase: 'str', pct: 'int', message: 'str') -> 'None':
    pass
