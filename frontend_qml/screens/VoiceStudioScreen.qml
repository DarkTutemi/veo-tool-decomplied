import QtQuick

import "../components"
import "../theme"

Item {
    id: screen
    objectName: "voiceStudioScreen"

    Rectangle {
        anchors.fill: parent
        color: VfTheme.canvas
    }

    // Voice Studio is audio-only: one shared-provider workspace (config + input
    // + queue + history) driven entirely by VoiceAudioView.
    VoiceAudioView {
        id: voiceAudioView
        anchors.fill: parent
        anchors.margins: VfTheme.dp(10)
    }

    function tourActivateSection(action) {
        voiceAudioView.tourActivateSection(action)
    }

    Component.onCompleted: {
        Qt.callLater(function() {
            voiceController.refreshOptions()
            voiceController.refresh()
            voiceController.refreshHistory()
        })
    }
}
