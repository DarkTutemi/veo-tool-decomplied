"""
Decompiled / Reconstructed Module: application.queue_config_lock
Source PyC: queue_config_lock.pyc

Docstring:
Lock queued-job config at run-start.

Add-to-queue snapshots the config panel into each queue row's ``meta["config"]``.
At run-start the queue is kicked via the LIVE ``_effective_route_config(route)`` so
the only values that may legitimately come from the live config are EXECUTION
control flags (dry-run / headless gate) — never user-facing settings (model,
aspect, style, language, char mode, library policy, ...). Everything else must
stay the snapshot so editing the config panel after queueing does NOT mutate jobs
already in the queue.

Normal route already does this (normal_service._stored_job_command); this is the
shared helper so clone / batch / extend / affiliate behave identically.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
Mapping = typing.Mapping
RUN_FLAG_KEYS = ('dry_run', 'allow_headless_execution')

# --- Top-Level Functions ---
def lock_config_with_run_flags(snapshot: 'Mapping[str, Any] | None', live: 'Mapping[str, Any] | None') -> 'Dict[str, Any]':
    pass
