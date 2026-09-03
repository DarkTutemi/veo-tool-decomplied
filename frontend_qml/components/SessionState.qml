import QtQuick
import QtQuick.Layouts

import "../theme"

Rectangle {
    id: root

    property string title: "Session"
    property string status: "idle"
    property var stats: ({})
    property var session: ({})
    property color accent: VfTheme.primary
    property bool canCreate: true

    signal createRequested()

    Layout.fillWidth: true
    implicitHeight: VfTheme.dp(88)
    radius: VfTheme.radiusPanel
    color: VfTheme.surface
    border.color: VfTheme.borderBox

    RowLayout {
        anchors.fill: parent
        anchors.margins: VfTheme.dp(10)
        spacing: VfTheme.dp(10)

        Rectangle {
            Layout.preferredWidth: VfTheme.dp(5)
            Layout.fillHeight: true
            radius: VfTheme.dp(3)
            color: root.accent
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: VfTheme.dp(4)

            Text {
                Layout.fillWidth: true
                text: {
                    if (root.session && String(root.session.title || "").length > 0)
                        return String(root.session.title)
                    return root.title
                }
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontControl
                font.weight: Font.Bold
                elide: Text.ElideRight
            }

            Text {
                Layout.fillWidth: true
                text: {
                    var parts = []
                    if (root.session && String(root.session.session_key || "").length > 0)
                        parts.push(String(root.session.session_key).slice(0, 42))
                    parts.push(root.status)
                    if (root.session && String(root.session.output_folder || "").length > 0)
                        parts.push(String(root.session.output_folder))
                    return parts.join("  |  ")
                }
                color: VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontSmall
                elide: Text.ElideRight
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: VfTheme.dp(8)

                Repeater {
                    model: [
                        { label: "Total", value: String(root.stats.total || 0) },
                        { label: "Queued", value: String(root.stats.queued || root.stats.pending || 0) },
                        { label: "Done", value: String(root.stats.completed || 0) },
                        { label: "Failed", value: String(root.stats.failed || 0) },
                        { label: "Cards", value: String((root.session && root.session.card_count) || 0) }
                    ]

                    VfStatusPill {
                        label: modelData.label
                        value: modelData.value
                        tone: index === 2 ? "green" : (index === 3 ? "red" : "blue")
                    }
                }

                Item {
                    Layout.fillWidth: true
                }

                VfButton {
                    visible: root.canCreate
                    text: (void i18n.revision, i18n.t("qml.work.new_session", "New Session"))
                    minWidth: VfTheme.dp(104)
                    tone: "primary"
                    onClicked: root.createRequested()
                }
            }
        }
    }
}
