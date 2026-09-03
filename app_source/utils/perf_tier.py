"""
Decompiled / Reconstructed Module: utils.perf_tier

Docstring:
Auto perf tier: quyết định UI motion mà KHÔNG cần user bật/tắt thủ công.

Tín hiệu (fail-open → máy còn tốt thì animation đầy đủ):
- GPU: quét registry display adapters (chỉ ``pci\ven_``, lọc virtual display
  như UltraViewer/Parsec — cùng cách services/shared/tts/engines/hardware_gate).
  Không có adapter PCI nào / desc chứa "basic render" → Qt đã rơi vào WARP
  (software D3D) → đây là trường hợp full CPU/GPU khi vẽ gradient động.
- RAM tổng + số core CPU.

Quyết định tắt motion (VfTheme.motion=false, infinite animation bỏ):
- probe fail hoặc WARP/basic-render, HOẶC
- chỉ iGPU (không NVIDIA, VRAM < 2GB) kèm RAM < 8GB hoặc cores <= 4, HOẶC
- RAM < 4GB.
Con lại: giữ nguyên mọi hiệu ứng. Probe chỉ vài ms winreg nên chạy mỗi boot,
file JSON trong %APPDATA%/VEO3_Generator_Pro là audit trail cho support,
KHÔNG dùng làm verdict dính (tránh sai sau khi user nâng cấp máy).

Env override (chỉ dành dev/support, user thường không cần biết):
- ``VEOFLOW_LOW_POWER=1`` ép tắt motion luôn thắng.
- ``VEOFLOW_FORCE_MOTION=1`` ép bật (thua VEOFLOW_LOW_POWER khi conflict).
"""

from __future__ import annotations
import sys, os, typing
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
_DISPLAY_CLASS_KEY = 'SYSTEM\\CurrentControlSet\\Control\\Class\\{4d36e968-e325-11ce-bfc1-08002be10318}'
_NVIDIA_VENDOR_PREFIX = 'pci\\ven_10de'
_DGPU_MIN_VRAM_GB = 2.0
_LOW_RAM_GB = 8.0
_CRITICAL_RAM_GB = 4.0
_LOW_CORES = 4
_WARP_MARKERS = ('basic render', 'basicrender')
_CACHE_FILENAME = 'perf_tier.json'
_DISPATCH_SLOTS_LOW_TIER = 2
_DISPATCH_SLOTS_HIGH_TIER = 5

# --- Class: PerfTierVerdict ---
class PerfTierVerdict:
    """PerfTierVerdict(motion_enabled: 'bool', tier: 'str', reason: 'str', metrics: 'Dict[str, Any]')"""
    def to_dict(self) -> 'Dict[str, Any]':
        # [PyArmor BCC constants]: 'tier', 'reason', 'metrics', 'dict'
        pass

    def __init__(self, motion_enabled: 'bool', tier: 'str', reason: 'str', metrics: 'Dict[str, Any]') -> None:
        pass

    def __repr__(self):
        pass


# --- Top-Level Functions ---
def _env_truthy(name: 'str') -> 'bool':
    # [PyArmor BCC constants]: 'os', 'environ', 'get', '', 'strip', 'lower', '1', 'on', 'yes', 'true'
    pass

def _read_ram_gb() -> 'float':
    """RAM TỔNG GB; 0.0 = không dò được (bỏ qua rule RAM). Cùng nguồn env_gate."""
    pass

def _detect_gpu() -> 'Dict[str, Any]':
    """
    GPU inventory rẻ từ registry, không WMI/subprocess.
    
        Trả về dict probe_ok/gpu/vram_gb/warp — fail-open nếu không đọc được.
    """
    # [PyArmor BCC constants]: 'probe_ok', 'gpu', 'vram_gb', 'nvidia', 'warp'
    pass

def resolve_perf_tier() -> 'PerfTierVerdict':
    # [PyArmor BCC constants]: '_env_truthy', 'VEOFLOW_LOW_POWER', 'VEOFLOW_FORCE_MOTION', 'low', 'high', 'VEOFLOW_LOW_POWER=1 (ép tắt motion)', 'VEOFLOW_FORCE_MOTION=1 (ép bật motion)', 'PerfTierVerdict', 'motion_enabled', 'tier', 'reason', 'metrics', 'env_forced', True, '_detect_gpu'
    pass

def _cache_path() -> 'str | None':
    # [PyArmor BCC constants]: 'os', 'environ', 'get', 'APPDATA', 'path', 'join', 'VEO3_Generator_Pro', '_CACHE_FILENAME'
    pass

def write_verdict_cache(verdict: 'PerfTierVerdict') -> 'None':
    # [PyArmor BCC constants]: '_cache_path', 'datetime', 'timezone', 'version', 'ts', 'motion_enabled', 1, 'now', 'utc', 'isoformat', 'bool', 'to_dict', 'os', 'path', 'dirname'
    pass

def _safe_print(text: 'str') -> 'None':
    # [PyArmor BCC constants]: 'print', 'flush', True, 'encode', 'ascii', 'replace', 'decode', 'UnicodeEncodeError'
    pass

def perf_motion_enabled() -> 'bool':
    """Một hàm duy nhất mà entrypoint cần gọi trước khi load QML."""
    pass

def job_slots_default() -> 'int':
    # [PyArmor BCC constants]: 'os', 'environ', 'get', 'VEOFLOW_JOB_SLOTS', '', 'strip', 'isdigit', 'max', 1, 'min', '_DISPATCH_SLOTS_HIGH_TIER', 'int', 'resolve_perf_tier', 'tier', 'low'
    pass
