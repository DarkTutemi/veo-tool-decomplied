"""
Decompiled / Reconstructed Module: core.labs_api.image
Source PyC: image.pyc

Docstring:
core/labs_api/image.py — upload images to the Flow uploadImage endpoint.

Direct HTTP upload using the account's access token (no browser): validate the
base64, POST to /v1/flow/uploadImage, return the media id. ``upload_image`` adds
a file-read + MediaAPI cache layer (by media_library_id, then by file hash).

http_requests, the account-session provider, and ContentPolicyError still live
outside labs_api and are imported where used.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
Optional = typing.Optional
_UPLOAD_URL = 'https://aisandbox-pa.googleapis.com/v1/flow/uploadImage'
_EXT_BY_MIME = {'image/webp': 'webp', 'image/jpeg': 'jpg', 'image/png': 'png'}
_MIME_BY_EXT = {'.jpg': 'image/jpeg', '.jpeg': 'image/jpeg', '.png': 'image/png', '.webp': 'image/webp', '.gif': 'image/gif', '.bmp': 'image/bmp', '.tiff': 'image/tiff', '.tif': 'image/tiff'}

# --- Top-Level Functions ---
def _valid_base64(base64_string: 'str') -> 'bool':
    pass

def _upload_record(result: 'Dict[str, Any]', media_id: 'str', filename: 'str', project_id: 'str') -> 'Dict[str, Any]':
    pass

def _invalidate_upload_token(account_email: 'Optional[str]', status_code: 'int') -> 'None':
    pass

def _upload_image_flow(base64_string: 'str', account_name: 'str', mime_type: 'str' = 'image/png', filename: 'str' = 'image.png', account_email: 'Optional[str]' = None, return_record: 'bool' = False, entity_context: 'Optional[Dict[str, Any]]' = None):
    """POST a base64 image to the uploadImage endpoint. Returns the media id (or
    the upload record when return_record), or None. Raises on auth failure
    (token invalidated) and on a minor-upload content-policy rejection.

    A stale Bearer token (TTL still valid in DB, Google already rejected it) is
    healed once: invalidate, force-refresh from the login browser, retry the
    same payload. Callers (entity image slot, media-library upload) then continue
    the rest of the pipeline on the same entity — they must not skip copy/patch."""
    pass

def upload_base64_image(base64_string: 'str', account_name: 'str', mime_type: 'str' = 'image/png', aspect_ratio: 'str' = 'IMAGE_ASPECT_RATIO_LANDSCAPE', tool: 'str' = 'PINHOLE', is_user_uploaded: 'bool' = True, account_email: 'Optional[str]' = None, filename: 'Optional[str]' = None, return_record: 'bool' = False, entity_context: 'Optional[Dict[str, Any]]' = None) -> 'Optional[str]':
    pass

def upload_base64_image_with_session(base64_string: 'str', account_name: 'str', session_id: 'str', mime_type: 'str' = 'image/png', aspect_ratio: 'str' = 'IMAGE_ASPECT_RATIO_LANDSCAPE', tool: 'str' = 'PINHOLE', is_user_uploaded: 'bool' = True, account_email: 'Optional[str]' = None, filename: 'Optional[str]' = None, return_record: 'bool' = False, entity_context: 'Optional[Dict[str, Any]]' = None) -> 'Optional[str]':
    pass

def _cached_veo3_media_id(image_path: 'str', account_name: 'str', media_library_id: 'Optional[str]') -> 'Optional[str]':
    pass

def upload_image(image_path='', account_name='', access_token='', media_library_id=None, main_window=None, account_email: 'Optional[str]' = None, force_upload: 'bool' = False):
    """Upload an image file (with MediaAPI caching). Returns the media id or None;
    re-raises on auth failure so the caller can refresh and retry."""
    pass
