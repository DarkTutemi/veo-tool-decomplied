"""
Decompiled / Reconstructed Module: services.tabs.timemachine.pipeline
Source PyC: pipeline.pyc

Docstring:
Locked Time Machine idea → finished video pipeline.

Authorities are separate. A later stage may not invent what an earlier
authority already owns.

    idea            user intent text
    director plan   camera registration + density + viewport graph
    milestones      WHEN / WHAT on the selected viewport
    chapter root    one locked plate per viewport_id (parallel)
    still N         previous 4K media_id on THAT camera
    video           I2V only inside the same viewport
    picture-lock    concat; hard cut when camera changes
    post            voice + measured SRT + TGS + audio-reactive waveform
    mux / publish   final master, publish kit and terminal state

The Director chooses a structured camera contract, but milestone rows never
write image/I2V prompts or construction novels. Image compile and I2V compile
are local templates. Downstream planner
/ story-contract / I2V still consume the expanded event IR produced
locally from milestones.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['AUTHORITIES', 'PHASES', 'PIPELINE_VERSION', 'is_milestone_outline', 'pipeline_projection']

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Mapping = typing.Mapping
PIPELINE_VERSION = '3.3'
AUTHORITIES = ({'key': 'intent', 'owns': 'what the user asked for', 'must_not': 'pixels, camera, clip recipes'}, {'key': 'director_plan', 'owns': 'camera registration, viewport graph and milestone density', 'must_n... [truncated]
PHASES = ({'key': 'intake', 'label': 'Đầu vào & mốc', 'llm': 'classifier + one milestone outline', 'output': 'directive + slim chapters/milestones'}, {'key': 'plan', 'label': 'Storyboard', 'llm': 'none — local... [truncated]
__all__ = ['AUTHORITIES', 'PHASES', 'PIPELINE_VERSION', 'is_milestone_outline', 'pipeline_projection']

# --- Top-Level Functions ---
def pipeline_projection() -> 'dict[str, Any]':
    pass

def is_milestone_outline(raw: 'Mapping[str, Any] | None') -> 'bool':
    pass
