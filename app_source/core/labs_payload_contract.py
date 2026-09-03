"""
Decompiled / Reconstructed Module: core.labs_payload_contract
Source PyC: labs_payload_contract.pyc

Docstring:
Google Labs payload defaults observed from the live browser client.

The Flow web app builds tool-specific payloads first, then a shared request
wrapper merges mediaGenerationContext and injects reCAPTCHA just before fetch.
Keep the same shape here so endpoint-specific drift is handled at one exit
point instead of duplicated across every generation helper.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
Dict = typing.Dict
Optional = typing.Optional
VIDEO_AUDIO_FAILURE_PREFERENCE = 'BLOCK_SILENCED_VIDEOS'

# --- Top-Level Functions ---
def _is_video_generation_url(url: Optional[str]) -> bool:
    pass

def apply_labs_payload_defaults(payload: Dict[str, Any], url: Optional[str]) -> Dict[str, Any]:
    pass
