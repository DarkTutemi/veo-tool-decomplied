.pragma library

var FEATURE_ICONS = {
    "account.accounts": "busts-in-silhouette",
    "account.active": "check-mark-button",
    "account.expires": "alarm-clock",
    "account.free_credits": "wrapped-gift",
    "account.license": "locked-with-key",
    "account.paid_credits": "money-bag",
    "account.proxy": "globe-with-meridians",
    "account.videos": "video-camera",
    "app.veoflow": "rocket",
    "community.facebook": "globe-americas",
    "community.group": "busts-in-silhouette",
    "community.web": "globe-with-meridians",
    "community.youtube": "video-camera",
    "dialog.license": "locked-with-key",
    "error.log": "red-triangle",
    "home.announcements": "loudspeaker",
    "home.community": "globe-with-meridians",
    "home.open_affiliate_url": "shopping-bags",
    "home.promo": "shopping-bags",
    "home.refresh": "clockwise-arrows",
    "home.route.affiliate": "shopping-bags",
    "home.route.batch": "artist-palette",
    "home.route.clone": "movie-camera",
    "home.route.extend": "clockwise-arrows",
    "home.route.history": "spiral-calendar",
    "home.route.master": "robot",
    "home.route.normal": "video-camera",
    "home.route.research": "magnifying-glass",
    "home.route.settings": "gear",
    "home.route.transcript": "studio-microphone",
    "home.route.voice": "studio-microphone",
    "home.tips": "light-bulb",
    "job.monitor": "clipboard",
    "media.library": "framed-picture",
    "model.select": "robot",
    "token.monitor": "money-bag",
    "voice.config": "voice-config",
    "voice.content": "voice-content",
    "voice.output": "voice-output",
    "voice.provider.gemini": "voice-provider-gemini",
    "voice.provider.moss": "voice-provider-moss",
    "voice.provider.omni": "voice-provider-omni",
    "voice.provider.vieneu": "voice-provider-vieneu",
    "voice.queue": "voice-queue",
    "work_panel.product_library": "package"
}

var ROUTE_ICONS = {
    "affiliate": "shopping-bags",
    "automation": "puzzle-piece",
    "batch": "artist-palette",
    "clone": "movie-camera",
    "extend": "clockwise-arrows",
    "history": "spiral-calendar",
    "home": "rocket",
    "master": "robot",
    "normal": "video-camera",
    "research": "magnifying-glass",
    "settings": "gear",
    "timemachine": "alarm-clock",
    "transcript": "studio-microphone",
    "voice": "studio-microphone"
}

