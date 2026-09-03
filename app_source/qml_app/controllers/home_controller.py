"""
Decompiled / Reconstructed Module: qml_app.controllers.home_controller

Docstring:
Home dashboard controller for the QML shell.
"""

from __future__ import annotations
import sys, os, typing
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
_GATED_CAPABILITIES = frozenset({'master_panel', 'image_panel', 'voice_studio', 'clone_panel', 'normal_panel', 'time_machine', 'deep_research', 'transcript_panel', 'extend_panel', 'affiliate_panel'})

# --- Class: HomeController ---
class HomeController(QObject):
    """Expose legacy HomeTab content as a headless QML data/action model."""
    _COMPLETED_STATUSES = frozenset({'done', 'completed', 'complete'})
    _FAILED_STATUSES = frozenset({'error', 'failed'})
    _LIVE_STATUSES = frozenset({'preparing', 'processing', 'retrying', 'pending', 'queued', 'running'})
    staticMetaObject = PySide6.QtCore.QMetaObject("HomeController" inherits "QObject":
Properties:
  #1 "summary", QVariantMap [designable], no...

    summaryChanged = Signal()
    contentChanged = Signal()
    actionsChanged = Signal()
    lifecycleChanged = Signal()
    statusMessageChanged = Signal()
    navigationRequested = Signal()
    externalOpenRequested = Signal()
    _homeContentReady = Signal()
    _summaryDataReady = Signal()
    def __init__(self, timer_factory: 'type[QTimer]' = <class 'PySide6.QtCore.QTimer'>) -> 'None':
        # [PyArmor BCC constants]: 'ok', 'blocked', 'actionId', 'message'
        pass

    def summary(*args, **kwargs):
        pass

    def dashboard(*args, **kwargs):
        pass

    def hero(*args, **kwargs):
        pass

    def heroBadges(*args, **kwargs):
        pass

    def features(*args, **kwargs):
        pass

    def readiness(*args, **kwargs):
        pass

    def quickActions(*args, **kwargs):
        pass

    def blockers(*args, **kwargs):
        pass

    def lastAction(*args, **kwargs):
        pass

    def announcements(*args, **kwargs):
        pass

    def news(*args, **kwargs):
        pass

    def tips(*args, **kwargs):
        pass

    def socialLinks(*args, **kwargs):
        pass

    def promotions(*args, **kwargs):
        pass

    def banners(*args, **kwargs):
        pass

    def tutorials(*args, **kwargs):
        pass

    def statusMessage(*args, **kwargs):
        pass

    def autoRefreshActive(*args, **kwargs):
        pass

    def onShown(self) -> 'None':
        # [PyArmor BCC constants]: '_is_visible', True, '_start_refresh_timers', 'lifecycleChanged', 'emit', '_shown_bg_running', 'threading', 'Thread', 'target', '_on_shown_bg', 'daemon', 'start'
        pass

    def _on_shown_bg(self) -> 'None':
        # [PyArmor BCC constants]: 'DEFAULT_CONTENT', 'get_home_content_service', 'dict', 'get_content', 'Exception', 'get_home_readiness_manifest', 'content', 'readiness', '_homeContentReady', 'emit', False, '_shown_bg_running'
        pass

    def _apply_home_content_payload(self, payload: 'dict') -> 'None':
        # [PyArmor BCC constants]: 'get', 'content', 'readiness', '_server_content', '_normalize_hero', 'hero', '_hero', '_normalize_feature_badges', 'feature_badges', '_feature_badges', '_normalize_hero_badges', '_hero_badges', '_normalize_feed', 'announcements', 'icon'
        pass

    def onHidden(self) -> 'None':
        # [PyArmor BCC constants]: '_is_visible', False, '_stop_refresh_timers', 'lifecycleChanged', 'emit'
        pass

    def refresh(self) -> 'None':
        # [PyArmor BCC constants]: '_refresh_readiness', '_load_content', '_summary_inflight', True, 'ok', 'accounts', 'history', 'headless_jobs', 'master_stats', 'list', 'get_account_service', 'list_accounts', 'include_inactive', 'get_history_service', 'query_runs'
        pass

    def _apply_summary_data(self, data: 'dict[str, Any]') -> 'None':
        pass

    def _build_dashboard(self, history: 'list[dict[str, Any]]', headless_jobs: 'list[dict[str, Any]]', master_queued: 'int') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'jobId', 'title', 'thumbnail', 'route', 'ago'
        pass

    def _build_queue_counts(self, headless_jobs: 'list[dict[str, Any]]', master_queued: 'int') -> 'dict[str, int]':
        # [PyArmor BCC constants]: 'SOURCE_ROUTES', 'str', 'get', 'status', '', 'lower', '_LIVE_STATUSES', 'tab_source', 0, 1, 'master', 'int'
        pass

    @staticmethod
    def _row_timestamp(value: 'Any') -> 'float':
        # [PyArmor BCC constants]: 'isinstance', 'int', 'float', 'str', '', 'strip', 0.0, 'ValueError', 'endswith', 'Z', 'replace', '+00:00', 'datetime', 'fromisoformat', 'timestamp'
        pass

    @staticmethod
    def _format_age(age_seconds: 'float') -> 'str':
        # [PyArmor BCC constants]: 'max', 0, 'int', 3600, 1, 60, 'm', 86400, 'h', 'd'
        pass

    def refreshRuntime(self) -> 'None':
        # [PyArmor BCC constants]: '_summary', 'get_headless_job_store', 'list_jobs', 'limit', 1000, 'get_master_queue_service', 'get_stats', 'int', 'get', 'queued', 'pending', 0, 'Exception', 'masterQueued', 'jobsInMemory'
        pass

    def _license_snapshot(self) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'get_license_manager', 'get_license_info', 'Exception', 'isinstance', 'get', 'data', 'dict', 'credits', 'licenseType', 'licenseExpiresAt', 'freeCredits', 'paidCredits', 'str', 'license_type', 'tier'
        pass

    @staticmethod
    def _format_license_expiry(info: 'dict[str, Any]') -> 'str':
        # [PyArmor BCC constants]: 'str', 'get', 'license_type', 'tier', '', 'upper', 'LIFETIME', '∞', 'expires_at', 'expires', '-', 'isinstance', 'endswith', 'Z', 'replace'
        pass

    def openUrl(self, url: 'str') -> 'None':
        pass

    def triggerCta(self, action: 'str', value: 'str') -> 'None':
        # [PyArmor BCC constants]: 'str', '', 'strip', 'lower', 'route', 'navigationRequested', 'emit', 'dialog', '_set_status', 'Dialog requested: ', '_request_external_url', 'home.cta'
        pass

    def triggerAction(self, action_id: 'str') -> 'None':
        # [PyArmor BCC constants]: 'str', '', 'strip', '_find_action', '_set_action_blocked', 'unknown_home_action', 'Home action is not registered.', 'bool', 'get', 'enabled', True, 'state', 'ready', 'blocked', 'isinstance'
        pass

    def _load_content(self) -> 'None':
        # [PyArmor BCC constants]: 'DEFAULT_CONTENT', 'get_home_content_service', 'dict', 'get_content', 'Exception', '_server_content', '_normalize_hero', 'get', 'hero', '_hero', '_normalize_feature_badges', 'feature_badges', '_feature_badges', '_normalize_hero_badges', '_hero_badges'
        pass

    @staticmethod
    def _normalize_cta(value: 'Any') -> 'dict[str, str]':
        # [PyArmor BCC constants]: 'isinstance', 'dict', 'str', 'get', 'label', 'text', '', 'strip', 'action', 'external_url', 'lower', 'value', 'tone', 'url', 'route'
        pass

    @classmethod
    def _normalize_hero(cls, value: 'Any') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'isinstance', 'dict', 'title', 'subtitle', 'body', 'mediaUrl', 'cta', 'str', 'get', 'VEOFLOW.DEV', 'AI automation workspace', 'description', 'Master Prompt - Clone - Audio To Video - Research - Voice Studio', 'bg_image_url', 'image_url'
        pass

    @classmethod
    def _normalize_promotions(cls, value: 'Any') -> 'list[dict[str, Any]]':
        # [PyArmor BCC constants]: 'isinstance', 'list', 'enumerate', 8, 'dict', 'str', 'get', 'title', '', 'strip', 'append', 'id', 'desc', 'imageUrl', 'badge'
        pass

    @classmethod
    def _normalize_banners(cls, value: 'Any') -> 'list[dict[str, Any]]':
        # [PyArmor BCC constants]: 'isinstance', 'list', 'enumerate', 8, 'dict', 'str', 'get', 'image_url', 'imageUrl', '', 'strip', 'title', '_normalize_cta', 'cta', 'link_url'
        pass

    @classmethod
    def _normalize_tutorials(cls, value: 'Any') -> 'list[dict[str, Any]]':
        # [PyArmor BCC constants]: 'isinstance', 'list', 'enumerate', 100, 'dict', 'str', 'get', 'title', '', 'strip', 'tag', 'youtube_id', 'youtubeId', 'video_id', 'url'
        pass

    @staticmethod
    def _normalize_feature_badges(value: 'Any') -> 'dict[str, dict[str, Any]]':
        # [PyArmor BCC constants]: 'isinstance', 'dict', 'items', 'str', 'get', 'text', '', 'credit', 'lower', 'color', 'enabled', 'icon', '#3B82F6', 'bool', True
        pass

    def _normalize_hero_badges(self) -> 'list[dict[str, str]]':
        # [PyArmor BCC constants]: 'isinstance', '_server_content', 'get', 'hero', 'dict', 'badges', 'list', 4, 'str', 'label', 'text', '', 'strip', 'append', 'icon'
        pass

    @staticmethod
    def _normalize_feed(value: 'Any', fallback: 'list[dict[str, str]]') -> 'list[dict[str, str]]':
        # [PyArmor BCC constants]: 'isinstance', 'list', 8, 'dict', 'append', 'icon', 'text', 'color', 'str', 'get', '*', 'title', '', '#3B82F6'
        pass

    def _normalize_social_links(self, value: 'Any') -> 'list[dict[str, Any]]':
        # [PyArmor BCC constants]: 'icon', 'FB', 'name', 'Facebook', 'url', 'https://www.facebook.com/dev.veoflowtool', 'color', '#1877F2', 'YT', 'YouTube', 'https://www.youtube.com/@veoflowdotdev', '#EF4444', 'WEB', 'VeoFlow', 'https://veoflow.dev'
        pass

    def _refresh_readiness(self) -> 'None':
        # [PyArmor BCC constants]: 'get_home_readiness_manifest', '_readiness', 'surface', 'summary', 'navigationActions', 'quickActions', 'structuredBlockers', 'actionCounts', 'qml_home', 'ready', 0, 'partial', 'blocked', 1, 'code'
        pass

    def _build_features(self) -> 'list[dict[str, Any]]':
        # [PyArmor BCC constants]: '_readiness', 'get', 'navigationActions', 'isinstance', 'dict', '_action_available', 'enabled', '_badge_for_action', 'str', 'text', '', 'badge', 'color', '#3B82F6', 'badgeColor'
        pass

    def _build_quick_actions(self) -> 'list[dict[str, Any]]':
        # [PyArmor BCC constants]: '_readiness', 'get', 'quickActions', 'isinstance', 'dict', '_action_available', 'enabled', 'append'
        pass

    def _action_available(self, action: 'dict[str, Any]') -> 'bool':
        # [PyArmor BCC constants]: 'str', 'get', 'state', 'ready', 'blocked', False, 'capability', '', 'strip', '_GATED_CAPABILITIES', True, 'get_license_manager', 'getattr', 'feature_gate', 'callable'
        pass

    def _badge_for_action(self, action: 'dict[str, Any]') -> 'dict[str, Any] | None':
        # [PyArmor BCC constants]: 'str', 'get', 'capability', '', 'strip', 'route', 'append', 'master', 'master_panel', 'clone', 'clone_panel', 'transcript', 'transcript_panel', 'normal', 'normal_panel'
        pass

    def _find_action(self, action_id: 'str') -> 'dict[str, Any] | None':
        # [PyArmor BCC constants]: '_features', '_quick_actions', '_social_links', 'str', 'get', 'actionId', ''
        pass

    def _request_external_url(self, action_id: 'str', url: 'str') -> 'None':
        # [PyArmor BCC constants]: 'str', '', 'strip', '_set_action_blocked', 'missing_external_url', 'External URL is empty.', 'urlparse', 'scheme', 'https', 'http', 'netloc', 'invalid_external_url', 'Invalid external URL: ', '_is_allowed_external_host', 'external_host_not_allowlisted'
        pass

    @staticmethod
    def _is_allowed_external_host(host: 'str') -> 'bool':
        # [PyArmor BCC constants]: 'veoflow.dev', 'facebook.com', 'youtube.com', 'zalo.me'
        pass

    def _set_action_ok(self, action_id: 'str', message: 'str') -> 'None':
        # [PyArmor BCC constants]: 'ok', 'blocked', 'actionId', 'message', True, False, '_last_action', '_set_status', 'actionsChanged', 'emit'
        pass

    def _set_action_blocked(self, action_id: 'str', blocker: 'str', message: 'str') -> 'None':
        # [PyArmor BCC constants]: 'ok', 'blocked', 'actionId', 'blocker', 'message', False, True, '_last_action', '_set_status', 'Blocked: ', 'actionsChanged', 'emit'
        pass

    def _set_status(self, message: 'str') -> 'None':
        pass

    def _start_refresh_timers(self) -> 'None':
        # [PyArmor BCC constants]: 2, '_remaining_delayed_refreshes', '_arm_delayed_refresh_timer', '_auto_refresh_timer', 'start', '_runtime_refresh_timer', 1, 'autoRefreshStartCount'
        pass

    def _stop_refresh_timers(self) -> 'None':
        # [PyArmor BCC constants]: 0, '_remaining_delayed_refreshes', '_delayed_refresh_timer', 'stop', 1, 'delayedRefreshStopCount', '_auto_refresh_timer', '_runtime_refresh_timer', 'autoRefreshStopCount'
        pass

    def _arm_delayed_refresh_timer(self) -> 'None':
        # [PyArmor BCC constants]: '_is_visible', '_remaining_delayed_refreshes', 0, '_delayed_refresh_timer', 'start', 1, 'delayedRefreshStartCount'
        pass

    def _on_delayed_refresh_timeout(self) -> 'None':
        # [PyArmor BCC constants]: '_remaining_delayed_refreshes', 0, 1, 'refresh', '_arm_delayed_refresh_timer'
        pass


# --- Top-Level Functions ---
def _count_status(rows: 'list[dict[str, Any]]', *statuses: 'str') -> 'int':
    pass
