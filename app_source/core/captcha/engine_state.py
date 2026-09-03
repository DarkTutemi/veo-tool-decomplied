"""
Decompiled / Reconstructed Module: core.captcha.engine_state
Source PyC: engine_state.pyc

Docstring:
Farm engine selection.

Policy (hardened 2026-07-14): FORK-ONLY. The farm ALWAYS runs on the in-house VeoFlowOS
stealth fork — vanilla Chrome is NEVER used as a farm engine. The fork's pipe-auth +
stealth patches are the security boundary, so the app must not be able to silently drop
to real Chrome, and no env var may downgrade it (a cracker must not escape the fork via
VEOFLOW_FARM_ENGINE=chrome / VEOFLOW_PREFER_FORK=0 — both are ignored). The old
Chrome→fork escalation ladder is therefore moot; escalate_to_veoflow() survives only as a
"first sustained burn → drop browsers + resume" hook (it can never pick Chrome).

Note: 403 UNUSUAL_ACTIVITY is mostly an ACCOUNT velocity/reputation signal, not a
browser problem (verified 2026-07-07: a fresh account passes headless on the very same
IP a burned account 403s on). Switching engines does NOT rescue a burned account — rest
/ rotate the account. See ip_block_state for the user-facing notice.

Env:
  VEOFLOW_FARM_ENGINE=veoflow  → (only "veoflow" honored; "chrome" is IGNORED — fork-only)
  VEOFLOW_BROWSER_ESCALATION=0 → disable the burn→drop/resume hook
  VEOFLOW_BROWSER_EXE=<path>   → use a local stealth build (skips CDN); DEV BUILDS ONLY
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
_lock = <unlocked _thread.lock object at 0x00000264DA5E46C0>
_escalated = False
_prefetch_started = False
MIN_FORK_VERSION = '1.0.13'
MIN_FORK_GATE_PROTOCOL = 2
_RUNTIME_WAIT_TIMEOUT_SECONDS = 1200
_runtime_condition = <Condition(<unlocked _thread.RLock object owner=0 count=0 at 0x00000264DA016340>, 0)>
_runtime_state = 'idle'
_runtime_error = ''
_runtime_version = ''
_auto_repair_outcomes = {}
_recovery_lock = <unlocked _thread.lock object at 0x00000264DA5E7940>
_recovery_timer = None
_recovery_attempts = 0
_RECOVERY_BACKOFF_SECONDS = (30, 60, 120, 300, 600)

# --- Class: BrowserRuntimeUpdateError ---
class BrowserRuntimeUpdateError(RuntimeError):
    """The managed fork could not be brought to the required release."""
    pass


# --- Top-Level Functions ---
def _arm_browser_recovery(reason: 'str') -> 'None':
    pass

def _browser_recovery_tick() -> 'None':
    pass

def _numeric_version(value: 'str') -> 'tuple[int, ...]':
    pass

def fork_version_supported(value: 'str') -> 'bool':
    pass

def browser_exe_override() -> 'str':
    pass

def _forced_engine() -> 'str':
    pass

def _escalation_enabled() -> 'bool':
    pass

def _prefetch_opt_out() -> 'bool':
    pass

def veoflow_binary_available() -> 'bool':
    pass

def _browser_update_available() -> 'bool':
    pass

def current_engine_is_veoflow() -> 'bool':
    pass

def can_escalate() -> 'bool':
    pass

def escalate_to_veoflow() -> 'bool':
    pass

def reset_escalation() -> 'None':
    pass

def browser_boot_action() -> 'str':
    pass

def browser_runtime_status() -> 'dict':
    pass

def ensure_browser_runtime_ready(*, on_progress=None, on_error=None, purpose: 'str' = 'launch', wait_timeout: 'float' = 1200) -> 'Path':
    pass

def _browser_executable_key(value: 'str | Path') -> 'str':
    pass

def repair_browser_runtime(failed_executable: 'str | Path' = '', failure_detail: 'str' = '', reason: 'str' = 'runtime-launch-failed', on_progress=None, on_error=None, manual: 'bool' = False, wait_timeout: 'float' = 1200) -> 'Path':
    pass

def repair_browser_after_launch_failure(failed_executable: 'str | Path', failure_detail: 'str', on_progress=None, on_error=None) -> 'Path':
    pass

def browser_runtime_snapshot(deep: 'bool' = False) -> 'dict':
    pass

def _reset_browser_runtime_coordinator_for_tests() -> 'None':
    pass

def prefetch_in_background() -> 'None':
    pass
