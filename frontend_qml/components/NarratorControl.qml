import QtQuick
import QtQuick.Layouts

import "../theme"

// Master leftovers after the shared TTS compact bar moved to MasterFeatureToolbar:
// auto-voice hint + one-shot ASR install offer when Người dẫn truyện is on.
Item {
    id: root
    objectName: "narratorControl"

    property bool expanded: false
    readonly property string provider: {
        var cfg = (typeof voiceController !== "undefined" && voiceController)
            ? (voiceController.sharedTtsConfig || ({}))
            : ({})
        var route = String(cfg.tts_route || cfg.provider || "gemini").toLowerCase()
        if (["omnivoice", "moss", "vieneu"].indexOf(route) >= 0)
            return route
        return "gemini"
    }

    visible: expanded
    Layout.fillWidth: true
    implicitHeight: expanded ? contentColumn.implicitHeight : 0

    ColumnLayout {
        id: contentColumn
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        spacing: VfTheme.dp(6)

        Text {
            Layout.fillWidth: true
            visible: root.provider === "gemini"
                && String(narratorController.autoVoiceHint).length > 0
            text: narratorController.autoVoiceHint
            color: VfTheme.textSubtle
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.fontSmall
            wrapMode: Text.WordWrap
        }

        Rectangle {
            Layout.fillWidth: true
            visible: narratorController.asrOfferVisible || narratorController.asrInstallBusy
            implicitHeight: asrOfferRow.implicitHeight + VfTheme.dp(10)
            radius: VfTheme.radiusControl
            color: VfTheme.surface
            border.color: VfTheme.cyanBorderSoft
            border.width: 1

            RowLayout {
                id: asrOfferRow
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: VfTheme.dp(8)
                anchors.rightMargin: VfTheme.dp(8)
                spacing: VfTheme.dp(7)

                Text {
                    Layout.fillWidth: true
                    text: narratorController.asrInstallBusy
                        ? narratorController.asrStatus
                        : "Máy có GPU NVIDIA — cài engine chép lời offline (4.75GB, 1 lần)."
                    color: VfTheme.textMuted
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.fontSmall
                    wrapMode: Text.WordWrap
                }
                VfButton {
                    text: "Cài ngay"
                    tone: "primary"
                    visible: !narratorController.asrInstallBusy
                    onClicked: narratorController.installAsrEngine()
                }
                VfButton {
                    text: "Để sau"
                    visible: !narratorController.asrInstallBusy
                    onClicked: narratorController.dismissAsrOffer()
                }
            }
        }
    }
}
