"""
Decompiled / Reconstructed Module: core.prompt_queue_service
Source PyC: prompt_queue_service.pyc

Docstring:
Thread-safe prompt queue store.

This module owns only queue persistence and state. Route services build their
own prompt/config metadata before entering this boundary.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
Iterable = typing.Iterable
List = typing.List
Optional = typing.Optional
_service_instance = None

# --- Class: BatchStatus ---
class BatchStatus(Enum):
    _use_args_ = False
    _member_names_ = ['PENDING', 'RUNNING', 'COMPLETE', 'FAILED']
    _member_map_ = {'PENDING': <BatchStatus.PENDING: 'pending'>, 'RUNNING': <BatchStatus.RUNNING: 'running'>, 'COMPLETE': <BatchStatus.COMP...
    _value2member_map_ = {'pending': <BatchStatus.PENDING: 'pending'>, 'running': <BatchStatus.RUNNING: 'running'>, 'complete': <BatchStatus.COMP...
    _unhashable_values_ = []
    _value_repr_ = None
    PENDING = <BatchStatus.PENDING: 'pending'>
    RUNNING = <BatchStatus.RUNNING: 'running'>
    COMPLETE = <BatchStatus.COMPLETE: 'complete'>
    FAILED = <BatchStatus.FAILED: 'failed'>

    @staticmethod
    def _generate_next_value_(name, start, count, last_values):
        """Generate the next value when not given.

        name: the name of the member
        start: the initial start value or None
        count: the number of existing members
        last_values: the list of values assigned"""
        pass

    def _new_member_(*args, **kwargs):
        """Create and return a new object.  See help(type) for accurate signature."""
        pass

    def _member_type_():
        """The base class of the class hierarchy.

