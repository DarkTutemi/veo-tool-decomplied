"""
Decompiled / Reconstructed Module: utils.win_job_object

Docstring:
Windows Job Object — OS-level child process cleanup.

Creates a Job Object with JOB_OBJECT_LIMIT_KILL_ON_JOB_CLOSE.
When the parent process exits (even force-killed), Windows automatically
terminates ALL child processes assigned to this Job.

Usage (in main.py, before any subprocess spawn):
    from utils.win_job_object import init_job_object, assign_pid_to_job

    init_job_object()  # Call once at startup
"""

from __future__ import annotations
import sys, os, typing
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
_job_handle = None
kernel32 = <WinDLL 'kernel32', handle 7ffb91670000 at 0x21acfbe4ec0>
JobObjectExtendedLimitInformation = 9
JOB_OBJECT_LIMIT_KILL_ON_JOB_CLOSE = 8192
JOB_OBJECT_LIMIT_BREAKAWAY_OK = 2048
PROCESS_ALL_ACCESS = 2097151
PROCESS_SET_QUOTA = 256
PROCESS_TERMINATE = 1

# --- Class: IO_COUNTERS ---
class IO_COUNTERS(Structure):
    _fields_ = [('ReadOperationCount', <class 'ctypes.c_ulonglong'>), ('WriteOperationCount', <class 'ctypes.c_ulonglong'>), ('OtherOpe...
    ReadOperationCount = <Field type=c_ulonglong, ofs=0, size=8>
    WriteOperationCount = <Field type=c_ulonglong, ofs=8, size=8>
    OtherOperationCount = <Field type=c_ulonglong, ofs=16, size=8>
    ReadTransferCount = <Field type=c_ulonglong, ofs=24, size=8>
    WriteTransferCount = <Field type=c_ulonglong, ofs=32, size=8>
    OtherTransferCount = <Field type=c_ulonglong, ofs=40, size=8>


# --- Class: JOBOBJECT_BASIC_LIMIT_INFORMATION ---
class JOBOBJECT_BASIC_LIMIT_INFORMATION(Structure):
    _fields_ = [('PerProcessUserTimeLimit', <class 'ctypes.c_longlong'>), ('PerJobUserTimeLimit', <class 'ctypes.c_longlong'>), ('Limit...
    PerProcessUserTimeLimit = <Field type=c_longlong, ofs=0, size=8>
    PerJobUserTimeLimit = <Field type=c_longlong, ofs=8, size=8>
    LimitFlags = <Field type=c_ulong, ofs=16, size=4>
    MinimumWorkingSetSize = <Field type=c_ulonglong, ofs=24, size=8>
    MaximumWorkingSetSize = <Field type=c_ulonglong, ofs=32, size=8>
    ActiveProcessLimit = <Field type=c_ulong, ofs=40, size=4>
    Affinity = <Field type=LP_c_ulong, ofs=48, size=8>
    PriorityClass = <Field type=c_ulong, ofs=56, size=4>
    SchedulingClass = <Field type=c_ulong, ofs=60, size=4>


# --- Class: JOBOBJECT_EXTENDED_LIMIT_INFORMATION ---
class JOBOBJECT_EXTENDED_LIMIT_INFORMATION(Structure):
    _fields_ = [('BasicLimitInformation', <class 'utils.win_job_object.JOBOBJECT_BASIC_LIMIT_INFORMATION'>), ('IoInfo', <class 'utils.w...
    BasicLimitInformation = <Field type=JOBOBJECT_BASIC_LIMIT_INFORMATION, ofs=0, size=64>
    IoInfo = <Field type=IO_COUNTERS, ofs=64, size=48>
    ProcessMemoryLimit = <Field type=c_ulonglong, ofs=112, size=8>
    JobMemoryLimit = <Field type=c_ulonglong, ofs=120, size=8>
    PeakProcessMemoryUsed = <Field type=c_ulonglong, ofs=128, size=8>
    PeakJobMemoryUsed = <Field type=c_ulonglong, ofs=136, size=8>


# --- Top-Level Functions ---
def init_job_object():
    # [PyArmor BCC constants]: 'sys', 'platform', 'win32', 'VeoFlow_Job_', 'os', 'getpid', 'kernel32', 'CreateJobObjectW', '_job_handle', 'print', '[JobObject] CreateJobObjectW failed: ', 'ctypes', 'get_last_error', 'JOBOBJECT_EXTENDED_LIMIT_INFORMATION', 'JOB_OBJECT_LIMIT_KILL_ON_JOB_CLOSE'
    pass

def assign_pid_to_job(pid: int) -> bool:
    # [PyArmor BCC constants]: '_job_handle', 'sys', 'platform', 'win32', False, 'kernel32', 'OpenProcess', 'PROCESS_SET_QUOTA', 'PROCESS_TERMINATE', 'AssignProcessToJobObject', 'CloseHandle', 'bool', 'Exception'
    pass

def is_active() -> bool:
    pass
