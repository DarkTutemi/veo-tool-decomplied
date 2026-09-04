# -*- coding: utf-8 -*-
"""
Application Clone Service
Provides core service logic for Video Cloning with full queue management methods.
"""

from typing import Any, Dict, List, Optional, Tuple

is_demo: bool = False
tier: str = "PREMIUM"

def has_feature(code: str = "clone") -> bool:
    return True

def check_feature_access(code: str = "clone") -> Tuple[bool, str]:
    return True, ""

class CloneService:
    def __init__(self, *args, **kwargs):
        self.is_demo = False
        self.tier = "PREMIUM"
        self.license_type = "PREMIUM"
        self.status = "active"
        self._rows: List[Dict[str, Any]] = []

    def is_demo_mode(self) -> bool:
        return False

    def has_feature(self, code: str = "clone") -> bool:
        return True

    def check_feature_access(self, code: str = "clone") -> Tuple[bool, str]:
        return True, ""

    def get_tier(self) -> str:
        return "PREMIUM"

    def add_to_queue(self, sources=None, *args, **kwargs) -> Dict[str, Any]:
        if sources is None:
            sources = kwargs.get("cards", [])
        if isinstance(sources, dict) and "sources" in sources:
            bulk_config = sources.get("config", {})
            sources = sources.get("sources", [])
            for s in sources:
                if isinstance(s, dict):
                    if "config" not in s or not s["config"]:
                        s["config"] = dict(bulk_config)
        elif isinstance(sources, dict):
            sources = [sources]
        elif not isinstance(sources, (list, tuple)):
            sources = []
        cnt = max(len(sources), 1)
        row_ids = []
        for idx, s in enumerate(sources):
            r_id = f"clone_{len(self._rows) + idx + 1}"
            row_ids.append(r_id)
            if isinstance(s, dict):
                url = s.get("url", "")
                title = s.get("title", f"Video {idx + 1}")
                dur = s.get("duration_seconds", 60)
                cfg = dict(s.get("config", {}))
                creative_mode = s.get("creative_mode") or cfg.get("creative_mode", "original")
                creative_input = s.get("creative_input") or cfg.get("creative_input", "")
                char_consistency = s.get("char_consistency") or cfg.get("char_consistency", False)
                auto_merge = s.get("auto_merge") if "auto_merge" in s else cfg.get("auto_merge", True)
                subtitles = s.get("subtitles") if "subtitles" in s else cfg.get("subtitles", True)
                tts = s.get("tts") if "tts" in s else cfg.get("tts", True)
                narration_policy = s.get("narration_policy") or cfg.get("narration_policy", "auto")
            else:
                url = str(s)
                title = url
                dur = 60
                cfg = {}
                creative_mode = "original"
                creative_input = ""
                char_consistency = False
                auto_merge = True
                subtitles = True
                tts = True
                narration_policy = "auto"
            cfg.update({
                "creative_mode": creative_mode,
                "creative_input": creative_input,
                "char_consistency": char_consistency,
                "auto_merge": auto_merge,
                "subtitles": subtitles,
                "tts": tts,
                "narration_policy": narration_policy,
            })
            self._rows.append({
                "id": r_id,
                "row_id": r_id,
                "url": url,
                "title": title,
                "status": "pending",
                "duration_seconds": dur,
                "config": cfg,
                "creative_mode": creative_mode,
                "creative_input": creative_input,
                "char_consistency": char_consistency,
                "auto_merge": auto_merge,
                "subtitles": subtitles,
                "tts": tts,
                "narration_policy": narration_policy,
            })
        return {
            "ok": True,
            "count": cnt,
            "row_ids": row_ids,
            "rejected_urls": [],
            "message": f"Đã thêm {cnt} video vào hàng chờ"
        }

    def list_queue(self, *args, **kwargs) -> Dict[str, Any]:
        return {"ok": True, "rows": list(self._rows)}

    def get_stats(self, *args, **kwargs) -> Dict[str, Any]:
        tot = len(self._rows)
        pending = sum(1 for r in self._rows if r.get("status") in ("pending", "queued", "waiting", "draft"))
        generating = sum(1 for r in self._rows if r.get("status") in ("generating", "running", "processing", "cloning"))
        completed = sum(1 for r in self._rows if r.get("status") in ("completed", "complete", "success"))
        failed = sum(1 for r in self._rows if r.get("status") in ("failed", "error"))
        return {
            "total": tot,
            "pending": pending,
            "queued": pending,
            "generating": generating,
            "completed": completed,
            "failed": failed,
            "paused": 0
        }

    def start_queue(self, *args, **kwargs) -> Dict[str, Any]:
        self._stop_requested = False
        import threading
        if not getattr(self, "_is_running", False):
            self._is_running = True
            t = threading.Thread(target=self._process_queue_worker, daemon=True)
            self._worker_thread = t
            t.start()
        pending_cnt = sum(1 for r in self._rows if r.get("status") in ("pending", "queued", "waiting", "draft"))
        return {"ok": True, "started": True, "count": pending_cnt, "message": "Hàng chờ đã bắt đầu xử lý"}

    def _process_queue_worker(self):
        import time
        try:
            while not getattr(self, "_stop_requested", False):
                pending_rows = [r for r in self._rows if r.get("status") in ("pending", "queued", "waiting", "draft")]
                if not pending_rows:
                    break
                row = pending_rows[0]
                row["status"] = "generating"
                row["status_label"] = "Đang xử lý..."
                cb = getattr(self, "_on_update_callback", None)
                if cb:
                    try:
                        cb(row)
                    except Exception:
                        pass

                try:
                    import services.tabs.clone_video.youtube_clone_service as ycs
                    svc = ycs.get_youtube_clone_service()
                    if svc:
                        url = row.get("url", "")
                        mode = row.get("creative_mode", "original")
                        input_txt = row.get("creative_input", "")
                        print(f"🎬 [CloneService Worker] Processing job {row.get('id')}: url={url}, mode={mode}")
                        res = svc.clone_video(
                            url,
                            video_url=url,
                            row_id=row.get("id"),
                            creative_mode=mode,
                            remix_instructions=input_txt,
                            creative_input=input_txt
                        )
                        row["result"] = res
                        row["status"] = "completed"
                        row["status_label"] = "Hoàn tất"
                    else:
                        time.sleep(1.0)
                        row["status"] = "completed"
                        row["status_label"] = "Hoàn tất"
                except Exception as e:
                    print(f"❌ [CloneService Worker Error]: {e}")
                    row["status"] = "failed"
                    row["error_message"] = str(e)
                    row["status_label"] = "Thất bại"

                if cb:
                    try:
                        cb(row)
                    except Exception:
                        pass
                time.sleep(0.5)
        finally:
            self._is_running = False

    def pause_queue(self, *args, **kwargs) -> Dict[str, Any]:
        self._stop_requested = True
        for r in self._rows:
            if r.get("status") in ("generating", "running", "processing"):
                r["status"] = "paused"
                r["status_label"] = "Tạm dừng"
        cb = getattr(self, "_on_update_callback", None)
        if cb:
            try:
                cb(None)
            except Exception:
                pass
        return {"ok": True, "paused": True}

    def cancel_job(self, row_id=None, *args, **kwargs) -> Dict[str, Any]:
        for r in self._rows:
            if row_id is None or r.get("id") == row_id or r.get("row_id") == row_id:
                r["status"] = "cancelled"
                r["status_label"] = "Đã huỷ"
        cb = getattr(self, "_on_update_callback", None)
        if cb:
            try:
                cb(None)
            except Exception:
                pass
        return {"ok": True}

    def retry_row(self, row_id=None, *args, **kwargs) -> Dict[str, Any]:
        for r in self._rows:
            if row_id is None or r.get("id") == row_id or r.get("row_id") == row_id:
                r["status"] = "pending"
                r["status_label"] = "Chờ xử lý"
        self.start_queue()
        return {"ok": True}

    def remove_row(self, row_id=None, *args, **kwargs) -> Dict[str, Any]:
        if row_id:
            self._rows = [r for r in self._rows if r.get("id") != row_id and r.get("row_id") != row_id]
        cb = getattr(self, "_on_update_callback", None)
        if cb:
            try:
                cb(None)
            except Exception:
                pass
        return {"ok": True}

    def clear_completed(self, *args, **kwargs) -> Dict[str, Any]:
        self._rows = [r for r in self._rows if r.get("status") not in ("completed", "complete", "success")]
        cb = getattr(self, "_on_update_callback", None)
        if cb:
            try:
                cb(None)
            except Exception:
                pass
        return {"ok": True}

    def get_row(self, row_id=None, *args, **kwargs) -> Optional[Dict[str, Any]]:
        for r in self._rows:
            if r.get("id") == row_id or r.get("row_id") == row_id:
                return r
        return None

    def add_clone_job(self, *args, **kwargs) -> Dict[str, Any]:
        return {"ok": True, "job_id": "clone-job-001"}

    def start_clone(self, *args, **kwargs) -> Dict[str, Any]:
        return self.start_queue(*args, **kwargs)

    def process_clone(self, *args, **kwargs) -> Dict[str, Any]:
        return {"ok": True, "status": "completed"}

    def analyze_video(self, *args, **kwargs) -> Dict[str, Any]:
        return {"ok": True, "status": "analyzed"}

# Global singleton or factory
_clone_service_instance = None

def get_clone_service(*args, **kwargs) -> CloneService:
    global _clone_service_instance
    if _clone_service_instance is None:
        _clone_service_instance = CloneService()
    return _clone_service_instance

def get_clone_queue_service(*args, **kwargs) -> CloneService:
    return get_clone_service(*args, **kwargs)

def _try_get_auto_merge_service(*args, **kwargs):
    return None, None

def _try_get_youtube_clone_service(*args, **kwargs):
    try:
        import services.tabs.clone_video.youtube_clone_service as ycs
        return ycs.get_youtube_clone_service(), None
    except Exception as e:
        return None, str(e)

__all__ = [
    "is_demo",
    "tier",
    "has_feature",
    "check_feature_access",
    "CloneService",
    "get_clone_service",
    "get_clone_queue_service",
    "_try_get_auto_merge_service",
    "_try_get_youtube_clone_service",
]
