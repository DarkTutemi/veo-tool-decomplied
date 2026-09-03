pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../dialogs"
import "../theme"

Item {
    id: dialogs

    property var controller: null
    signal actionError(string message)
    signal jobPromptRegenerateRequested(string jobId)
    signal failedJobRetryRequested(string jobId)
    signal failedJobFolderRequested(string folder)

    function editStage(stageIdx, name, visibleDescription) {
        stageDialog.stageIdx = stageIdx
        stageName.text = name
        stageVisible.text = visibleDescription
        stageDialog.errorText = ""
        stageDialog.open()
    }

    function editCell(viewId, viewLabel, stageIdx, prompt, locked) {
        if (locked)
            return
        cellDialog.viewId = viewId
        cellDialog.viewLabel = viewLabel
        cellDialog.stageIdx = stageIdx
        cellPrompt.text = prompt
        cellDialog.errorText = ""
        cellDialog.open()
    }

    function editMotion(motionKey, viewLabel, fromStage, toStage, prompt) {
        motionDialog.motionKey = motionKey
        motionDialog.finalReveal = String(motionKey || "")
                                   .indexOf("final_reveal:") === 0
        motionDialog.caption = motionDialog.finalReveal
                               ? viewLabel
                                 + " · CAMERA VIEW TOÀN CẢNH"
                               : viewLabel + " · S" + fromStage
                                 + " → S" + toStage
        motionPrompt.text = prompt
        motionDialog.errorText = ""
        motionDialog.open()
    }

    function chooseGraphicsPreset() {
        graphicsDialog.errorText = ""
        graphicsDialog.open()
    }

    function viewJobPrompt(payload) {
        var detail = payload || ({})
        detail.read_only = true
        detail.allow_regenerate = true
        detail.dialog_title = "Prompt video Start–End"
        detail.context_label = String(detail.title || "Clip Start–End")
        jobPromptDialog.openFor(detail, true)
    }

    function applyJobPromptRegenerateResult(result) {
        jobPromptDialog.applyRegenerateResult(result)
    }

    function showJobFailure(job) {
        failureDialog.openFor(job)
    }

    TimeMachineFailureDialog {
        id: failureDialog
        onRetryRequested: function(jobId) {
            dialogs.failedJobRetryRequested(jobId)
        }
        onOpenFolderRequested: function(folder) {
            dialogs.failedJobFolderRequested(folder)
        }
    }

    PromptEditDialog {
        id: jobPromptDialog
        onRegenerateRequested: function(jobId, prompt, card) {
            dialogs.jobPromptRegenerateRequested(jobId)
        }
    }

    Dialog {
        id: stageDialog
        modal: true
        anchors.centerIn: parent
        width: Math.min(dialogs.width - VfTheme.dp(40), VfTheme.dp(560))
        title: "Chỉnh giai đoạn"
        header: VfDialogHeader {
            title: stageDialog.title
            compact: true
            onCloseClicked: stageDialog.close()
        }
        standardButtons: Dialog.NoButton
        property int stageIdx: -1
        property string errorText: ""

        background: Rectangle {
            color: VfTheme.surface
            radius: VfTheme.dp(10)
            border.color: VfTheme.borderStrong
        }

        contentItem: ColumnLayout {
            spacing: VfTheme.dp(9)

            Text {
                text: "TÊN STAGE"
                color: VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(9)
                font.weight: Font.Bold
            }
            TextField {
                id: stageName
                Layout.fillWidth: true
                color: VfTheme.text
                selectByMouse: true
            }
            Text {
                text: "TRẠNG THÁI NHÌN THẤY"
                color: VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(9)
                font.weight: Font.Bold
            }
            ScrollView {
                id: stageVisibleScroll
                Layout.fillWidth: true
                Layout.preferredHeight: VfTheme.dp(130)
                TextArea {
                    id: stageVisible
                    width: stageVisibleScroll.availableWidth
                    color: VfTheme.text
                    wrapMode: TextEdit.Wrap
                    selectByMouse: true
                    background: Rectangle {
                        color: VfTheme.surfaceSoft
                        border.color: VfTheme.border
                        radius: VfTheme.dp(6)
                    }
                }
            }
            DialogError { text: stageDialog.errorText }
            RowLayout {
                Layout.fillWidth: true
                Item { Layout.fillWidth: true }
                VfButton { text: "HUỶ"; onClicked: stageDialog.close() }
                VfButton {
                    text: "LƯU & TẠO LẠI CỘT"
                    onClicked: {
                        var saved = dialogs.controller.updateStage(
                            stageDialog.stageIdx,
                            stageName.text,
                            stageVisible.text
                        )
                        if (!saved || !saved.ok) {
                            stageDialog.errorText = String(
                                (saved || {}).message || "Không thể lưu stage."
                            )
                            return
                        }
                        var result = dialogs.controller.regenerateStage(stageDialog.stageIdx)
                        if (result && result.ok) {
                            stageDialog.close()
                            dialogs.actionError("")
                        } else {
                            stageDialog.errorText = String(
                                (result || {}).message || "Không thể tạo lại cột."
                            )
                        }
                    }
                }
            }
        }
    }

    Dialog {
        id: cellDialog
        modal: true
        anchors.centerIn: parent
        width: Math.min(dialogs.width - VfTheme.dp(40), VfTheme.dp(620))
        title: "Prompt bóc keyframe"
        header: VfDialogHeader {
            title: cellDialog.title
            compact: true
            onCloseClicked: cellDialog.close()
        }
        standardButtons: Dialog.NoButton
        property string viewId: ""
        property string viewLabel: ""
        property int stageIdx: -1
        property string errorText: ""

        background: Rectangle {
            color: VfTheme.surface
            radius: VfTheme.dp(10)
            border.color: VfTheme.borderStrong
        }

        contentItem: ColumnLayout {
            spacing: VfTheme.dp(9)

            Text {
                Layout.fillWidth: true
                text: cellDialog.viewLabel + " · S" + cellDialog.stageIdx
                color: VfTheme.blueText
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(11)
                font.weight: Font.Bold
            }
            Text {
                Layout.fillWidth: true
                text: "Prompt này chỉ tạo lại đúng một ảnh; hai ảnh tham chiếu vẫn được giữ nguyên."
                color: VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(8)
                wrapMode: Text.Wrap
            }
            ScrollView {
                id: cellPromptScroll
                Layout.fillWidth: true
                Layout.preferredHeight: VfTheme.dp(230)
                TextArea {
                    id: cellPrompt
                    width: cellPromptScroll.availableWidth
                    color: VfTheme.text
                    wrapMode: TextEdit.Wrap
                    selectByMouse: true
                    background: Rectangle {
                        color: VfTheme.surfaceSoft
                        border.color: VfTheme.border
                        radius: VfTheme.dp(6)
                    }
                }
            }
            DialogError { text: cellDialog.errorText }
            RowLayout {
                Layout.fillWidth: true
                Item { Layout.fillWidth: true }
                VfButton { text: "HUỶ"; onClicked: cellDialog.close() }
                VfButton {
                    text: "LƯU"
                    onClicked: {
                        var result = dialogs.controller.updateCellPrompt(
                            cellDialog.viewId,
                            cellDialog.stageIdx,
                            cellPrompt.text
                        )
                        if (result && result.ok)
                            cellDialog.close()
                        else
                            cellDialog.errorText = String(
                                (result || {}).message || "Không thể lưu prompt."
                            )
                    }
                }
                VfButton {
                    text: "LƯU & TẠO LẠI Ô"
                    onClicked: {
                        var saved = dialogs.controller.updateCellPrompt(
                            cellDialog.viewId,
                            cellDialog.stageIdx,
                            cellPrompt.text
                        )
                        if (!saved || !saved.ok) {
                            cellDialog.errorText = String(
                                (saved || {}).message || "Không thể lưu prompt."
                            )
                            return
                        }
                        var result = dialogs.controller.regenerateCell(
                            cellDialog.viewId,
                            cellDialog.stageIdx
                        )
                        if (result && result.ok) {
                            cellDialog.close()
                            dialogs.actionError("")
                        } else {
                            cellDialog.errorText = String(
                                (result || {}).message || "Không thể tạo lại ô."
                            )
                        }
                    }
                }
            }
        }
    }

    Dialog {
        id: motionDialog
        modal: true
        anchors.centerIn: parent
        width: Math.min(dialogs.width - VfTheme.dp(40), VfTheme.dp(620))
        title: "Prompt chuyển động"
        header: VfDialogHeader {
            title: motionDialog.title
            compact: true
            onCloseClicked: motionDialog.close()
        }
        standardButtons: Dialog.NoButton
        property string motionKey: ""
        property string caption: ""
        property string errorText: ""
        property bool finalReveal: false

        background: Rectangle {
            color: VfTheme.surface
            radius: VfTheme.dp(10)
            border.color: VfTheme.borderStrong
        }

        contentItem: ColumnLayout {
            spacing: VfTheme.dp(9)

            Text {
                Layout.fillWidth: true
                text: motionDialog.caption
                color: VfTheme.violetText
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(11)
                font.weight: Font.Bold
            }
            Text {
                Layout.fillWidth: true
                text: motionDialog.finalReveal
                      ? "Prompt I2V một ảnh: chỉ chuyển động camera quanh ảnh mốc hoàn chỉnh."
                      : "Mô tả chuyển động 8 giây giữa hai keyframe liền nhau."
                color: VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(8)
            }
            ScrollView {
                id: motionPromptScroll
                Layout.fillWidth: true
                Layout.preferredHeight: VfTheme.dp(210)
                TextArea {
                    id: motionPrompt
                    width: motionPromptScroll.availableWidth
                    color: VfTheme.text
                    wrapMode: TextEdit.Wrap
                    selectByMouse: true
                    background: Rectangle {
                        color: VfTheme.surfaceSoft
                        border.color: VfTheme.violetBorder
                        radius: VfTheme.dp(6)
                    }
                }
            }
            DialogError { text: motionDialog.errorText }
            RowLayout {
                Layout.fillWidth: true
                Item { Layout.fillWidth: true }
                VfButton { text: "HUỶ"; onClicked: motionDialog.close() }
                VfButton {
                    text: "LƯU"
                    onClicked: {
                        var result = dialogs.controller.updateMotionPrompt(
                            motionDialog.motionKey,
                            motionPrompt.text
                        )
                        if (result && result.ok)
                            motionDialog.close()
                        else
                            motionDialog.errorText = String(
                                (result || {}).message || "Không thể lưu prompt."
                            )
                    }
                }
                VfButton {
                    text: "LƯU & DỰNG LẠI VIDEO"
                    onClicked: {
                        var saved = dialogs.controller.updateMotionPrompt(
                            motionDialog.motionKey,
                            motionPrompt.text
                        )
                        if (!saved || !saved.ok) {
                            motionDialog.errorText = String(
                                (saved || {}).message || "Không thể lưu prompt."
                            )
                            return
                        }
                        var result = dialogs.controller.rebuildVideo()
                        if (result && result.ok) {
                            motionDialog.close()
                            dialogs.actionError("")
                        } else {
                            motionDialog.errorText = String(
                                (result || {}).message || "Không thể dựng lại video."
                            )
                        }
                    }
                }
            }
        }
    }

    Dialog {
        id: graphicsDialog
        modal: true
        anchors.centerIn: parent
        width: Math.min(dialogs.width - VfTheme.dp(32), VfTheme.dp(940))
        height: Math.min(dialogs.height - VfTheme.dp(32), VfTheme.dp(690))
        title: "Hệ thiết kế Time Graphics"
        standardButtons: Dialog.NoButton
        property string errorText: ""

        header: VfDialogHeader {
            title: graphicsDialog.title
            compact: true
            onCloseClicked: graphicsDialog.close()
        }

        background: Rectangle {
            color: VfTheme.surface
            radius: VfTheme.dp(10)
            border.color: VfTheme.borderStrong
        }

        contentItem: ColumnLayout {
            spacing: VfTheme.dp(10)

            Text {
                Layout.fillWidth: true
                text: "Preset khóa màu, font và bố cục. AI chỉ được chọn trong catalog; ngôn ngữ chữ bám theo Ngôn ngữ nội dung."
                color: VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(9)
                wrapMode: Text.Wrap
            }

            ScrollView {
                id: graphicsPresetScroll
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true

                GridLayout {
                    width: graphicsPresetScroll.availableWidth
                    columns: width < VfTheme.dp(680) ? 2 : 3
                    columnSpacing: VfTheme.dp(8)
                    rowSpacing: VfTheme.dp(8)

                    Repeater {
                        model: dialogs.controller
                               ? (dialogs.controller.options.graphics_presets || [])
                               : []
                        delegate: Rectangle {
                            id: presetCard
                            required property var modelData
                            Layout.fillWidth: true
                            Layout.preferredHeight: VfTheme.dp(112)
                            radius: VfTheme.dp(8)
                            color: String(dialogs.controller.config.graphics_preset || "auto")
                                   === String(presetCard.modelData.value || "")
                                   ? VfTheme.blueFill : VfTheme.surfaceSoft
                            border.width: String(dialogs.controller.config.graphics_preset || "auto")
                                          === String(presetCard.modelData.value || "") ? 2 : 1
                            border.color: String(dialogs.controller.config.graphics_preset || "auto")
                                          === String(presetCard.modelData.value || "")
                                          ? VfTheme.blueBorderSoft : VfTheme.border

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: VfTheme.dp(9)
                                spacing: VfTheme.dp(4)

                                RowLayout {
                                    Layout.fillWidth: true
                                    Rectangle {
                                        Layout.preferredWidth: VfTheme.dp(24)
                                        Layout.preferredHeight: VfTheme.dp(8)
                                        radius: height / 2
                                        color: "#" + String(presetCard.modelData.accent || "7C5CFC")
                                    }
                                    Text {
                                        Layout.fillWidth: true
                                        text: String(presetCard.modelData.label || "")
                                        color: VfTheme.text
                                        font.family: VfTheme.fontFamily
                                        font.pixelSize: VfTheme.dp(10)
                                        font.weight: Font.Bold
                                        elide: Text.ElideRight
                                    }
                                }
                                Text {
                                    Layout.fillWidth: true
                                    text: String(presetCard.modelData.description || "")
                                    color: VfTheme.textMuted
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.dp(8)
                                    wrapMode: Text.Wrap
                                    maximumLineCount: 2
                                    elide: Text.ElideRight
                                }
                                Text {
                                    Layout.fillWidth: true
                                    text: String(presetCard.modelData.recommended_for || "")
                                    color: VfTheme.violetText
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.dp(8)
                                    elide: Text.ElideRight
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: dialogs.controller.setOption(
                                    "graphics_preset",
                                    String(presetCard.modelData.value || "auto"))
                            }
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: VfTheme.dp(7)
                Text {
                    text: "MẬT ĐỘ"
                    color: VfTheme.textMuted
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(9)
                    font.weight: Font.Bold
                }
                Repeater {
                    model: dialogs.controller
                           ? (dialogs.controller.options.graphics_densities || [])
                           : []
                    delegate: VfButton {
                        required property var modelData
                        compact: true
                        text: String(modelData.label || "")
                        tone: String(dialogs.controller.config.graphics_density || "balanced")
                              === String(modelData.value || "")
                              ? "primary" : "neutral"
                        tooltip: String(modelData.description || "")
                        onClicked: dialogs.controller.setOption(
                            "graphics_density", String(modelData.value || "balanced"))
                    }
                }
                Item { Layout.fillWidth: true }
                VfButton {
                    compact: true
                    text: "XONG"
                    tone: "primary"
                    onClicked: graphicsDialog.close()
                }
            }
            DialogError { text: graphicsDialog.errorText }
        }
    }

    component DialogError: Text {
        Layout.fillWidth: true
        visible: String(text || "").length > 0
        color: VfTheme.redText
        font.family: VfTheme.fontFamily
        font.pixelSize: VfTheme.dp(9)
        wrapMode: Text.Wrap
    }
}
