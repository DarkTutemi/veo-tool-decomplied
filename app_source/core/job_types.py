"""
Decompiled / Reconstructed Module: core.job_types
Source PyC: job_types.pyc
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['JobFeature', 'JobStatus', 'ACTIVE_JOB_STATUSES', 'TERMINAL_JOB_STATUSES', 'is_active_status', 'is_terminal_status']

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
ACTIVE_JOB_STATUSES = {<JobStatus.PENDING: 'pending'>, <JobStatus.UPSCALING: 'upscaling'>, <JobStatus.QUEUED: 'queued'>, <JobStatus.GENERATING: 'generating'>, <JobStatus.WAITING: 'waiting'>, <JobStatus.PROCESSING: 'process... [truncated]
TERMINAL_JOB_STATUSES = {<JobStatus.CANCELLED: 'cancelled'>, <JobStatus.COMPLETE: 'complete'>, <JobStatus.FAILED: 'failed'>}
__all__ = ['JobFeature', 'JobStatus', 'ACTIVE_JOB_STATUSES', 'TERMINAL_JOB_STATUSES', 'is_active_status', 'is_terminal_status']

# --- Class: JobFeature ---
class JobFeature(Enum):
    """High‑level feature / tab that produced a job."""
    _use_args_ = False
    _member_names_ = ['MASTER_PROMPT', 'TEXT2VIDEO_16_9', 'TEXT2VIDEO_9_16', 'IMAGE_TO_VIDEO', 'PORTRAIT_VIDEO', 'MULTI_ASSET_VIDEO', 'CLONE_...
    _member_map_ = {'MASTER_PROMPT': <JobFeature.MASTER_PROMPT: 'master_prompt'>, 'TEXT2VIDEO_16_9': <JobFeature.TEXT2VIDEO_16_9: 'text2vid...
    _value2member_map_ = {'master_prompt': <JobFeature.MASTER_PROMPT: 'master_prompt'>, 'text2video_16_9': <JobFeature.TEXT2VIDEO_16_9: 'text2vid...
    _unhashable_values_ = []
    _value_repr_ = None
    MASTER_PROMPT = <JobFeature.MASTER_PROMPT: 'master_prompt'>
    TEXT2VIDEO_16_9 = <JobFeature.TEXT2VIDEO_16_9: 'text2video_16_9'>
    TEXT2VIDEO_9_16 = <JobFeature.TEXT2VIDEO_9_16: 'text2video_9_16'>
    IMAGE_TO_VIDEO = <JobFeature.IMAGE_TO_VIDEO: 'image_to_video'>
    PORTRAIT_VIDEO = <JobFeature.PORTRAIT_VIDEO: 'portrait_video'>
    MULTI_ASSET_VIDEO = <JobFeature.MULTI_ASSET_VIDEO: 'multi_asset_video'>
    CLONE_VIDEO = <JobFeature.CLONE_VIDEO: 'clone_video'>
    TRANSCRIPT_VIDEO = <JobFeature.TRANSCRIPT_VIDEO: 'transcript_video'>
    AFFILIATE_VIDEO = <JobFeature.AFFILIATE_VIDEO: 'affiliate_video'>
    IMAGE_GENERATION = <JobFeature.IMAGE_GENERATION: 'image_generation'>
    EXTEND_VIDEO = <JobFeature.EXTEND_VIDEO: 'extend_video'>
    UPSCALE = <JobFeature.UPSCALE: 'upscale'>

    @staticmethod
    def _generate_next_value_(name, start, count, last_values):
        """Generate the next value when not given.

        name: the name of the member
        start: the initial start value or None
        count: the number of existing members
        last_values: the list of values assigned"""
        pass

    def _new_member_(*args, **kwargs):
        """Create and return a new object.  See help(type) for accurate signature."""
        pass

    def _member_type_():
        """The base class of the class hierarchy.

When called, it accepts no arguments and returns a new featureless
instance that has no instance attributes and cannot be given any."""
        pass


# --- Class: JobStatus ---
class JobStatus(Enum):
    """Normalized job lifecycle states for UI + backend.

    NOTE: This is a high‑level status used by JobStore / JobPanel.
    Existing per‑tab enums (CloneJobStatus, TranscriptJobStatus, ...)
    can be mapped into this."""
    _use_args_ = False
    _member_names_ = ['PENDING', 'WAITING', 'QUEUED', 'GENERATING', 'POLLING', 'PROCESSING', 'UPSCALING', 'MERGING', 'RETRYING', 'COMPLETE', ...
    _member_map_ = {'PENDING': <JobStatus.PENDING: 'pending'>, 'WAITING': <JobStatus.WAITING: 'waiting'>, 'QUEUED': <JobStatus.QUEUED: 'que...
    _value2member_map_ = {'pending': <JobStatus.PENDING: 'pending'>, 'waiting': <JobStatus.WAITING: 'waiting'>, 'queued': <JobStatus.QUEUED: 'que...
    _unhashable_values_ = []
    _value_repr_ = None
    PENDING = <JobStatus.PENDING: 'pending'>
    WAITING = <JobStatus.WAITING: 'waiting'>
    QUEUED = <JobStatus.QUEUED: 'queued'>
    GENERATING = <JobStatus.GENERATING: 'generating'>
    POLLING = <JobStatus.POLLING: 'polling'>
    PROCESSING = <JobStatus.PROCESSING: 'processing'>
    UPSCALING = <JobStatus.UPSCALING: 'upscaling'>
    MERGING = <JobStatus.MERGING: 'merging'>
    RETRYING = <JobStatus.RETRYING: 'retrying'>
    COMPLETE = <JobStatus.COMPLETE: 'complete'>
    FAILED = <JobStatus.FAILED: 'failed'>
    CANCELLED = <JobStatus.CANCELLED: 'cancelled'>

    @staticmethod
    def _generate_next_value_(name, start, count, last_values):
        """Generate the next value when not given.

        name: the name of the member
        start: the initial start value or None
        count: the number of existing members
        last_values: the list of values assigned"""
        pass

    def _new_member_(*args, **kwargs):
        """Create and return a new object.  See help(type) for accurate signature."""
        pass

    def _member_type_():
        """The base class of the class hierarchy.

When called, it accepts no arguments and returns a new featureless
instance that has no instance attributes and cannot be given any."""
        pass


# --- Top-Level Functions ---
def is_active_status(status: 'JobStatus') -> 'bool':
    pass

def is_terminal_status(status: 'JobStatus') -> 'bool':
    pass
