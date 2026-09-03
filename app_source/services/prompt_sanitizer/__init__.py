"""
Decompiled / Reconstructed Module: services.prompt_sanitizer.__init__
Source PyC: __init__.pyc

Docstring:
Prompt sanitization stages used by video generation pipelines.

This package centralizes low-level strip helpers while preserving the existing
stage boundaries: canonical prompts keep routing IDs, pre-dispatch removes
runtime fields, and wire prompts are the final send-only cleanup.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['sanitize_wire_prompt', 'strip_entity_tokens', 'strip_runtime_scene_fields', 'strip_voice_lock_speech_descriptors']

# --- Module Constants & Globals ---
__all__ = ['sanitize_wire_prompt', 'strip_entity_tokens', 'strip_runtime_scene_fields', 'strip_voice_lock_speech_descriptors']