var ACTION_ICONS = {
    "account.add": "plus",
    "account.delete": "cross-mark",
    "account.edit": "pencil",
    "dialog.close": "cross-mark",
    "dialog.confirm": "check-mark-button",
    "dialog.ok": "check-mark-button",
    "error_log": "red-triangle",
    "timemachine.content_mode": "globe-with-meridians",
    "batch_session.clear": "cross-mark",
    "batch_session.retry": "counterclockwise-arrows-button",
    "batch_session.select_failed": "check-box-with-check",
    "batch_session.deselect_all": "cross-mark",
    "batch_session.close": "cross-mark",
    "header.about": "light-bulb",
    "header.automation_center": "puzzle-piece",
    "header.credits": "money-bag",
    "header.gemini_api": "key",
    "header.license": "locked-with-key",
    "header.media_library": "framed-picture",
    "header.renew": "clockwise-arrows",
    "header.store": "shopping-bags",
    "header.style_manager": "artist-palette",
    "header.update": "down-arrow",
    "header.wiki": "globe-with-meridians",
    "header.youtube": "video-camera",
    "job_monitor.cancel_all": "stop-sign",
    "job_monitor.close": "cross-mark",
    "job_monitor.refresh": "clockwise-arrows",
    "job_monitor.start": "fast-forward-button",
    "job_monitor.stop": "stop-sign",
    "json_value_editor.value_type": "clipboard",
    "license.check": "locked-with-key",
    "license.key": "key",
    "master.config.folder_picker": "open-folder",
    "master.config.style_manager": "gear",
    "master.dialog.bulk_import": "inbox-tray",
    "master.dialog.script_guide": "notebook",
    "master.feature.auto_mode": "magic-wand",
    "master.feature.manual_mode": "memo",
    "master.feature.auto_extend": "clockwise-arrows",
    "master.feature.character_consistency": "busts-in-silhouette",
    "master.feature.deep_analysis": "magnifying-glass",
    "master.feature.script_architect": "notebook",
    "master.feature.auto_merge_video": "package",
    "master.queue.auto_clear_completed": "open-folder",
    "master.feature.content_mode": "globe-with-meridians",
    "master.feature.subtitle_studio": "memo",
    "master.feature.char_mode_full_ai": "robot",
    "master.feature.char_mode_hybrid": "artist-palette",
    "master.feature.char_mode_manual": "pencil",
    "master.feature.route_characters": "busts-in-silhouette",
    "master.feature.clear_characters": "cross-mark",
    "master.feature.thinking": "brain",
    "master.feature.voice_lock": "locked-with-key",
    "master.feature.script_format_monologue": "studio-microphone",
    "master.feature.script_format_dialogue": "speech-balloon",
    "master.input.extra_requirements": "speech-balloon",
    "master.input.idea_mode": "light-bulb",
    "clone.creative_autosave": "busts-in-silhouette",
    "master.input.script_mode": "memo",
    "master.queue.add_to_queue": "plus",
    "master.queue.clear_all": "cross-mark",
    "master.queue.delete_row": "cross-mark",
    "master.queue.details": "magnifying-glass",
    "master.queue.open_clip": "video-camera",
    "master.queue.open_folder": "open-folder",
    "master.queue.open_folder_selected": "open-folder",
    "master.queue.open_scene_clip": "video-camera",
    "master.queue.review": "magnifying-glass",
    "master.queue.start_processing": "fast-forward-button",
    "master.queue.stop_delete": "stop-sign",
    "media_library.import": "framed-picture",
    "prompt_card.delete": "cross-mark",
    "prompt_card.edit": "pencil",
    "prompt_card.extend": "clockwise-arrows",
    "prompt_card.insert_after_requested": "plus",
    "prompt_card.generate_extend": "magic-wand",
    "prompt_card.media": "framed-picture",
    "prompt_card.remove_timeline": "cross-mark",
    "prompt_card.submit": "fast-forward-button",
    "status.dispatcher": "chart-increasing",
    "status.errors": "red-triangle",
    "status.log": "memo",
    "status.monitor": "clipboard",
    "status.server_queue": "computer-disk",
    "status.tokens": "money-bag",
    "token_monitor.clear": "cross-mark",
    "token_monitor.close": "cross-mark",
    "token_monitor.export": "outbox-tray",
    "token_monitor.refresh": "clockwise-arrows",
    "voice.config.reset": "counterclockwise-arrows-button",
    "voice.config.save": "floppy-disk",
    "voice.output.pick_folder": "voice-output",
    "voice.queue.add": "plus",
    "voice.queue.run": "fast-forward-button",
    "voice.preview": "loudspeaker",
    "style_manager.add": "plus",
    "style_manager.edit": "pencil",
    "style_manager.delete": "cross-mark",
    "style_manager.favorite": "light-bulb",
    "style_manager.unfavorite": "light-bulb",
    "style_manager.preview": "artist-palette",
    "style_manager.mix": "magic-wand",
    "style_manager.bulk_missing": "artist-palette",
    "style_manager.bulk_all": "clockwise-arrows",
    "style_manager.draw_enabled": "pencil",
    "style_manager.clear": "cross-mark",
    "style_manager.cancel": "cross-mark",
    "style_manager.apply": "check-mark-button",
    "framework_mix.rebuild": "clockwise-arrows",
    "framework_mix.preview": "artist-palette",
    "framework_mix.save": "floppy-disk",
    "framework_mix.close": "cross-mark",
    "work_panel.add_blank": "plus",
    "work_panel.add_from_text": "memo",
    "work_panel.affiliate_background": "framed-picture",
    "work_panel.affiliate_back_to_input": "counterclockwise-arrows-button",
    "work_panel.affiliate_cancel_generate": "cross-mark",
    "work_panel.affiliate_character": "busts-in-silhouette",
    "work_panel.affiliate_generate_script": "magic-wand",
    "work_panel.affiliate_product_edit": "memo",
    "work_panel.affiliate_select_all": "check-box-with-check",
    "work_panel.affiliate_start": "fast-forward-button",
    "work_panel.affiliate_template": "memo",
    "work_panel.affiliate_voice": "studio-microphone",
    "work_panel.batch_actions": "check-box-with-check",
    "work_panel.batch_config": "gear",
    "work_panel.batch_open_folder": "open-folder",
    "work_panel.batch_reference_images": "framed-picture",
    "work_panel.bulk_import": "inbox-tray",
    "work_panel.clear_cards": "cross-mark",
    "work_panel.clear_queue": "cross-mark",
    "work_panel.clone_analyze_scenes": "magic-wand",
    "work_panel.clone_apply_style": "artist-palette",
    "work_panel.clone_batch_config": "gear",
    "work_panel.clone_video_files": "video-camera",
    "work_panel.clone_video_folder": "open-folder",
    "work_panel.clone_view_uploaded": "outbox-tray",
    "work_panel.clone_frame_slicing": "paperclip",
    "work_panel.clone_char_consistency": "busts-in-silhouette",
    "work_panel.clone_auto_extend": "clockwise-arrows",
    "work_panel.clone_auto_merge": "package",
    "work_panel.clone_content_mode": "globe-with-meridians",
    "work_panel.clone_subtitle_studio": "memo",
    "work_panel.clone_voice_lock": "locked-with-key",
    "work_panel.clone_creative_original": "movie-camera",
    "work_panel.clone_creative_remix": "magic-wand",
    "work_panel.clone_creative_create": "artist-palette",
    "work_panel.clone_creative_series": "next-track-button",
    "work_panel.clone_draw_settings": "pencil",
    "work_panel.clone_skip": "next-track-button",
    "work_panel.clone_stop": "stop-sign",
    "work_panel.clone_start": "fast-forward-button",
    "work_panel.clone_login_platform": "key",
    "work_panel.clone_pipeline": "hammer-and-wrench",
    "work_panel.transcript_char_consistency": "busts-in-silhouette",
    "work_panel.transcript_instruction": "speech-balloon",
    "work_panel.transcript_auto_merge": "package",
    "work_panel.transcript_content_mode": "globe-with-meridians",
    "work_panel.transcript_subtitle_studio": "memo",
    "work_panel.transcript_auto_next": "fast-forward-button",
    "work_panel.transcript_auto_extend": "clockwise-arrows",
    "work_panel.transcript_deep_analysis": "magnifying-glass",
    "work_panel.transcript_draw_settings": "pencil",
    "work_panel.transcript_skip": "next-track-button",
    "work_panel.transcript_voice_lock": "locked-with-key",
    "work_panel.normal_auto_merge_toggle": "package",
    "work_panel.affiliate_auto_merge_toggle": "package",
    "work_panel.affiliate_voice_preview": "studio-microphone",
    "work_panel.affiliate_voice": "studio-microphone",
    "work_panel.affiliate_template": "memo",
    "work_panel.extend_bulk_import": "inbox-tray",
    "work_panel.extend_bulk_preview": "magnifying-glass",
    "work_panel.extend_delete_session": "red-triangle",
    "work_panel.extend_generate_timeline": "spiral-calendar",
    "work_panel.extend_import_session": "inbox-tray",
    "work_panel.extend_preview": "magnifying-glass",
    "work_panel.extend_queue_view": "clipboard",
    "work_panel.extend_render_video": "video-camera",
    "work_panel.extend_auto_merge_toggle": "package",
    "work_panel.extend_rules": "gear",
    "work_panel.history": "spiral-calendar",
    "work_panel.import_from_batch_image": "artist-palette",
    "work_panel.mode_toggle": "gear",
    "work_panel.pause_queue": "pause-button",
    "work_panel.product_library": "package",
    "work_panel.queue_delete_row": "cross-mark",
    "work_panel.queue_open_clip": "video-camera",
    "work_panel.queue_open_output": "open-folder",
    "work_panel.route_characters": "busts-in-silhouette",
    "work_panel.select_all_cards": "check-box-with-check",
    "work_panel.start_queue": "fast-forward-button",
    "work_panel.submit_all": "fast-forward-button",
    "work_panel.transcript_audio_files": "studio-microphone",
    "work_panel.transcript_audio_folder": "open-folder",
    "work_panel.unselect_all_cards": "cross-mark-button"
}

