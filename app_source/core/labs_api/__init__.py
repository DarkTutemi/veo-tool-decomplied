"""
Decompiled / Reconstructed Module: core.labs_api.__init__
Source PyC: __init__.pyc

Docstring:
core/labs_api/ — refactored Labs (Flow) API client.

Clean re-home of the 6366-line god-file core/api_client.py. Each module = one
responsibility. The old file stays as a read-only reference; callers are
re-pointed gradually behind the VEOFLOW_LABS_API_V2 flag.

This package re-exports the public surface under the SAME names api_client uses,
so a caller switches backend by changing only the import line:

    from core.labs_api import generate_text_video_dict

Build order (see docs/architecture/api-client-refactor-plan.md):
  A contracts · B session/proxy · C transport · D flow_ui_bridge · E wire
  F calls · G download · H upscale · I multi_asset · J image · K generate
  L extend_chain/util · M __init__ re-export · N flag · O cleanup
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['generate_text_video', 'generate_text_video_dict', 'generate_image_video', 'generate_image_video_dict', 'generate_image_video_with_auto_fix', 'generate_extend_video_with_auto_fix', 'generate_multi_asset_video_with_auto_fix', 'call_multi_asset_batch_api', 'upscale_video_to_1080p', 'poll_and_download', 'download_video', 'GenerationResult', 'upload_image', 'upload_base64_image', 'upload_base64_image_with_session', 'get_extend_chain_manager', 'ensure_project_and_scene_for_chain', 'call_text_to_video', 'call_image_to_video', 'call_2_image_to_video', 'call_multi_asset', 'call_extend_video', 'check_credits', 'get_credits', 'call_flow_audio_generation_api', 'create_entity', 'patch_entity', 'upload_character_image', 'call_api_via_browser', 'flow_ui_native_enabled', 'call_flow_image_upscale_via_ui', 'http_requests', 'get_access_token', 'extract_error_message']

# --- Module Constants & Globals ---
http_requests = <core.labs_api.proxy.ProxyRequests object at 0x00000264DD151E20>
__all__ = ['generate_text_video', 'generate_text_video_dict', 'generate_image_video', 'generate_image_video_dict', 'generate_image_video_with_auto_fix', 'generate_extend_video_with_auto_fix', 'generate_multi_as... [truncated]
