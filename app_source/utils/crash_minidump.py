"""
Decompiled / Reconstructed Module: utils.crash_minidump

Docstring:
In-process Windows minidump writer — captures the C++ stack of the intermittent
Qt6Qml.dll access violation WITHOUT admin rights (unlike WER LocalDumps, which needs
elevation).

How it works: installs a top-level ``SetUnhandledExceptionFilter``. That filter is the
OS's last resort — it runs ONLY when an SEH exception (e.g. 0xC0000005) is about to
terminate the process, on the faulting thread, with a valid ``EXCEPTION_POINTERS``.
``dbghelp!MiniDumpWriteDump`` then writes a ``.dmp`` with EVERY thread's call stack.

Two things it will NOT do in this in-process self-dump context, both verified
empirically (see scratchpad mdtest_*): MiniDumpWriteDump rejects the EXCEPTION_POINTERS
with ERROR_NOACCESS(998) for every handle / ClientPointers / helper-thread / DumpType
combination, so the ``.dmp`` carries NO exception stream — a parser can't tell which of
the 100+ threads faulted. So we read the exception record OURSELVES from the OS pointers
(pure ctypes, safe under the fault) and drop the faulting thread id + fault address +
access kind into a ``<dump>.exc.json`` sidecar. That names the thread to symbolize
(``Qt6Qml.dll+0x3fa03``) and the address it touched.

CPython's ``faulthandler`` uses a *vectored* exception handler which fires earlier and
prints the faulting thread's Python stack; we add the *unhandled* filter on top, so both
fire and nothing is lost. Do NOT enable faulthandler's all-thread walk on Windows here:
when a worker thread is between thread-state creation and its first Python frame,
``_Py_DumpTracebackThreads`` can itself access-violate and hide the original exception.
The native dump already carries every thread's native stack. We return
EXCEPTION_CONTINUE_SEARCH so WER still records its AppCrash entry exactly as before —
we only add a dump.

Gated by ``VEOFLOW_MINIDUMP`` (default "1"). Windows-only; a no-op everywhere else.
"""

from __future__ import annotations
import sys, os, typing
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
_installed = False
_filter_cb = None

# --- Top-Level Functions ---
def install_minidump_handler(dump_dir: "'str | os.PathLike | None'" = None) -> 'bool':
    """
    Install the unhandled-exception minidump writer. Idempotent. Returns True if
        active. Safe to call early in startup (before the QML engine loads).
    """
    pass
