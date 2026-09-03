"""
Decompiled / Reconstructed Module: services.automation_center.channel_profiles
Source PyC: channel_profiles.pyc

Docstring:
Versioned production settings bound to one verified social channel.

The profile stores production intent only. Browser credentials and login state
remain owned by the publishing profile store; workflow execution remains owned
by Tool 1 adapters. Every saved revision is immutable so an Assignment V2 can
prove exactly which channel settings were compiled into the work order.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['CHANNEL_WORKFLOWS', 'CHANNEL_WORKFLOW_INPUT_MODES', 'ChannelProductionProfileStore', 'normalize_channel_profile']

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
UTC = datetime.timezone.utc
Iterator = typing.Iterator
NAMESPACE_URL = UUID('6ba7b811-9dad-11d1-80b4-00c04fd430c8')
CHANNEL_WORKFLOWS = ('master', 'clone', 'transcript', 'affiliate', 'timemachine')
CHANNEL_WORKFLOW_INPUT_MODES = {'master': ('idea', 'script'), 'clone': ('video_url', 'local_video'), 'transcript': ('text', 'audio_url', 'audio_file'), 'affiliate': ('prepared_product',), 'timemachine': ('idea',)}
_SUPPORTED_PLATFORMS = frozenset({'tiktok', 'youtube', 'facebook'})
_MAX_SNAPSHOT_BYTES = 33554432
_ASSET_POLICY_CATEGORIES = ('characters', 'objects', 'backgrounds')
__all__ = ['CHANNEL_WORKFLOWS', 'CHANNEL_WORKFLOW_INPUT_MODES', 'ChannelProductionProfileStore', 'normalize_channel_profile']

# --- Class: ChannelProductionProfileStore ---
class ChannelProductionProfileStore:
    """SQLite source of truth for immutable per-channel production revisions."""
    def __init__(self, database_path: 'str | Path') -> 'None':
        pass

    def _connect(self) -> "Iterator[__assert_armored__((sqlite3, b'\\x81\\xa6\\x94\\x1bR\\xb4\\xfdR\\xbe&\\xa3'))]":
        pass

    def _initialize(self) -> 'None':
        pass

    def upsert(self, value: 'Mapping[str, Any]') -> 'dict[str, Any]':
        pass

    def get(self, channel_profile_id: 'str', *, version: 'int' = 0) -> 'dict[str, Any]':
        pass

    def find_by_target(self, platform: 'str', channel_id: 'str') -> 'dict[str, Any] | None':
        pass

    def find_by_social_profile(self, platform: 'str', social_profile_id: 'str') -> 'dict[str, Any] | None':
        pass

    def list(self) -> 'list[dict[str, Any]]':
        pass

    def list_versions(self, channel_profile_id: 'str') -> 'list[dict[str, Any]]':
        pass

    def resolve_workflow(self, channel_profile_id: 'str', workflow: 'str', *, version: 'int' = 0) -> 'dict[str, Any]':
        pass

    @staticmethod
    def _row(profile: 'sqlite3.Row', revision: 'sqlite3.Row') -> 'dict[str, Any]':
        pass


# --- Top-Level Functions ---
def _utc_now() -> 'str':
    pass

def _canonical_json(value: 'Any') -> 'str':
    pass

def _json_mapping(value: 'Any', field: 'str') -> 'dict[str, Any]':
    pass

def _bounded_text(value: 'Any', field: 'str', maximum: 'int') -> 'str':
    pass

def _required_id(value: 'Any', field: 'str') -> 'str':
    pass

def _unique_ids(value: 'Any', field: 'str') -> 'list[str]':
    pass

def _normalize_brand(value: 'Any') -> 'dict[str, Any]':
    pass

def _normalize_entities(value: 'Any') -> 'dict[str, Any]':
    pass

def _normalize_asset_policy(value: 'Any') -> 'dict[str, Any]':
    pass

def _normalize_source_policy(value: 'Any') -> 'dict[str, dict[str, Any]]':
    """Normalize per-channel intake permissions without storing live sources.

    Campaign ideas, URLs and files remain work-order data.  This profile layer
    only records which native workflow/mode combinations belong to the channel
    and any JSON-safe defaults that a planner may apply before operator review."""
    pass

def _normalize_workflow_configs(value: 'Any') -> 'dict[str, dict[str, Any]]':
    pass

def _normalize_delivery_defaults(value: 'Any') -> 'dict[str, Any]':
    pass

def normalize_channel_profile(value: 'Mapping[str, Any]') -> 'dict[str, Any]':
    """Return one closed, canonical operational channel snapshot."""
    pass
