"""
Decompiled / Reconstructed Module: services.tabs.transcript_video.transcript_analyzer_service
Source PyC: transcript_analyzer_service.pyc

Docstring:
Transcript Analyzer Service - Phân tích audio và tạo scenes theo duration UI

Logic đơn giản hóa (v2):
1. AI nhận audio file
2. AI tạo scenes theo clip_duration_seconds trực tiếp
3. Route sang Text-to-Video/Portrait tab

Duration lấy từ UI/model config: 4s, 6s, 8s, 10s.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
Dict = typing.Dict
List = typing.List
Optional = typing.Optional
Tuple = typing.Tuple
Union = typing.Union
Callable = typing.Callable
_GLOBAL_SCENE_PLAN_MAX_SCENES = 240

# --- Class: TranscriptAnalyzerService ---
class TranscriptAnalyzerService:
    """Service phân tích transcript và tạo scenes timeline"""
    ai_provider = <property object at 0x00000264E6FC7240>
    DEFAULT_CONTENT_PROFILE = {'topic': 'general', 'content_type': 'narrative', 'format': 'narration', 'purpose': 'entertain', 'visual_strategy': {'pr...
    CONTENT_ANALYSIS_GUIDE = '\n═══════════════════════════════════════════════════════════════\n📋 CONTENT ANALYSIS GUIDE — How to analyze audio for ...
    SCENE_WRITING_GUIDE = '\n═══════════════════════════════════════════════════════════════\n🎬 SCENE WRITING GUIDE\n═════════════════════════════...

    def __init__(self, settings=None):
        pass

    def _audio_upload_provider(self):
        pass

    def analyze_transcript(self, transcript_text: str, visual_style: Optional[str] = None, temperature: float = 1.0, audio_file_path: Optional[str] = None, output_folder: Optional[str] = None, scene_interval: Union[int, str] = 8, pre_selected_asset_library: Optional[Dict] = None, pre_selected_entity_library: Optional[Dict] = None, library_policy: Optional[Dict] = None, target_market: str = 'global', deep_analysis: bool = False, progress_callback: Optional[Callable] = None, content_context: Optional[Dict] = None, pre_uploaded_file_uri: Optional[str] = None, user_instruction: Optional[str] = None, enable_char_consistency: bool = False, structural_style_id: str = '', structural_camera_id: str = '', surface_style_id: str = '', surface_camera_id: str = '', clip_duration_seconds: int = 8, aspect_ratio: str = '16:9', enable_flow_voice_lock: bool = False, video_model_key: str = '', srt_path: str = '', subtitle_profile: Optional[Dict] = None, content_language: str = '') -> Dict:
        pass

    def _analyze_and_create_duration_scenes(self, audio_file_path: str, audio_duration: float, visual_style: Optional[str], temperature: float, pre_selected_entity_library: Optional[Dict] = None, library_policy: Optional[Dict] = None, target_market: str = 'global', deep_analysis: bool = False, content_context: Optional[Dict] = None, pre_uploaded_file_uri: Optional[str] = None, progress_callback: Optional[Callable] = None, user_instruction: Optional[str] = None, enable_char_consistency: bool = False, style_package: Optional[Dict] = None, clip_duration_seconds: int = 8, aspect_ratio: str = '16:9', enable_flow_voice_lock: bool = False, video_model_key: str = '', srt_path: str = '', subtitle_profile: Optional[Dict] = None, content_language: str = '') -> Dict:
        """Single-call Visual DNA + Scene Generation.
        AI analyzes audio → returns Visual DNA + scenes in ONE response.
        1M token input, 65K output — plenty of room."""
        pass

    def _build_transcript_scene_module_contract(self, clip_duration_seconds: int, render_text_allowed: bool = True) -> str:
        pass

    @staticmethod
    def _is_vietnamese_language(content_language: str) -> bool:
        pass

    def _build_transcript_audio_understanding_guide(self, *, clip_duration_seconds: int, windows: List[str], is_block_mode: bool) -> str:
        pass

    def _build_transcript_module_scene_writing_guide(self, *, clip_duration_seconds: int, render_text_allowed: bool = True) -> str:
        pass

    def _build_transcript_external_audio_policy_guide(self) -> str:
        pass

    def _build_transcript_scene_output_example(self, *, clip_duration_seconds: int, windows: List[str], render_text_allowed: bool = True) -> str:
        pass

    def _build_entity_scene_output_contract(self, clip_duration_seconds: int, expected_scenes: int, include_publish_kit: bool = False) -> str:
        pass

    def estimate_prompt_tokens(self, duration_seconds: int = 60, clip_duration_seconds: int = 8, target_market: str = 'global') -> int:
        pass

    def estimate_output_tokens(self, duration_seconds: int = 60, clip_duration_seconds: int = 8) -> int:
        pass

    def _build_unified_prompt(self, audio_duration: float, expected_scenes: int, content_context: Optional[Dict], target_market: str, pre_selected_entity_library: Optional[Dict] = None, library_policy: Optional[Dict] = None, is_block_mode: bool = False, user_instruction: Optional[str] = None, enable_char_consistency: bool = False, style_package: Optional[Dict] = None, clip_duration_seconds: int = 8, enable_flow_voice_lock: bool = False, video_model_key: str = '', global_map_block: str = '', audio_profile_block: str = '', content_language: str = '') -> str:
        pass

    def _scrub_omitted_entity_example_keys(self, text, library_policy=None, pre_selected_entity_library=None):
        pass

    def _parse_unified_response(self, response_text: str) -> Dict:
        pass

    def _default_entity_library(self) -> Dict[str, List[Dict[str, Any]]]:
        pass

    @staticmethod
    def _has_entity_library_content(entity_library: Optional[Dict]) -> bool:
        pass

    def _coerce_entity_library(self, data: Optional[Dict]) -> Dict[str, List[Dict[str, Any]]]:
        pass

    def _ensure_entity_entry_defaults(self, entity_library: Dict[str, Any]) -> None:
        pass

    def _merge_entity_libraries(self, primary: Dict, secondary: Dict) -> Dict:
        pass

    def _normalize_anchor_plan(self, anchor_plan: Optional[Dict], entity_library: Optional[Dict]) -> Dict:
        pass

    def _normalize_block_plan(self, block_plan: Optional[Dict], scenes: Any, clip_duration_seconds: int) -> Dict:
        pass

    @staticmethod
    def _extract_entity_ids_from_text(text: str) -> Dict[str, List[str]]:
        pass

    def _normalize_scene_entities(self, scene: Dict[str, Any]) -> Dict[str, List[str]]:
        pass

    def _normalize_scene_timeline(self, scene: Dict[str, Any], *, source_range: str, clip_duration_seconds: int) -> List[Dict[str, Any]]:
        pass

    def _validate_adaptive_scene_timelines(self, scenes_list: List[Dict], *, clip_duration_seconds: int) -> None:
        """Reject malformed adaptive timelines while the AI retry loop is active.

        This validates structure only. Whether a boundary is semantically useful
        remains an audio-understanding decision; forcing deterministic diversity
        here would merely replace one stock rhythm with random variation."""
        pass

    def _normalize_transcript_scenes_for_dispatch(self, scenes_list: List[Dict], *, entity_library: Dict, clip_duration_seconds: int = 8) -> List[Dict]:
        pass

    def _enrich_entity_library_for_voice_lock(self, entity_library: Dict, *, scenes: List[Dict], model_key: str) -> Dict:
        pass

    def _parse_gap_fill_response(self, response_text: str, *, clip_duration_seconds: int = 8) -> Dict:
        pass

    def _legacy_convert_scenes_to_segments(self, scenes_list: List[Dict], style_package: Optional[Dict] = None, clip_duration_seconds: int = 8) -> List[Dict]:
        """Legacy adapter for old history/jobs. Runtime no longer calls this.

        Args:
            scenes_list: [{"time": "0-8", "audio_topic": "...", "visualization_type": "...", "visual": "..."}, ...]

        Returns:
            [{"segment_id": 0, "start_time": 0, "end_time": 8, "veo3_prompt": "...", "audio_topic": "...", "visualization_type": "..."}, ...]"""
        pass

    @staticmethod
    def _parse_time_to_seconds(t_str: str) -> float:
        pass

    def _validate_scenes_coverage(self, scenes_list: List[Dict], audio_duration: float, clip_duration_seconds: int = 8) -> Dict:
        pass

    def _get_adjacent_scenes(self, scenes: List[Dict], gap_start: int, gap_end: int) -> List[Dict]:
        pass

    def _build_gap_fill_prompt(self, gap_start: int, gap_end: int, scenes_needed: int, audio_duration: float, adjacent: List[Dict], pre_selected_entity_library: Optional[Dict] = None, target_market: str = 'global', clip_duration_seconds: int = 8, **legacy_kwargs) -> str:
        pass

    def _fill_gap_scenes(self, gaps: List, audio_duration: float, existing_scenes: List[Dict], audio_file_path: str, temperature: float, cached_file_uri: Optional[str], cached_mime_type: Optional[str], pre_selected_entity_library: Optional[Dict], target_market: str, clip_duration_seconds: int = 8) -> List[Dict]:
        pass

    def _fill_gap_scenes_individual(self, gaps: List, audio_duration: float, existing_scenes: List[Dict], audio_file_path: str, temperature: float, cached_file_uri: Optional[str], cached_mime_type: Optional[str], pre_selected_entity_library: Optional[Dict], target_market: str, clip_duration_seconds: int = 8) -> List[Dict]:
        pass

    def _recover_fork_runtime_before_upload_retry(self) -> None:
        pass

    def _upload_audio_once(self, audio_file_path: str) -> Tuple[Optional[str], Optional[str]]:
        """Upload audio file ONCE and return (file_uri, mime_type) for reuse.

        This prevents re-uploading the same audio on each retry attempt.

        Returns:
            Tuple of (file_uri, mime_type) or (None, None) if upload fails"""
        pass

    def _build_global_map_prompt(self, *, audio_duration: float, block_list_text: str, clip_duration_seconds: int, total_scenes: int, content_context: Optional[Dict], target_market: str, user_instruction: Optional[str], pre_selected_entity_library: Optional[Dict] = None, library_policy: Optional[Dict] = None, style_hint: str = '', include_scene_plan: bool = True, subtitle_profile: Optional[Dict] = None, content_language: str = '', source_kind: str = '', audio_profile_block: str = '') -> str:
        pass

    def _build_global_map(self, *, audio_file_path: Optional[str], audio_duration: float, clip_duration_seconds: int, cached_file_uri: Optional[str], cached_mime_type: Optional[str], temperature: float, content_context: Optional[Dict], target_market: str, user_instruction: Optional[str], progress_callback: Optional[Callable], pre_transcript_segments: Optional[List[Dict]] = None, pre_selected_entity_library: Optional[Dict] = None, library_policy: Optional[Dict] = None, style_hint: str = '', subtitle_profile: Optional[Dict] = None, content_language: str = '', audio_profile_block: str = '') -> Optional[Dict]:
        """Pass-0: one whole-source call → light story map. None on failure (block gen
        then proceeds without it — degrade gracefully, never block the job).

        VIDEO policy: an explicit/sibling SRT is an optional TEXT-ONLY accelerator.
        Without one, the map reads the cached audio URI. This call never asks the
        model to echo a full transcript, keeping output compact for long sources."""
        pass

    def _parse_global_map(self, response_text: str) -> Optional[Dict]:
        pass

    def _format_global_map_block(self, gmap: Optional[Dict]) -> str:
        """Render the story map as the GLOBAL header injected into pass-2's base prompt
        (present in every block turn via conversation history)."""
        pass

    @staticmethod
    def _srt_parse_block_json(resp_text: str) -> Optional[Dict[str, Any]]:
        pass

    @staticmethod
    def _srt_scene_items(data: Dict[str, Any], manifest: Optional[List[str]] = None) -> Dict[str, Dict[str, Any]]:
        """scenes (dict OR list) → {time_id: scene}. time_id = the manifest key."""
        pass

    def _run_text_blocks_parallel(self, *, base_prompt: str, blocks: List[Dict], transcript_segments: List[Dict], temperature: float, thinking_config: Optional[Dict], progress_callback: Optional[Callable] = None) -> Optional[str]:
        """Run every block as an independent TEXT-ONLY call, fanned out in PARALLEL.

        When an explicit/sibling SRT exists, each block gets ITS transcript slice
        instead of the audio file, so:
          • no per-block re-listening (the old path re-heard the full audio N times),
          • any TEXT model can serve a block (no multimodal requirement),
          • blocks are independent → run concurrently (gateway: N separate jobs;
            freepath: the per-account lock serialises them — still no re-listen).
        Missing manifest scenes are recovered in-place: each correction call asks
        only for the IDs still absent from that block, while completed sibling
        blocks stay checkpointed.  If local recovery is exhausted, raise a
        non-job-retryable error instead of replaying every text/audio block.
        Returns the MERGED unified-response JSON string, or None when the
        transcript itself is unusable (caller falls back to the legacy
        audio-block path)."""
        pass

    def _call_ai_for_scenes(self, prompt: str, audio_file_path: Optional[str], temperature: float, attempt: int = 0, cached_file_uri: Optional[str] = None, cached_mime_type: Optional[str] = None, deep_analysis: bool = False, progress_callback: Optional[Callable] = None, audio_duration: float = 0.0, clip_duration_seconds: int = 8, block_briefs: Optional[Dict] = None, scene_plan: Optional[List[Dict]] = None, focused: bool = False, transcript_segments: Optional[List[Dict]] = None) -> str:
        pass

    def _cut_audio_head(self, src: str, seconds: int = 60) -> str:
        pass

    def _remember_audio_output_classification(self, audio_file_path: str, result: str, payload: Optional[Dict[str, Any]] = None) -> None:
        pass

    def audio_output_classification_details(self, audio_file_path: str) -> Dict[str, Any]:
        pass

    def classify_audio_output(self, *, audio_file_path: str, progress_callback: Optional[Callable] = None) -> str:
        """AUTO mode — choose the A2V recreation pipeline from a short audio sample.

        IMAGE means narration-led still-image beats (storyboard / slideshow / explainer
        cards) remain faithful. VIDEO means continuous motion generation is required to
        preserve meaning. Returns ``"image"`` | ``"video"``.

        One cheap call: cut ~60s head when possible, upload sample only, parse JSON.
        Failure → ``"video"`` (safe fallback — never invent image routing)."""
        pass

    def _get_audio_duration(self, audio_file_path: str) -> Optional[float]:
        pass


# --- Top-Level Functions ---
def _format_relative_second(value: float) -> str:
    pass

def _adaptive_timeline_example_ranges(duration_seconds: int) -> Dict[str, List[str]]:
    """Return varied examples, never a runtime timing template.

    Transcript timing is selected from audible events inside each source window.
    These ranges only let prompt examples stay valid for every supported model
    duration (4/6/8/10s) while visibly demonstrating different beat counts."""
    pass

def _transcript_guard_multi_asset_info(pre_selected: Any) -> Dict[str, Any]:
    pass

def _ttrace(msg: str) -> None:
    pass
