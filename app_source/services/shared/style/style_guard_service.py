"""
Decompiled / Reconstructed Module: services.shared.style.style_guard_service
Source PyC: style_guard_service.pyc
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['StyleGuardService', 'get_style_guard_service']

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
Optional = typing.Optional
_GUARDED_FEATURES = {<JobFeature.TEXT2VIDEO_16_9: 'text2video_16_9'>, <JobFeature.PORTRAIT_VIDEO: 'portrait_video'>, <JobFeature.MULTI_ASSET_VIDEO: 'multi_asset_video'>, <JobFeature.TRANSCRIPT_VIDEO: 'transcript_video'>,... [truncated]
_STYLIZED_MARKERS = ('no photorealistic', 'no live-action', 'non-photorealistic', 'must become anime/manga characters', 'must become cartoon animation characters', 'finished illustration figures', 're-expressed as finish... [truncated]
_REALISTIC_MARKERS = ('photorealistic live-action', 'realistic live-action', 'must remain believable live-action')
_STYLIZED_LOOK_WORDS = ('cartoon', 'anime', 'manga', 'illustration', 'illustrated', 'hand-drawn', 'cel animation', 'cel-shaded', 'claymation', 'clay animation', 'stop-motion', 'stop motion', 'pixel art', 'watercolor', 'goua... [truncated]
_REALISTIC_LOOK_WORDS = ('live-action', 'live action', 'photoreal', 'photo-real', 'photorealistic', 'realistic', 'documentary', 'real footage', 'film footage', 'hyper-real', 'hyperreal')
_BATCH_MODEL = 'flash'
_BATCH_MAX = 10
_BATCH_IDLE_S = 90.0
_BATCH_MAX_WAIT_S = 300.0
_BRIEF_MAX = 900
_STYLE_HEAD_MAX = 140
_INTENDED_STYLE_MAX = 360
_ANCHOR_TTL_S = 7200
_CONSENSUS_TPL = 'You are a strict visual-consistency QC. Every attached image is a scene from ONE video that MUST share ONE consistent rendering STYLE — the same art medium (e.g. all line-art sketch, all 2D cartoon, ... [truncated]
_ANCHOR_KEEP = 3
_DESC_RE = re.compile('"description"\\s*:\\s*"((?:[^"\\\\]|\\\\.)+)"')
_CONTENT_FIELD_RE = re.compile('"(?:description|summary|context|setting|background|location|visual|action|reaction|subject|subjects|characters|objects|props|products|motion_graphics|on_screen_text|overlay_text|story_beat... [truncated]
_STYLE_FIELD_RE = re.compile('"(?:visual_style|style)"\\s*:\\s*"((?:[^"\\\\]|\\\\.)+)"', re.IGNORECASE)
_VISUAL_STYLE_RE = re.compile('\\[VISUAL STYLE:\\s*([^\\]]+)\\]', re.IGNORECASE)
_COMPILED_STYLE_START_RE = re.compile('^[ \\t]*STYLE FRAMEWORK(?:\\s*[—-]\\s*BINDING RENDER CONTRACT)?\\s*$', re.IGNORECASE|re.MULTILINE)
_COMPILED_SCENE_START_RE = re.compile('^[ \\t]*FROZEN MOMENT\\b[^\\r\\n]*$', re.IGNORECASE|re.MULTILINE)
_COMPILED_SCENE_END_RE = re.compile('^[ \\t]*(?:REFERENCE BINDING\\b|NEGATIVE CONSTRAINTS\\s*:|\\[STYLEGUARD_CORRECTION\\])', re.IGNORECASE|re.MULTILINE)
_COMPILED_CONTENT_PREFIXES = ('FROZEN MOMENT', 'INTERACTION / VISIBLE RESULT', 'WHERE')
_NEGATED_REALISTIC_RE = re.compile('\\b(?:non|not|no)[-\\s]?(?:photo)?realistic\\b')
_MAX_STYLE_REGEN = 3
_REGEN_NAG_AT = 3
_MAX_CHECK_ATTEMPTS = 3
_MAX_CHECK_ATTEMPTS_RATE = 5
_RETRY_DELAY_S = 30
_RETRY_DELAY_RATE_S = 120
_MIN_CALL_GAP_S = 6.0
_MODEL_TIER_LADDER = ('flash', 'pro')
_IMAGE_MIME = {'.webp': 'image/webp', '.png': 'image/png', '.jpg': 'image/jpeg', '.jpeg': 'image/jpeg', '.gif': 'image/gif'}
_PROMPT_TPL = 'You are a strict QC for ONE frame of an AI-generated video. Answer TWO INDEPENDENT checks.\n\n=== CHECK 1 — RENDERING STYLE ===\nThe SCENE SCRIPT in CHECK 2 below declares the intended STYLIZED visua... [truncated]
_SCENE_PROMPT_MAX = 2400
_instance = None
__all__ = ['StyleGuardService', 'get_style_guard_service']

# --- Class: StyleGuardService ---
class StyleGuardService:
    """Singleton: subscribe JobStore.job_changed → free vision QC → auto-regen."""
    def __init__(self):
        pass

    def install(self) -> 'None':
        pass

    def _gemini_client(self):
        pass

    def _reset_gemini_if_auth(self, err) -> 'None':
        pass

    def _gemini_vision(self, prompt: 'str', file_specs: 'list', *, model: 'str' = 'flash') -> 'str':
        pass

    def _on_job_changed(self, job) -> 'None':
        pass

    def pending_for_folder(self, output_folder: 'str') -> 'int':
        pass

    def _folder_of(self, job_id: 'str') -> 'str':
        pass

    def _folder_anchors(self, folder: 'str') -> 'list':
        pass

    def _register_anchor(self, folder: 'str', path: 'str') -> 'None':
        pass

    def _settle(self, job_id: 'str') -> 'None':
        pass

    def release_folder(self, output_folder: 'str') -> 'None':
        pass

    def wait_until_folder_settled(self, output_folder: 'str', *, timeout_s: 'float' = 900.0, poll_s: 'float' = 5.0) -> 'bool':
        pass

    def _run(self) -> 'None':
        pass

    def _process_item(self, item) -> 'None':
        pass

    def _consensus_text(self, ref_paths: 'list', briefs: 'list', intended_styles: 'list', target_paths: 'list', *, model: 'str' = 'flash') -> 'str':
        """1 Gemini vision call: [mốc style của run..] + [target..] → verdict/target.
        ref_paths rỗng → target TỰ làm số đông (batch đầu của run)."""
        pass

    def _process_batch(self, items) -> 'None':
        pass

    def _process_run_group(self, folder: 'str', members: 'list') -> 'None':
        pass

    def _schedule_retry(self, job_id: 'str', thumb: 'str', scene_prompt: 'str', hard_att: 'int', rate_att: 'int', rung: 'int', delay: 'float') -> 'None':
        pass

    def _check_and_regen(self, job_id: 'str', thumb: 'str', scene_prompt: 'str', hard_att: 'int' = 0, rate_att: 'int' = 0, rung: 'int' = 0) -> 'bool':
        pass

    def _apply_verdict(self, job_id: 'str', verdict: 'dict', *, intended_style: 'str' = '', trusted_consensus: 'bool' = True) -> 'bool':
        pass

    def _pace(self) -> 'None':
        pass

    def _ask_vision(self, target_path: 'str', scene_prompt: 'str' = '', refs: 'Optional[list]' = None, *, intended_style: 'str' = '', rung: 'int' = 0) -> 'Optional[dict]':
        pass


# --- Top-Level Functions ---
def _is_rate_limit(err) -> 'bool':
    pass

def _model_for_rung(rung: 'int') -> 'str':
    pass

def _guard_enabled() -> 'bool':
    pass

def _job_output_folder(job) -> 'str':
    pass

def _job_prompt_text(job) -> 'str':
    pass

def _is_timemachine_job(job) -> 'bool':
    pass

def _extract_style_text(prompt_text: 'str') -> 'str':
    """Trích phần STYLE TEXT từ wire prompt: field JSON `"style": "..."` (compiler
    master/transcript/clone) hoặc `[VISUAL STYLE: ...]` (manual prefix không framework)."""
    pass

def _compiled_prompt_sections(prompt_text: 'str') -> 'tuple[str, str]':
    """Split the shared compiled image prompt into style and authored content.

    The image-story compiler emits a prose contract rather than JSON.  Treating
    that whole prompt as one scene brief made the 900-char cap retain only the
    leading STYLE FRAMEWORK and discard the later FROZEN MOMENT/WHERE.  In that
    failure mode a deliberately modern gym rendered in a prehistoric 2D style
    was judged as wrong content because QC never received the gym scene at all.

    Return ``(style_block, content_block)``.  Empty strings mean this is another
    prompt format and the existing JSON/manual fallbacks should handle it."""
    pass

def _scene_brief(prompt_text: 'str') -> 'str':
    pass

def _intended_style_brief(prompt_text: 'str') -> 'str':
    """Return the authored visual-style contract for absolute style QC.

    Prefer the explicit style field emitted by the shared prompt builders.  The
    canonical marker fallback still gives vision a useful absolute requirement
    for older/manual prompts without inventing a specific medium."""
    pass

def _verdict_bool(value, default: 'bool') -> 'bool':
    pass

def _parse_verdict_list(text: 'str', n: 'int') -> 'Optional[dict]':
    pass

def _wants_stylized(prompt_text: 'str') -> 'bool':
    """True khi job TỰ TUYÊN BỐ style cấm/khác photoreal → drift realistic là vi phạm,
    regen chính đáng. Tier 1 = câu canonical của style_frameworks (realistic thắng
    tuyệt đối). Tier 2 = keyword trên STYLE TEXT tự do (clone auto-style). Không có
    tín hiệu nào = False (fail-safe PASS)."""
    pass

def _file_url_to_path(url: 'str') -> 'Optional[str]':
    pass

def _as_conf(v) -> 'float':
    pass

def _job_log_tag(job_id: 'str') -> 'str':
    pass

def _parse_verdict(text: 'str') -> 'Optional[dict]':
    pass

def get_style_guard_service() -> 'StyleGuardService':
    pass
