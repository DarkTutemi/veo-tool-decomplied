"""
Decompiled / Reconstructed Module: core.gemini_web.constants
Source PyC: constants.pyc

Docstring:
Gemini Web endpoints, tool modes & limits (live reverse 2026-07-11 Ultra).
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
BASE = 'https://gemini.google.com'
APP_URL = 'https://gemini.google.com/app'
USAGE_URL = 'https://gemini.google.com/usage'
STREAM_GENERATE = 'https://gemini.google.com/_/BardChatUi/data/assistant.lamda.BardFrontendService/StreamGenerate'
BATCHEXECUTE = 'https://gemini.google.com/_/BardChatUi/data/batchexecute'
DEFAULT_BUILD_LABEL = 'boq_assistant-bard-web-server_20260715.03_p0'
RPC_BARD_ACTIVITY = 'ESY5D'
RPC_USER_STATUS = 'otAQ7b'
RPC_LIST_GEMS = 'CNgdBe'
RPC_GET_FULL_SIZE_IMAGE = 'c8o8Fe'
RPC_DEEP_RESEARCH_STATUS = 'kwDCne'
RPC_DEEP_RESEARCH_PREFS = 'L5adhe'
RPC_DEEP_RESEARCH_BOOTSTRAP = 'ku4Jyf'
RPC_DEEP_RESEARCH_MODEL_STATE = 'qpEbW'
RPC_DEEP_RESEARCH_CAPS = 'aPya6c'
RPC_DEEP_RESEARCH_ACK = 'PCck7e'
RPC_READ_CHAT = 'hNvQHb'
RPC_LIST_CHATS = 'MaZiqc'
STREAMING_FLAG_INDEX = 7
GEM_FLAG_INDEX = 19
TURN_MODE_INDEX = 17
TEMPORARY_CHAT_FLAG_INDEX = 45
CHAT_EXTRA_FLAG_INDEX = 67
TOOL_MODE_INDEX = 49
DR_PLAN_TOOLS_INDEX = 54
DR_CAP_FLAG_INDEX = 55
DR_FLAG_INDEX = 49
TOOL_MODE_NONE = 0
TOOL_MODE_DEEP_RESEARCH = 1
TOOL_MODE_VIDEO = 11
TOOL_MODE_IMAGE = 14
TOOL_MODE_MUSIC = 21
TOOL_MODES = {'none': 0, 'chat': 0, 'deep_research': 1, 'research': 1, 'video': 11, 'create_video': 11, 'image': 14, 'create_image': 14, 'music': 21, 'create_music': 21}
DR_PLAN_META_KEY = '56'
DR_RUN_META_KEY = '57'
DR_PROGRESS_META_KEY = '58'
DR_STATE_META_KEY = '70'
DR_STATE_PLAN = 2
DR_STATE_RUNNING = 3
DEFAULT_CONFIRM_PROMPTS = ('Bắt đầu nghiên cứu', 'Start research', 'Start researching')
MODEL_HEADER_KEY = 'x-goog-ext-525001261-jspb'
MODEL_CATALOG = {'flash': {'model_id': '56fdd199312815e2', 'name': 'gemini-3-flash-plus', 'tail': 4}, 'flash_basic': {'model_id': 'fbb127bbb056c959', 'name': 'gemini-3-flash', 'tail': 1}, 'pro': {'model_id': 'e6fa609... [truncated]
LIMIT_WINDOWS = {'rolling': {'label': 'current_usage', 'approx_hours': 5, 'note': 'UI short window; Ultra shows percent + next reset clock'}, 'weekly': {'label': 'weekly_usage', 'note': 'UI weekly percent + reset dat... [truncated]
UPLOAD_SOURCES = ('local_file', 'google_drive', 'google_photos', 'notebook')
GEN_TOOLS = ('create_image', 'create_video', 'create_music', 'deep_research', 'canvas')
COOKIE_KEYS = ('__Secure-1PSID', '__Secure-1PSIDTS', 'SAPISID', '__Secure-1PAPISID', 'SID', 'HSID', 'SSID', 'APISID')
