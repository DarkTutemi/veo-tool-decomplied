"""
Decompiled / Reconstructed Module: qml_app.controllers.subtitle_studio_controller

Docstring:
Profile-v2 controller for the shared Subtitle Studio dialog.
"""

from __future__ import annotations
import sys, os, typing
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

__all__ = ['SubtitleStudioController']

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)
CAPTION_MODES = frozenset({'auto', 'subtitle', 'bilingual'})
OBJECT_IDS = frozenset({'overlay', 'caption'})
READING_SYSTEMS = frozenset({'auto', 'ipa', 'native_reading', 'native_and_romanization', 'romanization'})
STYLE_IDS = {'caption': frozenset({'translation', 'spoken'}), 'overlay': frozenset({'reading', 'lemma'})}
SUBTITLE_LANGUAGE_CODES = frozenset({'it', 'th', 'ru', 'fr', 'id', 'ja', 'de', 'ar', 'es', 'tr', 'ur', 'tl', 'ko', 'zh', 'en', 'ms', 'hi', 'pt', 'vi', 'bn'})
SUBTITLE_PRESETS = ({'preset_id': 'clean', 'label': 'Clean Outline', 'archetype': 'OUTLINE', 'category': 'readable', 'description': 'Viền sạch, cân bằng cho mọi footage.', 'recommended_for': 'Master · Clone', 'sample': ... [truncated]
_LANGUAGE_LABELS = {'vi': 'Tiếng Việt', 'en': 'English', 'zh': '中文', 'ja': '日本語', 'ko': '한국어', 'es': 'Español', 'fr': 'Français', 'de': 'Deutsch', 'pt': 'Português', 'ru': 'Русский', 'ar': 'العربية', 'hi': 'हिन्दी', 'id... [truncated]
_LEARNING_LANGUAGE_OPTIONS = ({'label': 'Tự động · ý tưởng / kịch bản / SRT', 'value': 'auto'}, {'label': 'Tiếng Việt', 'value': 'vi'}, {'label': 'English', 'value': 'en'}, {'label': '中文', 'value': 'zh'}, {'label': '日本語', 'value'... [truncated]
_LEARNING_PREVIEW_SAMPLES = {'vi': {'lemma': 'XIN CHÀO!', 'reading': '/sin˧˧ caːw˨˩/'}, 'en': {'lemma': 'HELLO!', 'reading': '/həˈloʊ/'}, 'zh': {'lemma': '你好！', 'reading': 'nǐ hǎo'}, 'ja': {'lemma': 'こんにちは！', 'reading': 'konnich... [truncated]
_HELLO_MEANINGS = {'vi': 'Xin chào!', 'en': 'Hello!', 'zh': '你好！', 'ja': 'こんにちは！', 'ko': '안녕하세요!', 'es': '¡Hola!', 'fr': 'Bonjour !', 'de': 'Hallo!', 'pt': 'Olá!', 'ru': 'Привет!', 'ar': 'مرحبًا!', 'hi': 'नमस्ते!', 'id... [truncated]
_PRESET_CATEGORIES = ({'label': 'Tất cả', 'value': 'all'}, {'label': 'Xu hướng', 'value': 'featured'}, {'label': 'Dễ đọc', 'value': 'readable'}, {'label': 'Social', 'value': 'social'}, {'label': 'Karaoke', 'value': 'karao... [truncated]
_READING_OPTIONS = ({'label': 'Tự động', 'value': 'auto'}, {'label': 'Chữ đọc bản địa', 'value': 'native_reading'}, {'label': 'La-tinh hóa', 'value': 'romanization'}, {'label': 'Bản địa + La-tinh', 'value': 'native_and_... [truncated]
_FONT_SOURCE_LABELS = {'auto': 'Tự động', 'bundled': 'Đi kèm', 'system': 'Hệ thống', 'custom': 'Đã nhập'}
_FONT_ROLE_LABELS = {'display': 'Be Vietnam Pro SemiBold', 'rounded': 'Be Vietnam Pro Bold', 'editorial': 'Noto Serif SemiBold', 'data': 'IBM Plex Sans SemiBold', 'condensed': 'Barlow Condensed SemiBold', 'universal': 'N... [truncated]
_PREVIEW_ROLE_FONT_ASSETS = ('BeVietnamPro-SemiBold.ttf', 'BeVietnamPro-Bold.ttf', 'NotoSerif-SemiBold.ttf', 'IBMPlexSans-SemiBold.ttf', 'BarlowCondensed-SemiBold.ttf', 'NotoSans-SemiBold.ttf')
_REGISTERED_PREVIEW_FONT_PATHS = set()
_STYLE_PATCH_KEYS = frozenset({'underline', 'uppercase', 'fill', 'font_role', 'offset_y', 'italic', 'accent', 'scale', 'font_id', 'tracking', 'shadow_scale', 'strike', 'offset_x', 'outline_scale', 'weight'})
_CHROME_PATCH_KEYS = frozenset({'motion_strength', 'motion', 'panel_alpha', 'stroke_px', 'stroke', 'glow_px', 'panel', 'word_state', 'panel_fill'})
_LEARNING_LANGUAGE_HINTS = (('vi', ('tiếng việt', 'vietnamese')), ('en', ('tiếng anh', 'english')), ('zh', ('tiếng trung', 'tiếng hoa', 'chinese', 'mandarin')), ('ja', ('tiếng nhật', 'japanese')), ('ko', ('tiếng hàn', 'korean')... [truncated]
_CONTEXT_HINT_KEYS = ('title', 'idea', 'script', 'script_text', 'transcript', 'transcript_text', 'srt_text', 'subtitle_text', 'description', 'prompt', 'tone')
_CONTEXT_SEMANTIC_KEYS = ('idea', 'script', 'script_text', 'transcript', 'transcript_text', 'srt_text', 'subtitle_text', 'description', 'prompt')
_SCRIPT_LANGUAGE_PATTERNS = (('ja', re.compile('[\\u3040-\\u30ff\\u31f0-\\u31ff]')), ('ko', re.compile('[\\u1100-\\u11ff\\u3130-\\u318f\\uac00-\\ud7af]')), ('ur', re.compile('[ٹڈڑںھہےۓژگچپ]')), ('ar', re.compile('[\\u0600-\\u06f... [truncated]
__all__ = ['SubtitleStudioController']

# --- Class: Inflight ---
class Inflight:
    """A 1-slot coalescing guard: refuses a new run while one is pending."""
    _busy = <member '_busy' of 'Inflight' objects>

    def __init__(self) -> 'None':
        pass

    def begin(self) -> 'bool':
        pass

    def done(self) -> 'None':
        pass


# --- Class: DictListModel ---
class DictListModel(QAbstractListModel):
    _ROLE = 257
    staticMetaObject = PySide6.QtCore.QMetaObject("DictListModel" inherits "QAbstractListModel":
Methods:
  #76 type=Slot, signature=setRows(QV...

    def __init__(self, parent: 'Any' = None) -> 'None':
        pass

    def roleNames(self):
        pass

    def rowCount(self, parent=<PySide6.QtCore.QModelIndex(-1,-1,0x0,QObject(0x0)) at 0x000001DFC1CE90C0>) -> 'int':
        # [PyArmor BCC constants]: 'isValid', 0, 'len', '_rows'
        pass

    def data(self, index, role=0):
        # [PyArmor BCC constants]: 'isValid', 0, 'row', 'len', '_rows'
        pass

    def setRows(self, rows: 'Any') -> 'None':
        # [PyArmor BCC constants]: 'isinstance', 'dict', '_rows', 'len', 'beginInsertRows', 'QtCore', 'QModelIndex', 1, 'endInsertRows', 'beginRemoveRows', 'endRemoveRows', 0, 'dataChanged', 'emit', 'index'
        pass

    def rows(self) -> 'list[dict]':
        pass


# --- Class: SubtitleStudioController ---
class SubtitleStudioController(QObject):
    staticMetaObject = PySide6.QtCore.QMetaObject("SubtitleStudioController" inherits "QObject":
Properties:
  #1 "presetModel", QObject* [cons...

    draftChanged = Signal()
    routeChanged = Signal()
    selectionChanged = Signal()
    statusChanged = Signal()
    autosaveChanged = Signal()
    fontCatalogChanged = Signal()
    openRequested = Signal()
    profileApplied = Signal()
    routeProfileAutosaved = Signal()
    routeApplyCompleted = Signal()
    _fontCatalogReady = Signal()
    _fontImportReady = Signal()
    _autosaveLoadReady = Signal()
    _autosaveSaveReady = Signal()
    def __init__(self, settings_manager: 'Any' = None, user_profile_store: 'Any' = None) -> 'None':
        pass

    @staticmethod
    def _auto_font_row() -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'font_id', 'auto', 'source', 'label', 'Tự động theo ngôn ngữ', 'family', 'Auto', 'style', 'Glyph-safe', 'note', 'Renderer chọn font đủ glyph'
        pass

    @staticmethod
    def _preset_row(raw: 'Any') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'dict', 'subtitle_preset_v2_defaults', 'get', 'preset_id', 'caption_styles', 'spoken', 'chrome', 'sample', 'preview_fill', 'preview_accent', 'preview_panel', 'preview_panel_alpha', 'preview_motion', 'preview_effect', 'preview_word_state'
        pass

    def _set_status(self, value: 'str') -> 'None':
        # [PyArmor BCC constants]: 'str', '', '_status', 'statusChanged', 'emit'
        pass

    def _set_autosave_status(self, value: 'str') -> 'None':
        # [PyArmor BCC constants]: 'str', '', '_autosave_status', 'autosaveChanged', 'emit'
        pass

    def _profile_for_context(self, raw: 'Any', *, prefer_saved_aspect: 'bool' = False) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'deepcopy', 'dict', 'str', 'get', 'aspect_ratio', '', 'strip', 'normalize_subtitle_aspect', '_job_context', '16:9', 'default_subtitle_profile_v2', '_route', 'normalize_subtitle_profile_v2', 'route', 'caption'
        pass

    def _restore_selection(self, state: 'Any') -> 'None':
        # [PyArmor BCC constants]: 'dict', 'str', 'get', 'object', 'caption', 'strip', 'lower', 'style', 'spoken', 'OBJECT_IDS', 'overlay', 'bool', '_draft', 'enabled', 'STYLE_IDS'
        pass

    def _autosave_state(self) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'deepcopy', '_draft', False, 'snapshot_locked', 'fingerprint_subtitle_profile_v2', 'fingerprint', 'profile', 'selection', 'object', 'style', '_selected_object', '_selected_style'
        pass

    @staticmethod
    def _route_snapshot(route: 'str', state: 'dict[str, Any]', job_context: 'dict[str, Any]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'resolve_subtitle_profile', 'dict', 'get', 'profile', 'route', 'context', True, 'snapshot_locked', 'fingerprint_subtitle_profile_v2', 'fingerprint'
        pass

    def _queue_autosave(self) -> 'None':
        # [PyArmor BCC constants]: 1, '_autosave_revision', '_route', '_autosave_state', 'revision', 'state', 'route_snapshot', '_route_snapshot', 'deepcopy', '_job_context', '_pending_autosaves', '_set_autosave_status', 'Đang tự lưu…', 'QCoreApplication', 'instance'
        pass

    def _start_autosave_load(self, token: 'int', guard_revision: 'int') -> 'None':
        # [PyArmor BCC constants]: '_route', '_user_profile_store', 'run_off_thread', '_autosaveLoadReady', 'name', 'SubtitleAutosaveLoad'
        pass

    def _flush_autosave(self) -> 'None':
        # [PyArmor BCC constants]: '_pending_autosaves', '_autosave_loading_token', 0, '_autosave_open_token', 'items', '_route', 'QCoreApplication', 'instance', '_autosave_timer', 'start', 120, 'int', 'get', 'revision', 'deepcopy'
        pass

    def _apply_autosave_load(self, payload: 'dict[str, Any]') -> 'None':
        # [PyArmor BCC constants]: 'dict', 'get', 'data', 'int', 'token', 0, '_autosave_open_token', '_autosave_loading_token', 'guard_revision', 'bool', 'ok', 'load_ok', '_set_autosave_status', 'Không thể tải bản tự lưu.', '_autosave_revision'
        pass

    def _apply_autosave_save(self, payload: 'dict[str, Any]') -> 'None':
        # [PyArmor BCC constants]: '_autosave_save_inflight', 'done', 'dict', 'get', 'data', 'int', 'revision', 0, 'str', 'route', '', 'bool', 'ok', 'save_ok', '_pending_autosaves'
        pass

    def _set_draft(self, profile: 'Any', message: 'str' = '', *, autosave: 'bool' = True) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_canonicalize_profile_geometry', 'route', '_route', '_draft', False, 'snapshot_locked', 'fingerprint_subtitle_profile_v2', 'fingerprint', 'compile_paint_plan', '_paint_plan', 'draftChanged', 'emit', 'selectionChanged', '_queue_autosave', '_set_status'
        pass

    def _selected_style_map(self) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'deepcopy', 'dict', '_draft', '_selected_object', 'styles', '_selected_style'
        pass

    def _selected_geom_map(self) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'deepcopy', 'dict', '_draft', '_selected_object', 'geom'
        pass

    def _authored_preset_overrides(self) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'apply_subtitle_preset_v2', '_draft', 'get', 'preset_id', 'route', '_route', 'OBJECT_IDS', 'dict', 'styles', 'STYLE_IDS', '_STYLE_PATCH_KEYS', 'deepcopy', 'chrome', '_CHROME_PATCH_KEYS'
        pass

    @staticmethod
    def _apply_authored_overrides(profile: 'dict[str, Any]', overrides: 'dict[str, Any]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'deepcopy', 'dict', 'get', 'styles', 'items', 'OBJECT_IDS', 'STYLE_IDS', 'update', 'chrome'
        pass

    def presetModel(*args, **kwargs):
        pass

    def presetCategoryModel(*args, **kwargs):
        pass

    def fontModel(*args, **kwargs):
        pass

    def draft(*args, **kwargs):
        pass

    def paintPlan(*args, **kwargs):
        pass

    def jobContext(*args, **kwargs):
        pass

    def selectedStyleData(*args, **kwargs):
        pass

    def selectedGeomData(*args, **kwargs):
        pass

    def activePreviewCue(*args, **kwargs):
        pass

    def activeRoute(*args, **kwargs):
        pass

    def contentMode(*args, **kwargs):
        pass

    def overlayEnabled(*args, **kwargs):
        pass

    def effectiveLearningLanguage(*args, **kwargs):
        pass

    def subtitlesEnabled(*args, **kwargs):
        pass

    def selectedObject(*args, **kwargs):
        pass

    def selectedStyle(*args, **kwargs):
        pass

    def statusMessage(*args, **kwargs):
        pass

    def autosaveStatus(*args, **kwargs):
        pass

    def fontCatalogBusy(*args, **kwargs):
        pass

    def fontCount(*args, **kwargs):
        pass

    def systemFontsLoaded(*args, **kwargs):
        pass

    def presetCount(*args, **kwargs):
        pass

    def readingSystems(*args, **kwargs):
        pass

    def translationLanguages(*args, **kwargs):
        pass

    def learningLanguages(*args, **kwargs):
        pass

    def platformSafeZoneOptions(*args, **kwargs):
        pass

    def openForRoute(self, route: 'str', route_profile: 'dict[str, Any]', job_context: 'dict[str, Any]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'str', 'master', 'strip', 'lower', '_route', 'dict', 'get', 'content_language', 'vi', 'normalize_subtitle_aspect', 'aspect_ratio', '_job_context', '_profile_for_context', '_route_snapshot', 'profile'
        pass

    def setEnabled(self, enabled: 'bool') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'deepcopy', '_draft', 'bool', 'enabled', 'ok', 'profile', True, '_set_draft'
        pass

    def setCaptionMode(self, mode: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'str', 'subtitle', 'strip', 'lower', 'CAPTION_MODES', 'ok', False, 'message', 'Chế độ caption không hợp lệ.', 'deepcopy', '_draft', 'caption', 'mode', '_selected_object', 'spoken'
        pass

    def setOverlayEnabled(self, enabled: 'bool') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'deepcopy', '_draft', 'bool', 'overlay', 'enabled', '_selected_object', 'lemma', '_selected_style', 'caption', 'spoken', '_set_draft', 'selectionChanged', 'emit', 'ok', 'profile'
        pass

    def setReadingSystem(self, reading_system: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'str', 'auto', 'strip', 'lower', 'READING_SYSTEMS', 'ok', False, 'message', 'Hệ chữ đọc không hợp lệ.', 'deepcopy', '_draft', 'overlay', 'reading_system', 'profile', True
        pass

    def setTargetLanguage(self, language: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'str', 'en', 'strip', 'lower', '_LANGUAGE_LABELS', 'ok', False, 'message', 'Ngôn ngữ B không hợp lệ.', 'deepcopy', '_draft', 'caption', 'target_language', 'profile', True
        pass

    def setLearningTargetLanguage(self, language: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'str', 'auto', 'strip', 'lower', 'SUBTITLE_LANGUAGE_CODES', 'ok', False, 'message', 'Ngôn ngữ học không hợp lệ.', 'deepcopy', '_draft', 'overlay', 'target_language', 'profile', True
        pass

    def setSelected(self, object_id: 'str', style_id: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'str', 'caption', 'strip', 'lower', '', 'OBJECT_IDS', 'ok', False, 'message', 'Object phụ đề không hợp lệ.', 'overlay', '_draft', 'enabled', 'Lớp từ + phiên âm đang tắt.', 'STYLE_IDS'
        pass

    def setObjectPosition(self, object_id: 'str', x: 'float', y: 'float') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'str', '', 'strip', 'lower', 'OBJECT_IDS', 'ok', False, 'message', 'Object phụ đề không hợp lệ.', 'deepcopy', '_draft', 'geom', 'update', 'x', 'y'
        pass

    def setLearningLayerOffset(self, object_id: 'str', style_id: 'str', offset_x: 'float', offset_y: 'float') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'str', '', 'strip', 'lower', 'OBJECT_IDS', 'STYLE_IDS', 'ok', False, 'message', 'Lớp học ngôn ngữ không hợp lệ.', 'deepcopy', '_draft', 'styles', 'update', 'offset_x'
        pass

    def setLearningRowGap(self, row_gap: 'float') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'deepcopy', '_draft', 'dict', 'get', 'learning_stack', 'float', 'row_gap', 'ok', 'profile', True, '_set_draft'
        pass

    def setObjectAlign(self, object_id: 'str', align: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'str', '', 'strip', 'lower', 'center', 'OBJECT_IDS', 'right', 'left', 'ok', False, 'message', 'Căn chỉnh không hợp lệ.', 'deepcopy', '_draft', 'geom'
        pass

    def setObjectBoxWidth(self, object_id: 'str', box_width: 'float') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'str', '', 'strip', 'lower', 'OBJECT_IDS', 'ok', False, 'message', 'Object phụ đề không hợp lệ.', 'deepcopy', '_draft', 'float', 'geom', 'box_width', True
        pass

    def patchStyle(self, object_id: 'str', style_id: 'str', key: 'str', value: 'Any') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'str', '', 'strip', 'lower', 'OBJECT_IDS', 'STYLE_IDS', '_STYLE_PATCH_KEYS', 'ok', False, 'message', 'Style patch không hợp lệ.', 'deepcopy', '_draft', 'styles', 'profile'
        pass

    def patchChrome(self, key: 'str', value: 'Any') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'str', '', 'strip', '_CHROME_PATCH_KEYS', 'ok', False, 'message', 'Chrome patch không hợp lệ.', 'deepcopy', '_draft', 'chrome', 'profile', True, '_set_draft'
        pass

    def selectPreset(self, preset_id: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_authored_preset_overrides', 'apply_subtitle_preset_v2', '_draft', 'route', '_route', '_apply_authored_overrides', 'ok', 'profile', True, '_set_draft'
        pass

    def setAspectRatio(self, aspect_ratio: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'deepcopy', '_draft', 'normalize_subtitle_aspect', 'aspect_ratio', 'bool', 'caption', 'get', 'geom_user_set', 'recommended_caption_geometry', 'platform_safe_zone', 'geom', 'ok', 'profile', True, '_set_draft'
        pass

    def setPlatformSafeZone(self, safe_zone: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'normalize_platform_safe_zone', 'deepcopy', '_draft', 'platform_safe_zone', 'bool', 'caption', 'get', 'geom_user_set', 'recommended_caption_geometry', 'aspect_ratio', 'geom', 'auto', 'str', '', '9:16'
        pass

    def resetDraft(self) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'default_subtitle_profile_v2', '_route', 'str', '_job_context', 'get', 'aspect_ratio', '16:9', 'caption', '_selected_object', 'spoken', '_selected_style', '_set_draft', 'Đã khôi phục đề xuất.', 'selectionChanged', 'emit'
        pass

    def persistDraft(self) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_autosave_timer', 'stop', '_flush_autosave', 'ok', 'profile', 'autosave_status', True, 'draft', '_autosave_status'
        pass

    def applyToRoute(self) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'resolve_subtitle_profile', '_draft', 'route', '_route', 'context', '_job_context', 'int', 'get', 'revision', 1, True, 'snapshot_locked', 'fingerprint_subtitle_profile_v2', 'fingerprint', 'deepcopy'
        pass

    def confirmRouteApply(self, route: 'str', result: 'dict[str, Any]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'str', '_route', 'master', 'dict', 'bool', 'get', 'ok', 'message', '', 'strip', 'Cấu hình phụ đề đã áp dụng cho job mới · ', 'Không thể áp dụng cấu hình phụ đề cho route ', '_set_status', 'routeApplyCompleted', 'emit'
        pass

    def confirmRouteAutosave(self, route: 'str', fingerprint: 'str', result: 'dict[str, Any]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'str', '_route', 'master', '', '_autosave_sync_fingerprints', 'get', 'ok', False, 'stale', True, 'message', 'Bỏ qua xác nhận cũ.', 'dict', 'bool', 'strip'
        pass

    def _apply_preset_filter(self) -> 'int':
        # [PyArmor BCC constants]: 'label', 'description', 'recommended_for', 'category', 'tags', 'sample'
        pass

    def setPresetFilter(self, category: 'str', search_text: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'str', 'all', 'strip', 'lower', '_PRESET_CATEGORIES', 'value', '_preset_category', '', '_preset_search', 'ok', 'count', True, '_apply_preset_filter'
        pass

    def _apply_font_filter(self) -> 'int':
        # [PyArmor BCC constants]: 'label', 'family', 'style', 'source'
        pass

    def _preview_font_row(self, font_id: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'ja', 'ko', 'zh', 'ar', 'ur', 'hi', 'th', 'bn'
        pass

    def _font_catalog_row(self, font_id: 'str') -> 'dict[str, Any] | None':
        pass

    def fontDisplayName(self, font_id: 'str') -> 'str':
        # [PyArmor BCC constants]: 'str', 'auto', 'strip', '_font_catalog_row', 'get', 'family', 'label', 'Tự động theo ngôn ngữ', 'split', ':', 1, 0, 'lower', '_FONT_SOURCE_LABELS', '_font_busy'
        pass

    def fontSourceLabel(self, font_id: 'str') -> 'str':
        # [PyArmor BCC constants]: 'str', 'auto', 'strip', '_font_catalog_row', 'get', 'source', '', 'lower', ':', 'split', 1, 0, '_FONT_SOURCE_LABELS'
        pass

    def previewFontFamily(self, font_id: 'str') -> 'str':
        # [PyArmor BCC constants]: '_preview_font_row', 'str', 'get', 'family', 'label', '', 'strip', 'Auto', 'Segoe UI'
        pass

    def previewFontUrl(self, font_id: 'str') -> 'str':
        # [PyArmor BCC constants]: 'str', '_preview_font_row', 'get', 'url', ''
        pass

    def previewFontNeedsLoader(self, font_id: 'str') -> 'bool':
        # [PyArmor BCC constants]: '_preview_font_row', 'str', 'get', 'source', '', 'strip', 'lower', 'path', 'system', False, 'bundled', 'replace', '\\', '/', 'rsplit'
        pass

    def fontRoleDisplayName(self, font_role: 'str') -> 'str':
        # [PyArmor BCC constants]: 'str', 'display', 'strip', 'lower', '_FONT_ROLE_LABELS', 'get'
        pass

    def fontRoleSourceLabel(self, font_role: 'str') -> 'str':
        # [PyArmor BCC constants]: 'str', 'display', 'strip', 'lower', '_FONT_ROLE_LABELS', '_FONT_SOURCE_LABELS', 'bundled', 'auto'
        pass

    def _start_font_catalog(self, include_system: 'bool') -> 'bool':
        # [PyArmor BCC constants]: '_font_busy', False, True, 'fontCatalogChanged', 'emit', 'run_off_thread', '_font_inflight', '_fontCatalogReady', 'name', 'SubtitleFontCatalog'
        pass

    def refreshBundledFontCatalog(self) -> 'bool':
        pass

    def refreshFontCatalog(self) -> 'bool':
        pass

    def _apply_font_catalog(self, payload: 'dict[str, Any]') -> 'None':
        # [PyArmor BCC constants]: '_font_inflight', 'done', False, '_font_busy', 'get', 'ok', 'list', 'data', 'dict', '_auto_font_row', '_font_catalog', '_apply_font_filter', '_set_status', 'Không tải được thư viện font; preview dùng font an toàn.', 'fontCatalogChanged'
        pass

    def setFontFilter(self, source: 'str', search_text: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'str', 'all', 'strip', 'lower', 'bundled', 'system', 'auto', 'custom', '_font_source', '', '_font_search', 'ok', 'count', True, '_apply_font_filter'
        pass

    def selectFont(self, font_id: 'str') -> 'dict[str, Any]':
        pass

    def importCustomFont(self, url_or_path: 'str') -> 'bool':
        # [PyArmor BCC constants]: 'str', '', 'startswith', 'file:', 'QUrl', 'toLocalFile', True, '_font_busy', 'fontCatalogChanged', 'emit', 'run_off_thread', '_font_import_inflight', '_fontImportReady', 'name', 'SubtitleFontImport'
        pass

    def _apply_font_import(self, payload: 'dict[str, Any]') -> 'None':
        # [PyArmor BCC constants]: '_font_import_inflight', 'done', False, '_font_busy', 'get', 'ok', 'dict', 'data', '_font_catalog', 'str', 'font_id', '', 'append', '_apply_font_filter', 'selectFont'
        pass


# --- Top-Level Functions ---
def _register_preview_role_fonts() -> 'None':
    # [PyArmor BCC constants]: 'QCoreApplication', 'instance', 'isinstance', 'QGuiApplication', 'get_bundled_resources_dir', 'fonts', 'timemachine', '_PREVIEW_ROLE_FONT_ASSETS', 'str', 'resolve', 'casefold', '_REGISTERED_PREVIEW_FONT_PATHS', 'is_file', 'QFontDatabase', 'addApplicationFont'
    pass

def _search_key(value: 'Any') -> 'str':
    pass

def _learning_language_from_context(context: 'dict[str, Any]') -> 'str':
    pass

def _preview_meaning_language(context: 'dict[str, Any]', target_language: 'str') -> 'str':
    # [PyArmor BCC constants]: 'str', 'get', 'content_language', 'vi', 'strip', 'lower', 'SUBTITLE_LANGUAGE_CODES', 'en'
    pass

def _load_autosave_payload(store: 'Any', route: 'str', token: 'int', guard_revision: 'int') -> 'dict[str, Any]':
    # [PyArmor BCC constants]: 'load_autosave', 'token', 'guard_revision', 'route', 'load_ok', 'error', False, 'type', '__name__', 'Exception', 'state', True
    pass

def _save_autosave_payload(store: 'Any', route: 'str', revision: 'int', state: 'dict[str, Any]', route_snapshot: 'dict[str, Any]') -> 'dict[str, Any]':
    # [PyArmor BCC constants]: 'save_autosave', 'revision', 'route', 'save_ok', 'error', False, 'type', '__name__', 'Exception', 'state', 'route_snapshot', True, 'deepcopy'
    pass

def _canonicalize_profile_geometry(profile: 'Any', *, route: 'str') -> 'dict[str, Any]':
    # [PyArmor BCC constants]: 'normalize_subtitle_profile_v2', 'route', 'compile_paint_plan', 'OBJECT_IDS', 'dict', 'pos', 'geom', 'update', 'x', 'y', 'box_width', 'float', 'x_norm', 'y_norm', 'box_width_norm'
    pass
