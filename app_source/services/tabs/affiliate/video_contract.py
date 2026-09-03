"""
Decompiled / Reconstructed Module: services.tabs.affiliate.video_contract
Source PyC: video_contract.pyc

Docstring:
Affiliate-owned planning and model-wire contracts.

Affiliate deliberately does not import the Master/Clone scene-module prompt
contract.  Its sales planner needs commerce-only reasoning fields, while Veo
must receive only the executable timeline plus the references selected by the
Affiliate production package.

The shared dispatcher remains transport infrastructure.  Everything that
decides what Affiliate asks the planning LLM to write, and what Affiliate lets
through to the video model, lives in this module.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['AFFILIATE_WIRE_PLAN_KEYS', 'affiliate_product_wire_identity', 'affiliate_timeline_has_character_dialogue', 'affiliate_wire_entity_context', 'build_affiliate_scene_contract', 'clean_affiliate_runtime_scene']

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
Optional = typing.Optional
AFFILIATE_WIRE_PLAN_KEYS = ('scene_role', 'persuasion_stage', 'viewer_reward', 'offer_item_ids', 'proof_ids', 'role_ids', 'sales_logic', 'render_strategy', 'human_presence', 'human_presence_reason', 'speech_reason', 'uses_chara... [truncated]
_SPEECH_PERFORMANCE_RE = re.compile('(?:\\b(?:speak(?:s|ing)?|talk(?:s|ing)?|say(?:s|ing)?|tell(?:s|ing)?|explain(?:s|ing)?|introduc(?:e|es|ing)|present(?:s|ing)?|pitch(?:es|ing)?|announc(?:e|es|ing)|invite(?:s|d|ing)?|addres... [truncated]
_GENERATED_UI_RE = re.compile('(?:\\b(?:ui|button|badge|sticker|banner|caption|screen\\s+text|shopping\\s+cart\\s+icon)\\b|(?:biểu\\s+tượng\\s+giỏ\\s+hàng|nút\\s+giỏ\\s+hàng|sticker|banner|khung\\s+giá|chữ\\s+trên\\s+mà... [truncated]
__all__ = ['AFFILIATE_WIRE_PLAN_KEYS', 'affiliate_product_wire_identity', 'affiliate_timeline_has_character_dialogue', 'affiliate_wire_entity_context', 'build_affiliate_scene_contract', 'clean_affiliate_runtime... [truncated]

# --- Top-Level Functions ---
def build_affiliate_scene_contract(clip_duration_seconds: 'int' = 8, *, narrator_enabled: 'bool' = False, voice_language: 'str' = '') -> 'str':
    pass

def _prune_empty_wire_value(value: 'Any') -> 'Any':
    pass

def affiliate_wire_entity_context(context: 'Dict[str, Any]') -> 'Dict[str, Any]':
    pass

def _normalized_label(value: 'Any') -> 'str':
    pass

def affiliate_product_wire_identity(entity_library: 'Dict[str, Any]') -> 'tuple[str, set[str]]':
    pass

def _is_product_wire_name(value: 'Any', identities: 'set[str]') -> 'bool':
    pass

def affiliate_timeline_has_character_dialogue(timeline: 'Any') -> 'bool':
    pass

def _append_render_action(target: 'Dict[str, Any]', key: 'str', action: 'str') -> 'None':
    pass

def _without_forbidden_clauses(value: 'Any', pattern: 're.Pattern[str]') -> 'str':
    pass

def _sanitize_actor_cues(beat: 'Dict[str, Any]') -> 'None':
    pass

def _sanitize_generated_ui_cues(beat: 'Dict[str, Any]') -> 'None':
    pass

def _append_unique_fragment(parts: 'list[str]', value: 'Any') -> 'None':
    pass

def _canonical_actor_actions(beat: 'Dict[str, Any]', *, product_identities: 'set[str]') -> 'list[Dict[str, str]]':
    """Collapse Affiliate planning taxonomy into one instruction per actor."""
    pass

def _fold_timeline_for_wire(timeline: 'Any', *, has_dialogue: 'bool', product_label: 'str', product_identities: 'set[str]') -> 'None':
    pass

def clean_affiliate_runtime_scene(scene: 'Dict[str, Any]', *, has_dialogue: 'bool', audio_mode: 'str' = '', product_label: 'str' = '', product_identities: 'Optional[set[str]]' = None) -> 'Dict[str, Any]':
    pass
