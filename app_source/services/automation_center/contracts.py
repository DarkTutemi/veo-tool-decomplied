"""
Decompiled / Reconstructed Module: services.automation_center.contracts
Source PyC: contracts.pyc

Docstring:
Protocol-neutral contracts for Tool 1's local Automation Center runtime.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
UTC = datetime.timezone.utc
Mapping = typing.Mapping
Sequence = typing.Sequence
ASSIGNMENT_DEFINITION_VERSION = 2
DELIVERY_MODES = frozenset({'scheduled', 'after_production', 'none'})
CAPTION_MODES = frozenset({'publish_kit', 'manual'})

# --- Class: ObservedState ---
class ObservedState(StrEnum):
    _use_args_ = True
    _member_names_ = ['QUEUED', 'LEASED', 'STARTING', 'RUNNING', 'PAUSING', 'PAUSED', 'CANCELLING', 'RECONCILIATION_REQUIRED', 'SUCCEEDED', '...
    _member_map_ = {'QUEUED': <ObservedState.QUEUED: 'queued'>, 'LEASED': <ObservedState.LEASED: 'leased'>, 'STARTING': <ObservedState.STAR...
    _value2member_map_ = {'queued': <ObservedState.QUEUED: 'queued'>, 'leased': <ObservedState.LEASED: 'leased'>, 'starting': <ObservedState.STAR...
    _unhashable_values_ = []
    QUEUED = <ObservedState.QUEUED: 'queued'>
    LEASED = <ObservedState.LEASED: 'leased'>
    STARTING = <ObservedState.STARTING: 'starting'>
    RUNNING = <ObservedState.RUNNING: 'running'>
    PAUSING = <ObservedState.PAUSING: 'pausing'>
    PAUSED = <ObservedState.PAUSED: 'paused'>
    CANCELLING = <ObservedState.CANCELLING: 'cancelling'>
    RECONCILIATION_REQUIRED = <ObservedState.RECONCILIATION_REQUIRED: 'reconciliation_required'>
    SUCCEEDED = <ObservedState.SUCCEEDED: 'succeeded'>
    FAILED = <ObservedState.FAILED: 'failed'>
    CANCELLED = <ObservedState.CANCELLED: 'cancelled'>

    @staticmethod
    def _generate_next_value_(name, start, count, last_values):
        """Return the lower-cased version of the member name."""
        pass

    def _new_member_(cls, *values):
        """values must already be of type `str`"""
        pass

    def _member_type_(*args, **kwargs):
        """str(object='') -> str
str(bytes_or_buffer[, encoding[, errors]]) -> str

