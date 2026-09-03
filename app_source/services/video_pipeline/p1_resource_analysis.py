"""
Decompiled / Reconstructed Module: services.video_pipeline.p1_resource_analysis
Source PyC: p1_resource_analysis.pyc

Docstring:
Step 2: Pre-Script Analysis — AI identifies all resources needed.

Input:  idea/script + user assets (from MediaLibrary)
Output: ResourcePlan with characters (CHAR_XXX), objects (OBJ_XXX), backgrounds (BG_XXX).
        Characters marked as "provided" (already in MediaLibrary) or "new" (need CharGen).
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
Dict = typing.Dict
Optional = typing.Optional

# --- Top-Level Functions ---
def analyze_resources(config: services.video_pipeline.pipeline_config.PipelineConfig, progress_callback=None) -> services.video_pipeline.pipeline_config.ResourcePlan:
    pass

def _build_analysis_prompt(config: services.video_pipeline.pipeline_config.PipelineConfig) -> str:
    pass

def _parse_analysis_response(response: str) -> Dict:
    pass
