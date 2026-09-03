"""
Decompiled / Reconstructed Module: core.history_store
Source PyC: history_store.pyc

Docstring:
History v3: one user run, ordered child items, attempts, and artifacts.

This module is the only persistence owner for History.  Tabs and QML never write
SQLite directly.  Dispatch stamps a HistoryContext at submission; JobStore
signals may only update that existing context and are ignored when the context
is absent.  That rule prevents a child runtime UUID from becoming a top-level
History run.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Callable = typing.Callable
Iterable = typing.Iterable
Mapping = typing.Mapping
Optional = typing.Optional
SCHEMA_VERSION = 3
DB_FILENAME = 'history_v3.db'
REPLAY_BLOB_MARK = '__history_v3_blob__'
_HEAVY_SNAPSHOT_KEYS = frozenset({'analysis_result', 'raw_analysis', 'full_result', 'llm_raw', 'raw_response', 'result_data'})
SNAPSHOT_SLIM_VERSION = 1
DEFAULT_RETENTION_DAYS = 45
HOUSEKEEP_INTERVAL_S = 86400
_COMPACT_JSON_MIN_BYTES = 16384
_ACTIVE_RUN_STATUSES = frozenset({'RUNNING', 'PENDING', 'UPSCALING', 'QUEUED', 'GENERATING', 'WAITING', 'PROCESSING', 'RETRYING', 'POLLING'})
ACTIVE_ITEM_STATES = frozenset({'PENDING', 'UPSCALING', 'QUEUED', 'GENERATING', 'WAITING', 'PROCESSING', 'RETRYING', 'POLLING'})
TERMINAL_ITEM_STATES = frozenset({'COMPLETED', 'CANCELLED', 'FAILED', 'INTERRUPTED'})
RUN_PARENT_KEYS = ('history_run_id', 'clone_job_id', 'transcript_job_id', 'master_prompt_job_id', 'affiliate_video_job_id', 'affiliate_queue_row_id', 'timemachine_job_id', 'normal_run_id', 'batch_run_id', 'voice_run_id... [truncated]
ITEM_ID_KEYS = ('history_item_id', 'scene_id', 'segment_id', 'row_id')
ITEM_INDEX_KEYS = ('history_item_index', 'timemachine_edit_seq', 'scene_index', 'segment_id', 'file_sequence', 'row_number', 'index')
_SOURCE_ALIASES = {'affiliate': 'affiliate_video', 'normal': 'normal_panel', 'normal_work_panel': 'normal_panel', 'clone': 'clone_video', 'transcript': 'transcript_video', 'audio_to_video': 'transcript_video', 'master'... [truncated]
_INTERNAL_IMAGE_SOURCES = frozenset({'feature.image_gen', 'character_generation', 'character_consistency_core', 'composite', 'image_generation', 'objgen', 'chargen', 'bggen'})
_PARENT_SOURCE_KEYS = (('clone_job_id', 'clone_video'), ('transcript_job_id', 'transcript_video'), ('master_prompt_job_id', 'master_prompt'), ('affiliate_video_job_id', 'affiliate_video'), ('affiliate_queue_row_id', 'affil... [truncated]
_DISPLAY_TITLE_UUID_RE = re.compile('^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$')
_DISPLAY_TITLE_LABELS = {'normal_panel': 'Normal', 'clone_video': 'Clone Video', 'transcript_video': 'Audio to Video', 'master_prompt': 'Master Prompt', 'affiliate_video': 'Affiliate', 'batch_image_generation': 'Batch Image'... [truncated]
_history_store = None
_history_store_lock = <unlocked _thread.lock object at 0x00000264D84049C0>

# --- Class: HistoryContext ---
class HistoryContext:
    """HistoryContext(run_id: 'str', item_id: 'str', item_index: 'int', attempt_id: 'str', source: 'str')"""
    def to_meta(self) -> 'dict[str, Any]':
        pass

    def __init__(self, run_id: 'str', item_id: 'str', item_index: 'int', attempt_id: 'str', source: 'str') -> None:
        pass

    def __repr__(self):
        pass


# --- Class: HistoryV3Backend ---
class HistoryV3Backend:
    """Small SQLite backend with no legacy schema or compatibility projections."""
    def __init__(self, db_path: 'str | Path | None' = None, blob_dir: 'str | Path | None' = None) -> 'None':
        pass

    def _connect(self) -> "__assert_armored__((sqlite3, b'\\x81\\xa6\\x94\\x1bR\\xb4\\xfdR\\xbe&\\xa3'))":
        pass

    def _get_conn(self) -> "__assert_armored__((sqlite3, b'\\x81\\xa6\\x94\\x1bR\\xb4\\xfdR\\xbe&\\xa3'))":
        pass

    def connection(self):
        pass

    def _init_schema(self) -> 'None':
        pass

    @staticmethod
    def _repair_internal_image_runs(conn: 'sqlite3.Connection') -> 'int':
        """Fold legacy asset-only top-level runs into their exact owning run.

        Early History v3 builds let CharGen/BGGen/OBJGen use their runtime UUID
        as ``history_run_id``.  The repair is deliberately conservative: it
        reparents only when an explicit parent id exists in the saved request,
        or when exactly one non-internal run has the same normalized output
        folder.  Ambiguous rows are left untouched and remain replayable."""
        pass

    def save_blob(self, data: 'bytes', *, suffix: 'str' = '.bin') -> 'tuple[str, str]':
        pass

    def execute(self, sql: 'str', params: 'Iterable[Any]' = ()) -> 'None':
        pass

    def fetchone(self, sql: 'str', params: 'Iterable[Any]' = ()) -> 'Optional[dict[str, Any]]':
        pass

    def fetchall(self, sql: 'str', params: 'Iterable[Any]' = ()) -> 'list[dict[str, Any]]':
        pass

    def clear(self) -> 'None':
        pass


# --- Class: HistoryStore ---
class HistoryStore:
    """Serialized event writer plus read API for History v3."""
    def __init__(self, backend: 'HistoryV3Backend | None' = None) -> 'None':
        pass

    def context_for_submission(self, *, feature: 'Any', prompt_data: 'dict[str, Any]', job_id: 'str', attempt_id: 'str', account_key: 'str' = '') -> 'HistoryContext':
        pass

    @staticmethod
    def _detached_copy(value: 'Any') -> 'Any':
        pass

    @staticmethod
    def context_from_meta(meta: 'Mapping[str, Any]') -> 'HistoryContext | None':
        pass

    def begin_run(self, run_id: 'str', *, source: 'str', kind: 'str', title: 'str', status: 'str' = 'QUEUED', prompt_preview: 'str' = '', output_folder: 'str' = '', restore_recipe: 'Mapping[str, Any] | None' = None, source_context: 'Mapping[str, Any] | None' = None, summary: 'Mapping[str, Any] | None' = None) -> 'None':
        pass

    def connect_to_jobstore(self) -> 'None':
        pass

    def _on_job_changed(self, job: 'Any') -> 'None':
        """Signal handler: copy scalar state and enqueue; never touch disk here."""
        pass

    def _on_job_removed(self, job_id: 'str') -> 'None':
        pass

    def attach_run_artifact(self, run_id: 'str', *, role: 'str', kind: 'str', path_or_data: 'Any', item_id: 'str' = '', attempt_id: 'str' = '', metadata: 'Mapping[str, Any] | None' = None) -> 'None':
        pass

    def patch_run(self, run_id: 'str', *, status: 'str' = '', phase: 'str' = '', progress: 'int | None' = None, output_folder: 'str' = '', restore_recipe: 'Mapping[str, Any] | None' = None, source_context: 'Mapping[str, Any] | None' = None, summary: 'Mapping[str, Any] | None' = None, event_type: 'str' = 'run_snapshot', message: 'str' = '') -> 'None':
        pass

    def record_item(self, run_id: 'str', *, item_id: 'str', item_index: 'int' = 0, job_id: 'str' = '', kind: 'str' = 'generation', title: 'str' = '', status: 'str' = 'RUNNING', prompt: 'str' = '', model: 'str' = '', config: 'Mapping[str, Any] | None' = None, result: 'Mapping[str, Any] | None' = None, message: 'str' = '') -> 'None':
        pass

    def record_external_result(self, context: 'HistoryContext', *, status: 'str', progress: 'int' = 100, prompt: 'str' = '', title: 'str' = '', model: 'str' = '', account_key: 'str' = '', error: 'str' = '', result: 'Mapping[str, Any] | None' = None) -> 'None':
        pass

    def finalize_run(self, run_id: 'str', *, status: 'str' = 'COMPLETED', output_path: 'str' = '', output_kind: 'str' = 'video', summary: 'Mapping[str, Any] | None' = None) -> 'None':
        pass

    def add_listener(self, callback: 'Callable[[str], None]') -> 'None':
        pass

    def remove_listener(self, callback: 'Callable[[str], None]') -> 'None':
        pass

    def _notify(self, run_id: 'str') -> 'None':
        pass

    def flush(self, timeout: 'float' = 5.0) -> 'bool':
        pass

    def close(self) -> 'None':
        pass

    def housekeep(self, retention_days: 'Any' = None, vacuum: 'bool' = False, timeout: 'float' = 30.0) -> 'bool':
        pass

    def _housekeep_timer_loop(self) -> 'None':
        pass

    def _worker_loop(self) -> 'None':
        pass

    def _run_housekeep(self, payload: 'Mapping[str, Any]') -> 'bool':
        pass

    def _compact_history_snapshots(self, conn: 'sqlite3.Connection') -> 'int':
        pass

    def _delete_expired_runs(self, conn: 'sqlite3.Connection', retention_days: 'int') -> 'int':
        pass

    def _referenced_blob_paths(self, conn: 'sqlite3.Connection') -> 'set[str]':
        pass

    @staticmethod
    def _remember_blob_path(bucket: 'set[str]', value: 'Any') -> 'None':
        pass

    def _gc_blob_dir(self, referenced: 'set[str]') -> 'int':
        pass

    def _gc_legacy_blob_dir(self) -> 'int':
        pass

    def _write_begin(self, payload: 'Mapping[str, Any]') -> 'str':
        pass

    def _write_run_patch(self, payload: 'Mapping[str, Any]') -> 'str':
        pass

    def _write_item_snapshot(self, payload: 'Mapping[str, Any]') -> 'str':
        pass

    def _write_submission(self, payload: 'Mapping[str, Any]') -> 'str':
        pass

    def _snapshot_for_replay(self, value: 'Any', key_path: 'str' = '', *, copy_local_files: 'bool' = True) -> 'Any':
        pass

    def _write_job_change(self, payload: 'Mapping[str, Any]') -> 'str':
        pass

    def _ensure_video_frame_thumbnail(self, context: 'HistoryContext', payload: 'Mapping[str, Any]') -> 'None':
        pass

    def _persist_video_frame_thumbnail(self, context: 'HistoryContext', video: 'str') -> 'None':
        pass

    @staticmethod
    def _insert_event(conn: 'sqlite3.Connection', run_id: 'str', item_id: 'str', attempt_id: 'str', event_type: 'str', status: 'str', message: 'str', data: 'Mapping[str, Any]', created_at: 'float') -> 'None':
        pass

    def _aggregate_run(self, conn: 'sqlite3.Connection', run_id: 'str', now: 'float') -> 'None':
        pass

    def _capture_prompt_artifacts(self, context: 'HistoryContext', prompt_data: 'Mapping[str, Any]') -> 'None':
        pass

    def _capture_result_artifacts(self, context: 'HistoryContext', payload: 'Mapping[str, Any]') -> 'None':
        pass

    def _write_artifact_event(self, payload: 'Mapping[str, Any]') -> 'str':
        pass

    def _persist_artifact(self, *, run_id: 'str', item_id: 'str', attempt_id: 'str', role: 'str', kind: 'str', value: 'Any', metadata: 'Mapping[str, Any]') -> 'str':
        pass

    def _write_finalize(self, payload: 'Mapping[str, Any]') -> 'str':
        pass

    @staticmethod
    def _media_source(row: 'Mapping[str, Any]') -> 'str':
        pass

    def query_runs(self, *, source: 'str' = '', search: 'str' = '', state: 'str' = '', include_archived: 'bool' = False, cursor: 'tuple[float, str] | None' = None, limit: 'int' = 40) -> 'list[dict[str, Any]]':
        pass

    def _run_dto(self, row: 'Mapping[str, Any]') -> 'dict[str, Any]':
        pass

    def load_detail(self, run_id: 'str') -> 'dict[str, Any]':
        pass

    def counts(self, *, source: 'str' = '', search: 'str' = '') -> 'dict[str, Any]':
        pass

    def archive(self, run_id: 'str', archived: 'bool' = True) -> 'bool':
        pass

    def delete(self, run_id: 'str', *, delete_files: 'bool' = False) -> 'bool':
        pass


# --- Top-Level Functions ---
def _text(value: 'Any') -> 'str':
    pass

def canonical_source(value: 'Any') -> 'str':
    pass

def _json_safe(value: 'Any') -> 'Any':
    pass

def slim_history_snapshot(value: 'Any') -> 'Any':
    pass

def _attempt_request_snapshot(prompt_data: 'Mapping[str, Any]', model: 'str', feature: 'str') -> 'dict[str, str]':
    pass

def _retention_days(override: 'Any' = None) -> 'int':
    pass

def _json_dumps(value: 'Any') -> 'str':
    pass

def _json_loads(value: 'Any', fallback: 'Any') -> 'Any':
    pass

def _merge_snapshot(base: 'Any', patch: 'Any') -> 'Any':
    pass

def _is_output_snapshot_path(key_path: 'str') -> 'bool':
    pass

def _normalized_status(value: 'Any') -> 'str':
    pass

def _first(mapping: 'Mapping[str, Any]', keys: 'Iterable[str]') -> 'str':
    pass

def _first_index(mapping: 'Mapping[str, Any]', default: 'int' = 0) -> 'int':
    pass

def _clean_snapshot(value: 'Any') -> 'Any':
    pass

def resolve_replay_media(value: 'Any') -> 'Any':
    pass

def is_bad_display_title(text: 'Any') -> 'bool':
    pass

def derive_display_title(title: 'Any' = '', config: 'Mapping[str, Any] | None' = None, source: 'str' = '', prompt_preview: 'Any' = '') -> 'str':
    """Build a stable human-facing History title from v3 submission data."""
    pass

def _title_from(prompt_data: 'Mapping[str, Any]', source: 'str') -> 'str':
    pass

def get_history_store() -> 'HistoryStore':
    pass

def reset_history_store_for_tests() -> 'None':
    pass
