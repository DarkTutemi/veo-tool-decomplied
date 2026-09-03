"""
Decompiled / Reconstructed Module: services.tabs.image_story.image_analyzer_service
Source PyC: image_analyzer_service.pyc

Docstring:
Audio → still-image storyboard analyzer.

The image counterpart of ``transcript_analyzer_service``. Same audio plumbing
(upload once, duration probe, provider call, JSON parse, entity coercion) but a
SINGLE-FRAME prompt contract (``image_module_contract``) and VARIABLE contiguous
time windows selected by the LLM under the user's rhythm intent. The backend maps,
validates and seals that semantic plan; it never invents replacement cut points.

Deliberately does NOT reuse ``_call_ai_for_scenes``: that path drives the video
block-gateway (fixed clip cadence + manifest validation), which would force
uniform windows. We call the provider directly (``blocks=None``) for one holistic
pass with variable windows, then validate/repair coverage.

Returns a storyboard dict shaped like the transcript result so the existing
downstream (``build_image_story``, chargen) consumes it unchanged:
  {total_duration, scenes[], segments[](alias), entity_library, anchor_plan}
Each scene: {time, start_time, end_time, duration_seconds, visual (compiled
prompt), image, motion_hint, transition, entities/entity_ids}.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Callable = typing.Callable
Dict = typing.Dict
List = typing.List
Optional = typing.Optional
MAX_GROUPS_PER_PASS1_CALL = 40
_MIN_SCENE_SECONDS = 1
_MAX_SCENE_SECONDS = 10
_ROW_PACE_RULES = {'auto': '   - ADAPTIVE RHYTHM: decide EACH cut directly from what the complete audio is doing. Do NOT\n     choose one global density/profile and do NOT target an average seconds-per-image.\n   - A d... [truncated]
_PACING_PROFILES = {'auto': {'min_window_s': 20.0, 'densest_s': 30.0}, 'moderate': {'min_window_s': 45.0, 'densest_s': 60.0}, 'sparse': {'min_window_s': 120.0, 'densest_s': 180.0}}
_MAX_ATTEMPTS = 3
_PASS1_VALIDATION_ATTEMPTS = 3
_PASS1_VALIDATION_RETRY_DELAY_SECONDS = 3.0

# --- Class: ImageAnalyzerService ---
class ImageAnalyzerService:
    """Analyze audio into a still-image storyboard (variable windows)."""
    ai_provider = <property object at 0x00000264E678C590>

    def __init__(self, settings=None) -> 'None':
        pass

    def analyze_image_story(self, *, transcript_text: 'str' = '', audio_file_path: 'str', config: 'Optional[Dict[str, Any]]' = None, pre_selected_entity_library: 'Optional[Dict[str, Any]]' = None, progress_callback: 'Optional[Callable[[str], None]]' = None, pre_uploaded_file_uri: 'Optional[str]' = None, srt_path: 'str' = '') -> 'Dict[str, Any]':
        pass

    def _analyze_holistic(self, *, transcript_text: 'str', audio_file_path: 'str', audio_duration: 'float', config: 'Dict[str, Any]', cached_file_uri: 'Optional[str]', cached_mime_type: 'Optional[str]', pre_selected_entity_library: 'Optional[Dict[str, Any]]', progress_callback: 'Optional[Callable[[str], None]]', srt_segments: 'Optional[List[Dict[str, Any]]]' = None) -> 'Dict[str, Any]':
        pass

    @staticmethod
    def _analysis_timeout(audio_duration: 'float') -> 'int':
        pass

    def _call_provider(self, *, prompt: 'str', audio_file_path: 'Optional[str]', cached_file_uri: 'Optional[str]', cached_mime_type: 'Optional[str]', temperature: 'float', thinking_config: 'Optional[Dict[str, Any]]', completion_spec: 'Optional[Dict[str, Any]]', progress_callback: 'Optional[Callable]', timeout: 'int' = 900, attach_media: 'bool' = True) -> 'str':
        pass

    def _transcribe_via_provider(self, *, audio_file_path: 'str', audio_duration: 'float', cached_file_uri: 'Optional[str]', cached_mime_type: 'Optional[str]', progress_callback: 'Optional[Callable]') -> 'Optional[List[Dict[str, Any]]]':
        pass

    def _rows_to_grouped_beats(self, groups: 'Any', segments: 'List[Dict[str, Any]]') -> 'List[Dict[str, Any]]':
        """Nhóm-số-hàng của LLM → beats với mốc THẬT của hàng. LLM chỉ nói
        "hàng #a-#b chung 1 ý" (bài đọc-hiểu, sở trường); mọi con số thời gian
        lấy từ transcript — nó không thể làm lệch giờ. Chuẩn hoá bất chấp LLM
        trả xấu: hàng bỏ sót → group đơn, chồng lấn → cắt, phủ kín #1..#n."""
        pass

    @staticmethod
    def _coerce_group_rows(group: 'Any') -> 'Optional[tuple]':
        pass

    @staticmethod
    def _normalize_row_groups(groups: 'Any', row_count: 'int') -> 'tuple':
        pass

    @staticmethod
    def _rebalance_row_groups_to_count(groups: 'List[Dict[str, Any]]', row_count: 'int', target: 'int') -> 'List[Dict[str, Any]]':
        pass

    @staticmethod
    def _validate_row_groups(groups: 'Any', row_count: 'int', *, expected_group_count: 'int' = 0, min_group_count: 'int' = 0, max_group_count: 'int' = 0) -> 'tuple[bool, str]':
        pass

    @staticmethod
    def _plan_pass1_partition(*, has_srt: 'bool', row_count: 'int', expected_group_count: 'int', envelope_min: 'int', envelope_max: 'int', pacing: 'str', audio_duration: 'float') -> 'Optional[Dict[str, Any]]':
        """Quyết Pass-1 chạy 1 call hay chia cửa sổ — MỌI rhythm mode dùng chung.

        Trả None = 1 call (budget ≤ MAX_GROUPS_PER_PASS1_CALL). Ngược lại:
          {"policy": "quota"|"coverage", "target": int, "rules": str}
          - fixed/manual: target = effective count, policy quota
          - detailed/balanced/chapter: target = midpoint envelope (deterministic
            trong [min,max]), policy quota
          - auto: target = ước lượng theo mật độ (2.5s/ảnh), policy coverage"""
        pass

    @staticmethod
    def _plan_slice_windows(srt_segments: 'List[Dict[str, Any]]', target: 'int', max_per_call: 'int', row_weights: 'Optional[List[float]]' = None) -> 'List[Any]':
        """Chia rows thành các cửa sổ LIỀN KỀ theo thời lượng + quota mỗi cửa sổ.

        Trả [(row_start, row_end_exclusive, quota)] với: Σquota = target,
        quota ≤ max_per_call, quota ≥ 1, quota ≤ số row cửa sổ. Ưu tiên cửa sổ
        đủ dài (quota ∝ thời lượng) — mật độ đều giữa các cửa sổ.
        ``row_weights`` (template curve): chia cửa sổ theo CỘNG TRỌNG SỐ thay vì
        thời lượng trần → cửa sổ vùng dày ngắn hơn, vùng thưa dài hơn; quota đều
        mỗi cửa sổ → mật độ tự theo curve."""
        pass

    @staticmethod
    def _pack_slice_windows_by_rows(n: 'int', target: 'int', max_per_call: 'int') -> 'List[Any]':
        pass

    def _build_window_partition_prompt(self, *, slice_rows: 'List[Dict[str, Any]]', quota: 'int', avg_hold_s: 'float', slice_index: 'int', slice_total: 'int', requested_total: 'int', count_policy: 'str' = 'quota', rules_block: 'str' = '') -> 'str':
        """Prompt dedicated cho MỘT cửa sổ — chung engine cho MỌI rhythm mode,
        chỉ khác khối count-instruction (quota/coverage) + rules theo mode."""
        pass

    @staticmethod
    def _exact_count_pacing_block(quota: 'int', row_count: 'int', avg_hold_s: 'float') -> 'str':
        pass

    def _pick_rhythm_template(self, *, audio_file_path: 'Optional[str]', cached_file_uri: 'Optional[str]', cached_mime_type: 'Optional[str]', progress_callback: 'Optional[Callable]') -> 'str':
        pass

    def _llm_partition_windowed(self, *, srt_segments: 'List[Dict[str, Any]]', expected_group_count: 'int', audio_file_path: 'Optional[str]', cached_file_uri: 'Optional[str]', cached_mime_type: 'Optional[str]', deep: 'bool', config: 'Dict[str, Any]', progress_callback: 'Optional[Callable]', trace_id: 'str', count_policy: 'str' = 'quota', rules_block: 'str' = '', template_id: 'str' = '') -> 'List[Dict[str, Any]]':
        """Pass-1 CHIA CỬA SỔ khi số group vượt sức 1 call — engine CHUNG cho mọi
        rhythm mode (exact=quota, envelope=quota-at-midpoint, auto=coverage).

        Mỗi cửa sổ: rows renumber + quota — LLM vẫn quyết mọi ranh giới ngữ
        nghĩa TRONG cửa sổ của nó; backend xác thực từng miếng rồi ghép.
        policy="quota": Σquota = expected_group_count (đúng số ảnh).
        policy="coverage": chỉ bắt phủ trọn, số lượng do nội dung quyết.
        template_id (mode template): AUTO → picker call chọn curve; cửa sổ
        chia theo cumulative WEIGHTED duration (vùng dày ngắn/quota dày hơn).
        Lỗi 1 cửa sổ → raise (outer Pass-1 retry loop chạy lại toàn bộ)."""
        pass

    def _snap_beats_to_boundaries(self, beats: 'List[Dict[str, Any]]', bounds: 'List[float]', tol: 'float' = 0.75) -> 'List[Dict[str, Any]]':
        """Hút mốc cắt về biên câu/segment THẬT gần nhất (≤ tol giây). LLM đọc
        transcript chọn mốc theo NGHĨA; số giây chính xác thuộc về transcript —
        triệt drift lẻ của con số LLM tự gõ. Mốc xa mọi biên (> tol, ví dụ cắt
        giữa 1 câu dài) giữ nguyên — vẫn là quyền tự do của model."""
        pass

    def _analyze_two_pass(self, *, transcript_text: 'str', audio_file_path: 'str', audio_duration: 'float', config: 'Dict[str, Any]', cached_file_uri: 'Optional[str]', cached_mime_type: 'Optional[str]', pre_selected_entity_library: 'Optional[Dict[str, Any]]', progress_callback: 'Optional[Callable[[str], None]]', srt_segments: 'Optional[List[Dict[str, Any]]]' = None) -> 'Dict[str, Any]':
        pass

    @staticmethod
    def _loose_json(text: 'str') -> 'Dict[str, Any]':
        pass

    def _coerce_seconds(self, raw: 'Any') -> 'Optional[float]':
        pass

    @staticmethod
    def _pacing_mode(config: 'Optional[Dict[str, Any]]') -> 'str':
        pass

    @staticmethod
    def _manual_image_target(config: 'Optional[Dict[str, Any]]') -> 'int':
        pass

    @staticmethod
    def _effective_manual_target(config: 'Optional[Dict[str, Any]]', audio_duration: 'float') -> 'int':
        pass

    def _enforce_auto_pacing(self, windows: 'List[Dict[str, Any]]', audio_duration: 'float', min_window_s: 'float', densest_s: 'float') -> 'List[Dict[str, Any]]':
        """Legacy deterministic pacing utility retained for old artifacts/tests.

        The live Rhythm Framework no longer calls this function: semantic merges
        belong to the LLM correction loop, while the backend only validates the
        declared profile budget and maps accepted row groups to timestamps.

        Legacy behavior:
        (1) window < min_window_s gộp gom-tới-ngưỡng;
        (2) tổng > ceil(duration/densest_s) → lặp gộp cặp liên tiếp ngắn nhất
        tới khi đạt trần. Giữ contiguity + Σ = audio."""
        pass

    def _windows_from_beats(self, beats: 'List[Dict[str, Any]]', audio_duration: 'float', min_s: 'float', max_s: 'float') -> 'List[Dict[str, Any]]':
        pass

    def _finalize_windows(self, windows: 'List[Dict[str, Any]]', content_scenes: 'List[Dict[str, Any]]', audio_duration: 'float', config: 'Dict[str, Any]') -> 'List[Dict[str, Any]]':
        pass

    @staticmethod
    def _normalize_scene_entity_states(scene: 'Dict[str, Any]') -> 'Dict[str, Any]':
        pass

    def _library_lens_line(self, config: 'Dict[str, Any]') -> 'str':
        pass

    def _library_control_block(self, config: 'Dict[str, Any]', pre_selected_entity_library: 'Optional[Dict[str, Any]]') -> 'str':
        pass

    def _build_beat_map_prompt(self, *, transcript_text: 'str', audio_duration: 'float', config: 'Dict[str, Any]', pre_selected_entity_library: 'Optional[Dict[str, Any]]', min_s: 'float', max_s: 'float', row_mode: 'bool' = False, row_count: 'int' = 0) -> 'str':
        pass

    def _build_content_prompt(self, *, windows: 'List[Dict[str, Any]]', entity_library: 'Dict[str, Any]', config: 'Dict[str, Any]', transcript_text: 'str', total: 'int') -> 'str':
        pass

    @staticmethod
    def _comprehension_block() -> 'str':
        pass

    @staticmethod
    def _entity_description_block() -> 'str':
        pass

    @staticmethod
    def _directors_brief_block(user_instruction: 'str') -> 'str':
        pass

    def _build_image_prompt(self, *, transcript_text: 'str', audio_duration: 'float', config: 'Dict[str, Any]', pre_selected_entity_library: 'Optional[Dict[str, Any]]') -> 'str':
        pass

    def _normalize_image_scenes(self, raw_scenes: 'List[Dict[str, Any]]', audio_duration: 'float', config: 'Dict[str, Any]', stats: 'Optional[Dict[str, int]]' = None) -> 'List[Dict[str, Any]]':
        pass

    @staticmethod
    def _scene_entity_ids(scene: 'Dict[str, Any]') -> 'List[str]':
        pass

    @staticmethod
    def _normalize_motion_hint(raw: 'Any', duration: 'float', index: 'int') -> 'Dict[str, Any]':
        pass


# --- Top-Level Functions ---
def _pass1_center_already_exhausted(error: 'BaseException') -> 'bool':
    pass

def _pass1_retry_plan(error: 'BaseException', failed_attempt: 'int') -> 'tuple[Optional[float], int]':
    pass
