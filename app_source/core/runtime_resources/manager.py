"""
Decompiled / Reconstructed Module: core.runtime_resources.manager
Source PyC: manager.pyc

Docstring:
Unified access to downloaded runtime binaries.

This layer keeps app code independent from where large tools come from. Today
FFmpeg/Deno/Browser still install through ``veoflow_res`` upstream downloaders;
later the provider can switch to a VeoFlow CDN without touching feature code.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Callable = typing.Callable
_RESOURCE_ALIASES = {'ffmpeg': 'ffmpeg', 'ffprobe': 'ffmpeg', 'ffplay': 'ffmpeg', 'deno': 'deno', 'browser': 'browser', 'chromium': 'browser'}
_FILE_TO_BINARY = {'ffmpeg.exe': 'ffmpeg', 'ffprobe.exe': 'ffprobe', 'ffplay.exe': 'ffplay', 'deno.exe': 'deno', 'node.exe': 'node', 'chrome.exe': 'chrome'}
_T = ~_T
_RECOVERY_POLICIES = {'aistudio_session': ResourceRecoveryPolicy(max_attempts=2, retryable_kinds=frozenset({<ResourceFailureKind.TRANSPORT: 'transport'>, <ResourceFailureKind.NOT_READY: 'not_ready'>, <ResourceFailureKind.... [truncated]
_manager = <core.runtime_resources.manager.RuntimeResourceManager object at 0x00000264DD40E090>

# --- Class: ResourceFailureKind ---
class ResourceFailureKind(str, Enum):
    """Stable failure taxonomy shared by every managed runtime."""
    _use_args_ = True
    _member_names_ = ['NOT_READY', 'TIMEOUT', 'PROCESS_EXIT', 'TRANSPORT', 'AUTH', 'QUOTA', 'CONFIG', 'HARDWARE', 'STORAGE', 'CONFLICT', 'TER...
    _member_map_ = {'NOT_READY': <ResourceFailureKind.NOT_READY: 'not_ready'>, 'TIMEOUT': <ResourceFailureKind.TIMEOUT: 'timeout'>, 'PROCES...
    _value2member_map_ = {'not_ready': <ResourceFailureKind.NOT_READY: 'not_ready'>, 'timeout': <ResourceFailureKind.TIMEOUT: 'timeout'>, 'proces...
    _unhashable_values_ = []
    NOT_READY = <ResourceFailureKind.NOT_READY: 'not_ready'>
    TIMEOUT = <ResourceFailureKind.TIMEOUT: 'timeout'>
    PROCESS_EXIT = <ResourceFailureKind.PROCESS_EXIT: 'process_exit'>
    TRANSPORT = <ResourceFailureKind.TRANSPORT: 'transport'>
    AUTH = <ResourceFailureKind.AUTH: 'auth'>
    QUOTA = <ResourceFailureKind.QUOTA: 'quota'>
    CONFIG = <ResourceFailureKind.CONFIG: 'config'>
    HARDWARE = <ResourceFailureKind.HARDWARE: 'hardware'>
    STORAGE = <ResourceFailureKind.STORAGE: 'storage'>
    CONFLICT = <ResourceFailureKind.CONFLICT: 'conflict'>
    TERMINAL = <ResourceFailureKind.TERMINAL: 'terminal'>
    UNKNOWN = <ResourceFailureKind.UNKNOWN: 'unknown'>

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


# --- Class: ResourceRecoveryPolicy ---
class ResourceRecoveryPolicy:
    """What the manager may do without changing the user's intent."""
    max_attempts = 1
    retryable_kinds = frozenset()
    backoff_seconds = ()
    allow_adopt = False
    allow_account_rotation = False
    allow_provider_fallback = False
    allow_identity_change = False

    def backoff_for(self, failed_attempt: 'int') -> 'float':
        pass

    def __init__(self, max_attempts: 'int' = 1, retryable_kinds: 'frozenset[ResourceFailureKind]' = frozenset(), backoff_seconds: 'tuple[float, ...]' = (), allow_adopt: 'bool' = False, allow_account_rotation: 'bool' = False, allow_provider_fallback: 'bool' = False, allow_identity_change: 'bool' = False) -> None:
        pass

    def __repr__(self):
        pass