// Tooltip text ported 1-1 from PyQt6 legacy (veoflowclient setToolTip calls).
// Keyed by actionId. Vietnamese preserved verbatim. \n = newline.
// Đồng bộ với TourData (20/7): tooltip = giải nghĩa "trọn bộ" — tác dụng, đi với
// tính năng nào, đổi thì sao. Key dùng chung nhiều tab (add_blank, bulk_import,
// submit_all, clear_cards) viết TRUNG HOÀ, không tả riêng 1 tab.
var ACTION_TOOLTIPS = {
    // Master feature toggles
    "master.feature.auto_mode": "AI tạo kịch bản và tự động gửi tạo video ngay (không cần review)",
    "master.feature.manual_mode": "AI tạo kịch bản, bạn review/chỉnh sửa trước khi gửi tạo video",
    "master.feature.character_consistency": "Công tắc TỔNG khối nhất quán — bật là hiện bảng Điều khiển nhân vật · đồ vật · bối cảnh (đi cùng Media Library).\nSong song AI + Thư viện: asset chọn thay vai trò tương ứng, AI tạo phần còn thiếu.\nChỉ dùng Thư viện: chỉ dùng asset đã chọn.\nTắt = mỗi cảnh AI tự hình dung — gương mặt, đồ vật có thể đổi giữa các cảnh.",
    "master.feature.voice_lock": "Gắn giọng CỐ ĐỊNH cho từng nhân vật (Omni/Abra) — nhân vật nói đúng 1 giọng qua mọi cảnh; giọng lấy từ mục Voice trong Media Library. Cần bật Điều khiển nhân vật để có nhân vật gắn giọng.\nTắt = giọng chỉ mô tả bằng chữ, mỗi cảnh có thể nghe khác nhau.",
    "master.feature.auto_merge_video": "Tất cả cảnh render xong tự nối thành 1 video hoàn chỉnh — không cần ghép tay.\nTắt nếu muốn tự dựng/edit: các cảnh rời vẫn nằm đủ trong thư mục lưu.",
    "master.queue.auto_clear_completed": "Bật: tự xóa các job đã hoàn thành trong hàng chờ, luôn giữ job xong cuối cùng để còn bấm mở thư mục. Tắt: mọi job xong vẫn nằm trong queue. Chỉ chạy 1 job thì job đó ở lại. File trên đĩa không bị xóa.",
    "master.feature.auto_extend": "Cho phép AI quyết định thời lượng cảnh (8s, 16s, 24s...). Cảnh dài tự động chain với Veo3 extend.",
    "master.feature.deep_analysis": "Bật Gemini Thinking để AI suy luận sâu hơn về nội dung. Phù hợp cho chủ đề phức tạp (y tế, tài chính, khoa học...). Tốn thêm chi phí thinking tokens.",
    "master.feature.thinking": "Bật Gemini Thinking để AI suy luận sâu hơn. Tốn thêm chi phí thinking tokens.",
    "master.feature.char_mode_full_ai": "AI tự phát hiện & tự tạo mọi nhân vật/đồ vật/bối cảnh — nhanh nhất, không cần chuẩn bị.\nTrong 1 video vẫn nhất quán; muốn video SAU dùng lại đúng nhân vật: bật Tự động lưu rồi lần sau chuyển chế độ Song song.",
    "master.feature.char_mode_hybrid": "Song song AI + Thư viện: bạn gắn asset cho vai muốn cố định (nhân vật thương hiệu, sản phẩm...), AI tạo phần còn thiếu và viết lại kịch bản cho khớp. Bật sẽ hiện 3 cột điều khiển riêng.",
    "master.feature.char_mode_manual": "Chỉ dùng Thư viện: thay nhân vật/đồ vật/bối cảnh tương ứng bằng asset đã chọn; bỏ phần không có asset.",
    "master.feature.clear_characters": "Bỏ hết asset đã gán ở cả 3 cột Nhân vật · Đồ vật · Bối cảnh.",
    "library_control.open_media_library": "Mở nhanh Media Library để import / quản lý ảnh nhân vật · đồ vật · bối cảnh rồi gắn vào các cột điều khiển.",
    "clone.creative_autosave": "Nhân vật nào AI tạo ra đều tự lưu vào Media Library. Đi cặp với chế độ Song song: video sau gắn lại đúng nhân vật đó — nuôi nhân vật thương hiệu / series không phải tạo lại từ đầu.",
    // Master config bar
    "master.config.folder_picker": "Nơi lưu video xuất ra trên máy. Các nút \"Mở thư mục\" ở hàng chờ / Bảng Job sẽ mở đúng chỗ này.",
    "master.config.style_manager": "Gắn phong cách (góc máy + chất liệu hình ảnh) áp THỐNG NHẤT cho mọi cảnh — thứ quyết định \"chất phim\". Đổi style chỉ ảnh hưởng video thêm sau. Tab Clone không chọn = tự theo style video gốc.",
    // Master input & queue
    "master.input.idea_mode": "Chỉ cần gõ ý tưởng (mỗi dòng = 1 video). AI tự viết kịch bản đầy đủ từ ý tưởng đó.",
    "master.input.script_mode": "Dán sẵn kịch bản hoàn chỉnh của bạn. AI giữ nguyên nội dung, chỉ phân cảnh và dựng video theo kịch bản.",
    "master.input.narrator": "Bật khi video có giọng KỂ CHUYỆN xuyên suốt (voice-over, không phải thoại nhân vật): AI tách lời dẫn riêng và giữ đúng 1 giọng kể đồng nhất qua mọi cảnh.",
    "master.input.extra_requirements": "Thêm ràng buộc riêng: ghi chú nhân vật, phong cách, điều cấm (negative)... áp cho toàn bộ video sắp tạo.",
    "master.dialog.narrator_template": "Mẫu kịch bản có lời dẫn đúng format (hiện ở chế độ Kịch bản khi đã bật Người dẫn truyện) — viết theo mẫu để AI nhận diện lời dẫn chính xác.",
    "master.dialog.bulk_import": "Dán nhiều ý tưởng (Idea) hoặc kịch bản (Script) cùng lúc — mỗi dòng/khối = 1 video. Tự tách khối thông minh, hoặc nạp từ file TXT / bảng tính (Excel/CSV, chọn cột + dải dòng). Xem trước & sửa rồi mới thêm vào hàng chờ.",
    "master.dialog.script_guide": "Cách viết 1 cảnh: nguyên liệu (@CHAR/@OBJ/@SETTING), tên thật (máy gán CHAR_000…), ≤3 NV/cảnh, limit ref Veo~3 / Omni~7.",
    "master.queue.add_to_queue": "Đóng gói nội dung + toàn bộ cấu hình đang chọn thành các dòng hàng chờ (mỗi dòng = 1 video). CHƯA render — thêm nhiều đợt với cấu hình khác nhau rồi Bắt đầu xử lý chạy hết một lần.",
    "master.queue.start_processing": "Chạy toàn bộ hàng chờ: AI viết kịch bản → tạo cảnh → render video. Theo dõi tiến độ ở Bảng Job bên phải.",
    "master.queue.stop_delete": "Dừng khẩn cấp: huỷ việc đang chạy và gỡ các dòng CHƯA CHẠY / LỖI khỏi hàng chờ. Dòng đã hoàn thành giữ nguyên.",
    "master.queue.clear_all": "Xóa toàn bộ dòng trong hàng chờ — bảng về trống. File video đã render trên máy KHÔNG bị xoá.",
    "master.queue.preview": "Xem nhanh cảnh/kịch bản đã dựng của dòng này trước khi render.",
    "master.queue.open_folder": "Mở thư mục chứa video/ảnh đã render của dòng này.",
    "master.queue.delete_row": "Bỏ video này khỏi hàng chờ (không ảnh hưởng các dòng khác).",
    "master.queue.review": "Review & chỉnh sửa kịch bản",
    "master.queue.details": "Xem chi tiết job: metadata, scenes, config",
    // Clone feature toggles
    "work_panel.clone_frame_slicing": "Download video, cắt thành các đoạn 8s, ghép cặp và tạo video interpolate",
    "work_panel.clone_char_consistency": "Công tắc TỔNG khối nhất quán — hợp mode Đổi vỏ / Tập tiếp theo: gắn đúng nhân vật CỦA BẠN thay cho nhân vật video gốc.\nSong song AI + Thư viện: asset chọn thay vai trò tương ứng, AI tạo phần còn thiếu.\nChỉ dùng Thư viện: chỉ dùng asset đã chọn.",
    "work_panel.clone_voice_lock": "Nhân vật clone nói đúng 1 giọng cố định qua mọi cảnh (Omni/Abra — giọng đã tạo/lưu trong thư viện). Cần bật Điều khiển nhân vật để có nhân vật gắn giọng.\nTắt = giọng mô tả bằng chữ, có thể lệch giữa các cảnh.",
    "work_panel.clone_auto_merge_toggle": "Nối các cảnh clone thành 1 video hoàn chỉnh sau khi xong. Tắt = giữ các clip rời trong thư mục lưu.",
    "work_panel.clone_auto_extend": "Cho phép AI quyết định thời lượng cảnh (8s, 16s, 24s...). Cảnh dài tự động chain với Veo3 extend.",
    "work_panel.clone_creative_original": "Copy gốc — tái tạo 1:1: giữ nguyên câu chuyện, lời thoại, hình ảnh của video gốc.",
    "work_panel.clone_creative_remix": "Giữ chuyện, đổi vỏ: cốt truyện & lời thoại y nguyên — chỉ thay nhân vật / bối cảnh / style hình / sản phẩm.\n\nVí dụ:\n• Đổi nhân vật thành mèo hoạt hình\n• Chuyển bối cảnh thành không gian vũ trụ\n• Phong cách anime Nhật Bản\n• Thời trung cổ, nhân vật thành hiệp sĩ",
    "work_panel.clone_creative_create": "Giữ công thức, chuyện mới: AI học hook + cấu trúc + nhịp viral của video gốc rồi viết nội dung hoàn toàn mới theo chủ đề bạn điền.\n\nNhân vật, bối cảnh, câu chuyện đều mới — chỉ giữ công thức thành công.",
    "work_panel.clone_creative_series": "Tập tiếp theo (series): giữ NGUYÊN dàn nhân vật & thế giới của video gốc — AI viết tập mới với tình huống mới. Hợp kênh nuôi nhân vật dài tập.",
    "work_panel.clone_video_files": "Thêm video local vào cùng danh sách nguồn với link — KHÔNG cần upload trước, job tự upload khi chạy.",
    "work_panel.clone_video_folder": "Quét cả thư mục video một lần — mọi file vào chung danh sách nguồn với link.",
    "work_panel.clone_select_all": "Tick video (link lẫn file) rồi thêm vào danh sách công việc. Nút \"Config Override\" trên từng dòng ghi đè cấu hình RIÊNG cho dòng đó — banner phía trên báo đang chỉnh cho link nào.",
    "work_panel.start_queue": "Chạy hàng chờ: tải/upload video → phân tích → xử lý theo chế độ đã chọn.",
    "work_panel.clone_stop": "Dừng queue",
    "work_panel.clone_skip": "Bỏ qua job hiện tại",
    "work_panel.clone_start": "Bắt đầu clone video",
    "work_panel.clone_login_platform": "Đăng nhập bằng cookie để tải được video riêng tư / giới hạn khu vực.",
    "work_panel.clone_apply_style": "Áp dụng style cho tất cả jobs",
    // Transcript feature toggles
    "work_panel.transcript_audio_files": "Chọn các file audio (lời thoại/giọng đọc) để chuyển thành video. Mỗi hàng file có nút \"Kịch bản\" riêng để hướng AI cách hiểu & phân cảnh lời thoại file đó.",
    "work_panel.transcript_audio_folder": "Nạp cả một thư mục audio cùng lúc thay vì chọn từng file.",
    "work_panel.transcript_char_consistency": "Công tắc TỔNG khối nhất quán: người kể / nhân vật minh hoạ giữ đúng 1 gương mặt qua mọi cảnh của lời thoại.\nSong song AI + Thư viện: asset chọn thay vai trò tương ứng, AI tạo phần còn thiếu.\nChỉ dùng Thư viện: chỉ dùng asset đã chọn.",
    "work_panel.transcript_instruction": "Thêm mô tả ý tưởng cho từng file audio:\n• Chọn file → bấm nút hoặc double-click cột Mô tả\n• VD: MV anime, hoạt hình thiếu nhi, phim tài liệu...",
    "work_panel.transcript_auto_merge": "Các cảnh minh hoạ render xong tự nối thành 1 video hoàn chỉnh khớp đúng audio gốc. Tắt nếu muốn tự dựng tay.",
    "work_panel.transcript_auto_next": "Xong job này tự chạy tiếp job sau trong hàng chờ — nạp cả loạt file audio rồi để máy chạy hết, không phải bấm từng cái.",
    "work_panel.transcript_auto_extend": "Cho phép AI quyết định thời lượng cảnh (8s, 16s, 24s...). Cảnh dài tự động chain với Veo3 extend.",
    "work_panel.transcript_deep_analysis": "Bật Gemini Thinking: AI suy luận sâu hơn khi phân tích lời thoại — hợp chủ đề phức tạp. Đổi lại tốn thêm chi phí thinking tokens; nội dung đơn giản cứ tắt cho nhanh & rẻ.",
    // Work panel shared (Normal / Extend / Batch — key dùng chung, mô tả trung hoà)
    "work_panel.add_blank": "Thêm 1 thẻ trống vào danh sách. Normal: số ô ảnh theo chế độ đang chọn. Extend: thẻ đầu là video gốc (ROOT), thẻ sau là đoạn nối tiếp.",
    "work_panel.bulk_import": "Nhập nhiều prompt cùng lúc — nạp từ TXT / bảng tính, nhiều kiểu ghép ảnh–prompt (kể cả ghép theo tên file). Xem trước & sửa từng mục rồi mới thêm.",
    "work_panel.import_from_batch_image": "Lấy ảnh đã gen xong trên tab Tạo Hình Ảnh (kèm prompt) thành thẻ AUTO FLOW — Ảnh: 1 ảnh/thẻ, 2 Ảnh: ghép cặp, Thành phần: gom theo số slot model.",
    "work_panel.select_all_cards": "Chọn nhanh mọi thẻ để gửi/xoá hàng loạt. Cạnh đó có Bỏ chọn, Xoá tất cả và bộ đếm đang-chọn / tổng.",
    "work_panel.submit_all": "Đưa các thẻ đang chọn vào hàng chờ xử lý. Nút hiện số thẻ đang chọn.",
    "work_panel.clear_cards": "Xoá TOÀN BỘ thẻ trong lô — bảng về trống. File đã render trên máy không bị xoá.",
    "work_panel.normal_voice_lock_toggle": "Khoá giọng nhân vật xuyên suốt các cảnh (cần model R2V Omni/Abra). Chỉ hiện ở chế độ 3 Thành phần.",
    "work_panel.normal_auto_merge_toggle": "Sau khi mọi thẻ render xong, tự nối thành 1 video hoàn chỉnh.",
    // Extend
    "work_panel.extend_rules": "Quy tắc chung khi AI viết đoạn tiếp: giữ bối cảnh, nhịp, hành động thế nào... Áp cho MỌI thẻ extend của phiên — chỉnh 1 lần thay vì dặn từng thẻ.",
    "work_panel.extend_bulk_import": "Dán danh sách prompt, mỗi mục thành 1 thẻ nối/gia hạn video.",
    "work_panel.extend_generate_timeline": "AI tự đề xuất timeline các đoạn nối từ video gốc — kết quả mở trong hộp xem trước, sửa từng mục rồi mới nhận vào chuỗi thẻ.",
    "work_panel.extend_preview": "Xem nhanh timeline phiên nối hiện tại — kiểm tra mạch chuyện trước khi tốn credit render.",
    "work_panel.extend_auto_merge_toggle": "Các đoạn render xong tự nối thành 1 video dài liền mạch. Tắt nếu muốn tự dựng tay.",
    "work_panel.extend_render_video": "Xuất video hoàn chỉnh từ chuỗi gốc + các đoạn đã nối/gia hạn.",
    // Batch image
    "work_panel.batch_add_prompt": "Thêm một prompt (mô tả ảnh) mới vào lô tạo ảnh.",
    "work_panel.batch_import_images": "Nạp ảnh tham chiếu để AI bám theo khi tạo ảnh mới.",
    "work_panel.batch_save_to_library_toggle": "Tự lưu ảnh tạo ra vào Media Library để dùng lại về sau (gắn làm nhân vật · đồ vật · bối cảnh)."
}

