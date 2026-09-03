"""
Decompiled / Reconstructed Module: core.captcha.browser_worker_base
Source PyC: browser_worker_base.pyc

Docstring:
Browser Worker Base — abstract base for browser workers.

Shared orchestration lives here: get_tokens, JIT cookie inject, session polling,
reCAPTCHA JS build, and rate limiting. Concrete engines only override the
engine-specific abstract methods.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
Optional = typing.Optional
RECAPTCHA_ACTION = 'VIDEO_GENERATION'
_log = <Logger browser_worker (WARNING)>

# --- Class: BrowserWorkerBase ---
class BrowserWorkerBase(ABC):
    """Abstract base: common orchestration, engine-specific abstract methods."""
    _abc_impl = <_abc._abc_data object at 0x00000264DA5B9CC0>

    def __init__(self, instance_id: int, account: dict, headless='new'):
        pass

    def _set_runtime_failure(self, category: str, error: str) -> None:
        pass

    def _clear_runtime_failure(self) -> None:
        pass

    def _readiness_failure_result(self, default_category: str = 'session_bootstrap_pending') -> dict:
        pass

    def _stop_behavior_ticker(self) -> None:
        pass

    def _install_download_blocker(self, page=None) -> dict:
        pass

    def _install_context_download_blocker(self) -> dict:
        pass

    def _install_context_resource_blocker(self) -> dict:
        """Abort heavy preview media while preserving Flow API/session requests."""
        pass

    def _install_context_media_throttle(self) -> dict:
        pass

    def _ensure_browser_resource_guards(self) -> None:
        pass

    def initialize(self) -> bool:
        pass

    def _add_cookies(self, cookies: list) -> None:
        pass

    def _navigate(self, url: str, referer: str = None) -> None:
        pass

    def _evaluate_js(self, js: str, timeout_ms: int = 10000) -> Optional[dict]:
        pass

    def _get_current_url(self) -> str:
        pass

    def close(self) -> None:
        """Best-effort base cleanup; concrete browser engines close resources."""
        pass

    def _return_to_idle_without_cookies(self) -> None:
        """Best-effort cleanup after an account-bound request.

        Engines override this to clear browser cookies and move back to the
        anonymous landing page so at most one browser keeps account cookies
        while a request is actively running."""
        pass

    def _run_blocking(self, fn, *args):
        """Run a synchronous (DB / threading.Lock-guarded) call off the asyncio
        loop thread.

        The farm runtime's event loop drives every browser's async timeouts. A
        synchronous provider/account-manager DB call (sqlite + threading.Lock)
        executed directly on this loop blocks ALL of them under contention — the
        loop freezes, no async deadline fires, and only the cross-thread submit
        watchdog (150s) can recover. Offloading to the default executor keeps the
        loop responsive so per-call timeouts work as intended."""
        pass

    def _export_cookies(self) -> list:
        """Default: no export. Engines override để đọc cookies hiện tại từ context."""
        pass

    def _export_live_session(self) -> dict:
        """Fetch token and identity from the live NextAuth session API.

        __NEXT_DATA__ chỉ set lúc page load và có thể stale. Không fallback sang
        snapshot đó: thiếu token/email từ endpoint phải được phân loại rõ."""
        pass

    def _export_access_token(self) -> str:
        """Compatibility helper backed by the identity-bearing session read."""
        pass

    def _accept_session_identity(self, observed_email: str) -> bool:
        pass

    def _sync_cookies_to_db(self) -> None:
        """Checkpoint only the worker's fresh access token.

        Farm profiles are disposable and the dedicated AI profile owns
        service-local browser state, so neither may replace the authoritative
        Google cookie jar. BrowserManager's stable login profile is the sole
        full-cookie writer."""
        pass

    def fetch_media_b64(self, url: str, timeout_ms: int = 20000) -> dict:
        """Fetch an auth-gated media URL (thumbnail) INSIDE the live page.

        Dùng cookie jar sống của chính page (credentials: 'include') thay vì
        cookie DB cache — cookie DB có thể stale/lệch → 401 trên
        media.getMediaUrlRedirect. Chỉ chạy khi browser đã warm + có session;
        KHÔNG tự inject/navigate (caller fallback sang httpx khi fail).
        Returns {success, content_type, data_url} (data_url = data:<ct>;base64,...)."""
        pass

    def fetch_json(self, url: str, payload: dict, timeout_ms: int = 30000) -> dict:
        """POST a JSON payload INSIDE the live page (credentials:'include' → the page's
        OWN cookies + UA + fingerprint + TLS). For TRPC setup calls (createEntity /
        createProject) so they match the browser session instead of httpx + DB cookie.
        No reCAPTCHA, no gen telemetry — a plain authenticated fetch.
        Returns {success, status, data}."""
        pass

    def execute_api_call(self, url: str, payload: dict, action: str = None, timeout_ms: int = 60000) -> dict:
        """JIT cookie inject → reCAPTCHA → fetch → companion requests.

        Serialize per account (tab/page not concurrency-safe). Retry once on
        browser-level error or 401/500."""
        pass

    def get_tokens(self, action: str = None, timeout_ms: int = 60000) -> dict:
        """JIT inject → wait session ready → get reCAPTCHA token + access_token.

        Returns:
            {success: True, recaptcha_token: str, access_token: str}
            hoặc {success: False, error: str, needs_reset: bool, error_category: str}"""
        pass

    def execute_flow_edit_extend(self, request: dict, timeout_ms: int = 120000) -> dict:
        pass

    def execute_flow_edit_upscale(self, request: dict, timeout_ms: int = 120000) -> dict:
        pass

    def execute_flow_create(self, request: dict, timeout_ms: int = 120000) -> dict:
        pass

    def _execute_flow_edit_ui(self, kind: str, request: dict, timeout_ms: int = 120000) -> dict:
        """Submit Flow jobs through the real UI controls."""
        pass

    def warmup(self, settle_seconds: float = 3.0) -> bool:
        """Prepare a browser for the next real API call without submitting work."""
        pass

    def _jit_cookie_inject(self) -> bool:
        """Inject cookies + navigate project page + verify session. Returns True if OK."""
        pass

    def _reinject_session_checkpoint(self, reason: str) -> bool:
        """Recover one live browser from the login owner's current checkpoint.

        The browser/profile remains alive. Only its volatile auth state is
        invalidated; ``_jit_cookie_inject`` re-reads the exact identity-bound
        checkpoint, overlays it and navigates the existing tab back to Flow."""
        pass

    def _mark_account_need_login(self, reason: str) -> None:
        """Report a consumer auth failure to the authoritative login-profile probe.

        BrowserWorkerBase instances belong to disposable Flow or dedicated AI
        runtimes.  Neither owns the stable Google login profile, so an empty
        checkpoint, a failed inject, or a rejected token here must never rewrite
        the account's global Login status. The owning caller may request a
        coalesced SessionKeeper probe; only that BrowserManager-backed probe may
        make the decision."""
        pass

    def _jit_failure_result(self) -> dict:
        pass

    def _wait_session_ready(self, timeout_ms: int = 15000) -> bool:
        """Poll the live NextAuth endpoint and reCAPTCHA independently.

        ``window.__NEXT_DATA__`` is a page-load snapshot and may stay empty or
        stale after NextAuth rotates a token.  The session endpoint is the sole
        token source used by readiness, verification and generation."""
        pass

    def _recent_session_ready(self, max_age_seconds: float = 120.0) -> bool:
        pass

    def _verify_session_alive(self) -> bool:
        """Verify access_token works via /v1/credits endpoint.

        This is only a preflight guard. A present browser token should not be
        discarded just because the lightweight credits check returns a transient
        non-401 response; the real generate call will classify 403/429/5xx."""
        pass

    @staticmethod
    def _iframe_mint_on() -> bool:
        pass

    @staticmethod
    def _fresh_load_per_token_on() -> bool:
        pass

    def _wait_dom_settled(self, timeout_ms: int = 8000) -> None:
        """Best-effort chờ DOM interactive sau navigate. _navigate dùng wait_until="commit"
        (trả về ở byte đầu tiên) — evaluate trong lúc trang còn parse/redirect chết
        "Execution context was destroyed" (log khách 213732: 258 lần, đều 2-4s sau
        api_call). DCL trên labs có thể rất chậm (>45s worst-case) nên bounded + nuốt
        timeout; readiness THẬT vẫn do _wait_session_ready quyết."""
        pass

    def _page_left_labs(self) -> str:
        """URL hiện tại nếu trang đã bị đá khỏi labs.google (session chết → SPA bounce
        sang accounts.google.com), else "". Phát hiện sớm để trả session_missing thay vì
        để evaluate nổ context-destroyed rồi churn browser mới với đúng cookies chết đó."""
        pass

    def _left_labs_failure(self, foreign_url: str) -> dict:
        pass

    def _reload_page(self) -> bool:
        """Reload project page and wait for session. Returns True if session ready.
        A full navigation re-inits reCAPTCHA → the next execute() gets a fresh, populated
        behavioral event-log, so mark this load as not-yet-minted."""
        pass

    def _log_api_failure(self, layer_event: str, result: Optional[dict], url: str = '', action: str = '') -> None:
        pass

    def _log_frontend_preflight_result(self, result: Optional[dict], url: str = '', action: str = '') -> None:
        """Emit compact diagnostics for fake Flow frontend event preflight."""
        pass

    def _log_frontend_preflight_plan(self, url: str, payload: dict, action: str = '') -> None:
        """Log the intended Flow frontend event cover before JS starts.

        This log still appears when browser evaluation later times out, which
        makes field testing easier than relying only on the JS result payload."""
        pass

    def _build_api_js(self, url: str, payload: dict, action: str, timeout_ms: int) -> str:
        pass

    def _human_warmup_activity(self) -> None:
        """No-op default. Firefox engine's stealth fingerprint carries reCAPTCHA
        score; no scripted mouse/keyboard activity needed. Engines may override."""
        pass

    def _run_pre_captcha_cover(self, action: str, reason: str) -> None:
        """No-op default. The pre-reCAPTCHA behavior cover is not needed for the
        real-Chrome engine. Engines may override."""
        pass

    def _build_get_tokens_js(self, action: str, timeout_ms: int) -> str:
        pass

    def _filter_session_cookies(self, raw_cookies: list) -> list:
        pass

    def _refresh_cookies_from_db(self) -> bool:
        pass

    def _humanized_delay(self) -> float:
        pass

    def _young_device_mult(self) -> float:
        pass


# --- Top-Level Functions ---
def _cookie_identity(cookie: dict) -> tuple[str, str, str, str]:
    pass

def _merge_cookie_jars(base: list, overlay: list) -> list:
    pass

def _select_persistent_bootstrap_cookies(profile_cookies: list, checkpoint_cookies: list, *, full_handoff: bool) -> list:
    pass
