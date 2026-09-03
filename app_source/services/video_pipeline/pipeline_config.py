"""
Decompiled / Reconstructed Module: services.video_pipeline.pipeline_config
Source PyC: pipeline_config.pyc

Docstring:
PipelineConfig — Unified configuration for the video generation pipeline.

All tabs build a PipelineConfig from their UI state, then pass it to VideoPipeline.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
Dict = typing.Dict
List = typing.List
Optional = typing.Optional
MASTER_PROMPT_THINKING_BUDGET = 8000
_PIPELINE_AI_FEATURE_BY_PARENT_KEY = {'master_prompt_job_id': 'master_prompt', 'clone_job_id': 'clone_video', 'transcript_job_id': 'transcript_video', 'affiliate_queue_row_id': 'affiliate_video', 'voice_studio_job_id': 'voice_studio', 'n... [truncated]

# --- Class: PipelineConfig ---
class PipelineConfig:
    """Configuration for a single video generation job."""
    idea = ''
    script = ''
    script_type = 'auto'
    template_name = 'storytelling'
    style = ''
    camera = ''
    voice_language = 'vi'
    aspect_ratio = '16:9'
    duration = 60
    clip_duration_seconds = 8
    target_market = 'global'
    subtitle_profile = None
    enable_char_consistency = False
    char_mode = 'full_ai'
    enable_flow_voice_lock = False
    enable_narrator = False
    enable_scene_consistency = False
    enable_scene_asset_planner = True
    enable_i2v_start = False
    prefer_i2v_for_overflow = False
    enable_i2v_interpolation = False
    multi_asset_info = None
    library_policy = None
    video_model_key = ''
    enable_upscale = False
    resolution = '720p'
    account_tier = 'ultra'
    session_folder = ''
    output_folder = ''
    additional_instructions = ''
    technique_name = ''
    material_name = ''
    material_id = ''
    style_mode = 'framework'
    style_framework_id = ''
    resolved_style_package = None
    style_id = ''
    camera_id = ''
    structural_style_id = ''
    structural_camera_id = ''
    surface_style_id = ''
    surface_camera_id = ''
    enable_thinking = True
    thinking_budget = 8000
    script_architect_mode = True
    script_architect_debug = False
    script_architect_debug_dir = ''
    job_id = ''
    job_title = ''
    parent_job_id_key = 'clone_job_id'
    cancel_event = None

    def __init__(self, idea: str = '', script: str = '', script_type: str = 'auto', template_name: str = 'storytelling', style: str = '', camera: str = '', voice_language: str = 'vi', aspect_ratio: str = '16:9', duration: int = 60, clip_duration_seconds: int = 8, target_market: str = 'global', subtitle_profile: Optional[Dict[str, Any]] = None, enable_char_consistency: bool = False, char_mode: str = 'full_ai', enable_flow_voice_lock: bool = False, enable_narrator: bool = False, enable_scene_consistency: bool = False, enable_scene_asset_planner: bool = True, enable_i2v_start: bool = False, prefer_i2v_for_overflow: bool = False, enable_i2v_interpolation: bool = False, user_assets: List[Dict] = <factory>, multi_asset_info: Optional[Dict] = None, library_policy: Optional[Dict] = None, video_model_key: str = '', enable_upscale: bool = False, resolution: str = '720p', account_tier: str = 'ultra', session_folder: str = '', output_folder: str = '', additional_instructions: str = '', technique_name: str = '', material_name: str = '', material_id: str = '', style_mode: str = 'framework', style_framework_id: str = '', resolved_style_package: Optional[Dict[str, Any]] = None, style_id: str = '', camera_id: str = '', structural_style_id: str = '', structural_camera_id: str = '', surface_style_id: str = '', surface_camera_id: str = '', enable_thinking: bool = True, thinking_budget: int = 8000, script_architect_mode: bool = True, script_architect_debug: bool = False, script_architect_debug_dir: str = '', job_id: str = '', job_title: str = '', parent_job_id_key: str = 'clone_job_id', cancel_event: Optional[threading.Event] = None) -> None:
        pass

    def __repr__(self):
        pass


# --- Class: ResourcePlan ---
class ResourcePlan:
    """Output of Step 1 — Pre-production planning."""
    content_type = 'narrative'
    provided_chars = <property object at 0x00000264E782F8D0>
    new_chars = <property object at 0x00000264E782F970>
    needs_chargen = <property object at 0x00000264E782FA60>

    def __init__(self, content_type: str = 'narrative', story_outline: Dict = <factory>, scene_breakdown: List[Dict] = <factory>, characters: List[Dict] = <factory>, objects: List[Dict] = <factory>, settings: List[Dict] = <factory>, backgrounds: List[Dict] = <factory>) -> None:
        pass

    def __repr__(self):
        pass


# --- Top-Level Functions ---
def build_master_thinking_config(enabled: bool = True, budget: Optional[int] = None) -> Optional[Dict[str, Any]]:
    pass

def feature_for_pipeline_config(config: Any) -> str:
    pass
