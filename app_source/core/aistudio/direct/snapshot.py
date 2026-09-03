"""
Decompiled / Reconstructed Module: core.aistudio.direct.snapshot
Source PyC: snapshot.pyc

Docstring:
core/aistudio/direct/snapshot.py — BotGuard snapshot service management.

Injects a hook that (1) signature-locates the snapshot function on
window.default_MakerSuite (key varies per build — never hardcode), (2) captures
the botguard "service" object so we can mint fresh snapshots for OUR content, and
(3) hooks XHR/fetch for streaming body-swap. All JS verified live 2026-07-09.

Operates on a synchronous Playwright page (as provided by veoflow's browser
manager via run_page_action).
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Optional = typing.Optional
_log = <Logger aistudio.direct.snapshot (WARNING)>
INSTALL_HOOKS_JS = "\n(() => {\n    const dms = window.default_MakerSuite;\n    if (!dms) return 'no_default_MakerSuite';\n\n    // 1. Signature-match the snapshot function (key changes per build).\n    let snapKey = wi... [truncated]
READY_JS = "(() => !!(window.default_MakerSuite && document.querySelector('textarea')))()"
HAS_SERVICE_JS = "(() => typeof window.__bg_service === 'object' && window.__bg_service !== null)()"

# --- Class: SnapshotService ---
class SnapshotService:
    """Manages the in-page botguard service on a warm page.

    Lifecycle: install_hooks() -> ensure_service() (triggers one dummy gen to
    capture the service if absent). Once ready, mint_token()/gateway can run."""
    snap_key = <property object at 0x00000264D9D319E0>
    request_url = <property object at 0x00000264DA087330>
    header_template = <property object at 0x00000264DA0B15D0>
    _KEEP_HEADERS = ('x-goog-ext-519733851-bin', 'x-aistudio-visit-id', 'x-aistudio-g1-tier', 'x-goog-api-key', 'x-user-agent', 'x-goog-auth...

    def __init__(self, page, *, dummy_prompt: 'str' = 'hi'):
        pass

    def install_hooks(self) -> 'str':
        pass

    def has_service(self) -> 'bool':
        pass

    def ensure_service(self, timeout_ms: 'int' = 30000) -> 'bool':
        pass

    def _fill_and_run(self, prompt: 'str') -> 'None':
        pass

    def _extract_headers(self, request) -> 'dict[str, str]':
        pass

