"""
Decompiled / Reconstructed Module: services.shared.ai.ai_providers
Source PyC: ai_providers.pyc
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
Dict = typing.Dict
Callable = typing.Callable
List = typing.List
Optional = typing.Optional
Sequence = typing.Sequence
Tuple = typing.Tuple
_repo_root = 'H:\\veo-tool\\unpack-veotool\\VEOFLOWPROMAX.exe_extracted\\PYZ.pyz_extracted'
DEFAULT_INTELLIGENCE_TIER = 'auto'
logger = <Logger services.shared.ai.ai_providers (WARNING)>
_AI_CREDITS_LOCK = <unlocked _thread.lock object at 0x00000264E133C280>
_ai_credits_exhausted_flag = False
_ai_feature_ctx = <_thread._local object at 0x00000264E13ACEF0>
_ai_feature_scope_ctx = <_thread._local object at 0x00000264E13AE1B0>
_GATEWAY_TRANSIENT_STATUS = frozenset({504, 500, 502, 503})
_GATEWAY_MAX_5XX_RETRIES = 3
TRANSCRIBE_MAX_UPLOAD_MB = 400
TRANSCRIBE_MAX_UPLOAD_BYTES = 400000000
_MIN_TRANSCRIBE_WINDOW_S = 120.0
TRANSCRIBE_WINDOW_S = 240.0
_TRANSCRIBE_NO_THINKING = {'enable': False}
_SPEECH_SEGMENT_KINDS = frozenset({'narration', 'speech', 'dialogue'})
_MAX_SPEECH_HOLE_S = 8.0
_SPEECH_GAP_RE = re.compile('speech_gap\\((\\d+(?:\\.\\d+)?)-(\\d+(?:\\.\\d+)?)s\\)')
_MIN_GRID_SPEECH_ROWS = 12
_MIN_GRID_SPAN_S = 60.0
_INTEGER_TS_EPS = 0.02
_INTEGER_TS_MAX_RATIO = 0.8
_FRAC_BUCKET_S = 0.05
_DURATION_CLUSTER_S = 0.25
_DURATION_CLUSTER_RATIO = 0.8
TRANSCRIBE_GRID_ATTEMPTS = 4
TRANSCRIBE_SCRIPT_WORD_RATIO_MIN = 0.85
TRANSCRIBE_SCRIPT_INDEX_RATIO_MIN = 0.9
TRANSCRIBE_COMPLETENESS_ATTEMPTS = 5
_REPEAT_DUP_RATIO = 0.45
_REPEAT_RUN = 3
_REPEAT_MIN_CHARS = 36
_REPEAT_MIN_WORDS = 8
_REPEAT_MIN_NOSPACE_CHARS = 16
_REPEAT_JACCARD = 0.85
_REPEAT_HINT_LINES = 12
_REPEAT_HINT_LINE_CHARS = 180
_TRANSCRIBE_CUE_NOISE_RE = re.compile('[^\\w\\s]+')
_cached_server_provider = None
_cached_server_provider_key = None
_cached_aistudio_provider = None
_cached_aistudio_account = None
_AISTUDIO_MEDIA_BINDINGS_LOCK = <unlocked _thread.RLock object owner=0 count=0 at 0x00000264E13A5D40>
_AISTUDIO_MEDIA_OWNER_MAP = {}
_AISTUDIO_MEDIA_LOCAL_PATH_MAP = {}
_AISTUDIO_MEDIA_BINDINGS_MAX = 4096
_AISTUDIO_PREWARM_WAKE = <threading.Event at 0x264e139c740: unset>
_AISTUDIO_SECONDARY_READY = False
_aistudio_current_account = None
_AISTUDIO_QUOTA_WAIT_STAGES = (30.0, 120.0, 300.0, 900.0)
_TTS_QUOTA_WAIT_CAP = 60.0
_AISTUDIO_RPM_METHODS = frozenset({'generate_image', 'generate_tts'})
_AISTUDIO_TTS_MODELS = ('gemini-3.1-flash-tts-preview', 'gemini-2.5-flash-preview-tts', 'gemini-2.5-pro-preview-tts')
_AISTUDIO_PAIR_QUOTA_LOCK = <unlocked _thread.lock object at 0x00000264E13A5C80>
_AISTUDIO_PAIR_QUOTA_UNTIL = {}
_AISTUDIO_PAIR_QUOTA_STRIKES = {}
_AI_MODE_KEYS = ('aistudio', 'server', 'personal')
_VIOLATION_TAXONOMY = [{'key': 'prominent_person', 'keywords': ('prominent_people_filter_failed', 'prominent_people_filter', 'prominent_person_policy', 'prominent_person', 'prominent_people'), 'violation_type': 'prominent ... [truncated]

# --- Class: InsufficientCreditsError ---
class InsufficientCreditsError(RuntimeError):
    """Raised when AI credit balance is insufficient (server returns 402)."""
    def __init__(self, message: str = 'Insufficient AI credits', balance: float = 0):
        pass


# --- Class: InputTooLargeError ---
class InputTooLargeError(RuntimeError):
    """Raised when the input exceeds what the model accepts — Gemini 400 INVALID_ARGUMENT
    (video/content too long) or the gateway token gate. NON-RETRYABLE: resubmitting the
    same oversized input just wastes calls, so callers must surface it and STOP."""
    pass


# --- Class: _FeatureBoundProvider ---
class _FeatureBoundProvider:
    """Thin proxy: runs EVERY call to the wrapped provider inside
    ai_feature_scope(feature). Binding once at the point a service fetches its
    provider (get_ai_provider(..., feature=...)) attributes ALL of that service's
    AI spend — current and future calls alike — without threading a feature=
    argument through each call site. A call that passes its OWN feature= still wins
    (request layer > ambient)."""
    _feature = <member '_feature' of '_FeatureBoundProvider' objects>
    _inner = <member '_inner' of '_FeatureBoundProvider' objects>

    def __init__(self, inner, feature):
        pass


# --- Class: ProviderConfig ---
class ProviderConfig:
    """Configuration for AI provider"""
    max_retries = 3
    timeout = 800
    temperature = 0.7
    top_p = 0.95
    top_k = 40

    def __init__(self, api_key: str, model: str, max_retries: int = 3, timeout: int = 800, temperature: float = 0.7, top_p: float = 0.95, top_k: int = 40) -> None:
        pass

    def __repr__(self):
        pass


# --- Class: BaseAIProvider ---
class BaseAIProvider(ABC):
    """Abstract base class for AI providers"""
    _abc_impl = <_abc._abc_data object at 0x00000264E13B5640>

    def __init__(self, config: services.shared.ai.ai_providers.ProviderConfig):
        pass

    def _configure(self):
        pass

    def validate_api_key(self) -> Dict[str, Any]:
        pass

    def get_usage_stats(self) -> Dict[str, Any]:
        pass

    def get_provider_name(self) -> str:
        pass

    def get_model_name(self) -> str:
        pass

    def check_credits_or_raise(self):
        pass

    def generate_content(self, *args: Any, **kwargs: Any) -> Any:
        pass

    def generate_with_media(self, *args: Any, **kwargs: Any) -> Any:
        pass

    def smart_generate_with_media(self, *args: Any, **kwargs: Any) -> Any:
        pass

    def generate_json(self, *args: Any, **kwargs: Any) -> Any:
        pass

    def generate_tts(self, *args: Any, **kwargs: Any) -> Any:
        pass

    def generate_image(self, *args: Any, **kwargs: Any) -> Any:
        pass

    def upload_file_from_path(self, *args: Any, **kwargs: Any) -> Any:
        pass

    def count_tokens(self, *args: Any, **kwargs: Any) -> int:
        pass

    def transcribe_audio_windowed(self, *args: Any, **kwargs: Any) -> Any:
        pass

    def get_credit_balance(self, *args: Any, **kwargs: Any) -> Dict[str, Any]:
        return {
            'balance': 500000000,
            'available': 500000000,
            'available_balance': 500000000,
            'paid_balance': 500000000,
            'free_balance': 0,
            'total_balance': 500000000,
            'credits': 500000000,
            'reserved': 0,
        }

    def estimate_cost(self, *args: Any, **kwargs: Any) -> Dict[str, Any]:
        pass

    def submit_job(self, *args: Any, **kwargs: Any) -> Any:
        pass

    def wait_for_job(self, *args: Any, **kwargs: Any) -> Any:
        pass

    def create_interaction(self, *args: Any, **kwargs: Any) -> Any:
        pass

    def create_interaction_stream(self, *args: Any, **kwargs: Any) -> Any:
        pass

    def resume_interaction_stream(self, *args: Any, **kwargs: Any) -> Any:
        pass

    def get_interaction(self, *args: Any, **kwargs: Any) -> Any:
        pass

    def cached_context(self, *args: Any, **kwargs: Any) -> Any:
        pass


# --- Class: _AttrDict ---
class _AttrDict:
    """Lightweight wrapper: convert nested dict → attribute-accessible object.
    Compatible with getattr() usage in DeepResearchWorker._process_stream().
    Handles nested dicts and lists of dicts recursively."""
    def __init__(self, data):
        pass

    @staticmethod
    def _wrap(v):
        pass

    def __repr__(self):
        pass


# --- Class: ServerProxyProvider ---
class ServerProxyProvider(BaseAIProvider):
    """AI Provider that proxies all calls through the Go AI Proxy server.
    Runtime auth uses the opaque gateway bearer token minted by the main backend."""
    max_upload_bytes = 0
    max_video_seconds = 0
    upload_provider_label = 'API Server'
    _abc_impl = <_abc._abc_data object at 0x00000264E13A5F80>

    def __init__(self, config: services.shared.ai.ai_providers.ProviderConfig, server_url: str, license_key: str, timeout: int = 600, upload_url: str = None):
        pass

    def _store_runtime_token(self, token: str) -> bool:
        pass

    def _sync_runtime_token_from_cache(self, cached_data: Optional[Dict[str, Any]] = None) -> bool:
        pass

    def _load_credentials(self):
        pass

    def _configure(self):
        pass

    def _get_headers(self, body: str = '') -> Dict[str, str]:
        pass

    def _get_cached_license_data(self) -> Dict[str, Any]:
        pass

    def _token_expires_soon(self, expires_at: Optional[str]) -> bool:
        pass

    def _ensure_runtime_token_ready(self):
        pass

    def _refresh_token(self) -> bool:
        pass

    def _refresh_token_locked(self) -> bool:
        pass

    @staticmethod
    def _response_error_code(resp) -> str:
        pass

    def _is_recoverable_auth_response(self, resp) -> bool:
        pass

    def _recover_auth_response(self, resp, observed_epoch: int) -> bool:
        pass

    def _raise_response_error(self, resp) -> None:
        pass

    def _send_with_transient_retry(self, label: str, send):
        pass

    def _post(self, endpoint: str, payload: dict, timeout: Optional[int] = None) -> dict:
        pass

    def _get(self, endpoint: str) -> dict:
        pass

    def validate_api_key(self) -> Dict[str, Any]:
        pass

    def get_usage_stats(self) -> Dict[str, Any]:
        pass

    def _ensure_credits(self):
        pass

    def check_credits_or_raise(self):
        pass

    def _settle_credits(self):
        pass

    def _capture_credit_usage(self, data: dict):
        pass

    def get_credit_balance(self) -> Dict[str, Any]:
        return {
            'balance': 500000000,
            'available': 500000000,
            'available_balance': 500000000,
            'paid_balance': 500000000,
            'free_balance': 0,
            'total_balance': 500000000,
            'credits': 500000000,
            'reserved': 0,
        }

    def generate_image(self, prompt: str, *, aspect_ratio: str = '16:9', image_size: str = '1K', images: Optional[list] = None, file_uris: Optional[list] = None, include_text: bool = False, timeout: int = 120) -> Dict[str, Any]:
        pass

    def generate_content(self, prompt, max_output_tokens=65000, temperature=None, system_instruction=None, model=None, thinking_config=None, cache_name=None, completion_spec=None, response_mime_type=None, on_progress=None, feature=None, light=False, **kwargs) -> str:
        pass

    def _generate_content_multiturn(self, turns: list, max_output_tokens=65000, temperature=None, system_instruction=None, model=None, completion_spec=None, response_mime_type=None) -> str:
        pass

    def generate_with_media(self, prompt, parts, max_output_tokens=65000, temperature=None, model=None, response_mime_type=None, thinking_config=None, completion_spec=None, on_progress=None, feature=None, light=False) -> str:
        pass

    def smart_generate_with_media(self, prompt, parts, max_output_tokens=65000, max_parts=10, temperature=None, model=None, response_mime_type=None, thinking_config=None, completion_spec=None, on_progress=None, timeout=1800, skip_quota_tracking=False, blocks=None, feature=None, light=False, intelligence=None) -> str:
        """SmartGenerate with media: multi-turn continuation for long content.

        Uses block-based generation or continuation protocol to generate content
        across multiple turns, then merges all parts.

        Args:
            parts: list of dicts with file_uri/base64_data + mime_type
            max_parts: max continuation turns (default 10)
            intelligence: deprecated compatibility argument. Model selection is
                automatic and this value is ignored."""
        pass

    def _smart_generate_story_continuity_blocks(self, *, prompt, parts, max_output_tokens, max_parts, temperature, model, response_mime_type, thinking_config, completion_spec, on_progress, timeout, skip_quota_tracking, blocks, feature, light) -> str:
        pass

    def generate_json(self, prompt, max_output_tokens=65000, temperature=None, system_instruction=None, response_schema=None, on_progress=None, feature=None, light=False) -> dict:
        pass

    def generate_content_plan(self, template_name: str, template_desc: str) -> list:
        pass

    def generate_tts(self, text, voice_name='Kore', model='gemini-2.5-flash-preview-tts', multi_speaker_config=None, _skip_credit_hooks=False) -> bytes:
        pass

    def submit_job(self, job_type: str, payload: dict, model: str = '', light: bool = False) -> dict:
        pass

    def get_job_status(self, job_id: str) -> dict:
        pass

    def stream_job(self, job_id: str, on_progress=None) -> dict:
        pass

    def wait_for_job(self, job_id: str, on_progress=None, timeout: int = 600) -> dict:
        pass

    def cancel_job(self, job_id: str) -> bool:
        pass

    def get_queue_info(self) -> dict:
        pass

    def wait_for_job_smart_generate(self, contents, prompt, system_instruction=None, model=None, max_output_tokens=10000, max_parts=10, temperature=None, thinking_config=None, on_progress=None, timeout=900):
        pass

    def wait_for_job_research(self, query, agent='deep-research-pro-preview-12-2025', on_progress=None, timeout=900):
        pass

    def wait_for_job_auto_pipeline(self, topic, prompts, tts_config, thinking_config=None, agent='', on_progress=None, timeout=1200):
        pass

    def generate_with_url_context(self, prompt, youtube_url, max_output_tokens=65000, temperature=1.5, skip_quota_tracking: bool = False) -> str:
        pass

    def upload_file_from_path(self, file_path, mime_type=None, display_name=None):
        pass

    def upload_file(self, base64_data, mime_type, display_name='image'):
        pass

    def transcribe_audio_windowed(self, *, audio_file_path: str, audio_duration: float, window_s: float = 240.0, cached_file_uri: Optional[str] = None, cached_mime_type: Optional[str] = None, progress_callback: Optional[Callable] = None, expected_script: Optional[List[Dict[str, Any]]] = None, cache_sibling: bool = True, minimum_segment_count: int = 0) -> Optional[List[Dict[str, Any]]]:
        pass

    def _plan_transcribe_windows(self, file_uri: str, mime_type: str, total_s: float, target_window_s: float, progress_callback: Optional[Callable] = None) -> List[Dict[str, float]]:
        """One whole-file coordinator call: choose real pause-safe cut points.

        It returns only a tiny boundary map, never transcript text. Failure is
        non-fatal: deterministic window targets remain a safe fallback."""
        pass

    def _transcribe_window(self, file_uri, mime_type, start_s, end_s, total_s, progress_callback, coverage_hint: str = '', minimum_rows: int = 0) -> Optional[List[Dict[str, Any]]]:
        """One window [start, end] → standard SRT segments. Thinking off.

        The intended script is never sent to the model. Completeness (word
        ratio / missing paragraphs) is a backend retry gate on the caller."""
        pass

    def count_tokens(self, contents, model=None) -> int:
        pass

    def estimate_clone(self, file_uri: str, intelligence: str = '', duration_seconds: int = 0, clip_duration_seconds: int = 8, mime_type: str = 'video/mp4', prompt_tokens: int = 0, output_tokens: int = 0) -> dict:
        pass

    def estimate_cost(self, input_tokens: int, output_tokens: int, intelligence: str = '') -> dict:
        pass

    def report_usage(self, model, input_tokens, output_tokens, total_tokens=0, operation='aistudio_generate', intelligence='', feature='') -> dict:
        pass

    def create_chat_session(self, system_instruction=None, temperature=None, model=None):
        pass

    def create_cache(self, contents, system_instruction=None, ttl_seconds=3600, display_name=None, model=None):
        pass

    def generate_with_cache(self, cache_name, prompt, max_output_tokens=65000, temperature=None, model=None, thinking_config=None, response_mime_type=None, completion_spec=None):
        pass

    def generate_with_cache_stream(self, cache_name, prompt, max_output_tokens=65000, temperature=None, model=None, thinking_config=None):
        """Streaming generate using cached context — yields SSE chunks.

        Args:
            cache_name: Cache name from create_cache().
            prompt: The prompt to send.
            max_output_tokens: Max output tokens.
            model: Must match the model used when creating the cache.
            thinking_config: Optional thinking config dict."""
        pass

    def list_caches(self):
        pass

    def get_cache(self, cache_name):
        pass

    def update_cache_ttl(self, cache_name, ttl_seconds):
        pass

    def delete_cache(self, cache_name):
        pass

    def smart_generate(self, contents, prompt, system_instruction=None, model=None, max_output_tokens=10000, max_parts=10, ttl_seconds=3600, temperature=None, thinking_config=None, response_mime_type=None, completion_spec=None, on_part_start=None, on_part_text=None, on_part_complete=None, on_cache_created=None):
        """Server-side smart generate with auto-continuation.

        The server creates a cache + multi-turn chat internally, generates
        content in chunks (each ≤ max_output_tokens), and merges everything.
        This avoids hallucination from long outputs by keeping each chunk
        in the LLM's quality sweet spot while maintaining full chat history.

        Args:
            contents: Large context text to cache.
            prompt: First-turn instruction (what to generate).
            system_instruction: System instruction (cached).
            model: Model name (Gemini 3.5/3.6 Flash only).
            max_output_tokens: Tokens per chunk (default 10000).
            max_parts: Max continuation rounds (default 10).
            ttl_seconds: Cache TTL (default 1h).
            temperature: Generation temperature.
            thinking_config: Optional thinking config dict.
            on_part_start: Callback(part_num) when a new part starts.
            on_part_text: Callback(part_num, text) for streaming text deltas.
            on_part_complete: Callback(part_num, tokens, is_complete) when part finishes.
            on_cache_created: Callback(cache_name, token_count) when cache is ready.

        Returns:
            dict with 'text' (merged output), 'parts' (count), 'usage'."""
        pass

    def cached_context(self, contents, system_instruction=None, model=None, ttl_seconds=3600, display_name=None):
        pass

    def cached_chat(self, contents, system_instruction=None, model=None, ttl_seconds=3600, temperature=None, max_output_tokens=65000, display_name=None):
        pass

    def create_interaction(self, query, agent='deep-research-preview-04-2026', background=True, stream=False, thinking_summaries='auto', previous_interaction_id=None, collaborative_planning=False, visualization=None, tools=None, files=None, agent_config=None, extra_payload=None):
        pass

    def create_interaction_stream(self, query, agent='deep-research-preview-04-2026', thinking_summaries='auto', previous_interaction_id=None, collaborative_planning=False, visualization=None, tools=None, files=None, agent_config=None, extra_payload=None):
        """SSE streaming cho Deep Research qua Go server /v2/research/start-stream.
        Yields attribute-based objects tương thích với DeepResearchWorker._process_stream()."""
        pass

    def resume_interaction_stream(self, interaction_id, last_event_id=None):
        """Resume research SSE stream via Go server /v2/research/{id}/stream.
        Forwards to Gemini: GET interactions/{id}?stream=true&last_event_id=XXX&alt=sse
        Falls back to JSON poll if SSE resume fails."""
        pass

    def get_interaction(self, interaction_id, include_steps=True):
        pass

    def auto_pipeline_stream(self, topic: str, prompts: dict, tts_config: dict, thinking_config: dict = None, agent: str = ''):
        """SSE streaming cho auto-pipeline: Research → Script → Director → TTS → Metadata.
        Server chạy toàn bộ pipeline, client chỉ nhận SSE events.

        Args:
            topic: Research topic
            prompts: {"script": "...", "director": "...", "metadata": "..."}
            tts_config: {"voice_name": "Kore", "model": "...", "multi_speaker_config": [...]}
            thinking_config: {"thinking_budget": -1} for script generation
            agent: Deep research agent model

        Yields:
            _AttrDict events with type: pipeline_start, step, text_delta,
            step_complete, progress, error, research_event, pipeline_complete"""
        pass

    def download_pipeline_audio(self, pipeline_id: str) -> bytes:
        pass

    def generate_content_stream(self, prompt, max_output_tokens=65000, temperature=None, system_instruction=None, model=None, cache_name=None):
        """SSE streaming client — yields text chunks.

        Args:
            cache_name: Optional cached content name. When provided, system_instruction
                        is ignored (it must come from the cache)."""
        pass


# --- Class: CachedContext ---
class CachedContext:
    """Auto-managed cached context for multi-step generation.

    Automatically creates a Gemini cache on __enter__ and deletes it on __exit__.
    Provides generate() and generate_stream() that use the cached context.

    Usage:
        with provider.cached_context(large_text, system_instruction="...") as ctx:
            result1 = ctx.generate("Summarize")
            result2 = ctx.generate("Extract key points")
        # cache auto-deleted"""
    cache_name = <property object at 0x00000264E13D39C0>
    token_count = <property object at 0x00000264E13D3A10>

    def __init__(self, provider: 'ServerProxyProvider', contents, system_instruction=None, model=None, ttl_seconds=3600, display_name=None):
        pass

    def __enter__(self):
        pass

    def __exit__(self, exc_type, exc_val, exc_tb):
        pass

    def generate(self, prompt, max_output_tokens=65000, temperature=None, thinking_config=None, response_mime_type=None, completion_spec=None):
        pass

    def generate_stream(self, prompt, max_output_tokens=65000, temperature=None, thinking_config=None):
        """Streaming generate using the cached context — yields SSE chunks."""
        pass


