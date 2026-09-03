"""
Decompiled / Reconstructed Module: services.video_pipeline.scene_prompt_builder
Source PyC: scene_prompt_builder.pyc

Docstring:
PromptBuilderV5 — Hardcoded prompt builder, no JSON templates.

Modular Lego blocks assembled per mode:
- idea: expand short idea → full script
- script: divide existing script → scenes
- multi_asset: user-provided reference images
- char_consistency: system generates character portraits

All modes share the same scene format:
  {entity_library, anchor_plan, block_plan, scenes[*].timeline}
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
Dict = typing.Dict
Optional = typing.Optional
LANGUAGE_EXAMPLES = {'vi': {'dialogue': 'Medium shot of a warm room with soft afternoon light. Alex steps closer to Maya, looks straight into their eyes. Alex says, "Tôi sẽ không bao giờ bỏ cuộc!" Maya smiles softly, nod... [truncated]
PLACEHOLDER_CONTINUE = '# __CONTINUE__'
LANG_NAMES = {'vi': 'Vietnamese', 'en': 'English', 'ja': 'Japanese', 'ko': 'Korean', 'zh': 'Chinese', 'es': 'Spanish', 'fr': 'French', 'de': 'German', 'pt': 'Portuguese', 'ru': 'Russian', 'ar': 'Arabic', 'hi': 'Hi... [truncated]
LANG_FULL_NAMES = {'vi': 'Vietnamese (Tiếng Việt)', 'en': 'English', 'ja': 'Japanese (日本語)', 'ko': 'Korean (한국어)', 'zh': 'Chinese (中文)', 'es': 'Spanish (Español)', 'fr': 'French (Français)', 'de': 'German (Deutsch)', '... [truncated]
_AUTO_SCENE_COUNT_HINT = "- AUTO DURATION MODE: You decide the scene count. Goal: cover the COMPLETE content without summarizing.\n  VEO3 uses the selected clip duration per scene. Each scene is one independent clip; longer m... [truncated]

# --- Class: PromptBuilderV5 ---
class PromptBuilderV5:
    """Hardcoded prompt builder — no JSON templates. Lego blocks per mode."""
    def build(self, idea: str, style: str, scene_count: int, voice_language: str, mode: str = 'idea', multi_asset_info: Optional[Dict] = None, library_policy: Optional[Dict] = None, additional_instructions: str = '', target_market: str = 'global', template_context: Optional[Dict] = None, char_mode: str = 'full_ai', enable_char_consistency: bool = False, enable_flow_voice_lock: bool = False, video_model_key: str = '', style_package: Optional[Dict] = None, content_type: str = 'narrative', clip_duration_seconds: int = 8, script_input_kind: str = 'user_directive', enable_narrator: bool = False, source_idea: str = '') -> str:
        pass

    def _script_body(self, idea: str, mode: str, script_input_kind: str = 'user_directive') -> str:
        pass

    def _system_role(self) -> str:
        pass

    def _clip_seconds(self) -> int:
        pass

    def _adapt_clip_duration_text(self, text: str) -> str:
        pass

    def _task_block(self, mode: str, idea: str, scene_count: int, clip_duration_seconds: int = 8, script_input_kind: str = 'user_directive', narrator_mode: bool = False) -> str:
        pass

    def _input_params(self, idea: str, style: str, scene_count: int, lang: str, mode: str = 'idea', clip_duration_seconds: int = 8, script_input_kind: str = 'user_directive') -> str:
        pass

    def _cultural_context(self, target_market: str) -> str:
        pass

    def _entity_library_injection(self, mai: Optional[Dict]) -> str:
        pass

    def _library_category_states(self, library_policy: Optional[Dict], multi_asset_info: Optional[Dict]) -> Dict[str, list]:
        pass

    def _library_applicability_note(self, library_policy: Optional[Dict], multi_asset_info: Optional[Dict]) -> str:
        pass

    def _library_control_rules(self, *, mode: str, char_mode: str, multi_asset_info: Optional[Dict], library_policy: Optional[Dict]) -> str:
        pass

    def _story_structure(self) -> str:
        pass

    def _module_scene_format(self, lang: str, is_no_voice: bool = False, narrator_mode: bool = False) -> str:
        pass

    def _scene_estimation(self) -> str:
        pass

    def _content_rules(self, lang: str, is_no_voice: bool = False, voicelock_on: bool = False, narrator_mode: bool = False) -> str:
        pass

    def _no_narrator_policy(self) -> str:
        pass

    def _narrator_policy_block(self, enable_narrator: bool = False, lang: str = 'en') -> str:
        pass

    def _no_voice_block(self) -> str:
        pass

    @staticmethod
    def _entity_schema_library_banner(library_states: Optional[Dict]) -> str:
        pass

    def _entity_library_schema(self, enable_flow_voice_lock: bool = False, library_states: Optional[Dict] = None) -> str:
        pass

    def _scene_format(self, lang: str) -> str:
        pass

    def _language_rules(self, lang: str, language_lesson: bool = False) -> str:
        pass

    def _scene_rules(self, lang: str, is_no_voice: bool = False, total_ref_slots: int = 3, char_ref_slots: int = 3) -> str:
        pass

    def _cinematography_guide(self) -> str:
        pass

    def _anti_hallucination(self) -> str:
        pass

    def _mode_rules(self, mode: str, char_mode: str = 'full_ai', library_control_active: bool = False, total_ref_slots: int = 3) -> str:
        pass

    def _char_consistency_prompt(self, enable_char_consistency: bool) -> str:
        pass

    def _morph_transition_block(self, enable_char_consistency: bool) -> str:
        pass

    def _output_format(self, lang: str, is_no_voice: bool = False, scene_count: int = 1, narrator_mode: bool = False, library_states: Optional[Dict] = None) -> str:
        pass

    @staticmethod
    def _prune_blueprint_for_library(blueprint: Dict, library_states: Optional[Dict]) -> Dict:
        """Remove OMITTED categories' groups from the blueprint EXAMPLE itself.

        An example IS an instruction — a CHAR_000 sample sitting under a
        characters-omitted lock contradicts the control block no matter how many
        reminders follow. Pruning makes the example agree with the lock."""
        pass

    @staticmethod
    def _blueprint_library_reminder(library_states: Optional[Dict]) -> str:
        """The blueprint above shows EVERY possible group with generic examples —
        under LIBRARY CONTROL some of those groups are forbidden. Restate the lock
        right here (the schema is the LAST thing the model reads before the script,
        so a lock stated only 300 lines earlier loses to the fresh example)."""
        pass

    def _additional(self, instructions: str, mai: Optional[Dict], total_ref_slots: int = 3) -> str:
        pass

    def _style_framework_block(self, style_package: Optional[Dict], template_context: Optional[Dict]) -> str:
        pass

    def _style_anchor_block(self, style_package: Optional[Dict], framework_block: str) -> str:
        pass

    def _template_guideline(self, template_context: Optional[Dict], lang: str) -> str:
        pass

    def _template_additional_context(self, template_context: Optional[Dict]) -> str:
        pass


# --- Top-Level Functions ---
def _get_lang_name(lang: str) -> str:
    pass
