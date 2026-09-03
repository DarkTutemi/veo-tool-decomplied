"""
Decompiled / Reconstructed Module: application.job_submission_gateway
Source PyC: job_submission_gateway.pyc

Docstring:
Central job submission gateway.

Controllers and feature services should enter job creation here after they have
built route-specific prompt/config data. The gateway owns enqueue/start policy
coordination; the queue store owns persistence.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Callable = typing.Callable
Dict = typing.Dict
Iterable = typing.Iterable
List = typing.List
_gateway_instance = None

# --- Class: QueueJobSpec ---
class QueueJobSpec:
    """Backend job contract shared by every route before queue persistence."""
    name = ''
    route = ''
    feature = ''
    batch_id = ''

    def to_queue_spec(self) -> 'Dict[str, Any]':
        pass

    def __init__(self, session_key: 'str', prompts: 'List[Any]', name: 'str' = '', meta: 'Dict[str, Any]' = <factory>, route: 'str' = '', feature: 'str' = '', batch_id: 'str' = '') -> None:
        pass

    def __repr__(self):
        pass


# --- Class: JobSubmissionGateway ---
class JobSubmissionGateway:
    """Single backend entry for enqueueing route-created jobs."""
    def __init__(self) -> 'None':
        pass

    def enqueue_prompt_batches(self, specs: 'Iterable[QueueJobSpec | Dict[str, Any]]', *, source: 'str' = '') -> 'Dict[str, Any]':
        pass

    def submit_batch_image_rows(self, rows: 'Iterable[Dict[str, Any]]', *, start: 'bool' = False, start_config: 'Dict[str, Any] | None' = None, source: 'str' = '') -> 'Dict[str, Any]':
        pass

    def generate_image_and_wait(self, *, prompt: 'str', account_key: 'str', image_inputs: 'Iterable[Dict[str, Any]] | None' = None, model: 'str' = '', aspect_ratio: 'str' = 'IMAGE_ASPECT_RATIO_LANDSCAPE', output_folder: 'str' = '', filename_stem: 'str' = '', route: 'str' = '', parent_job_id: 'str' = '', timeout_seconds: 'float' = 900.0, status_callback: 'Callable[[Dict[str, Any]], None] | None' = None, source: 'str' = '') -> 'Dict[str, Any]':
        pass

    def generate_images_and_wait(self, *, prompt: 'str', account_key: 'str', image_inputs: 'Iterable[Dict[str, Any]] | None' = None, output_count: 'int' = 1, model: 'str' = '', aspect_ratio: 'str' = 'IMAGE_ASPECT_RATIO_LANDSCAPE', output_folder: 'str' = '', filename_stem: 'str' = '', route: 'str' = '', parent_job_id: 'str' = '', timeout_seconds: 'float' = 900.0, status_callback: 'Callable[[Dict[str, Any]], None] | None' = None, source: 'str' = '') -> 'Dict[str, Any]':
        pass

    def dispatch_scene_prompts(self, *, feature: 'str', prompts: 'Iterable[Dict[str, Any]]', config: 'Dict[str, Any] | None' = None, route: 'str' = '', tab_source: 'str' = '', source: 'str' = '', reset_stats: 'bool' = False, direct: 'bool' = False) -> 'Dict[str, Any]':
        pass

    def submit_command(self, command: 'SubmitJobsCommand', *, source: 'str' = '') -> 'SubmitJobsResult':
        pass

    def _submit_via_port(self, command: 'SubmitJobsCommand') -> 'SubmitJobsResult':
        pass

    @staticmethod
    def _route_blocker(route: 'str', *, action: 'str') -> 'Dict[str, Any] | None':
        pass

    @classmethod
    def _command_blocker(cls, command: 'SubmitJobsCommand') -> 'Dict[str, Any] | None':
        pass

    @staticmethod
    def _materialize_blob_refs(command: 'SubmitJobsCommand') -> 'SubmitJobsCommand':
        pass

    def precreate_scene_placeholders(self, *, feature: 'str', prompts: 'Iterable[Dict[str, Any]]', config: 'Dict[str, Any] | None' = None, route: 'str' = '', tab_source: 'str' = '', source: 'str' = '') -> 'List[str]':
        pass

    @staticmethod
    def _ensure_batch_run_id(cfg: 'Dict[str, Any]', prompts: 'List[Dict[str, Any]]') -> 'str':
        """Pin the ONE canonical history run id for a batch BEFORE any writer runs.

        Priority: an explicit ``history_run_id`` already in config → the batch
        parent id resolved from the first prompt (clone/master/transcript job id).
        Stamps it into ``cfg`` and every prompt so placeholders, the submit seed,
        per-scene terminal patches, asset capture, and the read path all resolve to
        the SAME run — no divergence, no ghost, no orphaned scene assets. Returns
        the run id ('' when there is no parent id to adopt, e.g. a plain job)."""
        pass

    def _normalize_scene_prompts(self, prompts: 'List[Dict[str, Any]]', *, route: 'str', tab_source: 'str') -> 'None':
        pass

    def _precreate_scene_placeholders(self, *, feature: 'str', prompts: 'List[Dict[str, Any]]', config: 'Dict[str, Any]', route: 'str', tab_source: 'str', source: 'str') -> 'List[str]':
        pass

    def _mark_scene_placeholders_failed(self, job_ids: 'List[str]', error: 'str') -> 'None':
        pass

    def _scene_job_id(self, prompt: 'Dict[str, Any]') -> 'str':
        pass

    def _scene_tab_source(self, prompt: 'Dict[str, Any]', *, route: 'str', tab_source: 'str') -> 'str':
        pass

    def _scene_job_feature(self, prompt: 'Dict[str, Any]', feature: 'str') -> 'JobFeature':
        pass


# --- Top-Level Functions ---
def get_job_submission_gateway() -> 'JobSubmissionGateway':
    pass