# --- Class: _ServerChatSession ---
class _ServerChatSession:
    """Wrapper for server-side chat session."""
    def __init__(self, provider: 'ServerProxyProvider', session_id: str):
        pass

    def send_message(self, message):
        pass


# --- Class: CachedChatSession ---
class CachedChatSession:
    """Server-side cached chat session — combines Gemini cache + multi-turn chat.

    The server manages all complexity (cache creation, chat history, cleanup).
    This class just POSTs messages and receives results.

    Usage:
        with provider.cached_chat(contents="large doc", system_instruction="...") as chat:
            part1 = chat.send("Write part 1")
            part2 = chat.send("Continue part 2")
        # session auto-closed, cache auto-deleted"""
    session_id = <property object at 0x00000264E13D3B00>
    cache_name = <property object at 0x00000264E13D3B50>
    token_count = <property object at 0x00000264E13D3BA0>

    def __init__(self, provider: 'ServerProxyProvider', contents, system_instruction=None, model=None, ttl_seconds=3600, temperature=None, max_output_tokens=65000):
        pass

    def __enter__(self):
        pass

    def __exit__(self, exc_type, exc_val, exc_tb):
        pass

    def send(self, message: str) -> str:
        pass

    def send_stream(self, message: str):
        """Send a message and yield SSE chunks as dicts.

        Each chunk has at minimum 'text' and 'done' keys.
        The server retains full conversation history."""
        pass


