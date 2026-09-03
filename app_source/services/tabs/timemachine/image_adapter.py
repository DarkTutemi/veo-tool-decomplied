"""
Decompiled / Reconstructed Module: services.tabs.timemachine.image_adapter
Source PyC: image_adapter.pyc

Docstring:
Central-dispatch image adapter for the pure Time Machine regress engine.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['GoogleLabsRegressAdapter', 'reinforce_timemachine_image_prompt']

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Callable = typing.Callable
Dict = typing.Dict
Optional = typing.Optional
_RENDER_FIDELITY_MARKER = 'TIMEMACHINE_RENDER_FIDELITY_V1'
__all__ = ['GoogleLabsRegressAdapter', 'reinforce_timemachine_image_prompt']

# --- Class: GoogleLabsRegressAdapter ---
class GoogleLabsRegressAdapter:
    """Edit one immediately previous frame and persist the earlier result."""
    def __init__(self, *, account: 'Dict[str, Any]', output_dir: 'str', model: 'str' = '', aspect_ratio: 'str' = 'IMAGE_ASPECT_RATIO_LANDSCAPE', generation_gateway: 'Optional[Any]' = None, upload_service: 'Optional[Any]' = None, parent_job_id: 'str' = '', status_callback: 'Optional[Callable[[Dict[str, Any]], None]]' = None, style_context: 'str' = '', enable_still_upscale: 'bool' = True, upscale_image: 'Optional[Callable[..., Dict[str, Any]]]' = None) -> 'None':
        pass

    def _resolve_reference(self, raw: 'Dict[str, Any]') -> 'str':
        pass

    def _promote_still_to_4k(self, *, image_path: 'str', media_name: 'str', media_id: 'str') -> 'Dict[str, Any]':
        pass

    def _publish_still_media(self, image_path: 'str', media_name: 'str', media_id: 'str', note: 'str') -> 'Dict[str, Any]':
        pass

    def _still_upscale_failure(self, image_path: 'str', media_name: 'str', media_id: 'str', message: 'str', error_category: 'str' = 'recaptcha_failed', retryable: 'bool' = True) -> 'Dict[str, Any]':
        pass

    def _upload_4k_plate(self, image_path: 'str') -> 'str':
        pass

    def _emit_status(self, payload: 'Dict[str, Any]', *, view_id: 'str', target_stage: 'int') -> 'None':
        pass

    def _generate(self, *, prompt: 'str', media_names: 'list[str]', view_id: 'str', target_stage: 'int', failure_code: 'str', failure_message: 'str') -> 'Dict[str, Any]':
        pass

    def __call__(self, *, prompt: 'str', image_inputs: 'list[Dict[str, Any]]', view_id: 'str', target_stage: 'int') -> 'Dict[str, Any]':
        pass

    def generate_anchor(self, *, prompt: 'str', view_id: 'str' = 'idea_anchor', target_stage: 'int' = 99) -> 'Dict[str, Any]':
        pass

    def generate_forward_target(self, *, prompt: 'str', image_inputs: 'list[Dict[str, Any]]', view_id: 'str', target_stage: 'int') -> 'Dict[str, Any]':
        pass


# --- Top-Level Functions ---
def _still_metric(*, parent_job_id: 'str', stage: 'str', elapsed_ms: 'float', **fields: 'Any') -> 'None':
    pass

def usable_i2v_image_id(media_id: 'str') -> 'str':
    pass

def reinforce_timemachine_image_prompt(prompt: 'str', *, style_context: 'str' = '', has_reference: 'bool' = False) -> 'str':
    pass
