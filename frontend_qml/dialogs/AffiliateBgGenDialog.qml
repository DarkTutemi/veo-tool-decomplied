import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../components"
import "../theme"

Dialog {
    id: root

    objectName: "affiliateBgGenDialog"

    readonly property string assetType: "background"
    property var previewItems: []
    property int selectedIndex: -1
    property string statusText: ""
    property string feedbackTitle: ""
    property string feedbackMessage: ""
    property bool closeAfterFeedback: false
    property string jobId: ""
    property string cardId: ""
    property var countOptions: [
        { label: (void i18n.revision, i18n.t("affiliate_bg_gen_dialog.count_1_image", "1 ảnh")), value: 1 },
        { label: (void i18n.revision, i18n.t("affiliate_bg_gen_dialog.count_2_images", "2 ảnh")), value: 2 },
        { label: (void i18n.revision, i18n.t("affiliate_bg_gen_dialog.count_4_images", "4 ảnh")), value: 4 }
    ]
    property var aspectOptions: [
        { label: (void i18n.revision, i18n.t("affiliate_bg_gen_dialog.aspect_portrait", "9:16 (Portrait, khuyến nghị)")), value: "IMAGE_ASPECT_RATIO_PORTRAIT" },
        { label: "16:9 (Landscape)", value: "IMAGE_ASPECT_RATIO_LANDSCAPE" },
        { label: "1:1 (Square)", value: "IMAGE_ASPECT_RATIO_SQUARE" }
    ]
    property var environmentOptions: [
        (void i18n.revision, i18n.t("affiliate_bg_gen_dialog.environment_indoor", "Indoor (Trong nhà)")),
        (void i18n.revision, i18n.t("affiliate_bg_gen_dialog.environment_outdoor", "Outdoor (Ngoài trời)")),
        (void i18n.revision, i18n.t("affiliate_bg_gen_dialog.environment_studio", "Studio (Phòng chụp)")),
        "Abstract"
    ]

    signal generateRequested(var payload)
    signal saveRequested(var payload)
    signal selectRequested(var payload)

    parent: Overlay.overlay
    title: (void i18n.revision, i18n.t("affiliate.bg_gen_dialog_title", "Tạo bối cảnh (Background)"))
    header: null
    modal: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    width: VfDialogMetrics.width(parent, 950, 48)
    height: VfDialogMetrics.height(parent, 733, 48)
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

    function selectedEnvironment() {
        return String(environmentCombo.currentText || (void i18n.revision, i18n.t("affiliate_bg_gen_dialog.environment_indoor", "Indoor (Trong nhà)")))
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
            ai_compose: briefInput.text.trim().length === 0,   // trống → AI tự dựng bối cảnh theo thị trường + SP
            output_count: root.selectedCount(),
            aspect_ratio: root.selectedAspect(),
            environment_preset: root.selectedEnvironment(),
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
        // Trống mô tả → AI tự dựng bối cảnh theo thị trường + sản phẩm (multi-step compose).
        root.statusText = briefInput.text.trim().length === 0
            ? (void i18n.revision, i18n.t("affiliate_bg_gen_dialog.ai_composing", "AI đang tự dựng bối cảnh theo thị trường..."))
            : (void i18n.revision, i18n.t("affiliate_bg_gen_dialog.calling_ai_status", "Đang gọi AI... Vui lòng chờ."))
        root.generateRequested(root.buildPayload())
    }

    function applyGenerationResult(response) {
        var result = response || ({})
        root.jobId = String(result.job_id || "")
        root.cardId = String(result.card_id || "")
        root.previewItems = result.images || result.preview_items || []
        root.selectedIndex = -1
        root.statusText = result.error || result.message || (root.previewItems.length > 0 ? ((void i18n.revision, i18n.t("affiliate_bg_gen_dialog.generation_complete_prefix", "Tạo xong ")) + root.previewItems.length + (void i18n.revision, i18n.t("affiliate_bg_gen_dialog.generation_complete_suffix", " ảnh - click để chọn ảnh muốn lưu."))) : "")
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
            root.statusText = result.message || (void i18n.revision, i18n.t("affiliate_bg_gen_dialog.preview_selected", "Da chon anh preview."))
            root.cardId = String(result.card_id || root.cardId || "")
            root.jobId = String(result.job_id || root.jobId || "")
        } else {
            root.statusText = result.error || result.message || (void i18n.revision, i18n.t("affiliate_bg_gen_dialog.preview_selection_failed", "Khong chon duoc anh preview."))
            root.showFeedback((void i18n.revision, i18n.t("common.error", "Lỗi")), root.statusText, false)
        }
    }

    function saveSelected() {
        if (root.selectedIndex < 0) {
            root.statusText = (void i18n.revision, i18n.t("affiliate_bg_gen_dialog.click_to_select_image", "Hãy click vào ảnh muốn lưu."))
            root.showFeedback((void i18n.revision, i18n.t("affiliate_bg_gen_dialog.no_image_selected_title", "Chưa chọn ảnh")), root.statusText, false)
            return
        }
        root.saveRequested({
            asset_type: root.assetType,
            selected_index: root.selectedIndex,
            preview: root.previewItems[root.selectedIndex] || ({}),
            name: "affiliate_background",
            tags: ["affiliate", "background"],
            preview_items: root.previewItems,
            card_id: root.cardId,
            job_id: root.jobId,
            image_base64: String((root.previewItems[root.selectedIndex] || ({})).base64 || (root.previewItems[root.selectedIndex] || ({})).image_base64 || "")
        })
    }

    function applySaveResult(response) {
        var result = response || ({})
        if (result.ok && (result.saved || String(result.media_id || "").length > 0)) {
            root.statusText = result.message || (void i18n.revision, i18n.t("affiliate_bg_gen_dialog.image_saved_to_library", "Da luu anh vao thu vien."))
            root.showFeedback((void i18n.revision, i18n.t("common.saved", "Đã lưu")), root.statusText, true)
        } else {
            root.statusText = result.error || result.message || (void i18n.revision, i18n.t("affiliate_bg_gen_dialog.save_image_failed", "Luu anh khong thanh cong."))
            root.showFeedback((void i18n.revision, i18n.t("affiliate_bg_gen_dialog.save_image_error_title", "Lỗi lưu")), root.statusText, false)
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
            text: (void i18n.revision, i18n.t("affiliate.bg_gen_dialog_title", "Tạo bối cảnh (Background)"))
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
                Layout.preferredWidth: VfTheme.dp(350)
                Layout.fillHeight: true
                radius: VfTheme.dp(8)
                color: VfTheme.surface
                border.color: VfTheme.border
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: VfTheme.dp(16)
                    spacing: VfTheme.dp(8)

                    FieldLabel { text: (void i18n.revision, i18n.t("affiliate_bg_gen_dialog.description_label", "Mô tả")); bold: true }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: VfTheme.dp(240)
                        radius: VfTheme.dp(5)
                        color: VfTheme.surface
                        border.color: VfTheme.border

                        TextArea {
                            id: briefInput
                            property string emptyHint: (void i18n.revision, i18n.t("affiliate_bg_gen_dialog.description_example", "Ví dụ: Phòng gym hiện đại, ánh sáng tự nhiên, tông màu trắng xám, không có người..."))
                            anchors.fill: parent
                            anchors.margins: VfTheme.dp(6)
                            wrapMode: TextArea.Wrap
                            selectByMouse: true
                            color: VfTheme.text
                            placeholderTextColor: VfTheme.textSubtle
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.dp(14)
                            background: Rectangle {
                                color: VfTheme.surface
                                border.color: VfTheme.borderBox
                                border.width: 1
                                radius: VfTheme.radiusControl
                            }
                        }

                        Text {
                            anchors.fill: parent
                            anchors.margins: VfTheme.dp(12)
                            visible: briefInput.text.length === 0
                            text: briefInput.emptyHint
                            color: VfTheme.textSubtle
                            wrapMode: Text.WordWrap
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.dp(14)
                        }
                    }

                    FieldLabel { text: (void i18n.revision, i18n.t("affiliate_bg_gen_dialog.count_label", "Số lượng")) }
                    NoScrollComboBox {
                        id: countCombo
                        Layout.fillWidth: true
                        Layout.preferredHeight: VfTheme.dp(34)
                        model: root.countOptions
                        textRole: "label"
                        valueRole: "value"
                        currentIndex: 2
                    }

                    FieldLabel { text: (void i18n.revision, i18n.t("affiliate_bg_gen_dialog.aspect_ratio_label", "Tỉ lệ ảnh")) }
                    NoScrollComboBox {
                        id: aspectCombo
                        Layout.fillWidth: true
                        Layout.preferredHeight: VfTheme.dp(34)
                        model: root.aspectOptions
                        textRole: "label"
                        valueRole: "value"
                        currentIndex: 0
                    }

                    FieldLabel { text: (void i18n.revision, i18n.t("affiliate_bg_gen_dialog.environment_label", "Môi trường")) }
                    NoScrollComboBox {
                        id: environmentCombo
                        Layout.fillWidth: true
                        Layout.preferredHeight: VfTheme.dp(34)
                        model: root.environmentOptions
                        currentIndex: 0
                    }

                    VfButton {
                        Layout.fillWidth: true
                        implicitHeight: VfTheme.dp(44)
                        text: "Generate"
                        tone: "accent"
                        onClicked: root.submitGenerate()
                    }

                    Text {
                        Layout.fillWidth: true
                        visible: root.statusText.length > 0
                        text: root.statusText
                        color: VfTheme.textSubtle
                        wrapMode: Text.WordWrap
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.dp(11)
                    }

                    Item { Layout.fillHeight: true }
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

                    FieldLabel { text: (void i18n.revision, i18n.t("affiliate_bg_gen_dialog.results_label", "Kết quả (click để chọn)")); bold: true }

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
                                label: hasItem ? ((void i18n.revision, i18n.t("affiliate_bg_gen_dialog.image_label", "Ảnh")) + " " + (index + 1)) : "—"
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
                text: (void i18n.revision, i18n.t("affiliate_bg_gen_dialog.save_to_library_button", "Lưu vào thư viện"))
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
                    text: (void i18n.revision, i18n.t("common.ok", "OK"))
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