Create a new string object from the given object. If encoding or
errors is specified, then the object must expose a data buffer
that will be decoded using the given encoding and error handler.
Otherwise, returns the result of object.__str__() (if defined)
or repr(object).
encoding defaults to sys.getdefaultencoding().
errors defaults to 'strict'."""
        pass

    def _value_repr_(self, /):
        """Return repr(self)."""
        pass

    def __str__(self, /):
        """Return str(self)."""
        pass


# --- Class: WorkerControlError ---
class WorkerControlError(RuntimeError):
    """Machine-readable worker error that is safe to report to the coordinator."""
    def __init__(self, code: 'str', message: 'str', *, details: 'Mapping[str, Any] | None' = None) -> 'None':
        pass

    def to_dict(self) -> 'dict[str, Any]':
        pass


# --- Class: AssignmentDefinition ---
class AssignmentDefinition:
    """Immutable, canonical operator intent for one local work order.

    Only the canonical JSON string is retained by the value object.  Callers
    therefore cannot mutate a nested ``config`` or delivery target after its
    SHA-256 identity has been calculated and persisted."""
    definition_hash = <property object at 0x00000264DF4BA110>
    version = <property object at 0x00000264DF4BA160>
    source = <property object at 0x00000264DF4BA1B0>
    title = <property object at 0x00000264DF4BA200>
    production_control = <property object at 0x00000264DF4BA250>
    delivery = <property object at 0x00000264DF4BA2A0>

    @classmethod
    def from_mapping(cls, value: 'Mapping[str, Any]') -> "'AssignmentDefinition'":
        pass

    def to_dict(self) -> 'dict[str, Any]':
        pass

    def __init__(self, canonical_json: 'str') -> None:
        pass

    def __repr__(self):
        pass


# --- Class: AutomationIdentity ---
class AutomationIdentity:
    """AutomationIdentity(job_id: 'str', attempt_id: 'str', lease_id: 'str', lease_generation: 'int')"""
    def __init__(self, job_id: 'str', attempt_id: 'str', lease_id: 'str', lease_generation: 'int') -> None:
        pass

    def __repr__(self):
        pass


# --- Class: AutomationJob ---
class AutomationJob:
    """AutomationJob(identity: 'AutomationIdentity', workflow: 'str', input: 'Mapping[str, Any]', config: 'Mapping[str, Any]' = <factory>, schema_version: 'str' = '1.0', artifact_policy: 'Mapping[str, Any]' = <factory>, approval_grant: 'Mapping[str, Any]' = <factory>, trace: 'Mapping[str, Any]' = <factory>)"""
    schema_version = '1.0'

    def request_hash(self) -> 'str':
        pass

    def __init__(self, identity: 'AutomationIdentity', workflow: 'str', input: 'Mapping[str, Any]', config: 'Mapping[str, Any]' = <factory>, schema_version: 'str' = '1.0', artifact_policy: 'Mapping[str, Any]' = <factory>, approval_grant: 'Mapping[str, Any]' = <factory>, trace: 'Mapping[str, Any]' = <factory>) -> None:
        pass

    def __repr__(self):
        pass


# --- Class: ArtifactCandidate ---
class ArtifactCandidate:
    """ArtifactCandidate(kind: 'str', local_path: 'str', mime_type: 'str', size_bytes: 'int', required: 'bool' = True)"""
    required = True

    def to_dict(self) -> 'dict[str, Any]':
        pass

    @classmethod
    def from_dict(cls, value: 'Mapping[str, Any]') -> "'ArtifactCandidate'":
        pass

    def __init__(self, kind: 'str', local_path: 'str', mime_type: 'str', size_bytes: 'int', required: 'bool' = True) -> None:
        pass

    def __repr__(self):
        pass


# --- Class: WorkflowSnapshot ---
class WorkflowSnapshot:
    """WorkflowSnapshot(internal_run_id: 'str', observed_state: 'ObservedState', stage: 'str', progress: 'int', message: 'str' = '', product_ready: 'bool' = False, local_ready: 'bool' = False, artifacts: 'Sequence[ArtifactCandidate]' = <factory>, error_code: 'str' = '', error_message: 'str' = '', raw_status: 'str' = '')"""
    message = ''
    product_ready = False
    local_ready = False
    error_code = ''
    error_message = ''
    raw_status = ''

    def to_dict(self) -> 'dict[str, Any]':
        pass

    def __init__(self, internal_run_id: 'str', observed_state: 'ObservedState', stage: 'str', progress: 'int', message: 'str' = '', product_ready: 'bool' = False, local_ready: 'bool' = False, artifacts: 'Sequence[ArtifactCandidate]' = <factory>, error_code: 'str' = '', error_message: 'str' = '', raw_status: 'str' = '') -> None:
        pass

    def __repr__(self):
        pass


# --- Top-Level Functions ---
def _normalize_delivery(value: 'object') -> 'dict[str, Any]':
    pass

def _normalize_schedule_policy(value: 'object', scheduled_at_utc: 'str', timezone: 'str') -> 'dict[str, Any]':
    """Validate the versioned policy snapshot frozen into one occurrence.

    This optional object is omitted from legacy/single-occurrence definitions,
    preserving their canonical JSON and hashes.  It is present only after the
    local scheduling service has passed capacity/conflict checks."""
    pass

def _normalize_utc_timestamp(value: 'str') -> 'str':
    pass

def _required_mapping(value: 'object', code: 'str', message: 'str') -> 'dict[str, Any]':
    pass

def _json_object(value: 'object', code: 'str', message: 'str') -> 'dict[str, Any]':
    pass

def _canonical_json(value: 'object') -> 'str':
    pass
