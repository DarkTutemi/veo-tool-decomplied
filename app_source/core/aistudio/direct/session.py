"""
Decompiled / Reconstructed Module: core.aistudio.direct.session
Source PyC: session.pyc

Docstring:
Warm AI Studio on its dedicated persistent AI browser.

`AiStudioForkRuntime` owns one VeoFlowOS process/profile per account, separate
from BrowserFarm. AI Studio is tab A and Gemini Web is tab B in that AI context.
The runtime is async, so DirectSession exposes a synchronous surface and runs
each browser interaction on the runtime loop.

BrowserManager remains the Labs login owner, but an established dedicated AI
profile keeps its own device-bound Google SSO jar.  Labs cookies bootstrap only
a blank AI profile; explicit AI reauthentication uses this same stable profile.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Optional = typing.Optional
INSTALL_HOOKS_JS = "\n(() => {\n    const dms = window.default_MakerSuite;\n    if (!dms) return 'no_default_MakerSuite';\n\n    // 1. Signature-match the snapshot function (key changes per build).\n    let snapKey = wi... [truncated]
_MINT_AND_SEND_JS = "\n(async (args) => {\n    const dms = window.default_MakerSuite, sk = window.__snap_key, svc = window.__bg_service;\n    if (!dms || !sk || !svc) return JSON.stringify({status: 0, error: 'no_service'... [truncated]
API_KEY = 'AIzaSyDdP816MREB3SkjZO04QXbjsigfcI0GWOs'
SESSION_MEDIA_PERMISSION_WAITS = (25.0, 35.0, 45.0, 45.0)
_log = <Logger aistudio.direct.session (WARNING)>
GENERATE_URL = 'https://alkalimakersuite-pa.clients6.google.com/$rpc/google.internal.alkali.applications.makersuite.v1.MakerSuiteService/GenerateContent'
COUNT_TOKENS_URL = 'https://alkalimakersuite-pa.clients6.google.com/$rpc/google.internal.alkali.applications.makersuite.v1.MakerSuiteService/CountTokens'
_KEEP_HEADERS = ('x-goog-ext-519733851-bin', 'x-aistudio-visit-id', 'x-aistudio-g1-tier', 'x-goog-api-key', 'x-user-agent', 'x-goog-authuser')
DISMISS_ONBOARDING_JS = '\n(() => {\n    let clicked = 0;\n    const btns = Array.from(document.querySelectorAll(\'button\'));\n    // NEW-ACCOUNT "Save your chats to Google Drive?" prompt → pick the NON-saving option\n    /... [truncated]
_MEDIA_CONSENT_JS = '\n(() => {\n    let clicked = 0;\n    for (const b of document.querySelectorAll(\'button\')) {\n        const al = (b.getAttribute(\'aria-label\') || \'\').toLowerCase();\n        const tx = (b.textC... [truncated]
_DOM_CLICK_JS = '\n(sel) => { const el = document.querySelector(sel); if (!el) return false; el.click(); return true; }\n'
_ONBOARD_JS = '\n(async () => {\n    try {\n        let sapisid = \'\';\n        for (const c of document.cookie.split(\';\')) {\n            const eq = c.indexOf(\'=\'); if (eq < 0) continue;\n            const n ... [truncated]
_SET_PROMPT_JS = "\n(text) => {\n    const ta = document.querySelector('textarea');\n    if (ta) {\n        const set = Object.getOwnPropertyDescriptor(window.HTMLTextAreaElement.prototype,'value')?.set;\n        (set... [truncated]
_CLICK_RUN_JS = "\n() => {\n    const b = Array.from(document.querySelectorAll('button'))\n        .find(x => (x.textContent||'').trim().startsWith('Run') && !x.disabled);\n    if (b) b.click();\n}\n"
_HAS_SERVICE_JS = "(() => typeof window.__bg_service === 'object' && window.__bg_service !== null)()"
_RUNTIME_READY_JS = "() => !!(window.default_MakerSuite && document.querySelector('textarea'))"
_PAGE_HEALTH_JS = "\n() => {\n    let host = '';\n    let href = '';\n    try { host = String(location.hostname || ''); } catch (e) {}\n    try { href = String(location.href || ''); } catch (e) {}\n    return {\n      ... [truncated]
_FILE_READY_JS = '\n(() => {\n    const rows = document.querySelectorAll(\'.prompt-media-item-container, .multi-media-row, [class*="media-item"]\');\n    if (!rows.length) return false;\n    for (const r of rows) {\n ... [truncated]
_COUNT_TOKENS_JS = "\n(async (args) => {\n    let sapisid = '';\n    for (const c of document.cookie.split(';')) {\n        const eq = c.indexOf('='); if (eq < 0) continue;\n        const n = c.slice(0, eq).trim();\n   ... [truncated]
_VALID_SAMESITE = {'Strict', 'Lax', 'None'}
_UPLOAD_CREDS_JS = '\n(async () => {\n  try {\n    const RPC=\'https://alkalimakersuite-pa.clients6.google.com/$rpc/google.internal.alkali.applications.makersuite.v1.MakerSuiteService/\';\n    const KEY=\'AIzaSyDdP816MR... [truncated]

# --- Class: DirectSession ---
class DirectSession:
    """One account's warm page in the dedicated AI Studio fork runtime."""
    is_active = <property object at 0x00000264DA06B830>

    def __init__(self, account_name: 'str'):
        pass

    def _rt(self):
        pass

    def _fresh_cookies(self) -> 'list':
        pass

    def _resolved_account_email(self) -> 'str':
        pass

    def _fill_and_run(self, page, prompt: 'str') -> 'None':
        pass

    def _capture_service(self, page):
        """Install hooks + one dummy gen → capture __bg_service (in-page) + the
        snapKey + a real request's header template + url. Returns (snap_key,
        header_template, request_url)."""
        pass

    def _warm(self, page, cookies: 'list', account_email: 'str'):
        pass

    def _probe_page_health(self, page) -> 'bool':
        """B3 canary: live roundtrip + AI Studio URL/app/BotGuard."""
        pass

    def _refresh_model_catalog_if_stale(self, page, force=False):
        pass

    def refresh_model_catalog(self, force=False) -> 'bool':
        pass

    def ensure_ready(self) -> 'None':
        pass

    def _ensure_ready_once(self) -> 'None':
        pass

    def _handle(self, result: 'dict'):
        pass

    def _handle_audio(self, result: 'dict'):
        pass

    def _handle_images(self, result: 'dict'):
        pass

    def _generate(self, page, model, contents, gen_config, system_instruction, tools, timeout_ms):
        pass

    def _generate_audio(self, page, model, contents, gen_config, timeout_ms):
        pass

    def _generate_images(self, page, model, contents, gen_config, timeout_ms):
        pass

    def _apply_session_recovery(self, error: 'BaseException', has_media: 'bool', counters: 'dict', kind_label: 'str') -> 'bool':
        pass

    def generate(self, *, model: 'str', contents: 'list', gen_config=None, system_instruction=None, tools=None, timeout_ms: 'int' = 120000) -> 'str':
        pass

    def generate_audio(self, *, model: 'str', contents: 'list', gen_config=None, timeout_ms: 'int' = 180000) -> 'bytes':
        pass

    def generate_images(self, *, model: 'str', contents: 'list', gen_config=None, timeout_ms: 'int' = 180000) -> 'list[tuple[str, bytes]]':
        pass

    def count_tokens(self, contents, model: 'Optional[str]' = None) -> 'int':
        pass

    def _b1_drive_push(self, file_path: 'str', mime_type: 'str', display_name: 'str', token: 'str', folder) -> 'str':
        pass

    def _resolve_drive_account_meta(self) -> 'tuple[str, str, str]':
        pass

    def _mint_drive_creds(self) -> 'dict':
        pass

    def _drive_consent_error(self, *, reason: 'str' = '', body: 'str' = '') -> 'AiStudioAuthError':
        pass

    def _escalate_drive_consent_headed(self, *, email: 'str', profile: 'str', reason: 'str' = '', challenge: 'str' = '', totp_secret: 'str' = '', wait_s: 'float' = 180.0) -> 'dict':
        """Open headed interactive browser, drive consent UI, wait for mint 200."""
        pass

    def upload_file(self, file_path: 'str', mime_type: 'str', display_name: 'str') -> 'str':
        pass

    def keepalive(self) -> 'bool':
        pass

    def soft_reset(self) -> 'bool':
        """Reload the page (fresh x-aistudio-visit-id + fresh BotGuard service
        singleton) WITHOUT killing the browser — the cheap way to escape a poisoned
        session. Verified live (Playwright): after a media gen eats gRPC 7 the SAME
        page stays poisoned no matter how long it waits or how many times it re-mints
        (the token is already nonce-fresh per call, and the service is a SINGLETON —
        clearing __bg_service re-captures the SAME object). A page RELOAD yields a NEW
        visit-id + a NEW service singleton on the same browser/cookies, which is what
        clears it — a full new browser is NOT required (a new browser with the same
        cookies also worked, so the poison is page/context-level, not account-level).
        On failure it close()s so the caller can fall back to a full re-warm."""
        pass

    def close(self) -> 'None':
        pass


