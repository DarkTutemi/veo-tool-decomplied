"""
Decompiled / Reconstructed Module: core.dispatch.handlers.__init__
Source PyC: __init__.pyc

Docstring:
core/dispatch/handlers — one handler per ApiJob. No internal routing.

Each handler does exactly one thing (one API call family). Routing to the right
handler happens in registry.py keyed by ApiJob (resolved by JobClassifier at
submit time). See docs/architecture/dispatch-v2.md.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable
