"""
Decompiled / Reconstructed Module: services.shared.tts.engines.provisioning
Source PyC: provisioning.pyc

Docstring:
Provisioning engine TTS offline — CDN tải on-demand + server local tự bật/tắt.

Owner design: KHÔNG bundle engine vào build; user dùng Voice Studio thì hệ thống
kéo bootstrap từ resource store về AppData rồi CHẠY NHƯ SERVER RIÊNG (process
cách ly — không đụng numpy/onnxruntime của app đông lạnh). Cả VieNeu lẫn
OmniVoice cùng pattern uv-bootstrap: veoflow_res spawn + poll health, adapter
nói HTTP, watchdog tự tắt khi idle. Trạng thái expose qua ``engine_status()``.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Callable = typing.Callable
Dict = typing.Dict
Optional = typing.Optional
TOOL_CODES = {'vieneu': 'VEOFLOW_TTS_VIENEU', 'omnivoice': 'VEOFLOW_TTS', 'moss_nano': 'VEOFLOW_TTS_MOSS_NANO'}
PORT_OWNERS = {'vieneu': 'tts_vieneu', 'omnivoice': 'tts_omnivoice', 'moss_nano': 'tts_moss_nano'}
_IDLE_STOP_S = 300.0
_status_lock = <unlocked _thread.lock object at 0x00000264E48EBAC0>
_install_status = {}
_install_locks = {'vieneu': <unlocked _thread.lock object at 0x00000264E48EB900>, 'omnivoice': <unlocked _thread.lock object at 0x00000264E48EBB80>, 'moss_nano': <unlocked _thread.lock object at 0x00000264E48EBC80>}
_update_checked = set()
_runtimes = {'vieneu': <services.shared.tts.engines.provisioning._ServerRuntime object at 0x00000264E5115310>, 'omnivoice': <services.shared.tts.engines.provisioning._ServerRuntime object at 0x00000264E2B80380>, ... [truncated]
_watchdog_started = False

# --- Class: _ServerRuntime ---
class _ServerRuntime:
    def __init__(self, engine_id: 'str') -> 'None':
        pass

    def set(self, state: 'str', message: 'str' = '') -> 'None':
        pass

    def touch(self) -> 'None':
        pass

    def idle_stop_due(self, now: 'Optional[float]' = None) -> 'bool':
        pass

    def status(self) -> 'Dict[str, Any]':
        pass

    def stop(self) -> 'None':
        pass


# --- Top-Level Functions ---
def _set_status(engine_id: 'str', state: 'str', progress: 'int' = 0, message: 'str' = '') -> 'None':
    pass

def _get_status(engine_id: 'str') -> 'Dict[str, Any]':
    pass

def _hardware_block_reason(engine_id: 'str') -> 'str':
    pass

def _storage_block_reason(engine_id: 'str', install_root: 'Any') -> 'str':
    pass

def _runtime_sync_pending(engine_id: 'str', install_root: 'Any') -> 'bool':
    pass

def _ensure_storage_location(engine_id: 'str', progress: 'Optional[Callable[[str], None]]' = None, *, exclude_current: 'bool' = False) -> 'None':
    pass

def is_installed(engine_id: 'str') -> 'bool':
    pass

def ensure_engine_blocking(engine_id: 'str', progress: 'Optional[Callable[[str], None]]' = None) -> 'bool':
    pass

def ensure_engine_async(engine_id: 'str') -> 'None':
    pass

def _existing_service_state(resource: 'Dict[str, Any]', port: 'int') -> 'str':
    pass

def _wait_for_existing_service(resource: 'Dict[str, Any]', port: 'int', progress: 'Optional[Callable[[str], None]]' = None) -> 'bool':
    pass

def _watchdog() -> 'None':
    pass

def stop_all_servers() -> 'None':
    pass

def invalidate_engine_server(engine_id: 'str', reason: 'str' = '') -> 'None':
    pass

def touch(engine_id: 'str') -> 'None':
    pass

def request_activity(engine_id: 'str'):
    """Keep a managed TTS server alive for the full HTTP generation call.

    The idle timer starts only after the last active request finishes.  This is
    deliberately independent from request duration: an 8k-character take may
    need much longer than ``VEOFLOW_TTS_IDLE_S`` on consumer hardware."""
    pass

def server_status(engine_id: 'str') -> 'Dict[str, Any]':
    pass

def ensure_engine_server(engine_id: 'str', progress: 'Optional[Callable[[str], None]]' = None) -> 'str':
    pass

def ensure_omni_server(progress=None) -> 'str':
    pass

def omni_touch() -> 'None':
    pass

def stop_omni_server() -> 'None':
    pass

def engine_status(engine_id: 'str') -> 'Dict[str, Any]':
    pass
