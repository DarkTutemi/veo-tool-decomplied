"""
Decompiled / Reconstructed Module: core.captcha.chrome_worker
Source PyC: chrome_worker.pyc

Docstring:
Chrome farm engine — REAL Google Chrome (channel=chrome) in NEW headless mode.

Sole farm engine. This engine only owns
launch / cookies / navigate / evaluate — the JIT-cookie inject + build_api_js +
reCAPTCHA + **fetch payload** + sync-back flow is reused UNCHANGED from BrowserWorkerBase.

Chrome runs in **new headless** (``--headless=new``): the real full browser (real
GPU/WebGL, full feature set), just no window — so we need NO virtual
desktop / off-screen window-hider at all. The UA is overridden to drop the
"HeadlessChrome" token. reCAPTCHA Enterprise scores (not a hard CDP block); real
Chrome + new headless (GPU) + clean IP can clear the threshold.

Why this might pass despite CDP: reCAPTCHA Enterprise SCORES many signals; real
Chrome (NOT bundled Chromium — channel=chrome) with hardware WebGL + a clean IP +
the page's natural grecaptcha flow can pass even with the CDP transport present.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['ChromeBrowserInstance']

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Optional = typing.Optional
LANDING_URL = 'https://labs.google/fx/tools/flow'
TIMEOUT_PAGE_LOAD = 45000
_VISIBILITY_SCRIPT = "\n(() => {\n  try {\n    Object.defineProperty(document, 'visibilityState', { get: () => 'visible', configurable: true });\n    Object.defineProperty(document, 'hidden', { get: () => false, configura... [truncated]
_HOVER_TARGETS_JS = '() => {\n  const W = innerWidth, H = innerHeight, out = [], seen = new Set();\n  const sel = \'textarea,[contenteditable="true"],button,[role="button"],input:not([type=hidden]),a[href],[role="tab"],[... [truncated]
_PROMPT_FIELD_JS = '() => {\n  const cands = document.querySelectorAll(\'textarea,[contenteditable="true"],[role="textbox"]\');\n  let best = null, bestArea = 0;\n  for (const el of cands) {\n    const r = el.getBoundin... [truncated]
_SAMESITE_MAP = {'no_restriction': 'None', 'none': 'None', 'lax': 'Lax', 'unspecified': 'Lax', '': 'Lax', 'strict': 'Strict'}
__all__ = ['ChromeBrowserInstance']

# --- Class: ChromeBrowserInstance ---
class ChromeBrowserInstance(BrowserWorkerBase):
    """BrowserWorkerBase adapter backed by real Google Chrome (channel=chrome), new headless."""
    engine_name = 'chrome'
    _abc_impl = <_abc._abc_data object at 0x00000264DA5D6780>

    def __init__(self, instance_id: 'int', account: 'dict', headless='new'):
        pass

    def _tz_locale(self) -> 'tuple[str, str]':
        pass

    def _map_proxy(self) -> 'Optional[dict]':
        pass

    def initialize(self) -> 'bool':
        pass

    def _install_context_media_throttle(self) -> 'dict':
        pass

    def _behavioral_warmup_on(self) -> 'bool':
        pass

    def _type_prompt_on(self) -> 'bool':
        pass

    def _find_safe_click_point(self):
        """A page point safe to click — one whose elementFromPoint (and ancestor chain) is
        NOT interactive — so the gesture generates pointerdown/up + sets userActivation
        WITHOUT triggering a UI action / navigation. Scans a grid of edge/margin points
        (content is usually centered, edges empty) and returns the first non-interactive
        hit. Empty space (null elementFromPoint) is safest of all."""
        pass

    def _viewport_wh(self) -> 'tuple':
        """Best-effort inner viewport size (CDP-connected pages report viewport_size=None,
        so fall back to a live window.inner* read, then a sane default)."""
        pass

    def _organic_move_to(self, x: 'float', y: 'float', *, duration: 'float | None' = None) -> 'None':
        """Move the cursor to (x,y) along a curved Bézier with ease-in/out velocity +
        micro-tremor (human_motion.curved_path), one CDP move per waypoint → isTrusted
        pointermove stream with real curvature/velocity/jitter (not a straight line)."""
        pass

    def _tap_shift(self) -> 'None':
        """A single Shift keydown/keyup with human dwell — safe (no side effect), feeds
        the keydown/keyup cadence signal."""
        pass

    def _type_prompt_like_human(self) -> 'bool':
        """Focus the REAL prompt box and type a short phrase char-by-char with human
        inter-key cadence, then clear it. This is the high-value behavioral signal a
        manual pass supplies (real text-input keystrokes on the actual editable field,
        varying dwell/flight + occasional think-pause) which the tool's raw API submit
        otherwise never produces. NON-DESTRUCTIVE: the text is cleared afterwards and the
        submit button is NEVER clicked — the tool still submits via its own API path.
        Returns True if it typed. Falls back (caller uses Shift taps) when no field mounts."""
        pass

    def _type_burst_into_prompt(self, n_min: 'int' = 3, n_max: 'int' = 6) -> 'bool':
        """A SHORT fresh keystroke burst into the real prompt box (a few chars, human
        cadence, then cleared) — used right before execute() so EVERY token mint carries
        live typing telemetry, not just the one-time warmup. Cheap (~0.4-1s). Non-
        destructive (cleared, never submits). Returns True if typed."""
        pass

    def _behavior_targets(self, vw: 'float', vh: 'float') -> 'list':
        """2–4 PURPOSEFUL hover targets — real visible controls (prompt box, buttons, tabs)
        with a small aim offset (humans don't hit dead-center) — so the pointer path
        correlates with the page's interactive elements like a user surveying the app.
        Targets are chosen fresh/random each run (behavior must NOT be seeded — a repeated
        trajectory is itself a bot tell, unlike the stable device fingerprint). Falls back
        to content-region points when the DOM exposes no controls yet."""
        pass

    def _human_warmup_activity(self) -> 'None':
        """Organic behavioral seed after page load: curved (Bézier) pointer traversals
        with ease-in/out velocity + micro-tremor + variable dwell, a scroll, a safe click
        (userActivation), a few keystrokes — then a low-rate keep-alive ticker so the
        pointer stream is still ALIVE at execute() time. All isTrusted via CDP Input.
        This is the headed↔headless lever: static fingerprint is byte-identical between
        modes (A/B verified), so behavioral entropy is what a visible window's real cursor
        supplied for free and headless must synthesize. See human_motion.py."""
        pass

    def _start_behavior_ticker(self) -> 'None':
        pass

    def _behavior_keepalive_ticker(self) -> 'None':
        """Low-rate idle micro-motion (tiny drift, NO clicks) every ~0.6–2.2s so the
        behavioral collector never reads a dead pointer window at execute() time. Confined
        to a few px around the tracked cursor → cannot disturb page interactions."""
        pass

    def _run_pre_captcha_cover(self, action: 'str', reason: 'str') -> 'None':
        """Fresh organic touch right before execute(): one curved pointer move + a Shift
        tap so the behavioral stream is live at token-mint. Throttled to ~1 interaction /
        1.5s (this hook fires 2-3× per call: api_call + get_tokens + retries); the
        keep-alive ticker fills the gaps."""
        pass

    def _normalize_samesite(self, cookies: 'list') -> 'list':
        pass

    def _add_cookies(self, cookies: 'list') -> 'None':
        pass

    def _export_cookies(self) -> 'list':
        """Cookies session để sync về DB — chỉ domain Google (giống Firefox engine)."""
        pass

    def _navigate(self, url: 'str', referer: 'str' = None) -> 'None':
        pass

    def _evaluate_js(self, js: 'str', timeout_ms: 'int' = 10000) -> 'Optional[dict]':
        pass

    def _get_current_url(self) -> 'str':
        pass

    def _log_egress_ip(self) -> 'None':
        pass

    def _return_to_idle_without_cookies(self) -> 'None':
        pass

    def close(self) -> 'None':
        pass


# --- Top-Level Functions ---
def _clean_chrome_ua(version: 'str') -> 'Optional[str]':
    pass
