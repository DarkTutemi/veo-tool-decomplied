"""
Decompiled / Reconstructed Module: core.captcha.human_motion
Source PyC: human_motion.pyc

Docstring:
Human-like pointer motion primitives.

reCAPTCHA Enterprise v3 scores the BEHAVIORAL stream captured at execute() time:
pointer path curvature, velocity profile, micro-tremor, and event-timing distribution.
Playwright's ``mouse.move(x, y, steps=N)`` emits N *linear* interpolations — straight
line, constant velocity, zero jitter, uniform timing — i.e. the exact signature of a
non-human. A/B dumps proved the fork's static fingerprint is byte-identical headed vs
headless, so this behavioral gap is the remaining headed-passes / headless-403s lever.

These helpers generate WAYPOINTS ``(x, y, dt)`` along a random cubic Bézier with
ease-in/out timing + Gaussian tremor, to be replayed one CDP ``Input.dispatchMouseEvent``
per point (Playwright ``page.mouse.move`` with NO steps) so every event is isTrusted and
the resulting curve/velocity/tremor look human. Pure + deterministic-free (uses ``random``
only); no Playwright/asyncio import so it stays trivially unit-testable.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
List = typing.List
Tuple = typing.Tuple
Waypoint = typing.Tuple[float, float, float]

# --- Top-Level Functions ---
def ease_in_out_cubic(t: 'float') -> 'float':
    pass

def _cubic_bezier(p0, p1, p2, p3, t):
    pass

def curved_path(start, end, *, duration: 'float | None' = None, samples: 'int | None' = None, jitter: 'float' = 0.7, bow: 'float' = 0.22) -> 'List[Waypoint]':
    pass

def drift_path(center, radius: 'float' = 3.0, samples: 'int' = 3) -> 'List[Waypoint]':
    pass

def clamp(v: 'float', lo: 'float', hi: 'float') -> 'float':
    pass
