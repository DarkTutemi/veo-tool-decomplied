import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../components"
import "../theme"

Dialog {
    id: root
    objectName: "timeMachineFailureDialog"
    parent: Overlay.overlay

    property var jobData: ({})
    property bool technicalExpanded: false

    readonly property string jobId: String(jobData.id || "")
    readonly property string friendlyMessage: String(
        jobData.message
        || "Time Machine chưa thể hoàn tất bước hiện tại.")
    readonly property string technicalMessage: String(
        jobData.technical_error || jobData.message || "")
    readonly property string stoppedStep: {
        var step = String(jobData.pipeline_step_label || "").trim()
        if (step.length > 0)
            return step
        var phase = String(jobData.phase_label || "").trim()
        if (phase.length > 0 && phase.indexOf("LỖI") < 0)
            return phase
        return "Chuẩn bị clip"
    }
    readonly property string errorCode: String(jobData.error_code || "")
    readonly property string errorPath: String(jobData.error_path || "")
    readonly property string workFolder: String(jobData.work_dir || "")
    readonly property bool canRetry: Boolean(jobData.repairable)
    readonly property bool hasTechnicalDetail: {
        var technical = root.technicalMessage.trim()
        var friendly = root.friendlyMessage.trim()
        return technical.length > 0 && technical !== friendly
    }

    signal retryRequested(string jobId)
    signal openFolderRequested(string folder)

    function openFor(job) {
        var candidate = job || ({})
        if (String(candidate.status || "") !== "failed")
            return
        root.jobData = candidate
        root.technicalExpanded = false
        if (!root.visible)
            root.open()
    }

    modal: true
    closePolicy: Popup.CloseOnEscape
    standardButtons: Dialog.NoButton
    padding: 0
    leftPadding: VfTheme.dp(18)
    rightPadding: VfTheme.dp(18)
    topPadding: VfTheme.dp(14)
    bottomPadding: VfTheme.dp(14)
    width: VfDialogMetrics.width(parent, VfTheme.dp(640), VfTheme.dp(40))
    height: VfDialogMetrics.height(
        parent,
        technicalExpanded ? VfTheme.dp(560) : VfTheme.dp(420),
        VfTheme.dp(40))
    x: VfDialogMetrics.centerX(parent, width)
    y: VfDialogMetrics.centerY(parent, height)

    header: VfDialogHeader {
        title: "TIME MACHINE CHƯA THỂ TIẾP TỤC"
        subtitle: "Job đã dừng an toàn trước bước tạo tài nguyên tiếp theo"
        iconName: "red-triangle"
        onCloseClicked: root.close()
    }

    background: Rectangle {
        color: VfTheme.surface
        radius: VfTheme.radiusPanel
        border.color: VfTheme.redBorderSoft
        border.width: 1
    }

    // Do not anchors.fill the dialog: Qt places contentItem under the header.
    // Filling the whole Dialog draws the error card through the title bar and
    // clips the first wrapped line of the message.
    contentItem: ColumnLayout {
        spacing: VfTheme.dp(12)

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: messageColumn.implicitHeight + VfTheme.dp(24)
            Layout.preferredHeight: implicitHeight
            radius: VfTheme.radiusControl
            color: VfTheme.redFill
            border.color: VfTheme.redBorderSoft
            clip: false

            ColumnLayout {
                id: messageColumn
                width: parent.width - VfTheme.dp(24)
                x: VfTheme.dp(12)
                y: VfTheme.dp(12)
                spacing: VfTheme.dp(8)

                Text {
                    Layout.fillWidth: true
                    text: root.friendlyMessage
                    color: VfTheme.redText
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.fontBody
                    font.weight: Font.DemiBold
                    wrapMode: Text.Wrap
                }

                Text {
                    Layout.fillWidth: true
                    visible: root.hasTechnicalDetail
                    text: root.technicalMessage
                    color: VfTheme.textMuted
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.fontSmall
                    wrapMode: Text.Wrap
                    maximumLineCount: 5
                    elide: Text.ElideRight
                }
            }
        }

        GridLayout {
            Layout.fillWidth: true
            columns: 2
            columnSpacing: VfTheme.dp(10)
            rowSpacing: VfTheme.dp(6)

            Text {
                text: "BƯỚC DỪNG"
                color: VfTheme.textSubtle
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontTiny
                font.weight: Font.Bold
            }
            Text {
                Layout.fillWidth: true
                text: root.stoppedStep
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontSmall
                wrapMode: Text.Wrap
            }
            Text {
                visible: root.errorCode.length > 0
                text: "MÃ KIỂM TRA"
                color: VfTheme.textSubtle
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontTiny
                font.weight: Font.Bold
            }
            Text {
                visible: root.errorCode.length > 0
                Layout.fillWidth: true
                text: root.errorCode
                color: VfTheme.textMuted
                font.family: "Consolas"
                font.pixelSize: VfTheme.fontSmall
                wrapMode: Text.Wrap
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: root.technicalExpanded
            Layout.preferredHeight: root.technicalExpanded ? VfTheme.dp(120) : 0
            visible: root.technicalExpanded
            radius: VfTheme.radiusControl
            color: VfTheme.surfaceSoft
            border.color: VfTheme.borderBox
            clip: true

            ScrollView {
                anchors.fill: parent
                anchors.margins: VfTheme.dp(8)

                TextArea {
                    readOnly: true
                    selectByMouse: true
                    wrapMode: TextEdit.Wrap
                    text: root.technicalMessage
                          + (root.errorPath.length > 0
                             ? "\n\nPath: " + root.errorPath : "")
                    color: VfTheme.textMuted
                    font.family: "Consolas"
                    font.pixelSize: VfTheme.fontTiny
                    background: null
                }
            }
        }

        Item { Layout.fillHeight: true }
    }

    footer: Rectangle {
        implicitHeight: VfTheme.dp(56)
        color: "transparent"

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: VfTheme.dp(18)
            anchors.rightMargin: VfTheme.dp(18)
            anchors.bottomMargin: VfTheme.dp(8)
            spacing: VfTheme.dp(8)

            VfButton {
                text: root.technicalExpanded
                      ? "ẨN CHI TIẾT KỸ THUẬT" : "CHI TIẾT KỸ THUẬT"
                compact: true
                minWidth: VfTheme.dp(154)
                onClicked: root.technicalExpanded = !root.technicalExpanded
            }

            VfButton {
                visible: root.workFolder.length > 0
                text: "MỞ THƯ MỤC JOB"
                compact: true
                minWidth: VfTheme.dp(126)
                onClicked: root.openFolderRequested(root.workFolder)
            }

            Item { Layout.fillWidth: true }

            VfButton {
                text: "ĐÓNG"
                compact: true
                minWidth: VfTheme.dp(86)
                onClicked: root.close()
            }

            VfButton {
                visible: root.canRetry
                text: "THỬ LẠI"
                tone: "primary"
                compact: true
                minWidth: VfTheme.dp(104)
                onClicked: {
                    var failedJobId = root.jobId
                    root.close()
                    root.retryRequested(failedJobId)
                }
            }
        }
    }
}
