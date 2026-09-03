"""
Decompiled / Reconstructed Module: core.dispatch.asset_resolver
Source PyC: asset_resolver.pyc

Docstring:
core/dispatch/asset_resolver.py — R2VAssetResolver implementation.

Extracts character-metadata lazy-upload logic from the ~420-line block in
smart_job_dispatcher._execute_text_video_job (Branch 1.4: character_metadata).

Key improvements over old dispatcher:
- Instance owns _upload_cache and _upload_locks (not a god-object dict).
- _make_cache_key() replaces scattered _get_r2v_asset_cache_id +
  _get_r2v_cache_scope calls. Cache key = scope + asset identity hash.
- R2V-no-fallback invariant is preserved: resolve() raises if
  filtered_metadata is empty after filter_for_scene.
- _refs_scene_scoped bypass is preserved: skips deep filter when the
  dispatcher already scoped refs at Step5.
- Per-account lock prevents duplicate uploads for parallel scenes on the
  same account.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
_MISSING = <object object at 0x00000264D01A9CD0>

# --- Class: R2VAssetResolver ---
class R2VAssetResolver:
    """Implements IR2VAssetResolver.

    resolve() is async so callers can await it.  The real work is sync
    (RuntimeUploadService.upload_ref_to_account) and runs in-thread — the
    same pattern used by strategies (asyncio.to_thread wraps the strategy
    run() which calls resolve() directly, so blocking here is fine).

    Thread-safety:
    - _cache_lock guards _upload_cache reads/writes.
    - _upload_locks provides per (account_key, cache_id) upload serialisation
      so parallel scenes on the same account single-flight the upload."""
    def __init__(self) -> 'None':
        pass

    def invalidate_account(self, *identifiers: 'str') -> 'int':
        pass

    def resolve(self, character_metadata: 'dict', account: 'AccountSlot', scene_payload: 'dict', model_key: 'str', aspect_ratio: 'str') -> 'dict[str, str]':
        """Resolve character_metadata → {char_id: veo3_media_id}.

        Raises if filtered_metadata is empty (R2V-no-fallback invariant)."""
        pass

    def _filter_metadata(self, char_core: 'Any', character_metadata: 'dict', scene_payload: 'dict', model_key: 'str', aspect_ratio: 'str', account: 'AccountSlot') -> 'dict':
        pass

    def _resolve_one(self, char_id: 'str', metadata: 'dict', character_metadata: 'dict', account_email: 'str', profile_name: 'str', account_name: 'str', scope: 'str', aspect_ratio: 'str') -> 'str | None':
        pass

    @staticmethod
    def _do_upload(char_id: 'str', metadata: 'dict', account_email: 'str', account_name: 'str', profile_name: 'str') -> 'str | None':
        pass

    def _get_upload_lock(self, account_key: 'str', cache_id: 'str') -> "__assert_armored__((threading, b'\\x81\\xa9\\x94\\x16W'))":
        pass

    @staticmethod
    def _make_cache_key(scope: 'str', char_id: 'str', metadata: 'dict') -> 'str':
        pass

    @staticmethod
    def _resolve_scope(scene_payload: 'dict') -> 'str':
        pass

    @staticmethod
    def _extract_scene_id(scene_payload: 'dict') -> 'str':
        pass


# --- Top-Level Functions ---
def sole_media_account(uploaded_accounts) -> 'str':
    """Return the single account holding a character's media when cross-upload to the
    OTHER accounts was blocked (policy — e.g. a minor character no account accepts on
    upload) → media exists on exactly ONE account. Returns "" when media is on multiple
    accounts (normal) or none. Lets dispatch pin the scene to the only account that has
    the reference image instead of round-robining to one that lacks it (→ image_policy).
    Shared by master/clone/transcript via the orchestrator submit path."""
    pass
