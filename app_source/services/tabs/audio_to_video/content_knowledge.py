"""
Decompiled / Reconstructed Module: services.tabs.audio_to_video.content_knowledge
Source PyC: content_knowledge.pyc

Docstring:
Channel-content knowledge: curated categories + AI prompt templates.

Powers the Audio-to-Video "AI tạo" input mode — pick a niche (đạo lý, động lực,
tài chính…), give an optional topic, and generate N short narration scripts
ready for TTS → audio → video. Vietnamese-first, channel-friendly tone.
"""

from __future__ import annotations
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
Dict = typing.Dict
List = typing.List
CATEGORIES = [{'id': 'life_lessons', 'label': 'Đạo lý cuộc sống', 'icon': 'light-bulb', 'description': 'Bài học sống, đối nhân xử thế, giá trị sống.', 'angle': 'rút ra bài học sống sâu sắc, gần gũi, dễ thấm; giọng... [truncated]
_CATEGORY_BY_ID = {'life_lessons': {'id': 'life_lessons', 'label': 'Đạo lý cuộc sống', 'icon': 'light-bulb', 'description': 'Bài học sống, đối nhân xử thế, giá trị sống.', 'angle': 'rút ra bài học sống sâu sắc, gần gũi... [truncated]
_LENGTH_HINTS = {'short': 'khoảng 60–90 từ (clip ngắn ~30s)', 'medium': 'khoảng 120–180 từ (clip ~60s)', 'long': 'khoảng 220–300 từ (clip ~90–120s)'}
LENGTHS = [{'id': 'short', 'label': 'Ngắn (~30s)'}, {'id': 'medium', 'label': 'Vừa (~60s)'}, {'id': 'long', 'label': 'Dài (~90–120s)'}]
TONES = [{'id': '', 'label': 'Theo chủ đề'}, {'id': 'warm', 'label': 'Ấm áp'}, {'id': 'strong', 'label': 'Mạnh mẽ'}, {'id': 'inspire', 'label': 'Truyền cảm hứng'}, {'id': 'deep', 'label': 'Sâu lắng'}, {'id': ... [truncated]
_TONE_HINTS = {'warm': 'giọng ấm áp, gần gũi, chân thành', 'strong': 'giọng mạnh mẽ, dứt khoát, truyền lửa', 'inspire': 'giọng truyền cảm hứng, nâng đỡ, tích cực', 'deep': 'giọng trầm, sâu lắng, chiêm nghiệm', 'hum... [truncated]
_TEMPLATES = {'standard': 'CẤU TRÚC bắt buộc mỗi kịch bản (viết LIỀN MẠCH thành văn nói, KHÔNG ghi nhãn các phần):\n  1) HOOK — 1 câu đầu (3–5 giây): giật, gây tò mò/chạm cảm xúc, giữ chân ngay.\n  2) MỞ ĐẦU — dẫn... [truncated]
_TEMPLATES_META = [{'id': 'standard', 'label': 'Chuẩn (Hook → Thân → Kết)'}, {'id': 'story', 'label': 'Kể chuyện'}, {'id': 'listicle', 'label': 'Liệt kê (N điểm)'}, {'id': 'dialogue', 'label': 'Đối thoại'}]

# --- Top-Level Functions ---
def list_categories() -> 'List[Dict[str, str]]':
    pass

def list_lengths() -> 'List[Dict[str, str]]':
    pass

def list_tones() -> 'List[Dict[str, str]]':
    pass

def list_aspects(category_id: 'str') -> 'List[str]':
    pass

def list_templates() -> 'List[Dict[str, str]]':
    pass

def _character_block(characters: 'List[Dict[str, Any]] | None', char_mode: 'str') -> 'str':
    pass

def _build_prompt(category: 'Dict[str, Any]', topic: 'str', count: 'int', length: 'str', language: 'str', avoid_titles: 'List[str] | None' = None, characters: 'List[Dict[str, Any]] | None' = None, char_mode: 'str' = 'full_ai', tone: 'str' = '', series: 'bool' = False, aspect: 'str' = '', template: 'str' = 'standard', brief: 'str' = '', visual_style: 'str' = '') -> 'str':
    pass

def _parse_items(raw: 'Any', count: 'int') -> 'List[Dict[str, str]]':
    pass

def generate_texts(category_id: 'str', topic: 'str' = '', count: 'int' = 5, length: 'str' = 'medium', language: 'str' = 'vi', avoid_titles: 'List[str] | None' = None, characters: 'List[Dict[str, Any]] | None' = None, char_mode: 'str' = 'full_ai', tone: 'str' = '', series: 'bool' = False, aspect: 'str' = '', template: 'str' = 'standard', brief: 'str' = '', visual_style: 'str' = '') -> 'Dict[str, Any]':
    pass
