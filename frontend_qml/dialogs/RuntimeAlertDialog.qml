import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../components"
import "../theme"

Dialog {
    id: root

    property var payload: ({})

    signal actionRequested(string action, string value)

    parent: Overlay.overlay
    modal: true
    focus: true
    width: VfDialogMetrics.width(parent, VfTheme.dp(500), VfTheme.dp(48))
    x: VfDialogMetrics.centerX(parent, width)
    y: VfDialogMetrics.centerY(parent, height)
    padding: 0
    topPadding: 0
    bottomPadding: 0
    closePolicy: Popup.CloseOnEscape

    // All visuals live inside contentItem — keep the Dialog chrome empty.
    background: Item {}
    header:     Item { height: 0 }
    footer:     Item { height: 0 }

    function openFromPayload(data) {
        payload = data || {}
        open()
    }

    // ── Tone → palette ────────────────────────────────────────────────────────

    function _accent() {
        var t = String(root.payload.tone || "warning")
        if (t === "danger")  return VfTheme.redBorder
        if (t === "success") return VfTheme.greenBorder
        if (t === "info")    return VfTheme.blueBorder
        return VfTheme.amberBorder
    }

    function _badgeFill() {
        var t = String(root.payload.tone || "warning")
        if (t === "danger")  return VfTheme.redFill
        if (t === "success") return VfTheme.greenFill
        if (t === "info")    return VfTheme.blueFill
        return VfTheme.amberFill
    }

    function _badgeIcon() {
        if (root.payload.icon) return String(root.payload.icon)
        var t = String(root.payload.tone || "warning")
        if (t === "danger")  return "circle-alert"
        if (t === "success") return "circle-check"
        if (t === "info")    return "info"
        return "triangle-alert"
    }

    function _actions() {
        var a = root.payload.actions
        if (!a || !a.length) return [{ label: "Close", action: "close", value: "", tone: "neutral" }]
        return a
    }

    // ── Card ──────────────────────────────────────────────────────────────────

    contentItem: Rectangle {
        id: card
        implicitHeight: body.implicitHeight
        radius: VfTheme.radiusShell
        color:  VfTheme.surface
        border.color: VfTheme.border
        border.width: 1

        ColumnLayout {
            id: body
            anchors.left:  parent.left
            anchors.right: parent.right
            anchors.top:   parent.top
            spacing: 0

            // ── Header ────────────────────────────────────────────────────────
            RowLayout {
                Layout.fillWidth:    true
                Layout.leftMargin:   VfTheme.dp(22)
                Layout.rightMargin:  VfTheme.dp(14)
                Layout.topMargin:    VfTheme.dp(20)
                Layout.bottomMargin: VfTheme.dp(16)
                spacing: VfTheme.dp(13)

                // Soft-tinted icon badge
                Rectangle {
                    Layout.alignment: Qt.AlignTop
                    width:  VfTheme.dp(40)
                    height: VfTheme.dp(40)
                    radius: VfTheme.dp(11)
                    color:  _badgeFill()
                    border.color: _accent()
                    border.width: 1

                    VfIcon {
                        name:    _badgeIcon()
                        size:    VfTheme.dp(21)
                        variant: VfTheme.dark ? "light" : "dark"
                        anchors.centerIn: parent
                    }
                }

                // Title
                Text {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    text:           String(root.payload.title || "Alert")
                    font.family:    VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(17)
                    font.weight:    Font.DemiBold
                    color:          VfTheme.text
                    wrapMode:       Text.WordWrap
                    lineHeight:     1.25
                }

                // Close ×
                Item {
                    Layout.alignment: Qt.AlignTop
                    width:  VfTheme.dp(32)
                    height: VfTheme.dp(32)

                    Rectangle {
                        anchors.fill: parent
                        radius: VfTheme.dp(8)
                        color: closeHov.containsMouse ? VfTheme.surfaceSoft : "transparent"
                        Behavior on color { ColorAnimation { duration: 110 } }
                    }

                    VfIcon {
                        name:    "x"
                        size:    VfTheme.dp(16)
                        variant: VfTheme.dark ? "light" : "dark"
                        anchors.centerIn: parent
                        opacity: closeHov.containsMouse ? 0.95 : 0.5
                        Behavior on opacity { NumberAnimation { duration: 110 } }
                    }

                    MouseArea {
                        id: closeHov
                        anchors.fill:  parent
                        cursorShape:   Qt.PointingHandCursor
                        hoverEnabled:  true
                        onClicked:     root.close()
                    }
                }
            }

            // ── Body ──────────────────────────────────────────────────────────
            ColumnLayout {
                Layout.fillWidth:    true
                Layout.leftMargin:   VfTheme.dp(22)
                Layout.rightMargin:  VfTheme.dp(22)
                Layout.bottomMargin: VfTheme.dp(18)
                spacing: VfTheme.dp(14)

                // Explanation paragraph
                Text {
                    Layout.fillWidth: true
                    visible:        text.length > 0
                    text:           String(root.payload.message || "")
                    font.family:    VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(13)
                    lineHeight:     1.6
                    color:          VfTheme.textMuted
                    wrapMode:       Text.WordWrap
                    textFormat:     Text.PlainText
                }

                // Usage / detail card
                Rectangle {
                    Layout.fillWidth: true
                    visible: detailText.text.length > 0
                    radius: VfTheme.dp(11)
                    color:  VfTheme.surfaceSoft
                    border.color: VfTheme.borderSoft
                    border.width: 1
                    implicitHeight: detailCol.implicitHeight + VfTheme.dp(22)

                    ColumnLayout {
                        id: detailCol
                        anchors.left:   parent.left
                        anchors.right:  parent.right
                        anchors.top:    parent.top
                        anchors.margins: VfTheme.dp(13)
                        spacing: VfTheme.dp(6)

                        Text {
                            Layout.fillWidth: true
                            visible: String(root.payload.detailLabel || "").length > 0
                            text:           String(root.payload.detailLabel || "")
                            font.family:    VfTheme.fontFamily
                            font.pixelSize: VfTheme.dp(11)
                            font.weight:    Font.DemiBold
                            color:          VfTheme.textSubtle
                            font.capitalization: Font.AllUppercase
                            font.letterSpacing: 0.5
                        }

                        Text {
                            id: detailText
                            Layout.fillWidth: true
                            text:           String(root.payload.detail || "")
                            font.family:    "Consolas"
                            font.pixelSize: VfTheme.dp(12)
                            lineHeight:     1.7
                            color:          VfTheme.textMuted
                            wrapMode:       Text.WordWrap
                        }
                    }
                }
            }

            // Divider
            Rectangle {
                Layout.fillWidth:   true
                Layout.leftMargin:  VfTheme.dp(22)
                Layout.rightMargin: VfTheme.dp(22)
                height:  1
                color:   VfTheme.border
                opacity: 0.7
            }

            // ── Footer buttons ────────────────────────────────────────────────
            RowLayout {
                Layout.fillWidth:    true
                Layout.leftMargin:   VfTheme.dp(22)
                Layout.rightMargin:  VfTheme.dp(22)
                Layout.topMargin:    VfTheme.dp(14)
                Layout.bottomMargin: VfTheme.dp(18)
                spacing: VfTheme.dp(8)

                Item { Layout.fillWidth: true }

                Repeater {
                    model: _actions()

                    delegate: VfButton {
                        required property var modelData

                        text: String(modelData.label || "Close")
                        tone: String(modelData.tone || "neutral")
                        showLeadingIcon: String(modelData.icon || "").length > 0
                        iconName: String(modelData.icon || "")
                        onClicked: {
                            var act = String(modelData.action || "")
                            root.actionRequested(act, String(modelData.value || ""))
                            if (act === "close") root.close()
                        }
                    }
                }
            }
        }
    }
}
