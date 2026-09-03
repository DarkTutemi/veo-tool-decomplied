"""
Decompiled / Reconstructed Module: utils.video_merger

Docstring:
Video Merger Utility
Automatically merge all videos in a session folder into a single file using ffmpeg
Uses copy codec for fast merging without re-encoding
"""

from __future__ import annotations
import sys, os, typing
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['VideoMerger', 'get_video_merger', 'merge_session_videos']

# --- Module Constants & Globals ---
List = typing.List
Optional = typing.Optional
_ENCODER_ARGS_LOGGED = False
_video_merger = None
__all__ = ['VideoMerger', 'get_video_merger', 'merge_session_videos']

# --- Class: VideoMergerWorker ---
class VideoMergerWorker(QThread):
    """
    Background worker for merging videos without blocking UI
    
        Signals:
            merge_completed: Emitted when merge finishes (success: bool, output_path: str, error_msg: str)
            progress_update: Emitted during merge (message: str)
    """
    staticMetaObject = PySide6.QtCore.QMetaObject("VideoMergerWorker" inherits "QThread":
Methods:
  #12 type=Signal, signature=merge_completed...

    merge_completed = Signal()
    progress_update = Signal()
    def __init__(self, session_folder: str, output_filename: str = 'merged_video.mp4', naming_pattern: str = None):
        """
        Initialize worker
        
                Args:
                    session_folder: Path to session folder containing videos
                    output_filename: Name of merged output file
                    naming_pattern: Naming pattern used for videos
        """
        pass

    def run(self):
        # [PyArmor BCC constants]: 'progress_update', 'emit', '🎞️ Starting merge in: ', 'session_folder', 'merger', 'merge_session_videos', 'output_filename', 'naming_pattern', 'progress_callback', '✅ Merge completed: ', 'merge_completed', True, '', 'No merge needed (only 1 video, no videos, or unsupported naming pattern)', 'ℹ️ '
        pass


# --- Class: VideoMerger ---
class VideoMerger:
    """
    Merge multiple videos into a single file using ffmpeg concat
    
        Features:
        - Auto-detect videos in session folder
        - Sort by scene number (SCENE_001, SCENE_002, ...)
        - Use copy codec for fast merging (no re-encoding)
        - Save merged file in same session folder
        - Auto-detect GPU encoder (NVENC > QSV > AMF > CPU fallback)
    """
    _detected_encoder = None
    _detected_preset = None
    XFADE_MAX_INPUTS = 16
    _GPU_CODECS = ('h264_nvenc', 'hevc_nvenc', 'h264_qsv', 'hevc_qsv', 'h264_amf', 'hevc_amf')

    def __init__(self, ffmpeg_path: str = None):
        # [PyArmor BCC constants]: 'get_ffmpeg_binary', 'ffmpeg', 'ffmpeg_path', '_get_ffprobe_path', 'ffprobe_path', '_active_process', False, '_cancel_requested', 'was_cancelled', 'os', 'path', 'exists', 'FileNotFoundError', 'ffmpeg not found at: ', 'print'
        pass

    def cancel(self) -> None:
        # [PyArmor BCC constants]: True, '_cancel_requested', 'was_cancelled', '_active_process', 'terminate', 'Exception'
        pass

    def _begin_process(self, process) -> None:
        pass

    def _end_process(self) -> None:
        pass

    @staticmethod
    def _get_ffprobe_path() -> str:
        # [PyArmor BCC constants]: 'get_ffmpeg_binary', 'ffprobe', 'print', '⚠️ [VideoMerger] ffprobe unavailable: ', '', 'Exception'
        pass

    @staticmethod
    def _has_audio_stream(video_path: str) -> bool:
        # [PyArmor BCC constants]: 'VideoMerger', '_get_ffprobe_path', True, 'subprocess', 'run', '-v', 'error', '-select_streams', 'a', '-show_entries', 'stream=index', '-of', 'csv=p=0', 'capture_output', 'encoding'
        pass

    @staticmethod
    def get_video_resolution(video_path: str) -> Optional[tuple]:
        # [PyArmor BCC constants]: 'VideoMerger', '_get_ffprobe_path', 'subprocess', 'run', '-v', 'error', '-select_streams', 'v:0', '-show_entries', 'stream=width,height', '-of', 'csv=s=x:p=0', 'capture_output', True, 'encoding'
        pass

    @staticmethod
    def get_encoding_params_for_resolution(width: int, height: int) -> dict:
        # [PyArmor BCC constants]: 3840, 2160, 'maxrate', '45M', 'bufsize', '90M', 'level', '5.1', 'tier', '4K', 2560, 1440, '24M', '48M', '2K'
        pass

    @staticmethod
    def detect_best_encoder(ffmpeg_path: str = None) -> tuple:
        # [PyArmor BCC constants]: 'VideoMerger', '_detected_encoder', '_detected_preset', 'get_ffmpeg_binary', 'ffmpeg', 'os', 'path', 'exists', 'FileNotFoundError', 'ffmpeg not found at: ', 'subprocess', 'run', '-f', 'lavfi', '-i'
        pass

    @staticmethod
    def detect_encoder(ffmpeg_path: str = None) -> tuple:
        pass

    def merge_session_videos(self, session_folder: str, output_filename: str = 'merged_video.mp4', naming_pattern: str = None, progress_callback=None) -> Optional[str]:
        # [PyArmor BCC constants]: '_find_videos_in_folder', 'print', '⚠️ [VideoMerger] No videos found in: ', 'len', 1, 'ℹ️ [VideoMerger] Only 1 video found, no merge needed: ', 0, '_detect_naming_pattern', 'number_only', '⚠️ [VideoMerger] Merge not supported for naming pattern: ', "ℹ️ [VideoMerger] Only 'number_only' pattern (1.1.mp4, 2.1.mp4) is supported for merging", '📹 [VideoMerger] Found ', ' videos to merge (pattern: ', ')', '📹 Found '
        pass

    @staticmethod
    def _picture_clock_frame_counts(target_durations: Union[List[float], tuple[float, ...]], fps: int = 24) -> List[int]:
        # [PyArmor BCC constants]: 'max', 1, 'int', 24, 0.0, 0, 'float', 'math', 'isfinite', 'ValueError', 'Invalid picture-clock duration: ', 'ceil', 1e-09, 'append'
        pass

    @staticmethod
    def _picture_clock_video_filter(frame_count: int, fps: int = 24) -> str:
        # [PyArmor BCC constants]: 'max', 1, 'int', 24, 'float', 1.0, 'settb=AVTB,setsar=sar=1,fps=', ',tpad=stop_mode=clone:stop_duration=', '.6f', ',trim=end_frame=', ',setpts=N/', '/TB'
        pass

    @staticmethod
    def _picture_clock_encoder_args(codec: str, preset: str, fps: int = 24) -> List[str]:
        # [PyArmor BCC constants]: 'max', 1, 'int', 24, '-preset', '-tune', 'hq', '-rc', 'vbr', '-cq', '18', '-global_quality', '-quality', '-qp_i', '-qp_p'
        pass

    def merge_videos_to_timeline(self, video_configs: List[dict], output_path: str, target_durations: Union[List[float], tuple[float, ...]], fps: int = 24) -> bool:
        # [PyArmor BCC constants]: 'len', 'print', '❌ [VideoMerger] Picture-clock input mismatch: ', '/', False, 'os', 'path', 'dirname', 'abspath', 'makedirs', 'exist_ok', True, 'mkdtemp', 'prefix', '.picture_clock_'
        pass

    def merge_videos_hard_cut(self, video_configs: List[dict], output_path: str) -> bool:
        # [PyArmor BCC constants]: 'str', 'get', 'path', '', 'strip', 'os', 'realpath', 'isfile', 'print', '❌ [VideoMerger] Hard-cut merge: no source videos', False, 'len', 1, 'copy2', 0
        pass

    def merge_videos_with_offsets(self, video_configs: List[dict], output_path: str) -> bool:
        # [PyArmor BCC constants]: 'os', 'path', 'dirname', 'join', '_temp_cut_videos', 'makedirs', 'exist_ok', True, 'print', '✂️ [VideoMerger] Pre-cutting videos with offsets (RE-ENCODE mode)...', 'enumerate', 'get', 'inpoint', 0, 'outpoint'
        pass

    def merge_videos_with_xfade(self, video_configs: List[dict], output_path: str, xfade_duration: float = 0.083, transition_type: str = 'fade', codec: str = 'auto', crf: int = 18, preset: str = None, audio_bitrate: str = '192k', profile: str = None, rc_mode: str = 'vbr', multipass: str = None, spatial_aq: bool = False, temporal_aq: bool = False, rc_lookahead: int = 0, b_ref_mode: str = None, bf: int = 2, _allow_chunk: bool = True) -> bool:
        """
        Merge videos using xfade filter for seamless transitions (micro-crossfade)
        
                This method uses ffmpeg's xfade filter to create very short crossfades
                between videos, eliminating the micro-stutter that can occur with concat demuxer.
        
                Args:
                    video_configs: List of dicts with 'path', 'inpoint', 'outpoint'
                    output_path: Output file path
                    xfade_duration: Duration of crossfade in seconds (default 0.083s)
                    transition_type: Type of transition for xfade filter (default "fade")
                    codec: Video codec ("auto" = auto-detect GPU, or specify: h264_nvenc, h264_qsv, h264_amf, libx264)
                    crf: Constant Rate Factor for quality (default 18, lower = better quality)
                    preset: Encoding preset (auto-detected based on codec if None)
                    audio_bitrate: Audio bitrate (default "192k")
        
                Returns:
                    True if succeeded
        """
        # [PyArmor BCC constants]: '-f', 'lavfi', '-i', 'anullsrc=channel_layout=stereo:sample_rate=48000'
        pass

    @staticmethod
    def _is_gpu_error(stderr: str) -> bool:
        # [PyArmor BCC constants]: 'no nvenc capable devices', 'no capable devices found', 'cannot load nvcuda', 'cannot load cuda', 'cannot init cuda', 'cannot initialize cuda', 'openencodesessionex failed', 'no free encoding sessions', 'driver does not support', 'nvenc api version', 'failed to initialise', 'out of memory', 'unknown encoder', 'error initializing an mfx session', 'device creation failed'
        pass

    def _probe_duration(self, path: str) -> Optional[float]:
        # [PyArmor BCC constants]: 'ffprobe_path', 'subprocess', 'run', '-v', 'error', '-show_entries', 'format=duration', '-of', 'default=noprint_wrappers=1:nokey=1', 'capture_output', True, 'encoding', 'utf-8', 'errors', 'replace'
        pass

    def _probe_nb_frames(self, path: str) -> Optional[int]:
        # [PyArmor BCC constants]: 'ffprobe_path', 'subprocess', 'run', '-v', 'error', '-select_streams', 'v:0', '-show_entries', 'stream=nb_frames', '-of', 'default=noprint_wrappers=1:nokey=1', 'capture_output', True, 'encoding', 'utf-8'
        pass

    @staticmethod
    def _chunk_ranges(n: int, k: int) -> List[tuple]:
        # [PyArmor BCC constants]: 0, 'min', 'append', 'len', 2, 1, 'pop', 'tuple'
        pass

    def _seg_video_args(self, codec, preset, crf, level, fps, bf, profile=None, rc_mode='vbr', multipass=None, spatial_aq=False, temporal_aq=False, rc_lookahead=0, b_ref_mode=None) -> List[str]:
        # [PyArmor BCC constants]: '-c:v', '-preset', '-tune', 'hq', '-profile', '-rc', 'vbr', '-cq', 'str', '-pix_fmt', 'yuv420p', '-bf', '-multipass', 'qres', '1'
        pass

    @staticmethod
    def _effective_source_frames(duration_s: float, fps: int, nb_frames=None) -> int:
        # [PyArmor BCC constants]: 'int', 'float', 1e-09, 'min', 'max', 0, 'TypeError', 'ValueError'
        pass

    @staticmethod
    def _norm_v(idx, start_f, end_f, fps, label):
        # [PyArmor BCC constants]: '[', ':v]settb=AVTB,setsar=sar=1,fps=', ',trim=start_frame=', ':end_frame=', ',setpts=N/', '/TB[', ']'
        pass

    @staticmethod
    def _norm_a(idx, start_f, end_f, fps, label, has_audio=True):
        # [PyArmor BCC constants]: 'anullsrc=r=48000:cl=stereo,atrim=end=', '.6f', ',asetpts=PTS-STARTPTS[', ']', '[', ':a]aresample=48000,atrim=start=', ':end='
        pass

    def _build_group_cmd(self, members, out_path, codec, preset, crf, level, fps, xf, transition_type, audio_bitrate, profile, rc_mode, multipass, spatial_aq, temporal_aq, rc_lookahead, b_ref_mode, bf) -> List[str]:
        # [PyArmor BCC constants]: 'ffmpeg_path', '-i', 'path', 'len', 'enumerate', 'start_f', 'end_f', 'append', '_norm_v', 'v', '_norm_a', 'a', 'VideoMerger', '_has_audio_stream', 0.0
        pass

    def _build_transition_cmd(self, a_path, a_s, a_e, b_path, b_s, b_e, out_path, codec, preset, crf, level, fps, xf, transition_type, audio_bitrate, profile, rc_mode, multipass, spatial_aq, temporal_aq, rc_lookahead, b_ref_mode, bf) -> List[str]:
        # [PyArmor BCC constants]: 'ffmpeg_path', '-i', '_norm_v', 0, 'v0', 1, 'v1', '[v0][v1]xfade=transition=', ':duration=', '.6f', ':offset=0[vout]', '_norm_a', 'a0r', 'VideoMerger', '_has_audio_stream'
        pass

    @staticmethod
    def _chunk_concat_cmd(ffmpeg_path: str, ordered_paths: List[str], output_path: str, audio_bitrate: str, width: int, height: int, codec: str, preset: str, crf: int, fps: int = 24) -> List[str]:
        """
        Join chunk/seam files on a rebuilt CFR timeline.
        
                Stream-copy concat of NVENC 4K segments often keeps PTS at 0 across
                files, so the picture freezes while audio plays. The concat filter
                re-stamps frames; setpts=N/fps/TB forbids duplicate last-frame pads.
        """
        pass

    def _run_seg(self, cmd, codec) -> str:
        # [PyArmor BCC constants]: 'subprocess', 'Popen', 'stdout', 'PIPE', 'stderr', 'bufsize', 1, 'encoding', 'utf-8', 'errors', 'replace', 'creationflags', 'os', 'name', 'nt'
        pass

    def _merge_xfade_chunked(self, video_configs, output_path, xfade_duration, transition_type, codec, crf, preset, audio_bitrate, profile, rc_mode, multipass, spatial_aq, temporal_aq, rc_lookahead, b_ref_mode, bf) -> bool:
        # [PyArmor BCC constants]: 'audio_bitrate', 'width', 'height', 'codec', 'preset', 'crf', 'fps'
        pass

    def _reencode_video(self, input_path: str, output_path: str, codec: str = 'libx264', crf: int = 18, preset: str = 'medium', audio_bitrate: str = '192k') -> bool:
        # [PyArmor BCC constants]: 'VideoMerger', 'get_video_resolution', 'get_encoding_params_for_resolution', 'print', '📐 [VideoMerger] Detected ', 'tier', ' (', 'x', ') → maxrate=', 'maxrate', ', level=', 'level', '45M', 'bufsize', '90M'
        pass

    def _find_videos_in_folder(self, folder: str) -> List[str]:
        # [PyArmor BCC constants]: '.mp4', '.mov', '.avi', '.mkv', 'os', 'listdir', 'path', 'join', 'lower', 'isfile', 'startswith', 'merged_', '_', '.trimmed.', 're'
        pass

    def _detect_naming_pattern(self, video_files: List[str]) -> str:
        # [PyArmor BCC constants]: 'unknown', 'os', 'path', 'basename', 0, 'splitext', 're', 'match', '^\\d+(\\.\\d+)?$', 'number_only', '^\\d{10,}_\\d+$', 'timestamp_only', '^.+_\\d+_\\d{10,}$', 'prompt_number', '^.+_\\d+$'
        pass

    def _sort_videos_by_number_pattern(self, video_files: List[str]) -> List[str]:
        # [PyArmor BCC constants]: 'os', 'path', 'basename', 'splitext', 0, 're', 'match', '^(\\d+)(?:\\.(\\d+))?$', 'int', 'group', 1, 2, 'findall', '\\d+', 'len'
        pass

    def _create_concat_file(self, folder: str, video_files: List[str]) -> str:
        # [PyArmor BCC constants]: 'os', 'path', 'join', 'concat_list.txt', 'open', 'w', 'encoding', 'utf-8', 'write', '_concat_line', 'print', '📝 [VideoMerger] Created concat file: '
        pass

    def _merge_with_ffmpeg(self, concat_file: str, output_path: str, force_reencode: bool = False, progress_callback=None) -> bool:
        # [PyArmor BCC constants]: False, 'open', 'r', 'encoding', 'utf-8', 'read', 'inpoint', 'outpoint', True, 'print', '🔍 [VideoMerger] Detected inpoint/outpoint → Force re-encode', '🎬 [VideoMerger] Using RE-ENCODE mode (smooth playback for cut videos)', '🎬 Re-encoding videos for smooth playback...', 'maxrate', '45M'
        pass


# --- Top-Level Functions ---
def _concat_line(path: str) -> str:
    # [PyArmor BCC constants]: 'os', 'path', 'abspath', 'replace', '\\', '/', "'", "'\\''", "file '", "'\n"
    pass

def ffmpeg_video_encode_args(*, still=False, fast=True) -> list:
    # [PyArmor BCC constants]: 'VideoMerger', 'detect_best_encoder', 'str', 'libx264', 'strip', 'lower', '_ENCODER_ARGS_LOGGED', 'print', '[VideoEncoder] codec=', ' preset=', ' fast=', 'flush', True, '-c:v', '-preset'
    pass

def get_video_merger() -> utils.video_merger.VideoMerger:
    pass

def merge_session_videos(session_folder: str, output_filename: str = 'merged_video.mp4') -> Optional[str]:
    pass
