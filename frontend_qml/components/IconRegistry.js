.pragma library

var ACTION_ICONS = {
    "account.add": "user-round",
    "account.edit": "pencil",
    "account.delete": "trash-2",
    "error_log": "triangle-alert",
    "header.about": "circle-alert",
    "header.credits": "zap",
    "header.gemini_api": "key-round",
    "header.license": "shield-check",
    "header.media_library": "images",
    "header.renew": "refresh-cw",
    "header.store": "shopping-bag",
    "header.style_manager": "palette",
    "header.update": "download",
    "header.wiki": "book-open",
    "header.youtube": "video",
    "job_monitor.cancel_all": "circle-x",
    "job_monitor.close": "x",
    "job_monitor.refresh": "refresh-cw",
    "job_monitor.start": "play",
    "job_monitor.stop": "square",
    "json_value_editor.value_type": "list-check",
    "license.check": "shield-check",
    "license.key": "key-round",
    "master.config.folder_picker": "folder-open",
    "master.config.style_manager": "settings",
    "master.dialog.bulk_import": "upload",
    "master.dialog.script_guide": "book-open",
    "master.input.extra_requirements": "message-square-text",
    "master.input.idea_mode": "sparkles",
    "clone.creative_autosave": "users-round",
    "master.input.script_mode": "file-text",
    "master.queue.add_to_queue": "plus",
    "master.queue.clear_all": "trash-2",
    "master.queue.delete_row": "trash-2",
    "master.queue.details": "eye",
    "master.queue.open_clip": "video",
    "master.queue.open_folder": "folder-open",
    "master.queue.open_folder_selected": "folder-open",
    "master.queue.open_scene_clip": "video",
    "master.queue.review": "eye",
    "master.queue.start_processing": "play",
    "master.queue.stop_delete": "square",
    "media_library.import": "image-plus",
    "model.select": "bot",
    "prompt_card.delete": "trash-2",
    "prompt_card.edit": "pencil",
    "prompt_card.extend": "layers",
    "prompt_card.insert_after_requested": "plus",
    "prompt_card.generate_extend": "wand-sparkles",
    "prompt_card.media": "images",
    "prompt_card.remove_timeline": "trash-2",
    "prompt_card.submit": "send",
    "status.dispatcher": "activity",
    "status.errors": "triangle-alert",
    "status.log": "file-text",
    "status.monitor": "monitor",
    "status.server_queue": "database",
    "status.tokens": "gauge",
    "token_monitor.clear": "trash-2",
    "token_monitor.close": "x",
    "token_monitor.export": "download",
    "token_monitor.refresh": "refresh-cw",
    "work_panel.add_blank": "plus",
    "work_panel.add_from_text": "file-text",
    "work_panel.affiliate_background": "image",
    "work_panel.affiliate_character": "user-round",
    "work_panel.affiliate_start": "play",
    "work_panel.affiliate_template": "file-text",
    "work_panel.affiliate_voice": "mic",
    "work_panel.batch_actions": "list-check",
    "work_panel.batch_config": "settings",
    "work_panel.batch_open_folder": "folder-open",
    "work_panel.batch_reference_images": "images",
    "work_panel.bulk_import": "upload",
    "work_panel.clear_cards": "trash-2",
    "work_panel.clear_queue": "trash-2",
    "work_panel.clone_analyze_scenes": "sparkles",
    "work_panel.clone_apply_style": "wand-sparkles",
    "work_panel.clone_batch_config": "settings",
    "work_panel.clone_video_files": "video",
    "work_panel.clone_video_folder": "folder-open",
    "work_panel.clone_view_uploaded": "upload",
    "work_panel.extend_bulk_import": "upload",
    "work_panel.extend_delete_session": "trash-2",
    "work_panel.extend_generate_timeline": "timer",
    "work_panel.extend_import_session": "download",
    "work_panel.extend_preview": "eye",
    "work_panel.extend_queue_view": "list-check",
    "work_panel.extend_render_video": "video",
    "work_panel.extend_rules": "settings",
    "work_panel.history": "history",
    "work_panel.pause_queue": "pause",
    "work_panel.product_library": "shopping-bag",
    "work_panel.queue_delete_row": "trash-2",
    "work_panel.queue_open_clip": "video",
    "work_panel.queue_open_output": "folder-open",
    "work_panel.route_characters": "user-round",
    "work_panel.select_all_cards": "check",
    "work_panel.start_queue": "play",
    "work_panel.submit_all": "send",
    "work_panel.transcript_audio_files": "audio-lines",
    "work_panel.transcript_audio_folder": "folder-open",
    "work_panel.unselect_all_cards": "x"
}

