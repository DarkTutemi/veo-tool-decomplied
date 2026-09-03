"""
Decompiled / Reconstructed Module: services.automation_center.adapters.tool1_product_queue
Source PyC: tool1_product_queue.pyc

Docstring:
Shared lifecycle projection for Tool 1 product queue adapters.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['Tool1ProductQueueAdapter', 'mapping', 'text']

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
__all__ = ['Tool1ProductQueueAdapter', 'mapping', 'text']

# --- Class: Tool1ProductQueueAdapter ---
class Tool1ProductQueueAdapter:
    """Common fail-closed snapshot/artifact behavior for native route queues."""
    workflow = ''
    capability = ''
    display_name = 'Workflow'
    schema_versions = ('1.0',)
    input_modes = ()
    feature_code = ''

    def __init__(self, *, service_provider: 'Callable[[], Any]', config_provider: 'Callable[[], Mapping[str, Any]]', admission_provider: 'Callable[[], Mapping[str, Any] | None]', session_key: 'str') -> 'None':
        pass

    def capabilities(self) -> 'dict[str, Any]':
        pass

    def _validate_identity(self, job: 'AutomationJob') -> 'None':
        pass

    def _admission_blocker(self) -> 'dict[str, Any] | None':
        pass

    def _automation_config(self, job: 'AutomationJob') -> 'dict[str, Any]':
        pass

    def snapshot(self, internal_run_id: 'str') -> 'WorkflowSnapshot':
        pass

    def collect_artifacts(self, internal_run_id: 'str') -> 'tuple[ArtifactCandidate, ...]':
        pass

    def ensure_started(self, internal_run_id: 'str') -> 'WorkflowSnapshot':
        pass

    def pause_at_safe_point(self, internal_run_id: 'str') -> 'WorkflowSnapshot':
        pass

    def request_cancel(self, internal_run_id: 'str') -> 'WorkflowSnapshot':
        pass

    def reconcile(self, internal_run_id: 'str', *, checkpoint: 'dict[str, Any]', provider_job_ids: 'tuple[str, ...]') -> 'WorkflowSnapshot':
        pass

    @staticmethod
    def _row_progress(row: 'Mapping[str, Any]') -> 'int':
        pass

    def _artifacts_from_row(self, row: 'Mapping[str, Any]') -> 'tuple[ArtifactCandidate, ...]':
        pass

    def _find_row(self, internal_run_id: 'str') -> 'dict[str, Any] | None':
        pass

    def _start_target(self, internal_run_id: 'str', row: 'Mapping[str, Any]') -> 'Mapping[str, Any]':
        pass


# --- Top-Level Functions ---
def text(value: 'Any') -> 'str':
    pass

def mapping(value: 'Any') -> 'dict[str, Any]':
    pass
