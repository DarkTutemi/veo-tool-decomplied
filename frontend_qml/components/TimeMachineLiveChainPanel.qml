pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import "../theme"
import "MediaSourceResolver.js" as MediaSourceResolver

Rectangle {
    id: panel

    property var chainState: ({})
    property string pipelineKind: "live_window"
    property bool busy: false
    property bool portraitFrames: false
    readonly property bool constructionMode:
        pipelineKind === "construction"

    signal previewRequested(string path, string title, string status)

    readonly property int totalClips: Math.max(
        0, Number(chainState.total_clips || 0))
    readonly property int currentClip: Math.max(
        0, Number(chainState.current_clip_number || 0))
    readonly property int currentProgress: Math.max(
        0, Math.min(100, Number(chainState.current_progress || 0)))
    readonly property string currentStatus: String(
        chainState.current_status || "planned")
    readonly property string currentKind: String(
        chainState.current_kind || "transition")
    readonly property bool chainComplete:
        totalClips > 0
        && Number(chainState.completed_clips || 0) >= totalClips

    radius: VfTheme.dp(7)
    color: VfTheme.surfaceSoft
    border.color: VfTheme.cyanBorderSoft

    function stepColor(stepState) {
        var value = String(stepState || "pending")
        if (value === "completed")
            return VfTheme.greenText
        if (value === "active")
            return VfTheme.blueText
        if (value === "failed")
            return VfTheme.redText
        return VfTheme.textSubtle
    }

    function sourceLabel(source, fallback) {
        var value = String(source || "")
        if (value === "live_last_frame")
            return qsTr("LIVE START · last frame")
        if (value === "live_end")
            return qsTr("LIVE END")
        if (panel.constructionMode) {
            if (String(fallback).indexOf("END") >= 0)
                return qsTr("PEEL END")
            return qsTr("PEEL START")
        }
        return fallback
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: VfTheme.dp(8)
        spacing: VfTheme.dp(7)

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: VfTheme.dp(23)
            spacing: VfTheme.dp(5)

            Text {
                Layout.fillWidth: true
                text: panel.chainComplete
                      ? (panel.constructionMode
                         ? qsTr("PEEL START–END ĐÃ XONG")
                         : qsTr("LIVE CHAIN ĐÃ HOÀN THÀNH"))
                      : panel.currentKind === "final_reveal"
                        ? qsTr("CẢNH KẾT · JOBSTORE")
                      : panel.constructionMode
                        ? qsTr("CẶP START–END · %1 / %2")
                          .arg(panel.currentClip).arg(panel.totalClips)
                      : qsTr("ĐOẠN ĐANG XỬ LÝ · %1 / %2")
                        .arg(panel.currentClip).arg(panel.totalClips)
                color: panel.chainComplete
                       ? VfTheme.greenText : VfTheme.cyanText
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(9)
                font.weight: Font.Bold
                elide: Text.ElideRight
            }

            Rectangle {
                Layout.preferredWidth: statusText.implicitWidth + VfTheme.dp(12)
                Layout.preferredHeight: VfTheme.dp(18)
                radius: height / 2
                color: panel.currentStatus === "running"
                       ? VfTheme.blueFill
                       : panel.currentStatus === "completed"
                         ? VfTheme.greenFill
                         : panel.currentStatus === "failed"
                           ? VfTheme.redFill : VfTheme.surface
                border.color: panel.currentStatus === "running"
                              ? VfTheme.blueBorderSoft
                              : panel.currentStatus === "completed"
                                ? VfTheme.greenBorderSoft
                                : panel.currentStatus === "failed"
                                  ? VfTheme.redText : VfTheme.border
                Text {
                    id: statusText
                    anchors.centerIn: parent
                    text: panel.chainComplete
                          ? qsTr("XONG")
                          : panel.currentStatus === "preparing"
                            ? qsTr("CHUẨN BỊ")
                          : panel.currentStatus === "submitting"
                              ? qsTr("SUBMIT")
                              : panel.currentStatus === "running"
                                ? qsTr("JOBSTORE")
                                : panel.currentStatus === "failed"
                                  ? qsTr("LỖI TRƯỚC SUBMIT")
                                : qsTr("ĐANG CHỜ")
                    color: panel.currentStatus === "running"
                           ? VfTheme.blueText
                           : panel.currentStatus === "completed"
                             ? VfTheme.greenText
                             : panel.currentStatus === "failed"
                               ? VfTheme.redText : VfTheme.textMuted
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(7)
                    font.weight: Font.Bold
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: panel.portraitFrames
                                    ? VfTheme.dp(190) : VfTheme.dp(112)
            Layout.maximumHeight: Layout.preferredHeight
            spacing: VfTheme.dp(6)

            Repeater {
                model: panel.currentKind === "final_reveal"
                       ? [
                           {
                               title: qsTr("ANCHOR"),
                               source: String(
                                   panel.chainState.start_source || ""),
                               path: String(
                                   panel.chainState.start_image_path || ""),
                               fallback: qsTr("ẢNH MỐC CẢNH KẾT")
                           }
                         ]
                       : [
                    {
                        title: qsTr("START"),
                        source: String(panel.chainState.start_source || ""),
                        path: String(panel.chainState.start_image_path || ""),
                        fallback: qsTr("SEED START")
                    },
                    {
                        title: qsTr("END"),
                        source: String(panel.chainState.end_source || ""),
                        path: String(panel.chainState.end_image_path || ""),
                        fallback: qsTr("SEED END")
                    }
                         ]

                delegate: Rectangle {
                    id: plate
                    required property var modelData
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: VfTheme.dp(5)
                    color: VfTheme.surface
                    border.color: plate.modelData.path.length > 0
                                  ? VfTheme.blueBorderSoft : VfTheme.border
                    clip: true

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: VfTheme.dp(5)
                        spacing: VfTheme.dp(3)

                        Text {
                            Layout.fillWidth: true
                            text: plate.modelData.title
                            color: plate.modelData.title === qsTr("START")
                                   ? VfTheme.cyanText : VfTheme.violetText
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.dp(7)
                            font.weight: Font.Bold
                        }

                        Text {
                            Layout.fillWidth: true
                            text: panel.sourceLabel(
                                plate.modelData.source,
                                plate.modelData.fallback)
                            color: VfTheme.textMuted
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.dp(6)
                            font.weight: Font.DemiBold
                            elide: Text.ElideRight
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            radius: VfTheme.dp(4)
                            color: VfTheme.surfaceSoft
                            clip: true

                            Image {
                                anchors.fill: parent
                                source: MediaSourceResolver.localFileUrl(
                                            plate.modelData.path)
                                fillMode: Image.PreserveAspectCrop
                                asynchronous: true
                                cache: false
                                sourceSize.width: width
                                sourceSize.height: height
                                visible: plate.modelData.path.length > 0
                            }

                            Text {
                                anchors.centerIn: parent
                                visible: plate.modelData.path.length === 0
                                text: panel.constructionMode
                                      ? qsTr("CHỜ PEEL")
                                      : qsTr("CHỜ LIVE-CHAIN")
                                color: VfTheme.textSubtle
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.dp(6)
                                font.weight: Font.Bold
                            }

                            MouseArea {
                                anchors.fill: parent
                                enabled: plate.modelData.path.length > 0
                                cursorShape: enabled
                                             ? Qt.PointingHandCursor : Qt.ArrowCursor
                                onClicked: panel.previewRequested(
                                    plate.modelData.path,
                                    plate.modelData.title,
                                    panel.currentStatus)
                            }
                        }
                    }
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: VfTheme.dp(4)

            Repeater {
                model: panel.chainState.cycle_steps || []

                delegate: Rectangle {
                    id: cycleRow
                    required property int index
                    required property var modelData
                    Layout.fillWidth: true
                    Layout.preferredHeight: VfTheme.dp(28)
                    radius: VfTheme.dp(5)
                    color: String(cycleRow.modelData.state || "") === "active"
                           ? VfTheme.blueFill
                           : String(cycleRow.modelData.state || "") === "completed"
                             ? VfTheme.greenFill : VfTheme.surface
                    border.color: String(cycleRow.modelData.state || "") === "active"
                                  ? VfTheme.blueBorderSoft
                                  : String(cycleRow.modelData.state || "") === "completed"
                                    ? VfTheme.greenBorderSoft : VfTheme.border

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: VfTheme.dp(6)
                        anchors.rightMargin: VfTheme.dp(6)
                        spacing: VfTheme.dp(6)

                        Rectangle {
                            Layout.preferredWidth: VfTheme.dp(16)
                            Layout.preferredHeight: width
                            radius: width / 2
                            color: panel.stepColor(cycleRow.modelData.state)
                            Text {
                                anchors.centerIn: parent
                                text: String(cycleRow.modelData.state || "")
                                      === "completed" ? "✓" : cycleRow.index + 1
                                color: String(cycleRow.modelData.state || "")
                                       === "completed" ? VfTheme.surface : "white"
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.dp(7)
                                font.weight: Font.Bold
                            }
                        }

                        Text {
                            Layout.fillWidth: true
                            text: String(cycleRow.modelData.label || "")
                            color: panel.stepColor(cycleRow.modelData.state)
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.dp(7)
                            font.weight: Font.DemiBold
                            elide: Text.ElideRight
                        }

                        Text {
                            visible: String(cycleRow.modelData.key || "") === "render"
                                     && panel.currentStatus === "running"
                            text: panel.currentProgress + "%"
                            color: VfTheme.blueText
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.dp(7)
                            font.weight: Font.Bold
                        }
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: VfTheme.dp(7)
            radius: height / 2
            color: VfTheme.surface
            border.color: VfTheme.border
            clip: true

            Rectangle {
                width: parent.width * Math.max(
                    0, Math.min(
                        100,
                        Number(panel.chainState.overall_percent || 0))) / 100
                height: parent.height
                radius: height / 2
                color: VfTheme.primary
            }
        }

        Text {
            Layout.fillWidth: true
            text: String(panel.chainState.current_job_id || "").length > 0
                  ? qsTr("JobStore: %1").arg(
                        String(panel.chainState.current_job_id).slice(-18))
                  : qsTr("Workspace sẽ submit đúng một child job khi cặp ảnh sẵn sàng.")
            color: VfTheme.textSubtle
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.dp(6)
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideMiddle
        }

        Item { Layout.fillHeight: true }
    }
}
