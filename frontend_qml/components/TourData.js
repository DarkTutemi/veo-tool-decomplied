.pragma library

// Guided-tour step catalog.
//
// Each step = { actionId | objectName, title, body?, shared?, dialog? }.
//   - actionId : stable id on a feature button (VfChip/VfButton). Resolved by
//                walking the visual tree → no objectName wiring needed.
//   - objectName : a whole region/panel (baked into the shared component's root).
//   - title    : short callout heading.
//   - body     : long text. Omitted → falls back to the verbatim tooltip in
//                AppIconRegistry.ACTION_TOOLTIPS (single source of truth).
//   - shared   : a common/general intro (header, config panel, job panel, status
//                bar, library control). Shown ONCE across tab tours — a demo user
//                exploring tab-by-tab only meets each common thing a single time.
//   - dialog   : a big feature dialog id ("media_library" / "style_manager"). The
//                callout shows a "Mở thử" button that opens it for a hands-on look.
//
// A tab tour = COMMON_INTRO + that tab's SPECIFIC steps + COMMON_OUTRO. The shared
// steps de-dup by their target key, so wherever a common thing FIRST appears it is
// taught, and every later tab skips it. Steps whose target isn't visible right now
// (conditional buttons) are auto-skipped by the overlay, so a tour never dead-ends.

// Character/object/background control — shared panel (CharacterConsistencyPanel)
// embedded in most tabs. Spread (...LIBRARY_CONTROL) into a tab's steps right after
// its consistency toggle. Every entry de-dups by its own key. The current UI is an
// always-visible per-category matrix; "consistency:open" only reveals the panel and
// never changes/persists the user's selected policies.
var LIBRARY_CONTROL = [
    { objectName: "libraryControl", shared: true, pre: "consistency:open",
      title: "Điều khiển nhân vật · đồ vật · bối cảnh",
      body: "Bảng đồng nhất được chia riêng cho Nhân vật, Đồ vật và Bối cảnh. Mỗi nhóm tự chọn một trong 4 nguồn; tour chỉ mở bảng để giới thiệu, không thay đổi lựa chọn hiện tại của bạn." },
    { objectName: "scope_characters", shared: true, pre: "consistency:open",
      title: "Nhân vật — chọn nguồn đồng nhất",
      body: "AI tạo: AI tự dựng nhân vật. AI + Thư viện: ưu tiên asset đã chọn và tạo thêm phần thiếu. Chỉ Thư viện: không tạo nhân vật ngoài asset. Không đồng nhất: bỏ entity và ảnh tham chiếu nhân vật." },
    { actionId: "library_control.voice_sync", shared: true, pre: "consistency:open",
      title: "Đồng bộ giọng nhân vật",
      body: "Giữ đúng giọng cho nhân vật qua các cảnh. Nút chỉ bật được khi nhóm Nhân vật đang đồng nhất và model hiện tại hỗ trợ voice lock." },
    { objectName: "scope_objects", shared: true, pre: "consistency:open",
      title: "Đồ vật — chọn nguồn đồng nhất",
      body: "Chọn riêng cách xử lý đạo cụ hoặc sản phẩm: AI tạo · AI + Thư viện · Chỉ Thư viện · Không đồng nhất. Số đếm cho biết bao nhiêu asset đang được gắn." },
    { objectName: "scope_backgrounds", shared: true, pre: "consistency:open",
      title: "Bối cảnh — chọn nguồn đồng nhất",
      body: "Chọn riêng cách giữ không gian giữa các cảnh: AI tạo · AI + Thư viện · Chỉ Thư viện · Không đồng nhất." },
    { actionId: "library_control.open_media_library", shared: true, pre: "consistency:open",
      title: "Thư viện media",
      body: "Mở nhanh Media Library ngay tại đây để import / quản lý ảnh nhân vật · đồ vật · bối cảnh rồi gắn vào các cột bên dưới." },
    { actionId: "master.feature.clear_characters", shared: true, pre: "consistency:open",
      title: "Xóa asset đã chọn",
      body: "Bỏ các asset thư viện đang gán ở cả 3 nhóm; lựa chọn nguồn AI / Thư viện của từng nhóm vẫn được giữ." },
    { actionId: "clone.creative_autosave", shared: true, pre: "consistency:open",
      title: "Tự động lưu nhân vật",
      body: "Nhân vật do AI tạo sẽ tự lưu vào Media Library để video sau có thể tái sử dụng đúng nhân vật đó — phù hợp nuôi nhân vật thương hiệu hoặc làm series." }
]

var COMMON_INTRO = [
    { objectName: "masterConfigPanel", shared: true,
      title: "Bảng cấu hình",
      body: "Thanh trên cùng: cấu hình CHUNG cho mọi video sắp tạo — các tab đều dùng chung thanh này. Video thêm vào hàng chờ sẽ mang cấu hình đang chọn lúc đó; từng dòng vẫn chỉnh riêng được sau. Ta đi từ TRÁI sang PHẢI." },
    { objectName: "cfgAspect", shared: true, title: "Tỉ lệ khung hình",
      body: "16:9 (ngang·YouTube), 9:16 (dọc·TikTok/Reels), 1:1 (vuông). Chọn theo nền tảng định đăng. Đổi tỉ lệ chỉ áp cho video THÊM SAU — dòng đã trong hàng chờ giữ tỉ lệ lúc thêm (chỉnh riêng ở bảng hàng chờ nếu cần)." },
    { objectName: "cfgQuality", shared: true, title: "Chất lượng",
      body: "Độ phân giải video xuất (720p / 1080p...). Cao hơn = nét hơn nhưng tốn credit và render lâu hơn. Mẹo: để vừa phải cho nhanh — cảnh nào ưng thì nâng nét riêng bằng nút Re-Upscale ở Bảng Job sau khi tạo xong." },
    { objectName: "cfgModel", shared: true, title: "Chọn Model AI",
      body: "Model tạo video (Veo 3, Veo 2...). Model mới chuyển động đẹp và bám mô tả tốt hơn; chi phí credit mỗi cảnh khác nhau theo model. Ảnh hưởng mọi cảnh sắp render của mọi tab." },
    { actionId: "master.config.folder_picker", shared: true, title: "Thư mục lưu",
      body: "Nơi lưu video xuất ra trên máy. Các nút \"Mở thư mục\" ở hàng chờ / Bảng Job sẽ mở đúng chỗ này." },
    { actionId: "master.config.style_manager", shared: true, title: "Chọn Style",
      body: "Gắn phong cách (góc máy + chất liệu hình ảnh) áp THỐNG NHẤT cho mọi cảnh của video — đây là thứ quyết định \"chất phim\". Đổi style chỉ ảnh hưởng video thêm sau. Riêng tab Clone: không chọn = tự theo style video gốc." },
    { objectName: "cfgMarket", shared: true, title: "Thị trường",
      body: "Thị trường mục tiêu (ngôn ngữ · văn hoá): AI viết kịch bản, lời thoại và cách kể hợp khán giả nước đó. Đổi thị trường = đổi cả NGÔN NGỮ nội dung của video thêm sau." },
    { objectName: "cfgClipDuration", shared: true, title: "Độ dài clip",
      body: "Thời lượng MỖI CẢNH model render (8s, 16s...). Cảnh dài hơn mức model hỗ trợ sẽ tự CHAIN nhiều đoạn nối liền mạch — đổi lại tốn credit theo số đoạn. Video ngắn nhịp nhanh: để 8s là đẹp." }
]

