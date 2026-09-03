import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../components"
import "../theme"

Dialog {
    id: root

    objectName: "affiliateCharGenDialog"

    readonly property string assetType: "character"
    property var previewItems: []
    property int selectedIndex: -1
    property string statusText: ""
    property string feedbackTitle: ""
    property string feedbackMessage: ""
    property bool closeAfterFeedback: false
    property string jobId: ""
    property string cardId: ""

    // Structured KOL controls ("" = AUTO, AI tự quyết). Nền mặc định trắng.
    property string optGender: ""
    property string optAge: ""
    property string optSkin: ""
    property string optExpr: ""
    property string optMakeup: ""
    property string optTier: "kol"
    property string optWardrobe: ""
    property string optFraming: ""
    property string optLighting: ""
    property string optBackground: "white"
    property var countOptions: [
        { label: (void i18n.revision, i18n.t("affiliate_char_gen_dialog.count_1", "1 ảnh")), value: 1 },
        { label: (void i18n.revision, i18n.t("affiliate_char_gen_dialog.count_2", "2 ảnh")), value: 2 },
        { label: (void i18n.revision, i18n.t("affiliate_char_gen_dialog.count_4", "4 ảnh")), value: 4 }
    ]
    property var aspectOptions: [
        { label: (void i18n.revision, i18n.t("affiliate_char_gen_dialog.aspect_portrait_9_16", "9:16 (Portrait, khuyến nghị)")), value: "IMAGE_ASPECT_RATIO_PORTRAIT" },
        { label: (void i18n.revision, i18n.t("affiliate_char_gen_dialog.aspect_portrait_3_4", "3:4 (Portrait)")), value: "IMAGE_ASPECT_RATIO_PORTRAIT_THREE_FOUR" },
        { label: (void i18n.revision, i18n.t("affiliate_char_gen_dialog.aspect_square", "1:1 (Square)")), value: "IMAGE_ASPECT_RATIO_SQUARE" }
    ]
    property var styleOptions: [
        (void i18n.revision, i18n.t("affiliate_char_gen_dialog.style_realistic", "Realistic (Ảnh thật)")),
        (void i18n.revision, i18n.t("affiliate_char_gen_dialog.style_studio_portrait", "Studio portrait")),
        (void i18n.revision, i18n.t("affiliate_char_gen_dialog.style_cinematic", "Cinematic")),
        (void i18n.revision, i18n.t("affiliate_char_gen_dialog.style_soft_natural", "Soft natural light"))
    ]

    signal generateRequested(var payload)
    signal saveRequested(var payload)
    signal selectRequested(var payload)

    parent: Overlay.overlay
    title: (void i18n.revision, i18n.t("affiliate.char_gen_dialog_title", "Tạo nhân vật KOL"))
    header: null
    modal: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    width: VfDialogMetrics.width(parent, 1180, 48)
    height: VfDialogMetrics.height(parent, 720, 48)
    x: VfDialogMetrics.centerX(parent, width)
    y: VfDialogMetrics.centerY(parent, height)
    padding: 0
    standardButtons: Dialog.NoButton

    function selectedCount() {
        return Number(countCombo.currentValue || 4)
    }

    function selectedAspect() {
        return String(aspectCombo.currentValue || "IMAGE_ASPECT_RATIO_PORTRAIT")
    }

    function selectedStyle() {
        return String(styleCombo.currentText || (void i18n.revision, i18n.t("affiliate_char_gen_dialog.style_realistic", "Realistic (Ảnh thật)")))
    }

    function showFeedback(title, message, closeAfter) {
        root.feedbackTitle = String(title || "")
        root.feedbackMessage = String(message || "")
        root.closeAfterFeedback = Boolean(closeAfter)
        feedbackDialog.open()
    }

    function buildPayload() {
        return {
            asset_type: root.assetType,
            prompt: briefInput.text.trim(),
            ai_compose: briefInput.text.trim().length === 0,   // trống → AI tự định hình theo control + thị trường + SP
            output_count: root.selectedCount(),
            aspect_ratio: root.selectedAspect(),
            style_preset: root.selectedStyle(),
            options: {
                gender: root.optGender, age: root.optAge, skin: root.optSkin,
                expression: root.optExpr, makeup: root.optMakeup, tier: root.optTier,
                wardrobe: root.optWardrobe, framing: root.optFraming,
                lighting: root.optLighting, background: root.optBackground,
                hair: hairInput.text.trim(), outfit: outfitInput.text.trim()
            },
            card_id: root.cardId,
            job_id: root.jobId
        }
    }

    function previewImageSource(item) {
        var preview = item || ({})
        var base64Data = String(preview.base64 || preview.image_base64 || "")
        if (base64Data.length > 0)
            return "data:image/png;base64," + base64Data
        return String(preview.fife_url || preview.fifeUrl || preview.preview_path || preview.path || "")
    }

    function submitGenerate() {
        // Trống mô tả → AI tự định hình nhân vật theo thị trường + sản phẩm (multi-step compose).
        root.statusText = briefInput.text.trim().length === 0
            ? (void i18n.revision, i18n.t("affiliate_char_gen_dialog.ai_composing", "AI đang tự định hình & tạo ảnh theo thị trường..."))
            : (void i18n.revision, i18n.t("affiliate_char_gen_dialog.generating_ai", "Đang gọi AI... Vui lòng chờ."))
        root.generateRequested(root.buildPayload())
    }

    function applyGenerationResult(response) {
        var result = response || ({})
        root.jobId = String(result.job_id || "")
        root.cardId = String(result.card_id || "")
        root.previewItems = result.images || result.preview_items || []
        root.selectedIndex = -1
        root.statusText = result.error || result.message || (root.previewItems.length > 0 ? ((void i18n.revision, i18n.t("affiliate_char_gen_dialog.generation_complete", "Tạo xong")) + " " + root.previewItems.length + " " + (void i18n.revision, i18n.t("affiliate_char_gen_dialog.select_image", "ảnh - click để chọn ảnh muốn lưu."))) : "")
        if (!result.ok)
            root.showFeedback((void i18n.revision, i18n.t("common.error", "Lỗi")), root.statusText, false)
    }

    function selectPreview(index) {
        if (index < 0 || index >= 4)
            return
        root.selectedIndex = index
        root.selectRequested({
            asset_type: root.assetType,
            selected_index: index,
            preview: root.previewItems[index] || ({}),
            preview_items: root.previewItems,
            card_id: root.cardId,
            job_id: root.jobId
        })
    }

    function applySelectionResult(response) {
        var result = response || ({})
        if (result.ok) {
            root.selectedIndex = Number(result.selected_index)
            root.statusText = result.message || (void i18n.revision, i18n.t("affiliate_char_gen_dialog.image_selected", "Da chon anh preview."))
            root.cardId = String(result.card_id || root.cardId || "")
            root.jobId = String(result.job_id || root.jobId || "")
        } else {
            root.statusText = result.error || result.message || (void i18n.revision, i18n.t("affiliate_char_gen_dialog.selection_failed", "Khong chon duoc anh preview."))
            root.showFeedback((void i18n.revision, i18n.t("common.error", "Lỗi")), root.statusText, false)
        }
    }

    function saveSelected() {
        if (root.selectedIndex < 0) {
            root.statusText = (void i18n.revision, i18n.t("affiliate_char_gen_dialog.select_image_prompt", "Hãy click vào ảnh muốn lưu."))
            root.showFeedback((void i18n.revision, i18n.t("affiliate_char_gen_dialog.no_image_selected", "Chưa chọn ảnh")), root.statusText, false)
            return
        }
        root.saveRequested({
            asset_type: root.assetType,
            selected_index: root.selectedIndex,
            preview: root.previewItems[root.selectedIndex] || ({}),
            name: "affiliate_character",
            tags: ["affiliate", "character"],
            preview_items: root.previewItems,
            card_id: root.cardId,
            job_id: root.jobId,
            image_base64: String((root.previewItems[root.selectedIndex] || ({})).base64 || (root.previewItems[root.selectedIndex] || ({})).image_base64 || "")
        })
    }

    function applySaveResult(response) {
        var result = response || ({})
        if (result.ok && (result.saved || String(result.media_id || "").length > 0)) {
            root.statusText = result.message || (void i18n.revision, i18n.t("affiliate_char_gen_dialog.image_saved_library", "Da luu anh vao thu vien."))
            root.showFeedback((void i18n.revision, i18n.t("common.saved", "Đã lưu")), root.statusText, true)
        } else {
            root.statusText = result.error || result.message || (void i18n.revision, i18n.t("affiliate_char_gen_dialog.save_failed", "Luu anh khong thanh cong."))
            root.showFeedback((void i18n.revision, i18n.t("affiliate_char_gen_dialog.save_error", "Lỗi lưu")), root.statusText, false)
        }
    }

    background: Rectangle {
        radius: VfTheme.radiusPanel
        color: VfTheme.surfaceSoft
        border.color: VfTheme.borderStrong
        border.width: 1
    }

    contentItem: ColumnLayout {
        anchors.fill: parent
        anchors.margins: VfTheme.dp(20)
        spacing: VfTheme.dp(12)

        Text {
            Layout.fillWidth: true
            text: (void i18n.revision, i18n.t("affiliate.char_gen_dialog_title", "Tạo nhân vật KOL"))
            color: VfTheme.text
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.dp(18)
            font.weight: Font.Bold
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: VfTheme.dp(16)

            Rectangle {
                Layout.preferredWidth: VfTheme.dp(720)
                Layout.fillHeight: true
                radius: VfTheme.dp(8)
                color: VfTheme.surface
                border.color: VfTheme.border
                border.width: 1

                ScrollView {
                    id: formScroll
                    anchors.fill: parent
                    anchors.margins: VfTheme.dp(14)
                    clip: true
                    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                    GridLayout {
                        width: formScroll.availableWidth
                        columns: 2
                        columnSpacing: VfTheme.dp(16)
                        rowSpacing: VfTheme.dp(8)

                        OptChips { Layout.alignment: Qt.AlignTop
                            label: (void i18n.revision, i18n.t("affiliate_char_gen_dialog.gender", "Giới tính"))
                            opts: [{ v: "male", t: (void i18n.revision, i18n.t("affiliate_char_gen_dialog.male", "Nam")) }, { v: "female", t: (void i18n.revision, i18n.t("affiliate_char_gen_dialog.female", "Nữ")) }]
                            value: root.optGender; onPicked: root.optGender = v }
                        OptChips { Layout.alignment: Qt.AlignTop
                            label: (void i18n.revision, i18n.t("affiliate_char_gen_dialog.age", "Độ tuổi"))
                            opts: [{ v: "genz", t: "Gen Z" }, { v: "adult", t: "25-34" }, { v: "mature", t: "35-45" }]
                            value: root.optAge; onPicked: root.optAge = v }
                        OptChips { Layout.alignment: Qt.AlignTop
                            label: (void i18n.revision, i18n.t("affiliate_char_gen_dialog.skin", "Da"))
                            opts: [{ v: "fair", t: (void i18n.revision, i18n.t("affiliate_char_gen_dialog.skin_fair", "Trắng")) }, { v: "medium", t: (void i18n.revision, i18n.t("affiliate_char_gen_dialog.skin_medium", "Trung bình")) }, { v: "tan", t: (void i18n.revision, i18n.t("affiliate_char_gen_dialog.skin_tan", "Ngăm")) }]
                            value: root.optSkin; onPicked: root.optSkin = v }
                        OptChips { Layout.alignment: Qt.AlignTop
                            label: (void i18n.revision, i18n.t("affiliate_char_gen_dialog.expr", "Biểu cảm"))
                            opts: [{ v: "smile", t: (void i18n.revision, i18n.t("affiliate_char_gen_dialog.expr_smile", "Tươi cười")) }, { v: "confident", t: (void i18n.revision, i18n.t("affiliate_char_gen_dialog.expr_confident", "Tự tin")) }, { v: "friendly", t: (void i18n.revision, i18n.t("affiliate_char_gen_dialog.expr_friendly", "Thân thiện")) }]
                            value: root.optExpr; onPicked: root.optExpr = v }
                        OptChips { Layout.alignment: Qt.AlignTop
                            label: (void i18n.revision, i18n.t("affiliate_char_gen_dialog.makeup", "Trang điểm"))
                            opts: [{ v: "light", t: (void i18n.revision, i18n.t("affiliate_char_gen_dialog.makeup_light", "Nhẹ")) }, { v: "natural", t: (void i18n.revision, i18n.t("affiliate_char_gen_dialog.makeup_natural", "Tự nhiên")) }, { v: "none", t: (void i18n.revision, i18n.t("affiliate_char_gen_dialog.makeup_none", "Không")) }]
                            value: root.optMakeup; onPicked: root.optMakeup = v }
                        OptChips { Layout.alignment: Qt.AlignTop
                            label: (void i18n.revision, i18n.t("affiliate_char_gen_dialog.tier", "Đẳng cấp"))
                            opts: [{ v: "koc", t: "KOC" }, { v: "kol", t: "KOL" }, { v: "celebrity", t: (void i18n.revision, i18n.t("affiliate_char_gen_dialog.tier_celeb", "Minh tinh")) }]
                            value: root.optTier; onPicked: root.optTier = v }
                        OptChips { Layout.columnSpan: 2; Layout.alignment: Qt.AlignTop
                            label: (void i18n.revision, i18n.t("affiliate_char_gen_dialog.wardrobe", "Phong cách"))
                            opts: [{ v: "office", t: (void i18n.revision, i18n.t("affiliate_char_gen_dialog.wd_office", "Công sở")) }, { v: "casual", t: (void i18n.revision, i18n.t("affiliate_char_gen_dialog.wd_casual", "Casual sang")) }, { v: "street", t: "Street" }, { v: "sport", t: (void i18n.revision, i18n.t("affiliate_char_gen_dialog.wd_sport", "Thể thao")) }, { v: "gala", t: (void i18n.revision, i18n.t("affiliate_char_gen_dialog.wd_gala", "Dạ hội")) }, { v: "industry", t: (void i18n.revision, i18n.t("affiliate_char_gen_dialog.wd_industry", "Theo ngành")) }]
                            value: root.optWardrobe; onPicked: root.optWardrobe = v }
                        OptChips { Layout.alignment: Qt.AlignTop
                            label: (void i18n.revision, i18n.t("affiliate_char_gen_dialog.background", "Nền"))
                            opts: [{ v: "white", t: (void i18n.revision, i18n.t("affiliate_char_gen_dialog.bg_white", "Trắng")) }, { v: "grey", t: (void i18n.revision, i18n.t("affiliate_char_gen_dialog.bg_grey", "Xám")) }, { v: "context", t: (void i18n.revision, i18n.t("affiliate_char_gen_dialog.bg_context", "Ngữ cảnh")) }]
                            value: root.optBackground; onPicked: root.optBackground = (v || "white") }
                        OptChips { Layout.alignment: Qt.AlignTop
                            label: (void i18n.revision, i18n.t("affiliate_char_gen_dialog.framing", "Khung hình"))
                            opts: [{ v: "portrait", t: (void i18n.revision, i18n.t("affiliate_char_gen_dialog.fr_portrait", "Chân dung")) }, { v: "half", t: (void i18n.revision, i18n.t("affiliate_char_gen_dialog.fr_half", "Bán thân")) }, { v: "full", t: (void i18n.revision, i18n.t("affiliate_char_gen_dialog.fr_full", "Toàn thân")) }, { v: "multi", t: (void i18n.revision, i18n.t("affiliate_char_gen_dialog.fr_multi", "Đủ góc")) }]
                            value: root.optFraming; onPicked: root.optFraming = v }
                        OptChips { Layout.columnSpan: 2; Layout.alignment: Qt.AlignTop
                            label: (void i18n.revision, i18n.t("affiliate_char_gen_dialog.lighting", "Ánh sáng"))
                            opts: [{ v: "studio", t: "Studio" }, { v: "natural", t: (void i18n.revision, i18n.t("affiliate_char_gen_dialog.lt_natural", "Tự nhiên")) }, { v: "cinematic", t: "Cinematic" }]
                            value: root.optLighting; onPicked: root.optLighting = v }

                        ColumnLayout {
                            Layout.fillWidth: true; Layout.alignment: Qt.AlignTop; spacing: VfTheme.dp(3)
                            FieldLabel { text: (void i18n.revision, i18n.t("affiliate_char_gen_dialog.hair", "Tóc (kiểu + màu)")) }
                            LineInput { id: hairInput; Layout.fillWidth: true
                                placeholderText: (void i18n.revision, i18n.t("affiliate_char_gen_dialog.hair_ph", "vd: tóc dài đen, layer...")) }
                        }
                        ColumnLayout {
                            Layout.fillWidth: true; Layout.alignment: Qt.AlignTop; spacing: VfTheme.dp(3)
                            FieldLabel { text: (void i18n.revision, i18n.t("affiliate_char_gen_dialog.outfit", "Áo / quần (tuỳ chọn)")) }
                            LineInput { id: outfitInput; Layout.fillWidth: true
                                placeholderText: (void i18n.revision, i18n.t("affiliate_char_gen_dialog.outfit_ph", "Áo/quần cụ thể (tuỳ chọn)")) }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true; Layout.alignment: Qt.AlignTop; spacing: VfTheme.dp(3)
                            FieldLabel { text: (void i18n.revision, i18n.t("common.count", "Số lượng")) }
                            NoScrollComboBox { id: countCombo; Layout.fillWidth: true; Layout.preferredHeight: VfTheme.dp(34)
                                model: root.countOptions; textRole: "label"; valueRole: "value"; currentIndex: 2 }
                        }
                        ColumnLayout {
                            Layout.fillWidth: true; Layout.alignment: Qt.AlignTop; spacing: VfTheme.dp(3)
                            FieldLabel { text: (void i18n.revision, i18n.t("affiliate_char_gen_dialog.aspect_ratio", "Tỉ lệ")) }
                            NoScrollComboBox { id: aspectCombo; Layout.fillWidth: true; Layout.preferredHeight: VfTheme.dp(34)
                                model: root.aspectOptions; textRole: "label"; valueRole: "value"; currentIndex: 0 }
                        }
                        ColumnLayout {
                            Layout.columnSpan: 2; Layout.fillWidth: true; spacing: VfTheme.dp(3)
                            FieldLabel { text: (void i18n.revision, i18n.t("affiliate_char_gen_dialog.style_label", "Chất ảnh")) }
                            NoScrollComboBox { id: styleCombo; Layout.fillWidth: true; Layout.preferredHeight: VfTheme.dp(34)
                                model: root.styleOptions; currentIndex: 0 }
                        }

                        ColumnLayout {
                            Layout.columnSpan: 2; Layout.fillWidth: true; spacing: VfTheme.dp(3)
                            FieldLabel { text: (void i18n.revision, i18n.t("affiliate_char_gen_dialog.more_desc", "Mô tả thêm (tuỳ chọn)")) }
                            Rectangle {
                                Layout.fillWidth: true; Layout.preferredHeight: VfTheme.dp(56)
                                radius: VfTheme.radiusControl; color: VfTheme.surface; border.color: VfTheme.borderBox
                                TextArea {
                                    id: briefInput
                                    anchors.fill: parent; anchors.margins: VfTheme.dp(6)
                                    wrapMode: TextArea.Wrap; selectByMouse: true
                                    color: VfTheme.text; placeholderTextColor: VfTheme.textSubtle
                                    placeholderText: (void i18n.revision, i18n.t("affiliate_char_gen_dialog.prompt_example", "vd: cầm sản phẩm, studio sáng, nụ cười tươi..."))
                                    font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.dp(13)
                                    background: null
                                }
                            }
                        }

                        VfButton {
                            Layout.columnSpan: 2; Layout.fillWidth: true; implicitHeight: VfTheme.dp(42)
                            text: "⚡ " + (void i18n.revision, i18n.t("affiliate_char_gen_dialog.generate_kol", "Tạo KOL"))
                            tone: "accent"
                            onClicked: root.submitGenerate()
                        }
                        Text {
                            Layout.columnSpan: 2; Layout.fillWidth: true
                            visible: root.statusText.length > 0
                            text: root.statusText
                            color: VfTheme.textSubtle; wrapMode: Text.WordWrap
                            font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.dp(11)
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: VfTheme.dp(8)
                color: VfTheme.surface
                border.color: VfTheme.border
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: VfTheme.dp(16)
                    spacing: VfTheme.dp(12)

                    FieldLabel { text: (void i18n.revision, i18n.t("affiliate_char_gen_dialog.results_label", "Kết quả (click để chọn)")); bold: true }

                    GridLayout {
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.leftMargin: 16
                        Layout.rightMargin: 16
                        columns: 2
                        columnSpacing: VfTheme.dp(26)
                        rowSpacing: VfTheme.dp(12)

                        Repeater {
                            model: 4

                            ThumbSlot {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                selected: root.selectedIndex === index
                                hasItem: root.previewItems && root.previewItems.length > index
                                label: hasItem ? ((void i18n.revision, i18n.t("affiliate_char_gen_dialog.image_label", "Ảnh")) + " " + (index + 1)) : "—"
                                imageSource: hasItem ? root.previewImageSource(root.previewItems[index] || ({})) : ""
                                onClicked: root.selectPreview(index)
                            }
                        }
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: VfTheme.dp(10)

            Item { Layout.fillWidth: true }

            VfButton {
                text: (void i18n.revision, i18n.t("common.cancel", "Hủy"))
                minWidth: VfTheme.dp(86)
                implicitHeight: VfTheme.dp(40)
                onClicked: root.reject()
            }

            VfButton {
                text: (void i18n.revision, i18n.t("affiliate_char_gen_dialog.save_to_library", "Lưu vào thư viện"))
                tone: "success"
                minWidth: VfTheme.dp(194)
                implicitHeight: VfTheme.dp(40)
                enabled: root.selectedIndex >= 0
                onClicked: root.saveSelected()
            }
        }
    }

    component FieldLabel: Text {
        property bool bold: false
        color: VfTheme.text
        font.family: VfTheme.fontFamily
        font.pixelSize: VfTheme.dp(12)
        font.weight: bold ? Font.Bold : Font.Normal
    }

    component LineInput: TextField {
        Layout.preferredHeight: VfTheme.dp(34)
        color: VfTheme.text
        placeholderTextColor: VfTheme.textSubtle
        selectByMouse: true
        font.family: VfTheme.fontFamily
        font.pixelSize: VfTheme.dp(13)
        leftPadding: VfTheme.dp(8)
        background: Rectangle {
            radius: VfTheme.radiusControl
            color: VfTheme.surface
            border.color: VfTheme.borderBox
            border.width: 1
        }
    }

    // Nhóm chip 1-lựa-chọn ("" = AUTO). Click lại chip đang chọn → bỏ (về AUTO).
    component OptChips: ColumnLayout {
        id: ocRoot
        property string label: ""
        property var opts: []
        property string value: ""
        signal picked(string v)
        Layout.fillWidth: true
        spacing: VfTheme.dp(3)
        FieldLabel { text: ocRoot.label }
        Flow {
            Layout.fillWidth: true
            spacing: VfTheme.dp(5)
            Repeater {
                model: ocRoot.opts
                VfChip {
                    text: String((modelData || {}).t || "")
                    selected: ocRoot.value === String((modelData || {}).v || "")
                    accent: VfTheme.primary
                    showLeadingIcon: false
                    onClicked: ocRoot.picked(ocRoot.value === String((modelData || {}).v || "") ? "" : String((modelData || {}).v || ""))
                }
            }
        }
    }

    component ThumbSlot: Rectangle {
        id: thumb

        property bool selected: false
        property bool hasItem: false
        property string label: "—"
        property string imageSource: ""
        signal clicked()

        radius: VfTheme.dp(6)
        color: VfTheme.surfaceSoft
        border.color: selected ? VfTheme.primary : VfTheme.border
        border.width: selected ? 2 : 1
        implicitHeight: VfTheme.dp(224)

        Image {
            anchors.fill: parent
            anchors.margins: VfTheme.dp(8)
            visible: thumb.imageSource.length > 0
            source: thumb.imageSource
            fillMode: Image.PreserveAspectFit
            cache: false
            asynchronous: true
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: VfTheme.dp(10)
            text: thumb.label
            color: thumb.imageSource.length > 0 ? VfTheme.text : VfTheme.textSubtle
            font.family: VfTheme.fontFamily
            font.pixelSize: thumb.hasItem ? 13 : 24
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: thumb.clicked()
        }
    }

    Dialog {
        id: feedbackDialog
        parent: Overlay.overlay
        modal: true
        anchors.centerIn: parent
        width: VfDialogMetrics.width(parent, VfTheme.dp(420), VfTheme.dp(64))
        padding: VfTheme.dp(20)
        title: ""
        standardButtons: Dialog.NoButton

        background: Rectangle {
            radius: VfTheme.dp(8)
            color: VfTheme.surface
            border.color: VfTheme.borderStrong
        }

        contentItem: ColumnLayout {
            spacing: VfTheme.dp(14)

            Text {
                Layout.fillWidth: true
                text: root.feedbackTitle
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(18)
                font.weight: VfTheme.weightTitle
                wrapMode: Text.WordWrap
            }

            Text {
                Layout.fillWidth: true
                text: root.feedbackMessage
                color: VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontControl
                wrapMode: Text.WordWrap
            }

            RowLayout {
                Layout.fillWidth: true
                Item { Layout.fillWidth: true }

                VfButton {
                    text: "OK"
                    tone: "primary"
                    minWidth: VfTheme.dp(96)
                    onClicked: {
                        feedbackDialog.close()
                        if (root.closeAfterFeedback)
                            root.accept()
                    }
                }
            }
        }
    }
}