var TEXT_RULES = [
    ["delete", "trash-2"],
    ["clear", "trash-2"],
    ["remove", "trash-2"],
    ["cancel", "circle-x"],
    ["close", "x"],
    ["save", "save"],
    ["refresh", "refresh-cw"],
    ["reset", "rotate-ccw"],
    ["retry", "refresh-cw"],
    ["start", "play"],
    ["play", "play"],
    ["run", "play"],
    ["pause", "pause"],
    ["stop", "square"],
    ["generate", "wand-sparkles"],
    ["import", "upload"],
    ["export", "download"],
    ["upload", "upload"],
    ["download", "download"],
    ["add", "plus"],
    ["choose", "folder-open"],
    ["select", "check"],
    ["open", "folder-open"],
    ["folder", "folder-open"],
    ["copy", "copy"],
    ["search", "search"],
    ["settings", "settings"],
    ["config", "settings"],
    ["history", "history"],
    ["queue", "list-check"],
    ["media", "images"],
    ["image", "image"],
    ["video", "video"],
    ["voice", "mic"],
    ["audio", "audio-lines"],
    ["license", "shield-check"],
    ["key", "key-round"]
]

function normalizeIconName(value) {
    var name = String(value || "").trim()
    if (!name.length)
        return ""
    if (!/^[a-z0-9][a-z0-9-]*$/.test(name))
        return ""
    return name
}

function iconForAction(actionId) {
    var key = String(actionId || "").trim()
    if (!key.length)
        return ""
    if (ACTION_ICONS[key])
        return ACTION_ICONS[key]

    var lower = key.toLowerCase()
    if (lower.indexOf("delete") >= 0 || lower.indexOf("clear") >= 0 || lower.indexOf("remove") >= 0)
        return "trash-2"
    if (lower.indexOf("cancel") >= 0 || lower.indexOf("close") >= 0)
        return "circle-x"
    if (lower.indexOf("refresh") >= 0 || lower.indexOf("retry") >= 0)
        return "refresh-cw"
    if (lower.indexOf("start") >= 0 || lower.indexOf("play") >= 0 || lower.indexOf("submit") >= 0)
        return "play"
    if (lower.indexOf("pause") >= 0)
        return "pause"
    if (lower.indexOf("import") >= 0 || lower.indexOf("upload") >= 0)
        return "upload"
    if (lower.indexOf("export") >= 0 || lower.indexOf("download") >= 0)
        return "download"
    if (lower.indexOf("folder") >= 0 || lower.indexOf("open") >= 0)
        return "folder-open"
    if (lower.indexOf("history") >= 0)
        return "history"
    if (lower.indexOf("config") >= 0 || lower.indexOf("settings") >= 0 || lower.indexOf("rules") >= 0)
        return "settings"
    if (lower.indexOf("media") >= 0 || lower.indexOf("image") >= 0 || lower.indexOf("reference") >= 0)
        return "images"
    if (lower.indexOf("video") >= 0 || lower.indexOf("render") >= 0)
        return "video"
    if (lower.indexOf("voice") >= 0 || lower.indexOf("audio") >= 0)
        return "mic"
    if (lower.indexOf("license") >= 0)
        return "shield-check"
    return ""
}

function iconForText(text) {
    var lower = String(text || "").toLowerCase()
    if (!lower.length)
        return ""
    for (var i = 0; i < TEXT_RULES.length; i++) {
        if (lower.indexOf(TEXT_RULES[i][0]) >= 0)
            return TEXT_RULES[i][1]
    }
    return ""
}

function resolveIcon(actionId, text, explicitName) {
    var explicit = normalizeIconName(explicitName)
    if (explicit.length)
        return explicit
    var actionIcon = iconForAction(actionId)
    if (actionIcon.length)
        return actionIcon
    return iconForText(text)
}