var ACTION_TEXT_RULES = [
    ["bỏ chọn", "cross-mark"],
    ["xóa", "cross-mark"],
    ["xoá", "cross-mark"],
    ["hủy", "cross-mark"],
    ["huỷ", "cross-mark"],
    ["đóng", "cross-mark"],
    ["lưu", "floppy-disk"],
    ["sao chép", "clipboard"],
    ["copy", "clipboard"],
    ["làm mới", "clockwise-arrows"],
    ["gia hạn", "clockwise-arrows"],
    ["thử lại", "counterclockwise-arrows-button"],
    ["bắt đầu", "fast-forward-button"],
    ["xử lý", "fast-forward-button"],
    ["chạy", "fast-forward-button"],
    ["tạm dừng", "pause-button"],
    ["dừng", "stop-sign"],
    ["tạo", "magic-wand"],
    ["ai tạo", "magic-wand"],
    ["nhập", "inbox-tray"],
    ["import", "inbox-tray"],
    ["tải lên", "outbox-tray"],
    ["xuất", "outbox-tray"],
    ["tải xuống", "down-arrow"],
    ["thêm", "plus"],
    ["hàng loạt", "plus"],
    ["chọn", "check-box-with-check"],
    ["mở", "open-folder"],
    ["thư mục", "open-folder"],
    ["tìm", "magnifying-glass"],
    ["sửa", "pencil"],
    ["cấu hình", "gear"],
    ["dữ liệu", "computer-disk"],
    ["lịch sử", "spiral-calendar"],
    ["ảnh", "framed-picture"],
    ["video", "video-camera"],
    ["thoại", "studio-microphone"],
    ["âm thanh", "studio-microphone"],
    ["khóa", "key"],
    ["sản phẩm", "package"],
    ["gộp", "hammer-and-wrench"],
    ["tách", "paperclip"],
    ["kịch bản", "memo"],
    ["hướng dẫn", "notebook"],
    ["delete", "cross-mark"],
    ["remove", "cross-mark"],
    ["clear", "cross-mark"],
    ["cancel", "cross-mark"],
    ["close", "cross-mark"],
    ["save", "floppy-disk"],
    ["apply", "check-mark-button"],
    ["confirm", "check-mark-button"],
    ["ok", "check-mark-button"],
    ["preview", "artist-palette"],
    ["favorite", "light-bulb"],
    ["unfavorite", "light-bulb"],
    ["mix", "magic-wand"],
    ["copy", "clipboard"],
    ["refresh", "clockwise-arrows"],
    ["renew", "clockwise-arrows"],
    ["retry", "counterclockwise-arrows-button"],
    ["reset", "counterclockwise-arrows-button"],
    ["start", "fast-forward-button"],
    ["run", "fast-forward-button"],
    ["play", "fast-forward-button"],
    ["submit", "fast-forward-button"],
    ["queue", "clipboard"],
    ["pause", "pause-button"],
    ["stop", "stop-sign"],
    ["generate", "magic-wand"],
    ["ai", "magic-wand"],
    ["import", "inbox-tray"],
    ["upload", "outbox-tray"],
    ["export", "outbox-tray"],
    ["download", "down-arrow"],
    ["add", "plus"],
    ["new", "plus"],
    ["choose", "open-folder"],
    ["select", "check-box-with-check"],
    ["open", "open-folder"],
    ["folder", "open-folder"],
    ["search", "magnifying-glass"],
    ["find", "magnifying-glass"],
    ["settings", "gear"],
    ["config", "gear"],
    ["rules", "gear"],
    ["history", "spiral-calendar"],
    ["media", "framed-picture"],
    ["image", "framed-picture"],
    ["video", "video-camera"],
    ["voice", "studio-microphone"],
    ["audio", "studio-microphone"],
    ["license", "locked-with-key"],
    ["key", "key"],
    ["product", "package"],
    ["link", "link"],
    ["script", "memo"],
    ["review", "magnifying-glass"]
]

