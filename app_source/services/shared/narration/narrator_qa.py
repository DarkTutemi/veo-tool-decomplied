"""
Decompiled / Reconstructed Module: services.shared.narration.narrator_qa
Source PyC: narrator_qa.pyc

Docstring:
Narrator QA — one LLM call LISTENS to the rendered take and audits it against
the script (owner 2026-08, shared master/clone/affiliate).

Why: the PCM chunk-map path (master/clone) never listens to the take, so a TTS
model that code-switches languages (user-reported defect class: target-language
narration mixed with foreign words) ships silently — nothing verifies the
AUDIO against the SCRIPT. Transcript-only checks miss it too when the local ASR
mis-reads code-switched audio.

Language authority (owner 2026-08 correction): the EXPECTED paragraph text is
the authority, NOT the job language. A script may legitimately contain verbatim
foreign lines (clone verbatim narration, quoted foreign speech — the SCRIPT
MARKER verbatim rule outranks the language lock). So:
  - expected paragraph reads as TARGET language → transcript must be target
    language too: wrong_language / mixed / invented foreign words = FAIL;
  - expected paragraph is itself FOREIGN (verbatim allowed) → the language lock
    does not apply; only `missing` / low word recall fail.
Gate decisions are computed in PYTHON from the LLM measurement (deterministic),
never trusted from the model's own verdict alone.

Repair is OWNER-MANDATED ("ép phải sửa đúng"): failed paragraphs get up to
``max_rounds`` targeted chunk regens (only the failing chunks re-render), each
round re-audited; only after the budget is exhausted does it fail loud — a
narrator that does not read the script is the wrong product (fail-closed).
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['NarrationQAError', 'QA_MIN_SCORE', 'audit_take', 'failed_paragraph_indices', 'log_qa']

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Callable = typing.Callable
Dict = typing.Dict
List = typing.List
Optional = typing.Optional
QA_MIN_SCORE = 0.75
__all__ = ['NarrationQAError', 'QA_MIN_SCORE', 'audit_take', 'failed_paragraph_indices', 'log_qa']

# --- Class: NarrationQAError ---
class NarrationQAError(RuntimeError):
    """The rendered take violates the script/language contract after QA repair."""
    def __init__(self, message: 'str', paragraphs: 'Optional[List[int]]' = None):
        pass


# --- Top-Level Functions ---
def _extract_json(text: 'str') -> 'Optional[Dict[str, Any]]':
    pass

def audit_take(take: 'Any', script: 'Any', language: 'str', *, provider: 'Any' = None, progress: 'Optional[Callable[..., None]]' = None) -> 'Dict[str, Any]':
    pass

def failed_paragraph_indices(report: 'Dict[str, Any]', *, expected: 'Optional[List[Dict[str, Any]]]' = None, language: 'str' = 'vi', min_score: 'float' = 0.75) -> 'List[int]':
    pass

def log_qa(report: 'Dict[str, Any]', bad: 'List[int]', expected: 'Optional[List[Dict[str, Any]]]' = None) -> 'None':
    pass
