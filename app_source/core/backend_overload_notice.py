"""
Decompiled / Reconstructed Module: core.backend_overload_notice
Source PyC: backend_overload_notice.pyc

Docstring:
Global 'Google backend overloaded — pausing, will retry' notice funnel.

When Flow's generation backend is overloaded, submitted jobs sit at
``MEDIA_GENERATION_STATUS_SCHEDULED`` and every submit hangs ~60s then 503 (which
our 60s client timeout records as ``browser_runtime_timeout`` / HTTP 408).

We do NOT switch project or rotate browsers for this (it's server-side, not our
session). The dispatcher instead pushes the affected jobs onto a long retry delay
so they wait quietly and re-fire once Google recovers — and raises this one
informational alert telling the user to wait. There is no action button; the jobs
resume on their own.

Re-fire throttling (once per overload window per account) is done by the caller
(FailureHandler), so this module keeps no latch of its own.

The emit goes through the shared InstantUpscaleManager signal hub, whose QML-side
connection is a queued cross-thread one, so this is safe to call from dispatcher
worker threads.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)

# --- Top-Level Functions ---
def notify_backend_overload(account_email: 'str' = '', account_name: 'str' = '', minutes: 'int' = 5, detail: 'str' = '') -> 'None':
    pass
