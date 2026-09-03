"""
Decompiled / Reconstructed Module: qml_app.controllers.work_panel.ai_source_worker

Docstring:
Embedded AI source-analysis QThread worker for the Extend AI Director.
Extracted verbatim from work_panel_controller.py.
"""

from __future__ import annotations
import sys, os, typing
from typing import Any, Dict, List, Optional, Tuple, Union, Callable

# --- Module Constants & Globals ---
annotations = _Feature((3, 7, 0, 'beta', 1), None, 16777216)

# --- Class: EmbeddedAISourceAnalysisWorker ---
class EmbeddedAISourceAnalysisWorker(QThread):
    staticMetaObject = PySide6.QtCore.QMetaObject("EmbeddedAISourceAnalysisWorker" inherits "QThread":
Methods:
  #12 type=Signal, signature=re...

    resultReady = Signal()
    error = Signal()
    def __init__(self, idea: 'str', image_b64: 'str' = '', mime_type: 'str' = 'image/png') -> 'None':
        pass

    def run(self) -> 'None':
        # [PyArmor BCC constants]: 'get_ai_provider', 'auto', 'feature', 'extend_video', 'RuntimeError', 'No AI provider available', 'Analyze this reference for an extend-video planning workflow. Return JSON only with keys: subject, material, environment, camera, style, process_type, risks, opportunities. Be concise. Infer what kind of transformation/timelapse/process video this could become. User idea: ', 'idea', '(none)', 'image_b64', 'generate_with_media', 'parts', 'base64_data', 'mime_type', 'light'
        pass


# --- Class: EmbeddedAITimelineWorker ---
class EmbeddedAITimelineWorker(QThread):
    """
    Runs the extend ROOT→EXTEND timeline AI generation OFF the GUI thread.
    
        ``generate_scenes`` is network-bound (5-60s); calling it on the GUI thread freezes the
        app (qml-patterns Law 1). ``resultReady(dict)`` carries the raw generate_scenes result
        (scenes + process_summary); the controller marshals it back to build cards + summary.
    """
    staticMetaObject = PySide6.QtCore.QMetaObject("EmbeddedAITimelineWorker" inherits "QThread":
Methods:
  #12 type=Signal, signature=resultRe...

    resultReady = Signal()
    error = Signal()
    def __init__(self, kwargs: 'dict') -> 'None':
        pass

    def run(self) -> 'None':
        # [PyArmor BCC constants]: 'get_extend_prompt_service', 'generate_scenes', '_kwargs', 'resultReady', 'emit', 'dict', 'error', 'type', '__name__', ': ', 'Exception'
        pass