# --- Top-Level Functions ---
def _google_signin_surface(url: 'str') -> 'str':
    pass

def _select_expected_google_account(page, account_email: 'str', max_wait_ms: 'int' = 8000) -> 'bool':
    """Choose only the exact account represented by the authoritative DB row.

    Google can redirect a valid injected SSO jar to ``accountchooser``.  That is
    not an expired session.  Multiple accounts may be present, so never click a
    generic first row: only an exact ``data-identifier``/``data-email`` match is
    allowed.  The email is used only inside the page comparison and is never
    included in logs or exceptions."""
    pass

def _verify_expected_aistudio_account(page, account_email: 'str', max_wait_ms: 'int' = 8000) -> 'None':
    """Attest the exact signed-in AI account before any generation runs.

    A legacy profile name is lossy and cannot prove ownership.  AI Studio's
    Google-account control exposes the current email in an accessibility/data
    attribute.  Require an exact email occurrence there; arbitrary page text is
    deliberately ignored so a prompt cannot spoof profile ownership."""
    pass

def _warm_url() -> 'str':
    pass

def _dismiss_media_consent(page, *, poll: 'bool') -> 'bool':
    """Auto-accept AI Studio's first-upload copyright dialog so its modal backdrop stops
    intercepting clicks. poll=False → single shot (clear a leftover backdrop before we
    click Insert). poll=True → wait for the dialog that renders ~1s AFTER set_input_files,
    with early-exit the moment the upload is already proceeding (already-accepted account)."""
    pass