# --- Class: ResourceRecoveryEvent ---
class ResourceRecoveryEvent:
    """ResourceRecoveryEvent(resource: 'str', operation: 'str', kind: 'ResourceFailureKind', failed_attempt: 'int', next_attempt: 'int', max_attempts: 'int', error: 'BaseException')"""
    message = <property object at 0x00000264DD4BC810>

    def __init__(self, resource: 'str', operation: 'str', kind: 'ResourceFailureKind', failed_attempt: 'int', next_attempt: 'int', max_attempts: 'int', error: 'BaseException') -> None:
        pass

    def __repr__(self):
        pass


# --- Class: ResourceStorageSelection ---
class ResourceStorageSelection:
    """ResourceStorageSelection(path: 'Path', changed: 'bool', free_gb: 'float', required_gb: 'float')"""
    def __init__(self, path: 'Path', changed: 'bool', free_gb: 'float', required_gb: 'float') -> None:
        pass

    def __repr__(self):
        pass


# --- Class: RuntimeResourceError ---
class RuntimeResourceError(RuntimeError):
    """Raised when a managed runtime resource cannot be resolved/prepared."""
    def __init__(self, message: 'str', *, resource: 'str' = '', operation: 'str' = '', kind: 'ResourceFailureKind | str' = <ResourceFailureKind.UNKNOWN: 'unknown'>) -> 'None':
        pass


# --- Class: RuntimeResourceManager ---
class RuntimeResourceManager:
    def __init__(self) -> 'None':
        pass

    def ensure(self, resource: 'str', *, file: 'str | None' = None, allow_download: 'bool' = True) -> 'Path':
        pass

    def is_available(self, resource: 'str', *, file: 'str | None' = None) -> 'bool':
        pass

    def recovery_policy(self, resource: 'str') -> 'ResourceRecoveryPolicy':
        pass

    @staticmethod
    def classify_failure(exc: 'BaseException') -> 'ResourceFailureKind':
        """Normalize provider-specific errors without importing providers."""
        pass

    def ensure_storage_location(self, *, configured_base: 'str | os.PathLike[str]', default_base: 'str | os.PathLike[str]', required_free_gb: 'float', progress: 'Callable[[str], None] | None' = None, excluded_bases: 'tuple[str | os.PathLike[str], ...]' = ()) -> 'ResourceStorageSelection':
        """Choose and persist a writable resource root without user repair.

        The configured directory is kept whenever it is usable. Otherwise the
        default application resource root and fixed local drives are tried.
        Existing data is never deleted or moved implicitly; a failed location
        remains recoverable while new resources install into the selected root."""
        pass

    @staticmethod
    def _probe_storage_candidate(path: 'Path', required_gb: 'float') -> 'tuple[bool, float, str]':
        pass

    @staticmethod
    def _fixed_drive_resource_roots() -> 'tuple[Path, ...]':
        pass

    @staticmethod
    def _persist_resource_base(path: 'Path') -> 'None':
        pass

    def execute_with_recovery(self, resource: 'str', operation: 'str', action: 'Callable[[], _T]', *, policy: 'ResourceRecoveryPolicy | None' = None, classify: 'Callable[[BaseException], ResourceFailureKind] | None' = None, on_retry: 'Callable[[ResourceRecoveryEvent], None] | None' = None) -> '_T':
        pass

    def install_dir(self, resource: 'str') -> 'Path':
        pass

    def manifest(self) -> 'dict[str, Any]':
        pass

    def _resource_spec(self, resource: 'str') -> 'dict[str, Any]':
        pass

    def _canonical_resource(self, resource: 'str') -> 'str':
        pass

    def _binary_name(self, file: 'str | None', resource: 'str') -> 'str | None':
        pass

    @staticmethod
    def _verify_file(path: 'Path') -> 'None':
        pass

    def _lock_for(self, resource: 'str') -> "__assert_armored__((threading, b'\\x81\\xa9\\x94\\x16W'))":
        pass

    @staticmethod
    def _manifest_path() -> 'Path':
        pass


# --- Top-Level Functions ---
def get_runtime_resource_manager() -> 'RuntimeResourceManager':
    pass
