"""
Decompiled / Reconstructed Module: core.dispatch.contracts
Source PyC: contracts.pyc

Docstring:
core/dispatch/contracts.py — Data types, result shapes, and service Protocols.

Everything the dispatch system passes between its components is defined here.
No logic. No imports from the dispatch internals.

Replaces: the implicit dict shapes passed between 200 methods in smart_job_dispatcher.py.
Improvement: explicit, type-safe, one place to look.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Callable = typing.Callable

# --- Class: Feature ---
class Feature(str, Enum):
    """source_tab — WHERE the UI call came from. Metadata only, NOT a routing key."""
    _use_args_ = True
    _member_names_ = ['TEXT_VIDEO', 'PORTRAIT_VIDEO', 'IMAGE_VIDEO', 'EXTEND_VIDEO', 'MULTI_ASSET', 'IMAGE_GEN', 'CHARACTER_GEN', 'UPSCALE']
    _member_map_ = {'TEXT_VIDEO': <Feature.TEXT_VIDEO: 'text_video'>, 'PORTRAIT_VIDEO': <Feature.PORTRAIT_VIDEO: 'portrait_video'>, 'IMAGE_...
    _value2member_map_ = {'text_video': <Feature.TEXT_VIDEO: 'text_video'>, 'portrait_video': <Feature.PORTRAIT_VIDEO: 'portrait_video'>, 'image_...
    _unhashable_values_ = []
    TEXT_VIDEO = <Feature.TEXT_VIDEO: 'text_video'>
    PORTRAIT_VIDEO = <Feature.PORTRAIT_VIDEO: 'portrait_video'>
    IMAGE_VIDEO = <Feature.IMAGE_VIDEO: 'image_video'>
    EXTEND_VIDEO = <Feature.EXTEND_VIDEO: 'extend_video'>
    MULTI_ASSET = <Feature.MULTI_ASSET: 'multi_asset_video'>
    IMAGE_GEN = <Feature.IMAGE_GEN: 'image_generation'>
    CHARACTER_GEN = <Feature.CHARACTER_GEN: 'character_generation'>
    UPSCALE = <Feature.UPSCALE: 'upscale_video'>

    @staticmethod
    def _generate_next_value_(name, start, count, last_values):
        """Generate the next value when not given.

        name: the name of the member
        start: the initial start value or None
        count: the number of existing members
        last_values: the list of values assigned"""
        pass

    def _new_member_(*args, **kwargs):
        """Create and return a new object.  See help(type) for accurate signature."""
        pass

    def _member_type_(*args, **kwargs):
        """str(object='') -> str
str(bytes_or_buffer[, encoding[, errors]]) -> str

Create a new string object from the given object. If encoding or
errors is specified, then the object must expose a data buffer
that will be decoded using the given encoding and error handler.
Otherwise, returns the result of object.__str__() (if defined)
or repr(object).
encoding defaults to sys.getdefaultencoding().
errors defaults to 'strict'."""
        pass

    def _value_repr_(self, /):
        """Return repr(self)."""
        pass

    def __repr__(self):
        pass

    def __str__(self):
        pass


# --- Class: ApiJob ---
class ApiJob(str, Enum):
    """api_job — WHAT the system will actually do. THE routing key.

    Resolved once at submit time by JobClassifier from (feature, prompt_data).
    Handlers route on this, never on `feature` or by re-inspecting prompt_data."""
    _use_args_ = True
    _member_names_ = ['T2V', 'R2V_CHARACTER', 'R2V_VISUAL', 'MULTI_ASSET', 'IMAGE_VIDEO', 'EXTEND', 'IMAGE_GEN', 'UPSCALE', 'CHARACTER_GEN']
    _member_map_ = {'T2V': <ApiJob.T2V: 't2v'>, 'R2V_CHARACTER': <ApiJob.R2V_CHARACTER: 'r2v_character'>, 'R2V_VISUAL': <ApiJob.R2V_VISUAL:...
    _value2member_map_ = {'t2v': <ApiJob.T2V: 't2v'>, 'r2v_character': <ApiJob.R2V_CHARACTER: 'r2v_character'>, 'r2v_visual': <ApiJob.R2V_VISUAL:...
    _unhashable_values_ = []
    T2V = <ApiJob.T2V: 't2v'>
    R2V_CHARACTER = <ApiJob.R2V_CHARACTER: 'r2v_character'>
    R2V_VISUAL = <ApiJob.R2V_VISUAL: 'r2v_visual'>
    MULTI_ASSET = <ApiJob.MULTI_ASSET: 'multi_asset'>
    IMAGE_VIDEO = <ApiJob.IMAGE_VIDEO: 'image_video'>
    EXTEND = <ApiJob.EXTEND: 'extend'>
    IMAGE_GEN = <ApiJob.IMAGE_GEN: 'image_gen'>
    UPSCALE = <ApiJob.UPSCALE: 'upscale'>
    CHARACTER_GEN = <ApiJob.CHARACTER_GEN: 'character_gen'>

    @staticmethod
    def _generate_next_value_(name, start, count, last_values):
        """Generate the next value when not given.

        name: the name of the member
        start: the initial start value or None
        count: the number of existing members
        last_values: the list of values assigned"""
        pass

    def _new_member_(*args, **kwargs):
        """Create and return a new object.  See help(type) for accurate signature."""
        pass

    def _member_type_(*args, **kwargs):
        """str(object='') -> str
