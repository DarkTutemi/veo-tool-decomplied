"""
Decompiled / Reconstructed Module: qml_app.controllers.qthread_registry

Docstring:
Sổ đăng ký QThread sống + drain lúc thoát app — chống crash cuối cùng của lớp
`QThread: Destroyed while thread '' is still running`.

Các fix trước xử lý crash GIỮA phiên (signal `finished` bị shadow, thả reference khi
thread còn chạy, cleanup race). Còn MỘT nguồn nữa, chung cho MỌI QThread: khi user
thoát app đang lúc một worker chạy call mạng dài (TTS, upscale, header action), engine
teardown huỷ QThread mà không ai `quit()+wait()` → Qt6 qFatal → crash ngay khi tắt.

`off_thread.run_off_thread` (daemon thread) đã miễn nhiễm — daemon chết êm khi
interpreter thoát. Chỗ này lo phần QThread THẬT còn lại.

Cách dùng: gọi ``register(worker)`` ngay trước ``worker.start()``. WeakSet nên worker
tự rụng khỏi sổ khi bị GC — không giữ sống ngoài ý muốn. ``drain_all()`` nối vào
``QGuiApplication.aboutToQuit`` MỘT lần ở main.py.
"""

from __future__ import annotations
import sys, os, typing
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
_LOCK = <unlocked _thread.lock object at 0x0000021AD0D742C0>
_LIVE = set()

# --- Top-Level Functions ---
def register(worker: 'Any') -> 'Any':
    # [PyArmor BCC constants]: '_LOCK', '_LIVE', 'add', 'Exception'
    pass

def drain_all(timeout_ms: 'int' = 3000) -> 'None':
    # [PyArmor BCC constants]: '_LOCK', '_LIVE', 'isRunning', 'quit', 'wait', 'print', '[QThreadRegistry] worker ', 'type', '__name__', ' không dừng trong ', 'ms lúc thoát — bỏ qua', 'RuntimeError', 'Exception'
    pass
