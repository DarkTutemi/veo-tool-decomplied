"""
Decompiled / Reconstructed Module: core.local_ports
Source PyC: local_ports.pyc

Docstring:
Single source of truth for VeoFlow-owned localhost ports.

Only services started/owned by VeoFlow belong here. User-provided external
servers (Ollama, external speech endpoints, external OmniVoice, etc.) are not
reserved because VeoFlow does not control their ports.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
LOCAL_SERVICE_PORTS = {'tts_vieneu': 8766, 'tts_moss': 8767, 'tts_omnivoice': 8768, 'tts_moss_nano': 8769, 'affiliate_panel_ws': 47821}
VIENEU_TTS_PORT = 8766
MOSS_TTS_PORT = 8767
OMNIVOICE_TTS_PORT = 8768
MOSS_NANO_TTS_PORT = 8769
AFFILIATE_PANEL_WS_PORT = 47821
_assignment_lock = <unlocked _thread.RLock object owner=0 count=0 at 0x00000264D8E21B80>
_runtime_assignments = {}
_PORT_SCAN_SPAN = 128

# --- Top-Level Functions ---
def _persisted_assignments() -> 'dict[str, int]':
    pass

def _save_assignments(assignments: 'Mapping[str, int]') -> 'None':
    pass

def port_is_available(port: 'int', host: 'str' = '127.0.0.1') -> 'bool':
    pass

def managed_port_preferences(owner: 'str', preferred: 'int | None' = None) -> 'tuple[int, ...]':
    pass

def select_available_managed_port(owner: 'str', preferred: 'int | None' = None, *, excluded: 'set[int] | None' = None) -> 'int':
    pass

def remember_managed_port(owner: 'str', port: 'int') -> 'int':
    pass

def duplicate_default_ports(ports: 'Mapping[str, int] | None' = None) -> 'dict[int, tuple[str, ...]]':
    pass

def assert_unique_default_ports() -> 'None':
    pass

def validate_port_assignment(owner: 'str', port: 'int') -> 'int':
    pass

def env_port(owner: 'str', env_name: 'str', *, environ: 'Mapping[str, str] | None' = None) -> 'int':
    pass

def local_port_in_use(port: 'int', host: 'str' = '127.0.0.1') -> 'bool':
    pass
