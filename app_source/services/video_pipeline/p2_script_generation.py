"""
Decompiled / Reconstructed Module: services.video_pipeline.p2_script_generation
Source PyC: p2_script_generation.pyc

Docstring:
Step 2: Script Generation — AI creates scenes using template + resource plan.

Input:  ResourcePlan (Step 1) + idea/script + template
Output: result_data = {entity_library, scenes, metadata}; legacy asset_library is bridged only for older asset-generation code.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
Callable = typing.Callable
Dict = typing.Dict
Optional = typing.Optional

# --- Top-Level Functions ---
def _resolve_scene_count(config: services.video_pipeline.pipeline_config.PipelineConfig, resource_plan: services.video_pipeline.pipeline_config.ResourcePlan, duration: int, clip_duration: int) -> tuple[int, str]:
    pass

def _scene_manifest_error(scenes: Any, expected_ids: list[str]) -> str:
    """Return a retryable error when a block-generated scene manifest is incomplete."""
    pass

def _restore_stripped_scene_ids(scenes: Any, expected_ids: list[str]) -> bool:
    """Restore manifest IDs lost by a provider's dict-to-array coercion.

    The block merger already validated and ordered the keyed manifest before the
    response reached this client. Only repair the unambiguous case where every
    ID is blank and the list length exactly matches the expected manifest; mixed
    or partial IDs remain a hard error so scene-order bugs cannot be hidden."""
    pass

def generate_script(config: services.video_pipeline.pipeline_config.PipelineConfig, resource_plan: services.video_pipeline.pipeline_config.ResourcePlan, progress_callback: Optional[Callable] = None) -> Dict:
    """AI Call #2 — Generate scenes using template with full resource context.

    Reuses PromptBuilderV5, injecting resource_plan
    as pre-determined characters/objects/settings."""
    pass

def _enforce_scene_budget(result_data: Dict[str, Any], scene_count: int, source: str = 'Step4') -> list:
    pass

def _normalize_scene_contracts(result_data: Dict[str, Any], clip_duration: int) -> Dict[str, Any]:
    pass

def _count_directive_script_segments(script: str) -> int:
    pass

def _build_preproduction_context(resource_plan: services.video_pipeline.pipeline_config.ResourcePlan) -> str:
    pass

def _build_multi_asset_from_plan(config: services.video_pipeline.pipeline_config.PipelineConfig, resource_plan: services.video_pipeline.pipeline_config.ResourcePlan) -> Optional[Dict]:
    pass

def _parse_script_response(response: str) -> Dict:
    pass

def _normalize_char_ids_in_scenes(result_data: Dict) -> Dict:
    pass
