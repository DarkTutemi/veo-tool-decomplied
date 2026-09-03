"""
Decompiled / Reconstructed Module: services.shared.consistency.library_intake
Source PyC: library_intake.pyc

Docstring:
Library-media INTAKE — cổng SEAM A chung cho mọi route video (master/clone/transcript).

The analyzer/LLM's entity_library is an LLM ECHO — system fields (media_id/base64)
do not survive the round-trip. Without them the ref generators would RE-GENERATE
a library asset's image instead of reusing the existing library one (the 19/7
"library-only object regenerated as a wrong product" bug). Every tab MUST call
attach_library_media_to_entities() right after its analyzer/LLM step, BEFORE the
ensure step (apply_scene_consistency / p3 create_assets).

Promoted verbatim from application/transcript_service._attach_selected_media_to_entities
(the transcript tab's local fix) so all tabs share one implementation.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['attach_library_media_to_entities', 'merge_provided_character_metadata']

# --- Module Constants & Globals ---
Dict = typing.Dict
List = typing.List
__all__ = ['attach_library_media_to_entities', 'merge_provided_character_metadata']

# --- Top-Level Functions ---
def _text(value: Any) -> str:
    pass

def _safe_dict(value: Any) -> Dict[str, Any]:
    pass

def _safe_list(value: Any) -> List[Any]:
    pass

def attach_library_media_to_entities(result_data: Dict[str, Any], source: Dict[str, Any], config: Dict[str, Any]) -> None:
    pass

def merge_provided_character_metadata(result_data: Dict[str, Any]) -> Dict[str, Dict[str, Any]]:
    pass
