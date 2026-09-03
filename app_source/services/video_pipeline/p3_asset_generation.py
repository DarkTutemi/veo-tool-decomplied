"""
Decompiled / Reconstructed Module: services.video_pipeline.p3_asset_generation
Source PyC: p3_asset_generation.pyc

Docstring:
Step 3: Asset Creation — Generate images for characters + backgrounds + objects, upload to ALL accounts.

Input:  ResourcePlan (new chars) + result_data (asset_library with characters + backgrounds + objects)
Output: (character_metadata, bg_metadata, obj_metadata) — all {ID: {uploaded_accounts: {account: mediaId}, source, name}}

Flow:
  1. Provided chars → upload MediaLibrary items to all accounts
  2. New chars → CharGen creates portrait → upload to all accounts
  3. Backgrounds → BG-Gen creates environment image → upload to all accounts (≥2 usage only)
  4. Objects → OBJ-Gen creates object image → upload to all accounts (recurring anchors)
  5. Build unified metadata with veo3_media_ids per account
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
Callable = typing.Callable
Dict = typing.Dict
List = typing.List
Optional = typing.Optional
RETRY_BACKOFF_BASE_S = 5
RETRY_BACKOFF_MAX_S = 60

# --- Class: _PipelineCancelled ---
class _PipelineCancelled(Exception):
    """Raised when cancel_event is observed mid-stream so callers bail out fast."""
    pass


# --- Top-Level Functions ---
def _retry_backoff_seconds(attempt: int) -> int:
    pass

def _is_cancelled(config) -> bool:
    pass

def _interruptible_sleep(seconds: float, config, poll: float = 0.5) -> None:
    pass

def _asset_stream_timeout_seconds() -> int:
    pass

def _forced_reference_ids_from_scenes(scenes: List[Dict], id_pattern: str) -> set:
    pass

def _filter_identity_anchors(items: List[Dict], forced_ids: set | None = None) -> tuple:
    pass

def _account_key(account: Dict) -> str:
    pass

def _get_live_accounts_for_upload(dispatcher=None, context: str = 'Step3') -> list:
    pass

def _attach_character_generation_references(characters: list, live_accounts: list, progress_callback: Optional[Callable] = None) -> list:
    pass

def create_assets(config: services.video_pipeline.pipeline_config.PipelineConfig, resource_plan: services.video_pipeline.pipeline_config.ResourcePlan, result_data: Dict, dispatcher=None, progress_callback: Optional[Callable] = None) -> tuple:
    """Build unified character_metadata, bg_metadata, and obj_metadata with pre-uploaded veo3_media_ids.

    Returns: (character_metadata, bg_metadata, obj_metadata)
             Each: {ID: {name, source, veo3_media_ids: {account_email: veo3_id}}}"""
    pass

def _get_user_asset_media_id(char_id: str, config: services.video_pipeline.pipeline_config.PipelineConfig) -> str:
    pass

def _upload_media_to_all_accounts(media_id: str, accounts: list) -> Dict[str, str]:
    pass

def _upload_asset_ref_to_all_accounts(asset_ref: dict, accounts: list) -> Dict[str, str]:
    pass

def _metadata_from_generated_ref(name: str, source: str, uploaded_accounts: Dict[str, str], asset_ref: dict) -> Dict:
    pass

def _stream_chargen_and_upload(dispatcher, config, chars_to_generate: list, asset_style, all_chars: list, live_accounts: list, character_metadata: Dict, progress_callback: Optional[Callable] = None):
    pass

def _stream_bggen_and_upload(dispatcher, config, all_bgs: list, asset_style, live_accounts: list, bg_metadata: Dict, progress_callback: Optional[Callable] = None):
    pass

def _stream_objgen_and_upload(dispatcher, config, all_objs: list, asset_style, live_accounts: list, obj_metadata: Dict, progress_callback: Optional[Callable] = None):
    pass
