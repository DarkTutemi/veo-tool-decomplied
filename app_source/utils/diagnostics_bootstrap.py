"""
Decompiled / Reconstructed Module: utils.diagnostics_bootstrap

Docstring:
Single diagnostics bootstrap — the app-wide STANDARD for arming crash capture.

Call ``install_diagnostics()`` as one of the first things in every process entrypoint
(``main.py`` and any future standalone worker). It installs, in a fixed order and
idempotently, the layers that together guarantee we always know *what* crashed and
*what led to it*:

  1. faulthandler        — faulting-thread Python stack on a C-level fatal signal
                           (already enabled in main.py before imports; we just confirm
                           it's on). On Windows the minidump supplies all-thread stacks;
                           walking every Python thread inside SEH is unsafe during
                           concurrent thread creation.
  2. native minidump     — SEH filter → ``.dmp`` for a C++ access violation inside Qt
                           (the one class the Python excepthook can NEVER catch), with
                           the breadcrumb ring flushed beside it.
  3. CrashLogger         — sys.excepthook + threading.excepthook + qInstallMessageHandler
                           (Python / worker-thread / QML-fatal), each report carrying the
                           breadcrumb snapshot.

The breadcrumb ring (``utils.crash_breadcrumbs``) is the correlation layer: drop() at
chokepoints (route change, model reset/apply, feed flush, dispatch submit) costs nothing
until a crash flushes it.

NOTE: the forensic session logger (``utils.forensic_logger``) keeps its own existing
startup — it is intentionally not (re)started here, because ``get_forensic_logger()``
constructs a fresh logger each call (a second heartbeat thread).
"""

from __future__ import annotations
import sys, os, typing
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
_installed = False

# --- Top-Level Functions ---
def _prune_old_breadcrumb_logs(crumb_dir, keep: 'int' = 20) -> 'None':
    # [PyArmor BCC constants]: 'sorted', 'glob', 'breadcrumbs_live_*.jsonl', 'key', 'reverse', True, 'unlink', 'Exception'
    pass

def install_diagnostics() -> 'dict':
    # [PyArmor BCC constants]: 'faulthandler', False, 'minidump', 'crash_logger', '_installed', 'is_enabled', 'enable', 'all_threads', 'platform', 'win32', 'Exception', 'install_minidump_handler', 'get_crash_logger', True, 'drop'
    pass
