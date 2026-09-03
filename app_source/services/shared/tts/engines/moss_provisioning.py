"""
Decompiled / Reconstructed Module: services.shared.tts.engines.moss_provisioning
Source PyC: moss_provisioning.pyc

Docstring:
Managed OpenMOSS/MOSS-TTS Local v1.5 server bundle.

Customer machines download two immutable VeoFlow CDN resources: a self-contained
server runtime and a separately versioned model pack.  They never create a
virtualenv, run uv/pip, receive upstream source, or contact Hugging Face.

Nothing in this module is called on the GUI thread: ``ensure_async`` is the
dropdown warm-up path and ``ensure_server`` is called by a TTS worker.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Callable = typing.Callable
Dict = typing.Dict
Optional = typing.Optional
UPSTREAM_URL = 'https://github.com/OpenMOSS/MOSS-TTS.git'
UPSTREAM_COMMIT = 'ad99ec5f26debf1d6c1a4dc8461b2bcb787ec9af'
MODEL_ID = 'OpenMOSS-Team/MOSS-TTS-Local-Transformer-v1.5'
CODEC_ID = 'OpenMOSS-Team/MOSS-Audio-Tokenizer-v2'
MODEL_REVISION = 'be7766a6735b98bd793f7c79fb720b4d0f5d13b8'
CODEC_REVISION = 'f6e20e543b33d2c252a7ef71bdf8aa71e5ff9169'
SERVER_TOOL_CODE = 'VEOFLOW_TTS_MOSS'
MODELS_TOOL_CODE = 'VEOFLOW_TTS_MOSS_MODELS'
PORT = 8767
IDLE_STOP_S = 300.0
_lock = <unlocked _thread.RLock object owner=0 count=0 at 0x00000264E48C9080>
_status_lock = <unlocked _thread.lock object at 0x00000264E48CAA80>
_status = {'state': 'idle', 'progress': 0, 'message': ''}
_proc = None
_server_state = 'stopped'
_server_message = ''
_server_port = 0
_server_profile = ''
_last_used = 0.0
_watchdog_started = False
FULL_GPU_PROFILE = 'full_gpu'
HYBRID_12GB_PROFILE = 'hybrid_12gb'

# --- Top-Level Functions ---
def _normalize_runtime_profile(value: 'str') -> 'str':
    pass

def _runtime_device_args(runtime_profile: 'str') -> 'list[str]':
    pass

def _runtime_profile_gate_reason(runtime_profile: 'str') -> 'str':
    pass

def _resource_root() -> 'Path':
    pass

def _server_exe() -> 'Path':
    pass

def _models_root() -> 'Path':
    pass

def _model_dir() -> 'Path':
    pass

def _codec_dir() -> 'Path':
    pass

def _external_url() -> 'str':
    pass

def _models_ready() -> 'bool':
    pass

def _set_status(state: 'str', progress: 'int' = 0, message: 'str' = '') -> 'None':
    pass

def _set_server(state: 'str', message: 'str' = '') -> 'None':
    pass

def _local_gate_reason(*, include_disk: 'bool') -> 'str':
    pass

def _ensure_storage_location(progress: 'Optional[Callable[[str], None]]' = None, *, exclude_current: 'bool' = False) -> 'None':
    pass

def is_installed() -> 'bool':
    pass

def _install_resource(tool_code: 'str', label: 'str', progress: 'Optional[Callable[[str], None]]', progress_start: 'int', progress_end: 'int') -> 'str':
    pass

def _cleanup_legacy_bootstrap() -> 'None':
    pass

def ensure_blocking(progress: 'Optional[Callable[[str], None]]' = None, *, _storage_retry: 'bool' = True) -> 'bool':
    pass

def ensure_async() -> 'None':
    pass

def touch() -> 'None':
    pass

def _health_ready(url: 'str') -> 'bool':
    pass

def _terminate_process(proc: 'Optional[subprocess.Popen]') -> 'None':
    pass

def _watchdog() -> 'None':
    pass

def ensure_server(progress: 'Optional[Callable[[str], None]]' = None, runtime_profile: 'str' = 'auto') -> 'str':
    pass

def status() -> 'Dict[str, Any]':
    pass

def stop() -> 'None':
    pass
