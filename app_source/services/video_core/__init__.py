"""
Decompiled / Reconstructed Module: services.video_core.__init__
Source PyC: __init__.pyc

Docstring:
Shared video-scene core for Master, Clone, Transcript/Audio, and Normal tabs.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['CompileResult', 'NO_HUMAN_RULES', 'NO_VOICE_RULES', 'ReferencePlan', 'ScenePolicy', 'SceneSchemaError', 'anchor_policy_prompt_block', 'clean_model_facing_value', 'build_model_intent', 'build_entity_library_from_media_ids', 'build_legacy_asset_library_from_media_ids', 'build_multi_asset_info_from_provided_characters', 'build_preselected_character_entity_library', 'build_prompt_data', 'build_prompt_data_from_compiled_result', 'build_queue_prompt_item_from_compiled_result', 'build_scene_fallback_prompt_data', 'build_visual_timeline_scene', 'compile_visual_scene_prompt', 'compile_scene_prompt_data', 'compile_visual_scene_prompt_data', 'compile_video_scene_prompt', 'director_brief_has_dialogue', 'anchor_library_from_entity_library', 'apply_style_override_to_libraries', 'build_legacy_asset_library', 'ensure_entity_library', 'ensure_legacy_asset_library', 'ensure_style_in_libraries', 'entity_library_from_asset_library', 'legacy_asset_library_from_entity_library', 'merge_legacy_asset_libraries', 'merge_entity_libraries', 'merge_provided_asset_library_into_result', 'extract_locked_entity_refs', 'extract_scene_requirements', 'filter_asset_library_for_locked_refs', 'get_anchor_flag', 'get_char_consistency_prompt', 'get_cinematography_guide', 'get_scene_policy', 'get_scene_writing_rules', 'inject_voice_into_dialogue', 'inject_voice_into_scene', 'prompt_text_for_job_record', 'prompt_text_from_payload', 'prompt_text_from_prompt_data', 'normalize_legacy_asset_library', 'normalize_anchor_flag', 'normalize_entity_library', 'preserve_provided_character_voice_metadata', 'remove_character_from_libraries', 'replace_character_in_libraries', 'set_characters_in_libraries', 'normalize_dialogue', 'normalize_director_brief', 'normalize_scene', 'normalize_result_scene_contract', 'normalize_multi_asset_info', 'normalize_video_quality', 'preferred_video_output_path', 'sync_legacy_asset_library_to_entity_library', 'sync_result_libraries', 'update_character_fields_in_libraries', 'update_legacy_asset_entry_fields', 'plan_scene_references', 'build_scene_asset_plan', 'strip_asset_ids', 'strip_asset_ids_for_wire', 'strip_scene_for_veo3', 'video_output_contract']

# --- Module Constants & Globals ---
NO_HUMAN_RULES = 'No people. No humans. No characters. No faces. No silhouettes of people. No hands. No body parts. Pure environment, scenery, or objects only.'
NO_VOICE_RULES = 'No voice. No speech. No talking. No dialogue. No whispering. No lip movement. No mouth opening. No vocal sounds. Characters are completely silent. Show emotions through facial expressions and body la... [truncated]
__all__ = ['CompileResult', 'NO_HUMAN_RULES', 'NO_VOICE_RULES', 'ReferencePlan', 'ScenePolicy', 'SceneSchemaError', 'anchor_policy_prompt_block', 'clean_model_facing_value', 'build_model_intent', 'build_entity_... [truncated]
