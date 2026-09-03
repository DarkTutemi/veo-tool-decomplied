"""
Decompiled / Reconstructed Module: core.captcha.device_trust
Source PyC: device_trust.pyc

Docstring:
Per-account device MATURITY — 'consecutive successes since the last burn' as a proxy for
how much trust the account's CURRENT device (fingerprint seed) has earned server-side.

Why: reCAPTCHA scores a device by its server-side HISTORY (see docs/recaptcha_deep_signals.json:
the _ga/_grecaptcha device-id is timestamped, trust accrues with age + successful use). A
freshly-rotated or just-burned device has NO positive history (or a negative flag) → maturity 0.
Hammering a young device re-burns it (no trust buffer) → the rotation spiral. So pace a young
device GENTLY, let it earn a few clean successes, then ramp back to full speed.

Maturity ++ on each success; resets to 0 on any 403 burn (rotate). Singleton + thread-safe;
module-level so both farm_runtime (which sees success/burn) and the browser's pacing reach it.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
_instance = None
_instance_lock = <unlocked _thread.lock object at 0x00000264DA5E7080>

# --- Class: _DeviceTrust ---
class _DeviceTrust:
    def __init__(self) -> 'None':
        pass

    def record_success(self, account_key: 'str') -> 'None':
        pass

    def record_burn(self, account_key: 'str') -> 'None':
        pass

    def maturity(self, account_key: 'str') -> 'int':
        pass


# --- Top-Level Functions ---
def get_device_trust() -> '_DeviceTrust':
    pass
