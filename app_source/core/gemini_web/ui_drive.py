"""
Decompiled / Reconstructed Module: core.gemini_web.ui_drive
Source PyC: ui_drive.pyc

Docstring:
core/gemini_web/ui_drive.py — Deep Research via the REAL Gemini UI (fork Tab B).

WHY: Deep Research StreamGenerate validates the BotGuard token in inner[3]
STRICTLY (unlike plain chat, which tolerates a fake). BotGuard is minted by an
obfuscated client VM (``window.botguard`` / ``default_BardChatUi``) that resists
hooking — so we cannot hand-build a DR request with a valid token from Python
(verified 2026-07-22: byte-identical payload + fake BG → only the "creating a
plan" preamble, never the plan card).

SOLUTION: drive the page's own UI to send the plan + start requests, so the page
mints a REAL BotGuard natively. Only the plan+start gates need this; the progress
POLL (batchexecute ``hNvQHb``) is NOT BotGuard-gated, so pollers keep using the
plain ``batch_execute`` path.

All interactions are JS-based (``page.evaluate``) — verified more reliable than
Playwright locators in the headless fork (contenteditable focus + dynamic menus).
Labels matched in both Vietnamese and English.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Optional = typing.Optional
APP_URL = 'https://gemini.google.com/app'
_log = <Logger gemini_web.ui_drive (WARNING)>
_CLICK_JS = '\n(texts) => {\n  const sel = \'button,[role="menuitem"],[role="menuitemcheckbox"],[role="button"],a,[role="option"]\';\n  const els = Array.from(document.querySelectorAll(sel));\n  for (const t of t... [truncated]
_TYPE_JS = '\n(t) => {\n  const el = document.querySelector(\'div[contenteditable="true"]\') || document.querySelector(\'textarea\');\n  if (!el) return -1;\n  el.focus();\n  if (el.tagName === \'TEXTAREA\') {\n... [truncated]
_SEND_JS = "\n() => {\n  const b = Array.from(document.querySelectorAll('button')).find(x => {\n    const a = (x.getAttribute('aria-label') || '').toLowerCase();\n    return (a.includes('gửi') || a.includes('sen... [truncated]
_DR_ON_JS = '\n() => {\n  const html = document.body.innerHTML;\n  // the composer shows a "Deep Research" chip once enabled\n  return /Deep Research|Nghiên cứu sâu/.test(html)\n      && /Bạn muốn nghiên cứu|What... [truncated]
_TOOLS_LABELS = ['Nội dung tải lên và công cụ', 'công cụ', 'tools', 'Insert']
_MORE_LABELS = ['Các công cụ khác', 'More tools']
_DR_LABELS = ['Deep Research', 'Nghiên cứu sâu']
_START_LABELS = ['Bắt đầu nghiên cứu', 'Start research']
BOTGUARD_CAPTURE_JS = "\n(() => {\n  if (window.__vf_bg_hooked) return;\n  window.__vf_bg_hooked = true;\n  window.__vf_bg = window.__vf_bg || null;\n  const grab = (body) => {\n    try {\n      if (typeof body !== 'string... [truncated]

# --- Top-Level Functions ---
def _click(page, labels, *, settle_ms: 'int' = 700) -> 'Optional[str]':
    pass

def enable_deep_research(page) -> 'bool':
    """Open tools ➜ more tools ➜ Deep Research. Idempotent (skips if already on)."""
    pass

def mint_botguard(page, *, timeout_s: 'float' = 45.0) -> 'Optional[str]':
    """Make the page mint a REAL BotGuard (via a throwaway DR send) and return it.

    The capture hook (BOTGUARD_CAPTURE_JS) must already be active on the page
    (installed at warm). Drives: new chat ➜ enable DR ➜ type a minimal prompt ➜
    send ➜ read window.__vf_bg. Does NOT wait for the plan (we only need the
    outgoing request's token)."""
    pass

def drive_deep_research(page, topic: 'str', *, plan_timeout_s: 'float' = 150.0) -> 'dict':
    """Full plan+start via UI on a FRESH chat. Returns {ok, cid, url} or {error}.

    On success the research is RUNNING; caller polls status by cid (no BotGuard)."""
    pass
