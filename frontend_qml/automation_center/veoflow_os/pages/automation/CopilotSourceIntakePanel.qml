pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Layouts
import "../.."
import "../../foundation" as Foundation

Rectangle {
    id: root
    objectName: "copilotSourceIntakePanel"
    color: Theme.panel
    radius: Theme.radiusMedium
    border.width: 1
    border.color: Theme.borderSoft
    Accessible.role: Accessible.Pane
    Accessible.name: "Nạp nguồn sản xuất cho Channel Copilot"

    property var controlPlaneBridge: null
    property var sourceModel: null
    property bool hasProject: false
    property bool actionBusy: false
    property string feedbackMessage: ""
    property string titleText: "Nguồn sản xuất"
    property string subtitleText: "AI nhận text và metadata tối thiểu; file, URL thực thi và product ID giữ trong Tool 1."
    property string listTitleText: "Nguồn của dự án"
    property string emptyText: "Chưa có nguồn. Nạp ý tưởng, kịch bản, link, audio, video hoặc sản phẩm đã chuẩn bị ở cột bên trái."
    property string actionText: "Nạp và xác minh nguồn"
    property bool closeVisible: true

    signal closeRequested()
    signal importRequested(var sources)

    readonly property var selectedMode: sourceModePicker.currentIndex >= 0
        ? sourceModes.get(sourceModePicker.currentIndex) : ({})
    readonly property string selectedInputMode: String(
        root.selectedMode.inputMode || "idea")
    readonly property bool usesFiles: ["local_video", "audio_file"].indexOf(
        root.selectedInputMode) >= 0
    readonly property int sourceCount: Number(root.sourceModel
        ? root.sourceModel.count || 0 : 0)
    readonly property bool hasPendingInput: root.usesFiles
        ? selectedFileModel.count > 0 : batchInput.text.trim().length > 0

    ListModel {
        id: sourceModes
        ListElement { label: "Ý tưởng → Master Prompt"; workflow: "master"; inputMode: "idea" }
        ListElement { label: "Kịch bản → Master Prompt"; workflow: "master"; inputMode: "script" }
        ListElement { label: "Link video → Clone Video"; workflow: "clone"; inputMode: "video_url" }
        ListElement { label: "Video cục bộ → Clone Video"; workflow: "clone"; inputMode: "local_video" }
        ListElement { label: "Văn bản / lời thoại → Audio to Video"; workflow: "transcript"; inputMode: "text" }
        ListElement { label: "Link audio → Audio to Video"; workflow: "transcript"; inputMode: "audio_url" }
        ListElement { label: "Audio cục bộ → Audio to Video"; workflow: "transcript"; inputMode: "audio_file" }
        ListElement { label: "Sản phẩm đã chuẩn bị → Affiliate"; workflow: "affiliate"; inputMode: "prepared_product" }
        ListElement { label: "Ý tưởng → Time Machine"; workflow: "timemachine"; inputMode: "idea" }
    }

    ListModel { id: selectedFileModel }

    function currentRows(): var {
        const rows = []
        const workflow = String(root.selectedMode.workflow || "master")
        const inputMode = root.selectedInputMode
        if (root.usesFiles) {
            for (let index = 0; index < selectedFileModel.count; ++index) {
                const row = selectedFileModel.get(index)
                rows.push({
                    "workflow": workflow,
                    "input_mode": inputMode,
                    "content": String(row.filePath || "")
                })
            }
            return rows
        }
        const raw = batchInput.text.replace(/\r\n/g, "\n").trim()
        if (!raw) return rows
        let chunks = []
        if (["script", "text"].indexOf(inputMode) >= 0
                && /\n\s*---\s*\n/.test(raw)) {
            chunks = raw.split(/\n\s*---\s*\n/)
        } else {
            chunks = raw.split("\n")
        }
        for (let index = 0; index < chunks.length; ++index) {
            const content = String(chunks[index] || "").trim()
            if (!content) continue
            rows.push({
                "workflow": workflow,
                "input_mode": inputMode,
                "content": content
            })
        }
        return rows
    }

    function submitSources(): void {
        if (!root.hasProject || root.actionBusy) return
        const rows = root.currentRows()
        if (!rows.length) return
        root.importRequested(rows)
    }

    function finishImport(ok): void {
        if (!ok) return
        batchInput.clear()
        selectedFileModel.clear()
    }

    function chooseFiles(): void {
        sourceFileDialog.nameFilters = root.selectedInputMode === "audio_file"
            ? ["Âm thanh (*.m4a *.mp3 *.ogg *.wav)"]
            : ["Video (*.3gpp *.avi *.flv *.mkv *.mov *.mp4 *.mpeg *.mpg *.webm *.wmv)"]
        sourceFileDialog.open()
    }

    FileDialog {
        id: sourceFileDialog
        title: root.selectedInputMode === "audio_file"
            ? "Chọn nhiều tệp âm thanh" : "Chọn nhiều video nguồn"
        fileMode: FileDialog.OpenFiles
        onAccepted: {
            selectedFileModel.clear()
            for (let index = 0; index < sourceFileDialog.selectedFiles.length; ++index) {
                const path = root.controlPlaneBridge
                    ? root.controlPlaneBridge.localPath(
                        sourceFileDialog.selectedFiles[index]) : ""
                if (path) selectedFileModel.append({"filePath": path})
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 10

        RowLayout {
            Layout.fillWidth: true
            spacing: 8
            UiIcon {
                objectName: "copilotSourcePanelIcon"
                name: "ui/paperclip"
                tone: Theme.accent
                iconSize: 18
                Layout.preferredWidth: 18
                Layout.preferredHeight: 18
            }
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 1
                Text {
                    Layout.fillWidth: true
                    text: root.titleText
                    color: Theme.text
                    font.pixelSize: Theme.fontSection
                    font.weight: Font.DemiBold
                    elide: Text.ElideRight
                }
                Text {
                    Layout.fillWidth: true
                    text: root.subtitleText
                    color: Theme.textFaint
                    font.pixelSize: Theme.fontMetadata
                    elide: Text.ElideRight
                }
            }
            Foundation.StatusPill {
                text: String(root.sourceCount) + " nguồn"
                tone: root.sourceCount > 0 ? Theme.success : Theme.textMuted
            }
            AppButton {
                objectName: "copilotSourceCloseButton"
                text: "Đóng"
                leadingIcon: "ui/close"
                subtle: true
                implicitHeight: 30
                visible: root.closeVisible
                onClicked: root.closeRequested()
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: Theme.borderSoft
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 10

            Rectangle {
                Layout.preferredWidth: root.width < 680
                    ? Math.max(210, Math.round((root.width - 34) * 0.44))
                    : 312
                Layout.fillHeight: true
                radius: Theme.radiusSmall
                color: Theme.elevated
                border.width: 1
                border.color: Theme.borderSoft

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 8

                    Text {
                        Layout.fillWidth: true
                        text: "1. Chọn tuyến sản xuất"
                        color: Theme.text
                        font.pixelSize: Theme.fontBody
                        font.weight: Font.DemiBold
                    }
                    WorkflowComboBox {
                        id: sourceModePicker
                        objectName: "copilotSourceModePicker"
                        Layout.fillWidth: true
                        model: sourceModes
                        textRole: "label"
                        valueRole: "inputMode"
                        currentIndex: 0
                        enabled: root.hasProject && !root.actionBusy
                    }

                    Text {
                        Layout.fillWidth: true
                        text: root.usesFiles
                            ? "2. Chọn tệp từ máy"
                            : "2. Mỗi dòng là một mục. Với kịch bản nhiều dòng, ngăn cách bằng dòng ---"
                        color: Theme.textMuted
                        font.pixelSize: Theme.fontMetadata
                        wrapMode: Text.Wrap
                    }

                    TextArea {
                        id: batchInput
                        objectName: "copilotSourceBatchInput"
                        visible: !root.usesFiles
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.minimumHeight: 120
                        enabled: root.hasProject && !root.actionBusy
                        placeholderText: root.selectedInputMode === "video_url"
                            ? "https://youtube.com/watch?v=...\nhttps://tiktok.com/@.../video/..."
                            : root.selectedInputMode === "audio_url"
                            ? "https://.../audio.mp3"
                            : root.selectedInputMode === "prepared_product"
                            ? "product_id_001\nproduct_id_002"
                            : "Nhập hoặc dán hàng loạt nội dung…"
                        color: Theme.text
                        placeholderTextColor: Theme.textFaint
                        selectionColor: Theme.accent
                        selectedTextColor: "white"
                        font.pixelSize: Theme.fontBody
                        wrapMode: TextArea.Wrap
                        leftPadding: 10
                        rightPadding: 10
                        topPadding: 9
                        bottomPadding: 9
                        activeFocusOnTab: true
                        background: Rectangle {
                            radius: Theme.radiusSmall
                            color: Theme.panel
                            border.width: 1
                            border.color: batchInput.activeFocus
                                ? Theme.accent : Theme.borderSoft
                        }
                    }

                    ColumnLayout {
                        visible: root.usesFiles
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: 7
                        AppButton {
                            objectName: "copilotChooseSourceFilesButton"
                            Layout.fillWidth: true
                            text: selectedFileModel.count > 0
                                ? "Chọn lại tệp" : "Chọn nhiều tệp"
                            leadingIcon: "ui/folder"
                            enabled: root.hasProject && !root.actionBusy
                            onClicked: root.chooseFiles()
                        }
                        ListView {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true
                            reuseItems: true
                            boundsBehavior: Flickable.StopAtBounds
                            model: selectedFileModel
                            spacing: 4
                            delegate: Rectangle {
                                id: fileRow
                                required property string filePath
                                width: ListView.view ? ListView.view.width : 280
                                height: 34
                                radius: Theme.radiusSmall
                                color: Theme.panel
                                border.width: 1
                                border.color: Theme.borderSoft
                                Text {
                                    anchors.fill: parent
                                    anchors.leftMargin: 8
                                    anchors.rightMargin: 8
                                    text: fileRow.filePath
                                    color: Theme.textMuted
                                    font.pixelSize: Theme.fontMetadata
                                    verticalAlignment: Text.AlignVCenter
                                    elide: Text.ElideMiddle
                                }
                            }
                        }
                    }

                    Text {
                        visible: root.feedbackMessage.length > 0
                        Layout.fillWidth: true
                        text: root.feedbackMessage
                        color: Theme.textMuted
                        font.pixelSize: Theme.fontMetadata
                        wrapMode: Text.Wrap
                        maximumLineCount: 2
                        elide: Text.ElideRight
                    }

                    AppButton {
                        objectName: "copilotImportSourcesButton"
                        Layout.fillWidth: true
                        text: root.actionBusy
                            ? (root.width < 680 ? "Đang nạp…" : "Đang xác minh…")
                            : (root.width < 680 ? "Nạp nguồn" : root.actionText)
                        leadingIcon: "semantic/upload-cloud"
                        primary: true
                        enabled: root.hasProject && root.hasPendingInput
                            && !root.actionBusy
                        onClicked: root.submitSources()
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 7

                RowLayout {
                    id: sourceListHeader
                    Layout.fillWidth: true
                    Text {
                        Layout.fillWidth: true
                        text: root.listTitleText
                        color: Theme.text
                        font.pixelSize: Theme.fontBody
                        font.weight: Font.DemiBold
                    }
                    Text {
                        visible: sourceList.width >= 390
                        Layout.maximumWidth: Math.max(0,
                            sourceListHeader.width - 130)
                        text: "Không tự cào kênh · không server trung gian"
                        color: Theme.textFaint
                        font.pixelSize: Theme.fontMetadata
                        elide: Text.ElideRight
                    }
                }

                ListView {
                    id: sourceList
                    objectName: "copilotSourceList"
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    reuseItems: true
                    spacing: 5
                    boundsBehavior: Flickable.StopAtBounds
                    model: root.sourceModel
                    ScrollBar.vertical: ScrollBar {}

                    delegate: Rectangle {
                        id: sourceRow
                        required property var modelData
                        readonly property bool ready: String(
                            sourceRow.modelData.status || "") === "ready"
                        width: ListView.view ? ListView.view.width : 420
                        height: 58
                        radius: Theme.radiusSmall
                        color: Theme.elevated
                        border.width: 1
                        border.color: sourceRow.ready
                            ? Theme.borderSoft : Theme.warning

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 9
                            anchors.rightMargin: 9
                            spacing: 8
                            Rectangle {
                                Layout.preferredWidth: 30
                                Layout.preferredHeight: 30
                                radius: 15
                                color: sourceRow.ready
                                    ? Theme.successSoft : Theme.warningSoft
                                UiIcon {
                                    anchors.centerIn: parent
                                    name: sourceRow.ready
                                        ? "ui/check" : "semantic/alert-triangle"
                                    tone: sourceRow.ready
                                        ? Theme.success : Theme.warning
                                    iconSize: 15
                                }
                            }
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2
                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 7
                                    Text {
                                        Layout.fillWidth: true
                                        text: String(sourceRow.modelData.title || "Nguồn")
                                        color: Theme.text
                                        font.pixelSize: Theme.fontBody
                                        font.weight: Font.DemiBold
                                        elide: Text.ElideRight
                                    }
                                    Text {
                                        visible: sourceList.width >= 390
                                        text: String(sourceRow.modelData.workflowLabel || "")
                                            + " · "
                                            + String(sourceRow.modelData.inputModeLabel || "")
                                        color: Theme.accent
                                        font.pixelSize: Theme.fontMetadata
                                    }
                                }
                                Text {
                                    Layout.fillWidth: true
                                    text: sourceRow.ready
                                        ? String(sourceRow.modelData.content || "")
                                        : String(sourceRow.modelData.errorMessage || "Nguồn chưa hợp lệ")
                                    color: sourceRow.ready
                                        ? Theme.textFaint : Theme.warning
                                    font.pixelSize: Theme.fontMetadata
                                    elide: Text.ElideMiddle
                                }
                            }
                            Foundation.StatusPill {
                                visible: sourceList.width >= 330
                                text: String(sourceRow.modelData.statusLabel
                                    || (sourceRow.ready ? "Sẵn sàng" : "Nguồn lỗi"))
                                tone: sourceRow.ready ? Theme.success : Theme.warning
                            }
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        visible: !root.sourceModel || root.sourceCount === 0
                        width: Math.min(parent.width - 30, 420)
                        text: root.emptyText
                        color: Theme.textMuted
                        font.pixelSize: Theme.fontBody
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.Wrap
                    }
                }
            }
        }
    }
}
