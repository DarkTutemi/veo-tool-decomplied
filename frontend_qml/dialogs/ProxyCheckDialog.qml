import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../components"
import "../theme"

Dialog {
    id: root

    property var check: ({})
    property string actionMessage: ""
    property bool actionError: false

    signal startRequested()

    function applyStartResult(result) {
        var response = result || ({})
        root.actionMessage = String(response.message || response.error || "")
        root.actionError = !Boolean(response.ok)
    }

    function isCompleted() {
        return Boolean(root.check && root.check.completed)
    }

    modal: true
    parent: Overlay.overlay
    width: VfDialogMetrics.width(parent, 700, 80)
    height: VfDialogMetrics.height(parent, 500, 80)
    x: VfDialogMetrics.centerX(parent, width)
    y: VfDialogMetrics.centerY(parent, height)
    padding: 0
    title: ""
    header: null
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    onOpened: {
        root.actionMessage = ""
        root.actionError = false
    }

    background: Rectangle {
        radius: VfTheme.radiusPanel
        color: VfTheme.surface
        border.color: VfTheme.borderBox
    }

    contentItem: ColumnLayout {
        spacing: 0

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: VfTheme.dp(48)
            color: VfTheme.surfaceSoft
            border.color: VfTheme.borderSoft

            Text {
                anchors.fill: parent
                anchors.leftMargin: VfTheme.dp(14)
                anchors.rightMargin: VfTheme.dp(14)
                text: (void i18n.revision, i18n.t("settings.proxy_check_title", "Proxy Check"))
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontSection
                font.weight: VfTheme.weightTitle
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: 12
            spacing: VfTheme.dp(10)

            ProgressBar {
                Layout.fillWidth: true
                from: 0
                to: Math.max(1, Number(root.check.total || 0))
                value: Number(root.check.current || 0)
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: VfTheme.dp(38)
                color: VfTheme.surfaceSoft
                border.color: VfTheme.borderSoft

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: VfTheme.dp(10)
                    anchors.rightMargin: VfTheme.dp(10)
                    spacing: VfTheme.dp(8)

                    Text {
                        Layout.fillWidth: true
                        text: (void i18n.revision, i18n.t("settings.col_proxy", "Proxy"))
                        color: VfTheme.text
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.fontSmall
                        font.weight: VfTheme.weightStrong
                        horizontalAlignment: Text.AlignHCenter
                        elide: Text.ElideRight
                    }

                    Text {
                        Layout.preferredWidth: VfTheme.dp(126)
                        text: (void i18n.revision, i18n.t("settings.col_status", "Status"))
                        color: VfTheme.text
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.fontSmall
                        font.weight: VfTheme.weightStrong
                        horizontalAlignment: Text.AlignHCenter
                        elide: Text.ElideRight
                    }

                    Text {
                        Layout.preferredWidth: VfTheme.dp(100)
                        text: (void i18n.revision, i18n.t("settings.col_time", "Time (ms)"))
                        color: VfTheme.text
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.fontSmall
                        font.weight: VfTheme.weightStrong
                        horizontalAlignment: Text.AlignHCenter
                        elide: Text.ElideRight
                    }

                    Text {
                        Layout.fillWidth: true
                        text: (void i18n.revision, i18n.t("settings.col_message", "Message"))
                        color: VfTheme.text
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.fontSmall
                        font.weight: VfTheme.weightStrong
                        horizontalAlignment: Text.AlignHCenter
                        elide: Text.ElideRight
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: VfTheme.surface
                border.color: VfTheme.borderSoft

                ListView {
                    id: proxyResultList
                    anchors.fill: parent
                    clip: true
                    spacing: 0
                    reuseItems: true
                    model: root.check.rows || []

                    delegate: Rectangle {
                        width: proxyResultList.width
                        height: VfTheme.dp(42)
                        color: index % 2 === 0 ? VfTheme.surface : VfTheme.surfaceSoft
                        border.color: VfTheme.borderSoft

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: VfTheme.dp(10)
                            anchors.rightMargin: VfTheme.dp(10)
                            spacing: VfTheme.dp(8)

                            Text {
                                Layout.fillWidth: true
                                text: String(modelData.key || "")
                                color: VfTheme.text
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.fontSmall
                                font.weight: VfTheme.weightStrong
                                elide: Text.ElideRight
                            }

                            Text {
                                Layout.preferredWidth: VfTheme.dp(126)
                                text: String(modelData.checkStatus || modelData.status || "waiting")
                                color: VfTheme.textMuted
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.fontTiny
                                horizontalAlignment: Text.AlignHCenter
                                elide: Text.ElideRight
                            }

                            Text {
                                Layout.preferredWidth: VfTheme.dp(100)
                                text: modelData.responseTime ? String(modelData.responseTime) : "-"
                                color: VfTheme.textMuted
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.fontTiny
                                horizontalAlignment: Text.AlignHCenter
                                elide: Text.ElideRight
                            }

                            Text {
                                Layout.fillWidth: true
                                text: String(modelData.message || modelData.lastError || "")
                                color: VfTheme.textMuted
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.fontTiny
                                elide: Text.ElideRight
                            }
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: VfTheme.dp(8)

                Text {
                    visible: root.isCompleted()
                    text: "\u2713"
                    color: "#10b981"
                    font.family: "Segoe UI Symbol"
                    font.pixelSize: VfTheme.fontSmall
                    verticalAlignment: Text.AlignVCenter
                }

                Text {
                    Layout.fillWidth: true
                    text: root.isCompleted()
                        ? "Live: " + String(root.check.live || 0)
                        : (void i18n.revision, i18n.t("settings.waiting", "Waiting"))
                    color: VfTheme.text
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.fontSmall
                    verticalAlignment: Text.AlignVCenter
                }

                Text {
                    visible: root.isCompleted()
                    text: "|"
                    color: VfTheme.textMuted
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.fontSmall
                    verticalAlignment: Text.AlignVCenter
                }

                Text {
                    visible: root.isCompleted()
                    text: "\u2717"
                    color: "#ef4444"
                    font.family: "Segoe UI Symbol"
                    font.pixelSize: VfTheme.fontSmall
                    verticalAlignment: Text.AlignVCenter
                }

                Text {
                    visible: root.isCompleted()
                    text: "Dead: " + String(root.check.dead || 0)
                    color: VfTheme.text
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.fontSmall
                    verticalAlignment: Text.AlignVCenter
                }
            }

            Text {
                Layout.fillWidth: true
                visible: root.actionMessage.length > 0
                text: root.actionMessage
                color: root.actionError ? "#DC2626" : VfTheme.tealText
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontSmall
                wrapMode: Text.WordWrap
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: VfTheme.dp(8)

                Item { Layout.fillWidth: true }

                VfButton {
                    text: root.isCompleted()
                        ? (void i18n.revision, i18n.t("settings.close_complete", "Close"))
                        : (root.check.running ? (void i18n.revision, i18n.t("settings.checking", "Checking")) : (void i18n.revision, i18n.t("common.close", "Close")))
                    onClicked: root.accept()
                }
            }
        }
    }
}
