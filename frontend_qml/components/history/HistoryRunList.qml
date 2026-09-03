pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../../theme"

Rectangle {
    id: root

    required property var runModel
    property string selectedRunId: ""
    property var stats: ({})
    property bool loading: false
    property bool canLoadMore: false

    signal runSelected(string runId)
    signal loadMoreRequested()

    color: VfTheme.surfaceSoft
    border.color: VfTheme.borderSoft
    clip: true

    function sourceSummary() {
        var counts = root.stats.sourceCounts || ({})
        var labels = {
            "master_prompt": "Master",
            "clone_video": "Clone",
            "transcript_video": "Audio → Video",
            "affiliate_video": "Affiliate",
            "timemachine_panel": "TimeMachine",
            "normal_panel": "Normal",
            "batch_image_generation": "Batch Image",
            "extend_panel": "Extend",
            "deep_research": "Research",
            "voice_studio": "Voice Studio",
            "reupscale": "Re-upscale"
        }
        var parts = []
        for (var key in counts) {
            if (Number(counts[key] || 0) <= 0)
                continue
            parts.push(String(labels[key] || key) + " " + String(counts[key]))
            if (parts.length >= 5)
                break
        }
        return parts.join(" · ")
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: VfTheme.dp(7)
        spacing: VfTheme.dp(5)

        ColumnLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: VfTheme.dp(34)
            spacing: VfTheme.dp(1)

            Text {
                Layout.fillWidth: true
                text: {
                    var s = root.stats || ({})
                    var parts = [String(Number(s.total || 0)) + " job tổng"]
                    if (Number(s.completed || 0) > 0)
                        parts.push("✓ " + String(s.completed))
                    if (Number(s.failed || 0) > 0)
                        parts.push("✗ " + String(s.failed))
                    if (Number(s.running || 0) > 0)
                        parts.push(String(s.running) + " đang chạy")
                    return parts.join(" · ")
                }
                color: VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(10)
                font.weight: Font.DemiBold
                elide: Text.ElideRight
            }

            Text {
                Layout.fillWidth: true
                text: root.sourceSummary()
                color: VfTheme.textSubtle
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(9)
                elide: Text.ElideRight
            }
        }

        ListView {
            id: runList

            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: VfTheme.dp(5)
            clip: true
            reuseItems: true
            cacheBuffer: Math.max(0, height * 2)
            model: root.runModel

            delegate: HistoryRunCard {
                required property var modelData

                width: runList.width
                row: modelData
                selected: String(row.runId || "") === root.selectedRunId
                onClicked: root.runSelected(String(row.runId || ""))
            }

            onMovementEnded: {
                if (root.canLoadMore && contentY + height >= contentHeight - 180)
                    root.loadMoreRequested()
            }
        }

        Text {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: runList.count === 0 && !root.loading
            text: "Không tìm thấy lịch sử phù hợp."
            color: VfTheme.textSubtle
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.fontControl
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        BusyIndicator {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: VfTheme.dp(24)
            Layout.preferredHeight: VfTheme.dp(24)
            running: root.loading
            visible: running
        }
    }
}
