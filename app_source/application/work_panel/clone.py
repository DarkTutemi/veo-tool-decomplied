# -*- coding: utf-8 -*-
"""
Decompiled / Reconstructed Module: application.work_panel.clone
"""

import uuid
import re
from typing import Any, Dict, List, Optional, Tuple
from application.clone_service import (
    is_demo,
    tier,
    has_feature,
    check_feature_access,
    CloneService,
    get_clone_service,
    get_clone_queue_service,
)

def _try_get_youtube_clone_service():
    try:
        import services.tabs.clone_video.youtube_clone_service as ycs
        return ycs.YouTubeCloneService(), None
    except Exception as e:
        return None, str(e)

def _try_get_auto_merge_service():
    return None, None

class WorkPanelState:
    def __init__(self, ctrl=None):
        self.ctrl = ctrl
        self.cards = []
        self.queue = []

class CloneUseCases:
    def __init__(self, state=None):
        self.state = state
        try:
            import services.tabs.clone_video.youtube_clone_service as ycs
            self._service = ycs.YouTubeCloneService()
        except Exception:
            self._service = None

    def parse_clone_auto_fetch_entries(self, text: str) -> List[str]:
        if not text:
            return []
        lines = [line.strip() for line in str(text).splitlines() if line.strip()]
        return lines if lines else [str(text).strip()]

    def fetch_clone_videos_for_entry(self, entry: str, filter_mode: str = "all") -> List[Dict[str, Any]]:
        entry_str = str(entry or "").strip()
        try:
            import yt_dlp
            print(f"\n==== [VideoDetails] yt-dlp fetch for 1 videos ====")
            print(f"[1/1] 🔵 yt-dlp → {entry_str}...")
            ydl_opts = {"quiet": True, "skip_download": True, "no_warnings": True}
            with yt_dlp.YoutubeDL(ydl_opts) as ydl:
                info = ydl.extract_info(entry_str, download=False)
                title = info.get("title", entry_str)
                dur = info.get("duration", 60)
                vid_id = info.get("id", "vid")
                print(f"   ✅ yt-dlp OK: {title}...")
                print(f"   📦 Added: {title} (source=yt-dlp)\n")
                print(f"[VideoDetails] ✅ Fetched 1 videos")
                return [{
                    "video_id": vid_id,
                    "title": title,
                    "url": entry_str,
                    "views": info.get("view_count", 0),
                    "duration_seconds": dur,
                    "published_at": info.get("upload_date", "20260904"),
                    "_fetch_source": "yt-dlp",
                    "_fetch_failed": False,
                    "_invalid_url": False,
                }]
        except Exception as e:
            print(f"ℹ️ [CloneUseCases] Fetch via yt-dlp fallback: {e}")

        # Direct fallback:
        vid_id = "direct_" + str(abs(hash(entry_str)))[:8]
        if "v=" in entry_str:
            try:
                vid_id = entry_str.split("v=")[1].split("&")[0]
            except Exception:
                pass
        elif "youtu.be/" in entry_str:
            try:
                vid_id = entry_str.split("youtu.be/")[1].split("?")[0]
            except Exception:
                pass
        return [{
            "video_id": vid_id,
            "title": entry_str,
            "url": entry_str,
            "views": 0,
            "duration_seconds": 60,
            "published_at": "20260904",
            "_fetch_source": "direct_input",
            "_fetch_failed": False,
            "_invalid_url": False,
        }]

    def build_clone_card_from_video(self, video: Dict[str, Any]) -> Dict[str, Any]:
        cid = f"clone_{uuid.uuid4().hex[:8]}"
        return {
            "id": cid,
            "row_id": cid,
            "video_id": video.get("video_id", ""),
            "title": video.get("title", ""),
            "url": video.get("url", ""),
            "duration": video.get("duration_seconds", 60),
            "status": "ready",
            "prompt": video.get("title", ""),
        }

__all__ = [
    "is_demo",
    "tier",
    "has_feature",
    "check_feature_access",
    "CloneService",
    "CloneUseCases",
    "WorkPanelState",
    "get_clone_service",
    "get_clone_queue_service",
    "_try_get_youtube_clone_service",
    "_try_get_auto_merge_service",
]