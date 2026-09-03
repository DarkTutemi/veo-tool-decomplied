pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import ".."
import "../../theme"

Rectangle {
    id: root

    property var detail: ({})
    required property var itemModel
    property bool loading: false
    property bool actionsLocked: true
    property bool compact: false

    signal backRequested()
    signal actionRequested(string actionId)
    signal itemActionRequested(string itemId, string actionId)
    signal openArtifactRequested(string target)

    readonly property var summary: detail.summary || ({})
    readonly property var capabilities: detail.capabilities || ({})
    readonly property var counts: summary.sceneCounts || ({})
    readonly property var runArtifacts: detail.runArtifacts || []
    readonly property var libraryAssets: detail.libraryAssets || []

    color: VfTheme.surface
    border.color: VfTheme.borderSoft
    clip: true

    function statusColor(bucket) {
        if (bucket === "completed") return VfTheme.greenText
        if (bucket === "failed") return VfTheme.redText
        if (bucket === "needs_attention" || bucket === "interrupted")
            return VfTheme.amberText
        return VfTheme.primary
    }

    function statusFill(bucket) {
        if (bucket === "completed") return VfTheme.greenFill
        if (bucket === "failed") return VfTheme.redFill
        if (bucket === "needs_attention" || bucket === "interrupted")
            return VfTheme.amberFill
        return VfTheme.blueFill
    }

    component CountChip: Rectangle {
        id: countChip

        required property string label
        required property string value
        property color accent: VfTheme.text

        implicitWidth: chipRow.implicitWidth + VfTheme.dp(14)
        implicitHeight: VfTheme.dp(24)
        radius: VfTheme.dp(6)
        color: VfTheme.surfaceSoft
        border.color: VfTheme.borderSoft

        RowLayout {
            id: chipRow

            anchors.centerIn: parent
            spacing: VfTheme.dp(4)

            Text {
                text: countChip.value
                color: countChip.accent
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(10)
                font.weight: Font.Bold
            }

            Text {
                text: countChip.label
                color: VfTheme.textSubtle
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(8)
            }
        }
    }

    Item {
        anchors.fill: parent
        visible: root.loading

        Column {
            anchors.centerIn: parent
            spacing: VfTheme.dp(10)

            BusyIndicator {
                anchors.horizontalCenter: parent.horizontalCenter
                width: VfTheme.dp(34)
                height: width
                running: true
            }

            Text {
                text: "Đang tải toàn bộ job con…"
                color: VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontControl
            }
        }
    }

    Item {
        anchors.fill: parent
        visible: !root.loading && String(root.summary.runId || "").length === 0

        Column {
            anchors.centerIn: parent
            spacing: VfTheme.dp(7)

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Chọn một job tổng"
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(17)
                font.weight: Font.DemiBold
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Toàn bộ video con, thumbnail và prompt sẽ hiện ngay tại đây."
                color: VfTheme.textSubtle
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontControl
            }
        }
    }

    ColumnLayout {
        id: detailBody

        anchors.fill: parent
        anchors.margins: VfTheme.dp(8)
        visible: !root.loading && String(root.summary.runId || "").length > 0
        spacing: VfTheme.dp(7)

            RowLayout {
                Layout.fillWidth: true
                visible: root.compact

                VfButton {
                    compact: true
                    text: "Quay lại"
                    iconName: "chevron-left"
                    onClicked: root.backRequested()
                }

                Item { Layout.fillWidth: true }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: root.compact
                    ? VfTheme.dp(138) : VfTheme.dp(130)
                radius: VfTheme.dp(9)
                color: VfTheme.surfaceSoft
                border.color: VfTheme.borderBox

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: VfTheme.dp(8)
                    spacing: VfTheme.dp(10)

                    Rectangle {
                        Layout.preferredWidth: root.compact
                            ? VfTheme.dp(176) : VfTheme.dp(196)
                        Layout.preferredHeight: root.compact
                            ? VfTheme.dp(99) : VfTheme.dp(110)
                        Layout.fillHeight: false
                        Layout.alignment: Qt.AlignVCenter
                        radius: VfTheme.dp(7)
                        color: VfTheme.surface
                        border.color: VfTheme.borderSoft
                        clip: true

                        Image {
                            anchors.fill: parent
                            source: String(root.summary.thumbnail || "")
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            sourceSize.width: 392
                            sourceSize.height: 220
                            visible: String(source).length > 0
                        }

                        Text {
                            anchors.centerIn: parent
                            visible: String(root.summary.thumbnail || "").length === 0
                            text: "CHƯA CÓ ẢNH"
                            color: VfTheme.textSubtle
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.dp(8)
                            font.weight: Font.Bold
                        }

                        MouseArea {
                            anchors.fill: parent
                            enabled: Boolean(root.capabilities.canOpenOutput)
                                && !root.actionsLocked
                            cursorShape: enabled
                                ? Qt.PointingHandCursor : Qt.ArrowCursor
                            onClicked: root.actionRequested("open_output")
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: VfTheme.dp(2)

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: VfTheme.dp(7)

                            Text {
                                Layout.fillWidth: true
                                text: String(root.summary.title || "Job tổng")
                                color: VfTheme.text
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.dp(14)
                                font.weight: Font.Bold
                                elide: Text.ElideRight
                            }

                            Rectangle {
                                implicitWidth: phaseText.implicitWidth
                                    + VfTheme.dp(14)
                                implicitHeight: VfTheme.dp(21)
                                radius: VfTheme.dp(10)
                                color: root.statusFill(
                                    String(root.summary.stateBucket || "")
                                )

                                Text {
                                    id: phaseText
                                    anchors.centerIn: parent
                                    text: String(
                                        root.summary.phaseLabel || "—"
                                    ).toUpperCase()
                                    color: root.statusColor(
                                        String(root.summary.stateBucket || "")
                                    )
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.dp(8)
                                    font.weight: Font.Bold
                                }
                            }
                        }

                        Text {
                            Layout.fillWidth: true
                            text: String(root.summary.sourceLabel || "—")
                                + "  ·  "
                                + String(root.summary.runId || "")
                            color: VfTheme.textSubtle
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.dp(8)
                            elide: Text.ElideMiddle
                        }

                        Text {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            text: String(
                                root.summary.promptPreview
                                || "Không có prompt tổng."
                            )
                            color: VfTheme.text
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.dp(10)
                            wrapMode: Text.WordWrap
                            elide: Text.ElideRight
                            maximumLineCount: root.compact ? 3 : 2
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: VfTheme.dp(5)

                            CountChip {
                                label: "job"
                                value: String(root.counts.total || 0)
                            }

                            CountChip {
                                label: "xong"
                                value: String(root.counts.complete || 0)
                                accent: VfTheme.greenText
                            }

                            CountChip {
                                label: "đang chạy"
                                value: String(root.counts.pending || 0)
                                accent: VfTheme.primary
                            }

                            CountChip {
                                label: "lỗi"
                                value: String(root.counts.failed || 0)
                                accent: Number(root.counts.failed || 0) > 0
                                    ? VfTheme.redText : VfTheme.textMuted
                            }

                            Item { Layout.fillWidth: true }
                        }
                    }

                    ColumnLayout {
                        Layout.preferredWidth: root.compact
                            ? VfTheme.dp(128) : VfTheme.dp(142)
                        Layout.fillHeight: true
                        spacing: VfTheme.dp(6)

                        Item { Layout.fillHeight: true }

                        VfButton {
                            Layout.fillWidth: true
                            compact: true
                            minWidth: 0
                            tone: "primary"
                            text: "Tạo lại tất cả"
                            iconName: "clockwise-arrows"
                            enabled: Boolean(root.capabilities.canRecreate)
                                && !root.actionsLocked
                            tooltip: enabled ? "" : String(
                                (root.capabilities.disabledReasonByAction || {}).recreate
                                || ""
                            )
                            onClicked: root.actionRequested("recreate")
                        }

                        VfButton {
                            Layout.fillWidth: true
                            compact: true
                            minWidth: 0
                            text: "Mở output cuối"
                            iconName: "play"
                            visible: Boolean(root.capabilities.canOpenOutput)
                            enabled: visible && !root.actionsLocked
                            onClicked: root.actionRequested("open_output")
                        }

                        Item { Layout.fillHeight: true }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: visible ? VfTheme.dp(92) : 0
                visible: root.libraryAssets.length > 0
                radius: VfTheme.dp(8)
                color: VfTheme.surface
                border.color: VfTheme.borderSoft
                clip: true

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: VfTheme.dp(7)
                    spacing: VfTheme.dp(5)

                    Text {
                        text: "THƯ VIỆN ASSET  ·  nhân vật / bối cảnh / vật thể"
                        color: VfTheme.text
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.dp(11)
                        font.weight: Font.Bold
                    }

                    ListView {
                        id: libraryRail

                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        orientation: ListView.Horizontal
                        spacing: VfTheme.dp(6)
                        clip: true
                        reuseItems: true
                        model: root.libraryAssets // perf-lint: disable=R2 sticky library strip, not a polled queue

                        delegate: Rectangle {
                            id: libraryCard

                            required property var modelData
                            readonly property var asset: modelData || ({})

                            width: VfTheme.dp(78)
                            height: libraryRail.height
                            radius: VfTheme.dp(6)
                            color: VfTheme.surfaceSoft
                            border.color: VfTheme.borderSoft
                            clip: true

                            Column {
                                anchors.fill: parent
                                anchors.margins: VfTheme.dp(4)
                                spacing: VfTheme.dp(3)

                                Rectangle {
                                    width: parent.width
                                    height: VfTheme.dp(48)
                                    radius: VfTheme.dp(4)
                                    color: VfTheme.surface
                                    border.color: VfTheme.borderSoft
                                    clip: true

                                    Image {
                                        anchors.fill: parent
                                        source: String(
                                            libraryCard.asset.previewSource || ""
                                        )
                                        asynchronous: true
                                        fillMode: Image.PreserveAspectCrop
                                        sourceSize.width: 156
                                        sourceSize.height: 96
                                        visible: String(source).length > 0
                                    }
                                }

                                Text {
                                    width: parent.width
                                    text: String(libraryCard.asset.label || "Asset")
                                    color: VfTheme.textSubtle
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.dp(8)
                                    font.weight: Font.DemiBold
                                    elide: Text.ElideRight
                                    horizontalAlignment: Text.AlignHCenter
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                enabled: Boolean(libraryCard.asset.canOpen)
                                    && !root.actionsLocked
                                cursorShape: enabled
                                    ? Qt.PointingHandCursor : Qt.ArrowCursor
                                onClicked: root.openArtifactRequested(
                                    String(libraryCard.asset.source || "")
                                )
                            }
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: visible ? VfTheme.dp(102) : 0
                visible: root.runArtifacts.length > 0
                radius: VfTheme.dp(8)
                color: VfTheme.surface
                border.color: VfTheme.borderSoft
                clip: true

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: VfTheme.dp(8)
                    spacing: VfTheme.dp(6)

                    Text {
                        text: "TÀI SẢN / OUTPUT CỦA JOB TỔNG"
                        color: VfTheme.text
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.dp(11)
                        font.weight: Font.Bold
                    }

                    ListView {
                        id: artifactRail

                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        orientation: ListView.Horizontal
                        spacing: VfTheme.dp(7)
                        clip: true
                        reuseItems: true
                        model: root.runArtifacts

                        delegate: Rectangle {
                            id: artifactCard

                            required property var modelData
                            readonly property var artifact: modelData || ({})

                            width: VfTheme.dp(238)
                            height: artifactRail.height
                            radius: VfTheme.dp(7)
                            color: VfTheme.surfaceSoft
                            border.color: VfTheme.borderSoft

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: VfTheme.dp(6)
                                spacing: VfTheme.dp(7)

                                Rectangle {
                                    Layout.preferredWidth: VfTheme.dp(62)
                                    Layout.fillHeight: true
                                    radius: VfTheme.dp(5)
                                    color: VfTheme.surface
                                    border.color: VfTheme.borderSoft
                                    clip: true

                                    Image {
                                        anchors.fill: parent
                                        source: artifactCard.artifact.isImage
                                            ? String(
                                                artifactCard.artifact.previewSource
                                                || ""
                                            )
                                            : ""
                                        asynchronous: true
                                        fillMode: Image.PreserveAspectCrop
                                        sourceSize.width: 124
                                        sourceSize.height: 124
                                        visible: String(source).length > 0
                                    }

                                    Text {
                                        anchors.centerIn: parent
                                        visible: !artifactCard.artifact.isImage
                                        text: String(
                                            artifactCard.artifact.kind || "FILE"
                                        ).toUpperCase()
                                        color: VfTheme.textSubtle
                                        font.family: VfTheme.fontFamily
                                        font.pixelSize: VfTheme.dp(9)
                                        font.weight: Font.Bold
                                    }
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    spacing: VfTheme.dp(2)

                                    Text {
                                        Layout.fillWidth: true
                                        text: String(
                                            artifactCard.artifact.label
                                            || "Artifact"
                                        )
                                        color: VfTheme.text
                                        font.family: VfTheme.fontFamily
                                        font.pixelSize: VfTheme.dp(10)
                                        font.weight: Font.DemiBold
                                        elide: Text.ElideMiddle
                                    }

                                    Text {
                                        Layout.fillWidth: true
                                        text: String(
                                            artifactCard.artifact.role || "output"
                                        ).toUpperCase()
                                            + " · "
                                            + String(
                                                artifactCard.artifact.kind || "file"
                                            ).toUpperCase()
                                        color: VfTheme.textSubtle
                                        font.family: VfTheme.fontFamily
                                        font.pixelSize: VfTheme.dp(8)
                                        elide: Text.ElideRight
                                    }

                                    Item { Layout.fillHeight: true }

                                    VfButton {
                                        compact: true
                                        text: "Mở"
                                        iconName: "open-folder"
                                        enabled: Boolean(
                                            artifactCard.artifact.canOpen
                                        )
                                        onClicked: root.openArtifactRequested(
                                            String(
                                                artifactCard.artifact.source
                                                || ""
                                            )
                                        )
                                    }
                                }
                            }
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: VfTheme.dp(5)
                Layout.bottomMargin: VfTheme.dp(2)

                Text {
                    text: "TOÀN BỘ JOB CON"
                    color: VfTheme.text
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(12)
                    font.weight: Font.Bold
                }

                Rectangle {
                    implicitWidth: childCount.implicitWidth + VfTheme.dp(12)
                    implicitHeight: VfTheme.dp(21)
                    radius: VfTheme.dp(10)
                    color: VfTheme.blueFill

                    Text {
                        id: childCount
                        anchors.centerIn: parent
                        text: String(root.counts.total || 0)
                        color: VfTheme.blueText
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.dp(9)
                        font.weight: Font.Bold
                    }
                }

                Item { Layout.fillWidth: true }

                Text {
                    text: "Thumbnail · Prompt · Model · Output · Tạo lại riêng"
                    color: VfTheme.textSubtle
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(9)
                }
            }

            ListView {
                id: jobList

                Layout.fillWidth: true
                Layout.fillHeight: true
                model: root.itemModel
                spacing: VfTheme.dp(7)
                clip: true
                reuseItems: true
                cacheBuffer: Math.max(0, height)

        delegate: Rectangle {
            id: jobCard

            required property var modelData
            readonly property var row: modelData || ({})
            readonly property string bucket: String(row.stateBucket || "")

            width: ListView.view.width
            height: root.compact ? VfTheme.dp(156) : VfTheme.dp(144)
            radius: VfTheme.dp(8)
            color: VfTheme.surface
            border.width: 1
            border.color: jobCard.bucket === "failed"
                ? VfTheme.redBorderSoft : VfTheme.borderSoft

            RowLayout {
                anchors.fill: parent
                anchors.margins: VfTheme.dp(7)
                spacing: VfTheme.dp(8)

                Rectangle {
                    Layout.preferredWidth: root.compact
                        ? VfTheme.dp(176) : VfTheme.dp(196)
                    Layout.preferredHeight: root.compact
                        ? VfTheme.dp(99) : VfTheme.dp(110)
                    Layout.fillHeight: false
                    Layout.alignment: Qt.AlignVCenter
                    radius: VfTheme.dp(7)
                    color: VfTheme.surfaceSoft
                    border.color: VfTheme.borderSoft
                    clip: true

                    Image {
                        anchors.fill: parent
                        source: String(jobCard.row.thumbnail || "")
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        sourceSize.width: 392
                        sourceSize.height: 220
                        visible: String(source).length > 0
                    }

                    Text {
                        anchors.centerIn: parent
                        visible: String(jobCard.row.thumbnail || "").length === 0
                        text: String(jobCard.row.kind || "JOB").toUpperCase()
                        color: VfTheme.textSubtle
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.dp(10)
                        font.weight: Font.Bold
                    }

                    MouseArea {
                        anchors.fill: parent
                        enabled: !root.actionsLocked && (
                            Boolean(jobCard.row.canOpenOutput)
                            || String(jobCard.row.thumbnail || "").length > 0
                        )
                        cursorShape: enabled
                            ? Qt.PointingHandCursor : Qt.ArrowCursor
                        onClicked: {
                            if (Boolean(jobCard.row.canOpenOutput))
                                root.itemActionRequested(
                                    String(jobCard.row.itemId || ""),
                                    "open_output"
                                )
                            else
                                root.openArtifactRequested(
                                    String(jobCard.row.thumbnail || "")
                                )
                        }
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: VfTheme.dp(4)

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: VfTheme.dp(6)

                        Text {
                            Layout.fillWidth: true
                            text: String(
                                jobCard.row.displayTitle
                                || ("Job " + String(
                                    Number(jobCard.row.itemIndex || 0) + 1
                                ))
                            )
                            color: VfTheme.text
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.dp(11)
                            font.weight: Font.Bold
                            elide: Text.ElideRight
                        }

                        Rectangle {
                            implicitWidth: cardStatus.implicitWidth + VfTheme.dp(12)
                            implicitHeight: VfTheme.dp(20)
                            radius: VfTheme.dp(10)
                            color: root.statusFill(jobCard.bucket)

                            Text {
                                id: cardStatus
                                anchors.centerIn: parent
                                text: String(jobCard.row.status || "—").toUpperCase()
                                color: root.statusColor(jobCard.bucket)
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.dp(7)
                                font.weight: Font.Bold
                            }
                        }

                        Text {
                            text: String(jobCard.row.updatedLabel || "")
                            color: VfTheme.textSubtle
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.dp(8)
                        }
                    }

                    Text {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        text: String(
                            jobCard.row.displayPrompt || "Không có prompt."
                        )
                        color: VfTheme.text
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.dp(10)
                        wrapMode: Text.WordWrap
                        elide: Text.ElideRight
                        maximumLineCount: 3
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: VfTheme.dp(32)
                        spacing: VfTheme.dp(6)

                        Rectangle {
                            Layout.maximumWidth: Math.max(
                                VfTheme.dp(120),
                                jobCard.width * 0.34
                            )
                            implicitWidth: Math.min(
                                modelText.implicitWidth + VfTheme.dp(12),
                                jobCard.width * 0.34
                            )
                            implicitHeight: VfTheme.dp(22)
                            radius: VfTheme.dp(5)
                            color: VfTheme.blueFill

                            Text {
                                id: modelText
                                anchors.fill: parent
                                anchors.leftMargin: VfTheme.dp(6)
                                anchors.rightMargin: VfTheme.dp(6)
                                text: String(
                                    jobCard.row.modelLabel || "Chưa ghi model"
                                )
                                color: VfTheme.blueText
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.dp(8)
                                font.weight: Font.DemiBold
                                verticalAlignment: Text.AlignVCenter
                                elide: Text.ElideRight
                            }
                        }

                        Text {
                            text: String(jobCard.row.attemptCount || 0)
                                + " lượt"
                            color: VfTheme.textMuted
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.dp(9)
                        }

                        Text {
                            text: String((jobCard.row.inputPreviews || []).length)
                                + " nguồn"
                            color: VfTheme.textMuted
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.dp(9)
                        }

                        Row {
                            spacing: VfTheme.dp(4)
                            visible: (jobCard.row.inputPreviews || []).length > 0

                            Repeater {
                                model: (jobCard.row.inputPreviews || []).slice(0, 8)

                                delegate: Rectangle {
                                    id: inputPreview
                                    required property var modelData

                                    width: VfTheme.dp(42)
                                    height: VfTheme.dp(28)
                                    radius: VfTheme.dp(4)
                                    color: VfTheme.surfaceSoft
                                    border.color: VfTheme.borderSoft
                                    clip: true

                                    Image {
                                        anchors.fill: parent
                                        source: String(inputPreview.modelData || "")
                                        fillMode: Image.PreserveAspectCrop
                                        asynchronous: true
                                        sourceSize.width: 84
                                        sourceSize.height: 56
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        enabled: String(
                                            inputPreview.modelData || ""
                                        ).length > 0 && !root.actionsLocked
                                        cursorShape: enabled
                                            ? Qt.PointingHandCursor
                                            : Qt.ArrowCursor
                                        onClicked: root.openArtifactRequested(
                                            String(inputPreview.modelData || "")
                                        )
                                    }
                                }
                            }
                        }

                        Text {
                            visible: Boolean(jobCard.row.canOpenOutput)
                            text: "✓ Có output"
                            color: VfTheme.greenText
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.dp(9)
                            font.weight: Font.DemiBold
                        }

                        Item { Layout.fillWidth: true }
                    }
                }

                ColumnLayout {
                    Layout.preferredWidth: root.compact
                        ? VfTheme.dp(124) : VfTheme.dp(136)
                    Layout.fillHeight: true
                    spacing: VfTheme.dp(6)

                    Item { Layout.fillHeight: true }

                    VfButton {
                        Layout.fillWidth: true
                        compact: true
                        tone: "primary"
                        minWidth: 0
                        text: String(jobCard.row.recreateLabel || "Tạo lại job")
                        iconName: "clockwise-arrows"
                        enabled: Boolean(jobCard.row.canRecreate)
                            && !root.actionsLocked
                        onClicked: root.itemActionRequested(
                            String(jobCard.row.itemId || ""),
                            "recreate_item"
                        )
                    }

                    VfButton {
                        Layout.fillWidth: true
                        compact: true
                        minWidth: 0
                        text: "Mở output"
                        iconName: "play"
                        visible: Boolean(jobCard.row.canOpenOutput)
                        enabled: visible && !root.actionsLocked
                        onClicked: root.itemActionRequested(
                            String(jobCard.row.itemId || ""),
                            "open_output"
                        )
                    }

                    Item { Layout.fillHeight: true }
                }
            }
        }

        footer: ColumnLayout {
            width: jobList.width
            spacing: VfTheme.dp(7)

            Rectangle {
                Layout.fillWidth: true
                Layout.topMargin: VfTheme.dp(4)
                Layout.preferredHeight: VfTheme.dp(58)
                radius: VfTheme.dp(8)
                color: VfTheme.surfaceSoft
                border.color: VfTheme.borderSoft

                Flow {
                    anchors.fill: parent
                    anchors.margins: VfTheme.dp(9)
                    spacing: VfTheme.dp(7)

                    VfButton {
                        text: "Thử lại job lỗi"
                        visible: Boolean(root.capabilities.canRetryFailed)
                        enabled: !root.actionsLocked
                        onClicked: root.actionRequested("retry_failed")
                    }

                    VfButton {
                        text: "Mở output cuối"
                        iconName: "play"
                        enabled: Boolean(root.capabilities.canOpenOutput)
                            && !root.actionsLocked
                        onClicked: root.actionRequested("open_output")
                    }

                    VfButton {
                        text: "Mở thư mục"
                        iconName: "open-folder"
                        enabled: Boolean(root.capabilities.canOpenFolder)
                            && !root.actionsLocked
                        onClicked: root.actionRequested("open_folder")
                    }

                    VfButton {
                        text: "Lưu trữ"
                        enabled: Boolean(root.capabilities.canArchive)
                            && !root.actionsLocked
                        onClicked: root.actionRequested("archive")
                    }

                    VfButton {
                        tone: "danger"
                        text: "Xóa bản ghi"
                        enabled: Boolean(root.capabilities.canDeletePermanently)
                            && !root.actionsLocked
                        onClicked: deleteDialog.open()
                    }
                }
            }

            Item { Layout.preferredHeight: VfTheme.dp(7) }
        }
            }
    }

    Dialog {
        id: deleteDialog

        parent: Overlay.overlay
        modal: true
        anchors.centerIn: parent
        width: Math.min(VfTheme.dp(420), parent.width - VfTheme.dp(40))
        padding: VfTheme.dp(20)
        title: ""
        standardButtons: Dialog.NoButton

        background: Rectangle {
            radius: VfTheme.dp(9)
            color: VfTheme.surface
            border.color: VfTheme.borderBox
        }

        contentItem: ColumnLayout {
            spacing: VfTheme.dp(14)

            Text {
                Layout.fillWidth: true
                text: "Xóa job tổng và toàn bộ dữ liệu History?"
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(17)
                font.weight: Font.Bold
                wrapMode: Text.WordWrap
            }

            Text {
                Layout.fillWidth: true
                text: "Video và output gốc không bị xóa. Bản ghi job tổng, "
                    + "các job con và thông tin tái tạo sẽ bị xóa khỏi History."
                color: VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(11)
                wrapMode: Text.WordWrap
            }

            RowLayout {
                Layout.fillWidth: true

                Item { Layout.fillWidth: true }

                VfButton {
                    text: "Hủy"
                    onClicked: deleteDialog.close()
                }

                VfButton {
                    tone: "danger"
                    text: "Xóa History"
                    onClicked: {
                        deleteDialog.close()
                        root.actionRequested("delete_permanently")
                    }
                }
            }
        }
    }
}
