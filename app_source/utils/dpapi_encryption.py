"""
Decompiled / Reconstructed Module: utils.dpapi_encryption

Docstring:
License Cache Encryption Module
Uses Fernet (from cryptography library) - cross-platform, no external dependencies

UNIFIED: Thay thế DPAPI + ObfuscatedStorage bằng Fernet duy nhất

MIGRATION SUPPORT: Handles migration from legacy key derivation (uuid.getnode())
to stable key derivation for existing encrypted license caches.
"""

from __future__ import annotations
import sys, os, typing
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
Optional = typing.Optional
Dict = typing.Dict
Tuple = typing.Tuple
_ENCRYPTION_SECRET = b'VEO3_LICENSE_CACHE_2026_FERNET_KEY'
_MIGRATION_MARKER_KEY = '_cache_version'
_CURRENT_CACHE_VERSION = 2
_logger = <Logger utils.dpapi_encryption (WARNING)>
_storage_instance = None
_migration_save_callback = None

# --- Class: FernetStorage ---
class FernetStorage:
    """
    Cross-platform encryption using Fernet (AES-128-CBC + HMAC)
        Key derived from machine info + secret
    
        Supports migration from legacy key derivation (uuid.getnode()) to stable key.
    """
    def __init__(self):
        # [PyArmor BCC constants]: '_fernet', '_fernet_legacy', '_stable_machine_id', '_init_fernet'
        pass

    def _get_stable_machine_id(self) -> str:
        # [PyArmor BCC constants]: '_stable_machine_id', '_logger', 'debug', 'Using cached machine identifier', 'platform', 'system', 'Retrieving stable machine identifier for platform: ', 'Windows', 'Attempting to retrieve Windows MachineGuid from registry', 'OpenKey', 'HKEY_LOCAL_MACHINE', 'SOFTWARE\\Microsoft\\Cryptography', 0, 'KEY_READ', 'KEY_WOW64_64KEY'
        pass

    def _derive_key(self) -> bytes:
        # [PyArmor BCC constants]: '_logger', 'debug', 'Starting encryption key derivation (stable method)', '_get_stable_machine_id', 'platform', 'node', 'machine', '_ENCRYPTION_SECRET', 'decode', '|', 'join', 'hashlib', 'sha256', 'encode', 'hexdigest'
        pass

    def _derive_key_legacy(self) -> bytes:
        # [PyArmor BCC constants]: '_logger', 'debug', 'Starting legacy key derivation (uuid.getnode method)', 'platform', 'node', 'machine', 'str', 'getnode', '_ENCRYPTION_SECRET', 'decode', 'hashlib', 'sha256', '|', 'join', 'encode'
        pass

    def _init_fernet(self):
        # [PyArmor BCC constants]: '_logger', 'debug', 'Initializing Fernet ciphers', 'Fernet', '_derive_key', '_fernet', 'Primary Fernet cipher initialized successfully', '_derive_key_legacy', '_fernet_legacy', 'Legacy Fernet cipher initialized for migration support', 'error', 'cryptography library not available - encryption disabled', 'ImportError', 'Fernet initialization failed (', 'type'
        pass

    @property
    def is_available(self):
        pass

    def encrypt(self, data: bytes) -> Optional[bytes]:
        # [PyArmor BCC constants]: '_fernet', '_logger', 'debug', 'Encryption skipped - Fernet not available', 'encrypt', 'error', 'Encryption failed (', 'type', '__name__', ')', 'Exception'
        pass

    def decrypt(self, encrypted_data: bytes) -> Optional[bytes]:
        # [PyArmor BCC constants]: '_fernet', '_logger', 'debug', 'Decryption skipped - Fernet not available', 'decrypt', 'Decryption failed (', 'type', '__name__', ')', 'Exception'
        pass

    def decrypt_legacy(self, encrypted_data: bytes) -> Optional[bytes]:
        # [PyArmor BCC constants]: '_fernet_legacy', '_logger', 'debug', 'Legacy decryption skipped - legacy Fernet not available', 'decrypt', 'Legacy decryption failed (', 'type', '__name__', ')', 'Exception'
        pass

    def decrypt_with_migration(self, encrypted_data: bytes) -> Tuple[Optional[bytes], bool]:
        # [PyArmor BCC constants]: 'decrypt', False, '_logger', 'debug', 'Primary key failed, attempting legacy key decryption', 'decrypt_legacy', 'info', '[MIGRATION] Successfully decrypted with legacy key - migration needed', True
        pass

    def encrypt_json(self, data: Dict[str, Any]) -> Optional[str]:
        # [PyArmor BCC constants]: '_logger', 'debug', 'Encrypting JSON data', 'json', 'dumps', 'separators', 'encode', 'utf-8', 'encrypt', 'JSON encryption successful', 'base64', 'b64encode', 'decode', 'ascii', 'JSON encryption returned None'
        pass

    def decrypt_json(self, encrypted_b64: str) -> Optional[Dict[str, Any]]:
        # [PyArmor BCC constants]: '_logger', 'debug', 'Decrypting JSON data', 'base64', 'b64decode', 'decrypt', 'JSON decryption successful', 'json', 'loads', 'decode', 'utf-8', 'JSON decryption returned None', 'JSON decryption failed (', 'type', '__name__'
        pass

    def decrypt_json_with_migration(self, encrypted_b64: str) -> Tuple[Optional[Dict[str, Any]], bool]:
        # [PyArmor BCC constants]: 'base64', 'b64decode', 'decrypt_with_migration', 'json', 'loads', 'decode', 'utf-8', '_logger', 'debug', 'JSON decryption with migration failed (', 'type', '__name__', ')', 'Exception'
        pass


# --- Top-Level Functions ---
def get_secure_storage() -> utils.dpapi_encryption.FernetStorage:
    pass

def set_migration_save_callback(callback):
    # [PyArmor BCC constants]: '_migration_save_callback', '_logger', 'debug', 'Migration save callback registered'
    pass

def encrypt_license_cache(data: Dict[str, Any]) -> Optional[str]:
    # [PyArmor BCC constants]: '_logger', 'debug', 'encrypt_license_cache called', 'copy', '_CURRENT_CACHE_VERSION', '_MIGRATION_MARKER_KEY', 'get_secure_storage', 'encrypt_json', 'License cache encryption successful (version %d)', 'error', 'License cache encryption failed'
    pass

def decrypt_license_cache(encrypted_b64: str, save_callback=None) -> Optional[Dict[str, Any]]:
    # [PyArmor BCC constants]: '_logger', 'debug', 'decrypt_license_cache called', 'get_secure_storage', 'decrypt_json_with_migration', 'warning', 'License cache decryption failed with both keys', 'get', '_MIGRATION_MARKER_KEY', 1, '_CURRENT_CACHE_VERSION', 'info', '[MIGRATION] Migrating license cache from version ', ' to ', 'items'
    pass
