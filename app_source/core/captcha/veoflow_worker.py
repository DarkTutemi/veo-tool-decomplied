"""
Decompiled / Reconstructed Module: core.captcha.veoflow_worker
Source PyC: veoflow_worker.pyc

Docstring:
VeoFlowOS Browser farm engine — the custom stealth Chromium fork.

This engine drives the in-house "VeoFlowOS Browser" (a Chromium fork with a
deterministic per-seed fingerprint + native proxy auth) instead of system Chrome.
It clears reCAPTCHA Enterprise / the 403 wall that flags burnt IPs on vanilla
Chrome.

Integration shape (see H:\Chromium\docs\BROWSER_INTEGRATION.md):
  1. Resolve chrome.exe — env VEOFLOW_BROWSER_EXE override, else the CDN-managed
     VEOFLOW_BROWSER resource (auto-downloaded by veoflow_res, like ffmpeg/deno).
  2. Launch it ourselves with the named-pipe challenge/response auth (without it the
     stealth patches stay dormant) + --remote-debugging-port + --fingerprint=<seed>
     + --fingerprint-proxy + headless=new.
  3. Playwright connect_over_cdp() to the debug port → a normal Playwright Browser.
  4. Everything else (JIT cookie inject, navigate, evaluate, fetch payload, the whole
     reCAPTCHA flow) is reused UNCHANGED from ChromeBrowserInstance / BrowserWorkerBase
     — we only override initialize()/close().

The seed is REAL here (unlike the cosmetic seed of the real-Chrome engine): it maps
to --fingerprint=<seed>, derived deterministically from the account identity + the
farm's 403 rotation counter, so the existing rotate-on-403 machinery actually swaps
the device fingerprint.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['VeoFlowBrowserInstance', 'reap_managed_profile_owner']

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Optional = typing.Optional
LANDING_URL = 'https://labs.google/fx/tools/flow'
_MAGIC_A = 6491850925360682353
_MAGIC_B = 5644216790571828547
_MASK = 18446744073709551615
_JOB_OBJECT_LIMIT_KILL_ON_JOB_CLOSE = 8192
_JobObjectExtendedLimitInformation = 9
_LIVE_FORK_PIDS = {}
_live_fork_pids_lock = <unlocked _thread.lock object at 0x00000264D637EE40>
_FORK_EVER_LAUNCHED = False
__all__ = ['VeoFlowBrowserInstance', 'reap_managed_profile_owner']

# --- Class: _ForkLaunchOwner ---
class _ForkLaunchOwner:
    """Thread-safe ownership token for one executor-backed fork launch.

    Cancelling an asyncio Future returned by ``run_in_executor`` does not stop
    the worker thread.  The token therefore outlives the cancelled coroutine:
    close() marks it cancelled, and a late Popen is reaped by the launch thread
    instead of being published back into an already-closed browser instance."""
    cancelled = <member 'cancelled' of '_ForkLaunchOwner' objects>

    def __init__(self) -> 'None':
        pass


# --- Class: _JOBOBJECT_BASIC_LIMIT_INFORMATION ---
class _JOBOBJECT_BASIC_LIMIT_INFORMATION(Structure):
    _fields_ = [('PerProcessUserTimeLimit', <class 'ctypes.c_longlong'>), ('PerJobUserTimeLimit', <class 'ctypes.c_longlong'>), ('Limit...
    PerProcessUserTimeLimit = <Field type=c_longlong, ofs=0, size=8>
    PerJobUserTimeLimit = <Field type=c_longlong, ofs=8, size=8>
    LimitFlags = <Field type=c_ulong, ofs=16, size=4>
    MinimumWorkingSetSize = <Field type=c_ulonglong, ofs=24, size=8>
    MaximumWorkingSetSize = <Field type=c_ulonglong, ofs=32, size=8>
    ActiveProcessLimit = <Field type=c_ulong, ofs=40, size=4>
    Affinity = <Field type=c_ulonglong, ofs=48, size=8>
    PriorityClass = <Field type=c_ulong, ofs=56, size=4>
    SchedulingClass = <Field type=c_ulong, ofs=60, size=4>


# --- Class: _IO_COUNTERS ---
class _IO_COUNTERS(Structure):
    _fields_ = [('ReadOperationCount', <class 'ctypes.c_ulonglong'>), ('WriteOperationCount', <class 'ctypes.c_ulonglong'>), ('OtherOpe...
    ReadOperationCount = <Field type=c_ulonglong, ofs=0, size=8>
    WriteOperationCount = <Field type=c_ulonglong, ofs=8, size=8>
    OtherOperationCount = <Field type=c_ulonglong, ofs=16, size=8>
    ReadTransferCount = <Field type=c_ulonglong, ofs=24, size=8>
    WriteTransferCount = <Field type=c_ulonglong, ofs=32, size=8>
    OtherTransferCount = <Field type=c_ulonglong, ofs=40, size=8>


# --- Class: _JOBOBJECT_EXTENDED_LIMIT_INFORMATION ---
class _JOBOBJECT_EXTENDED_LIMIT_INFORMATION(Structure):
    _fields_ = [('BasicLimitInformation', <class 'core.captcha.veoflow_worker._JOBOBJECT_BASIC_LIMIT_INFORMATION'>), ('IoInfo', <class ...
    BasicLimitInformation = <Field type=_JOBOBJECT_BASIC_LIMIT_INFORMATION, ofs=0, size=64>
    IoInfo = <Field type=_IO_COUNTERS, ofs=64, size=48>
    ProcessMemoryLimit = <Field type=c_ulonglong, ofs=112, size=8>
    JobMemoryLimit = <Field type=c_ulonglong, ofs=120, size=8>
    PeakProcessMemoryUsed = <Field type=c_ulonglong, ofs=128, size=8>
    PeakJobMemoryUsed = <Field type=c_ulonglong, ofs=136, size=8>


# --- Class: VeoFlowBrowserInstance ---
class VeoFlowBrowserInstance(ChromeBrowserInstance):
    """Farm engine backed by the custom VeoFlowOS Browser (CDP-driven)."""
    engine_name = 'veoflow'
    _abc_impl = <_abc._abc_data object at 0x00000264DA640880>

    def __init__(self, instance_id: 'int', account: 'dict', headless='new'):
        pass

    def _begin_fork_launch(self) -> '_ForkLaunchOwner':
        pass

    def _finish_fork_launch(self, owner: '_ForkLaunchOwner') -> 'None':
        pass

    def _fork_launch_cancelled(self, owner: '_ForkLaunchOwner') -> 'bool':
        pass

    def _publish_fork_launch(self, owner: '_ForkLaunchOwner', proc: 'subprocess.Popen', job: 'Optional[int]', stderr_file, stderr_path: 'Optional[str]', profile_dir: 'str') -> 'bool':
        pass

    def _cancel_launches_and_detach_fork(self):
        pass

    def _seed_rotation_count(self) -> 'int':
        pass

    def _fingerprint_seed(self) -> 'int':
        pass

    def _proxy_url(self) -> 'str':
        pass

    def _profile_dir(self) -> 'str':
        pass

    def _delete_profile_on_close(self) -> 'bool':
        pass

    def _prepare_profile_for_launch(self, profile_dir: 'str') -> 'None':
        pass

    def _launch_with_pipe_auth(self, exe: 'str', seed: 'int', profile_dir: 'str', port: 'int', proxy_url: 'str', tz_name: 'str', headless: 'bool', compatibility_mode: 'bool', launch_owner: '_ForkLaunchOwner') -> "Optional[__assert_armored__((subprocess, b'\\x81\\xb5\\x94\\x05Y\\xbf'))]":
        pass

    def _await_devtools_ws(self, timeout: 'float' = 25.0) -> 'str':
        """Return the DevTools ws:// CDP URL, parsed straight from the fork's stderr.

        Stock Chromium writes <user-data-dir>/DevToolsActivePort after the listener binds, but the
        VeoFlowOS fork does NOT (verified on the dev box: the listener binds fine — stderr prints
        "DevTools listening on ws://127.0.0.1:PORT/devtools/browser/GUID" — yet that file is never
        written). So we read the ws:// URL from the captured stderr and hand it to connect_over_cdp
        directly: no DevToolsActivePort poll (fork never writes it) and no /json/version HTTP probe
        (which some client machines' AV refuses on loopback → ECONNREFUSED though the browser is
        fine). Process dies while waiting → fail fast (headless/GPU crash, reason is in the log);
        no ws:// within the window → surface as a launch failure to the fork-only
        compatibility ladder."""
        pass

    @staticmethod
    def _is_repairable_pre_devtools_failure(phase: 'str', error: 'str') -> 'bool':
        pass

    def initialize(self) -> 'bool':
        """Launch once; on pre-DevTools failure restart leftover processes first.

        Re-downloading the browser cannot fix a wedged Chromium singleton
        (field 2026-08-29: 180 fresh-download loops, restarting the tool cured
        it). Restart is the same sweep users get by closing and reopening the
        app. A corrupt tree still falls through to one reinstall."""
        pass

    def _initialize_attempt_ladder(self) -> 'bool':
        """Start the activated fork without changing its presentation contract.

        A background Farm worker may retry with native-safe fingerprint flags,
        but it must remain headless. Interactive callers that explicitly request
        headed mode remain headed across their own compatibility retry."""
        pass

    def _initialize_once(self, use_headless: 'bool', compatibility_mode: 'bool') -> 'bool':
        pass

    def close(self) -> 'None':
        pass


# --- Top-Level Functions ---
def _safe_print(*values, sep: 'str' = ' ', end: 'str' = '\n', flush: 'bool' = False) -> 'None':
    """Write diagnostics without letting a legacy Windows codec kill the fork.

    Frozen/console-less Windows launches can expose a strict CP1252 stdout.
    Fork diagnostics contain emoji and Vietnamese text, so a normal ``print``
    may raise before Chromium is even launched. Preserve the message with
    backslash escapes when the active stream cannot encode it."""
    pass

def _compute_activation_hash(seed: 'int') -> 'int':
    pass

def _compute_pipe_response(seed: 'int', challenge: 'bytes') -> 'int':
    pass

def _free_port() -> 'int':
    pass

def _start_minimized_enabled() -> 'bool':
    pass

def _offscreen_enabled() -> 'bool':
    pass

def _farm_profile_base() -> 'Path':
    pass

def purge_stale_farm_profiles() -> 'None':
    pass

def _mark_profile_clean(profile_dir: 'str') -> 'None':
    pass

def _resolve_browser_exe() -> 'str':
    pass

def _build_fork_launch_args(exe: 'str', pipe_id: 'str', seed: 'int', profile_dir: 'str', port: 'int', proxy_url: 'str', tz_name: 'str', headless: 'bool', compatibility_mode: 'bool', start_minimized: 'Optional[bool]' = None, park_virtual_desktop: 'bool' = False, park_desktop1: 'bool' = False) -> 'list[str]':
    pass

def _normalize_browser_window_geometry(page, cdp_session) -> 'dict[str, object]':
    """Size the native window after renderer/DPI initialization has settled.

    Windows can rescale the pre-navigation CDP bounds when the first renderer
    commits under a forced device scale factor. Apply the seeded available
    screen size again after that commit and reject impossible JS geometry."""
    pass

def _fork_diag_text(value: 'object', limit: 'int' = 1600) -> 'str':
    """Keep diagnostics readable as one line in the in-app System Log."""
    pass

def _classify_fork_start_failure(exit_code: 'Optional[int]', stderr_tail: 'str', *, timed_out: 'bool' = False) -> 'tuple[str, str]':
    pass

def _assign_fork_to_kill_job(proc: 'subprocess.Popen') -> 'Optional[int]':
    pass

def _terminate_owned_fork(proc: 'Optional[subprocess.Popen]', job: 'Optional[int]', wait_seconds: 'float' = 3.0) -> 'None':
    pass

def purge_orphan_fork_processes() -> 'None':
    """Kill leftover FARM fork processes from a previous run at farm startup. Backstop for the
    Job reaper (_assign_fork_to_kill_job): covers a hard crash where close() never ran. Matches
    by EXACT exe path AND a --user-data-dir under the farm profile base, so it never touches the
    user's real Chrome NOR the AI Studio prewarm fork (which shares this exe but lives in a
    different profile). Only runs when the farm is NOT live (see start()), so no managed fork is
    ever killed. Best-effort; never raises."""
    pass

def reap_managed_profile_owner(profile_dir: 'str', wait_seconds: 'float' = 3.0) -> 'list[int]':
    """Reap a stale VeoFlow fork that owns one exact app-managed profile.

    AI Studio profiles are persistent, so a hard app exit/update can leave the
    browser process alive while the Python runtime that owned it is gone.  Match
    both the exact ``--user-data-dir`` and the private ``--vf-pipe`` activation
    switch; this cannot target the user's normal Chrome profile."""
    pass