// Guided walkthroughs that run INSIDE a feature dialog. The header buttons for
// these pulse in guide-pick mode; clicking one opens the dialog and spotlights
// the controls inside (the overlay is on the dialog layer for these). Launched
// via App.startDialogTour(id); the dialog is closed when the tour ends.
var DIALOG_TOURS = {
    "media_library": [
        { objectName: "mlSearchInput", pre: "filter:all",
          title: "Tìm kiếm asset",
          body: "Gõ để lọc nhanh theo tên hoặc thẻ." },
        { objectName: "mlFilterChips",
          title: "Bộ lọc loại",
          body: "Chuyển nhóm asset: Tất cả · Video · Nhân vật · Voice · Object · Setting · Background · Sản phẩm. Bấm 1 chip để chỉ xem đúng nhóm đó." },
        { objectName: "mlImportImages",
          title: "Nhập ảnh",
          body: "Thêm ảnh từ máy vào thư viện để tái sử dụng làm nhân vật · đồ vật · bối cảnh." },
        { objectName: "mlImportFolder",
          title: "Nhập cả thư mục",
          body: "Nạp hàng loạt: chọn 1 thư mục, mọi ảnh trong đó được đưa vào thư viện." },
        { objectName: "mlDeleteSelected",
          title: "Xoá mục đã chọn",
          body: "Chọn một hoặc nhiều asset rồi bấm để xoá khỏi thư viện." },
        { objectName: "mlGrid",
          title: "Lưới asset",
          body: "Toàn bộ asset đã lưu. Rê chuột lên mỗi thẻ để: Xem trước · Đổi tên · Xoá · Đổi loại asset (dropdown). Bấm để chọn khi ở chế độ chọn." },
        { objectName: "mlVoiceSearch", pre: "filter:voice",
          title: "Mục Voice — tìm giọng",
          body: "Chuyển sang mục Voice để quản lý giọng đọc/TTS. Gõ để tìm giọng đã tạo." },
        { objectName: "mlVoiceCreate",
          title: "Tạo Voice",
          body: "Tạo giọng mới: tên · base voice · mô tả speaker · tông giọng · câu thoại mẫu." },
        { objectName: "mlVoicePreview",
          title: "Nghe thử",
          body: "Phát mẫu giọng đang chọn để kiểm tra." },
        { objectName: "mlVoiceGrid",
          title: "Thư viện voice",
          body: "Danh sách giọng đã tạo — bấm 1 giọng để chọn." },
        { objectName: "mlVoiceCharGrid",
          title: "Nhân vật để bind",
          body: "Danh sách nhân vật — chọn 1 để gán (bind) với giọng đang chọn." },
        { objectName: "mlVoiceBind",
          title: "Bind voice ↔ nhân vật",
          body: "Gắn giọng đang chọn cho nhân vật đang chọn — nhân vật đó sẽ dùng giọng này khi tạo video." },
        { objectName: "mlVoiceUnbind",
          title: "Gỡ bind",
          body: "Bỏ liên kết giọng khỏi nhân vật." }
    ],
    "style_manager": [
        { objectName: "smBucket_style",
          title: "Tab Style Framework",
          body: "Nhóm phong cách hình ảnh dựng sẵn (Realistic, Cinematic, Anime...). Chọn tab này để duyệt và gắn render style." },
        { objectName: "smBucket_topic",
          title: "Tab Chủ đề",
          body: "Cây style theo chủ đề (VD: Phật giáo, Cyberpunk...). Chọn để dùng bộ style đã nhóm sẵn theo chủ đề." },
        { objectName: "smCombo",
          title: "Style kết hợp",
          body: "Bật để gộp nhiều framework (style + chủ đề) thành 1 preview kết hợp — kiểm tra prompt tổng trước khi áp." },
        { objectName: "smSearch",
          title: "Tìm style",
          body: "Gõ tên hoặc id để lọc nhanh danh sách style." },
        { objectName: "smSort",
          title: "Sắp xếp",
          body: "Sắp theo A→Z, Z→A, hoặc Mới dùng gần đây." },
        { objectName: "smFavOnly",
          title: "Chỉ yêu thích",
          body: "Lọc chỉ hiện những style bạn đã đánh dấu yêu thích." },
        { actionId: "style_manager.add",
          title: "Thêm style mới",
          body: "Tạo bộ phong cách riêng: đặt tên + mô tả chất liệu hình ảnh (tông màu/kết cấu). Góc máy do AI tự viết theo từng cảnh." },
        { actionId: "style_manager.edit",
          title: "Sửa style",
          body: "Chỉnh lại mô tả góc máy / chất liệu hình của style đang chọn — video thêm sau sẽ theo bản đã sửa." },
        { actionId: "style_manager.delete",
          title: "Xoá style",
          body: "Xoá style riêng không dùng nữa (style dựng sẵn không xoá được)." },
        { actionId: "style_manager.topic_generate",
          title: "AI gợi ý theo chủ đề",
          body: "Nhập chủ đề (VD: Cyberpunk, Ẩm thực Việt...), AI đề xuất bộ style phù hợp để dùng ngay." },
        { actionId: "style_manager.preview",
          title: "Xem trước",
          body: "Sinh ảnh preview để kiểm tra đúng style/camera trước khi áp dụng." },
        { actionId: "style_manager.bulk_missing",
          title: "Tạo preview còn thiếu",
          body: "Sinh ảnh preview cho những style/camera chưa có ảnh." },
        { actionId: "style_manager.bulk_all",
          title: "Tạo lại tất cả preview",
          body: "Sinh lại toàn bộ ảnh preview khi muốn làm mới." },
        { actionId: "style_manager.clear",
          title: "Bỏ chọn",
          body: "Gỡ style đang gắn — video mới sẽ không ép phong cách (tab Clone khi đó tự theo style video gốc)." },
        { actionId: "style_manager.apply",
          title: "Áp dụng",
          body: "Gắn style đang chọn cho video sắp tạo." }
    ],

    // In-dialog tour for Smart Bulk Import (opened from the "Nhập hàng loạt" button).
    // Steps target the DEFAULT text/Idea mode; controls hidden in that mode auto-skip.
    "bulk_import": [
        { objectName: "bulkImportModeToggle", title: "Chế độ nhập: Ý tưởng / Kịch bản",
          body: "Ý tưởng = mỗi dòng/khối là 1 video, hệ thống tự tách. Kịch bản = dán 1 kịch bản dài, tự phân cảnh. Chọn đúng kiểu nội dung bạn có." },
        { objectName: "bulkImportTextInput", title: "Ô dán nội dung",
          body: "Dán trực tiếp nhiều prompt/ý tưởng vào đây (mỗi dòng 1 mục). Xem trước bên phải cập nhật ngay." },
        { objectName: "bulkImportLoadTxtButton", title: "Nạp từ file TXT / bảng tính",
          body: "Thay vì dán tay: nạp từ file .txt (mỗi dòng 1 prompt) hoặc Excel/CSV (chọn cột + dải dòng). Nhanh cho danh sách dài." },
        { objectName: "bulkImportPreviewList", title: "Xem trước & chỉnh",
          body: "Mỗi mục đã tách hiện 1 dòng, có ô tích để chọn/bỏ. Bấm 1 dòng để chọn rồi dùng các nút bên dưới." },
        { objectName: "bulkImportSelectAllButton", title: "Chọn / bỏ chọn tất cả",
          body: "Chọn hết hoặc bỏ hết để đưa vào (hoặc loại khỏi) danh sách import." },
        { objectName: "bulkImportEditButton", title: "Sửa mục đang chọn",
          body: "Mở trình sửa để chỉnh lại prompt của mục đang chọn trước khi import." },
        { objectName: "bulkImportMergeButton", title: "Gộp / Tách mục",
          body: "Gộp nhiều mục đã chọn thành 1, hoặc dùng Tách để chẻ 1 mục dài thành nhiều cảnh theo câu." },
        { objectName: "bulkImportAcceptButton", title: "Import vào hàng chờ",
          body: "Đưa tất cả mục đang chọn vào danh sách/hàng chờ tạo video. Bấm Hủy nếu muốn bỏ." }
    ],

    // In-dialog tour for Bulk Extend Import (dán list prompt → thẻ nối/gia hạn).
    "bulk_extend": [
        { objectName: "bulkExtendInput", title: "Ô dán prompt",
          body: "Dán nhiều prompt, mỗi dòng 1 cảnh. Dòng đầu = ROOT (cảnh gốc), các dòng sau = EXTEND (nối tiếp) — tự nhận diện." },
        { objectName: "bulkExtendIgnoreEmptyToggle", title: "Bỏ qua dòng trống",
          body: "Bật: dòng trống bị bỏ. Tắt: dòng trống / dấu --- dùng để tách chuỗi (chain) mới." },
        { objectName: "bulkExtendPreview", title: "Xem trước chuỗi",
          body: "Danh sách thẻ đã tách kèm nhãn ROOT/EXTEND và số chuỗi. Bấm 1 thẻ để đổi ROOT ↔ EXTEND." },
        { objectName: "bulkExtendAccept", title: "Import & Chạy / Thêm vào hàng chờ",
          body: "Đưa cả lô thẻ vào phiên extend (chạy ngay hoặc xếp hàng chờ tuỳ chế độ)." }
    ],

    // Bulk Import in IMAGE mode (Normal/Batch) — the tour FORCES the dialog open via
    // openForImageMode("image") so these image-only controls are visible even though
    // the dialog defaults to text mode.
    "bulk_import_image": [
        { objectName: "bulkImportImagePanel", title: "Nhập ảnh hàng loạt",
          body: "Chế độ ghép ảnh: mỗi thẻ = ảnh + prompt. Bảng trên hiện loại ghép, số ảnh đã chọn, và hướng dẫn nhanh." },
        { objectName: "bulkImportSubmode", title: "Kiểu ghép ảnh ↔ prompt",
          body: "Chọn cách khớp: N ảnh + N prompt (mỗi ảnh 1 prompt), N ảnh + 1 prompt (dùng chung), hoặc 1 ảnh + N prompt. Ở chế độ 2 ảnh/đa thành phần là ghép cặp/bộ." },
        { objectName: "bulkImportImageList", title: "Danh sách ảnh",
          body: "Thêm ảnh từ máy hoặc thư viện; sắp xếp, xoá. Số ảnh phải khớp với kiểu ghép đã chọn. MẸO: chọn \"Import theo tên ảnh\" ở menu nếu muốn hệ thống TỰ khớp ảnh với prompt bằng cách đặt tên file ảnh trùng tên nhân vật/đồ vật viết trong prompt." },
        { objectName: "bulkImportTextInput", title: "Prompt cho ảnh",
          body: "Mỗi dòng 1 prompt, hệ thống ghép với ảnh theo kiểu đã chọn ở trên." },
        { objectName: "bulkImportPreviewList", title: "Xem trước thẻ ghép",
          body: "Danh sách thẻ ảnh + prompt sẽ tạo. Tích chọn/bỏ từng thẻ trước khi import." },
        { objectName: "bulkImportAcceptButton", title: "Import ảnh vào danh sách",
          body: "Đưa các thẻ ảnh–prompt đã chọn vào panel để tạo video." }
    ],

    // Named-reference import — the tour opens the dialog via openForNamedRef so the
    // auto-match-by-filename flow is shown. (No submode panel in this mode.)
    "bulk_import_named_ref": [
        { objectName: "bulkImportImageList", title: "Ảnh đặt theo tên",
          body: "Thêm ảnh và ĐẶT TÊN FILE theo tên nhân vật/đồ vật (vd \"Mai.png\", \"logo.png\"). Hệ thống dùng chính tên này để khớp với prompt." },
        { objectName: "bulkImportTextInput", title: "Prompt có nhắc tên",
          body: "Viết prompt như thường, chỉ cần NHẮC ĐÚNG tên đã đặt cho ảnh (vd \"Mai đứng trước logo...\"). Ảnh sẽ tự gán vào cảnh chứa tên đó." },
        { objectName: "bulkImportPreviewList", title: "Xem khớp ảnh ↔ prompt",
          body: "Mỗi dòng hiện ảnh nào được khớp (hoặc \"không tìm thấy ảnh\"). Kiểm lại tên nếu có dòng chưa khớp." },
        { objectName: "bulkImportAcceptButton", title: "Import",
          body: "Đưa các thẻ đã khớp ảnh–prompt vào panel để tạo video." }
    ]
}

