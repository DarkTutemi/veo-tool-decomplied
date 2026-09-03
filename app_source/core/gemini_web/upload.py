"""
Decompiled / Reconstructed Module: core.gemini_web.upload
Source PyC: upload.pyc

Docstring:
Gemini Web file upload → content-push.googleapis.com.

Verified pattern (gemini-webapi / live headers):
  POST https://content-push.googleapis.com/upload
  Headers: X-Tenant-Id: bard-storage, Push-ID: feeds/<id>
  Multipart field ``file`` with filename + bytes
  Response body: file identifier path string, e.g.
    /contrib_service/ttl_1d/...
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Optional = typing.Optional
Union = typing.Union
UPLOAD_URL = 'https://content-push.googleapis.com/upload'
DEFAULT_PUSH_ID = 'feeds/mcudyrk2a4khkz'
TENANT = 'bard-storage'

# --- Top-Level Functions ---
def parse_push_id(html: 'str') -> 'Optional[str]':
    pass

def upload_file(session: "'requests.Session'", file: 'Union[str, os.PathLike, bytes]', *, push_id: 'str' = 'feeds/mcudyrk2a4khkz', filename: 'Optional[str]' = None, timeout: 'float' = 120.0) -> 'str':
    pass
