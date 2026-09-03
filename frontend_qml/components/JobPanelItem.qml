import QtQuick
import QtQuick.Layouts

import "../theme"

Rectangle {
    id: root

    property var row: ({})
    property int slotIndex: -1
    property bool selected: false
    property bool compact: false
    property bool showDelete: false
    property string label: ""
    property string sublabel: ""
    property string previewPath: ""
    property string mediaId: ""

    signal clicked(var row, int slotIndex)
    signal deleteRequested(var row)

    Layout.fillWidth: true
    implicitHeight: compact ? 32 : 72
    radius: VfTheme.radiusControl
    color: selected ? VfTheme.blueFill : (mouse.containsMouse ? VfTheme.surfaceSoft : VfTheme.surface)
    border.color: selected ? VfTheme.primary : VfTheme.borderBox
    clip: true

    function fileUrl(value) {
        var raw = String(value || "")
        if (raw.length === 0)
            return ""
        if (raw.indexOf("file:") === 0 || raw.indexOf("qrc:") === 0 || raw.indexOf("data:") === 0)
            return raw
        if (raw.indexOf("http://") === 0 || raw.indexOf("https://") === 0)
            return raw
        return "file:///" + raw.replace(/\\/g, "/")
    }

    function isImagePath(value) {
        var lower = String(value || "").toLowerCase()
        return lower.endsWith(".png")
            || lower.endsWith(".jpg")
            || lower.endsWith(".jpeg")
            || lower.endsWith(".webp")
            || lower.endsWith(".bmp")
            || lower.endsWith(".gif")
            || lower.indexOf("data:image/") === 0
    }

    function fallbackLabel() {
        if (root.compact && !root.selected && root.previewPath.length === 0 && root.mediaId.length === 0)
            return ""
        if (root.label.length > 0)
            return root.label
        if (root.mediaId.length > 0)
            return root.mediaId.length > 8 ? root.mediaId.slice(0, 8) : root.mediaId
        if (root.slotIndex >= 0)
            return "A" + String(root.slotIndex + 1)
        return String(root.row.title || root.row.name || root.row.prompt || root.row.id || "")
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: compact ? 2 : 8
        spacing: compact ? 4 : 8

        Rectangle {
            Layout.preferredWidth: compact ? 0 : 48
            Layout.fillHeight: true
            radius: VfTheme.dp(8)
            color: VfTheme.surfaceSoft
            border.color: VfTheme.borderSoft
            visible: !root.compact

            Text {
                anchors.centerIn: parent
                text: String(root.row.feature || root.row.type || "Job").slice(0, 3).toUpperCase()
                color: VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontTiny
                font.weight: Font.Bold
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: VfTheme.dp(2)

            Image {
                Layout.fillWidth: true
                Layout.fillHeight: true
                source: root.isImagePath(root.previewPath) ? root.fileUrl(root.previewPath) : ""
                fillMode: Image.PreserveAspectCrop
                visible: root.compact && root.isImagePath(root.previewPath)
            }

            Text {
                Layout.fillWidth: true
                Layout.fillHeight: root.compact
                text: root.fallbackLabel()
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: root.compact && root.previewPath.length > 0 ? 8 : VfTheme.fontControl
                font.weight: root.compact ? Font.DemiBold : Font.Bold
                elide: root.compact ? Text.ElideMiddle : Text.ElideRight
                horizontalAlignment: root.compact ? Text.AlignHCenter : Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
                maximumLineCount: root.compact ? 1 : 1
                visible: !root.compact || !root.isImagePath(root.previewPath)
            }

            Text {
                Layout.fillWidth: true
                text: root.sublabel.length > 0 ? root.sublabel : String(root.row.status || root.row.status_label || "queued")
                color: VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontSmall
                elide: Text.ElideRight
                visible: !root.compact
            }
        }

        VfButton {
            text: (void i18n.revision, i18n.t("common.delete", "Delete"))
            minWidth: VfTheme.dp(62)
            implicitHeight: VfTheme.dp(26)
            visible: root.showDelete
            onClicked: root.deleteRequested(root.row)
        }
    }

    MouseArea {
        id: mouse
        property string actionId: "job_panel.asset"
        anchors.fill: parent
        anchors.rightMargin: root.showDelete ? 68 : 0
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked(root.row, root.slotIndex)
    }
}
