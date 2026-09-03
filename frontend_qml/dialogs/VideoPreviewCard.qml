import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../components"
import "../theme"

Rectangle {
    id: root

    property var preview: ({})
    property string title: ""
    property string path: ""
    property string status: ""
    property int index: 0
    property int total: 0
    property bool selected: false

    signal openRequested()
    signal openPathRequested(string path)
    signal playRequested(string path)
    signal previewRequested(var preview)

    Layout.fillWidth: true
    implicitHeight: VfTheme.dp(156)
    radius: VfTheme.dp(12)
    color: mouse.containsMouse ? VfTheme.surfaceSoft : VfTheme.surface
    border.color: root.selected ? VfTheme.primary : VfTheme.borderBox
    border.width: root.selected ? 2 : 1
    clip: true

    function value(key, fallback) {
        var nextValue = root.preview ? root.preview[key] : undefined
        if (nextValue !== undefined && nextValue !== null && String(nextValue).length > 0)
            return String(nextValue)
        return fallback || ""
    }

    function displayTitle() {
        return root.title || root.value("title", "") || root.value("name", "") || root.fileName() || "Asset preview"
    }

    function displayPath() {
        return root.path || root.value("path", "") || root.value("file_url", "")
    }

    function fileName() {
        var name = root.value("name", "")
        if (name.length > 0)
            return name
        var raw = root.displayPath().replace(/\\/g, "/")
        if (raw.length === 0)
            return ""
        return raw.split("/").pop()
    }

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

    function sizeText() {
        var sizeMb = root.preview ? root.preview.size_mb : 0
        if (sizeMb !== undefined && Number(sizeMb) > 0)
            return Number(sizeMb).toFixed(1) + " MB"
        return ""
    }

    function statusText() {
        if (root.status.length > 0)
            return root.status
        if (root.preview && root.preview.thumbnail_blocker)
            return String(root.preview.thumbnail_blocker.message || root.preview.thumbnail_blocker.code)
        var errors = root.preview ? root.preview.errors || [] : []
        if (errors.length > 0)
            return String(errors[0].message || errors[0].code)
        if (root.preview && root.preview.is_image)
            return "Local image asset ready"
        if (root.preview && root.preview.playable)
            return "Playable local video"
        if (root.displayPath().length > 0)
            return "Preview contract ready"
        return "No local path"
    }

    function badgeText() {
        var totalValue = root.total || Number(root.value("total", 0))
        var indexValue = root.index || Number(root.value("index", 0))
        if (totalValue > 0)
            return "Video " + String(indexValue + 1) + " / " + String(totalValue)
        if (root.preview && root.preview.is_image)
            return "IMAGE"
        var extension = root.value("extension", "")
        return extension.length > 0 ? extension.toUpperCase().replace(".", "") : "VIDEO"
    }

    function primaryActionText() {
        if (root.preview && root.preview.is_image)
            return "View"
        return "Play"
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            root.previewRequested(root.preview)
            root.openRequested()
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: VfTheme.dp(10)
        spacing: VfTheme.dp(12)
        z: 1

        Rectangle {
            Layout.preferredWidth: VfTheme.dp(180)
            Layout.fillHeight: true
            radius: VfTheme.dp(10)
            color: VfTheme.surface
            border.color: VfTheme.borderStrong
            border.width: 1
            clip: true

            Image {
                anchors.fill: parent
                source: root.fileUrl(root.value("thumbnail_path", ""))
                fillMode: Image.PreserveAspectCrop
                visible: root.value("thumbnail_path", "").length > 0
            }

            ColumnLayout {
                anchors.centerIn: parent
                width: parent.width - 18
                spacing: VfTheme.dp(5)
                visible: root.value("thumbnail_path", "").length === 0

                Text {
                    Layout.fillWidth: true
                    text: "VIDEO"
                    color: VfTheme.text
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(16)
                    font.weight: VfTheme.weightTitle
                    horizontalAlignment: Text.AlignHCenter
                }

                Text {
                    Layout.fillWidth: true
                    text: root.fileName() || "No file"
                    color: VfTheme.textMuted
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.fontTiny
                    horizontalAlignment: Text.AlignHCenter
                    elide: Text.ElideMiddle
                }
            }

            Rectangle {
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.margins: VfTheme.dp(8)
                width: badgeLabel.implicitWidth + 14
                height: VfTheme.dp(22)
                radius: VfTheme.dp(6)
                color: VfTheme.primary

                Text {
                    id: badgeLabel
                    anchors.centerIn: parent
                    text: root.badgeText()
                    color: "#FFFFFF"
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.fontTiny
                    font.weight: VfTheme.weightStrong
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: VfTheme.dp(6)

            Text {
                Layout.fillWidth: true
                text: root.displayTitle()
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontSection
                font.weight: VfTheme.weightTitle
                elide: Text.ElideRight
                maximumLineCount: 1
            }

            Text {
                Layout.fillWidth: true
                text: root.displayPath() || "No local path"
                color: VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontSmall
                elide: Text.ElideMiddle
                maximumLineCount: 1
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: VfTheme.dp(6)

                VfChip {
                    text: root.preview && root.preview.exists ? "Exists" : "Missing"
                    selected: true
                    accent: root.preview && root.preview.exists ? VfTheme.greenBorder : VfTheme.redBorder
                }

                VfChip {
                    text: root.preview && root.preview.supported === false ? "Unsupported" : "Supported"
                    selected: root.preview && root.preview.supported === false
                    accent: VfTheme.redBorder
                }

                Text {
                    Layout.fillWidth: true
                    text: root.sizeText()
                    color: VfTheme.textSubtle
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.fontSmall
                    elide: Text.ElideRight
                }
            }

            Text {
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: root.statusText()
                color: VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontSmall
                wrapMode: Text.WordWrap
                maximumLineCount: 2
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: VfTheme.dp(8)

                Item { Layout.fillWidth: true }

                VfButton {
                    text: "Preview"
                    enabled: root.displayPath().length > 0
                    onClicked: {
                        root.previewRequested(root.preview)
                        root.openRequested()
                    }
                }

                VfButton {
                    text: "Open"
                    enabled: root.displayPath().length > 0 && root.preview && root.preview.exists
                    onClicked: root.openPathRequested(root.displayPath())
                }

                VfButton {
                    text: root.primaryActionText()
                    tone: "primary"
                    enabled: root.displayPath().length > 0
                    onClicked: root.playRequested(root.displayPath())
                }
            }
        }
    }
}
