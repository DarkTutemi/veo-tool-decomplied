"""
Decompiled / Reconstructed Module: services.script_architect_engine
Source PyC: script_architect_engine.pyc

Docstring:
Single-file Script Architect.

Script Architect is a pre-production tool for Master Prompt idea mode:

    rough idea -> complete directive-rich script -> normal script pipeline

It deliberately does not build final VEO payloads. It writes a strong script and
a machine-readable ResourcePlan so the existing script-mode core can handle
scene JSON, assets, references, voice lock, and dispatch in one consistent path.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['ArchitectState', 'TierRecord', 'estimate_tokens', 'run_script_architect', '_build_generation_prompt', '_convert_to_pipeline_format']

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Callable = typing.Callable
Dict = typing.Dict
List = typing.List
Optional = typing.Optional
MASTER_PROMPT_THINKING_BUDGET = 8000
_SCENE_HEADER_RE = re.compile('(?im)^\\s*\\[SCENE\\s+(?P<scene_id>\\d{1,3}[a-z]?)(?:\\s*-\\s*[^\\]\\r\\n]*)?\\](?P<tail>[^\\r\\n]*)$', re.IGNORECASE|re.MULTILINE)
__all__ = ['ArchitectState', 'TierRecord', 'estimate_tokens', 'run_script_architect', '_build_generation_prompt', '_convert_to_pipeline_format']

# --- Class: TierRecord ---
class TierRecord:
    """Telemetry for the consolidated architect call."""
    started_at = 0.0
    duration_ms = 0
    tokens_in = 0
    tokens_out = 0
    success = False
    error = None
    prompt = None
    response = None

    def __init__(self, tier_id: 'str', started_at: 'float' = 0.0, duration_ms: 'int' = 0, tokens_in: 'int' = 0, tokens_out: 'int' = 0, success: 'bool' = False, error: 'Optional[str]' = None, prompt: 'Optional[str]' = None, response: 'Optional[str]' = None) -> None:
        pass

    def __repr__(self):
        pass


# --- Class: ArchitectState ---
class ArchitectState:
    """All context Script Architect needs before writing the hand-off script."""
    idea = ''
    style = ''
    voice_language = 'vi'
    target_market = 'global'
    duration = 60
    clip_duration_seconds = 8
    aspect_ratio = '16:9'
    enable_thinking = True
    thinking_budget = 8000
    enable_char_consistency = False
    enable_scene_consistency = False
    enable_flow_voice_lock = False
    enable_narrator = False
    video_model_key = ''
    account_tier = 'ultra'
    char_mode = 'full_ai'
    additional_instructions = ''
    genre = ''
    debug = False
    prompt = ''
    raw_response = ''
    detected_content_type = 'narrative'
    directive_script = ''

    def record(self, rec: 'TierRecord') -> 'None':
        pass

    def total_tokens(self) -> 'Dict[str, int]':
        pass

    def total_duration_ms(self) -> 'int':
        pass

    def __init__(self, idea: 'str' = '', style: 'str' = '', voice_language: 'str' = 'vi', target_market: 'str' = 'global', duration: 'int' = 60, clip_duration_seconds: 'int' = 8, aspect_ratio: 'str' = '16:9', enable_thinking: 'bool' = True, thinking_budget: 'int' = 8000, enable_char_consistency: 'bool' = False, enable_scene_consistency: 'bool' = False, enable_flow_voice_lock: 'bool' = False, enable_narrator: 'bool' = False, video_model_key: 'str' = '', account_tier: 'str' = 'ultra', char_mode: 'str' = 'full_ai', user_assets: 'List[Dict[str, Any]]' = <factory>, additional_instructions: 'str' = '', genre: 'str' = '', domain_profile: 'Dict[str, Any]' = <factory>, debug: 'bool' = False, library_policy: 'Dict[str, Any]' = <factory>, multi_asset_info: 'Dict[str, Any]' = <factory>, prompt: 'str' = '', raw_response: 'str' = '', detected_content_type: 'str' = 'narrative', resource_plan_payload: 'Dict[str, Any]' = <factory>, directive_script: 'str' = '', tier_history: 'List[TierRecord]' = <factory>) -> None:
        pass

    def __repr__(self):
        pass


# --- Top-Level Functions ---
def estimate_tokens(text: 'str') -> 'int':
    pass

def run_script_architect(config: 'PipelineConfig', progress_callback: 'Optional[Callable]' = None) -> 'Dict[str, Any]':
    pass

def _build_generation_prompt(state: 'ArchitectState') -> 'str':
    pass

def _narrator_contract(state: 'ArchitectState', clip_s: 'int') -> 'str':
    pass

def _library_control_contract(state: 'ArchitectState') -> 'str':
    pass

def _character_consistency_contract(state: 'ArchitectState') -> 'str':
    pass

def _anchor_consistency_contract(state: 'ArchitectState') -> 'str':
    pass

def _format_user_assets_for_prompt(state: 'ArchitectState') -> 'str':
    pass

def _additional_instructions_block(state: 'ArchitectState') -> 'str':
    pass

def _recover_script_after_resource_plan(text: 'str') -> 'str':
    pass

def _parse_architect_response(text: 'str') -> 'tuple[Dict[str, Any], str]':
    pass

def _extract_tag(text: 'str', tag: 'str') -> 'str':
    pass

def _strip_fences(text: 'str') -> 'str':
    pass

def _extract_first_json_object(text: 'str') -> 'str':
    pass

def _resource_plan_from_payload(payload: 'Dict[str, Any]', state: 'ArchitectState', script: 'str') -> 'ResourcePlan':
    pass

def _as_list(value: 'Any') -> 'List[Any]':
    pass

def _normalize_characters(items: 'List[Any]', state: 'ArchitectState') -> 'List[Dict[str, Any]]':
    pass

def _normalize_objects(items: 'List[Any]') -> 'List[Dict[str, Any]]':
    pass

def _normalize_backgrounds(items: 'List[Any]') -> 'List[Dict[str, Any]]':
    pass

def _normalize_scene_breakdown(plan: 'Dict[str, Any]', script: 'str', state: 'ArchitectState') -> 'List[Dict[str, Any]]':
    pass

def _scene_breakdown_from_script(script: 'str', clip: 'int') -> 'List[Dict[str, Any]]':
    pass

def _first_visual_line(body: 'str') -> 'str':
    pass

def _safe_int(value: 'Any', default: 'int') -> 'int':
    pass

def _expected_clip_budget(resource_plan: 'ResourcePlan', state: 'ArchitectState', fallback: 'int') -> 'int':
    pass

def _validate_directive_script(state: 'ArchitectState', script: 'str', expected_clips: 'int') -> 'Dict[str, List[str]]':
    pass

def _convert_to_pipeline_format(script: 'str', *, max_total_scenes: 'int' = 0) -> 'str':
    pass

def _build_state(config: 'PipelineConfig') -> 'ArchitectState':
    pass

def _dump_debug(state: 'ArchitectState', config: 'PipelineConfig') -> 'str':
    pass

def _safe_asdict(value: 'Any') -> 'Dict[str, Any]':
    pass

def _max_output_tokens_for_target(target_clips: 'int') -> 'int':
    pass
