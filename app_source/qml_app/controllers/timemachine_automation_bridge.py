"""
Decompiled / Reconstructed Module: qml_app.controllers.timemachine_automation_bridge

Docstring:
Qt-safe consumer for the durable Automation Center Time Machine inbox.
"""

from __future__ import annotations
import sys, os, typing
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['TimeMachineAutomationControllerBridge']

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
__all__ = ['TimeMachineAutomationControllerBridge']

# --- Class: Inflight ---
class Inflight:
    """A 1-slot coalescing guard: refuses a new run while one is pending."""
    _busy = <member '_busy' of 'Inflight' objects>

    def __init__(self) -> 'None':
        pass

    def begin(self) -> 'bool':
        pass

    def done(self) -> 'None':
        pass


# --- Class: TimeMachineAutomationControllerBridge ---
class TimeMachineAutomationControllerBridge(QObject):
    """
    Claim on a worker, then apply the detached request on the GUI thread.
    
        The process-local producer receives only ``_push.emit``.  It never receives
        the controller callback and cannot call or mutate the controller QObject.
        Every SQLite operation runs through ``run_off_thread``.
    """
    staticMetaObject = PySide6.QtCore.QMetaObject("TimeMachineAutomationControllerBridge" inherits "QObject":
Methods:
  #4 type=Signal, signat...

    _push = Signal()
    _claimDone = Signal()
    _handoffDone = Signal()
    _projectionDone = Signal()
    projectionCommitted = Signal()
    def __init__(self, *, database_path: 'str | Path', accept_request: 'Callable[[dict[str, Any]], Mapping[str, Any]]', parent: 'QObject | None' = None) -> 'None':
        pass

    @property
    def consumer_token(self):
        pass

    def shutdown(self) -> 'None':
        # [PyArmor BCC constants]: '_closed', True, 'unregister_timemachine_consumer', '_database_path', '_consumer_token', '_pending_projection'
        pass

    def project(self, rows: 'Sequence[Mapping[str, Any]]') -> 'None':
        # [PyArmor BCC constants]: '_closed', 'dict', '_projection_inflight', 'begin', '_pending_projection', '_database_path', 'TimeMachineAutomationStore', 'update_projections', 'run_off_thread', '_projectionDone', 'name', 'TimeMachineAutomationProjection'
        pass

    def _schedule_claim(self) -> 'None':
        # [PyArmor BCC constants]: '_closed', '_claim_inflight', 'begin', True, '_claim_again', '_database_path', '_consumer_token', 'TimeMachineAutomationStore', 'claim_next', 'run_off_thread', '_claimDone', 'name', 'TimeMachineAutomationClaim'
        pass

    def _apply_claim(self, payload: 'Mapping[str, Any]') -> 'None':
        # [PyArmor BCC constants]: '_claim_inflight', 'done', '_closed', 'bool', 'get', 'ok', 'data', 'isinstance', 'Mapping', '_claim_again', False, '_schedule_claim', 'dict', 'str', 'target_run_id'
        pass

    def _write_handoff_result(self, target: 'str', accepted: 'Mapping[str, Any]') -> 'None':
        # [PyArmor BCC constants]: '_handoff_inflight', 'begin', True, '_claim_again', '_database_path', 'dict', 'TimeMachineAutomationStore', 'bool', 'get', 'ok', 'acknowledge', 'reject', 'str', 'code', 'TIMEMACHINE_HANDOFF_REJECTED'
        pass

    def _apply_handoff_result(self, payload: 'Mapping[str, Any]') -> 'None':
        # [PyArmor BCC constants]: '_handoff_inflight', 'done', '_closed', False, '_claim_again', '_schedule_claim'
        pass

    def _apply_projection_result(self, payload: 'Mapping[str, Any]') -> 'None':
        # [PyArmor BCC constants]: '_projection_inflight', 'done', '_closed', 'bool', 'get', 'ok', 'max', 0, 'int', 'data', 'TypeError', 'ValueError', 'projectionCommitted', 'emit', '_pending_projection'
        pass

