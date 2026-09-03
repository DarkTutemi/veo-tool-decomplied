"""
Decompiled / Reconstructed Module: services.shared.research.deep_research_backend
Source PyC: deep_research_backend.pyc

Docstring:
One guarded port for Deep Research execution.

The implementation remains in the protected ``deep_research`` feature pack.
Callers receive only a verified factory in frozen builds; source fallback exists
solely for development.  Network work in this module is blocking and therefore
must be invoked from an existing worker, never a QML slot.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Callable = typing.Callable
Dict = typing.Dict
Mapping = typing.Mapping
Optional = typing.Optional

# --- Class: DeepResearchBackendError ---
class DeepResearchBackendError(RuntimeError):
    """Deep Research cannot be resolved or did not produce a usable report."""
    pass


# --- Top-Level Functions ---
def resolve_deep_research_service() -> 'tuple[Optional[Any], Optional[str]]':
    pass

def resolve_deep_research_route() -> 'str':
    pass

def _status_text(status: 'Any') -> 'str':
    pass

def run_deep_research_job(query: 'str', *, language: 'str' = 'vi', account_name: 'str' = '', on_status: 'Optional[Callable[[str], None]]' = None, timeout_s: 'float' = 1800.0) -> 'Dict[str, Any]':
    pass
