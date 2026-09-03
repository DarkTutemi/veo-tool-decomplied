"""
Decompiled / Reconstructed Module: license.hardware_key_derivation

Docstring:
Decompiled / Reconstructed Module: license.hardware_key_derivation

Docstring:
Hardware-Based Key Derivation
Generates encryption keys from hardware fingerprint + server secret
NO HARDCODED KEYS - Keys are derived uniquely per machine
"""

from __future__ import annotations
import sys, os, typing
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
List = typing.List
Optional = typing.Optional
Tuple = typing.Tuple
Union = typing.Union
Callable = typing.Callable
_DEVICE_ID_STORE_VERSION = 1
_DEVICE_ID_PATTERN = re.compile('^[A-Za-z0-9][A-Za-z0-9._:-]{7,190}$')
_key_derivation_instance = None

# --- Class: HardwareKeyDerivation ---
class HardwareKeyDerivation:
    _OEM_PLACEHOLDERS = {'', 'base board serial number', 'n/a', 'none', 'not specified', 'unknown', 'chassis serial number', 'not applicable'}

    def __init__(self, debug: 'bool' = False):
        pass

    def get_hardware_signature(self) -> 'str':
        pass

    def _get_windows_machine_guid(self) -> 'Optional[str]':
        pass

    def _get_windows_product_id(self) -> 'Optional[str]':
        pass

    def _get_macos_hardware_uuid(self) -> 'Optional[str]':
        pass

    def _get_macos_serial_number(self) -> 'Optional[str]':
        pass

    def _get_linux_machine_id(self) -> 'Optional[str]':
        pass

    def _is_placeholder(self, value: 'str') -> 'bool':
        pass

    def _wmi_query(self, wmi_class: 'str', field: 'str') -> 'Optional[str]':
        pass

    def _normalize_hw_value(self, value: 'Optional[str]') -> 'Optional[str]':
        pass

    def _batch_wmi_query(self) -> 'dict':
        pass

    def _get_baseboard_serial(self) -> 'Optional[str]':
        pass

    def _get_bios_serial(self) -> 'Optional[str]':
        pass

    def _get_cpu_processor_id(self) -> 'Optional[str]':
        pass

    def _get_disk_serial(self) -> 'Optional[str]':
        pass

    @staticmethod
    def _normalize_device_id(value) -> 'Optional[str]':
        pass

    def _device_identity_path(self):
        pass

    def _load_persisted_device_id(self) -> 'Optional[str]':
        pass

    def _load_cached_license_device_id(self) -> 'Optional[str]':
        pass

    def _persist_device_id(self, device_id: 'str') -> 'bool':
        pass

    @staticmethod
    def _generate_install_device_id() -> 'str':
        pass

    def get_composite_device_id(self) -> 'str':
        pass

    def _get_smbios_uuid(self) -> 'Optional[str]':
        pass

    def _get_windows_install_date(self) -> 'Optional[str]':
        pass

    def _get_windows_sid(self) -> 'Optional[str]':
        pass

    def get_fingerprint_components(self) -> 'dict':
        pass

    def derive_encryption_keys(self, server_secret: 'str', salt: 'str' = 'ezstream_license_v4') -> 'Tuple[bytes, bytes]':
        pass

    def verify_hardware_not_changed(self, stored_signature: 'str') -> 'bool':
        pass


# --- Top-Level Functions ---
def get_key_derivation(debug: 'bool' = False) -> 'license.hardware_key_derivation.HardwareKeyDerivation':
    pass

def derive_keys_from_hardware_and_server(server_secret: 'str', debug: 'bool' = False) -> 'Tuple[bytes, bytes]':
    pass

def get_composite_device_id(debug: 'bool' = False) -> 'str':
    pass

def get_fingerprint_for_server(debug: 'bool' = False) -> 'dict':
    pass

def get_device_identity(debug: 'bool' = False) -> 'dict':
    pass