var ICON_ALIASES = {
    "activity": "chart-increasing",
    "arrow-left": "chevron-left",
    "audio-lines": "studio-microphone",
    "bot": "robot",
    "book-open": "notebook",
    "check": "check-box-with-check",
    "circle-alert": "light-bulb",
    "circle-x": "cross-mark",
    "copy": "clipboard",
    "database": "computer-disk",
    "download": "down-arrow",
    "eye": "magnifying-glass",
    "file-text": "memo",
    "folder-open": "open-folder",
    "gauge": "money-bag",
    "history": "spiral-calendar",
    "image": "framed-picture",
    "image-plus": "framed-picture",
    "images": "framed-picture",
    "key-round": "key",
    "layers": "notebook",
    "link": "link",
    "list-check": "check-box-with-check",
    "mic": "studio-microphone",
    "monitor": "clipboard",
    "pause": "pause-button",
    "pencil": "pencil",
    "play": "fast-forward-button",
    "plus": "plus",
    "refresh-cw": "clockwise-arrows",
    "rotate-ccw": "counterclockwise-arrows-button",
    "save": "floppy-disk",
    "search": "magnifying-glass",
    "send": "fast-forward-button",
    "settings": "gear",
    "shield-check": "locked-with-key",
    "shopping-bag": "shopping-bags",
    "speaker-high-volume": "loudspeaker",
    "sparkles": "magic-wand",
    "square": "stop-sign",
    "timer": "alarm-clock",
    "trash-2": "cross-mark",
    "triangle-alert": "red-triangle",
    "upload": "inbox-tray",
    "user-round": "busts-in-silhouette",
    "users-round": "busts-in-silhouette",
    "video": "video-camera",
    "wand-sparkles": "magic-wand",
    "x": "cross-mark",
    "zap": "light-bulb"
}

