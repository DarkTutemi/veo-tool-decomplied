import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../theme"

Rectangle {
    id: root

    property var job: ({})
    property bool selected: false
    property bool showActions: false
    property bool clickable: !showActions

    signal clicked()
    signal restoreRequested()
    signal folderRequested()
    signal deleteRequested()

    readonly property string sourceText: String(job.tabLabel || job.tab_label || "")
    readonly property string typeText: String(job.typeLabel || "")
    readonly property string statusText: String(job.statusLabel || job.status || "")
    readonly property string statusBucket: String(job.statusBucket || "processing")
    readonly property string contextText: String(job.contextLabel || "")
    readonly property string titleText: String(job.title || job.job_id || "Untitled job")
    readonly property string secondaryText: String(job.secondaryText || "")
    readonly property string dateText: String(job.savedLabel || "")
    readonly property string thumbnailSource: String(job.thumbnail || job.thumbnail_url || "")
    readonly property string folderPath: String(job.outputFolder || job.output_dir || job.folder || "")
    readonly property int sceneCount: Number(job.sceneCount || job.scene_count || 0)
    readonly property int videoCount: Number(job.videoCount || job.video_count || 0)
    readonly property int failedCount: Number(job.failedCount || job.failed_count || 0)
    readonly property int jobProgress: Math.max(0, Math.min(100, Number(job.jobProgress || job.job_progress || 0)))
    readonly property string countsText: {
        var parts = []
        if (sceneCount > 0)
            parts.push(String(sceneCount) + " scene")
        if (videoCount > 0)
            parts.push("✓ " + String(videoCount))
        if (failedCount > 0)
            parts.push("✗ " + String(failedCount))
        return parts.join(" · ")
    }

    implicitHeight: VfTheme.dp(72)
    radius: VfTheme.dp(8)
    color: selected ? VfTheme.blueFill : VfTheme.surface
    border.color: selected ? VfTheme.primary : VfTheme.border
    border.width: 1

    function statusFill(bucket) {
        if (bucket === "completed") return VfTheme.greenFill
        if (bucket === "failed") return VfTheme.redFill
        return VfTheme.blueFill
    }

    function statusTone(bucket) {
        if (bucket === "completed") return VfTheme.greenText
        if (bucket === "failed") return VfTheme.redText
        return VfTheme.primary
    }

    function sourceFill(source) {
        if (source === "master_prompt") return VfTheme.violetFill
        if (source === "clone_video") return VfTheme.greenFill
        if (source === "transcript_video") return VfTheme.cyanFill
        if (source === "batch_image_generation") return VfTheme.amberFill
        if (source === "affiliate_video") return VfTheme.pinkFill
        if (source === "deep_research") return VfTheme.violetFill
        if (source === "voice_studio") return VfTheme.indigoFill
        return VfTheme.violetFill
    }

    function sourceTone(source) {
        if (source === "master_prompt") return VfTheme.violetText
        if (source === "clone_video") return VfTheme.greenText
        if (source === "transcript_video") return VfTheme.cyanText
        if (source === "batch_image_generation") return VfTheme.amberText
        if (source === "affiliate_video") return VfTheme.redText
        if (source === "deep_research") return "#7C3AED"
        if (source === "voice_studio") return VfTheme.indigoText
        return VfTheme.primary
    }

    component Pill: Rectangle {
        property string label: ""
        property color labelColor: VfTheme.text
        property color fill: VfTheme.surfaceSoft
        property color stroke: "transparent"

        implicitWidth: pillText.implicitWidth + VfTheme.dp(12)
        implicitHeight: pillText.implicitHeight + VfTheme.dp(4)
        radius: VfTheme.dp(4)
        color: fill
        border.color: stroke
        border.width: stroke === "transparent" ? 0 : 1

        Text {
            id: pillText
            anchors.centerIn: parent
            text: parent.label
            color: parent.labelColor
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.dp(10)
            font.weight: Font.DemiBold
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: VfTheme.dp(10)
        spacing: VfTheme.dp(10)

        // ─── Left badges column (Source + Status stacked) ────────────
        ColumnLayout {
            Layout.preferredWidth: VfTheme.dp(96)
            Layout.fillHeight: false
            Layout.alignment: Qt.AlignTop
            spacing: VfTheme.dp(3)

            Pill {
                Layout.alignment: Qt.AlignLeft
                label: root.statusText.toUpperCase()
                fill: root.statusFill(root.statusBucket)
                labelColor: root.statusTone(root.statusBucket)
                visible: root.statusText.length > 0
            }

            Pill {
                Layout.alignment: Qt.AlignLeft
                label: root.typeText
                fill: VfTheme.surface
                stroke: VfTheme.borderStrong
                labelColor: VfTheme.textMuted
                visible: root.typeText.length > 0
            }

            Text {
                Layout.alignment: Qt.AlignLeft
                visible: root.thumbnailSource.length === 0
                text: "NO PREVIEW"
                color: VfTheme.textSubtle
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(9)
                font.weight: Font.DemiBold
            }
        }

        // ─── Middle content (Source label + title + secondary) ─────
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: VfTheme.dp(2)

            RowLayout {
                Layout.fillWidth: true
                spacing: VfTheme.dp(6)

                Pill {
                    label: root.sourceText
                    fill: root.sourceFill(String(root.job.tabSource || root.job.tab_source || ""))
                    labelColor: root.sourceTone(String(root.job.tabSource || root.job.tab_source || ""))
                    visible: root.sourceText.length > 0
                }

                Text {
                    Layout.fillWidth: true
                    text: root.contextText
                    visible: text.length > 0
                    color: VfTheme.textSubtle
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(10)
                    elide: Text.ElideRight
                }
            }

            Text {
                Layout.fillWidth: true
                text: root.titleText
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(13)
                font.weight: Font.DemiBold
                elide: Text.ElideRight
                maximumLineCount: 1
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: VfTheme.dp(6)

                Text {
                    text: root.countsText
                    visible: text.length > 0
                    color: VfTheme.textMuted
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(10)
                    font.weight: Font.DemiBold
                }

                Text {
                    Layout.fillWidth: true
                    text: root.secondaryText
                    visible: text.length > 0
                    color: root.statusBucket === "failed" ? VfTheme.redText : VfTheme.textSubtle
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(10)
                    elide: Text.ElideRight
                }
            }
        }

        // ─── Right date column ──────────────────────────────────────
        Text {
            Layout.alignment: Qt.AlignTop | Qt.AlignRight
            text: root.dateText
            visible: text.length > 0
            color: VfTheme.textSubtle
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.dp(10)
            horizontalAlignment: Text.AlignRight
        }

        // ─── Optional action buttons ───────────────────────────────
        ColumnLayout {
            Layout.preferredWidth: VfTheme.dp(82)
            Layout.fillHeight: true
            spacing: VfTheme.dp(4)
            visible: root.showActions

            VfButton {
                Layout.fillWidth: true
                text: "Restore"
                implicitHeight: VfTheme.dp(26)
                onClicked: root.restoreRequested()
            }

            VfButton {
                Layout.fillWidth: true
                text: "Folder"
                implicitHeight: VfTheme.dp(26)
                enabled: root.folderPath.length > 0
                onClicked: root.folderRequested()
            }

            VfButton {
                Layout.fillWidth: true
                text: "Delete"
                tone: "danger"
                implicitHeight: VfTheme.dp(26)
                onClicked: root.deleteRequested()
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        enabled: root.clickable
        hoverEnabled: enabled
        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: root.clicked()
    }
}
