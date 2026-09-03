"""
Decompiled / Reconstructed Module: services.tabs.timemachine.session
Source PyC: session.pyc

Docstring:
Durable per-job session storage for Time Machine.

All functions in this module perform disk I/O and must be called from a worker,
never directly from a QML signal handler or the GUI thread.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['MEDIA_REFS_MANIFEST', 'GROUNDING_MANIFEST', 'LEGACY_GROUNDING_MANIFEST', 'SESSION_MANIFEST', 'SESSION_SUBFOLDERS', 'TIMELINE_CHAPTERS_FOLDER', 'TIMELINE_CURSOR_NAME', 'TIMELINE_FOLDER', 'TIMELINE_OUTLINE_NAME', 'load_timeline_chapter_checkpoint', 'load_timeline_cursor', 'load_timeline_outline_checkpoint', 'timeline_checkpoint_root', 'write_timeline_chapter_checkpoint', 'write_timeline_cursor', 'write_timeline_outline_checkpoint', 'TIME_MACHINE_ORPHAN_RETENTION_S', 'TIME_MACHINE_SUCCESS_RETENTION_S', 'WORKSPACE_COMPLETE_MARKER', 'WORKSPACE_MARKER', 'cleanup_stale_time_machine_workdirs', 'cleanup_time_machine_workdir', 'mark_time_machine_workdir_complete', 'sweep_time_machine_session', 'prepare_time_machine_session', 'apply_keyframe_checkpoint', 'build_keyframe_checkpoint', 'rehydrate_time_machine_snapshot', 'load_session_manifest', 'update_session_manifest', 'write_media_refs', 'write_grounding_manifest', 'write_session_manifest']

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
Mapping = typing.Mapping
Sequence = typing.Sequence
SESSION_MANIFEST = 'session.json'
MEDIA_REFS_MANIFEST = 'media_refs.json'
GROUNDING_MANIFEST = 'timeline_manifest.json'
LEGACY_GROUNDING_MANIFEST = 'evidence_ledger.json'
TIMELINE_FOLDER = 'timeline'
TIMELINE_OUTLINE_NAME = 'outline.normalized.json'
TIMELINE_CHAPTERS_FOLDER = 'chapters'
TIMELINE_CURSOR_NAME = 'cursor.json'
SESSION_SUBFOLDERS = ('inputs', 'anchors', 'keyframes', 'stills', 'clips', 'narration')
WORKSPACE_MARKER = '.veoflow-timemachine-work.json'
WORKSPACE_COMPLETE_MARKER = '.cleanup-ready.json'
TIME_MACHINE_SUCCESS_RETENTION_S = 86400
TIME_MACHINE_ORPHAN_RETENTION_S = 259200
_SESSION_KEEP_DIRS = frozenset({'narration', 'keyframes', 'clips', 'stills', 'anchors'})
_SESSION_KEEP_FILES = frozenset({'publish_kit.json', 'publish_kit_status.json', 'publish_info.txt', 'timeline_manifest.json'})
_SESSION_KEEP_SUFFIXES = frozenset({'.png', '.srt', '.mp4', '.mp3', '.webp', '.m4a', '.jpg', '.aac', '.vtt', '.jpeg', '.wav'})
__all__ = ['MEDIA_REFS_MANIFEST', 'GROUNDING_MANIFEST', 'LEGACY_GROUNDING_MANIFEST', 'SESSION_MANIFEST', 'SESSION_SUBFOLDERS', 'TIMELINE_CHAPTERS_FOLDER', 'TIMELINE_CURSOR_NAME', 'TIMELINE_FOLDER', 'TIMELINE_OU... [truncated]

# --- Top-Level Functions ---
def _safe_file_part(value: 'str', fallback: 'str') -> 'str':
    pass

def _atomic_json(path: 'Path', data: 'Mapping[str, Any]') -> 'None':
    pass

def _work_root(temp_root: 'str | os.PathLike[str] | None' = None) -> 'Path':
    pass

def _owned_work_folder(work_folder: 'str | os.PathLike[str]', *, temp_root: 'str | os.PathLike[str] | None' = None) -> 'Path | None':
    pass

def cleanup_time_machine_workdir(work_folder: 'str | os.PathLike[str]', *, temp_root: 'str | os.PathLike[str] | None' = None) -> 'bool':
    pass

def _is_time_machine_session(root: 'Path') -> 'bool':
    pass

def _keep_session_entry(path: 'Path') -> 'bool':
    pass

def sweep_time_machine_session(session_folder: 'str | os.PathLike[str]') -> 'bool':
    pass

def mark_time_machine_workdir_complete(work_folder: 'str | os.PathLike[str]', *, temp_root: 'str | os.PathLike[str] | None' = None) -> 'bool':
    pass

def cleanup_stale_time_machine_workdirs(*, temp_root: 'str | os.PathLike[str] | None' = None, completed_max_age_s: 'float' = 86400, orphan_max_age_s: 'float' = 259200, now: 'float | None' = None) -> 'list[str]':
    pass

def prepare_time_machine_session(config: 'Mapping[str, Any]', *, job_id: 'str', title: 'str', inputs: 'Sequence[Mapping[str, Any]]', temp_root: 'str | os.PathLike[str] | None' = None) -> 'Dict[str, Any]':
    pass

def write_session_manifest(session_folder: 'str', payload: 'Mapping[str, Any]') -> 'str':
    pass

def load_session_manifest(session_folder_or_path: 'str') -> 'Dict[str, Any]':
    pass

def build_keyframe_checkpoint(plan: 'Mapping[str, Any]') -> 'Dict[str, Any]':
    """Serialize the contiguous ready prefix of every chapter.

    This is intentionally separate from the final I2V manifest: it is written
    after each completed keyframe, allowing a retry to continue from the last
    actual generated image instead of repeating earlier LLM/image calls."""
    pass

def apply_keyframe_checkpoint(plan: 'Mapping[str, Any]', checkpoint: 'Mapping[str, Any]') -> 'Dict[str, Any]':
    pass

def rehydrate_time_machine_snapshot(snapshot: 'Mapping[str, Any]', config: 'Mapping[str, Any]', *, job_id: 'str', title: 'str', inputs: 'Sequence[Mapping[str, Any]]', temp_root: 'str | os.PathLike[str] | None' = None) -> 'Dict[str, Any]':
    pass

def update_session_manifest(session_folder: 'str', changes: 'Mapping[str, Any]') -> 'str':
    pass

def write_media_refs(session_folder: 'str', i2v_plan: 'Mapping[str, Any]') -> 'str':
    pass

def timeline_checkpoint_root(work_folder: 'str') -> 'Path':
    pass

def _read_json_object(path: 'Path') -> 'Dict[str, Any] | None':
    pass

def write_timeline_outline_checkpoint(work_folder: 'str', outline: 'Mapping[str, Any]') -> 'str':
    pass

def load_timeline_outline_checkpoint(work_folder: 'str') -> 'Dict[str, Any] | None':
    pass

def write_timeline_chapter_checkpoint(work_folder: 'str', chapter_index: 'int', chapter: 'Mapping[str, Any]') -> 'str':
    pass

def load_timeline_chapter_checkpoint(work_folder: 'str', chapter_index: 'int') -> 'Dict[str, Any] | None':
    pass

def write_timeline_cursor(work_folder: 'str', payload: 'Mapping[str, Any]') -> 'str':
    pass

def load_timeline_cursor(work_folder: 'str') -> 'Dict[str, Any] | None':
    pass

def write_grounding_manifest(output_folder: 'str', grounding: 'Mapping[str, Any]') -> 'str':
    pass
