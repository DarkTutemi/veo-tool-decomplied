"""
Decompiled / Reconstructed Module: services.tabs.extend_panel.extend_prompt_service
Source PyC: extend_prompt_service.pyc

Docstring:
Extend Prompt Service - Backend service for Master Prompt Extend Chain Generator

Generates action-based storytelling prompts for extend video chains using AI.
Uses technique + material style system.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
Dict = typing.Dict
List = typing.List
Optional = typing.Optional
logger = <Logger services.tabs.extend_panel.extend_prompt_service (WARNING)>
_ARCHITECT_THINKING_BUDGET = 10000
_service_instance = None
_service_lock = <unlocked _thread.lock object at 0x00000264E654B740>

# --- Class: ExtendPromptError ---
class ExtendPromptError(Exception):
    """Custom exception for ExtendPromptService errors"""
    pass


# --- Class: ExtendPromptService ---
class ExtendPromptService:
    """Service for generating extend chain prompts — style-based, no flow system"""
    _ANTI_STATIC_CAMERA_SUFFIX = 'continuous subtle camera motion throughout the clip — never a locked-off static tripod; gentle micro-dolly or slow pan ...
    _MOVING_CAMERA_IDS = ('slow_pan_left', 'slow_pan_right', 'slow_zoom_in', 'slow_zoom_out', 'tracking', 'orbit', 'crane_up', 'crane_down', 'dol...
    _EXTEND_SPECIFICITY_MODULES = ('context', 'subjects', 'objects', 'visual_action', 'camera', 'lighting', 'effects', 'constraints')
    _EXTEND_CARRY_LEAD_RE = re.compile('^\\s*(?:(?:(?:the\\s+)?(?:clip|shot|scene)\\s+)?(?:opening|opens?|starting|starts?|beginning|begins?)\\s+(?:...
    _VEO3_PROMPT_EXCLUDE_KEYS = {'veo3_prompt', 'card_type', 'phase', 'scene_index', 'scene_id'}

    def __init__(self):
        pass

    def _load_logic_flows(self):
        pass

    def _load_styles(self):
        pass

    def get_ambient_options(self) -> List[Dict]:
        pass

    @staticmethod
    def _parse_negative_prompt(negative_prompt: str) -> List[str]:
        pass

    def generate_scenes(self, idea: str, num_scenes: int, seconds_per_scene: int = 7, camera_mode: str = 'auto', camera_value: str = 'auto', lighting_mode: str = 'fixed', lighting_value: str = 'natural', audio_mode: str = 'fixed', audio_value: str = 'silence', technique_id: str = 'none', material_id: str = 'none', additional_instructions: str = '', rules: str = '', negative_prompt: str = '', reference_images: Optional[List] = None, root_mode: str = 'text', style_package: Optional[Dict[str, Any]] = None, target_market: str = 'global', progress_callback=None) -> Dict[str, Any]:
        pass

    def _combine_style_prompt(self, technique_id: str, material_id: str) -> str:
        """Get ONLY material veo3_prompt (visual style)."""
        pass

    def _get_camera_prompt(self, technique_id: str) -> str:
        """Get technique veo3_prompt (camera movement)."""
        pass

    def _resolve_moving_camera_prompt(self, camera_value: str = '') -> str:
        """Pick a concrete moving-camera phrase; never return pure 'static'."""
        pass

    def _build_anti_static_camera_block(self) -> str:
        pass

    def _build_config_section(self, camera_mode: str, camera_value: str, lighting_mode: str, lighting_value: str, audio_mode: str = 'auto', audio_value: str = '') -> str:
        """Build config section for AI prompt"""
        pass

    def _build_specificity_contract(self) -> str:
        pass

    def _build_root_mode_section(self, root_mode: str) -> str:
        pass

    def _build_auto_fields_instruction(self, camera_mode: str, lighting_mode: str) -> str:
        pass

    def _build_timing_block(self, clip: int, num_scenes: int) -> str:
        pass

    def _build_cultural_block(self, target_market: str) -> str:
        pass

    def _build_chain_control(self, clip: int) -> str:
        pass

    def _build_extend_module_contract(self, clip: int) -> str:
        """DEDICATED extend module contract. INHERITS the shared MODULE_POOL + CONTENT_TYPE_PROFILES
        (the inventions of clone/master/transcript) and adds extend PROCESS ARCHETYPES + diverse
        examples. The AI assembles each scene DYNAMICALLY — pick only the modules a clip needs and
        build its `timeline` from short beats — so scenes stay rich + diverse (not one rigid
        'caterpillar' shape) across ANY process the user throws at it."""
        pass

    def _build_ai_prompt(self, idea: str, num_scenes: int, seconds_per_scene: int, config_section: str, auto_fields: str, additional_instructions: str, rules_text: str = '', negative_prompt: str = '', root_mode: str = 'text', framework_block: str = '', style_anchor_block: str = '', target_market: str = 'global') -> str:
        pass

    @classmethod
    def _strip_extend_carry_preamble(cls, visual: str) -> str:
        pass

    @staticmethod
    def _extend_delta_from_contract(scene: Dict[str, Any]) -> str:
        """Compile only changed actions/effects from an EXTEND timeline."""
        pass

    def _extend_delta_prompt(self, scene: Dict[str, Any], visual: str, seen_visuals: set[str]) -> str:
        pass

    def _finalize_scenes(self, scenes: List[Dict], clip: int, style_prompt: str, camera_prompt: str, global_rules: Dict[str, Any], negative_prompt: str) -> List[Dict]:
        """Keep each scene's per-second `timeline` (JSON module contract) AND compile a CLEAN
        per-second `visual` ('0-1s: … 1-2s: …', short phrases) for the card/dispatch — NOT the
        verbose 'X-second Y scene. Timeline: key: value' dump. Fold the style framework +
        restrictions into `veo3_prompt`. Tolerant of legacy flat-`visual` scenes."""
        pass

    @staticmethod
    def _compile_per_second(scene: Dict[str, Any]) -> str:
        """CLEAN per-second prose from the timeline beats: '0-1s: <subject/action/camera>. 1-2s:
        <action>. …'. Short — one phrase per second; drops the module-key noise (no 'context:
        description:', no 'X-second Y scene', no 'Audio summary:'). SFX summarized once at end."""
        pass

    def _parse_ai_response(self, response: str) -> Dict[str, Any]:
        pass

    def _clean_json_string(self, json_str: str) -> str:
        pass

    def _apply_card_types(self, scenes: List[Dict]) -> List[Dict]:
        pass

    def _build_veo3_prompts(self, scenes: List[Dict], camera_mode: str, camera_value: str, lighting_mode: str, lighting_value: str, audio_mode: str, audio_value: str, style_prompt: str = '', global_rules: Dict[str, Any] = None, camera_prompt: str = '', negative_prompt: str = '') -> List[Dict]:
        """Build final VEO3 prompts for each scene — plain text, VEO 3.1 optimized.

        Strategy:
        - ROOT (scene 0): Full establishment — [Camera] + [Subject+Setting] + [Lighting] + [Audio] + [Style] + [Rules]
        - EXTEND (scene 1+): Continuation — [Transition] + [New visual state] + [Audio] + [Style]
          EXTEND describes what CHANGES from the previous frame, not the full scene."""
        pass


# --- Top-Level Functions ---
def get_extend_prompt_service() -> services.tabs.extend_panel.extend_prompt_service.ExtendPromptService:
    pass
