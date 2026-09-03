"""
Decompiled / Reconstructed Module: services.automation_center.channel_development_kit
Source PyC: channel_development_kit.pyc

Docstring:
Projection and safety helpers for deep per-channel Tool 1 configuration.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['diff_snapshots', 'sanitize_workflow_config', 'workflow_config_fields', 'workflow_config_hash', 'workflow_config_issues']

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
FROZEN_ASSIGNMENT_CONFIG_MARKER = '_automation_assignment_config_snapshot_v2'
CHANNEL_WORKFLOWS = ('master', 'clone', 'transcript', 'affiliate', 'timemachine')
_VOLATILE_KEYS = {'master': frozenset({'multi_asset_info'}), 'clone': frozenset(), 'transcript': frozenset(), 'affiliate': frozenset(), 'timemachine': frozenset({'automation_lease_generation', 'base_output_folder', 'a... [truncated]
_GROUP_KEYS = (('output', frozenset({'image_resolution', 'output_mode', 'output_folder', 'resolution', 'output_count', 'image_model', 'filename_format', 'enable_upscale', 'quality', 'model_key', 'clip_duration_seco... [truncated]
_TRANSCRIPT_STYLE_KEYS = ('selected_style_id', 'style_id', 'override_style', 'selected_style', 'selected_style_name', 'structural_style_id')
__all__ = ['diff_snapshots', 'sanitize_workflow_config', 'workflow_config_fields', 'workflow_config_hash', 'workflow_config_issues']

# --- Top-Level Functions ---
def sanitize_workflow_config(workflow: 'str', value: 'Mapping[str, Any] | None') -> 'dict[str, Any]':
    pass

def workflow_config_hash(config: 'Mapping[str, Any] | None') -> 'str':
    pass

def workflow_config_issues(workflow: 'str', config: 'Mapping[str, Any] | None') -> 'list[dict[str, str]]':
    """Run config-only checks that exactly mirror native adapter gates.

    Input/product/browser checks remain work-order preflight because they need
    the assigned source. These checks are deliberately limited to conditions
    knowable from one immutable channel workflow snapshot."""
    pass

def _value_type(value: 'Any') -> 'str':
    pass

def _field_group(key: 'str') -> 'str':
    pass

def workflow_config_fields(config: 'Mapping[str, Any] | None') -> 'list[dict[str, Any]]':
    pass

def diff_snapshots(before: 'Mapping[str, Any] | None', after: 'Mapping[str, Any] | None') -> 'list[dict[str, Any]]':
    pass
