"""
Decompiled / Reconstructed Module: qml_app.controllers.research_controller

Docstring:
Deep Research controller for QML.
"""

from __future__ import annotations
import sys, os, typing
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)

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

    def rowCount(self, parent=<PySide6.QtCore.QModelIndex(-1,-1,0x0,QObject(0x0)) at 0x0000021AD009CBC0>) -> 'int':
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


# --- Class: ResearchController ---
class ResearchController(QObject):
    """QML adapter for the headless research service."""
    staticMetaObject = PySide6.QtCore.QMetaObject("ResearchController" inherits "QObject":
Properties:
  #1 "queueRows", QVariantList [designab...

    queueRowsChanged = Signal()
    statsChanged = Signal()
    historyChanged = Signal()
    schedulesChanged = Signal()
    suggestionsChanged = Signal()
    plannerTemplatesChanged = Signal()
    plannerIdeasChanged = Signal()
    plannerTemplateChanged = Signal()
    previewChanged = Signal()
    reportChanged = Signal()
    assetPackChanged = Signal()
    statusMessageChanged = Signal()
    actionResultChanged = Signal()
    assessmentChanged = Signal()
    assessingChanged = Signal()
    activeContentChanged = Signal()
    evidenceChanged = Signal()
    metadataChanged = Signal()
    plannerGeneratingChanged = Signal()
    activeRunningChanged = Signal()
    audiosChanged = Signal()
    seriesChanged = Signal()
    creatingSeriesChanged = Signal()
    _assessDone = Signal()
    _scheduleDone = Signal()
    _plannerIdeasDone = Signal()
    _audiosReady = Signal()
    _seriesReady = Signal()
    _seriesCreateDone = Signal()
    _refreshReady = Signal()
    def __init__(self) -> 'None':
        # [PyArmor BCC constants]: 'ok', 'blocked', 'action', 'code', 'message', 'blocker'
        pass

    def shutdown(self) -> 'None':
        # [PyArmor BCC constants]: '_shutdown_done', True, 'getattr', '_schedule_timer', 'isActive', 'stop', 'Exception', 'timeout', 'disconnect', '_on_schedule_timer', '_app', 'aboutToQuit', 'shutdown'
        pass

    def queueRows(*args, **kwargs):
        pass

    def stats(*args, **kwargs):
        pass

    def history(*args, **kwargs):
        pass

    def schedules(*args, **kwargs):
        pass

    def queueRowsModel(*args, **kwargs):
        pass

    def historyModel(*args, **kwargs):
        pass

    def schedulesModel(*args, **kwargs):
        pass

    def suggestions(*args, **kwargs):
        pass

    def plannerTemplates(*args, **kwargs):
        pass

    def plannerIdeas(*args, **kwargs):
        pass

    def plannerTemplateId(*args, **kwargs):
        pass

    def plannerTemplate(*args, **kwargs):
        pass

    def plannerStorePath(*args, **kwargs):
        pass

    def previewPrompt(*args, **kwargs):
        pass

    def assessment(*args, **kwargs):
        pass

    def assessing(*args, **kwargs):
        pass

    def planMarkdown(*args, **kwargs):
        pass

    def scriptText(*args, **kwargs):
        pass

    def evidenceMarkdown(*args, **kwargs):
        pass

    def metadataMap(*args, **kwargs):
        pass

    def reportMarkdown(*args, **kwargs):
        pass

    def assetPack(*args, **kwargs):
        pass

    def assetPackText(*args, **kwargs):
        pass

    def lastJobId(*args, **kwargs):
        pass

    def statusMessage(*args, **kwargs):
        pass

    def lastAction(*args, **kwargs):
        pass

    def actionStatus(*args, **kwargs):
        pass

    def refresh(self) -> 'None':
        # [PyArmor BCC constants]: 'str', '_planner_template_id', '', '_service', 'queue', 'stats', 'history', 'schedules', 'planner', 'list_queue', 'get_stats', 'list_history', 'list_schedules', 'get_content_planner_state', 'run_off_thread'
        pass

    def _apply_refresh(self, payload: 'dict') -> 'None':
        # [PyArmor BCC constants]: '_refresh_inflight', 'done', 'get', 'ok', 'dict', 'data', '_coerce_rows', 'queue', 'stats', 'history', 'schedules', 'planner', 'templates', 'ideas', 'str'
        pass

    def audioLibraryModel(*args, **kwargs):
        pass

    def audioCount(*args, **kwargs):
        pass

    def currentAccount(*args, **kwargs):
        pass

    def refreshAudios(self) -> 'None':
        # [PyArmor BCC constants]: 'run_off_thread', '_audios_inflight', '_audiosReady', 'name', 'ResearchAudios'
        pass

    def _apply_audios(self, payload: 'dict') -> 'None':
        # [PyArmor BCC constants]: '_audios_inflight', 'done', 'get', 'ok', 'data', 'audios', 'isinstance', 'dict', '_audios', '_audios_model', 'setRows', 'audiosChanged', 'emit'
        pass

    def sendAudioToVideo(self, job_id: 'str', notes: 'str' = '') -> 'None':
        # [PyArmor BCC constants]: '_service', 'send_audio_to_transcript', 'str', '', '_set_action_result', 'action', 'research.audio.send_to_video', 'success_message', 'Đã đẩy audio sang Audio-to-Video', 'refreshAudios'
        pass

    def deleteAudio(self, job_id: 'str', delete_file: 'bool' = False) -> 'None':
        # [PyArmor BCC constants]: '_service', 'delete_audio', 'str', '', 'bool', '_set_action_result', 'action', 'research.audio.delete', 'success_message', 'Đã xoá audio khỏi kho', 'refreshAudios'
        pass

    def openAudioPath(self, path: 'str') -> 'None':
        # [PyArmor BCC constants]: 'str', '', 'strip', '_open_local_path'
        pass

    def seriesModel(*args, **kwargs):
        pass

    def seriesCount(*args, **kwargs):
        pass

    def creatingSeries(*args, **kwargs):
        pass

    def createSeries(self, job_id: 'str', count: 'int' = 8) -> 'None':
        # [PyArmor BCC constants]: 'str', '_last_job_id', '', 'strip', True, '_creating_series', 'creatingSeriesChanged', 'emit', 'run_off_thread', '_series_create_inflight', '_seriesCreateDone', 'name', 'CreateSeries', False
        pass

    def _on_series_created(self, payload: 'dict') -> 'None':
        # [PyArmor BCC constants]: '_series_create_inflight', 'done', False, '_creating_series', 'creatingSeriesChanged', 'emit', 'get', 'ok', 'data', '_set_action_result', 'dict', 'action', 'research.series.create', 'success_message', 'Đã tạo series — lịch các tập sẵn sàng'
        pass

    def refreshSeries(self) -> 'None':
        # [PyArmor BCC constants]: 'run_off_thread', '_series_inflight', '_seriesReady', 'name', 'ResearchSeries'
        pass

    def _apply_series(self, payload: 'dict') -> 'None':
        # [PyArmor BCC constants]: '_series_inflight', 'done', 'get', 'ok', 'data', 'series', 'isinstance', 'dict', '_series', '_series_model', 'setRows', 'seriesChanged', 'emit'
        pass

    def runSeriesEpisode(self, series_id: 'str', episode_no: 'int' = 0) -> 'None':
        # [PyArmor BCC constants]: '_service', 'run_series_episode', 'str', '', 'int', 0, '_apply_report_result', '_set_action_result', 'action', 'research.series.run_episode', 'success_message', 'Đang chạy tập…', 'refreshSeries'
        pass

    def suggestTopics(self, topic: 'str', count: 'int' = 5, creativity_level: 'str' = 'medium') -> 'None':
        # [PyArmor BCC constants]: '_service', 'suggest_topic', 'get', 'topics', 'str', '_suggestions', 'suggestionsChanged', 'emit', '_set_status', 'Suggested ', 'len', ' topic(s)'
        pass

    def previewTopic(self, topic: 'str', tone: 'str' = 'professional', audience: 'str' = 'general audience') -> 'None':
        # [PyArmor BCC constants]: '_service', 'preview_prompt', 'tone', 'audience', 'str', 'get', 'prompt', '', '_preview_prompt', 'strip', '_last_topic', 'previewChanged', 'emit', '_set_status', 'Research prompt preview updated'
        pass

    def refreshPlanner(self, template_id: 'str' = '') -> 'None':
        # [PyArmor BCC constants]: 'str', '_planner_template_id', '', 'plannerTemplateChanged', 'emit', 'getattr', '_planner_notice', 'plannerGeneratingChanged', 'refresh'
        pass

    def _feature_blocked(self, action: 'str') -> 'dict[str, Any] | None':
        # [PyArmor BCC constants]: 'feature_blocker', 'deep_research', '_set_status', 'str', 'get', 'message', ''
        pass

    def generatePlannerIdeas(self, template_id: 'str', seed_topic: 'str' = '', count: 'int' = 5) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_feature_blocked', 'research.planner_ideas', '_service', 'generate_content_plan_ideas', '_planner_template_id', '_load_planner_state', 'str', 'get', 'template_id', 'plannerIdeasChanged', 'emit', 'plannerTemplateChanged', 'dict', 'setdefault', 'message'
        pass

    def addPlannerIdea(self, template_id: 'str', topic: 'str') -> 'None':
        # [PyArmor BCC constants]: '_service', 'add_content_plan_ideas', '_planner_template_id', '_load_planner_state', 'str', 'get', 'template_id', 'plannerIdeasChanged', 'emit', '_set_status', 'ok', 'Planner idea added', 'error', 'Planner add failed'
        pass

    def applyPlannerIdea(self, template_id: 'str', idea_id: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_service', 'apply_content_plan_idea', '_planner_template_id', '_load_planner_state', 'str', 'get', 'template_id', 'plannerIdeasChanged', 'emit', 'dict', 'ok', 'setdefault', 'message', 'Planner idea applied', '_set_status'
        pass

    def deletePlannerIdea(self, template_id: 'str', idea_id: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_service', 'delete_content_plan_idea', '_planner_template_id', '_load_planner_state', 'str', 'get', 'template_id', 'plannerIdeasChanged', 'emit', 'dict', 'setdefault', 'message', 'ok', 'Planner idea deleted', 'Planner idea not found'
        pass

    def saveTemplate(self, payload: 'dict[str, Any]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'dict', '_service', 'save_content_template', 'str', 'get', 'template_id', '_planner_template_id', '_load_planner_state', 'plannerTemplatesChanged', 'emit', 'plannerTemplateChanged', 'plannerIdeasChanged', '_set_status', 'message', 'error'
        pass

    def deleteTemplate(self, template_id: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'dict', '_service', 'delete_content_template', '_load_planner_state', '', 'plannerTemplatesChanged', 'emit', 'plannerTemplateChanged', 'plannerIdeasChanged', '_set_status', 'str', 'get', 'message', 'error', 'Template delete finished'
        pass

    def generateAiTemplate(self, description: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_feature_blocked', 'research.ai_template', 'dict', '_service', 'generate_content_template', 'str', 'get', 'template_id', '_planner_template_id', '_load_planner_state', 'plannerTemplatesChanged', 'emit', 'plannerTemplateChanged', 'plannerIdeasChanged', '_set_status'
        pass

    def sendToTranscript(self, topic: 'str' = '', notes: 'str' = '') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_report_markdown', '_preview_prompt', 'dict', '_service', 'send_to_transcript', 'job_id', 'topic', 'prompt', 'notes', '_last_job_id', 'setdefault', 'action', 'research.transcript.send', 'message', 'get'
        pass

    def generateAssetPack(self, topic: 'str', notes: 'str' = '') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_feature_blocked', 'research.asset_pack', 'dict', '_service', 'generate_asset_pack', 'topic', 'notes', 'get', 'asset_pack', '_asset_pack', 'format_asset_pack', '', '_asset_pack_text', 'assetPackChanged', 'emit'
        pass

    def copyAssetPack(self) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_asset_pack_text', 'ok', False, 'blocked', 'action', 'research.asset_pack.copy', 'error', 'asset_pack_empty', 'code', 'message', 'Asset pack is empty', '_set_action_result', 'failure_message', 'QGuiApplication', 'clipboard'
        pass

    def exportAssetPack(self, format: 'str' = 'md') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'dict', '_service', 'export_asset_pack', '_asset_pack', 'format', 'setdefault', 'action', 'research.asset_pack.export', 'message', 'str', 'get', 'path', 'error', 'Asset pack export requested', '_set_action_result'
        pass

    def captureContextFiles(self, paths: 'list[Any]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'str', '', 'strip', 'append', 'ok', 'blocked', 'action', 'count', 'paths', 'message', True, False, 'research.context_files.capture', 'len', 'Captured '
        pass

    def generateEvidencePack(self, topic: 'str', report: 'str' = '', notes: 'str' = '', language: 'str' = 'vi') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_feature_blocked', 'research.evidence_pack', 'dict', '_service', 'generate_evidence_pack', 'job_id', 'topic', 'report', 'notes', 'language', 'metadata_prompt', '_last_job_id', '_report_markdown', '_preview_prompt', 'str'
        pass

    def extractMetadata(self, topic: 'str', report: 'str' = '', notes: 'str' = '', language: 'str' = 'vi') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'dict', '_service', 'extract_metadata', 'job_id', 'topic', 'report', 'notes', 'language', '_last_job_id', '_report_markdown', '_preview_prompt', 'str', '', 'strip', '_last_topic'
        pass

    def saveMetadataKit(self, titles_text: 'str', descriptions_text: 'str', thumbnail_prompts_text: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'str', '', 'split', '\n', 'strip', '\n\n', '_metadata', 'titles', 'descriptions', 'thumbnail_prompts', '_last_action', 'isinstance', 'dict', 'setdefault', 'metadata'
        pass

    def approveContent(self, topic: 'str' = '', notes: 'str' = '') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'dict', '_service', 'approve_content', 'job_id', 'topic', 'report', 'notes', '_last_job_id', '_last_topic', '_report_markdown', '_preview_prompt', 'str', '', 'strip', '_apply_report_result'
        pass

    def requestMoreResearch(self, topic: 'str' = '', notes: 'str' = '') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'dict', '_service', 'request_more_research', 'job_id', 'topic', 'report', 'notes', '_last_job_id', '_last_topic', '_report_markdown', '_preview_prompt', 'str', '', 'strip', '_apply_report_result'
        pass

    def sendChat(self, message: 'str', view: 'str' = '', topic: 'str' = '', notes: 'str' = '') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'report', 'str', '', 'strip', 'lower', 'script', 'plan', 'dict', '_service', 'send_chat', 'job_id', 'topic', 'message', 'target', 'source_text'
        pass

    def runAuto(self, topic: 'str', language: 'str' = 'vi', duration: 'str' = 'auto', tone: 'str' = 'professional') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'runAutoConfigured', 'language', 'duration', 'tone'
        pass

    def runAutoConfigured(self, topic: 'str', config: 'dict[str, Any]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'dict', 'topic', '_service', 'run_auto', 'str', '', 'strip', '_last_topic', '_apply_report_result', '_set_action_result', 'action', 'research.auto.run', 'success_message', 'get', 'summary'
        pass

    def runStep(self, job_id: 'str', step: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_service', 'run_step', '_last_job_id', '_apply_report_result', '_set_action_result', 'action', 'research.step.run', 'success_message', "Step '", "' completed", 'failure_message', 'Step failed', 'refresh'
        pass

    def runStepForTopic(self, topic: 'str', step: 'str', language: 'str' = 'vi', duration: 'str' = 'auto', tone: 'str' = 'professional') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'runStepForTopicConfigured', 'job_id', 'language', 'duration', 'tone', '_last_job_id'
        pass

    def runStepForTopicConfigured(self, topic: 'str', step: 'str', config: 'dict[str, Any]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'dict', 'setdefault', 'job_id', '_last_job_id', '_service', 'run_step_for_topic', 'str', '', 'strip', '_last_topic', '_apply_report_result', '_set_action_result', 'action', 'research.step.run_for_topic', 'success_message'
        pass

    def addToQueue(self, topic: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'str', '', 'strip', '_last_topic', 'ok', False, 'blocked', 'action', 'research.queue.add', 'error', 'topic_required', 'code', 'message', 'Research topic is required', '_set_action_result'
        pass

    def startQueue(self) -> 'None':
        # [PyArmor BCC constants]: '_service', 'start_queue', '_apply_report_result', 'get', 'completed', 'queue_', 1, '_last_job_id', 'format_report', 'str', 'report', '_report_markdown', 'reportChanged', 'emit', '_set_action_result'
        pass

    def pollScheduler(self) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'dict', '_service', 'process_due_schedules', 'int', 'get', 'started', 0, 'failed', '_apply_report_result', '_set_action_result', 'action', 'research.schedule.process_due', 'success_message', 'Research scheduler started ', ' job(s)'
        pass

    def activeJobRunning(*args, **kwargs):
        pass

    def activeJobStatus(*args, **kwargs):
        pass

    def _set_active_running(self, running: 'bool') -> 'None':
        # [PyArmor BCC constants]: 'bool', 'getattr', '_active_running', False, 'activeRunningChanged', 'emit'
        pass

    def _set_active_status(self, status: 'str') -> 'bool':
        # [PyArmor BCC constants]: 'str', '', 'strip', 'lower', 'running', '_active_status', '_active_running', 'activeRunningChanged', 'emit', True, '_set_active_running', False
        pass

    def syncActive(self) -> 'None':
        # [PyArmor BCC constants]: 'str', '_last_job_id', '', 'strip', '_set_active_status', '_service', 'get_history_entry', 'get', 'ok', 'dict', 'entry', 'plan', False, '_plan_markdown', True
        pass

    def pauseQueue(self) -> 'None':
        # [PyArmor BCC constants]: '_service', 'pause_queue', '_set_action_result', 'action', 'research.queue.pause', 'success_message', 'Research queue paused (', 'get', 'paused', 0, ' pending)', 'failure_message', 'Research queue pause failed', 'refresh'
        pass

    def clearQueue(self) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'dict', '_service', 'clear_queue', 'setdefault', 'action', 'research.queue.clear', 'message', 'Research queue cleared', '_set_action_result', 'success_message', 'failure_message', 'Research queue clear failed', 'refresh'
        pass

    def removeRow(self, row_id: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'str', '', 'strip', 'ok', False, 'blocked', 'action', 'research.queue.remove_row', 'error', 'missing_row_id', 'code', 'message', 'Missing research row id', '_set_action_result', 'failure_message'
        pass

    def saveAudio(self, job_id: 'str' = '') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_service', 'save_audio', '_last_job_id', 'dict', 'setdefault', 'action', 'research.audio.save', 'message', 'str', 'get', 'path', 'error', 'Audio save requested', '_set_action_result', 'success_message'
        pass

    def saveReport(self, job_id: 'str' = '', format: 'str' = 'txt') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'str', '_last_job_id', '', 'strip', '_service', 'save_report', 'format', 'save_report_markdown', '_report_markdown', '_preview_prompt', 'topic', '_last_topic', 'get', 'ok', 'job_id'
        pass

    def copyReport(self) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_report_markdown', '_preview_prompt', 'ok', False, 'blocked', 'action', 'research.report.copy', 'error', 'report_content_empty', 'code', 'message', 'No report content to copy', '_set_action_result', 'failure_message', 'QGuiApplication'
        pass

    def loadHistory(self, job_id: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_service', 'get_history_entry', 'get', 'ok', 'str', '', '_last_job_id', 'report', '_report_markdown', 'reportChanged', 'emit', 'dict', 'entry', '_set_active_status', 'status'
        pass

    def copyHistory(self, job_id: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_service', 'get_history_entry', 'get', 'ok', 'dict', 'setdefault', 'action', 'research.history.copy', 'message', 'str', 'error', 'History entry not found', '_set_action_result', 'failure_message', 'QGuiApplication'
        pass

    def copyScriptHistory(self, job_id: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_service', 'get_history_entry', 'get', 'ok', 'dict', 'setdefault', 'action', 'research.history.copy_script', 'message', 'str', 'error', 'History entry not found', '_set_action_result', 'failure_message', 'entry'
        pass

    def loadScriptHistory(self, job_id: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_service', 'get_history_entry', 'get', 'ok', 'dict', 'setdefault', 'action', 'research.history.load_script', 'message', 'str', 'error', 'History entry not found', '_set_action_result', 'failure_message', 'entry'
        pass

    def openHistoryFolder(self, job_id: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_service', 'get_history_entry', 'get', 'ok', 'dict', 'setdefault', 'action', 'research.history.open_folder', 'message', 'str', 'error', 'History entry not found', '_set_action_result', 'failure_message', 'entry'
        pass

    def deleteHistory(self, job_id: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'dict', '_service', 'delete_history', 'setdefault', 'action', 'research.history.delete', 'message', 'get', 'ok', 'Research history deleted', 'str', 'error', 'History entry not found', '_set_action_result', 'success_message'
        pass

    def playAudio(self, job_id: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'dict', '_service', 'play_audio', '_last_job_id', 'str', 'get', 'audio_path', '', 'strip', 'ok', '_open_local_path', True, 'opened', 'message', 'blocked'
        pass

    def addSchedule(self, topic: 'str', cron: 'str') -> 'dict[str, Any]':
        pass

    def addScheduleConfigured(self, topic: 'str', cron: 'str', config: 'dict') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'str', '', 'strip', 'ok', False, 'blocked', 'action', 'research.schedule.add', 'error', 'topic_required', 'code', 'message', 'Schedule topic is required', '_set_action_result', 'failure_message'
        pass

    def addScheduleAdvanced(self, topic: 'str', cron: 'str', quality_mode: 'bool', auto_director_notes: 'bool', auto_import: 'bool') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'str', '', 'strip', 'ok', False, 'blocked', 'action', 'research.schedule.add', 'error', 'topic_required', 'code', 'message', 'Schedule topic is required', '_set_action_result', 'failure_message'
        pass

    def runScheduleNow(self, schedule_id: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'dict', '_service', 'run_schedule_now', 'setdefault', 'action', 'research.schedule.run_now', 'message', 'get', 'ok', 'Schedule executed', 'str', 'error', 'Schedule failed', '_set_action_result', 'success_message'
        pass

    def toggleSchedule(self, schedule_id: 'str', enabled: 'bool') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'dict', '_service', 'toggle_schedule', 'setdefault', 'action', 'research.schedule.toggle', 'message', 'get', 'ok', 'Schedule updated', 'str', 'error', 'Schedule failed', '_set_action_result', 'success_message'
        pass

    def resetSchedule(self, schedule_id: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'dict', '_service', 'reset_schedule', 'setdefault', 'action', 'research.schedule.reset', 'message', 'get', 'ok', 'Schedule reset', 'str', 'error', 'Schedule failed', '_set_action_result', 'success_message'
        pass

    def removeSchedule(self, schedule_id: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'dict', '_service', 'remove_schedule', 'setdefault', 'action', 'research.schedule.remove', 'message', 'get', 'ok', 'Schedule removed', 'str', 'error', 'Schedule not found', '_set_action_result', 'success_message'
        pass

    def generateScript(self, format: 'str' = 'monologue', speakers: 'str' = '', duration: 'str' = 'auto') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_feature_blocked', 'research.script.generate', '_service', 'run_step', '_last_job_id', 'script', '_apply_report_result', 'setdefault', 'action', 'message', 'str', 'get', 'summary', 'error', 'Script generation started'
        pass

    def generateScriptForTopic(self, topic: 'str', format: 'str' = 'monologue') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_feature_blocked', 'research.script.generate_for_topic', '_service', 'run_step_for_topic', 'script', 'job_id', 'script_format', 'script_prompt', '_last_job_id', 'str', '_planner_template', 'get', '', '_last_topic', 'strip'
        pass

    def generateTts(self, voice: 'str' = '', model: 'str' = '') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_feature_blocked', 'research.tts.generate', '_service', 'run_step', '_last_job_id', 'tts', '_apply_report_result', 'setdefault', 'action', 'message', 'str', 'get', 'summary', 'error', 'TTS generation started'
        pass

    def generateDirectorNotes(self, topic: 'str' = '', script: 'str' = '', language: 'str' = 'vi') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_service', 'run_step_for_topic', '_last_topic', 'director_notes', 'job_id', 'script', 'language', '_last_job_id', '_report_markdown', '_apply_report_result', 'setdefault', 'action', 'research.director_notes.generate', 'message', 'str'
        pass

    def getState(self) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'ok', 'job_id', 'topic', 'report', 'preview', 'planner_template_id', 'planner_template', True, '_last_job_id', '_last_topic', '_report_markdown', '_preview_prompt', '_planner_template_id', '_planner_template'
        pass

    def applyState(self, state: 'dict[str, Any]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'str', 'get', 'job_id', '', 'strip', '_last_job_id', 'topic', '_last_topic', 'report', '_report_markdown', 'reportChanged', 'emit', 'preview', '_preview_prompt', 'previewChanged'
        pass

    def generateScriptQuality(self, topic: 'str' = '') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: '_service', 'run_step', '_last_job_id', 'script_quality', '_apply_report_result', 'setdefault', 'action', 'research.script.quality', 'message', 'str', 'get', 'summary', 'Script quality generation started', '_set_action_result', 'success_message'
        pass

    def buildTtsPrompt(self, voice: 'str' = '', model: 'str' = '') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'DeepResearchService', '_report_markdown', '_preview_prompt', 'hasattr', 'build_tts_prompt', '', 'ok', 'prompt', 'voice', 'model', 'action', 'message', True, 'str', 'research.tts.build_prompt'
        pass

    def _apply_assessment_result(self, result: 'dict[str, Any]') -> 'None':
        # [PyArmor BCC constants]: 'get', 'ok', 'dict', 'assessment', '_assessment', 'str', 'recommended_pipeline', '', 'tool_preset', 'bool', 'needs_visualization', 'assessmentChanged', 'emit', 'summary', '_preview_prompt'
        pass

    def assessTopic(self, topic: 'str', language: 'str' = 'vi') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'dict', '_service', 'assess_topic', 'topic', 'language', '_last_topic', 'str', '', 'strip', '_apply_assessment_result', 'setdefault', 'action', 'research.topic.assess', 'message', 'get'
        pass

    def plannerGenerating(*args, **kwargs):
        pass

    def plannerNotice(*args, **kwargs):
        pass

    def generatePlannerIdeasAsync(self, template_id: 'str', seed_topic: 'str' = '', count: 'int' = 5) -> 'None':
        # [PyArmor BCC constants]: 'getattr', '_planner_generating', False, '_feature_blocked', 'research.planner_ideas', 'str', 'get', 'message', 'Planner bị khoá theo license', '_planner_notice', 'plannerGeneratingChanged', 'emit', True, '', '_service'
        pass

    def _on_planner_ideas_done(self, result: 'object') -> 'None':
        # [PyArmor BCC constants]: False, '_planner_generating', 'isinstance', 'dict', 'get', 'ok', '', '_planner_notice', 'Đã tạo ', 'int', 'added', 0, ' ý tưởng', 'str', 'message'
        pass

    def assessTopicAsync(self, topic: 'str', language: 'str' = 'vi') -> 'None':
        # [PyArmor BCC constants]: 'str', '', 'strip', '_assessing', True, 'assessingChanged', 'emit', '_service', '_last_topic', 'dict', 'assess_topic', 'topic', 'language', 'ok', 'error'
        pass

    def _on_assess_done(self, result: 'object') -> 'None':
        # [PyArmor BCC constants]: False, '_assessing', 'assessingChanged', 'emit', 'isinstance', 'dict', 'str', 'get', 'topic', '_last_topic', '', 'strip', '_apply_assessment_result', '_set_action_result', 'action'
        pass

    def runFastContent(self, topic: 'str', config: 'dict[str, Any]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'dict', 'setdefault', 'job_id', '_last_job_id', '_service', 'run_step_for_topic', '_last_topic', 'fast_content', 'str', '', 'strip', '_apply_report_result', '_set_action_result', 'action', 'research.fast_content.run'
        pass

    def runRecommended(self, topic: 'str', config: 'dict[str, Any]') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'str', '_assessment', 'get', 'recommended_pipeline', '', 'strip', 'dict', 'setdefault', 'job_id', '_last_job_id', 'fast_content', 'runFastContent', 'web', 'tool_preset', '_service'
        pass

    def cancelCurrent(self) -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'str', '_last_job_id', '', 'strip', 'ok', True, 'action', 'research.job.cancel', 'message', 'No active research job.', '_set_action_result', 'success_message', 'dict', '_service', 'cancel_job'
        pass

    def markBlocked(self, action: 'str') -> 'None':
        pass

    def _load_planner_store_path(self) -> 'str':
        # [PyArmor BCC constants]: 'str', '_service', 'content_planner_store_path', '', 'Exception'
        pass

    def _load_planner_state(self, template_id: 'str' = '') -> 'None':
        # [PyArmor BCC constants]: '_service', 'get_content_planner_state', '_coerce_rows', 'templates', '_planner_templates', 'ideas', '_planner_ideas', 'str', 'get', 'selected_template_id', '', '_planner_template_id', 'selected_template', 'isinstance', 'dict'
        pass

    def _apply_report_result(self, result: 'dict[str, Any]') -> 'None':
        # [PyArmor BCC constants]: 'str', 'get', 'job_id', '', '_last_job_id', 'historyChanged', 'emit', 'prompt', '_preview_prompt', 'previewChanged', 'report', '_report_markdown', 'reportChanged', 'status', 'strip'
        pass

    def _set_action_result(self, result: 'dict[str, Any]', *, action: 'str', success_message: 'str' = '', failure_message: 'str' = '') -> 'None':
        # [PyArmor BCC constants]: 'isinstance', 'get', 'blocker', 'dict', 'bool', 'blocked', 'str', 'code', 'error', '', 'message', 'ok', 'Research action completed', 'action', '_last_action'
        pass

    def _set_status(self, message: 'str') -> 'None':
        pass

    def _open_local_path(self, path: 'str') -> 'dict[str, Any]':
        # [PyArmor BCC constants]: 'Path', 'str', '', 'expanduser', 'exists', 'ok', 'code', 'error', 'message', 'path', False, 'path_missing', 'Path does not exist: ', 'os', 'name'
        pass

    def _on_schedule_timer(self) -> 'None':
        # [PyArmor BCC constants]: '_schedule_poll_inflight', True, '_service', 'dict', 'process_due_schedules', 'ok', 'error', 'message', False, 'type', '__name__', 'Research scheduler poll failed: ', 'Exception', '_scheduleDone', 'emit'
        pass

    def _on_schedule_done(self, result: 'object') -> 'None':
        # [PyArmor BCC constants]: False, '_schedule_poll_inflight', 'isinstance', 'dict', 'get', 'ok', 'error', '_set_status', 'str', 'message', 'Research scheduler poll failed', 'int', 'started', 0, 'failed'
        pass


# --- Top-Level Functions ---
def _coerce_rows(payload: 'dict[str, Any]', key: 'str') -> 'list[dict[str, Any]]':
    pass
