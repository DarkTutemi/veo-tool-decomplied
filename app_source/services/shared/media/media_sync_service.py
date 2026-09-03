"""
Decompiled / Reconstructed Module: services.shared.media.media_sync_service
Source PyC: media_sync_service.pyc

Docstring:
Media Sync Service — Proactive background sync.
Keeps all media library items uploaded to all live accounts.
veo3_id luôn sẵn sàng → không cần lazy upload khi job chạy.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
_instance = None
_lock = <unlocked _thread.lock object at 0x00000264E16377C0>

# --- Class: MediaSyncService ---
class MediaSyncService(Thread):
    """Background daemon that periodically syncs all media to all live accounts."""
    def __init__(self, interval_minutes: int = 10, initial_delay: int = 30):
        pass

    def stop(self):
        pass

    def is_alive(self):
        pass

    def run(self):
        pass

    def _sweep(self):
        """One full sweep: upload missing media to all live accounts."""
        pass


# --- Top-Level Functions ---
def start_media_sync(interval_minutes: int = 10, initial_delay: int = 30):
    pass
