"""
Decompiled / Reconstructed Module: application.smart_dispatcher_port
Source PyC: smart_dispatcher_port.pyc

Docstring:
Production DispatcherPort backed by the central SmartJobDispatcher.

This is the desktop/production implementation of :class:`DispatcherPort`. It maps
the clean ``SubmitJobsCommand`` (cards + config) into the prompt-dict contract
that ``SmartJobDispatcher.submit_jobs(feature, prompts)`` expects, so QML route
submissions flow through the central engine — gaining multi-account rotation,
per-account worker pools, retry/auto-fix, queue management and progress that the
minimal :class:`HeadlessDispatcher` does not provide.

Layering note: this lives in the application layer but is the *adapter* to the
infra-level engine. It imports ``SmartJobDispatcher`` lazily (inside methods) so
the application package stays import-clean and Qt-free at module load.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
List = typing.List
_CONFIG_PASSTHROUGH = ('output_folder', 'download_folder', 'output_count', 'quality', 'filename_format', 'user_tier', 'enable_upscale', 'resolution', 'model_key', 'generation_time', 'generationTimeSeconds', 'generation_tim... [truncated]
_FEATURE_ALIASES = {'extend': 'extend_video'}
REQUIRED_COMMON = ('job_id', 'mode_key', 'tab_source', 'model', 'aspect_ratio', 'row_id', 'row_number', 'output_count')
REQUIRED_SUBMIT_META = ('history_run_id', 'history_item_id', 'history_item_index', 'route', 'runtime_kind')
REQUIRED_BY_FEATURE = {'text_video': ('prompt',), 'portrait_video': ('prompt',), 'image_video': ('mode',), 'multi_asset_video': ('prompt',), 'extend_video': ()}
REQUIRED_ANY_BY_FEATURE = {'image_video': (('start_image_path', 'image_path', 'start_media_id', 'start_media_library_id'),), 'multi_asset_video': (('asset_ids', 'asset_paths', 'asset_refs'),), 'extend_video': (('media_id', 'vi... [truncated]
_EMPTY = (None, '', [], {})

# --- Class: SmartDispatcherPort ---
class SmartDispatcherPort(DispatcherPort):
    """Route job submissions through the central SmartJobDispatcher engine."""
    _is_protocol = False
    _abc_impl = <_abc._abc_data object at 0x00000264D4D6D700>

    def _build_prompt(self, card: 'Dict[str, Any]', config: 'Dict[str, Any]', feature: 'str', index: 'int', run_id: 'str' = '') -> 'Dict[str, Any]':
        pass

    def submit_jobs(self, command: 'SubmitJobsCommand') -> 'SubmitJobsResult':
        pass

    def cancel_job(self, job_id: 'str') -> 'bool':
        pass


# --- Top-Level Functions ---
def _text(value: 'Any') -> 'str':
    pass

def _feature_name(value: 'Any') -> 'str':
    pass

def _is_portrait(aspect_ratio: 'str') -> 'bool':
    pass

def _generation_time_for_model(model_key: 'Any') -> 'int':
    pass

def _is_entity_key(value: 'str') -> 'bool':
    pass

def _add_asset_ref(refs: 'List[Dict[str, str]]', seen_ids: 'set[str]', seen_paths: 'set[str]', media_id: 'Any', path: 'Any') -> 'None':
    pass

def _collect_multi_asset_refs(prompt: 'Dict[str, Any]') -> 'List[Dict[str, str]]':
    pass

def _ensure_multi_asset_contract_refs(prompt: 'Dict[str, Any]') -> 'None':
    """Fill SmartPort contract fields for transcript/clone multi-asset cards.

    Those routes stamp job_type + character_metadata but leave asset_ids /
    asset_paths / asset_refs empty. The engine still resolves CHAR/BG from the
    prompt JSON; the contract warning and headless handler do not."""
    pass

def validate_prompt(prompt: 'Dict[str, Any]', feature: 'str') -> 'List[str]':
    """Return the list of missing required contract keys for a built prompt.

    Empty list == contract satisfied. Used by the parity test (hard guard) and as
    a runtime warning in ``submit_jobs``."""
    pass
