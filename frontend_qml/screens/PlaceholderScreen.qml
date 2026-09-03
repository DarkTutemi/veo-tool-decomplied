import QtQuick
import QtQuick.Layouts

import "../components"
import "../theme"

Item {
    property string route: ""

    ColumnLayout {
        anchors.centerIn: parent
        width: Math.min(parent.width - 80, 520)
        spacing: VfTheme.dp(14)

        Text {
            text: route.toUpperCase()
            color: VfTheme.text
            font.pixelSize: VfTheme.dp(24)
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            Layout.fillWidth: true
        }

        Text {
            text: (void i18n.revision, i18n.t("qml.placeholder.body", "This route is reserved for QML migration. Master Prompt is the first active quality-bar screen."))
            color: VfTheme.textMuted
            font.pixelSize: VfTheme.dp(13)
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            Layout.fillWidth: true
        }
    }
}
