"""
Decompiled / Reconstructed Module: core.aistudio.direct.__init__
Source PyC: __init__.pyc

Docstring:
core/aistudio/direct — Direct in-page RPC to AI Studio (no UI drive).

Mints a fresh BotGuard snapshot per request via window.default_MakerSuite's
snapshot function, builds the wire (protobuf-JSON positional) body, and POSTs
it straight from the logged-in page context. Verified live 2026-07-09.

See docs/AISTUDIO_DIRECT_API_DESIGN.md for the full wire spec.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['WireCodec', 'GenerationConfig', 'Part', 'Content', 'ThinkingLevel', 'MediaResolution', 'resolve_model_rules', 'SnapshotService', 'DirectGateway', 'DirectSession', 'DirectProvider', 'start_interactive_login', 'poll_interactive_login', 'cancel_interactive_login']

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
__all__ = ['WireCodec', 'GenerationConfig', 'Part', 'Content', 'ThinkingLevel', 'MediaResolution', 'resolve_model_rules', 'SnapshotService', 'DirectGateway', 'DirectSession', 'DirectProvider', 'start_interactiv... [truncated]
