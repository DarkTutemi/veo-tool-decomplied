"""
Decompiled / Reconstructed Module: license.hardware_key_derivation

Docstring:
Hardware-Based Key Derivation
Generates encryption keys from hardware fingerprint + server secret
NO HARDCODED KEYS - Keys are derived uniquely per machine
"""

from __future__ import annotations
import sys, os, typing, re
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
Optional = typing.Optional
Tuple = typing.Tuple
_DEVICE_ID_STORE_VERSION = 1
_DEVICE_ID_PATTERN = re.compile('^[A-Za-z0-9][A-Za-z0-9._:-]{7,190}$')
_key_derivation_instance = None

# --- Class: HardwareKeyDerivation ---
class HardwareKeyDerivation:
    _OEM_PLACEHOLDERS = {'', 'unknown', 'none', 'chassis serial number', 'n/a', 'not applicable', 'base board serial number', 'not specified'}

    def __init__(self, debug: bool = False):
        # [PyArmor BCC constants]: 'debug', 'threading', 'RLock', '_device_id_lock'
        pass

    def get_hardware_signature(self) -> str:
        # [PyArmor BCC constants]: 'platform', 'system', 'Windows', '_get_windows_machine_guid', 'Darwin', '_get_macos_hardware_uuid', '_get_linux_machine_id', 'append', 'GUID:', 'processor', 'CPU:', 'uuid', 'getnode', 'MAC:', 'node'
        pass

    def _get_windows_machine_guid(self) -> Optional[str]:
        # [PyArmor BCC constants]: 'platform', 'system', 'Windows', 'OpenKey', 'HKEY_LOCAL_MACHINE', 'SOFTWARE\\Microsoft\\Cryptography', 'QueryValueEx', 'MachineGuid', 'CloseKey', 'len', 36, 'debug', 'print', '⚠️ Could not read Machine GUID: ', 'Exception'
        pass

    def _get_windows_product_id(self) -> Optional[str]:
        # [PyArmor BCC constants]: 'platform', 'system', 'Windows', 'OpenKey', 'HKEY_LOCAL_MACHINE', 'SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion', 'QueryValueEx', 'ProductId', 'CloseKey', 'debug', 'print', '⚠️ Could not read Product ID: ', 'Exception'
        pass

    def _get_macos_hardware_uuid(self) -> Optional[str]:
        # [PyArmor BCC constants]: 'platform', 'system', 'Darwin', 'subprocess', 'run', 'ioreg', '-d2', '-c', 'IOPlatformExpertDevice', 'capture_output', True, 'text', 'timeout', 5, 'returncode'
        pass

    def _get_macos_serial_number(self) -> Optional[str]:
        # [PyArmor BCC constants]: 'platform', 'system', 'Darwin', 'subprocess', 'run', 'system_profiler', 'SPHardwareDataType', 'capture_output', True, 'text', 'timeout', 10, 'returncode', 0, 'search'
        pass

    def _get_linux_machine_id(self) -> Optional[str]:
        # [PyArmor BCC constants]: 'platform', 'system', 'Linux', '/etc/machine-id', 'os', 'path', 'exists', 'open', 'r', 'read', 'strip', '/var/lib/dbus/machine-id', 'debug', 'print', '⚠️ Could not read Linux Machine ID: '
        pass

    def _is_placeholder(self, value: str) -> bool:
        pass

    def _wmi_query(self, wmi_class: str, field: str) -> Optional[str]:
        # [PyArmor BCC constants]: 'Get-CimInstance -ClassName ', ' | Select-Object -ExpandProperty ', ' -First 1', 'subprocess', 'run', 'powershell', '-Command', 'capture_output', True, 'text', 'timeout', 10, 'creationflags', 'platform', 'system'
        pass

    def _normalize_hw_value(self, value: Optional[str]) -> Optional[str]:
        # [PyArmor BCC constants]: 'str', 'strip', '_is_placeholder', 'upper'
        pass

    def _batch_wmi_query(self) -> dict:
        # [PyArmor BCC constants]: 'hasattr', '_cached_wmi_parts', 'dict', '$bb = (Get-CimInstance Win32_BaseBoard).SerialNumber; $bi = (Get-CimInstance Win32_BIOS).SerialNumber; $cp = (Get-CimInstance Win32_Processor).ProcessorId; $dk = (Get-CimInstance Win32_DiskDrive | Sort-Object Index | Select-Object -First 1).SerialNumber; "BB=$bb`nBIOS=$bi`nCPU=$cp`nDISK=$dk"', 'subprocess', 'run', 'powershell', '-NoProfile', '-Command', 'capture_output', True, 'text', 'timeout', 15, 'creationflags'
        pass

    def _get_baseboard_serial(self) -> Optional[str]:
        pass

    def _get_bios_serial(self) -> Optional[str]:
        pass

    def _get_cpu_processor_id(self) -> Optional[str]:
        pass

    def _get_disk_serial(self) -> Optional[str]:
        # [PyArmor BCC constants]: 'Get-CimInstance -ClassName Win32_DiskDrive | Sort-Object Index | Select-Object -First 1 -ExpandProperty SerialNumber', 'subprocess', 'run', 'powershell', '-Command', 'capture_output', True, 'text', 'timeout', 10, 'creationflags', 'platform', 'system', 'Windows', 'CREATE_NO_WINDOW'
        pass

    @staticmethod
    def _normalize_device_id(value) -> Optional[str]:
        # [PyArmor BCC constants]: 'str', '', 'strip', '_DEVICE_ID_PATTERN', 'fullmatch'
        pass

    def _device_identity_path(self):
        pass

    def _load_persisted_device_id(self) -> Optional[str]:
        # [PyArmor BCC constants]: '_device_identity_path', 'exists', 'json', 'loads', 'read_text', 'encoding', 'utf-8', 'isinstance', 'dict', 'get', 'encrypted', 'get_secure_storage', 'decrypt_json', 'version', '_DEVICE_ID_STORE_VERSION'
        pass

    def _load_cached_license_device_id(self) -> Optional[str]:
        # [PyArmor BCC constants]: 'get_json_license_cache_manager', 'get_license_data', 'isinstance', 'dict', '_normalize_device_id', 'get', 'device_id', 'debug', 'print', '[DEVICE-ID] Could not migrate cached identity: ', 'type', '__name__', 'Exception'
        pass

    def _persist_device_id(self, device_id: str) -> bool:
        # [PyArmor BCC constants]: '_normalize_device_id', False, 'get_secure_storage', 'encrypt_json', 'version', 'device_id', '_DEVICE_ID_STORE_VERSION', '_device_identity_path', 'parent', 'mkdir', 'parents', True, 'exist_ok', 'with_name', '.'
        pass

    @staticmethod
    def _generate_install_device_id() -> str:
        # [PyArmor BCC constants]: 'uuid', 'uuid4', 'hex', 'upper'
        pass

    def get_composite_device_id(self) -> str:
        # [PyArmor BCC constants]: '_device_id_lock', '_normalize_device_id', 'getattr', '_cached_device_id', '_load_persisted_device_id', '_load_cached_license_device_id', '_persist_device_id', '_generate_install_device_id'
        pass

    def _get_smbios_uuid(self) -> Optional[str]:
        # [PyArmor BCC constants]: 'platform', 'system', 'Windows', 'subprocess', 'run', 'powershell', '-Command', 'Get-CimInstance -ClassName Win32_ComputerSystemProduct | Select-Object -ExpandProperty UUID', 'capture_output', True, 'text', 'timeout', 10, 'creationflags', 'CREATE_NO_WINDOW'
        pass

    def _get_windows_install_date(self) -> Optional[str]:
        # [PyArmor BCC constants]: 'platform', 'system', 'Windows', 'OpenKey', 'HKEY_LOCAL_MACHINE', 'SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion', 'QueryValueEx', 'InstallDate', 'CloseKey', 'str', 'debug', 'print', '⚠️ Could not read Install Date: ', 'Exception'
        pass

    def _get_windows_sid(self) -> Optional[str]:
        # [PyArmor BCC constants]: 'platform', 'system', 'Windows', 'subprocess', 'run', 'whoami', '/user', 'capture_output', True, 'text', 'timeout', 10, 'creationflags', 'CREATE_NO_WINDOW', 0
        pass

    def get_fingerprint_components(self) -> dict:
        # [PyArmor BCC constants]: 'platform', 'system', 'Windows', '_batch_wmi_query', 'BB', 'BIOS', 'CPU', 'DISK', '_normalize_hw_value', '_get_baseboard_serial', '_get_bios_serial', '_get_cpu_processor_id', '_get_disk_serial', 'get', 'baseboard_serial'
        pass

    def derive_encryption_keys(self, server_secret: str, salt: str = 'ezstream_license_v4') -> Tuple[bytes, bytes]:
        # [PyArmor BCC constants]: 'get_hardware_signature', '|', 'PBKDF2', 'encode', 'dkLen', 64, 'count', 100000, 'hmac_hash_module', 'SHA256', 32, 'debug', 'print', '🔒 [KEY-DERIVATION] Keys derived successfully', '   Encryption Key: '
        pass

    def verify_hardware_not_changed(self, stored_signature: str) -> bool:
        # [PyArmor BCC constants]: 'get_hardware_signature', 'debug', 'print', '🚨 [KEY-DERIVATION] Hardware signature mismatch!', '   Stored:  ', 16, '...', '   Current: '
        pass


# --- Top-Level Functions ---
def get_key_derivation(debug: bool = False) -> license.hardware_key_derivation.HardwareKeyDerivation:
    # [PyArmor BCC constants]: '_key_derivation_instance', 'HardwareKeyDerivation', 'debug'
    pass

def derive_keys_from_hardware_and_server(server_secret: str, debug: bool = False) -> Tuple[bytes, bytes]:
    pass

def get_composite_device_id(debug: bool = False) -> str:
    pass

def get_fingerprint_for_server(debug: bool = False) -> dict:
    pass

def get_device_identity(debug: bool = False) -> dict:
    # [PyArmor BCC constants]: 'get_key_derivation', 'debug', 'get_fingerprint_components', 'get_composite_device_id', 'sorted', 'keys', 'get', 'str', 'strip', 'append', ':', '|', 'join', 'device_id:', 'hashlib'
    pass