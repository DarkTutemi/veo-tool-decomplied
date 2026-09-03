.pragma library

// Baked sample data shown in the REAL tab widgets while a guided tour runs
// (TourState.preview). Purely illustrative — never dispatched, never persisted.
// Fields are over-provided so whichever field a delegate reads, it finds
// something sensible; extra fields are ignored.

function _cfg(over) {
    var c = {
        aspect_ratio: "16:9", duration: 48, language: "vi",
        style: "Cinematic", style_id: "cinematic", camera: "Dolly In", camera_id: "dolly_in",
        technique_name: "Cinematic", material_name: "Realistic", material_id: "realistic",
        voice_language: "vi", voice_id: "vi_male_warm", model_key: "veo3"
    }
    if (over) { for (var k in over) c[k] = over[k] }
    return c
}

function masterQueue() {
    return [
        { id: "demo-q1", row_id: "demo-q1", batch_id: "demo-q1",
          name: "Bí ẩn kim tự tháp Ai Cập", title: "Bí ẩn kim tự tháp Ai Cập",
          idea: "Khám phá cách người Ai Cập cổ xây kim tự tháp Giza — góc nhìn điện ảnh.",
          prompt: "Cinematic documentary about the Great Pyramid of Giza...",
          input_mode: "idea", status: "generating", status_label: "Đang tạo", state: "generating", job_status: "generating",
          scene_count: 6, video_count: 6, progress: 62, job_progress: 62,
          config: _cfg({ duration: 48 }) },
        { id: "demo-q2", row_id: "demo-q2", batch_id: "demo-q2",
          name: "Review tai nghe XY-9 Pro", title: "Review tai nghe XY-9 Pro",
          idea: "Đánh giá chi tiết tai nghe XY-9 Pro, tập trung chất âm và pin.",
          prompt: "Sleek product review of XY-9 Pro headphones...",
          input_mode: "idea", status: "completed", status_label: "Hoàn tất", state: "completed", job_status: "completed",
          scene_count: 4, video_count: 4, progress: 100, job_progress: 100,
          config: _cfg({ duration: 32, style: "Product", technique_name: "Product Shot" }) },
        { id: "demo-q3", row_id: "demo-q3", batch_id: "demo-q3",
          name: "Công thức bánh mì Việt Nam", title: "Công thức bánh mì Việt Nam",
          idea: "Hướng dẫn làm bánh mì Việt giòn rụm tại nhà.",
          prompt: "Warm cooking video: authentic Vietnamese banh mi...",
          input_mode: "idea", status: "ready", status_label: "Chờ", state: "ready", job_status: "ready",
          scene_count: 5, video_count: 5, progress: 0, job_progress: 0,
          config: _cfg({ duration: 40, style: "Warm", language: "vi" }) }
    ]
}

// The card resolves its thumbnail from `thumbnail_url` (snake_case) on the row when
// the model role is empty (array feed). Use seeded picsum images (end in .jpg so
// isImagePath passes) — always available online, different per scene.
function _thumb(seed) {
    return "https://picsum.photos/seed/veoflow" + seed + "/320/200.jpg"
}

function _job(i, sceneId, label, status, statusText, progress) {
    var canRetry = (status === "completed" || status === "error")
    return {
        id: "demo-j" + i, job_id: "demo-j" + i, jobId: "demo-j" + i,
        kind: "video", sequenceNumber: i,
        row_id: "demo-q1", master_prompt_job_id: "demo-q1",
        scene_id: sceneId, scene_index: i - 1, scene_label: label,
        title: label, subtitle: sceneId + " · 16:9 · 8s",
        prompt: label + " — cinematic wide shot, warm light.",
        status: status, statusText: statusText, statusChipText: statusText,
        status_label: statusText, state: status, job_status: status,
        progress: progress, job_progress: progress, aspectRatio: "16:9", aspect: "16:9",
        canRetry: canRetry, canEdit: true, canDelete: true, canUpscale: (status === "completed"),
        // cover EVERY field name the card's thumbnailSource() checks + the model
        // role, so whichever path the delegate reads finds the image:
        thumbnailUrl: _thumb(i), thumbnail_url: _thumb(i), thumbnail_path: _thumb(i),
        thumb_path: _thumb(i), thumbnail: _thumb(i), preview_image: _thumb(i),
        preview_path: _thumb(i), thumbnailPlaceholder: label
    }
}

function masterJobs() {
    return [
        _job(1, "S001", "Cảnh 1 · Toàn cảnh kim tự tháp", "completed", "Xong", 100),
        _job(2, "S002", "Cảnh 2 · Sa mạc Sahara", "completed", "Xong", 100),
        _job(3, "S003", "Cảnh 3 · Chân dung Pharaoh", "generating", "Đang tạo", 62),
        _job(4, "S004", "Cảnh 4 · Bên trong lăng mộ", "generating", "Đang tạo", 28)
    ]
}

function masterStats() {
    return { total: 4, generating: 2, completed: 2, ready: 0, failed: 0, pending: 0,
             analyzed: 4, uploaded: 4 }
}

// Work tabs (Clone / Transcript / Normal / Extend / Batch) share the same generic
// "video being generated" demo so their job panel + queue look alive during a tour.
function workQueue() { return masterQueue() }
function workJobs() { return masterJobs() }
function workStats() { return masterStats() }
