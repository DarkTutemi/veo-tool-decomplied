"""
Decompiled / Reconstructed Module: application.header_service
Source PyC: header_service.pyc

Docstring:
Headless service for QML shell/header actions.

The legacy header was tightly coupled to ``MainWindow`` and PyQt dialogs.  This
service exposes the same information as local data so QML can render native
dialogs without importing widget UI code.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
List = typing.List
Optional = typing.Optional
PROJECT_ROOT = WindowsPath('H:/veo-tool/unpack-veotool/VEOFLOWPROMAX.exe_extracted/PYZ.pyz_extracted')
ACTIVE_LICENSE_STATUSES = {'verify_only', 'valid', 'active', 'ok', 'licensed'}
INVALID_LICENSE_STATUSES = {'error', 'blocked', 'invalid', 'expired', 'revoked'}
PENDING_LICENSE_STATUSES = {'configured', 'pending'}
DEFAULT_FEATURE_CATALOG = [('master_panel', 'MASTER PROMPT'), ('clone_panel', 'CLONE VIDEO'), ('voice_studio', 'VOICE STUDIO'), ('transcript_panel', 'AUDIO TO VIDEO'), ('deep_research', 'DEEP RESEARCH'), ('normal_panel', 'NORM... [truncated]
UPDATE_FSM_STATES = {'DOWNLOAD_FAILED', 'NO_UPDATE', 'IDLE', 'DOWNLOADING', 'READY_TO_APPLY', 'CHECKING', 'APPLYING', 'UPDATE_AVAILABLE'}
_MIN_FREE_DISK_FLOOR_BYTES = 536870912
HEADER_ACTION_BLOCKERS = {'commerce_load_store': {'label': 'Load Store', 'category': 'network_store', 'reason': 'requires the backend store API and may perform network I/O', 'requires': ['backend store API', 'license manager ... [truncated]
_HEADER_SERVICE = None

# --- Class: HeaderService ---
class HeaderService:
    """Provide local header/about/license/store snapshots for QML."""
    def __init__(self) -> 'None':
        pass

    def snapshot(self) -> 'Dict[str, Any]':
        pass

    def dialog(self, mode: 'str', store_data: 'Optional[Dict[str, Any]]' = None) -> 'Dict[str, Any]':
        pass

    def execute_action(self, action: 'str', value: 'str' = '', store_data: 'Optional[Dict[str, Any]]' = None, progress_callback: 'Optional[Any]' = None) -> 'Dict[str, Any]':
        pass

    def dialog_for_action_result(self, action: 'str', result: 'Dict[str, Any]', store_data: 'Optional[Dict[str, Any]]' = None) -> 'Dict[str, Any]':
        pass

    def _blocked_header_action(self, action: 'str', value: 'str' = '', *, fallback_reason: 'str' = '') -> 'Dict[str, Any]':
        pass

    def cancel_action(self, action: 'str') -> 'Dict[str, Any]':
        pass

    def _set_active_action(self, action: 'str', downloader: 'Any' = None) -> 'None':
        pass

    def _clear_active_action(self, action: 'str' = '') -> 'None':
        pass

    def _license_manager(self) -> 'Any':
        pass

    def _load_commerce_store(self) -> 'Dict[str, Any]':
        pass

    def _create_credit_topup(self, value: 'str') -> 'Dict[str, Any]':
        pass

    def _buy_full_pack(self, value: 'str', store_data: 'Dict[str, Any]') -> 'Dict[str, Any]':
        pass

    def _buy_feature_days(self, value: 'str') -> 'Dict[str, Any]':
        pass

    def _payment_info(self, value: 'str') -> 'Dict[str, Any]':
        pass

    def _check_update(self) -> 'Dict[str, Any]':
        pass

    def _normalize_update_info(self, raw: 'Dict[str, Any]') -> 'Dict[str, Any]':
        pass

    def _is_newer_version(self, latest: 'Any', current: 'Any') -> 'bool':
        pass

    def _resolve_update_info(self, value: 'str' = '') -> 'Dict[str, Any]':
        pass

    def _emit_progress(self, progress_callback: 'Optional[Any]', percent: 'int', status: 'str', *, indeterminate: 'bool' = False) -> 'None':
        pass

    def _ensure_free_disk_space(self, target_path: 'str', size_hint: 'Any') -> 'Optional[Dict[str, Any]]':
        pass

    def _download_update(self, value: 'str', progress_callback: 'Optional[Any]' = None) -> 'Dict[str, Any]':
        pass

    def _download_installer_fallback(self, requested_version: 'str', current_version: 'str', required_base: 'str', progress_callback: 'Optional[Any]' = None, original_info: 'Optional[Dict[str, Any]]' = None, download_id: 'str' = '') -> 'Dict[str, Any]':
        pass

    def _apply_pending_update(self, value: 'str', progress_callback: 'Optional[Any]' = None) -> 'Dict[str, Any]':
        pass

    def _app_info(self) -> 'Dict[str, Any]':
        pass

    def _license_cache(self) -> 'Dict[str, Any]':
        pass

    def _credits(self, license_data: 'Dict[str, Any]') -> 'Dict[str, Any]':
        pass

    def set_live_balance(self, data: 'Dict[str, Any]') -> 'None':
        pass

    def _usage_dashboard_billing(self) -> 'Dict[str, Any]':
        pass

    def _billing_money(self, license_data: 'Dict[str, Any]', credits: 'Dict[str, Any]') -> 'Dict[str, Any]':
        pass

    def _billing_usage_rows(self, billing: 'Dict[str, Any]', license_data: 'Dict[str, Any]') -> 'List[Dict[str, Any]]':
        pass

    def _browser_health(self) -> 'Dict[str, Any]':
        pass

    def _license_label(self, data: 'Dict[str, Any]') -> 'str':
        pass

    def _paths(self) -> 'Dict[str, str]':
        pass

    def _update_state_snapshot(self) -> 'Dict[str, Any]':
        pass

    def _blocked_dialog(self, result: 'Dict[str, Any]') -> 'Dict[str, Any]':
        pass

    def _about_dialog(self, snapshot: 'Dict[str, Any]') -> 'Dict[str, Any]':
        pass

    def _data_dialog(self, snapshot: 'Dict[str, Any]') -> 'Dict[str, Any]':
        pass

    def _update_dialog(self, snapshot: 'Dict[str, Any]', status: 'str' = '') -> 'Dict[str, Any]':
        pass

    def _license_dialog(self, snapshot: 'Dict[str, Any]') -> 'Dict[str, Any]':
        pass

    def _gateway_billing_dialog(self, snapshot: 'Dict[str, Any]', store_data: 'Optional[Dict[str, Any]]' = None, focus: 'str' = 'money', status: 'str' = '') -> 'Dict[str, Any]':
        pass

    def feature_purchase_dialog(self, route: 'str', store_data: 'Optional[Dict[str, Any]]' = None, payment: 'Optional[Dict[str, Any]]' = None, status: 'str' = '') -> 'Dict[str, Any]':
        pass

    def _credits_dialog(self, snapshot: 'Dict[str, Any]') -> 'Dict[str, Any]':
        pass

    def _store_dialog(self, snapshot: 'Dict[str, Any]', store_data: 'Optional[Dict[str, Any]]' = None, status: 'str' = '') -> 'Dict[str, Any]':
        pass

    def _renew_dialog(self, snapshot: 'Dict[str, Any]', store_data: 'Optional[Dict[str, Any]]' = None) -> 'Dict[str, Any]':
        pass

    def _payment_dialog(self, payment: 'Dict[str, Any]', source_action: 'str') -> 'Dict[str, Any]':
        pass

    @staticmethod
    def _payment_status_subtitle(status: 'str', source_action: 'str', payment: 'Dict[str, Any]') -> 'str':
        pass

    def _update_result_dialog(self, data: 'Dict[str, Any]') -> 'Dict[str, Any]':
        pass

    def _update_download_dialog(self, data: 'Dict[str, Any]') -> 'Dict[str, Any]':
        pass

    def _update_apply_confirm_dialog(self, snapshot: 'Dict[str, Any]') -> 'Dict[str, Any]':
        pass

    def _update_apply_dialog(self, data: 'Dict[str, Any]') -> 'Dict[str, Any]':
        pass

    def _error_dialog(self, action: 'str', message: 'str') -> 'Dict[str, Any]':
        pass

    def _feature_rows(self, license_data: 'Dict[str, Any]') -> 'List[Dict[str, Any]]':
        pass

    def _license_state(self, license_data: 'Dict[str, Any]') -> 'Dict[str, Any]':
        pass

    def _extract_reseller(self, license_data: 'Dict[str, Any]') -> 'Dict[str, Any]':
        """Extract reseller contact info from license payload.

        Server may return reseller info under various keys depending on backend version.
        No default contact is synthesized; the UI should show this block only when
        the license/key payload explicitly contains reseller data."""
        pass

    def _reseller_for_display(self, license_data: 'Dict[str, Any]') -> 'Dict[str, Any]':
        pass

    def _support_contact_url(self, snapshot: 'Dict[str, Any]') -> 'str':
        pass

    def _reseller_contact_url(self, reseller: 'Dict[str, Any]') -> 'str':
        pass

    def _commerce_features(self, store_data: 'Dict[str, Any]') -> 'List[Dict[str, Any]]':
        pass

    def _feature_day_store_rows(self, store_data: 'Dict[str, Any]') -> 'List[Dict[str, Any]]':
        pass

    def _payment_method_rows(self, store_data: 'Dict[str, Any]') -> 'List[Dict[str, str]]':
        pass

    def _feature_price_rows(self, features: 'List[Dict[str, Any]]') -> 'List[Dict[str, Any]]':
        pass

    def _friendly_error(self, message: 'Any') -> 'str':
        pass


# --- Top-Level Functions ---
def _safe_str(value: 'Any', fallback: 'str' = '') -> 'str':
    pass

def _mask_key(value: 'Any') -> 'str':
    pass

def _fmt_number(value: 'Any') -> 'str':
    pass

def _fmt_compact_number(value: 'Any') -> 'str':
    pass

def _safe_float(value: 'Any', fallback: 'float' = 0.0) -> 'float':
    pass

def _safe_int(value: 'Any', fallback: 'int' = 0) -> 'int':
    pass

def _safe_bool(value: 'Any', fallback: 'bool' = False) -> 'bool':
    pass

def _fmt_vnd(value: 'Any') -> 'str':
    pass

def _current_language() -> 'str':
    pass

def _money_target_currency() -> 'str':
    pass

def _fmt_money_for_locale(value: 'Any', source_currency: 'Any' = 'VND', exchange_rate: 'Any' = 25000) -> 'str':
    pass

def _flatten_payload(data: 'Any') -> 'Dict[str, Any]':
    pass

def _parse_datetime(value: 'Any') -> 'Optional[datetime]':
    pass

def _format_expiry(value: 'Any') -> 'str':
    pass

def _format_remaining(value: 'Any', tier: 'str' = '') -> 'str':
    pass

def _pick(data: 'Dict[str, Any]', *keys: 'str', default: 'Any' = '') -> 'Any':
    pass

def _path_row(label: 'str', path: 'Path') -> 'Dict[str, Any]':
    pass

def _contract_code(action: 'str') -> 'str':
    pass

def derive_update_fsm_state(mode: 'str', update_available: 'bool' = False, has_pending: 'bool' = False) -> 'str':
    pass

def _parse_size_to_bytes(value: 'Any') -> 'int':
    pass

def _blocked_action(action: 'str', reason: 'str', *, label: 'str | None' = None, code: 'str | None' = None, category: 'str' = 'native', context: 'Dict[str, Any] | None' = None, requires: 'List[str] | None' = None, destructive: 'bool' = False, contract_type: 'str' = 'native_action') -> 'Dict[str, Any]':
    pass

def get_header_service() -> 'HeaderService':
    pass
