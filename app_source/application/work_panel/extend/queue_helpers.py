"""
Decompiled / Reconstructed Module: application.work_panel.extend.queue_helpers
Source PyC: queue_helpers.pyc

Docstring:
Pure helpers for the Extend queue service (extracted from extend_service.py).

Module-level functions + shared constants used by ExtendQueueService. Behaviour copied
verbatim; re-exported from application.extend_service so the public import surface holds.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
List = typing.List
_DEFAULT_SESSION_KEY = 'extend_work'
_STOPPED_BY_USER = 'stopped_by_user'

# --- Top-Level Functions ---
def _extend_prompt_to_veo_text(prompt: 'Any', card_type: 'str' = '') -> 'str':
    pass

def _blocked(action: 'str', code: 'str', message: 'str', **details: 'Any') -> 'Dict[str, Any]':
    pass

def _session_key(value: 'str | None' = None) -> 'str':
    pass

def _execution_mode(payload: 'Dict[str, Any]', config: 'Dict[str, Any]') -> 'str':
    pass

def _prompt_item(card: 'Dict[str, Any]', index: 'int' = 0) -> 'SimpleNamespace':
    pass

def _extend_dispatch_fields(config: 'Dict[str, Any]') -> 'Dict[str, Any]':
    pass

def _extend_feature_for_card(card: 'Dict[str, Any]') -> 'str':
    pass

def _resolve_extend_card_model(card_type: 'str', mode: 'str', quality_mode: 'str', is_portrait: 'bool', tier_mode: 'str' = 'ultra') -> 'tuple[str, Dict[str, Any] | None]':
    pass

def _extend_output_stem(card: 'Dict[str, Any]') -> 'str':
    pass

def _enrich_extend_card(card: 'Dict[str, Any]', dispatch_fields: 'Dict[str, Any]') -> 'Dict[str, Any]':
    """Fill the dispatch fields on a card from config, without clobbering values the
    card already carries (a card may have its own aspect/model from per-card editing).

    Also maps the card's chain fields to the keys the dispatch orchestrator reads to
    resolve each clip's input from the previous clip's output
    (``RegenService.lookup_previous_media_id`` matches on extend_chain_id +
    extend_position + root_card_index across job meta):
      • extend_chain_id = the chain's root id (shared by every card in the chain)
      • extend_position = 0 for ROOT, 1.. for each EXTEND segment
      • root_card_index = 0-based chain group index (media-lookup key; keep stable)
      • extend_filename / desired_filenames = 1 / 1.1 / 1.2 / 2 / 2.1 … (on-disk names)
    The worker later chooses and stamps either native Extend or a same-account
    last-frame I2V fallback."""
    pass

def _text(value: 'Any') -> 'str':
    pass

def _safe_dict(value: 'Any') -> 'Dict[str, Any]':
    pass

def _safe_list(value: 'Any') -> 'List[Any]':
    pass

def _batch_to_row(batch: 'Any') -> 'Dict[str, Any]':
    pass

def _status_value(status: 'Any') -> 'str':
    pass

def _history_status(batch_status: 'str') -> 'str':
    pass

def _batch_cards(batch: 'Any') -> 'list[dict[str, Any]]':
    pass

def _core_dispatch_jobs(dispatcher_job_ids: 'List[Any]') -> 'List[Dict[str, Any]]':
    pass

def _scene_result_from_job(job: 'Dict[str, Any]') -> 'Dict[str, Any]':
    pass

def _aggregate_dispatch_jobs(dispatcher_job_ids: 'List[Any]') -> 'Dict[str, Any]':
    pass

def _ensure_extend_session_folder(config: 'Dict[str, Any]', session_key: 'str' = '') -> 'str':
    """Moi luot dispatch extend = 1 session subfolder (parity PyQt).

    Khi truyen ``session_key`` (path chain auto-advance cua extend): neu session do
    DA co ``session_folder`` (do batch dau tien trong chain tao ra), tai dung no cho
    MOI segment ke tiep -> ca chain do vao cung 1 folder thay vi moi clip 1 folder.
    Folder moi chi duoc tao o batch dau tien va persist tro lai vao session state.

    No-op khi config khong co output_folder goc (giu hanh vi mac dinh cua
    dispatcher); loi tao folder khong duoc chan viec submit job."""
    pass

def _common_output_folder(rows: 'list[dict[str, Any]]') -> 'str':
    pass

def _snapshot_extra(snapshot: 'Dict[str, Any]') -> 'Dict[str, Any]':
    pass

def _timeline_from_snapshot(snapshot: 'Dict[str, Any]') -> 'list[dict[str, Any]]':
    pass

def _cards_data_from_snapshot(snapshot: 'Dict[str, Any]') -> 'list[dict[str, Any]]':
    pass

def _title_from_prompt(prompt: 'str', fallback: 'str') -> 'str':
    pass

def _restore_card_from_timeline_entry(entry: 'Dict[str, Any]', *, session_key: 'str', card_type: 'str', chain_index: 'int', position_in_chain: 'int', chain_root_id: 'str') -> 'Dict[str, Any]':
    pass

def _restored_cards_from_timeline(snapshot: 'Dict[str, Any]', session_key: 'str') -> 'list[dict[str, Any]]':
    pass

def _restored_cards_from_legacy_cards(snapshot: 'Dict[str, Any]', session_key: 'str') -> 'list[dict[str, Any]]':
    pass
