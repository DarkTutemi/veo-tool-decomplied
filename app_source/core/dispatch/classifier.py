"""
Decompiled / Reconstructed Module: core.dispatch.classifier
Source PyC: classifier.pyc

Docstring:
core/dispatch/classifier.py — JobClassifier.

THE single routing decision point of the dispatch system.

Maps (source_tab `feature`, `prompt_data`) -> `ApiJob`. Pure function, no state,
no I/O. Run ONCE at submit time; the resulting ApiJob is stored on the JobHandle
and in JobStore. Handlers route on ApiJob and never re-inspect prompt_data for
routing.

Reference (read-only): managers/smart_job_dispatcher.py
  - _execute_job_async feature routing (~L6549-6579)
  - _execute_text_video_job branch precedence (~L8177-8996):
        if download_result is not None:                       # resume
        elif visual_assets and len>0 and not character_metadata:  -> R2V_VISUAL
        elif character_metadata and len>0:                        -> R2V_CHARACTER
        elif job_type == 'multi_asset_video':                     -> MULTI_ASSET
        else:                                                     -> T2V
  - portrait routing: portrait_video WITH character_metadata routes into
    _execute_text_video_job (=> R2V_CHARACTER); without => portrait T2V.

Improvement over old code: this decision was re-derived at EXECUTION time inside a
1324-line method. Here it is made once, explicitly, in one tested place. Adding a
new capability changes only this file's rules.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
_classifier = None

# --- Class: JobClassifier ---
class JobClassifier:
    """Pure routing: (feature, prompt_data) -> ApiJob."""
    _VIDEO_TEXT_FEATURES = {'text_video', 'portrait_video', 'multi_asset_video'}

    def classify(self, feature: 'str', prompt_data: 'dict | None') -> 'ApiJob':
        pass

    def _classify_text_family(self, pd: 'dict') -> 'ApiJob':
        pass


# --- Top-Level Functions ---
def _truthy_list(value: 'Any') -> 'bool':
    pass

def get_classifier() -> 'JobClassifier':
    pass