var COMMON_OUTRO = [
    { objectName: "jobPanel", shared: true,
      title: "Bảng Job",
      body: "Theo dõi tiến độ từng cảnh theo thời gian thực: đang tạo · xong · lỗi. Mỗi thẻ có các nút thao tác — xem tiếp bên dưới." },
    { objectName: "jobBtnRetry", shared: true,
      title: "Tạo lại cảnh",
      body: "Render lại đúng cảnh này (khi bị lỗi hoặc muốn kết quả khác) mà không phải làm lại cả video." },
    { objectName: "jobBtnUpscale", shared: true,
      title: "Nâng độ nét (Re-Upscale)",
      body: "Tăng độ phân giải của cảnh ĐÃ TẠO cho sắc nét hơn. Đi cặp với ô Chất lượng ở bảng cấu hình: cứ render nhanh ở mức vừa, cảnh nào ưng mới nâng nét — đỡ tốn credit hơn render tất cả ở mức cao." },
    { objectName: "jobBtnEdit", shared: true,
      title: "Sửa prompt cảnh",
      body: "Chỉnh lại lời mô tả (prompt) của cảnh rồi tạo lại theo ý mới." },
    { objectName: "jobBtnDelete", shared: true,
      title: "Xoá cảnh",
      body: "Xoá cảnh này khỏi bảng job (không ảnh hưởng các cảnh khác)." },
    { objectName: "statusBar", shared: true,
      title: "Thanh trạng thái",
      body: "Đáy màn hình: trạng thái hệ thống, bộ điều phối (dispatcher), số job trong hàng chờ, và lối mở nhật ký lỗi / theo dõi token." }
]

