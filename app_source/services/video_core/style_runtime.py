"""
Decompiled / Reconstructed Module: services.video_core.style_runtime
Source PyC: style_runtime.pyc

Docstring:
Single runtime entrypoint for selected VEOFLOW styles/cameras.

Tabs and pipeline stages should use this facade instead of importing
`resolve_style_framework` or prompt helpers directly. Storage remains in
`resources/styles.json`; this module controls how selected style data becomes
prompt text for each runtime phase.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
Mapping = typing.Mapping
Optional = typing.Optional
IMAGE_STYLE_SNAPSHOT_VERSION = 1

# --- Top-Level Functions ---
def selection_from_pipeline_config(config: 'Any') -> 'Dict[str, str]':
    pass

def resolve(selection: 'Optional[Dict[str, Any]]' = None, **overrides: 'Any') -> 'Dict[str, Any]':
    pass

def resolve_from_pipeline_config(config: 'Any') -> 'Dict[str, Any]':
    pass

def resolve_inline_framework(framework_definition: 'Optional[Dict[str, Any]]', *, display_name: 'str' = 'Auto Style (video gốc)', framework_id: 'str' = '__auto_style__') -> 'Optional[Dict[str, Any]]':
    """Wrap an AI-extracted ``framework_definition`` into the same style_package
    shape ``resolve()`` returns — WITHOUT a library lookup or the keyword-profile
    strengthener (``compile_style_contract_for_item`` → ``_profile_for_style``),
    which matches on summary/name text and could clobber an observed look.

    This is the "load into the core" step for the clone auto-style pass: an ephemeral,
    video-derived framework rides the existing early-injection (`build_framework_prompt_block`)
    and dispatch (`build_post_generation_style_fields`) helpers unchanged, because those
    read only style_package keys — they never care whether it came from a saved item.
    Returns None when there's nothing usable to inject."""
    pass

def build_manual_prefix(style_package: 'Optional[Dict[str, Any]]') -> 'str':
    pass

def build_dispatch_fields(style_package: 'Optional[Dict[str, Any]]', raw_style: 'Optional[str]' = '', raw_camera: 'Optional[str]' = '', raw_style_fallback: 'Optional[str]' = None, raw_camera_fallback: 'Optional[str]' = None) -> 'Dict[str, str]':
    pass

def get_asset_generation_style(style_package: 'Optional[Dict[str, Any]]', fallback: 'str' = '') -> 'str':
    pass

def resolve_from_mapping(config: 'Mapping[str, Any] | None') -> 'Dict[str, Any]':
    pass

def _image_style_snapshot_hash_payload(snapshot: 'Mapping[str, Any]') -> 'Dict[str, Any]':
    pass

def _image_style_snapshot_hash(snapshot: 'Mapping[str, Any]') -> 'str':
    pass

def validate_image_style_snapshot(snapshot: 'Mapping[str, Any] | None') -> 'Dict[str, Any]':
    pass

def _image_dispatch_projection(style_package: 'Mapping[str, Any]', fallback: 'str') -> 'str':
    pass

def build_image_style_snapshot(config: 'Mapping[str, Any] | None') -> 'Dict[str, Any]':
    """Build/freeze authoring, asset and dispatch projections from one package.

    An existing valid snapshot wins over mutable UI config, so queued jobs cannot
    change style when the user edits the panel while they are running."""
    pass

def build_trace(style_package: 'Optional[Dict[str, Any]]', source: 'str' = '') -> 'Dict[str, Any]':
    pass