var EMOJI_ICONS = {
    "⚠": "red-triangle",
    "🚀": "rocket",
    "❌": "cross-mark",
    "✕": "cross-mark",
    "✗": "cross-mark",
    "✘": "cross-mark",
    "✖": "cross-mark",
    "✅": "check-mark-button",
    "✓": "check-mark-button",
    "✔": "check-mark-button",
    "☑": "check-box-with-check",
    "☐": "empty-box",
    "💾": "floppy-disk",
    "📋": "clipboard",
    "✍": "pencil",
    "🎙": "studio-microphone",
    "📖": "notebook",
    "📝": "memo",
    "🎭": "drama",
    "🔧": "hammer-and-wrench",
    "🌐": "globe-with-meridians",
    "💳": "credit-card",
    "🚫": "stop-sign",
    "🎨": "artist-palette",
    "✂": "scissors",
    "🧑": "busts-in-silhouette",
    "👤": "busts-in-silhouette",
    "👥": "busts-in-silhouette",
    "🖼": "framed-picture",
    "🔀": "shuffle",
    "🧩": "puzzle-piece",
    "⭐": "star",
    "★": "star",
    "🌟": "star",
    "💡": "light-bulb",
    "📁": "open-folder",
    "📂": "open-folder",
    "🎬": "movie-camera",
    "🔑": "key",
    "💰": "money-bag",
    // Bổ sung 22/7 (bug nút trống): glyph các nút hành động affiliate/job-card.
    "▶": "fast-forward-button",
    "⏸": "pause-button",
    "↻": "clockwise-arrows",
    "🗑": "cross-mark",
    "⬇": "down-arrow",
    "🛍": "shopping-bags",
    "⚡": "light-bulb",
    "📄": "memo",
    "🔗": "link",
    "📚": "notebook",
    "🏞": "framed-picture"
}