When called, it accepts no arguments and returns a new featureless
instance that has no instance attributes and cannot be given any."""
        pass


# --- Class: QueueBatchItem ---
class QueueBatchItem:
    """QueueBatchItem(prompt: 'str', card_type: 'str', chain_index: 'int' = 0, position_in_chain: 'int' = 0, start_type: 'str' = 'text', start_images: 'Any' = None, payload: 'Dict[str, Any]' = <factory>)"""
    chain_index = 0
    position_in_chain = 0
    start_type = 'text'
    start_images = None

    def __init__(self, prompt: 'str', card_type: 'str', chain_index: 'int' = 0, position_in_chain: 'int' = 0, start_type: 'str' = 'text', start_images: 'Any' = None, payload: 'Dict[str, Any]' = <factory>) -> None:
        pass

    def __repr__(self):
        pass


# --- Class: QueueBatch ---
class QueueBatch:
    """QueueBatch(batch_id: 'str', prompts: 'List[QueueBatchItem]', status: 'BatchStatus' = <BatchStatus.PENDING: 'pending'>, created_at: 'str' = '', name: 'str' = '', meta: 'Dict[str, Any]' = <factory>)"""
    status = <BatchStatus.PENDING: 'pending'>
    created_at = ''
    name = ''

    def to_dict(self) -> 'dict':
        pass

    def to_persisted_dict(self) -> 'dict':
        pass

    @classmethod
    def from_dict(cls, data: 'dict') -> "'QueueBatch'":
        pass

    def __init__(self, batch_id: 'str', prompts: 'List[QueueBatchItem]', status: 'BatchStatus' = <BatchStatus.PENDING: 'pending'>, created_at: 'str' = '', name: 'str' = '', meta: 'Dict[str, Any]' = <factory>) -> None:
        pass

    def __repr__(self):
        pass


# --- Class: PromptQueueService ---
class PromptQueueService:
    """Queue batches per session with one canonical bulk enqueue primitive."""
    _instance = None
    TEMP_FILE = 'C:\\Users\\vutru\\AppData\\Local\\Temp\\veo3_prompt_queue.json'

    def __init__(self) -> 'None':
        pass

    def add_batch(self, session_key: 'str', prompts: 'List[Any]', name: 'str' = '', meta: 'Optional[Dict[str, Any]]' = None) -> 'str':
        pass

    def add_batches(self, batches: 'List[Dict[str, Any]]') -> 'Dict[str, Any]':
        pass

    def _coerce_queue_prompts(self, prompts: 'Any') -> 'List[QueueBatchItem]':
        pass

    def get_next_batch(self, session_key: 'str') -> 'Optional[QueueBatch]':
        pass

    def get_queue(self, session_key: 'str') -> 'List[QueueBatch]':
        pass

    def get_pending_count(self, session_key: 'str') -> 'int':
        pass

    def get_total_count(self, session_key: 'str') -> 'int':
        pass

    def update_batch_meta(self, session_key: 'str', batch_id: 'str', patch: 'Dict[str, Any]') -> 'bool':
        pass

    def has_pending(self, session_key: 'str') -> 'bool':
        pass

    def mark_running(self, session_key: 'str', batch_id: 'str') -> 'None':
        pass

    def claim_pending(self, session_key: 'str', batch_id: 'str') -> 'Dict[str, Any]':
        """Atomically claim exactly one pending row for a route worker.

        Route services previously implemented ``get pending`` followed by
        ``mark_running`` as two separate operations.  Two in-process callers
        could therefore both observe an idle route and the second call would
        overwrite ``_current_batch``.  Automation Center needs a target-row
        seam, so the ownership check and transition live under the shared
        queue lock."""
        pass

    def release_claim(self, session_key: 'str', batch_id: 'str') -> 'bool':
        pass

    def mark_complete(self, session_key: 'str', batch_id: 'str' = None) -> 'None':
        pass

    def mark_failed(self, session_key: 'str', batch_id: 'str' = None) -> 'None':
        pass

    def get_batch(self, session_key: 'str', batch_id: 'str') -> 'Optional[QueueBatch]':
        pass

    def update_batch(self, session_key: 'str', batch_id: 'str', prompts: 'List[Any]', name: 'str' = None, meta: 'Optional[Dict[str, Any]]' = None) -> 'bool':
        pass

    def remove_batch(self, session_key: 'str', batch_id: 'str') -> 'bool':
        pass

    def clear_queue(self, session_key: 'str') -> 'None':
        pass

    def clear_completed(self, session_key: 'str') -> 'None':
        pass

    def retain_sessions_for_startup(self, session_keys: 'Iterable[str]', automation_shared_sessions: 'Iterable[str]' = ()) -> 'Dict[str, int]':
        """Clear transient UI queues while retaining durable module sessions.

        A row that was RUNNING in the previous process is never made silently
        runnable again. Automation-owned RUNNING and COMPLETE rows receive a
        reconciliation marker because COMPLETE only proves scene dispatch, not
        that postproduction produced a durable artifact. Pending rows that had
        never started remain eligible for normal startup."""
        pass

    def get_current_batch(self, session_key: 'str') -> 'Optional[QueueBatch]':
        pass

    def is_running(self, session_key: 'str') -> 'bool':
        pass

    def on_queue_changed(self, callback: 'callable') -> 'None':
        pass

    def remove_callback(self, callback: 'callable') -> 'None':
        pass

    def _notify_queue_changed(self, session_key: 'str') -> 'None':
        pass

    def _save_to_temp(self) -> 'None':
        pass

    def _load_from_temp(self) -> 'None':
        pass

    @staticmethod
    def _prepare_batch_for_restart(batch: 'QueueBatch') -> 'None':
        pass

    def _find_batch(self, session_key: 'str', batch_id: 'str') -> 'Optional[QueueBatch]':
        pass


# --- Top-Level Functions ---
def _verbose_runtime_logs() -> 'bool':
    pass

def get_prompt_queue_service() -> 'PromptQueueService':
    pass
