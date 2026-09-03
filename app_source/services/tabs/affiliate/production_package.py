"""
Decompiled / Reconstructed Module: services.tabs.affiliate.production_package
Source PyC: production_package.pyc

Docstring:
Build the immutable Affiliate production package at worker admission.

This is the hard boundary between the mutable waiting pool and production:

* preparation may call AI/TTS/image/consistency services;
* a durable queue row may wait with its sales plan while CHAR/BG inputs remain
  editable;
* immediately before submit, the worker reads the latest inputs and locks a
  package whose timeline, voice timing, references, slot arithmetic and optional
  start frames have passed;
* production may submit/render/merge, but it must not plan or select assets.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Callable = typing.Callable
Dict = typing.Dict
PACKAGE_SCHEMA_VERSION = 2

# --- Class: AffiliateProductionRuntime ---
class AffiliateProductionRuntime:
    """Authorized Affiliate operations supplied by the RAM-loaded feature pack.

    The shell-side package builder must never import private symbols from the
    protected queue module.  The active pack hands these callables across the
    boundary for one package build instead."""
    def validate(self) -> 'None':
        pass

    def __init__(self, apply_product_reference_contract: 'Callable[..., Any]', apply_wearable_look_routing: 'Callable[..., Any]', apply_live_resource_choices: 'Callable[..., Any]', asset_inputs: 'Callable[..., Any]', intake_source: 'Callable[..., Any]', model_budget: 'Callable[..., Any]', narrator_enabled: 'Callable[..., Any]', narration_voice_state: 'Callable[..., Any]', package_multi_asset_info: 'Callable[..., Any]', plan_has_narration: 'Callable[..., Any]', pipeline_config: 'Callable[..., Any]', rebind_plan_resources: 'Callable[..., Any]', render_slots: 'Callable[..., Any]', prepare_wearable_character_looks: 'Callable[..., Any]', resource_binding: 'Callable[..., Any]', resource_plan: 'Callable[..., Any]', save_generated_assets: 'Callable[..., Any]', user_assets: 'Callable[..., Any]', variant_output_folder: 'Callable[..., Any]', scene_analysis_from_plan: 'Callable[..., Any]') -> None:
        pass

    def __repr__(self):
        pass


# --- Top-Level Functions ---
def _text(value: 'Any') -> 'str':
    pass

def _safe_dict(value: 'Any') -> 'Dict[str, Any]':
    pass

def _safe_list(value: 'Any') -> 'list[Any]':
    pass

def _safe_int(value: 'Any', default: 'int' = 0) -> 'int':
    pass

def _durable_metadata(meta_map: 'Dict[str, Any]') -> 'Dict[str, Any]':
    pass

def _entity_library_items(plan: 'Dict[str, Any]', category: 'str') -> 'list[Dict[str, Any]]':
    pass

def _same_entity_identity(current: 'Dict[str, Any]', previous: 'Dict[str, Any]') -> 'bool':
    pass

def _reusable_sibling_asset_slots(store: 'Any', variant: 'Dict[str, Any]', plan: 'Dict[str, Any]', resource_binding: 'Dict[str, Any]') -> 'tuple[list[Dict[str, Any]], list[Dict[str, Any]]]':
    pass

def start_frame_scene_indices(scenes: 'list[Any]', start_mode: 'str') -> 'list[int]':
    pass

def validate_production_package(package: 'Dict[str, Any]') -> 'list[str]':
    pass

def prepare_workflow_variant(variant_run_id: 'str', *, runtime: 'AffiliateProductionRuntime', progress: 'Callable[[Dict[str, Any]], None] | None' = None, cancel_check: 'Callable[[], bool] | None' = None, runtime_config: 'Dict[str, Any] | None' = None, force_rebuild: 'bool' = False, allow_queued: 'bool' = False) -> 'Dict[str, Any]':
    """Resolve and persist one production package.

    The caller runs this function off the GUI thread.  Progress is a small dict
    suitable for a queued Qt signal; no Qt object is touched here."""
    pass
