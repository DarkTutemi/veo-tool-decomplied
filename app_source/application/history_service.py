"""
Decompiled / Reconstructed Module: application.history_service
Source PyC: history_service.pyc

Docstring:
Application boundary for the clean History v3 run/detail model.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Mapping = typing.Mapping
REPLAY_BLOB_MARK = '__history_v3_blob__'
RUN_PARENT_KEYS = ('history_run_id', 'clone_job_id', 'transcript_job_id', 'master_prompt_job_id', 'affiliate_video_job_id', 'affiliate_queue_row_id', 'timemachine_job_id', 'normal_run_id', 'batch_run_id', 'voice_run_id... [truncated]
_INTERNAL_IMAGE_SOURCES = frozenset({'feature.image_gen', 'character_generation', 'character_consistency_core', 'composite', 'image_generation', 'objgen', 'chargen', 'bggen'})
SOURCE_LABELS = {'normal_panel': 'Normal', 'clone_video': 'Clone', 'transcript_video': 'Audio → Video', 'master_prompt': 'Master', 'extend_panel': 'Extend', 'batch_image_generation': 'Batch', 'affiliate_video': 'Affi... [truncated]
SOURCE_ROUTES = {'normal_panel': 'normal', 'clone_video': 'clone', 'transcript_video': 'transcript', 'master_prompt': 'master', 'extend_panel': 'extend', 'batch_image_generation': 'batch', 'affiliate_video': 'affilia... [truncated]
_SCENE_HINT_KEYS = ('scene_role', 'description', 'timeline', 'viewer_reward', 'visual_prompt', 'visual', 'veo3_prompt', 'visual_action', 'prompt')
_PROMPT_VALUE_KEYS = ('visual', 'veo3_prompt', 'visual_prompt', 'video_prompt', 'description', 'prompt', 'text', 'narration', 'idea', 'script', 'compiled_prompt', 'core_description', 'scene_description', 'viewer_reward')
_SUPPORTING_ASSET_MARKERS = ('chargen_group_id', 'bggen_group_id', 'objgen_group_id', 'composite_group_id')
_LIBRARY_CATEGORY_LABELS = {'char': 'Nhân vật', 'bg': 'Bối cảnh', 'obj': 'Vật thể', 'ref': 'Asset'}
_service = None

# --- Class: HistoryService ---
class HistoryService:
    """UI-safe application facade. Controller calls it only on workers."""
    def __init__(self, store: 'HistoryStore | None' = None) -> 'None':
        pass

    def query_runs(self, request: 'Mapping[str, Any]') -> 'dict[str, Any]':
        pass

    @staticmethod
    def _list_row(row: 'Mapping[str, Any]') -> 'dict[str, Any]':
        pass

    def load_detail(self, run_id: 'str') -> 'dict[str, Any]':
        pass

    @staticmethod
    def _detail_artifact(artifact: 'Mapping[str, Any]') -> 'dict[str, Any]':
        pass

    @staticmethod
    def _domain_snapshot(detail: 'Mapping[str, Any]') -> 'dict[str, Any]':
        pass

    @staticmethod
    def _detail_item(item: 'Mapping[str, Any]') -> 'dict[str, Any]':
        """Project persisted records into one user-facing child-job card."""
        pass

    def execute(self, run_id: 'str', action: 'str') -> 'dict[str, Any]':
        pass

    def execute_item(self, run_id: 'str', item_id: 'str', action: 'str') -> 'dict[str, Any]':
        """Open or recreate one child job."""
        pass

    def _recreate_run(self, run_id: 'str') -> 'dict[str, Any]':
        pass

    @staticmethod
    def _recreate_voice_studio_pipeline(run_id: 'str', snapshot: 'Mapping[str, Any]') -> 'dict[str, Any]':
        pass

    @staticmethod
    def _recreate_voice(run_id: 'str', snapshot: 'Mapping[str, Any]', *, new_run_id: 'str', title: 'str') -> 'dict[str, Any]':
        pass

    @staticmethod
    def _recreate_affiliate(run_id: 'str', snapshot: 'Mapping[str, Any]', *, new_run_id: 'str', title: 'str') -> 'dict[str, Any]':
        pass

    def _dispatch_items(self, detail: 'Mapping[str, Any]', items: 'list[dict[str, Any]]', *, target_run_id: 'str', title: 'str', fresh_items: 'bool', action: 'str') -> 'dict[str, Any]':
        pass

    @staticmethod
    def _submit_utility_item(feature: 'str', card: 'Mapping[str, Any]') -> 'dict[str, Any]':
        pass

    def _retry_failed(self, run_id: 'str') -> 'dict[str, Any]':
        pass


# --- Top-Level Functions ---
def _cursor_encode(updated: 'float', run_id: 'str') -> 'str':
    pass

def _cursor_decode(value: 'Any') -> 'tuple[float, str] | None':
    pass

def _time_label(value: 'Any') -> 'str':
    pass

def _state_bucket(status: 'Any') -> 'str':
    pass

def _tone(bucket: 'str') -> 'str':
    pass

def _is_ephemeral_preview_source(value: 'Any') -> 'bool':
    pass

def _mapping_from_json(value: 'Any') -> 'dict[str, Any]':
    pass

def _clean_display_text(value: 'Any', *, limit: 'int' = 900) -> 'str':
    pass

def _first_display_text(source: 'Mapping[str, Any]', *keys: 'str') -> 'str':
    pass

def _as_mapping(value: 'Any') -> 'dict[str, Any]':
    pass

def _plain_prompt_text(value: 'Any') -> 'str':
    pass

def _timeline_prompt(timeline: 'Any') -> 'str':
    pass

def _readable_from_mapping(source: 'Mapping[str, Any]', *, depth: 'int' = 0) -> 'str':
    pass

def _scene_projection(prompt: 'Any', config: 'Mapping[str, Any]') -> 'tuple[str, str]':
    """Return a readable scene role and prompt without exposing stored JSON."""
    pass

def qml_image_source(source: 'Any') -> 'str':
    pass

def openable_target(source: 'Any') -> 'tuple[str, str]':
    pass

def _artifact_openable(artifact: 'Mapping[str, Any]') -> 'tuple[str, str]':
    pass

def is_supporting_asset_item(item: 'Mapping[str, Any]') -> 'bool':
    """True for CharGen/BGGen/OBJGen/composite children of a user video run.

    Those jobs exist so a scene can reuse generated stills.  They are not
    user-facing child jobs — History hides them from the child list and
    shows the stills once on the run asset rail (and on a lone scene card).
    Batch image runs and per-scene stills stay visible."""
    pass

def items_for_replay(items: 'list[Any]') -> 'list[dict[str, Any]]':
    pass

def _preview_source(item: 'Mapping[str, Any]') -> 'str':
    pass

def _preview_identity(source: 'Any') -> 'str':
    pass

def _media_identity_keys(*values: 'Any', size_bytes: 'Any' = 0) -> 'set[str]':
    pass

def _artifact_identity_keys(artifact: 'Mapping[str, Any]') -> 'set[str]':
    pass

def _unique_preview_list(sources: 'list[Any]') -> 'list[str]':
    pass

def _prefer_artifact_preview(source: 'str', artifacts: 'list[Mapping[str, Any]]') -> 'str':
    pass

def _previews_not_in_library(sources: 'list[Any]', library_assets: 'list[Mapping[str, Any]]') -> 'list[str]':
    pass

def _library_category(item: 'Mapping[str, Any]') -> 'str':
    pass

def _library_asset_dto(source: 'str', category: 'str') -> 'dict[str, Any]':
    pass

def _supporting_library_assets(supporting_items: 'list[dict[str, Any]]') -> 'list[dict[str, Any]]':
    pass

def _display_image_ref(value: 'Any', depth: 'int' = 0) -> 'str':
    pass

def _scene_map_from_config(item: 'Mapping[str, Any]', config: 'Mapping[str, Any]') -> 'dict[str, Any]':
    pass

def _ids_and_images_from_scene(scene: 'Mapping[str, Any]') -> 'tuple[list[str], list[str]]':
    pass

def _scene_owned_previews(item: 'Mapping[str, Any]') -> 'list[str]':
    pass

def _lift_shared_and_supporting_previews(primary_items: 'list[dict[str, Any]]', supporting_items: 'list[dict[str, Any]]') -> 'tuple[list[dict[str, Any]], list[dict[str, Any]]]':
    pass

def _scene_title(item: 'Mapping[str, Any]', role: 'str') -> 'str':
    pass

def _replay_path_ref(value: 'Any') -> 'Any':
    pass

def _replay_feature(value: 'Any') -> 'str':
    pass

def _replay_mode_key(feature: 'str', card: 'Mapping[str, Any]') -> 'str':
    pass

def _prepare_replay_assets(card: 'dict[str, Any]') -> 'None':
    """Join durable History blobs back onto the metadata the R2V resolver reads."""
    pass

def get_history_service() -> 'HistoryService':
    pass
