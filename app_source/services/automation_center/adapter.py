"""
Decompiled / Reconstructed Module: services.automation_center.adapter
Source PyC: adapter.pyc

Docstring:
Narrow workflow boundary owned by the local Automation Center runtime.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['FROZEN_ASSIGNMENT_CONFIG_MARKER', 'WorkflowAdapter', 'resolve_automation_config']

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
FROZEN_ASSIGNMENT_CONFIG_MARKER = '_automation_assignment_config_snapshot_v2'
__all__ = ['FROZEN_ASSIGNMENT_CONFIG_MARKER', 'WorkflowAdapter', 'resolve_automation_config']

# --- Class: WorkflowAdapter ---
class WorkflowAdapter(Protocol):
    _is_protocol = True
    _abc_impl = <_abc._abc_data object at 0x00000264DF455900>

    def capabilities(self) -> 'dict[str, Any]':
        pass

    def validate(self, job: 'AutomationJob') -> 'None':
        pass

    def start(self, job: 'AutomationJob', *, on_internal_run_created: 'Callable[[str], None]') -> 'str':
        pass

    def snapshot(self, internal_run_id: 'str') -> 'WorkflowSnapshot':
        pass

    def collect_artifacts(self, internal_run_id: 'str') -> 'tuple[ArtifactCandidate, ...]':
        pass

    def pause_at_safe_point(self, internal_run_id: 'str') -> 'WorkflowSnapshot':
        pass

    def request_cancel(self, internal_run_id: 'str') -> 'WorkflowSnapshot':
        pass

    def reconcile(self, internal_run_id: 'str', *, checkpoint: 'dict[str, Any]', provider_job_ids: 'tuple[str, ...]') -> 'WorkflowSnapshot':
        pass

    def __init__(self, *args, **kwargs):
        pass


# --- Top-Level Functions ---
def resolve_automation_config(job: 'AutomationJob', config_provider: 'Callable[[], Mapping[str, Any]]') -> 'dict[str, Any]':
    pass
