"""
Decompiled / Reconstructed Module: services.shared.audio.audio_profile
Source PyC: audio_profile.pyc

Docstring:
services/shared/audio/audio_profile.py — deterministic AUDIO GENRE detection.

Vấn đề (bug 28/8/2026): khi audio-to-video đi qua SRT (block mode), model KHÔNG
nghe audio — chỉ đọc transcript. Mọi khoảng không lời ≥2s bị
``srt_source.fill_nonspeech_gaps`` dán nhãn ``silence "(no speech)"``. Với MV
ca nhạc, đó là NHẠC DẠO (intro/solo/outro) chứ không phải im lặng — model đọc
"(no speech)" là không còn cách nào phân loại SPEECH_DOMINANT vs MUSIC_DOMINANT
(guide genre chỉ có tác dụng khi model nghe audio thật), nên coi nhạc dạo là
thời gian chết → lệch timing, thiếu cảnh, khớp thời lượng < 100%.

Fix: đo bằng ffmpeg ``silencedetect`` (local, 0 LLM cost):
  - khoảng không lời NẰM TRONG cửa sổ im lặng thật  → giữ ``silence``;
  - khoảng không lời VẪN CÓ NĂNG LƯỢNG ÂM THANH     → ``music`` (instrumental).
Rồi inject 1 block "AUDIO GENRE PROFILE" (kết quả đo thật, không phải LLM tự
đoán) vào Pass-0 và block prompt để dạy model map cấu trúc bài hát.

Fail-open: ffmpeg lỗi/thiếu → windows rỗng, fallback heuristic theo độ dài gap,
không bao giờ làm hỏng job phân tích.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
List = typing.List
Optional = typing.Optional
Tuple = typing.Tuple
_MUSIC_GAP_MIN_DEFAULT = 8.0
_NOISE_FLOOR_DEFAULT = -35
_SILENCE_MIN_D_DEFAULT = 2.0
_SILENCE_START_RE = re.compile('silence_start:\\s*(-?[\\d.]+)')
_SILENCE_END_RE = re.compile('silence_end:\\s*(-?[\\d.]+)')
_WINDOWS_CACHE = {}

# --- Top-Level Functions ---
def _music_gap_min() -> 'float':
    pass

def detect_silence_windows(audio_path: 'str', audio_duration: 'float') -> 'List[Tuple[float, float]]':
    """Cửa sổ im lặng THẬT (năng lượng < noise floor ≥ min duration) của file audio.

    Trả [] khi ffmpeg thiếu/lỗi — caller phải xử lý như 'chưa xác minh được'."""
    pass

def _merge_windows(windows: 'List[Tuple[float, float]]') -> 'List[Tuple[float, float]]':
    pass

def _overlap_seconds(a_start: 'float', a_end: 'float', windows: 'List[Tuple[float, float]]') -> 'float':
    pass

def build_audio_profile(audio_path: 'str', audio_duration: 'float', segments: 'Optional[List[Dict[str, Any]]]') -> 'Dict[str, Any]':
    """Phân loại audio từ dữ liệu ĐO ĐƯỢC (không hỏi LLM).

    Trả profile dict:
      audio_kind: MUSIC_ONLY | MUSIC_DOMINANT | SPEECH_DOMINANT
      speech_ratio: tỉ lệ thời lượng có lời (speech / tổng)
      music_windows: [(start, end)] các đoạn không lời ≥ gap_min mà VẪN có tiếng
      music_seconds / silence_seconds / verified"""
    pass

def label_transcript_gaps(segments: 'List[Dict[str, Any]]', profile: 'Dict[str, Any]') -> 'List[Dict[str, Any]]':
    pass

def render_audio_genre_block(profile: 'Dict[str, Any]', clip_duration_seconds: 'int' = 8) -> 'str':
    """Block prompt AUDIO GENRE PROFILE — kết quả đo deterministic, đưa vào cả
    Pass-0 (story map) và unified prompt (block gen). Nhạc → dạy map cấu trúc
    bài hát; speech → note ngắn giữ pacing 1:1."""
    pass
