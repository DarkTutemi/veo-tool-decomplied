"""
Decompiled / Reconstructed Module: core.dispatch.image_gen_groups
Source PyC: image_gen_groups.pyc

Docstring:
core/dispatch/image_gen_groups.py — image-gen group subsystem on V2.

Ported from the legacy SmartJobDispatcher chargen/bggen/objgen/composite
subsystem (managers/smart_job_dispatcher_legacy.py, removed 2026-06-13). Each
``submit_*_job`` fans out N ``image_generation`` jobs onto the V2
DispatchOrchestrator (same account pool as video — so PRO/ULTRA mode + tier
resolution already apply) and tracks them as a group; results are harvested at
job-completion via a JobStateSync listener and exposed through the exact legacy
attributes that ``CharacterConsistencyCore`` and ``youtube_clone_service``
poll: ``_chargen_ready_chars`` / ``_chargen_results`` (+ bg/obj/composite).

Mixed into ``LegacyCompatDispatcher`` so the caller contract is unchanged.

Result harvesting depends on ``GenResult.images`` (the raw service payload with
base64/mediaName) which ``ImageGenHandler`` attaches for group jobs only.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
TYPE_CHECKING = False
Dict = typing.Dict
List = typing.List
Optional = typing.Optional
_GROUP_MARKERS = ('chargen_group_id', 'bggen_group_id', 'objgen_group_id', 'composite_group_id')
_VALID_CHAR_MODES = {'hybrid', 'full_ai', 'manual'}

# --- Class: ImageGenGroupsMixin ---
class ImageGenGroupsMixin:
    """Image-gen group submit/track/wait API backed by the V2 orchestrator."""
    def _init_image_gen_groups(self) -> 'None':
        pass

    def _register_image_gen_listeners(self) -> 'None':
        pass

    def _on_image_job_completed(self, job_id: 'str', result: 'Any') -> 'None':
        pass

    def _on_image_job_failed(self, job_id: 'str', error: 'str' = '', category: 'str' = '') -> 'None':
        pass

    def _route_group_collect(self, job_id: 'str', success: 'bool', result: 'Dict') -> 'None':
        pass

    def _account_of_job(self, job_id: 'str') -> 'str':
        pass

    def _discard_image_job_row(self, job_id: 'str') -> 'None':
        pass

    @staticmethod
    def _img_aspect(aspect_ratio: 'str', *, allow_square: 'bool' = False) -> 'str':
        pass

    def _submit_image_job(self, prompt_data: 'dict', account_key: 'str' = '') -> 'str':
        pass

    def submit_character_generation_job(self, character_data: 'List[Dict]', output_folder: 'str', job_id: 'Optional[str]' = None, row_id: 'Optional[str]' = None, aspect_ratio: 'str' = '16:9', visual_style: 'Optional[str]' = None, parent_job_id_key: 'str' = 'clone_job_id', defer_base64_download: 'bool' = True) -> 'str':
        pass

    def _build_generated_asset_ref(self, first_img: 'Dict', worker_account: 'str' = '', source: 'str' = '') -> 'Dict':
        pass

    def _collect_chargen_result(self, image_job_id: 'str', success: 'bool', result: 'Dict', worker_account: 'str' = '') -> 'None':
        pass

    def _emit_chargen_group_completion(self, group_id: 'str', success: 'bool', assets: 'Dict', parent_job_id: 'Optional[str]' = None, chargen_media_names: 'Dict' = None, chargen_account: 'str' = '', policy_failed_characters: 'list' = None) -> 'None':
        pass

    def cancel_chargen_group(self, group_id: 'str') -> 'int':
        pass

    def _pack_chargen_wait_result(self, result: 'Dict') -> 'Dict':
        pass

    def wait_for_chargen_result(self, job_id: 'str', timeout_seconds: 'float' = 300.0, poll_interval: 'float' = 0.5, progress_callback=None) -> 'Dict':
        pass

    @staticmethod
    def _build_bggen_prompt(bg: 'Dict', visual_style: 'str' = '') -> 'str':
        pass

    def submit_bggen_job(self, background_data: 'List[Dict]', output_folder: 'str', job_id: 'Optional[str]' = None, aspect_ratio: 'str' = '16:9', visual_style: 'Optional[str]' = None, parent_job_id_key: 'str' = 'clone_job_id') -> 'str':
        pass

    def _collect_bggen_result(self, image_job_id: 'str', success: 'bool', result: 'Dict', worker_account: 'str' = '') -> 'None':
        pass

    def submit_objgen_job(self, object_data: 'List[Dict]', output_folder: 'str', job_id: 'Optional[str]' = None, aspect_ratio: 'str' = '16:9', visual_style: 'Optional[str]' = None, parent_job_id_key: 'str' = 'clone_job_id') -> 'str':
        pass

    def _collect_objgen_result(self, image_job_id: 'str', success: 'bool', result: 'Dict', worker_account: 'str' = '') -> 'None':
        pass

    def _collect_simple_group(self, image_job_id, success, result, worker_account, *, job_to_group, groups, results, ready, id_field, job_map_key, source, label) -> 'None':
        pass

    def submit_composite_image_job(self, composite_jobs: 'List[Dict]', output_folder: 'str', job_id: 'Optional[str]' = None, aspect_ratio: 'str' = '16:9', parent_job_id_key: 'str' = 'clone_job_id') -> 'str':
        pass

    def _collect_composite_result(self, image_job_id: 'str', success: 'bool', result: 'Dict', worker_account: 'str' = '') -> 'None':
        pass

    def wait_for_composite_result(self, group_id: 'str', timeout_seconds: 'float' = 300.0, poll_interval: 'float' = 0.5, progress_callback=None) -> 'Dict':
        pass


# --- Top-Level Functions ---
def _short(value: 'str') -> 'str':
    pass
