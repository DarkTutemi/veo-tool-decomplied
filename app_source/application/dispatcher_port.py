"""
Decompiled / Reconstructed Module: application.dispatcher_port
Source PyC: dispatcher_port.pyc

Docstring:
Dispatcher port boundary for headless job execution.

Routers and application services must depend on this interface, not directly on
the legacy SmartJobDispatcher. A production implementation can wrap a fully
headless dispatcher once Qt dependencies are removed from the execution path.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
List = typing.List
_dispatcher_port = <application.dispatcher_port.UnavailableDispatcherPort object at 0x00000264D4035D30>

# --- Class: SubmitJobsCommand ---
class SubmitJobsCommand:
    """SubmitJobsCommand(feature: 'str', cards: 'List[Dict[str, Any]]', config: 'Dict[str, Any]' = <factory>)"""
    def __init__(self, feature: 'str', cards: 'List[Dict[str, Any]]', config: 'Dict[str, Any]' = <factory>) -> None:
        pass

    def __repr__(self):
        pass


# --- Class: SubmitJobsResult ---
class SubmitJobsResult:
    """SubmitJobsResult(job_ids: 'List[str]' = <factory>, error: 'str | None' = None)"""
    error = None

    def __init__(self, job_ids: 'List[str]' = <factory>, error: 'str | None' = None) -> None:
        pass

    def __repr__(self):
        pass


# --- Class: DispatcherPort ---
class DispatcherPort(Protocol):
    _is_protocol = True
    _abc_impl = <_abc._abc_data object at 0x00000264D40814C0>

    def submit_jobs(self, command: 'SubmitJobsCommand') -> 'SubmitJobsResult':
        pass

    def cancel_job(self, job_id: 'str') -> 'bool':
        pass

    def __init__(self, *args, **kwargs):
        pass


# --- Class: UnavailableDispatcherPort ---
class UnavailableDispatcherPort:
    """Explicit placeholder until SmartJobDispatcher is split from Qt."""
    error = 'dispatcher_port_not_implemented'

    def submit_jobs(self, command: 'SubmitJobsCommand') -> 'SubmitJobsResult':
        pass

    def cancel_job(self, job_id: 'str') -> 'bool':
        pass


# --- Top-Level Functions ---
def get_dispatcher_port() -> 'DispatcherPort':
    pass

def set_dispatcher_port(port: 'DispatcherPort') -> 'None':
    pass

def install_headless_dispatcher() -> 'DispatcherPort':
    pass
