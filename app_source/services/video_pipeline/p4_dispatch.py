"""
Decompiled / Reconstructed Module: services.video_pipeline.p4_dispatch
Source PyC: p4_dispatch.pyc

Docstring:
Step 5: Dispatch normalized scenes through the shared video_core compiler.

Input:  result_data (entity_library + scenes) + runtime media metadata + config
Output: dispatcher job ids

This module owns ref attachment and queue routing. Model-facing prompt text is
compiled by services.video_core.compiler so Master, Clone, Transcript, and
Normal Panel share one scene prompt contract.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
Callable = typing.Callable
Dict = typing.Dict
List = typing.List
Optional = typing.Optional
NO_HUMAN_RULES = 'No people. No humans. No characters. No faces. No silhouettes of people. No hands. No body parts. Pure environment, scenery, or objects only.'
_LANG_NAMES = {'en': 'English', 'vi': 'Vietnamese', 'ja': 'Japanese', 'ko': 'Korean', 'zh': 'Chinese', 'th': 'Thai', 'es': 'Spanish', 'fr': 'French', 'de': 'German', 'pt': 'Portuguese', 'ru': 'Russian', 'ar': 'Arab... [truncated]

# --- Top-Level Functions ---
def _get_lang_name(lang: str) -> str:
    pass

def _library_asset_local_paths(media_id: Any) -> tuple[str, str]:
    pass

def _build_scene_asset_slots(existing_meta: Dict[str, Any], character_metadata: Optional[Dict[str, Any]], obj_metadata: Optional[Dict[str, Any]], bg_metadata: Optional[Dict[str, Any]], autosave_media_ids: Optional[Dict[str, Any]]) -> List[Dict[str, Any]]:
    """Per-scene multi_asset_info.assets[] for the QML job-card asset slots.

    Each asset carries a LIBRARY media_id (autosave id for AI-generated chars,
    or the library-select id) so the job-panel enrich step resolves a local
    file:// thumbnail from the Media Library SSOT. The per-account veo3 upload id
    (uploaded_accounts) is intentionally NOT used here — it is not resolvable in
    the local Library, which is why every generated character's slot stayed blank."""
    pass

def _sanitize_debug_payload(obj: Any, *, _depth: int = 0) -> Any:
    """Return a lightweight debug copy with binary/base64 blobs replaced."""
    pass

def _summarize_blob(value: Any) -> Any:
    pass

def _looks_like_large_blob(value: str) -> bool:
    pass

def _strip_runtime_base64_from_meta(meta: Dict[str, Any]) -> Dict[str, Any]:
    pass

def _first_entity_style_text(entity_library: Dict[str, Any]) -> str:
    pass

def _store_runtime_base64_for_dispatch(asset_id: str, meta: Dict[str, Any]) -> None:
    pass

def _report_bucket(report: Dict[str, Any], feature: str, prompts: List[Dict[str, Any]], job_ids: List[str], error: Any) -> None:
    pass

def dispatch_scenes(config: services.video_pipeline.pipeline_config.PipelineConfig, result_data: Dict, character_metadata: Optional[Dict] = None, bg_metadata: Optional[Dict] = None, obj_metadata: Optional[Dict] = None, composite_frames: Optional[Dict] = None, i2v_keyframes: Optional[Dict] = None, i2v_start_frames: Optional[Dict] = None, scene_asset_plan: Optional[Dict] = None, progress_callback: Optional[Callable] = None, tab_source: str = 'master_prompt', parent_job_id_key: str = 'master_prompt_job_id', scene_obj_overrides: Optional[Dict] = None, cancel_check: Optional[Callable] = None, sequence_namespace: str = 'master_prompt', reset_run_stats: bool = True, dispatch_report: Optional[Dict] = None) -> List[str]:
    """Build per-scene prompt_data and submit to dispatcher.

    Returns list of dispatcher job IDs.

    Caller-optional extensions (defaults keep master behavior byte-identical):
      i2v_start_frames: {scene_id: {image_path, media_id/media_name}} — explicit
          image-first callers may route those scenes as image_video. Affiliate is
          R2V-only and deliberately never supplies this argument.
      scene_obj_overrides: {scene_id: obj_metadata_map} — per-scene OBJ map replacing
          the shared obj_metadata for that scene only (affiliate sheet framing).
      cancel_check: callable invoked per scene + inside the account-live wait; it
          RAISES to abort (affiliate stop button). None → never checked.
      sequence_namespace: session_manager counter key. Callers running several
          dispatches in parallel (affiliate variants) pass their own key so the
          shared "master_prompt" counter cannot race between concurrent batches.
      reset_run_stats: pass False to keep dispatcher per-run stats (affiliate runs
          batches concurrently; a reset mid-run would clobber sibling batches).
      dispatch_report: caller-provided dict; when given it is filled with
          features / dispatched_scenes [{job_id, scene_id, feature, prompt}] /
          multi_asset_info / errors for scene↔job tracking (retry-per-scene)."""
    pass

def _get_live_accounts() -> list:
    pass
