import QtQuick
import QtQuick.Layouts

import "../theme"

VfPanel {
    id: root

    property var session: ({})
    property var stats: ({})
    property string sessionId: String((session && (session.session_key || session.id)) || "")
    property string rootPrompt: String((session && session.root_prompt) || "")
    property int sceneCount: Number((session && session.scene_count) || 0)
    property int extendCount: Number((session && session.extend_count) || 0)
    property bool selected: false
    property string blocker: ""

    signal openRequested(string sessionKey)
    signal deleteRequested(string sessionKey)

    title: {
        if (session && String(session.title || "").length > 0)
            return String(session.title)
        return sessionId.length > 0 ? sessionId : "Extend Session"
    }
    subtitle: root.rootPrompt.length > 0 ? root.rootPrompt : (root.selected ? "Active session" : "Idle session")
    dense: true
    showFrame: true
    border.color: root.selected ? VfTheme.primary : VfTheme.borderBox

    RowLayout {
        Layout.fillWidth: true
        spacing: VfTheme.dp(8)

        VfStatusPill {
            label: "Scenes"
            value: String(root.sceneCount)
            tone: "blue"
        }
        VfStatusPill {
            label: "Extend"
            value: String(root.extendCount)
            tone: "green"
        }
        VfStatusPill {
            label: "Queue"
            value: String(root.stats.total || 0)
            tone: (root.stats.failed || 0) > 0 ? "red" : "blue"
        }
        Item {
            Layout.fillWidth: true
        }
        VfButton {
            text: "Open"
            enabled: root.sessionId.length > 0 && !root.selected
            onClicked: root.openRequested(root.sessionId)
        }
        VfButton {
            text: "Delete"
            enabled: root.sessionId.length > 0
            tone: "danger"
            onClicked: root.deleteRequested(root.sessionId)
        }
    }
}
