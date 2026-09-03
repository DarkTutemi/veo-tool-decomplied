"""
Decompiled / Reconstructed Module: services.automation_center.adapters.master
Source PyC: master.pyc

Docstring:
Master Prompt adapter using the same backend entrypoints as the desktop UI.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['MasterWorkflowAdapter']

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
__all__ = ['MasterWorkflowAdapter']

# --- Class: MasterWorkflowAdapter ---
class MasterWorkflowAdapter:
    workflow = 'master'
    schema_versions = ('1.0',)

    def __init__(self, *, service_provider: 'Callable[[], Any] | None' = None, config_provider: 'Callable[[], Mapping[str, Any]] | None' = None, admission_provider: 'Callable[[], Mapping[str, Any] | None] | None' = None, session_key: 'str' = 'master_prompt') -> 'None':
        pass

    @staticmethod
    def _default_service_provider() -> 'Any':
        pass

    @staticmethod
    def _default_config_provider() -> 'Mapping[str, Any]':
        pass

    @staticmethod
    def _default_admission_provider() -> 'Mapping[str, Any] | None':
        pass

    def capabilities(self) -> 'dict[str, Any]':
        pass

    def validate(self, job: 'AutomationJob') -> 'None':
        pass

    def _admission_blocker(self) -> 'dict[str, Any] | None':
        pass

    def start(self, job: 'AutomationJob', *, on_internal_run_created: 'Callable[[str], None]') -> 'str':
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

    def _automation_config(self, job: 'AutomationJob') -> 'dict[str, Any]':
        pass

    @staticmethod
    def _master_input(value: 'Mapping[str, Any]') -> 'tuple[str, str, str]':
        pass

    def _find_row(self, internal_run_id: 'str') -> 'dict[str, Any] | None':
        pass

    def _artifacts_from_row(self, row: 'Mapping[str, Any]') -> 'tuple[ArtifactCandidate, ...]':
        pass


# --- Top-Level Functions ---
def _text(value: 'Any') -> 'str':
    pass