var GLYPH_CLASS = "([\\uD800-\\uDBFF][\\uDC00-\\uDFFF]|[\\u2190-\\u2BFF\\u2300-\\u23FF])\\uFE0F?"

function leadingGlyph(text) {
    var match = String(text || "").match(new RegExp("^\\s*" + GLYPH_CLASS))
    return match ? match[1] : ""
}

// Returns the SVG icon name for a leading emoji glyph in `text`, or "".
function iconForGlyph(text) {
    var glyph = leadingGlyph(text)
    if (!glyph.length)
        return ""
    return EMOJI_ICONS[glyph] || ""
}

// Removes a single leading emoji glyph (and following spaces) from `text`.
function stripGlyph(text) {
    return String(text || "").replace(new RegExp("^\\s*" + GLYPH_CLASS + "\\s*"), "").trim()
}

// Semantic tint per icon. Empty/absent => caller's default (neutral text).
var ICON_COLORS = {
    // destructive / stop -> red
    "cross-mark": "#EF4444",
    "cross-mark-button": "#EF4444",
    "stop-sign": "#EF4444",
    "red-triangle": "#EF4444",
    "scissors": "#EF4444",
    "pause-button": "#EF4444",
    // add / confirm / positive -> green
    "plus": "#10B981",
    "check-mark-button": "#10B981",
    "check-box-with-check": "#10B981",
    // navigate / cycle / transfer -> blue
    "clockwise-arrows": "#3B82F6",
    "counterclockwise-arrows-button": "#3B82F6",
    "fast-forward-button": "#3B82F6",
    "next-track-button": "#3B82F6",
    "shuffle": "#3B82F6",
    "link": "#3B82F6",
    "down-arrow": "#3B82F6",
    "inbox-tray": "#3B82F6",
    "outbox-tray": "#3B82F6",
    "magnifying-glass": "#3B82F6",
    "globe-with-meridians": "#3B82F6",
    "globe-americas": "#3B82F6",
    "busts-in-silhouette": "#3B82F6",
    // AI / smart / creative -> violet
    "magic-wand": "#7C3AED",
    "robot": "#7C3AED",
    "brain": "#7C3AED",
    "light-bulb": "#7C3AED",
    "drama": "#7C3AED",
    "puzzle-piece": "#7C3AED",
    "rocket": "#7C3AED",
    // media / visual -> amber
    "framed-picture": "#D97706",
    "movie-camera": "#D97706",
    "video-camera": "#D97706",
    "artist-palette": "#D97706",
    "star": "#D97706",
    "wrapped-gift": "#D97706",
    "spiral-calendar": "#D97706",
    "alarm-clock": "#D97706",
    "package": "#D97706",
    "open-folder": "#D97706",
    "file-folder": "#D97706",
    // audio / voice -> cyan
    "studio-microphone": "#0891B2",
    "microphone": "#0891B2",
    "music": "#0891B2",
    "loudspeaker": "#0891B2",
    "speech-balloon": "#0891B2",
    "muted-speaker": "#0891B2",
    "voice-config": "#7C3AED",
    "voice-content": "#3B82F6",
    "voice-output": "#3B82F6",
    "voice-provider-gemini": "#3B82F6",
    "voice-provider-omni": "#7C3AED",
    "voice-provider-moss": "#0D9488",
    "voice-provider-vieneu": "#10B981",
    "voice-queue": "#7C3AED",
    // security / commerce -> amber/green
    "locked-with-key": "#D97706",
    "key": "#D97706",
    "money-bag": "#10B981",
    "credit-card": "#10B981",
    "shopping-bags": "#10B981",
    "chart-increasing": "#10B981",
    "bar-chart": "#10B981",
    // theme toggle
    "crescent-moon": "#6366F1",
    "sun": "#F59E0B"
}

