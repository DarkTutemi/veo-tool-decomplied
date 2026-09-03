"""
Decompiled / Reconstructed Module: core.aistudio.selectors
Source PyC: selectors.pyc

Docstring:
core/aistudio/selectors.py — DOM selector registry for aistudio.google.com.

Selectors ordered by resilience: placeholder/aria-label first, class last.
Update here when Google changes the UI — all drivers read from this file.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
AISTUDIO_URL = 'https://aistudio.google.com/prompts/new_chat'
PROMPT_TEXTAREA = ['textarea[placeholder*="Start typing"]', 'textarea[placeholder*="prompt"]', '[role="textbox"][aria-label*="prompt" i]']
SUBMIT_BUTTON = ['button:has-text("Run")', 'button[class*="ctrl-enter"]', 'button[aria-label="Run"]']
NEW_CHAT_BUTTON = ['button[aria-label="New chat"]', 'button:has-text("New chat")', 'a[href*="/prompts/new_chat"]']
SYSTEM_INSTR_BUTTON = ['button:has-text("System instructions")', 'button[aria-label*="System instructions" i]']
SYSTEM_INSTR_TEXTAREA = ['textarea[placeholder*="Optional tone"]', 'textarea[placeholder*="system instruction" i]']
SYSTEM_INSTR_CLOSE = ['button:has-text("Close panel")', 'button[aria-label="Close"]']
FILE_MENU_BUTTON = ['button[aria-label*="Insert images, videos, audio, or files" i]', 'button[aria-label*="Insert" i]']
UPLOAD_FILES_MENUITEM = ['.upload-file-menu-item', '[role="menuitem"]:has-text("Upload files")']
YOUTUBE_VIDEO_MENUITEM = ['.youtube-video-menu-item', '[role="menuitem"]:has-text("YouTube Video")']
MODEL_RESPONSE_TURN = '[data-turn-role="model"]'
STREAMING_INDICATOR = '.loading, .streaming, [aria-label="Loading"]'
ERROR_INTERNAL = 'text="An internal error has occurred."'
ERROR_RATE_LIMIT = 'text=/rate limit/i'
LOGGED_IN_INDICATORS = ['button[aria-label*="Google Account"]', 'button[aria-label="Settings"]', 'button[aria-label="New chat"]']
MODEL_SELECTOR = ['button[aria-label*="model" i]', '[data-testid="model-selector"]']
PAID_BADGE = '.badge.paid'
MODEL_OPTION_FREE = '[role="option"]:not(:has(.badge.paid)), .model-title:not(:has(.badge.paid))'

# --- Top-Level Functions ---
def first_match(page, selector_list: list[str], *, timeout: int = 5000):
    pass