def _register_live_fork_pid(pid: 'int', owner_id: 'str') -> 'None':
    pass

def _drop_live_fork_pid(pid) -> 'None':
    pass

def _mark_fork_launched() -> 'None':
    pass

def _claim_boot_sweep() -> 'bool':
    pass

def has_live_fork_pids() -> 'bool':
    pass

def prepare_browser_process_restart(failed_executable: 'str' = '', wait_seconds: 'float' = 3.0) -> 'dict':
    pass

def _managed_fork_install_root(failed_executable: 'str') -> 'str':
    pass

def _sweep_udd_under_managed_root(udd: 'str', farm_base: 'str', ai_base: 'str', diag_root: 'str') -> 'bool':
    pass

def sweep_stale_fork_processes(failed_executable: 'str' = '', wait_seconds: 'float' = 3.0, include_orphans: 'bool' = True) -> 'dict':
    """Kill leftover VeoFlowOS fork processes that wedge all new launches.

    Boot (``include_orphans=True``) may reap parentless leftovers from a previous
    session. Mid-session restart (``include_orphans=False``) only reaps
    unprotected ``--vf-pipe`` / managed scratch profiles so a live Google login
    browser whose parent is this app survives. Live pids registered by this
    process are always protected.

    Safe by construction: candidates must run the managed fork exe (path under the
    browser_versions root — never the user's real Chrome)."""
    pass