# --- Class: _AiStudioRouter ---
class _AiStudioRouter:
    """Routes generation to the free AI Studio DirectProvider.

    The selected route is exact: AI Studio generation NEVER falls through to the
    paid gateway or Gemini Web. Structured/non-light work rotates through Flash
    3.5/3.6 on every eligible account. If every pair is quota-limited, the caller's
    worker waits and retries in-place so its current pipeline stage is preserved.
    Auth/session/non-quota failures still rotate or raise by their own policy.
    Every media-bound call is ownership-aware. A reference with a recoverable
    local source may rotate and re-upload per account; an account-scoped id is
    pinned to its uploader and must never rotate accounts.

    Only the generation surface is routed; everything else (credit checks, infra,
    unknown attrs) delegates to the gateway object regardless of mode."""
    _ROUTED = ('generate_content', 'generate_with_media', 'smart_generate_with_media', 'generate_json', 'generate_tts', 'generate_imag...
    _GEN_METHODS = ('generate_content', 'generate_with_media', 'smart_generate_with_media', 'generate_json', 'generate_tts', 'generate_imag...
    max_upload_bytes = <property object at 0x00000264E1400220>
    max_video_seconds = <property object at 0x00000264E1400270>
    upload_provider_label = <property object at 0x00000264E14002C0>
    _GEMINI_FALLBACK_METHODS = ()

    def __init__(self, direct, fallback, pinned_account: str = '', fail_on_all_quota: bool = False):
        pass

    def _bind_direct(self, account: str) -> Any:
        pass

    def _gemini_web_client(self):
        pass

    def _gemini_fallback(self, name: str, args: tuple, kwargs: dict):
        pass

    def _ensure_direct_runtime(self, direct, account: str, source: str, retry_failed: bool):
        pass

    @staticmethod
    def _direct_runtime_token(direct):
        pass

    @staticmethod
    def _reset_direct_runtime(direct, account: str, source: str) -> None:
        pass

    def prewarm(self) -> bool:
        pass

    def keepalive(self) -> bool:
        pass

    def ensure_local_media_path(self, url: str) -> str:
        pass

    def cached_local_media_path(self, url: str) -> str:
        pass

    @staticmethod
    def _direct_account_name(direct: Any) -> str:
        pass

    def _record_upload_owner(self, file_ref: Any, account: str, local_path: str = '') -> None:
        pass

    @staticmethod
    def _portable_media_ref(file_ref: Any) -> bool:
        pass

    @staticmethod
    def _explicit_media_owner(part: Dict[str, Any]) -> str:
        pass

    def _media_binding(self, file_ref: Any) -> Dict[str, str]:
        pass

    def _prepare_media_part(self, raw_part: Dict[str, Any], scoped_owners: Dict[str, str], unknown_refs: List[str]) -> Dict[str, Any]:
        pass

    def _prepare_account_scoped_media_call(self, name: str, args: tuple, kwargs: Dict[str, Any]) -> tuple[tuple, typing.Dict[str, typing.Any], str]:
        """Normalize media inputs and return the one required owner, if any.

        Bare AI Studio file ids without ownership are rejected. Rotating those
        requests is never valid; a clear re-upload error is safer than a random
        permission/not-found result on another account."""
        pass

    def _pinned_transcribe_router(self, cached_file_uri: Any = None):
        pass

    def transcribe_audio_windowed(self, **kwargs):
        pass

    def _transcribe_window(self, *args, **kwargs):
        pass

    def _plan_transcribe_windows(self, *args, **kwargs):
        pass

    def _report_usage(self, method: str, feature: str = '', direct: Any = None) -> None:
        pass


# --- Class: _AiStudioUnavailable ---
class _AiStudioUnavailable:
    """Pure AI Studio mode, but no durable authenticated account is eligible.

    Honour the chosen mode: content generation and media upload/transcription RAISE a
    clear error and are NEVER silently re-routed to the paid gateway (Bố Độ 2026-07-22:
    "chọn mode nào đi mode đó, không fallback qua lại" — same law as
    ``_AiStudioRouter`` and the research/TTS route guards).

    Non-generation infra (is_configured / credit / token / usage) still delegates to the
    gateway object so the app itself doesn't crash. Upload is part of the selected AI
    route, not infra: delegating it would POST the user's media to upload.veoflow.dev.
    ``is_aistudio_route`` reports this as the AI-Studio axis so downstream route pickers
    (e.g. TTS) stay on AI Studio and hit this raise instead of dropping to the gateway."""
    _GEN = frozenset({'generate_content_plan', 'smart_generate', 'generate_with_media', 'generate_with_url_context', 'generate_stre...
    _AUTH_NOTICE_GEN = frozenset({'generate_stream', 'create_interaction_stream', 'smart_generate_with_media', 'generate_content_plan', 'genera...

    def __init__(self, fallback):
        pass


# --- Top-Level Functions ---
def _resolve_model_setting() -> str:
    pass

def _resolve_effort_setting() -> str:
    pass

def input_error_notice(message: str) -> Optional[str]:
    """Return the friendly *too-large* notice only for explicit size/token evidence.

    ``INVALID_ARGUMENT``/HTTP 400 is a generic Gemini bucket: malformed JSON,
    unsupported parameters, a stale media reference, and real size overflow all use it.
    Treating every 400 as "video quá dài" made a 21-minute MP3 look over-limit even
    though no duration gate fired. Generic 400s must retain their real server detail."""
    pass

def auth_error_notice(message: str) -> Optional[str]:
    """If `message` is a balance-check failure the gateway raised because it could NOT
    verify the licence (runtime token stale/expired/invalid, session revoked, licence
    not synced), return a friendly Vietnamese notice; else None.

    Wording is LICENCE-framed on purpose: VeoFlow has no username/password login — a
    user ACTIVATES a licence key on a device. The runtime token is just a short-lived
    derivative of that licence, and it only fails to renew when the licence itself is
    expired / unsynced / revoked. So "đăng nhập lại" would tell the user to do something
    that does not exist; the real action is to check or renew the licence.

    Why it matters: this balance check is the chokepoint gating EVERY generate (AI Studio
    free path included — `check_credits_or_raise` is not in the AiStudio wrapper's
    _ROUTED, so it always falls through to the gateway). The old text ("Cannot check
    credits: 401 ...") sent users hunting a credit/billing bug instead."""
    pass

def set_ai_feature(feature: str) -> None:
    pass

def current_ai_feature() -> str:
    pass

def ai_feature_scope(feature: str):
    """Attribute every AI call inside this block to `feature`. Use for call paths
    whose provider method takes no `feature` argument (TTS, image, cache, ...)."""
    pass

def with_ai_feature(feature: str):
    pass

def bind_feature(provider, feature: str):
    pass

def _transcribe_route_info(provider) -> Dict[str, str]:
    pass

def _transcribe_ref_kind(ref: Any) -> str:
    pass

def ai_credits_exhausted() -> bool:
    pass

def notify_ai_credits_exhausted(detail: str = '') -> None:
    pass

def _gateway_backoff(n: int) -> float:
    pass

def validate_transcribe_audio_file_size(audio_file_path: str) -> int:
    pass

def _parse_transcribe_srt(raw: Any) -> List[Dict[str, Any]]:
    """Provider transcribe JSON (fenced or bare) → enriched segment dicts,
    dropping malformed rows. Pure — no provider state.

    Some transports prepend prose, while Gemini can return the requested
    ``segments`` array directly instead of wrapping it in ``{"segments": ...}``.
    Both shapes carry the same timestamp contract, so accept either without
    throwing away a complete transcription."""
    pass

def _stitch_transcribe_windows(segments: List[Dict[str, Any]], total_s: float) -> List[Dict[str, Any]]:
    """Concatenated per-window rows → one monotonic, non-overlapping track.
    A boundary overlap (a window edge splitting an utterance) is trimmed to the
    previous row's end; zero-length leftovers dropped. Pure."""
    pass

def _parse_transcribe_cut_plan(raw: Any) -> List[Dict[str, float]]:
    pass

def resolve_transcribe_window_s(total_s: float, window_s: float = 240.0, *, known_script: bool = False) -> float:
    pass

def _build_transcribe_windows(total_s: float, target_window_s: float, cut_plan: Optional[List[Dict[str, float]]] = None) -> List[Tuple[float, float]]:
    pass

def _transcribe_rows(segments: Optional[List[Dict[str, Any]]]) -> List[Dict[str, Any]]:
    pass

def _largest_speech_hole(rows: List[Dict[str, Any]], start_s: float, end_s: float) -> Optional[Tuple[float, float]]:
    pass

def parse_speech_gap_range(reason: str) -> Optional[Tuple[float, float]]:
    pass

def _validate_transcribe_window_coverage(segments: Optional[List[Dict[str, Any]]], start_s: float, end_s: float) -> Tuple[bool, str]:
    pass

def _is_whole_second(value: float) -> bool:
    pass

def _is_srt_clock_failure(reason: str) -> bool:
    pass

def _frac_bucket(value: float) -> int:
    pass

def _validate_transcribe_timestamp_realism(segments: Optional[List[Dict[str, Any]]], start_s: float, end_s: float) -> Tuple[bool, str]:
    """Reject lattices that tile the clock but miss spoken onsets.

    POV 30/8 window 2: 175 cues on a 2s/:00 grid after the 599.2s seam.
    0-based rescue that adds 599.2 produces 601.200, 603.200 — still a
    lattice, just not whole seconds. Fake milliseconds on a fixed step
    (2.00s ± 0.05) are the same bug. Short/sparse windows stay allowed."""
    pass

def _transcript_word_count(text: str) -> int:
    pass

def _validate_transcribe_script_completeness(segments: Optional[List[Dict[str, Any]]], expected_script: Optional[List[Dict[str, Any]]] = None) -> Tuple[bool, str]:
    """Reject empty or summarized transcripts that still cover the clock.

    Coverage only proves timestamps tile 0→end. The WW2 clone SRT spanned
    1017s with 60% of the script words; later cues were stretched. When a
    known script exists, word count and paragraph mapping must stay close."""
    pass

def _normalize_transcribe_cue_text(text: str) -> str:
    pass

def _transcribe_cue_is_substantive(norm: str) -> bool:
    pass

def _transcribe_speech_cues(segments: Optional[List[Dict[str, Any]]]) -> List[Tuple[str, str]]:
    pass

def _transcribe_cues_repeat(later_norm: str, prior_norm: str) -> bool:
    pass

def _local_repeat_flags(later_cues: List[Tuple[str, str]], prior_cues: List[Tuple[str, str]]) -> List[bool]:
    pass

def _repeat_gate(flags: List[bool], later_cues: List[Tuple[str, str]]) -> Tuple[bool, str, List[str]]:
    pass

def _parse_repeat_indices(raw: Any, n_later: int) -> Optional[List[int]]:
    pass

def _transcribe_repeat_report(later: Optional[List[Dict[str, Any]]], prior: Optional[List[Dict[str, Any]]], extra_indices: Optional[Sequence[int]] = None) -> Tuple[bool, str, List[str]]:
    pass

def _validate_transcribe_no_repeat(later: Optional[List[Dict[str, Any]]], prior: Optional[List[Dict[str, Any]]]) -> Tuple[bool, str]:
    pass

def _validate_stitched_no_repeat(segments: Optional[List[Dict[str, Any]]], duration_s: float, window_s: Optional[float] = None) -> Tuple[bool, str]:
    pass

def _format_transcribe_repeat_hint(reason: str, start_s: float, end_s: float, forbidden: Optional[Sequence[str]] = None) -> str:
    pass

def _call_transcribe_repeat_spotter(provider: Any, later: Optional[List[Dict[str, Any]]], prior: Optional[List[Dict[str, Any]]]) -> Optional[List[int]]:
    pass

def _judge_transcribe_window_repeat(later: Optional[List[Dict[str, Any]]], prior: Optional[List[Dict[str, Any]]], provider: Any = None, extra_indices: Optional[Sequence[int]] = None) -> Tuple[bool, str, List[str]]:
    pass

def _is_terminal_transcribe_error(exc: Exception) -> bool:
    """Errors that retrying the same cached URI cannot repair."""
    pass

def sync_cached_provider_runtime_credentials() -> bool:
    pass

def _remember_aistudio_media_binding(file_ref: Any, owner_account: str, local_path: str = '') -> None:
    pass

def _aistudio_media_binding(file_ref: Any) -> Dict[str, str]:
    pass

def _acct_key(name: str) -> str:
    pass

def _persisted_aistudio_accounts() -> list:
    """Return durable account identities eligible to cold-start AI Studio.

    BrowserManager ``_contexts`` is runtime cache, not authentication state.  A
    successful manual login deliberately closes its headed browser before the
    account is published Live; the next cookie read then JIT-opens that same
    permanent profile with ``headless=new``.  Gating here on an already-open
    context therefore produced a false ``aistudio_unavailable`` after login or
    app restart and prevented that lazy recovery from ever running.

    The durable admission contract is the one established by login import:
    enabled + a committed Labs session cookie.  Normal work requires ``Live``;
    ``Need Login`` remains a recovery candidate because Labs status does not prove
    AI Studio health; its own TTL permits one real browser probe. Other states stay
    excluded.  The browser/profile owns the current cookie jar; the DB snapshot
    only proves that this account passed the complete login transaction and is
    safe to cold-start."""
    pass

def _rank_accounts_by_tier(names) -> list:
    pass

def _usable_aistudio_accounts(candidates: Optional[list] = None) -> list:
    pass

def _blocked_aistudio_probe_account() -> str:
    pass

def _request_aistudio_login_owner_probe(account: str, detail: str = '') -> bool:
    pass

def _reset_aistudio_auth_recovery(account: str) -> None:
    pass

def _resolve_aistudio_account() -> Optional[str]:
    pass

def _is_quota_err(e) -> bool:
    pass

def _aistudio_pair_key(account: str, model: str) -> tuple[str, str]:
    pass

def _aistudio_pair_quota_remaining(account: str, model: str) -> float:
    pass

def _mark_aistudio_pair_quota(account: str, model: str, cap: float | None = None) -> float:
    pass

def _clear_aistudio_pair_quota(account: str, model: str) -> None:
    pass

def _aistudio_earliest_pair_ready_in(accounts: Sequence[str], models: Sequence[Optional[str]]) -> float:
    pass

def _aistudio_tts_model_chain(kwargs: Dict[str, Any]) -> tuple[str, ...]:
    pass

def _aistudio_structured_model_chain(method: str, kwargs: Dict[str, Any]) -> tuple[str, ...]:
    """Return the full quota recovery lane for every AI Studio generation call."""
    pass

def _aistudio_quota_wait_delay(cycle: int) -> float:
    pass

def _aistudio_exhausted_wait_seconds(method: str, cycle: int, pair_ready: float) -> float:
    pass

def _aistudio_all_pairs_quota(attempted_pairs: int, quota_hits: int) -> bool:
    pass

def _wait_for_aistudio_quota(seconds: float) -> None:
    pass

def _loose_json_dict(text: str) -> Optional[dict]:
    pass

def force_rotate_aistudio_account(failed: str = '') -> Optional[str]:
    pass

def _refresh_aistudio_from_login_owner(account: str, *, fresh_login: bool) -> None:
    pass

def refresh_aistudio_after_login(account: str = '') -> None:
    pass

def refresh_aistudio_after_owner_probe(account: str = '') -> None:
    pass

def allowed_ai_modes() -> dict:
    pass

def effective_api_mode() -> str:
    pass

def make_windowed_transcriber(feature: str = '', *, provider: Optional[services.shared.ai.ai_providers.BaseAIProvider] = None, cached_file_uri: Optional[str] = None, cached_mime_type: Optional[str] = None, expected_script: Optional[List[Dict[str, Any]]] = None, cache_sibling: bool = True, minimum_segment_count: int = 0) -> Callable[..., Optional[List[Dict[str, Any]]]]:
    pass

def get_ai_provider(provider_name: str = 'auto', feature: str = '') -> Optional[services.shared.ai.ai_providers.BaseAIProvider]:
    pass

def _maybe_wrap_aistudio(server_provider):
    pass

def is_aistudio_route(provider: Any = None) -> bool:
    pass

def prewarm_aistudio() -> bool:
    pass

def keepalive_aistudio() -> bool:
    pass

def request_aistudio_prewarm() -> None:
    pass

def run_aistudio_keeper(initial_delay_seconds: float = 0.0, retry_delay_seconds: float = 30.0, keepalive_interval_seconds: float = 1800.0, stop_event: Optional[threading.Event] = None) -> None:
    pass

def _get_local_ai_provider(provider_name: str = 'auto') -> Optional[services.shared.ai.ai_providers.BaseAIProvider]:
    pass

def has_api_key_available(provider: str = 'auto') -> bool:
    pass

def get_preferred_provider_name() -> Optional[str]:
    pass

def _strip_code_fences(text: str) -> str:
    pass

def _validate_fixed_prompt_shape(original_prompt: str, fixed_prompt: str) -> Tuple[bool, str]:
    pass

def extract_error_code(error_message: str) -> str:
    pass

def classify_violation(error_message: str) -> Tuple[str, str]:
    """Return (violation_type, guidance) for an error message.

    First-match-wins against the ordered taxonomy. Falls back to a generic
    "content policy" bucket if no keyword matches."""
    pass

def _violation_key(error_message: str) -> str:
    """Return the stable taxonomy key used by output-contract validation."""
    pass

def _is_input_image_ip_error(error_message: str) -> bool:
    pass

def _validate_ip_replacement_manifest(original_prompt: str, fixed_prompt: str, replacements: Any) -> Tuple[bool, str]:
    pass

def _verify_ip_rewrite_with_ai(provider: Any, original_prompt: str, fixed_prompt: str, replacements: Any) -> Tuple[bool, str]:
    """Ask a separate AI pass to audit semantic completeness of an IP repair.

    Local code can prove exact substitutions but cannot own a complete, current list
    of public people, protected characters, works, and brands. This second pass checks
    the semantic part independently and rejects candidates that left another risky
    name behind or replaced a clearly invented safe name without cause."""
    pass

def _build_escalation_guidance(attempt_num: int, previous_prompt: Optional[str]) -> str:
    pass

def _extract_json_object(text: str) -> Optional[dict]:
    pass

def fix_policy_violation_prompt(original_prompt: str, error_message: str, max_attempts: int = 2, attempt_num: int = 1, previous_prompt: Optional[str] = None, repair_metadata: Optional[Dict[str, Any]] = None) -> Tuple[Optional[str], Optional[str]]:
    """Strong policy fixer: send the FULL prompt + API error to the AI and ask it to
    return the FULL rewritten prompt with ONLY the violating words changed.

    The prompt is TEXT, not strict JSON — VEO3 does not require valid JSON and the
    prompt is post-processed with raw string replacements upstream, so a "parse →
    edit a field → re-serialize" approach is both fragile and wrong. We let the AI
    rewrite the text directly and verify that it preserved every asset ID and
    scene_id key the gateway depends on. IP-name repairs additionally return an
    auditable replacement manifest; the backend verifies those exact substitutions
    without trying to own a stale celebrity/copyright blacklist.  ``repair_metadata``
    is an optional mutable sink used by the dispatcher to apply the SAME name map to
    every nested entity field and every sibling scene in the batch.  The public
    two-item return contract remains unchanged for existing callers."""
    pass