var SPECIFIC = {
    "master": [
        { objectName: "masterFeatureToolbar",
          title: "Thanh tính năng",
          body: "Các công tắc điều khiển cách AI dựng kịch bản và video. Ta đi qua từng nút từ trái sang phải." },
        { actionId: "master.feature.character_consistency", title: "Đồng nhất nhân vật · đồ vật · bối cảnh",
          body: "Mở hoặc thu gọn bảng đồng nhất bên dưới. Chỉ số N/3 cho biết bao nhiêu nhóm đang hoạt động; trạng thái thật được chọn riêng cho Nhân vật, Đồ vật và Bối cảnh trong bảng." },
        { actionId: "master.feature.auto_merge_video", title: "Tự động ghép video",
          body: "Tất cả cảnh render xong là hệ thống tự nối thành 1 video hoàn chỉnh — không cần ghép tay. Tắt nếu muốn tự dựng/edit từng clip: các cảnh rời vẫn nằm đủ trong thư mục lưu." },
        { objectName: "masterVoiceLanguage", title: "Ngôn ngữ lời thoại",
          body: "Chọn ngôn ngữ giọng nói cho video Master. Cờ và tên ngôn ngữ đang chọn được hiển thị ngay trên thanh tính năng." },
        ...LIBRARY_CONTROL,
        { actionId: "master.input.idea_mode", title: "Nhập bằng Ý tưởng",
          body: "Chỉ cần gõ ý tưởng (mỗi dòng = 1 video). AI tự viết kịch bản đầy đủ từ ý tưởng đó." },
        { actionId: "master.input.script_mode", title: "Nhập bằng Kịch bản",
          body: "Dán sẵn kịch bản hoàn chỉnh của bạn. AI giữ nguyên nội dung, chỉ phân cảnh và dựng video theo kịch bản." },
        { actionId: "master.input.narrator", title: "Người dẫn truyện",
          body: "Bật khi video có giọng KỂ CHUYỆN xuyên suốt (voice-over, không phải thoại nhân vật): AI tách lời dẫn riêng và giữ đúng 1 giọng kể đồng nhất qua mọi cảnh." },
        { actionId: "master.dialog.narrator_template", title: "Mẫu dẫn truyện", pre: "narrator:on",
          body: "Mẫu kịch bản có lời dẫn đúng format (chỉ hiện ở chế độ Kịch bản khi đã bật Người dẫn truyện) — viết theo mẫu để AI nhận diện lời dẫn chính xác." },
        { objectName: "narratorControl", title: "Cấu hình giọng dẫn truyện", pre: "narrator:on",
          body: "Panel hiện khi bật Người dẫn truyện: chọn nhà cung cấp Gemini, OmniVoice, MOSS hoặc VieNeu; sau đó chọn model/chế độ, giọng và cách đọc. Cấu hình dùng chung cho các luồng có lời dẫn." },
        { objectName: "ideaInput", title: "Ô nhập nội dung",
          body: "Gõ ý tưởng ở đây — mỗi DÒNG là 1 video riêng. Ở chế độ Kịch bản thì dán nguyên kịch bản. Có thể nhập hàng loạt qua nút Thêm Hàng Loạt bên dưới." },
        { actionId: "master.input.extra_requirements", title: "Yêu cầu thêm", pre: "extra:on",
          body: "Thêm ràng buộc riêng: ghi chú nhân vật, phong cách, điều cấm (negative)... áp cho toàn bộ video sắp tạo." },
        { actionId: "master.dialog.script_guide", title: "Hướng dẫn kịch bản", pre: "input:script",
          body: "Tài liệu cách viết kịch bản đúng format (phân cảnh, thoại, chú thích) để AI dựng chính xác ý bạn — kèm nút Copy toàn bộ, Copy mẫu trống và Mẫu dẫn truyện. Chỉ hiện ở chế độ Kịch bản." },
        { actionId: "master.queue.add_to_queue", title: "Thêm vào hàng chờ",
          body: "Đóng gói nội dung + toàn bộ cấu hình đang chọn thành các dòng hàng chờ (mỗi dòng = 1 video). CHƯA render vội — có thể thêm nhiều đợt với cấu hình khác nhau rồi chạy hết một lần bằng nút Bắt đầu xử lý." },
        { actionId: "master.dialog.bulk_import", title: "Nhập hàng loạt", dialog: "bulk_import",
          body: "Mở hộp Smart Bulk Import: dán nhiều ý tưởng (Idea) hoặc nhiều kịch bản (Script) cùng lúc — mỗi dòng/khối = 1 video. Tự tách khối thông minh, hoặc nạp từ file TXT / bảng tính (Excel/CSV, chọn cột + dải dòng). Xem trước & sửa từng mục rồi mới thêm vào hàng chờ." },
        { actionId: "master.queue.auto_clear_completed", title: "Tự xóa job xong",
          body: "Bật: tự xóa các job đã hoàn thành, luôn giữ lại job xong cuối cùng để còn mở thư mục. Tắt: mọi job xong vẫn nằm trong hàng chờ. Chỉ chạy 1 job thì job đó ở lại." },
        { actionId: "master.queue.start_processing", title: "Bắt đầu xử lý",
          body: "Chạy toàn bộ hàng chờ: AI viết kịch bản → tạo cảnh → render video. Theo dõi tiến độ ở Job Panel bên phải." },
        { actionId: "master.queue.stop_delete", title: "Dừng & Xoá",
          body: "Dừng khẩn cấp: huỷ việc đang chạy và gỡ các dòng CHƯA CHẠY / LỖI khỏi hàng chờ. Dòng đã hoàn thành giữ nguyên." },
        { actionId: "master.queue.clear_all", title: "Xoá tất cả",
          body: "Xoá toàn bộ dòng trong hàng chờ — bảng về trống. File video đã render trên máy KHÔNG bị xoá." },
        { objectName: "queueTable", title: "Danh sách hàng chờ",
          body: "Bảng dưới liệt kê mọi video đang chờ/đang tạo/đã xong. Mỗi dòng chỉnh nhanh được tỉ lệ, giọng, độ dài, style; bấm để xem chi tiết kịch bản hoặc mở thư mục." },
        { actionId: "master.queue.preview", title: "Xem trước cảnh",
          body: "Mỗi dòng hàng chờ có nút xem nhanh cảnh/kịch bản đã dựng trước khi render." },
        { actionId: "master.queue.open_folder", title: "Mở thư mục kết quả",
          body: "Mở thư mục chứa video/ảnh đã render của dòng này." },
        { actionId: "master.queue.delete_row", title: "Xoá dòng khỏi hàng chờ",
          body: "Bỏ video này khỏi hàng chờ (không ảnh hưởng các dòng khác)." }
    ],

    "clone": [
        { objectName: "cloneOutputMode", title: "Chọn loại đầu ra",
          body: "Ở hàng cấu hình Master: Tự động để AI quyết định, Ảnh để tạo chuỗi ảnh kể chuyện, hoặc Video để luôn tạo clip động. Hàng này cũng chứa model/clip/nhịp ảnh theo nhánh đang chọn." },
        { objectName: "cfgCloneDialogueLanguage", title: "Ngôn ngữ lời thoại đầu ra",
          body: "Nằm cạnh Thị trường trên MasterConfig. Giá trị tự đồng bộ theo market nhưng vẫn đổi riêng được tại đây." },
        { actionId: "work_panel.clone_creative_original", title: "Copy gốc — tái tạo 1:1",
          body: "Clone lại y hệt video gốc — giữ nguyên câu chuyện, lời thoại, hình ảnh." },
        { actionId: "work_panel.clone_creative_remix", title: "Giữ chuyện, đổi vỏ",
          body: "Cốt truyện & lời thoại y nguyên — chỉ thay nhân vật / bối cảnh / style hình / sản phẩm bằng chip công thức bên dưới." },
        { actionId: "work_panel.clone_creative_create", title: "Giữ công thức, chuyện mới",
          body: "AI học hook + cấu trúc + nhịp viral của video gốc rồi viết nội dung hoàn toàn mới theo chủ đề bạn điền." },
        { actionId: "work_panel.clone_creative_series", title: "Tập tiếp theo (series)",
          body: "Giữ NGUYÊN dàn nhân vật & thế giới của video gốc — AI viết tập mới với tình huống mới. Hợp kênh nuôi nhân vật dài tập." },
        { objectName: "remixInstructionsInput", title: "Yêu cầu riêng cho chế độ Clone", pre: "clone:remix",
          body: "Ô một dòng dùng phần trống ngay trong hàng Sao chép. Có thể để trống để AI chạy công thức chuẩn; khi nhập, nội dung này trở thành ràng buộc ưu tiên. Trên màn hình hẹp, ô này thu thành nút Yêu cầu thêm." },
        { actionId: "work_panel.clone_draw_toggle", title: "Bật/tắt Draw cho đầu ra Ảnh / Tự động",
          body: "Công tắc Draw nằm ở nửa ẢNH của hàng Đầu ra trên MasterConfig. Bật/tắt ngay tại đây, không cần mở dialog. Khi bật, mọi cảnh ảnh đi qua pipeline Draw (với Tự động chỉ khi hệ thống phân loại ra Ảnh)." },
        { actionId: "work_panel.clone_draw_settings", title: "Cấu hình Draw (style / tay)",
          body: "Nút Cấu hình chỉ bật khi Draw đang ON. Mở Style Manager bucket Draw để chọn Draw Style, actor và tay/bút — không dùng để tắt Draw." },
        { actionId: "work_panel.clone_char_consistency", title: "Điều khiển nhân vật · đồ vật · bối cảnh",
          body: "Mở hoặc thu gọn bảng đồng nhất. Chỉ số N/3 là số nhóm đang hoạt động; rất hữu ích khi Đổi vỏ hoặc làm Tập tiếp theo bằng nhân vật và bối cảnh riêng của bạn." },
        { actionId: "work_panel.clone_auto_merge", title: "Tự động ghép video",
          body: "Nối các cảnh clone thành 1 video hoàn chỉnh sau khi xong." },
        { objectName: "cloneNarrationVoice", title: "Giọng kể cho Clone ảnh",
          body: "TTS chỉ dùng khi video gốc có giọng kể chuyện. Clone kế thừa cấu hình chung và cho phép chọn nhanh provider/giọng; nghe thử và tùy chỉnh sâu được quản lý trong Voice Studio." },
        ...LIBRARY_CONTROL,
        { actionId: "work_panel.clone_video_files", title: "Chọn file video từ máy",
          body: "Chọn một hoặc nhiều video local đưa vào cùng danh sách nguồn. Không cần upload trước; job tự upload khi chạy." },
        { actionId: "work_panel.clone_video_folder", title: "Chọn cả thư mục video",
          body: "Quét một thư mục và thêm toàn bộ file video phù hợp vào danh sách nguồn trong một lần." },
        { actionId: "work_panel.clone_login_platform", title: "Đăng nhập nền tảng",
          body: "Đăng nhập bằng cookie để tải được video riêng tư / giới hạn khu vực." },
        { objectName: "cloneUrlInput", title: "Nguồn video: link và file chung một bảng",
          body: "Dán link YouTube, TikTok, Facebook hoặc Instagram, mỗi dòng một link; hệ thống tự lấy thông tin khi bạn ngừng gõ. Bạn cũng có thể kéo-thả file vào toàn bộ khung nguồn." },
        { objectName: "cloneSourceList", title: "Danh sách nguồn đã nhận",
          body: "Link và file local cùng nằm tại đây. Chọn từng dòng, kiểm tra trạng thái và dùng Config Override nếu một nguồn cần cấu hình riêng." },
        { actionId: "work_panel.clone_select_all", title: "Chọn nhanh toàn bộ nguồn",
          body: "Chọn tất cả các nguồn đang hiển thị; có thể dùng Deselect bên cạnh hoặc bỏ chọn riêng từng dòng trước khi đưa sang danh sách công việc." },
        { actionId: "work_panel.clone_submit_worklist", title: "Thêm vào danh sách công việc",
          body: "Đưa đúng các nguồn đang chọn qua bước xác nhận rồi vào hàng đợi Clone. Nếu vừa dán link và danh sách chưa kịp hiện, nút này sẽ kích hoạt lấy thông tin link trước." },
        { actionId: "work_panel.start_queue", title: "Bắt đầu Clone",
          body: "Nút Clone nằm ở đầu khung hàng đợi. Nó chạy chuỗi tải hoặc upload nguồn, phân tích, rồi tạo đầu ra theo chế độ và cấu hình đã chọn." },
        { objectName: "cloneQueueList", title: "Theo dõi hàng đợi Clone",
          body: "Mỗi dòng cho biết nguồn, đầu ra/model, chất lượng, style, ngôn ngữ và tiến trình. Các thao tác trên dòng chỉ tác động đúng job đó." }
    ],

    "transcript": [
        { objectName: "transcriptOutputMode", title: "Chọn loại đầu ra",
          body: "Ở hàng cấu hình Master: Tự động để AI quyết định Ảnh hay Video từ audio, Ảnh để luôn dựng chuỗi ảnh kể chuyện, hoặc Video để luôn tạo clip động. Hàng này cũng chứa model/clip/nhịp ảnh theo nhánh đang chọn." },
        { objectName: "cfgAutoImageRhythm", title: "Image Rhythm Framework", pre: "transcript:output_image",
          body: "Nhịp ảnh nằm ở nửa ẢNH của hàng Đầu ra trên MasterConfig. Chọn Auto, đúng N ảnh, một ảnh xuyên suốt, chi tiết, cân bằng hoặc theo chương. Backend khóa manifest và giữ nguyên số cảnh đến video cuối." },
        { actionId: "work_panel.transcript_draw_toggle", title: "Bật/tắt Draw cho đầu ra Ảnh / Tự động", pre: "transcript:output_image",
          body: "Công tắc Draw nằm ở nửa ẢNH của hàng Đầu ra trên MasterConfig. Bật/tắt ngay tại đây; với Tự động chỉ chạy Draw khi hệ thống phân loại ra Ảnh." },
        { actionId: "work_panel.transcript_draw_settings", title: "Cấu hình Draw (style / tay)", pre: "transcript:output_image",
          body: "Nút Cấu hình chỉ bật khi Draw đang ON. Mở Style Manager bucket Draw để chọn Draw Style và tay/bút dùng chung cho mọi cảnh minh hoạ." },
        { actionId: "work_panel.transcript_char_consistency", title: "Điều khiển nhân vật · đồ vật · bối cảnh",
          body: "Mở bảng nhất quán để người kể, nhân vật minh hoạ, vật thể và bối cảnh giữ đúng nhận diện qua toàn bộ timeline audio." },
        ...LIBRARY_CONTROL,
        { actionId: "work_panel.transcript_auto_merge", title: "Tự động ghép video",
          body: "Các cảnh minh hoạ render xong sẽ tự nối thành video hoàn chỉnh khớp audio gốc. Tắt nếu muốn tự dựng từ các clip hoặc ảnh rời." },
        { actionId: "work_panel.transcript_auto_next", title: "Tự chạy job kế tiếp",
          body: "Xong job hiện tại sẽ tự chạy job sau trong hàng đợi, phù hợp khi xử lý nhiều file audio liên tục." },
        { actionId: "work_panel.transcript_deep_analysis", title: "Suy luận sâu (Thinking)",
          body: "Bật khi lời thoại phức tạp và cần AI phân tích nhiều tầng ý trước khi chia cảnh; chế độ này dùng thêm thinking tokens." },
        { actionId: "work_panel.transcript_audio_files", title: "Chọn file audio",
          body: "Chọn một hoặc nhiều file MP3, WAV, M4A hoặc OGG. Mỗi file được đưa vào bảng nguồn như một video minh hoạ độc lập." },
        { actionId: "work_panel.transcript_audio_folder", title: "Thư mục audio",
          body: "Nạp cả một thư mục audio cùng lúc thay vì chọn từng file." },
        { objectName: "transcriptUrlInput", title: "Nhập audio bằng link",
          body: "Dán một hoặc nhiều link, mỗi dòng một link. Hệ thống chỉ lấy tiêu đề vào bảng nguồn trước; audio thật được tải khi hàng đợi bắt đầu xử lý." },
        { objectName: "transcriptAudioList", title: "Bảng audio chờ cấu hình",
          body: "Kiểm tra từng file hoặc link tại đây. Mỗi dòng có thể gắn SRT riêng và mở Kịch bản để hướng AI về nhịp, trọng tâm, gộp hoặc tách cảnh; Style quản lý phần mỹ thuật." },
        { actionId: "master.queue.add_to_queue", title: "Thêm vào hàng chờ",
          body: "Đưa các audio đã nạp cùng cấu hình hiện tại vào hàng đợi; mỗi file hoặc link trở thành một job độc lập và chưa render ở bước này." },
        { actionId: "work_panel.start_queue", title: "Bắt đầu Audio-to-Video",
          body: "Bắt đầu hoặc tiếp tục xử lý hàng đợi. Các nút Clear, Pause và Skip bên cạnh điều khiển luồng job mà không thay đổi phần cấu hình nguồn." },
        { objectName: "transcriptQueueList", title: "Theo dõi hàng đợi Audio-to-Video",
          body: "Bảng này hiển thị audio, tỉ lệ, style, trạng thái, tiến trình và số phân đoạn của từng job; có thể mở thư mục kết quả ngay trên từng dòng." }
    ],

    // Normal panel — walks the 4 FEATURE MODES in order first (all 4 buttons are
    // always visible), then the shared toolbar. The video model is chosen in the
    // config bar above (cfgModel, taught in the shared intro). Voice-sync only shows
    // in the 3-ingredient mode → it auto-skips in the other modes.
    "normal": [
        { objectName: "normalMode_text", title: "Chế độ Text",
          body: "Chỉ chữ → video. Gõ prompt, AI tự dựng cảnh — không cần ảnh đầu vào." },
        { objectName: "normalMode_image", title: "Chế độ Ảnh (1 ảnh)",
          body: "1 ảnh → video: AI làm ảnh chuyển động theo prompt (image-to-video)." },
        { objectName: "normalMode_interpolation", title: "Chế độ 2 Ảnh (nội suy)",
          body: "2 ảnh đầu–cuối: AI nội suy chuyển cảnh mượt từ ảnh đầu sang ảnh cuối." },
        { objectName: "normalMode_multi_asset", title: "Chế độ 3 Thành phần",
          body: "Ghép nhiều thành phần (nhân vật + đồ vật + bối cảnh) vào 1 cảnh. Hỗ trợ đồng bộ giọng khi dùng model R2V (Omni/Abra)." },
        { actionId: "work_panel.add_blank", title: "Thêm thẻ trống",
          body: "Thêm 1 thẻ prompt mới. Số ô ảnh trong thẻ đổi theo chế độ đang chọn (0 / 1 / 2 / nhiều)." },
        { actionId: "work_panel.bulk_import", title: "Nhập hàng loạt", dialog: "bulk_import_image",
          body: "Nhập nhiều prompt cùng lúc. Ở chế độ Ảnh / 3 Thành phần, nút này bung menu Standard Import và Named Reference (ghép ảnh theo tên trong prompt). Bấm \"Mở thử\" để xem hộp nhập ẢNH hàng loạt. (Chế độ Text nhập giống Master Prompt.)" },
        { actionId: "work_panel.select_all_cards", title: "Chọn / bỏ chọn thẻ",
          body: "Chọn nhanh mọi thẻ để gửi/xoá hàng loạt. Cạnh đó có Bỏ chọn, Xoá tất cả và bộ đếm đang-chọn / tổng." },
        { actionId: "work_panel.normal_voice_lock_toggle", title: "Đồng bộ giọng nói", pre: "normal:multi_asset",
          body: "Chỉ hiện ở chế độ 3 Thành phần: khoá giọng nhân vật xuyên suốt các cảnh (cần model R2V Omni/Abra)." },
        { actionId: "work_panel.normal_auto_merge_toggle", title: "Tự động ghép video",
          body: "Sau khi mọi thẻ render xong, tự nối thành 1 video hoàn chỉnh." },
        { actionId: "work_panel.submit_all", title: "Tạo video (gửi tất cả)",
          body: "Đưa các thẻ đang chọn vào hàng chờ tạo video. Nút hiện số thẻ đang chọn." }
    ],

    "extend": [
        { actionId: "work_panel.extend_rules", title: "Luật nối / gia hạn",
          body: "Bảng quy tắc chung khi AI viết đoạn tiếp: giữ bối cảnh, nhịp, hành động thế nào... Áp cho MỌI thẻ extend của phiên — chỉnh 1 lần thay vì dặn từng thẻ." },
        { actionId: "work_panel.add_blank", title: "Thêm thẻ trống",
          body: "Thêm 1 thẻ vào chuỗi: thẻ ROOT đầu tiên là video gốc, mỗi thẻ sau là 1 đoạn nối tiếp theo — chuỗi thẻ = mạch video dài." },
        { actionId: "work_panel.extend_bulk_import", title: "Nhập hàng loạt (Bulk Extend)", dialog: "bulk_extend",
          body: "Mở Bulk Extend Import: dán danh sách prompt, mỗi mục thành 1 thẻ nối/gia hạn video. Bấm \"Mở thử\" để xem hướng dẫn bên trong hộp." },
        { actionId: "work_panel.extend_generate_timeline", title: "Tạo timeline",
          body: "AI tự đề xuất timeline các đoạn nối từ video gốc — kết quả mở trong hộp xem trước, sửa từng mục ưng rồi mới nhận vào chuỗi thẻ." },
        { actionId: "work_panel.extend_preview", title: "Xem trước",
          body: "Xem nhanh timeline phiên nối hiện tại — kiểm tra mạch chuyện trước khi tốn credit render." },
        { actionId: "work_panel.extend_auto_merge_toggle", title: "Tự động ghép video",
          body: "Các đoạn render xong tự nối thành 1 video dài liền mạch. Tắt nếu muốn tự dựng tay từ các clip rời." },
        { actionId: "work_panel.extend_render_video", title: "Render video",
          body: "Xuất video hoàn chỉnh từ chuỗi gốc + các đoạn đã nối/gia hạn." },
        { actionId: "work_panel.submit_all", title: "Gửi tất cả",
          body: "Đưa các thẻ đã chọn vào hàng chờ để nối/gia hạn video." }
    ],

    "batch": [
        { actionId: "work_panel.batch_add_prompt", title: "Thêm prompt",
          body: "Thêm một prompt (mô tả ảnh) mới vào lô tạo ảnh." },
        { actionId: "work_panel.batch_import_images", title: "Nhập ảnh tham chiếu",
          body: "Nạp ảnh tham chiếu để AI bám theo khi tạo ảnh mới." },
        { actionId: "work_panel.bulk_import", title: "Nhập hàng loạt", dialog: "bulk_import",
          body: "Mở Smart Bulk Import cho ảnh: dán nhiều prompt cùng lúc và ghép với ảnh theo nhiều kiểu (N ảnh + N prompt, N ảnh + 1 prompt, 1 ảnh + N prompt, ghép nội suy, đa tham chiếu, ghép theo tên file). Bấm \"Mở thử\" để xem hướng dẫn bên trong." },
        { actionId: "work_panel.batch_save_to_library_toggle", title: "Lưu ảnh vào thư viện",
          body: "Bật để tự lưu ảnh tạo ra vào Media Library dùng lại về sau." },
        { actionId: "work_panel.submit_all", title: "Tạo ảnh (gửi tất cả)",
          body: "Đưa toàn bộ prompt trong lô vào hàng chờ tạo ảnh." },
        { actionId: "work_panel.clear_cards", title: "Xoá tất cả thẻ",
          body: "Xoá TOÀN BỘ thẻ prompt trong lô — bảng về trống. Ảnh đã render trên máy không bị xoá." }
    ],

    // Affiliate Studio — targets the durable cockpit regions, not product/queue
    // delegates. The tour therefore works both before the first import and while a
    // production pool is already running.
    "affiliate": [
        { objectName: "affiliateConfigPanel", title: "Cấu hình chiến dịch Affiliate",
          body: "Chọn model video, tỉ lệ, chất lượng, thư mục lưu, thị trường và ngôn ngữ lời dẫn. Giọng kể và cảm xúc chỉ dùng khi bật Lời dẫn; nếu tắt, KOL trong cảnh sẽ tự nói khi kịch bản cần." },
        { objectName: "affiliateModelBudget", title: "Ngân sách ảnh tham chiếu",
          body: "Dải này cho biết model đang chọn nhận tối đa bao nhiêu ảnh tham chiếu cho mỗi video: sản phẩm, KOL và bối cảnh. Chọn nhiều asset thì hệ thống tự xoay theo từng biến thể, không nhồi vượt giới hạn model." },
        { actionId: "affiliate.product.import", title: "Import sản phẩm",
          body: "Một cửa nhập duy nhất: thêm ảnh rời, thư mục sản phẩm hoặc lấy sản phẩm từ Shopee/TikTok. Mỗi sản phẩm vào Kho SP cùng ảnh, giá và dữ liệu nguồn để chuẩn bị chiến dịch." },
        { objectName: "affiliateProductLibrary", title: "① Kho sản phẩm",
          body: "Danh sách sản phẩm của chiến dịch. Chọn một sản phẩm để xem hồ sơ ở cột giữa; ngay trên thẻ có thể gắn KOL hoặc bối cảnh riêng cho sản phẩm đó, ưu tiên hơn tài nguyên chung." },
        { objectName: "affiliateSalesProfile", title: "② Hồ sơ bán hàng",
          body: "AI nhận diện sản phẩm đang chọn, kiểm tra dữ liệu còn thiếu và dựng công thức bán phù hợp. Có thể sửa ngành, giá, chức năng, nỗi đau, khách hàng, góc bán và mô tả trước khi chạy." },
        { objectName: "affiliateProductAnalysis", title: "Nhận diện và checklist",
          body: "Khối Nhận diện là dữ liệu đầu vào thật của kịch bản; checklist bên cạnh báo tài nguyên nào đã đủ, tài nguyên nào hệ thống sẽ tự tạo. Sửa tại đây sẽ ưu tiên hơn suy luận tự động." },
        { objectName: "affiliateVariantMatrix", title: "Ma trận thử nghiệm A/B",
          body: "Mỗi dòng là một video với format, hook và CTA riêng. Dùng “Thêm phiên bản” để tạo biến thể thủ công; hệ thống giữ từng biến thể độc lập khi đóng gói và đưa vào pipeline." },
        { objectName: "affiliateCharacterPicker", title: "Nhân vật KOL",
          body: "Để Auto nếu muốn AI tạo KOL hợp ngành từng sản phẩm, hoặc chuyển sang Thư viện để gắn nhân vật có sẵn. KOL tạo mới có thể tự lưu và khóa cùng giọng để tái sử dụng." },
        { objectName: "affiliateBackgroundPicker", title: "Bối cảnh",
          body: "Chọn Auto để dựng không gian quay phù hợp từng sản phẩm, hoặc dùng bối cảnh từ Thư viện. Mỗi scene chỉ nhận số bối cảnh nằm trong ngân sách tham chiếu của model." },
        { objectName: "affiliateQueuePool", title: "③ Pipeline và hàng chờ tự động",
          body: "Theo dõi toàn bộ vòng đời: nhập → sheet → plan → asset → voice → package → render → ghép. Mỗi dòng giữ trạng thái package, công việc hiện tại, kết quả và thao tác thử lại/mở thư mục/xóa." },
        { actionId: "affiliate.queue.autopilot", title: "Cổng Autopilot",
          body: "Bật để package đủ điều kiện được submit cuốn chiếu. Tắt chỉ ngừng đẩy lượt submit mới; package chưa submit được giữ nguyên và job đã submit vẫn chạy xong. Bật lại sẽ tiếp tục, không phân tích lại." },
        ...COMMON_OUTRO
    ],

    // Time Machine uses the shared video config + Job Panel but owns a dedicated
    // builder, chapter board, video order and durable queue.
    "timemachine": [
        { objectName: "timeMachineJobBuilder", title: "Tạo job Time Machine",
          body: "Đây là nơi gom ý tưởng, audio/SRT và ảnh mốc thành một job. Có thể bắt đầu chỉ bằng mô tả; nếu có ảnh thật, hệ thống dùng chúng làm neo cứng để giữ công trình hoặc chủ thể xuyên suốt thời gian." },
        { objectName: "timeMachineIntentInput", title: "Ý tưởng cần dựng theo thời gian",
          body: "Mô tả điểm đầu, điểm cuối hoặc quá trình muốn thấy. AI tự suy ra số phân đoạn, các mốc trung gian và hướng tiến/lùi phù hợp với nội dung." },
        { actionId: "timemachine.narration", title: "Dẫn truyện hoặc bình luận",
          body: "Bật để AI viết lời dẫn theo storyboard và tạo TTS. Tắt nếu chỉ cần hình ảnh cùng âm thanh gốc của video." },
        { objectName: "timeMachineAudioControls", title: "Audio, SRT và âm Veo",
          body: "Có thể nạp audio lời bình, SRT/VTT hoặc dùng TTS tự sinh. Cụm ÂM VEO chọn Auto duck, giữ 50% hay tắt âm gốc để lời dẫn không bị chồng lấn." },
        { objectName: "timeMachineInputMedia", title: "Ảnh mốc và tham chiếu",
          body: "Thêm nhiều ảnh từ Media Library. Ảnh thật trở thành mốc khóa; AI nhận diện góc nhìn và vị trí trên tiến trình. Không có ảnh vẫn chạy được — hệ thống sẽ tự sinh ảnh mốc từ ý tưởng." },
        { objectName: "timeMachinePipeline", title: "Workspace realtime",
          body: "Khu làm việc cập nhật trực tiếp từ pipeline: nhận diện → storyboard → keyframe → Start–End → voice → render → ghép. Nhãn trạng thái và phần trăm cho biết chính xác hệ thống đang ở bước nào." },
        { objectName: "timeMachineChapterBoard", title: "Bảng phân đoạn và ảnh mốc",
          body: "Mỗi hàng là một phân đoạn độc lập với chuỗi mốc riêng. Ảnh cuối hàng là neo của phân đoạn; bấm ô để xem nhanh hoặc sửa prompt khi bản kế hoạch đã sẵn sàng." },
        { objectName: "timeMachineVideoOrder", title: "Thứ tự clip Start–End",
          body: "Danh sách này là timeline video thật: clip chuyển giữa hai mốc, cảnh cắt khi đổi góc và cảnh kết Final Reveal. Có thể mở từng clip để chỉnh prompt chuyển động." },
        { actionId: "timemachine.queue.add", title: "Thêm vào hàng chờ",
          body: "Đóng gói ý tưởng, đầu vào và snapshot cấu hình hiện tại thành một job bền vững. Job đã thêm không bị thay đổi khi bạn chỉnh cấu hình cho job tiếp theo." },
        { objectName: "timeMachineQueue", title: "Hàng chờ Time Machine",
          body: "Mỗi dòng tóm tắt ý tưởng, đầu vào, quy mô pipeline, model/style, dẫn truyện, thư mục xuất và tiến độ A–Z. Chọn một dòng để theo dõi workspace và Job Panel của đúng job đó." }
    ],

    // Settings tab — standalone (no work-tab shared intro/outro). EVERY step targets
    // an ALWAYS-VISIBLE control so nothing floats: per-account/proxy ROW buttons (only
    // exist once you have accounts/proxies) and the mutually-exclusive TTS buttons
    // (Install XOR Start/Stop/Uninstall, by install state) are TAUGHT INSIDE the body
    // of their always-present parent step instead of getting their own spotlight step.
    // Research Labs — route "research" đứng riêng (không WORK_ROUTES). Mọi step trỏ
    // control LUÔN HIỆN; các khu điều kiện (Gợi ý AI / Tài liệu / nút Duyệt báo cáo)
    // dạy trong body — không pre, không step riêng.
    "research": [
        { objectName: "researchTopicTabs", title: "Nguồn chủ đề",
          body: "3 cách ra chủ đề: Câu hỏi — tự gõ. Gợi ý — AI sinh danh sách ý tưởng theo Mẫu nghiên cứu đang chọn, bấm \"Dùng\" là thành chủ đề. Tài liệu — đính kèm PDF/DOCX/TXT/MD làm nguồn để nghiên cứu bám theo." },
        { objectName: "researchTopicInput", title: "Ô chủ đề",
          body: "Nhập chủ đề / câu hỏi cần nghiên cứu. Ngừng gõ là AI TỰ CHẤM ĐIỂM 0–100 ngay bên dưới (Nên làm / Cân nhắc / Chưa đáng research) kèm lý do và góc gợi ý — khỏi tốn công nghiên cứu chủ đề yếu." },
        { objectName: "researchSetupCard", title: "Thiết lập nghiên cứu",
          body: "Mẫu nghiên cứu: nạp sẵn phong cách kịch bản, giọng đọc, thời lượng (không chọn cũng được). Ngôn ngữ đầu ra: áp cho cả kịch bản · audio · thông tin video." },
        { objectName: "researchModeSelect", title: "Chế độ nghiên cứu",
          body: "Lập kế hoạch trước = AI viết dàn ý để bạn duyệt rồi mới nghiên cứu (chất lượng cao nhất). Chạy ngay = nghiên cứu luôn. Tự động = chạy trọn pipeline nghiên cứu → kịch bản → audio, không cần duyệt tay." },
        { objectName: "researchDoneCard", title: "Đã nghiên cứu & Lịch tự động",
          body: "Mọi chủ đề đã làm nằm ở đây — bấm 1 dòng là mở lại báo cáo (🎧 = đã có audio). Dòng \"Lịch tự động\" phía trên: bấm Quản lý để đặt nghiên cứu chạy ĐỊNH KỲ, tự ra audio." },
        { objectName: "researchStartBtn", title: "Bắt đầu nghiên cứu",
          body: "Chạy nghiên cứu theo chế độ đã chọn — tiến trình và kết quả hiện ở khung bên phải. Nút \"Lịch\" bên cạnh: lên lịch chạy tự động định kỳ thay vì chạy tay." },
        { objectName: "researchOpsBtn", title: "Lịch sử · Hàng đợi · Lịch chạy",
          body: "Mở khung vận hành: Lịch sử job, Hàng đợi đang chờ, Lịch chạy định kỳ. Nút \"⏹ Dừng\" bên cạnh huỷ tác vụ nghiên cứu/kịch bản/TTS đang chạy." },
        { objectName: "researchStepper", title: "Tiến trình 2 bước",
          body: "Quy trình: ① Nghiên cứu → ② Sản xuất. Bấm vào chấm số để nhảy qua lại giữa 2 giai đoạn; bước Sản xuất mở khoá sau khi duyệt báo cáo." },
        { objectName: "researchOutputTabs", title: "Khung kết quả",
          body: "Nghiên cứu: Kế hoạch & Đánh giá · Báo cáo. Kịch bản: sửa trực tiếp trong ô, màn rộng có báo cáo tham chiếu bên cạnh. Sản xuất: Giọng đọc (nghe thử / lưu audio) · Thông tin video (tiêu đề, mô tả, thumbnail) · Gói hình ảnh." },
        { objectName: "researchChatInput", title: "Tinh chỉnh bằng chat",
          body: "Gõ yêu cầu để AI chỉnh đúng thứ đang xem: thu hẹp kế hoạch còn 3 góc, ưu tiên nguồn uy tín, viết lại kịch bản ngắn hơn... — không phải chạy lại từ đầu." },
        { objectName: "researchSendVideoBtn", title: "Import sang Audio-to-Video",
          body: "Bước chốt quy trình: báo cáo xong sẽ hiện nút \"✓ Duyệt báo cáo\" — chốt nội dung, tự tạo podcast. Rồi bấm nút này gửi audio + báo cáo sang tab AUDIO TO VIDEO để dựng video. \"Lưu báo cáo\" bên cạnh xuất file ra máy." }
    ],

    // Voice Studio — route riêng, không kèm config/job-panel của video. The tour
    // never changes provider because choosing a local provider can start managed
    // provisioning; it only switches the UI-only Single/Import and Queue/History
    // tabs so every workspace region can be shown without persisting user config.
    "voice": [
        { objectName: "voiceSharedTtsBar", title: "Trung tâm cấu hình giọng",
          body: "Cột bên trái là cấu hình TTS dùng chung cho job mới của Voice Studio, Master và Clone: trạng thái, provider, model/chế độ, giọng, ngôn ngữ và các tùy chọn thật sự có tác dụng." },
        { objectName: "voiceProviderStatus", title: "Trạng thái provider",
          body: "Thanh trạng thái cố định trên cùng hiển thị provider, mode, giọng và Sẵn sàng · Chưa cài · Đang tải/cài · Đang nạp model · Bị chặn phần cứng · Lỗi. Với engine local, ba ô bên phải đổi sang GPU, VRAM và RAM theo thời gian thực." },
        { objectName: "voiceProviderList", title: "Chọn nguồn tạo giọng",
          body: "Gemini chạy qua AI Studio; OmniVoice, MOSS-TTS và VieNeu là engine local có quản lý. Tour không tự đổi provider để tránh tải model ngoài ý muốn — bạn chỉ cần chọn provider phù hợp khi sử dụng." },
        { objectName: "voiceProviderSettings", title: "Tùy chỉnh theo provider",
          body: "Chỉ nội dung bên trong block cấu hình này đổi theo provider: Gemini có model/giọng/cách đọc; OmniVoice có mode, profile/clone/design, tốc độ, chất lượng và hậu kỳ; MOSS có mode/sampling/audio mẫu; VieNeu có giọng, style, precision và clone audio. Kích thước ba cột không đổi." },
        { actionId: "voice.config.save", title: "Lưu cấu hình dùng chung",
          body: "Áp dụng các thay đổi cho job tạo SAU này. Job đang chạy vẫn giữ snapshot cũ, nên đổi provider hoặc giọng tại đây không làm lệch audio đang render." },
        { actionId: "voice.config.reset", title: "Đặt lại thay đổi",
          body: "Bỏ các chỉnh sửa chưa lưu và nạp lại cấu hình giọng dùng chung gần nhất." },
        { objectName: "voiceGeminiDirector", title: "Đạo diễn giọng Gemini",
          body: "Cấu hình người nói, style, nhịp, chất giọng, Audio Profile, bối cảnh và ngữ cảnh mẫu nằm chung trong rack bên trái; vùng làm việc không lặp lại một khối cấu hình thứ hai." },
        { objectName: "voiceGeminiSpeakerControls", title: "Chỉ dẫn người nói",
          body: "Chọn một hoặc hai người nói. Khi dùng hội thoại, giọng thứ hai xuất hiện ngay tại đây; các lựa chọn được lưu cùng snapshot của job." },
        { objectName: "voiceInputTabs", title: "Nhập đơn hoặc Import",
          body: "Đơn tạo một job từ ô văn bản. Import nạp hàng loạt: mỗi file TXT/Markdown là một job, mỗi dòng CSV là một job; tất cả dùng cấu hình giọng ở cột trái." },
        { objectName: "voiceSingleInput", title: "Nội dung cần đọc", pre: "voice:single",
          body: "Dán hoặc gõ văn bản. Với Gemini hai người nói, dùng từng dòng “Speaker 1: …” / “Speaker 2: …”; có thể chèn [laughs], [whispers], [shouting] trực tiếp trong câu." },
        { objectName: "voicePreviewBar", title: "Nghe thử cấu hình",
          body: "Khi chưa có audio, nút loa tạo hoặc phát bản nghe thử của cấu hình hiện tại. Khi đã có audio, thanh này trở thành trình phát với tên file, tiến độ và thời lượng." },
        { objectName: "voiceAddQueue", title: "Thêm vào hàng đợi",
          body: "Đóng gói văn bản cùng snapshot cấu hình hiện tại thành một job. Có thể thêm nhiều job rồi chạy tuần tự một lần." },
        { objectName: "voiceImportArea", title: "Import hàng loạt", pre: "voice:import",
          body: "Chọn nhiều file TXT/Markdown hoặc CSV. File TXT tạo một job mỗi file; CSV tạo một job mỗi dòng và báo ngay tổng số job đã thêm." },
        { objectName: "voiceRightTabs", title: "Hàng đợi và Lịch sử", pre: "voice:queue",
          body: "Hàng đợi hiển thị job chờ/đang chạy/xong/lỗi. Lịch sử giữ các audio đã tạo để nghe lại, ghép hoặc gửi sang Audio to Video." },
        { actionId: "voice.output.pick_folder", title: "Thư mục lưu audio",
          body: "Chọn nơi lưu file âm thanh đầu ra. Đường dẫn hiện cố định trên khối vận hành bên phải để luôn biết audio sẽ được ghi ở đâu." },
        { actionId: "voice.queue.run", title: "Chạy hàng đợi", pre: "voice:queue",
          body: "Chạy tuần tự các job đang chờ. Khi bận, nút này đổi thành Dừng; bên cạnh có Xóa đã xong và nút xóa toàn bộ hàng đợi." },
        { objectName: "voiceQueueMonitor", title: "Bảng điều hành",
          body: "Bốn chỉ số Chờ, Đang chạy, Xong và Lỗi cùng thanh tiến độ được lấy trực tiếp từ queue. Chọn một job để xem route, giọng, chất lượng, lỗi và file đầu ra." },
        { objectName: "voiceQueueList", title: "Theo dõi từng job", pre: "voice:queue",
          body: "Mỗi dòng hiển thị trạng thái theo thời gian thực. Bảng chi tiết của job đã chọn cho phép sao chép ID, thử lại, bỏ qua, xóa, phát, mở file hoặc gửi sang Audio to Video." },
        { objectName: "voiceHistoryPanel", title: "Lịch sử audio", pre: "voice:history",
          body: "Theo dõi số file và dung lượng, mở thư mục đầu ra, nghe lại, sao chép đường dẫn, gửi từng file sang Audio to Video hoặc ghép nhiều file thành một bản." }
    ],

    "settings": [
        { objectName: "set_mode_ultra", title: "Chế độ ULTRA / PRO",
          body: "ULTRA: tối đa 10 tài khoản, mở khoá upscale ảnh 4K. PRO: không giới hạn số tài khoản (upscale tối đa 2K). Chỉ 1 chế độ chạy cùng lúc — bấm chọn chế độ nào thì tự bật tài khoản loại đó và tắt loại kia." },
        { actionId: "add_account", title: "Thêm tài khoản",
          body: "Mở trình duyệt đăng nhập Google/Gemini để thêm tài khoản. Mỗi hàng tài khoản sau đó có sẵn: Mở trình duyệt, Làm tươi cookie, Sửa, chọn/tạo Project (mỗi acc 1 project Google Cloud), Gán proxy riêng, và Xoá." },
        { actionId: "check_all_accounts", title: "Kiểm tra tất cả tài khoản",
          body: "Quét mọi tài khoản để xác minh cookie, trạng thái và tín chỉ còn lại." },
        { actionId: "reset_profiles", title: "Xoá hồ sơ trình duyệt",
          body: "Xoá toàn bộ hồ sơ trình duyệt đã lưu (phải đăng nhập lại tất cả). Chỉ dùng khi hồ sơ hỏng." },
        { actionId: "clear_proxy_mappings", title: "Xoá ánh xạ proxy",
          body: "Bỏ hết gán proxy→tài khoản (proxy vẫn còn trong nhóm)." },
        { actionId: "add_proxy", title: "Thêm proxy",
          body: "Nhập proxy (vd socks5://ip:port) + đường quay IP (tuỳ chọn) — sẽ được kiểm tra tự động. Mỗi hàng proxy có nút Xoá; nút \"Xoay IP\" xuất hiện khi proxy đã cấu hình đường quay (bấm cột đường quay để nhập)." },
        { actionId: "check_proxies", title: "Kiểm tra proxy",
          body: "Quét nhóm proxy để xác minh Live/Dead, thời gian phản hồi." },
        { actionId: "remove_dead_proxies", title: "Xoá proxy chết",
          body: "Tự xoá mọi proxy trạng thái Dead khỏi nhóm." },
        { actionId: "remove_selected_proxy", title: "Xoá proxy đã chọn",
          body: "Xoá proxy đang chọn (bấm 1 hàng proxy để chọn trước)." },
        { actionId: "move_database", title: "Di chuyển cơ sở dữ liệu",
          body: "Chọn vị trí mới cho veoflow.db. Hồ sơ trình duyệt/TTS/nhật ký vẫn ở chỗ cũ. Cần khởi động lại." }
    ]
}

function hasSteps(route) {
    return !!SPECIFIC[String(route || "")]
}

// Work tabs share the config-bar intro + job-panel/status-bar outro. Non-work
// routes (settings) stand alone — prepending COMMON would just make the tour
// stall on unresolvable config/job-panel steps before auto-skipping.
var WORK_ROUTES = {
    "master": 1, "clone": 1, "transcript": 1, "normal": 1, "extend": 1, "batch": 1,
    "timemachine": 1
}

function stepsFor(route) {
    var r = String(route || "")
    var specific = SPECIFIC[r]
    if (!specific)
        return []
    if (WORK_ROUTES[r])
        return COMMON_INTRO.concat(specific).concat(COMMON_OUTRO)
    return specific
}

function hasDialogTour(id) {
    return !!DIALOG_TOURS[String(id || "")]
}

function dialogStepsFor(id) {
    var s = DIALOG_TOURS[String(id || "")]
    return s ? s.slice() : []
}


