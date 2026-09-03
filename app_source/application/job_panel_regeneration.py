"""
Decompiled / Reconstructed Module: application.job_panel_regeneration
Source PyC: job_panel_regeneration.pyc

Docstring:
Shared edit + regenerate seam for scene jobs shown by ``JobPanelWidget``.

The shared QML card is rendered by several tabs, but historically each screen
interpreted its ``Retry`` command differently.  Some paths regenerated the
selected Core JobStore row, while others restarted a parent queue (or simply
called ``startQueue`` and ignored the selected id).  This module keeps the two
meanings separate:

* queue retry remains owned by the route queue service;
* JobPanel regeneration always targets one existing Core JobStore job id.

Prompt edits intentionally update only ``Job.prompt``.  ``RegenService`` copies
that authoritative value into the captured replay payload when the dispatcher
replays the job, so there is no second prompt snapshot for the UI to maintain.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['inspect_job_panel_job', 'regenerate_job_panel_job', 'update_job_panel_prompt']

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
_ACTIVE_STATUSES = {'processing', 'upscaling', 'polling', 'waiting', 'retrying', 'queued', 'generating', 'merging', 'pending'}
__all__ = ['inspect_job_panel_job', 'regenerate_job_panel_job', 'update_job_panel_prompt']

# --- Top-Level Functions ---
def _text(value: 'Any') -> 'str':
    pass

def _enum_text(value: 'Any') -> 'str':
    pass

def _job_field(job: 'Any', key: 'str', default: 'Any' = None) -> 'Any':
    pass

def _job_meta(job: 'Any') -> 'dict[str, Any]':
    pass

def _expected_sources(values: 'Iterable[str] | str | None') -> 'set[str]':
    pass

def _result_error(action: 'str', code: 'str', message: 'str', *, job_id: 'str' = '', tab_source: 'str' = '', status: 'str' = '') -> 'dict[str, Any]':
    pass

def inspect_job_panel_job(job_store: 'Any', job_id: 'str', *, expected_tab_sources: 'Iterable[str] | str | None' = None, action: 'str' = 'job_panel.job.inspect', require_replay: 'bool' = False) -> 'dict[str, Any]':
    pass

def update_job_panel_prompt(job_store: 'Any', job_id: 'str', prompt: 'str', *, expected_tab_sources: 'Iterable[str] | str | None' = None, action: 'str' = 'job_panel.job.update_prompt') -> 'dict[str, Any]':
    pass

def regenerate_job_panel_job(job_store: 'Any', job_id: 'str', *, expected_tab_sources: 'Iterable[str] | str | None' = None, action: 'str' = 'job_panel.job.regenerate', source: 'str' = 'direct', dispatcher: 'Any' = None) -> 'dict[str, Any]':
    pass