// Returns the semantic tint for an icon name, or "" when the icon is neutral
// (utility glyphs like gear/memo/pencil keep the caller's default color).
function iconColor(name) {
    var key = normalizeIconName(name)
    if (!key.length)
        return ""
    return ICON_COLORS[key] || ""
}

function normalizeIconName(value) {
    var name = String(value || "").trim()
    if (!name.length)
        return ""
    if (!/^[a-z0-9][a-z0-9-]*$/.test(name))
        return ""
    if (ICON_ALIASES[name])
        return ICON_ALIASES[name]
    return name
}

function actionIconForId(actionId) {
    var key = String(actionId || "").trim()
    if (!key.length)
        return ""
    if (ACTION_ICONS[key])
        return ACTION_ICONS[key]
    return actionIconForText(key)
}

function actionIconForText(text) {
    var lower = String(text || "").toLowerCase()
    if (!lower.length)
        return ""
    for (var i = 0; i < ACTION_TEXT_RULES.length; i++) {
        if (lower.indexOf(ACTION_TEXT_RULES[i][0]) >= 0)
            return ACTION_TEXT_RULES[i][1]
    }
    return ""
}

function featureIconForId(featureId) {
    var key = String(featureId || "").trim()
    if (!key.length)
        return ""
    if (FEATURE_ICONS[key])
        return FEATURE_ICONS[key]

    var lower = key.toLowerCase()
    if (lower.indexOf("license") >= 0)
        return "locked-with-key"
    if (lower.indexOf("token") >= 0 || lower.indexOf("credit") >= 0)
        return "money-bag"
    if (lower.indexOf("account") >= 0 || lower.indexOf("character") >= 0)
        return "busts-in-silhouette"
    if (lower.indexOf("video") >= 0 || lower.indexOf("render") >= 0)
        return "video-camera"
    if (lower.indexOf("voice") >= 0 || lower.indexOf("audio") >= 0)
        return "studio-microphone"
    if (lower.indexOf("batch") >= 0 || lower.indexOf("image") >= 0)
        return "artist-palette"
    if (lower.indexOf("research") >= 0 || lower.indexOf("search") >= 0)
        return "magnifying-glass"
    if (lower.indexOf("setting") >= 0 || lower.indexOf("config") >= 0)
        return "gear"
    if (lower.indexOf("history") >= 0)
        return "spiral-calendar"
    if (lower.indexOf("affiliate") >= 0 || lower.indexOf("product") >= 0)
        return "shopping-bags"
    return ""
}

function featureIconForRoute(route) {
    var key = String(route || "").trim()
    if (!key.length)
        return ""
    return ROUTE_ICONS[key] || ""
}

function resolveFeatureIcon(featureId, route, explicitName) {
    var explicit = normalizeIconName(explicitName)
    if (explicit.length)
        return explicit
    var byId = featureIconForId(featureId)
    if (byId.length)
        return byId
    return featureIconForRoute(route)
}

function resolveActionIcon(actionId, text, explicitName) {
    var explicit = normalizeIconName(explicitName)
    if (explicit.length)
        return explicit
    var byId = actionIconForId(actionId)
    if (byId.length)
        return byId
    var byText = actionIconForText(text)
    if (byText.length)
        return byText
    // Nút glyph-only ("✕", "📁", "▶"…): stripGlyph đã xoá chữ — không map glyph →
    // icon thì nút TRỐNG TRƠN (bug 22/7). Glyph lạ chưa có trong EMOJI_ICONS sẽ
    // vẫn trống → thêm vào EMOJI_ICONS chứ đừng bỏ text glyph trần.
    return iconForGlyph(text)
}

function resolveActionTooltip(actionId, explicitTooltip, fallbackText) {
    var explicit = String(explicitTooltip || "").trim()
    if (explicit.length)
        return explicit
    var key = String(actionId || "").trim()
    if (key.length && ACTION_TOOLTIPS[key])
        return ACTION_TOOLTIPS[key]
    return String(fallbackText || "")
}