def _cdp_set_file_input(page, file_path: 'str') -> 'bool':
    """Set the file on <input class="file-input"> via raw CDP ``DOM.setFileInputFiles``,
    handing the browser the local PATH (it reads the file itself — same machine). This
    AVOIDS Playwright's ``FileChooser.set_files`` / ``set_input_files``, which read the file
    and STREAM its bytes (base64) in one big CDP message over the fork's websocket — that
    HANGS on large videos (field: ``fc.set_files(33MB)`` never returns, no "files set" log).
    A path is a tiny message, so it never stalls regardless of file size. Returns False if
    the input can't be located (caller falls back to fc.set_files)."""
    pass

def _dom_click(page, selector: 'str') -> 'bool':
    """Click an element via the DOM (dispatched straight on the node) instead of a pointer
    click. A CDK modal backdrop — the first-media copyright dialog's
    ``.dialog-backdrop-blur-overlay`` — intercepts POINTER events, so Playwright's
    ElementHandle.click times out (30s) while it is up; a DOM ``.click()`` is not hit-tested
    and still fires. Returns False when the selector matches nothing (caller falls back)."""
    pass

def _consent_result(ok: 'bool' = False, *, reason: 'str' = '', needs_user: 'bool' = False, challenge: 'str' = '') -> 'dict':
    pass

def _popup_challenge_kind(pop) -> 'str':
    """Classify Google OAuth step-up screens (totp / sms / password / consent).

    URL path wins over body text — accountchooser pages often mention "password"
    in chrome copy without being a password challenge."""
    pass

def _try_fill_totp(pop, secret: 'str') -> 'bool':
    """Fill Google Authenticator challenge when a TOTP secret is configured."""
    pass

def _drive_consent_finish_popup(pop, account_email: 'str', totp_secret: 'str' = '') -> 'dict':
    """Drive an already-open OAuth popup through chooser / TOTP / Allow."""
    pass

def _grant_drive_consent(page, account_email: 'str', totp_secret: 'str' = '') -> 'dict':
    """Grant AI Studio the Drive OAuth scope for this account (one-time, server-side).

    Returns a dict ``{ok, reason, needs_user, challenge}``. ``ok`` only means the
    OAuth UI path looked successful — callers MUST re-mint GenerateAccessToken and
    require HTTP 200 before treating Drive as granted.

    Handles accountchooser auto-approve, legacy Allow, and optional TOTP autofill
    when ``totp_secret`` is set. Step-up without a secret sets ``needs_user=True``."""
    pass

def _clear_upload_blockers(page, *, poll: 'bool') -> 'None':
    """Clear EVERY modal that can pointer-block the Insert click during an upload — the
    UI can pop TWO: the copyright 'Acknowledge' dialog AND the new-account 'Save
    conversations in Drive? / temporary chat' prompt. The old handler watched only ONE, so
    whichever it wasn't watching left a blocking backdrop and the click timed out. This
    accepts the copyright dialog (click Acknowledge — records consent), declines the
    save/temp-chat prompt, then sweeps away ANY residual ``.cdk-overlay-backdrop`` so
    nothing can intercept the pointer. Cheap no-op when no dialog is up."""
    pass

def classify_page_health(probe=None, page_closed=False) -> 'str':
    pass

def _normalize_cookies(cookies: 'list') -> 'list':
    pass

def _flatten_text(contents) -> 'str':
    pass