str(bytes_or_buffer[, encoding[, errors]]) -> str

Create a new string object from the given object. If encoding or
errors is specified, then the object must expose a data buffer
that will be decoded using the given encoding and error handler.
Otherwise, returns the result of object.__str__() (if defined)
or repr(object).
encoding defaults to sys.getdefaultencoding().
errors defaults to 'strict'."""
        pass

    def _value_repr_(self, /):
        """Return repr(self)."""
        pass

    def __repr__(self):
        pass

    def __str__(self):
        pass


# --- Class: JobHandle ---
class JobHandle:
    """Minimal runtime handle. State is read from/written to JobStore."""
    api_job = None
    retry_count = 0
    ai_fix_attempts = 0
    policy_violation_count = 0
    timeout_count = 0
    black_regen_count = 0
    upscale_retry_count = 0
    consecutive_429 = 0
    model_retry_count = 0
    model_switches = 0
    locked_account_key = ''
    preferred_account_key = ''
    should_cancel = False
    cancel_reason = ''
    quota_consumed = False
    extend_chain_id = ''
    extend_position = 0
    predecessor_media_id = ''
    last_sent_prompt = ''
    policy_prev_input = ''
    audio_fix_attempts = 0
    audio_prev_input = ''
    model_key = ''
    required_credits = 0
    no_account_since = 0.0

    def __init__(self, job_id: 'str', feature: 'Feature', account_key: 'str', attempt_id: 'str', api_job: "'ApiJob | None'" = None, created_at: 'float' = <factory>, retry_count: 'int' = 0, ai_fix_attempts: 'int' = 0, policy_violation_count: 'int' = 0, timeout_count: 'int' = 0, black_regen_count: 'int' = 0, upscale_retry_count: 'int' = 0, consecutive_429: 'int' = 0, model_retry_count: 'int' = 0, model_switches: 'int' = 0, locked_account_key: 'str' = '', preferred_account_key: 'str' = '', excluded_account_keys: 'set[str]' = <factory>, should_cancel: 'bool' = False, cancel_reason: 'str' = '', quota_consumed: 'bool' = False, extend_chain_id: 'str' = '', extend_position: 'int' = 0, predecessor_media_id: 'str' = '', depends_on: 'list[str]' = <factory>, last_sent_prompt: 'str' = '', policy_prev_input: 'str' = '', audio_fix_attempts: 'int' = 0, audio_prev_input: 'str' = '', model_key: 'str' = '', required_credits: 'int' = 0, no_account_since: 'float' = 0.0) -> None:
        pass

    def __repr__(self):
        pass


# --- Class: AccountSlot ---
class AccountSlot:
    """Immutable view of an assigned account slot."""
    is_ultra = <property object at 0x00000264DAD46CA0>
    key = <property object at 0x00000264DAD46200>

    def __init__(self, account_id: 'str', account_name: 'str', account_email: 'str', profile_name: 'str', project_id: 'str', user_tier: 'str', credits: 'int', proxy_config: 'dict[str, Any] | None') -> None:
        pass

    def __repr__(self):
        pass


# --- Class: GenResult ---
class GenResult:
    """Unified result from any generation strategy."""
    workflow_id = ''
    executing_account = ''
    error = ''
    error_category = ''
    retryable = True
    cancelled = False
    resumed = False
    download_error = ''

    @classmethod
    def failure(cls, error: 'str', error_category: 'str' = 'unknown', retryable: 'bool' = True) -> 'GenResult':
        pass

    @classmethod
    def cancelled_result(cls, reason: 'str' = 'Job cancelled') -> 'GenResult':
        pass

    def __init__(self, success: 'bool', media_ids: 'list[str]' = <factory>, image_paths: 'list[str]' = <factory>, video_paths: 'list[str]' = <factory>, images: 'list[dict]' = <factory>, upscaled_paths: 'list[str]' = <factory>, video_urls: 'list[str]' = <factory>, thumbnail_urls: 'list[str]' = <factory>, workflow_id: 'str' = '', executing_account: 'str' = '', error: 'str' = '', error_category: 'str' = '', retryable: 'bool' = True, cancelled: 'bool' = False, resumed: 'bool' = False, download_error: 'str' = '') -> None:
        pass

    def __repr__(self):
        pass


# --- Class: FailureAction ---
class FailureAction(Enum):
    _use_args_ = False
    _member_names_ = ['RETRY', 'REGEN', 'FAIL', 'MIGRATE', 'COOLDOWN']
    _member_map_ = {'RETRY': <FailureAction.RETRY: 1>, 'REGEN': <FailureAction.REGEN: 2>, 'FAIL': <FailureAction.FAIL: 3>, 'MIGRATE': <Fail...
    _value2member_map_ = {1: <FailureAction.RETRY: 1>, 2: <FailureAction.REGEN: 2>, 3: <FailureAction.FAIL: 3>, 4: <FailureAction.MIGRATE: 4>, 5:...
    _unhashable_values_ = []
    _value_repr_ = None
    RETRY = <FailureAction.RETRY: 1>
    REGEN = <FailureAction.REGEN: 2>
    FAIL = <FailureAction.FAIL: 3>
    MIGRATE = <FailureAction.MIGRATE: 4>
    COOLDOWN = <FailureAction.COOLDOWN: 5>

    @staticmethod
    def _generate_next_value_(name, start, count, last_values):
        """Generate the next value when not given.

        name: the name of the member
        start: the initial start value or None
        count: the number of existing members
        last_values: the list of values assigned"""
        pass

    def _new_member_(*args, **kwargs):
        """Create and return a new object.  See help(type) for accurate signature."""
        pass

    def _member_type_():
        """The base class of the class hierarchy.

