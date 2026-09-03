"""
Decompiled / Reconstructed Module: services.tabs.timemachine.story_budget
Source PyC: story_budget.pyc

Docstring:
Frozen story/runtime budget derived from an accepted story inventory.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['CLIP_DURATION_S', 'STORY_BUDGET_VERSION', 'TimeMachineStoryBudgetError', 'resolve_story_budget', 'validate_story_budget', 'write_story_budget']

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Mapping = typing.Mapping
STORY_BUDGET_VERSION = '1.0'
CLIP_DURATION_S = 8.0
__all__ = ['CLIP_DURATION_S', 'STORY_BUDGET_VERSION', 'TimeMachineStoryBudgetError', 'resolve_story_budget', 'validate_story_budget', 'write_story_budget']

# --- Class: TimeMachineStoryBudgetError ---
class TimeMachineStoryBudgetError(ValueError):
    """The requested scope cannot be projected to a stable render budget."""
    pass


# --- Top-Level Functions ---
def _fingerprint(value: 'Mapping[str, Any]') -> 'str':
    pass

def resolve_story_budget(*, intent: 'str', directive: 'Mapping[str, Any]', source_context: 'Mapping[str, Any] | None' = None, config: 'Mapping[str, Any] | None' = None, reference_date: 'str' = '', story_blueprint: 'Mapping[str, Any] | None' = None) -> 'dict[str, Any]':
    """Freeze a budget from the accepted, event-driven visual story plan.

    Time span, UI configuration and source-media duration are deliberately not
    runtime authorities. The Visual Story Architect first inventories distinct
    visible states; this function only projects them onto fixed eight-second,
    same-viewport I2V edges. Legacy StoryBlueprint input remains readable."""
    pass

def validate_story_budget(raw: 'Mapping[str, Any]') -> 'dict[str, Any]':
    pass

def write_story_budget(work_folder: 'str', budget: 'Mapping[str, Any]') -> 'str':
    pass
