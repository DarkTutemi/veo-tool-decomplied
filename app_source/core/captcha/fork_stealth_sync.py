"""
Decompiled / Reconstructed Module: core.captcha.fork_stealth_sync
Source PyC: fork_stealth_sync.pyc

Docstring:
SYNC full-stealth launcher for the VeoFlowOS Browser fork (affiliate browse/fetch).

The farm engine (`veoflow_worker.py`) runs the fork with FULL stealth via a named-pipe
challenge/response handshake (without it the C++ fingerprint patches stay DORMANT and the
fork behaves like vanilla Chromium) + `--fingerprint=<seed>` + CDP attach. That worker is
ASYNC (async_playwright, farm event loop).

The affiliate browser (`services/tabs/affiliate/product_browser.py`) runs on the SYNC
BrowserManager worker-thread model, so it cannot reuse the async farm path. This module is
the SYNC twin: same subprocess + named-pipe auth + connect_over_cdp, minus the farm-only
rotation/proxy/off-screen machinery.

Design choices for the affiliate profile (decided with owner 2026-07-22):
  · STABLE seed (no rotation) — the user LOGS IN to their Shopee/TikTok burner and the
    cookies must persist against a CONSISTENT device fingerprint. A rotating seed would
    read as a new device every launch → re-login / flag.
  · Real IP (no proxy) — residential IP matches the account; datacenter proxy would hurt.
  · Persistent profile dir (shared with the vanilla path) so existing logins carry over.

The ONLY security-critical bit (the shared-secret pipe response) is IMPORTED from
veoflow_worker, never re-implemented, so it can never silently diverge from the browser.
The ctypes pipe plumbing + stderr ws:// parsing below mirror `_launch_with_pipe_auth`
/ `_await_devtools_ws` in veoflow_worker; keep them in sync if that handshake changes.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['affiliate_stealth_enabled', 'stable_seed', 'fork_exe_available', 'resolve_fork_exe', 'launch_fork_pipe_auth', 'poll_devtools_ws', 'kill_proc']

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Optional = typing.Optional
Tuple = typing.Tuple
_SEED_GEN_FILE = '.vf_seed_generation'
__all__ = ['affiliate_stealth_enabled', 'stable_seed', 'fork_exe_available', 'resolve_fork_exe', 'launch_fork_pipe_auth', 'poll_devtools_ws', 'kill_proc']

# --- Top-Level Functions ---
def affiliate_stealth_enabled() -> 'bool':
    pass

def stable_seed(key: 'str', generation: 'int' = 0) -> 'int':
    pass

def _seed_gen_path(profile_dir: 'str') -> 'Path':
    pass

def seed_generation(profile_dir: 'str') -> 'int':
    pass

def bump_seed_generation(profile_dir: 'str') -> 'int':
    pass

def set_seed_generation(profile_dir: 'str', generation: 'int') -> 'int':
    pass

def seed_for_profile(key: 'str', profile_dir: 'str') -> 'int':
    pass

def fork_exe_available() -> 'bool':
    pass

def resolve_fork_exe() -> 'Optional[str]':
    pass

def _mark_profile_clean(profile_dir: 'str') -> 'None':
    pass

def _build_fork_launch_args(exe: 'str', pipe_id: 'str', seed: 'int', profile_dir: 'str', *, proxy_url: 'str' = '', tz_name: 'str' = '', languages: 'str' = '', native_screen: 'bool' = True, spoof_gpu: 'bool' = False, headless: 'bool' = False, maximized: 'bool' = True, panel_ext_dir: 'str' = '') -> 'list[str]':
    pass

def launch_fork_pipe_auth(exe: 'str', seed: 'int', profile_dir: 'str', *, proxy_url: 'str' = '', tz_name: 'str' = '', languages: 'str' = '', native_screen: 'bool' = True, spoof_gpu: 'bool' = False, headless: 'bool' = False, maximized: 'bool' = True, panel_ext_dir: 'str' = '', handshake_timeout: 'float' = 0.0, attach_kill_job: 'bool' = False) -> "Tuple[__assert_armored__((subprocess, b'\\x81\\xb5\\x94\\x05Y\\xbf')), str]":
    pass

def poll_devtools_ws(proc: 'subprocess.Popen', stderr_path: 'str', timeout: 'float' = 25.0) -> 'str':
    pass

def kill_proc(proc: 'Optional[subprocess.Popen]') -> 'None':
    pass
