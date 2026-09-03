"""
Decompiled / Reconstructed Module: application.async_dispatch
Source PyC: async_dispatch.pyc

Docstring:
Small background wrapper for UI-facing dispatcher submissions.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Callable = typing.Callable
ResultCallback = typing.Callable[[application.dispatcher_port.SubmitJobsResult], NoneType]
ErrorCallback = typing.Callable[[BaseException], NoneType]

# --- Top-Level Functions ---
def dispatch_jobs_background(command: 'SubmitJobsCommand', *, thread_name: 'str', on_result: 'ResultCallback | None' = None, on_error: 'ErrorCallback | None' = None, install_dispatcher: 'bool' = True) -> "__assert_armored__((threading, b'\\x81\\xb1\\x93\\x07Y\\xb0\\xfa'))":
    pass
