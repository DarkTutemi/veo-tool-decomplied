"""
Decompiled / Reconstructed Module: services.shared.tts.engines.hardware_gate
Source PyC: hardware_gate.pyc

Docstring:
Gate phần cứng cho TTS local — chặn tải/chạy engine vượt sức máy.

Các engine không cùng trọng lượng:

* VieNeu có đường CPU/int8 và là engine nhẹ nhất.
* OmniVoice cần NVIDIA/CUDA để có tốc độ dùng được trong pipeline dài.
* MOSS-TTS Local v1.5 là model 4B, cần NVIDIA + VRAM/RAM/disk cao hơn hẳn.

Gate phán 3 mức để UI vừa chặn được, vừa cảnh báo được:

  blocked — coi như không chạy nổi: thiếu AVX2 (CPU đời trước ~2013), < 4 nhân
            logic, RAM tổng < 8 GB. Hoặc: KHÔNG có card rời MÀ cấu hình còn ở
            mức vừa đủ (< 6 nhân hoặc < 12 GB) — CPU-only trên máy đó quá chậm.
  warn    — chạy được nhưng chậm: không card rời (iGPU), hoặc cấu hình vừa đủ.
  ok      — đủ sức.

API ``local_tts_verdict()`` giữ verdict chung để tương thích. Mọi engine phải gọi
``engine_tts_verdict(engine_id)``; provisioning gọi thêm
``local_tts_storage_availability`` trong worker trước khi tải.

Ràng buộc: ``availability()`` được gọi trên UI THREAD khi build dropdown, nên mọi
phép dò phải rẻ và cache. Đo thật: AVX2 0.01ms, GPU (registry) 0.11ms — không
dùng WMI/PowerShell (hàng trăm ms). Kết quả cache theo process.

Fail-open chỉ áp dụng cho gate chung/VieNeu. Engine CUDA mà không xác nhận được
NVIDIA/VRAM sẽ bị chặn an toàn thay vì kéo hàng chục GB rồi mới crash.

Escape:   VEOFLOW_TTS_LOCAL_FORCE=1        — bỏ qua gate, luôn cho chạy
Test/QA:  VEOFLOW_TTS_LOCAL_HW=blocked|warn|ok  — ép verdict để test UI

Chẩn đoán trên máy khách (in verdict + số đo thật):
  python -c "import json; from services.shared.tts.engines import local_tts_verdict; print(json.dumps(local_tts_verdict().to_dict(), ensure_ascii=False))"
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
Tuple = typing.Tuple
MIN_CORES = 4
MIN_RAM_GB = 8.0
MARGINAL_CORES = 6
MARGINAL_RAM_GB = 12.0
DGPU_MIN_VRAM_GB = 2.0
ENGINE_REQUIREMENTS = {'vieneu': {'label': 'VieNeu', 'min_cores': 4, 'min_ram_gb': 8.0, 'min_vram_gb': 0.0, 'recommended_vram_gb': 0.0, 'requires_nvidia': False, 'min_free_disk_gb': 6.0}, 'omnivoice': {'label': 'OmniVoice'... [truncated]
_NVIDIA_VENDOR = 'ven_10de'
_DISPLAY_CLASS = 'SYSTEM\\CurrentControlSet\\Control\\Class\\{4d36e968-e325-11ce-bfc1-08002be10318}'
_lock = <unlocked _thread.RLock object owner=0 count=0 at 0x00000264D8ED2E40>
_cached = None
_engine_cached = {}

# --- Class: HardwareVerdict ---
class HardwareVerdict:
    """HardwareVerdict(tier: 'str', reason: 'str' = '', warning: 'str' = '', metrics: 'Dict[str, Any]' = <factory>)"""
    reason = ''
    warning = ''
    ok = <property object at 0x00000264E48B0950>

    def to_dict(self) -> 'Dict[str, Any]':
        pass

    def __init__(self, tier: 'str', reason: 'str' = '', warning: 'str' = '', metrics: 'Dict[str, Any]' = <factory>) -> None:
        pass

    def __repr__(self):
        pass


# --- Top-Level Functions ---
def _env_truthy(name: 'str') -> 'bool':
    pass

def _has_avx2() -> 'bool | None':
    pass

def _read_ram_gb() -> 'float':
    pass

def _read_display_adapter(winreg: 'Any', root: 'Any', subkey: 'str') -> 'tuple[str, str, float] | None':
    pass

def _detect_gpu_details() -> 'Dict[str, Any]':
    pass

def _detect_dgpu() -> 'Tuple[bool, str]':
    pass

def _evaluate() -> 'HardwareVerdict':
    pass

def local_tts_verdict(*, refresh: 'bool' = False) -> 'HardwareVerdict':
    pass

def _engine_forced_verdict(engine_id: 'str') -> 'HardwareVerdict | None':
    pass

def _evaluate_engine(engine_id: 'str') -> 'HardwareVerdict':
    pass

def engine_tts_verdict(engine_id: 'str', *, refresh: 'bool' = False) -> 'HardwareVerdict':
    pass

def peek_engine_tts_verdict(engine_id: 'str') -> 'HardwareVerdict | None':
    pass

def prewarm_engine_tts_verdicts() -> 'Dict[str, HardwareVerdict]':
    pass

def local_tts_storage_availability(engine_id: 'str', install_root: 'str | os.PathLike[str]') -> 'Tuple[bool, str, Dict[str, Any]]':
    pass

def local_tts_availability(engine_id: 'str' = '') -> 'Tuple[bool, str]':
    pass
