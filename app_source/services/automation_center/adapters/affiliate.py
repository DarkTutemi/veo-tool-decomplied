"""
Decompiled / Reconstructed Module: services.automation_center.adapters.affiliate
Source PyC: affiliate.pyc

Docstring:
Affiliate adapter for one prepared Tool 1 product/variant.

The desktop Affiliate workspace owns product import and preparation UX, but the
actual production row is a durable ``AffiliateQueueService`` batch.  Automation
Center therefore enters below the Qt/controller layer: it snapshots one prepared
product, creates exactly one automation-owned row, then invokes ``start_row`` for
that returned id.  It never arms the broad Affiliate conveyor.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['AffiliateWorkflowAdapter']

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
_PREPARED_STATES = {'prepared', 'ready'}
__all__ = ['AffiliateWorkflowAdapter']

# --- Class: AffiliateWorkflowAdapter ---
class AffiliateWorkflowAdapter(Tool1ProductQueueAdapter):
    """Submit one prepared Affiliate product to one target queue row."""
    workflow = 'affiliate'
    capability = 'video.affiliate'
    display_name = 'Affiliate'
    input_modes = ('prepared_product',)
    feature_code = 'affiliate_panel'

    def __init__(self, *, service_provider: 'Callable[[], Any] | None' = None, config_provider: 'Callable[[], Mapping[str, Any]] | None' = None, admission_provider: 'Callable[[], Mapping[str, Any] | None] | None' = None, product_provider: 'Callable[[str], Mapping[str, Any] | None] | None' = None, session_key: 'str' = 'affiliate') -> 'None':
        pass

    @staticmethod
    def _default_service_provider() -> 'Any':
        pass

    @staticmethod
    def _default_config_provider() -> 'Mapping[str, Any]':
        pass

    @staticmethod
    def _default_admission_provider() -> 'Mapping[str, Any] | None':
        pass

    @staticmethod
    def _default_product_provider(product_id: 'str') -> 'Mapping[str, Any] | None':
        pass

    def validate(self, job: 'AutomationJob') -> 'None':
        pass

    def start(self, job: 'AutomationJob', *, on_internal_run_created: 'Callable[[str], None]') -> 'str':
        pass

    def ensure_started(self, internal_run_id: 'str') -> 'WorkflowSnapshot':
        pass

    def _find_row(self, internal_run_id: 'str') -> 'dict[str, Any] | None':
        pass

    def _start_target(self, internal_run_id: 'str', row: 'Mapping[str, Any]') -> 'Mapping[str, Any]':
        pass

    @staticmethod
    def _restart_uncertain(row: 'Mapping[str, Any]') -> 'bool':
        pass

    @staticmethod
    def _enqueue_row_ids(enqueue: 'Mapping[str, Any]') -> 'list[str]':
        pass

    @staticmethod
    def _payload_prompt(base_prompt: 'Any', additional_instructions: 'Any') -> 'str':
        pass

    def _prepared_product(self, value: 'Mapping[str, Any]', config: 'Mapping[str, Any]') -> 'tuple[dict[str, Any], dict[str, Any], str]':
        pass

    @staticmethod
    def _requested_variant_index(source: 'Mapping[str, Any]', config: 'Mapping[str, Any]') -> 'int':
        pass

    @staticmethod
    def _variant_index(variant: 'Mapping[str, Any]', source: 'Mapping[str, Any]', config: 'Mapping[str, Any]') -> 'int':
        pass