When called, it accepts no arguments and returns a new featureless
instance that has no instance attributes and cannot be given any."""
        pass


# --- Class: RetryDecision ---
class RetryDecision:
    """RetryDecision(action: 'FailureAction', delay_seconds: 'float' = 0.0, reason: 'str' = '', new_error_category: 'str' = '')"""
    delay_seconds = 0.0
    reason = ''
    new_error_category = ''

    def __init__(self, action: 'FailureAction', delay_seconds: 'float' = 0.0, reason: 'str' = '', new_error_category: 'str' = '') -> None:
        pass

    def __repr__(self):
        pass


# --- Class: UpscaleRequest ---
class UpscaleRequest:
    """UpscaleRequest(media_id: 'str', account_key: 'str', prompt: 'str', filename: 'str', output_index: 'int', output_count: 'int', output_folder: 'str', job_type: 'str', aspect_ratio: 'str', resolution: 'str' = '1080p', video_url_720p: 'str' = '', is_auto_regen: 'bool' = False, scene_uid: 'str' = '', clone_job_id: 'str' = '', job_store_id: 'str' = '', parent_job_id: 'str' = '', row_id: 'str' = '', watermark_model: 'str' = '', workflow_id: 'str' = '', user_tier: 'str' = '', on_api_success: 'Callable[[], None] | None' = None)"""
    resolution = '1080p'
    video_url_720p = ''
    is_auto_regen = False
    scene_uid = ''
    clone_job_id = ''
    job_store_id = ''
    parent_job_id = ''
    row_id = ''
    watermark_model = ''
    workflow_id = ''
    user_tier = ''
    on_api_success = None

    def __init__(self, media_id: 'str', account_key: 'str', prompt: 'str', filename: 'str', output_index: 'int', output_count: 'int', output_folder: 'str', job_type: 'str', aspect_ratio: 'str', resolution: 'str' = '1080p', video_url_720p: 'str' = '', is_auto_regen: 'bool' = False, scene_uid: 'str' = '', clone_job_id: 'str' = '', job_store_id: 'str' = '', parent_job_id: 'str' = '', row_id: 'str' = '', watermark_model: 'str' = '', workflow_id: 'str' = '', user_tier: 'str' = '', on_api_success: 'Callable[[], None] | None' = None) -> None:
        pass

    def __repr__(self):
        pass


# --- Class: UpscaleResult ---
class UpscaleResult:
    """UpscaleResult(success: 'bool', video_path: 'str' = '', error: 'str' = '', retryable: 'bool' = True)"""
    video_path = ''
    error = ''
    retryable = True

    def __init__(self, success: 'bool', video_path: 'str' = '', error: 'str' = '', retryable: 'bool' = True) -> None:
        pass

    def __repr__(self):
        pass


# --- Class: IModelResolver ---
class IModelResolver(Protocol):
    _is_protocol = True
    _abc_impl = <_abc._abc_data object at 0x00000264DAD42580>
    _is_runtime_protocol = True

    def resolve_t2v(self, aspect: 'str', tier: 'str', speed: 'str') -> 'str':
        pass

    def resolve_r2v(self, aspect: 'str', tier: 'str', speed: 'str', duration_seconds: 'float | None', source_model_key: 'str' = '') -> 'str':
        pass

    def resolve_upscale_aspect(self, aspect_ratio_str: 'str') -> 'str':
        pass

    def extract_speed(self, model_key: 'str') -> 'str':
        pass

    def duration_from_prompt(self, prompt_data: 'dict', base_model: 'str') -> 'float':
        pass

    def late_bind(self, model_key: 'str', prompt_data: 'dict', user_tier: 'str') -> 'str':
        pass

    def guard_t2v_model(self, model_key: 'str', aspect: 'str', tier: 'str', has_ref_assets: 'bool', job_type: 'str') -> 'str':
        pass

    def align_model_duration(self, model_key: 'str', target_duration: 'int | float | None', aspect: 'str' = '16:9', tier: 'str' = 'ultra') -> 'str':
        pass

    def __init__(self, *args, **kwargs):
        pass


# --- Class: IRetryPolicy ---
class IRetryPolicy(Protocol):
    _is_protocol = True
    _abc_impl = <_abc._abc_data object at 0x00000264DA632880>
    _is_runtime_protocol = True

    def decide(self, handle: 'JobHandle', result: 'GenResult', account: 'AccountSlot') -> 'RetryDecision':
        pass

    def __init__(self, *args, **kwargs):
        pass


# --- Class: IJobStateSync ---
class IJobStateSync(Protocol):
    """Owns ALL writes to JobStore and UI signals."""
    _is_protocol = True
    _abc_impl = <_abc._abc_data object at 0x00000264DAD42840>
    _is_runtime_protocol = True

    def on_generating(self, handle: 'JobHandle', phase: 'str') -> 'None':
        pass

    def on_polling(self, handle: 'JobHandle') -> 'None':
        pass

    def on_upscaling(self, handle: 'JobHandle', resolution: 'str') -> 'None':
        pass

    def on_completed(self, handle: 'JobHandle', result: 'GenResult') -> 'None':
        pass

    def on_failed(self, handle: 'JobHandle', error: 'str', error_category: 'str') -> 'None':
        pass

    def on_retrying(self, handle: 'JobHandle', delay: 'float', reason: 'str') -> 'None':
        pass

    def persist_media_id(self, handle: 'JobHandle', media_id: 'str', video_url_720p: 'str') -> 'None':
        pass

    def save_pending_thumbnail(self, handle: 'JobHandle', thumbnail_url: 'str') -> 'None':
        pass

    def mark_attempt_heartbeat(self, handle: 'JobHandle', phase: 'str') -> 'None':
        pass

    def is_current_attempt(self, handle: 'JobHandle') -> 'bool':
        pass

    def __init__(self, *args, **kwargs):
        pass


# --- Class: IUpscaleService ---
class IUpscaleService(Protocol):
    _is_protocol = True
    _abc_impl = <_abc._abc_data object at 0x00000264D9D6F300>
    _is_runtime_protocol = True

    def upscale(self, req: 'UpscaleRequest') -> 'UpscaleResult':
        pass

    def __init__(self, *args, **kwargs):
        pass


# --- Class: IR2VAssetResolver ---
class IR2VAssetResolver(Protocol):
    """Resolves R2V asset references to veo3 media IDs, uploading lazily."""
    _is_protocol = True
    _abc_impl = <_abc._abc_data object at 0x00000264D4D037C0>
    _is_runtime_protocol = True

    def resolve(self, character_metadata: 'dict', account: 'AccountSlot', scene_payload: 'dict', model_key: 'str', aspect_ratio: 'str') -> 'dict[str, str]':
        pass

    def __init__(self, *args, **kwargs):
        pass


# --- Class: IGenerationStrategy ---
class IGenerationStrategy(Protocol):
    """Each strategy handles one feature type. Receives the job handle + account
    slot + injected services, produces a GenResult. Runs inside
    asyncio.to_thread so it may call sync api_client functions freely."""
    _is_protocol = True
    _abc_impl = <_abc._abc_data object at 0x00000264DAD43880>
    _is_runtime_protocol = True

    def run(self, handle: 'JobHandle', prompt_data: 'dict', account: 'AccountSlot', *, model_resolver: 'IModelResolver', asset_resolver: 'IR2VAssetResolver', upscale_service: 'IUpscaleService', job_state: 'IJobStateSync', stop_check: 'Callable[[], bool]', heartbeat: 'Callable[[str], None]') -> 'GenResult':
        pass

    def __init__(self, *args, **kwargs):
        pass


# --- Class: DispatchCallbacks ---
class DispatchCallbacks:
    """DispatchCallbacks(stop_check: 'Callable[[], bool]', heartbeat: 'Callable[[str], None]', progress: 'Callable[[str, int, int], None]')"""
    def __init__(self, stop_check: 'Callable[[], bool]', heartbeat: 'Callable[[str], None]', progress: 'Callable[[str, int, int], None]') -> None:
        pass

    def __repr__(self):
        pass

