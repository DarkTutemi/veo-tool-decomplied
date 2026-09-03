import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../components"
import "../theme"

Dialog {
    id: root

    property int fixedCharacterCount: 0
    // Image batch (batch route) cần Model + Tỷ lệ; clone batch (nhân bản video)
    // kế thừa model/tỷ lệ từ motif gốc nên ẩn đi (set false ở cloneBatchConfigDialog).
    property bool showMediaFields: true
    property int initialVariations: 10
    property bool initialAntiDuplicate: true
    property string initialInstructions: ""
    property string initialCharacterStrategy: "inherit"
    property string initialVariationStrength: "balanced"
    property string initialAspectRatio: "16:9"
    property string initialModel: "GEM_PIX_2"
    property string statusText: ""
    property string feedbackTitle: ""
    property string feedbackMessage: ""

    signal saveRequested(int variations, bool antiDuplicate, string instructions, string characterStrategy, string variationStrength, string aspectRatio, string model)

    title: (void i18n.revision, i18n.t("batch.dialog_title", "Batch Configuration"))
    header: null
    modal: true
    parent: Overlay.overlay
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    width: VfDialogMetrics.width(parent, 700, 80)
    height: VfDialogMetrics.height(parent, 583, 80)
    x: VfDialogMetrics.centerX(parent, width)
    y: VfDialogMetrics.centerY(parent, height)
    padding: 0

    background: Rectangle {
        color: VfTheme.surface
        radius: VfTheme.dp(10)
        border.color: VfTheme.borderStrong
        border.width: 1
    }

    function variationsValue() {
        return parseInt(String(variations.currentText || "10").replace(/[^0-9]/g, "")) || 10
    }

    function comboIndexByValue(combo, wanted, fallbackIndex) {
        var nextIndex = fallbackIndex || 0
        for (var i = 0; i < combo.model.length; i++) {
            var row = combo.model[i]
            if (row && String(row.value) === String(wanted)) {
                nextIndex = i
                break
            }
        }
        return nextIndex
    }

    function openFor(config) {
        var payload = config || ({})
        root.initialVariations = Number(payload.variations || 10)
        root.initialAntiDuplicate = payload.anti_duplicate === undefined ? true : Boolean(payload.anti_duplicate)
        root.initialInstructions = String(payload.instructions || "")
        root.initialCharacterStrategy = String(payload.character_strategy || "inherit")
        root.initialVariationStrength = String(payload.variation_strength || "balanced")
        root.initialAspectRatio = String(payload.aspect_ratio || "16:9")
        root.initialModel = String(payload.model || "GEM_PIX_2")
        root.statusText = ""

        var options = [1, 2, 3, 5, 10, 20, 50, 100]
        var wanted = root.initialVariations
        var nextIndex = 4
        for (var i = 0; i < options.length; i++) {
            if (options[i] === wanted) {
                nextIndex = i
                break
            }
        }
        variations.currentIndex = nextIndex
        antiDup.checked = root.initialAntiDuplicate
        characterStrategy.currentIndex = root.comboIndexByValue(characterStrategy, root.initialCharacterStrategy, 1)
        variationStrength.currentIndex = root.comboIndexByValue(variationStrength, root.initialVariationStrength, 0)
        aspectRatioCombo.currentIndex = root.comboIndexByValue(aspectRatioCombo, root.initialAspectRatio, 0)
        modelCombo.currentIndex = root.comboIndexByValue(modelCombo, root.initialModel, 0)
        root.open()
    }

    function applySaveResult(result) {
        var response = result || ({})
        if (response.ok === false) {
            var message = String(response.message || response.error || response.code || "Save failed.")
            root.statusText = message
            root.feedbackTitle = "Error"
            root.feedbackMessage = message
            feedbackDialog.open()
            return
        }
        root.statusText = String(response.message || "Batch config saved.")
        root.accept()
    }

    contentItem: ColumnLayout {
        spacing: VfTheme.dp(16)

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: VfTheme.dp(1)
        }

        Text {
            Layout.fillWidth: true
            Layout.leftMargin: 20
            Layout.rightMargin: 20
            text: (void i18n.revision, i18n.t("batch_config_dialog.title", "Cấu hình tạo Batch"))
            color: VfTheme.text
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.dp(18)
            font.weight: Font.Bold
        }

        Text {
            Layout.fillWidth: true
            Layout.leftMargin: 20
            Layout.rightMargin: 20
            text: (void i18n.revision, i18n.t("batch_config_dialog.subtitle", "Tạo nhiều job độc lập từ motif đã fetch. Không fetch lại video nguồn."))
            color: VfTheme.textMuted
            wrapMode: Text.WordWrap
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.dp(13)
            lineHeight: 1.18
        }

        GridLayout {
            Layout.fillWidth: true
            Layout.leftMargin: 20
            Layout.rightMargin: 20
            columns: 2
            columnSpacing: VfTheme.dp(18)
            rowSpacing: VfTheme.dp(12)

            // Số biến thể
            ColumnLayout {
                Layout.fillWidth: true
                spacing: VfTheme.dp(4)
                FieldLabel { text: (void i18n.revision, i18n.t("batch_config_dialog.variation_count_label", "Số biến thể:")) }
                NoScrollComboBox {
                    id: variations
                    Layout.fillWidth: true
                    Layout.preferredHeight: VfTheme.dp(44)
                    model: ["1 videos", "2 videos", "3 videos", "5 videos", "10 videos", "20 videos", "50 videos", "100 videos"]
                    currentIndex: 4
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(15)
                    background: FieldBackground { active: variations.activeFocus }
                }
            }

            // Tỷ lệ khung hình (chỉ batch ảnh; clone batch kế thừa từ motif)
            ColumnLayout {
                Layout.fillWidth: true
                visible: root.showMediaFields
                spacing: VfTheme.dp(4)
                FieldLabel { text: (void i18n.revision, i18n.t("batch.aspect_ratio_label", "Tỷ lệ khung hình:")) }
                NoScrollComboBox {
                    id: aspectRatioCombo
                    Layout.fillWidth: true
                    Layout.preferredHeight: VfTheme.dp(44)
                    model: [
                        { label: (void i18n.revision, i18n.t("batch_config_dialog.aspect_16_9", "16:9 (Ngang rộng)")), value: "16:9" },
                        { label: (void i18n.revision, i18n.t("batch_config_dialog.aspect_4_3", "4:3 (Ngang cổ điển)")), value: "4:3" },
                        { label: (void i18n.revision, i18n.t("batch_config_dialog.aspect_1_1", "1:1 (Vuông)")), value: "1:1" },
                        { label: (void i18n.revision, i18n.t("batch_config_dialog.aspect_3_4", "3:4 (Dọc cổ điển)")), value: "3:4" },
                        { label: (void i18n.revision, i18n.t("batch_config_dialog.aspect_9_16", "9:16 (Dọc)")), value: "9:16" }
                    ]
                    currentIndex: 0
                    textRole: "label"
                    valueRole: "value"
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(13)
                    background: FieldBackground { active: aspectRatioCombo.activeFocus }
                }
            }

            // Model tạo ảnh (chỉ batch ảnh; clone batch kế thừa model từ motif)
            ColumnLayout {
                Layout.fillWidth: true
                visible: root.showMediaFields
                spacing: VfTheme.dp(4)
                FieldLabel { text: (void i18n.revision, i18n.t("batch.model_label", "Model:")) }
                NoScrollComboBox {
                    id: modelCombo
                    Layout.fillWidth: true
                    Layout.preferredHeight: VfTheme.dp(44)
                    model: [
                        { label: "🍌 Nano Banana Pro", value: "GEM_PIX_2" },
                        { label: "🍌 Nano Banana 2", value: "NARWHAL" }
                    ]
                    currentIndex: 0
                    textRole: "label"
                    valueRole: "value"
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(14)
                    background: FieldBackground { active: modelCombo.activeFocus }
                }
            }

            // Nhân vật
            ColumnLayout {
                Layout.fillWidth: true
                spacing: VfTheme.dp(4)
                FieldLabel { text: (void i18n.revision, i18n.t("batch_config_dialog.character_label", "Nhân vật:")) }
                NoScrollComboBox {
                    id: characterStrategy
                    Layout.fillWidth: true
                    Layout.preferredHeight: VfTheme.dp(44)
                    model: root.fixedCharacterCount > 0 ? [
                        { label: (void i18n.revision, i18n.t("batch_config_dialog.char_inherit", "Ẩn theo config Clone chính")), value: "inherit" },
                        { label: (void i18n.revision, i18n.t("batch_config_dialog.char_lock_main", "Khóa nhân vật chính")), value: "lock_main" },
                        { label: (void i18n.revision, i18n.t("batch_config_dialog.char_reuse_all", "Dùng lại toàn bộ nhân vật")), value: "reuse_all" }
                    ] : [
                        { label: (void i18n.revision, i18n.t("batch_config_dialog.char_inherit", "Ẩn theo config Clone chính")), value: "inherit" },
                        { label: (void i18n.revision, i18n.t("batch_config_dialog.char_lock_main", "Khóa nhân vật chính")), value: "lock_main" },
                        { label: (void i18n.revision, i18n.t("batch_config_dialog.char_fresh_all", "Tạo mới toàn bộ nhân vật")), value: "fresh_all" },
                        { label: (void i18n.revision, i18n.t("batch_config_dialog.char_reuse_all", "Dùng lại toàn bộ nhân vật")), value: "reuse_all" }
                    ]
                    currentIndex: 1
                    textRole: "label"
                    valueRole: "value"
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(14)
                    background: FieldBackground { active: characterStrategy.activeFocus }
                }
            }

            // Độ khác biệt
            ColumnLayout {
                Layout.fillWidth: true
                spacing: VfTheme.dp(4)
                FieldLabel { text: (void i18n.revision, i18n.t("batch_config_dialog.variation_strength_label", "Độ khác biệt:")) }
                NoScrollComboBox {
                    id: variationStrength
                    Layout.fillWidth: true
                    Layout.preferredHeight: VfTheme.dp(44)
                    model: [
                        { label: (void i18n.revision, i18n.t("batch_config_dialog.variation_safe", "An toàn - ít khác biệt")), value: "safe" },
                        { label: (void i18n.revision, i18n.t("batch_config_dialog.variation_balanced", "Cân bằng - video mới rõ ràng")), value: "balanced" },
                        { label: (void i18n.revision, i18n.t("batch_config_dialog.variation_wild", "Mạnh - khác biệt lớn")), value: "wild" }
                    ]
                    currentIndex: 1
                    textRole: "label"
                    valueRole: "value"
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(14)
                    background: FieldBackground { active: variationStrength.activeFocus }
                }
            }

            // Chống trùng lặp — toggle button chính
            ColumnLayout {
                Layout.fillWidth: true
                spacing: VfTheme.dp(4)
                FieldLabel { text: (void i18n.revision, i18n.t("batch_config_dialog.anti_dup_label", "Chống trùng lặp:")) }
                Rectangle {
                    id: antiDup
                    property bool checked: true
                    Layout.fillWidth: true
                    Layout.preferredHeight: VfTheme.dp(44)
                    radius: VfTheme.dp(8)
                    color: antiDup.checked ? "#8B5CF6" : VfTheme.surface
                    border.color: antiDup.checked ? "#7C3AED" : VfTheme.borderStrong
                    border.width: antiDup.checked ? 0 : 1

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: VfTheme.dp(8)
                        VfAppIcon {
                            name: antiDup.checked ? "check-mark-button" : "empty-box"
                            size: VfTheme.dp(14)
                            framed: false
                            color: antiDup.checked ? "#FFFFFF" : VfTheme.textMuted
                        }
                        Text {
                            text: antiDup.checked ? (void i18n.revision, i18n.t("batch_config_dialog.anti_dup_enabled", "Đang bật")) : (void i18n.revision, i18n.t("batch_config_dialog.anti_dup_disabled", "Đang tắt"))
                            color: antiDup.checked ? "#FFFFFF" : VfTheme.textMuted
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.dp(14)
                            font.weight: Font.DemiBold
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: antiDup.checked = !antiDup.checked
                    }
                }
            }
        }

        Text {
            Layout.fillWidth: true
            Layout.leftMargin: 20
            Layout.rightMargin: 20
            text: (void i18n.revision, i18n.t("batch_config_dialog.anti_dup_note", "Anti-dup đổi ý/kịch bản. Độ đồng nhất nhân vật vẫn ăn theo Library Control/Creative character settings ở panel Clone chính."))
            color: VfTheme.textSubtle
            wrapMode: Text.WordWrap
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.dp(12)
        }

        Rectangle {
            visible: root.fixedCharacterCount > 0
            Layout.fillWidth: true
            Layout.leftMargin: 20
            Layout.rightMargin: 20
            implicitHeight: fixedNote.implicitHeight + 20
            radius: VfTheme.dp(6)
            color: VfTheme.amberFill
            border.color: VfTheme.amberBorderSoft

            Text {
                id: fixedNote
                anchors.fill: parent
                anchors.margins: VfTheme.dp(10)
                text: (void i18n.revision, i18n.t("batch_config_dialog.fixed_char_note", "Đang có ")) + root.fixedCharacterCount + (void i18n.revision, i18n.t("batch_config_dialog.fixed_char_suffix", " nhân vật cố định từ Library. Batch sẽ giữ các nhân vật này; tùy chọn tạo nhân vật mới đã được ẩn để tránh lỗi cấu hình."))
                color: VfTheme.amberText
                wrapMode: Text.WordWrap
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(12)
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.leftMargin: 20
            Layout.rightMargin: 20
            implicitHeight: instructionNote.implicitHeight + 20
            radius: VfTheme.dp(6)
            color: VfTheme.surfaceSoft
            border.color: VfTheme.border

            Text {
                id: instructionNote
                anchors.fill: parent
                anchors.margins: VfTheme.dp(10)
                text: (void i18n.revision, i18n.t("batch_config_dialog.instruction_note", "Batch không có ô nhập prompt riêng. Nếu đang ở Remix hoặc Creative, instruction từ tab chính sẽ được dùng để tạo parent motif và được khóa tiếp vào mọi video con."))
                color: VfTheme.textMuted
                wrapMode: Text.WordWrap
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(12)
            }
        }

        Item { Layout.fillHeight: true }

        Text {
            Layout.fillWidth: true
            Layout.leftMargin: 20
            Layout.rightMargin: 20
            visible: root.statusText.length > 0
            text: root.statusText
            color: VfTheme.redText
            wrapMode: Text.WordWrap
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.dp(12)
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: 20
            Layout.rightMargin: 20
            Layout.bottomMargin: 18
            spacing: VfTheme.dp(8)

            Item { Layout.fillWidth: true }

            VfButton {
                text: (void i18n.revision, i18n.t("common.cancel", "Hủy"))
                minWidth: VfTheme.dp(96)
                onClicked: root.reject()
            }

            VfButton {
                text: (void i18n.revision, i18n.t("common.ok", "OK"))
                tone: "accent"
                minWidth: VfTheme.dp(96)
                onClicked: {
                    root.saveRequested(
                        root.variationsValue(),
                        antiDup.checked,
                        "",
                        String(characterStrategy.currentValue || "inherit"),
                        String(variationStrength.currentValue || "balanced"),
                        String(aspectRatioCombo.currentValue || "16:9"),
                        String(modelCombo.currentValue || "GEM_PIX_2")
                    )
                }
            }
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
            border.color: VfTheme.border
        }

        contentItem: ColumnLayout {
            spacing: VfTheme.dp(14)

            Text {
                Layout.fillWidth: true
                text: root.feedbackTitle
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(18)
                font.weight: Font.DemiBold
                wrapMode: Text.WordWrap
            }

            Text {
                Layout.fillWidth: true
                text: root.feedbackMessage
                color: VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(12)
                wrapMode: Text.WordWrap
            }

            RowLayout {
                Layout.fillWidth: true
                Item { Layout.fillWidth: true }

                VfButton {
                    text: (void i18n.revision, i18n.t("common.ok", "OK"))
                    minWidth: VfTheme.dp(96)
                    onClicked: feedbackDialog.close()
                }
            }
        }
    }

    component FieldLabel: Text {
        color: VfTheme.text
        font.family: VfTheme.fontFamily
        font.pixelSize: VfTheme.dp(13)
        verticalAlignment: Text.AlignVCenter
    }

    component FieldBackground: Rectangle {
        property bool active: false

        radius: VfTheme.dp(6)
        color: VfTheme.surface
        border.color: active ? "#8B5CF6" : VfTheme.borderStrong
        border.width: active ? 2 : 1
    }
}
