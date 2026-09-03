"""
Decompiled / Reconstructed Module: core.dispatch.__init__
Source PyC: __init__.pyc

Docstring:
core/dispatch — clean rewrite of the generation dispatch system.

Reference spec (read-only): managers/smart_job_dispatcher.py
Architecture: docs/superpowers/plans/2026-06-07-new-dispatch-architecture.md

Design decisions:
- JobStore is the SINGLE source of truth for job state (no fat runtime Job objects).
- core/dispatch/ is isolated; production still uses the old dispatcher until
  VEOFLOW_NEW_DISPATCH=1 enables the new orchestrator.
- Hybrid concurrency: asyncio orchestrator + asyncio.to_thread() for generation
  strategies (which call existing sync api_client). Poll uses await asyncio.sleep.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable
