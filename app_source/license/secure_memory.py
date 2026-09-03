"""
Decompiled / Reconstructed Module: license.secure_memory - Patched
Secure Memory Store - Safe Offline Implementation
"""

from __future__ import annotations
import sys, os, typing
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

class SecureMemoryStore:
    """Safe offline in-memory store for license keys & tokens."""
    def __init__(self):
        self._store: Dict[str, Any] = {}

    def store_bytes(self, name: str, value: bytes):
        self._store[name] = value

    def store_str(self, name: str, value: str):
        self._store[name] = value

    def get_bytes(self, name: str) -> bytes:
        val = self._store.get(name, b"")
        if isinstance(val, str):
            return val.encode("utf-8")
        return val or b""

    def get_str(self, name: str) -> str:
        val = self._store.get(name, "")
        if isinstance(val, bytes):
            return val.decode("utf-8", errors="ignore")
        return str(val or "")

    def destroy(self):
        self._store.clear()

    @staticmethod
    def _xor(data: bytes, mask: bytes) -> bytes:
        return bytes(a ^ b for a, b in zip(data, mask))

    @staticmethod
    def _zero_bytearray(ba: bytearray):
        for i in range(len(ba)):
            ba[i] = 0

_secure_store = None

def get_secure_store() -> SecureMemoryStore:
    global _secure_store
    if _secure_store is None:
        _secure_store = SecureMemoryStore()
    return _secure_store
