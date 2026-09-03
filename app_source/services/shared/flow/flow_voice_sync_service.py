"""
Decompiled / Reconstructed Module: services.shared.flow.flow_voice_sync_service
Source PyC: flow_voice_sync_service.pyc

Docstring:
Sync Flow voice blueprints to account-scoped generated voice workflows.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Callable = typing.Callable
Dict = typing.Dict
Iterable = typing.Iterable
Optional = typing.Optional
FLOW_VOICE_RETRYABLE_GENERATION_CATEGORIES = {'browser_warmup_failed', 'browser_runtime_timeout', 'api_server_error', 'rate_limit', 'recaptcha_failed', 'network', 'session_bootstrap_pending', 'high_traffic', 'captcha_provider_down', 'server_erro... [truncated]

# --- Class: FlowVoiceSyncService ---
class FlowVoiceSyncService:
    """Resolve local voice refs into Flow entity audioReferences for one account."""
    _sync_locks = {}
    _sync_locks_guard = <unlocked _thread.lock object at 0x00000264DFBE2500>

    def __init__(self, *, store: 'Optional[FlowVoiceStore]' = None, api_call: 'Optional[Callable[..., Dict[str, Any]]]' = None, max_generate_attempts: 'int' = 3, retry_sleep: 'Optional[Callable[[float], None]]' = None):
        pass

    def ensure_audio_reference(self, voice_ref: 'Dict[str, Any]', account: 'Dict[str, Any]') -> 'Dict[str, str]':
        pass

    @classmethod
    def _lock_for(cls, blueprint_id: 'str', key: 'str') -> "__assert_armored__((threading, b'\\x81\\xb7\\xb7\\x1a_\\xba'))":
        pass

    def _call_generate_voice_with_retry(self, blueprint, account: 'Dict[str, Any]') -> 'Dict[str, Any]':
        pass

    def ensure_blueprint_for_accounts(self, blueprint_id: 'str', accounts: 'Iterable[Dict[str, Any]]', *, max_workers: 'int' = 4) -> 'Dict[str, Dict[str, str]]':
        pass

    def presync_all_blueprints_for_account(self, account: 'Dict[str, Any]', *, max_workers: 'int' = 2) -> 'Dict[str, Dict[str, str]]':
        pass

    def presync_blueprint_for_available_accounts(self, blueprint_id: 'str', *, accounts: 'Optional[Iterable[Dict[str, Any]]]' = None, max_workers: 'int' = 4) -> 'Dict[str, Dict[str, str]]':
        pass

    @staticmethod
    def _available_accounts(accounts: 'Optional[Iterable[Dict[str, Any]]]' = None) -> 'list[Dict[str, Any]]':
        pass

    def _call_generate_voice(self, blueprint, account: 'Dict[str, Any]') -> 'Dict[str, Any]':
        pass

