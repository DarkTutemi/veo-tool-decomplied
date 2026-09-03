pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import "../../theme"

Rectangle {
    id: root

    required property var row
    property bool selected: false

    signal clicked()

    implicitHeight: VfTheme.dp(82)
    radius: VfTheme.dp(8)
    color: selected ? VfTheme.blueFill : VfTheme.surface
    border.width: 1
    border.color: selected ? VfTheme.primary : VfTheme.border

    function toneFill(tone) {
        if (tone === "green") return VfTheme.greenFill
        if (tone === "red") return VfTheme.redFill
        if (tone === "amber") return VfTheme.amberFill
        if (tone === "cyan") return VfTheme.cyanFill
        if (tone === "pink") return VfTheme.pinkFill
        if (tone === "indigo") return VfTheme.indigoFill
        if (tone === "violet") return VfTheme.violetFill
        if (tone === "neutral") return VfTheme.surfaceSoft
        return VfTheme.blueFill
    }

    function toneText(tone) {
        if (tone === "green") return VfTheme.greenText
        if (tone === "red") return VfTheme.redText
        if (tone === "amber") return VfTheme.amberText
        if (tone === "cyan") return VfTheme.cyanText
        if (tone === "pink") return VfTheme.pinkText
        if (tone === "indigo") return VfTheme.indigoText
        if (tone === "violet") return VfTheme.violetText
        if (tone === "neutral") return VfTheme.textMuted
        return VfTheme.blueText
    }

    component Pill: Rectangle {
        required property string label
        required property string tone

        implicitWidth: labelText.implicitWidth + VfTheme.dp(10)
        implicitHeight: VfTheme.dp(18)
        radius: VfTheme.dp(4)
        color: root.toneFill(tone)

        Text {
            id: labelText
            anchors.centerIn: parent
            text: parent.label
            color: root.toneText(parent.tone)
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.dp(9)
            font.weight: Font.DemiBold
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: VfTheme.dp(7)
        spacing: VfTheme.dp(8)

        Rectangle {
            Layout.preferredWidth: VfTheme.dp(96)
            Layout.preferredHeight: VfTheme.dp(54)
            Layout.fillHeight: false
            Layout.alignment: Qt.AlignVCenter
            radius: VfTheme.dp(6)
            color: VfTheme.surfaceSoft
            border.color: VfTheme.borderSoft
            clip: true

            Image {
                anchors.fill: parent
                source: String(root.row.thumbnail || "")
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                sourceSize.width: 192
                sourceSize.height: 108
                visible: String(source).length > 0
            }

            Column {
                anchors.centerIn: parent
                spacing: VfTheme.dp(2)
                visible: String(root.row.thumbnail || "").length === 0

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: String(root.row.sourceLabel || "?").slice(0, 3).toUpperCase()
                    color: VfTheme.textMuted
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(11)
                    font.weight: Font.Bold
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "NO PREVIEW"
                    color: VfTheme.textSubtle
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(7)
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: VfTheme.dp(2)

            RowLayout {
                Layout.fillWidth: true
                spacing: VfTheme.dp(5)

                Repeater {
                    model: (root.row.badges || []).slice(0, 2)
                    delegate: Pill {
                        required property var modelData
                        label: String(modelData.label || "")
                        tone: String(modelData.tone || "blue")
                    }
                }

                Item { Layout.fillWidth: true }

                Text {
                    text: String(root.row.updatedLabel || "")
                    color: VfTheme.textSubtle
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(9)
                }
            }

            Text {
                Layout.fillWidth: true
                text: String(root.row.title || root.row.runId || "")
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(12)
                font.weight: Font.DemiBold
                elide: Text.ElideRight
                maximumLineCount: 1
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: VfTheme.dp(6)

                Text {
                    text: {
                        var c = root.row.sceneCounts || ({})
                        var total = Number(c.total || 0)
                        var complete = Number(c.complete || 0)
                        var failed = Number(c.failed || 0)
                        var parts = []
                        if (total > 0) parts.push(String(total) + " job con")
                        if (complete > 0) parts.push("✓ " + String(complete))
                        if (failed > 0) parts.push("✗ " + String(failed))
                        return parts.join(" · ")
                    }
                    color: Number((root.row.sceneCounts || {}).failed || 0) > 0
                        ? VfTheme.redText : VfTheme.textMuted
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(9)
                    font.weight: Font.DemiBold
                }

                Text {
                    Layout.fillWidth: true
                    text: String(root.row.subtitle || "")
                    color: VfTheme.textSubtle
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(9)
                    elide: Text.ElideRight
                }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
