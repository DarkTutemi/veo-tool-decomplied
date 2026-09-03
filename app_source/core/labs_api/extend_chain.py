"""
Decompiled / Reconstructed Module: core.labs_api.extend_chain
Source PyC: extend_chain.pyc

Docstring:
core/labs_api/extend_chain.py — extend-chain state + helpers (relocated, Phase O).

ExtendChainManager holds *live mutable state* (per-chain project/scene/session
ids, video paths, concat inputs) behind a process singleton. Relocated verbatim
from the api_client god-file; the singleton lives here now so callers import
from labs_api and there is exactly ONE instance.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
List = typing.List
Optional = typing.Optional
_extend_chain_manager = None
_manager_lock = <unlocked _thread.lock object at 0x00000264DC05D300>

# --- Class: ExtendChainManager ---
class ExtendChainManager:
    """Global manager for extend video chains

    Tracks which worker is handling each extend chain to ensure
    all extends in a chain use the same worker (same mediaId context).

    NEW: Also tracks Project/Scene for Labs integration and concat data."""
    def __init__(self):
        pass

    def create_chain(self, chain_id: 'str', initial_media_id: 'str', worker_id: 'str', max_extends: 'int' = 80, session_id: 'str' = None) -> 'None':
        pass

    def get_chain_worker(self, chain_id: 'str') -> 'Optional[str]':
        pass

    def update_chain(self, chain_id: 'str', new_media_id: 'str', root_card_index: 'Optional[int]' = None) -> 'bool':
        """Update chain with new mediaId after successful extend

        Args:
            chain_id: Chain identifier
            new_media_id: New mediaId from the extended video
            root_card_index: Optional root card index to update last_media_by_root

        Returns:
            True if update successful, False if chain not found or max extends reached"""
        pass

    def get_chain_info(self, chain_id: 'str') -> 'Optional[Dict]':
        pass

    def update_initial_media_id(self, chain_id: 'str', media_id: 'str') -> 'bool':
        pass

    def update_chain_project(self, chain_id: 'str', project_id: 'str') -> 'bool':
        pass

    def set_scene_id(self, chain_id: 'str', scene_id: 'str') -> 'bool':
        pass

    def get_scene_id(self, chain_id: 'str') -> 'Optional[str]':
        pass

    def set_workflow_id(self, chain_id: 'str', workflow_id: 'str') -> 'bool':
        pass

    def get_workflow_id(self, chain_id: 'str') -> 'Optional[str]':
        pass

    def add_clip_to_chain(self, chain_id: 'str', clip: 'Dict', concat_input: 'Dict') -> 'bool':
        pass

    def insert_clip_at_position(self, chain_id: 'str', position: 'int', clip: 'Dict', concat_input: 'Dict') -> 'bool':
        pass

    def remove_clip_at_position(self, chain_id: 'str', position: 'int') -> 'bool':
        pass

    def get_clips(self, chain_id: 'str') -> 'List[Dict]':
        pass

    def get_concat_inputs(self, chain_id: 'str') -> 'List[Dict]':
        pass

    def get_clip_count(self, chain_id: 'str') -> 'int':
        pass

    def get_media_id_at_position(self, chain_id: 'str', position: 'int') -> 'Optional[str]':
        pass

    def set_concat_status(self, chain_id: 'str', operation_name: 'str' = None, status: 'str' = None, output_path: 'str' = None) -> 'bool':
        pass

    def set_session_id(self, chain_id: 'str', session_id: 'str') -> 'bool':
        pass

    def get_session_id(self, chain_id: 'str') -> 'Optional[str]':
        pass

    def set_root_card_index(self, chain_id: 'str', root_card_index: 'int') -> 'bool':
        pass

    def add_video_path(self, chain_id: 'str', video_path: 'str') -> 'bool':
        pass

    def get_video_paths(self, chain_id: 'str') -> 'List[str]':
        pass

    def add_fife_url(self, chain_id: 'str', fife_url: 'str') -> 'bool':
        pass

    def get_fife_urls(self, chain_id: 'str') -> 'List[str]':
        pass

    def get_last_fife_url(self, chain_id: 'str') -> 'Optional[str]':
        pass

    def set_last_frame_media_id(self, chain_id: 'str', media_id: 'str') -> 'bool':
        pass

    def get_last_frame_media_id(self, chain_id: 'str') -> 'Optional[str]':
        pass

    def can_extend(self, chain_id: 'str') -> 'bool':
        pass

    def remove_chain(self, chain_id: 'str') -> 'None':
        pass

    def update_root_media_id(self, chain_id: 'str', position: 'int', media_id: 'str') -> 'bool':
        pass

    def update_last_media_for_root(self, chain_id: 'str', root_card_index: 'int', media_id: 'str') -> 'bool':
        pass

    def get_last_media_for_root(self, chain_id: 'str', root_card_index: 'int') -> 'Optional[str]':
        pass


# --- Top-Level Functions ---
def get_extend_chain_manager() -> 'ExtendChainManager':
    pass

def ensure_project_and_scene_for_chain(chain_id: 'str', initial_media_id: 'str', root_prompt: 'str', account_name: 'str' = None, main_window=None) -> 'bool':
    pass
