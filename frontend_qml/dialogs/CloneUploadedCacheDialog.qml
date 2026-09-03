import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../components"
import "../theme"

Dialog {
    id: root

    property var uploadRows: []
    property string cachePath: ""
    property int selectedIndex: 0
    property string feedbackTitle: ""
    property string feedbackMessage: ""

    signal useRequested(string filePath)

    modal: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    width: VfDialogMetrics.width(parent, 920, 80)
    height: VfDialogMetrics.height(parent, 620, 80)
    x: VfDialogMetrics.centerX(parent, width)
    y: VfDialogMetrics.centerY(parent, height)
    padding: 0
    header: null

    function openFor(rows, cacheFile) {
        root.uploadRows = rows || []
        root.cachePath = String(cacheFile || "")
        root.selectedIndex = root.uploadRows.length > 0 ? 0 : -1
        root.open()
    }

    function currentRow() {
        if (root.selectedIndex < 0 || root.selectedIndex >= (root.uploadRows || []).length)
            return null
        return root.uploadRows[root.selectedIndex]
    }

    function showFeedback(title, message) {
        root.feedbackTitle = String(title || (void i18n.revision, i18n.t("common.notice", "Notice")))
        root.feedbackMessage = String(message || "")
        feedbackDialog.open()
    }

    function applyUseResult(result) {
        var payload = result || ({})
        if (payload.ok) {
            root.close()
            return true
        }
        root.showFeedback(
            (void i18n.revision, i18n.t("clone.use_file_failed_title", "Use cached file failed")),
            String(payload.message || payload.error || (void i18n.revision, i18n.t("clone.use_file_failed_message", "Could not add the cached upload to the clone list.")))
        )
        return false
    }

    background: Rectangle {
        color: VfTheme.surface
        radius: VfTheme.dp(12)
        border.color: VfTheme.borderBox
    }

    contentItem: ColumnLayout {
        spacing: 0

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: VfTheme.dp(56)
            color: VfTheme.surfaceSoft
            border.color: VfTheme.border

            RowLayout {
                anchors.fill: parent
                anchors.margins: VfTheme.dp(16)
                spacing: VfTheme.dp(10)

                Text {
                    Layout.fillWidth: true
                    text: (void i18n.revision, i18n.t("clone.view_uploaded", "View uploaded"))
                    color: VfTheme.text
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(16)
                    font.weight: Font.DemiBold
                    elide: Text.ElideRight
                }

                VfButton {
                    text: (void i18n.revision, i18n.t("common.close", "Close"))
                    minWidth: VfTheme.dp(88)
                    tone: "neutral"
                    onClicked: root.close()
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: 16
            spacing: VfTheme.dp(10)

            Text {
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                text: (void i18n.revision, i18n.t("clone.cache_location", "Cache location: {path}")).replace("{path}", root.cachePath || "-")
                color: VfTheme.textSubtle
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(12)
            }

            Text {
                Layout.fillWidth: true
                text: (void i18n.revision, i18n.t("clone.total_uploads", "Total uploads: {count}")).replace("{count}", String((root.uploadRows || []).length))
                color: VfTheme.textSubtle
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(12)
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: VfTheme.dp(10)
                color: VfTheme.surface
                border.color: VfTheme.border
                clip: true

                ListView {
                    id: listView
                    anchors.fill: parent
                    anchors.margins: VfTheme.dp(8)
                    spacing: VfTheme.dp(6)
                    model: root.uploadRows || []
                    currentIndex: root.selectedIndex
                    reuseItems: true

                    delegate: Rectangle {
                        required property int index
                        required property var modelData
                        width: ListView.view.width
                        height: VfTheme.dp(86)
                        radius: VfTheme.dp(8)
                        color: ListView.isCurrentItem ? VfTheme.blueFill : VfTheme.surface
                        border.color: ListView.isCurrentItem ? "#60A5FA" : VfTheme.border

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.selectedIndex = index
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: VfTheme.dp(12)
                            spacing: VfTheme.dp(12)

                            Rectangle {
                                Layout.preferredWidth: VfTheme.dp(42)
                                Layout.preferredHeight: VfTheme.dp(42)
                                radius: VfTheme.dp(10)
                                color: VfTheme.blueFill
                                border.color: VfTheme.blueBorderSoft

                                Text {
                                    anchors.centerIn: parent
                                    text: "\u2191"
                                    color: "#2563EB"
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.dp(18)
                                    font.weight: Font.Bold
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: VfTheme.dp(4)

                                Text {
                                    Layout.fillWidth: true
                                    text: String(modelData.file_name || "")
                                    color: VfTheme.text
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.dp(13)
                                    font.weight: Font.DemiBold
                                    elide: Text.ElideRight
                                }

                                Text {
                                    Layout.fillWidth: true
                                    text: String(modelData.file_path || "")
                                    color: VfTheme.textSubtle
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.dp(11)
                                    elide: Text.ElideMiddle
                                }

                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: VfTheme.dp(12)

                                    Text {
                                        text: String(modelData.file_size_text || "")
                                        color: VfTheme.textMuted
                                        font.family: VfTheme.fontFamily
                                        font.pixelSize: VfTheme.dp(11)
                                    }

                                    Text {
                                        text: String(modelData.duration_text || "")
                                        color: VfTheme.textMuted
                                        font.family: VfTheme.fontFamily
                                        font.pixelSize: VfTheme.dp(11)
                                    }

                                    Text {
                                        text: String(modelData.uploaded_at_text || "")
                                        color: VfTheme.textMuted
                                        font.family: VfTheme.fontFamily
                                        font.pixelSize: VfTheme.dp(11)
                                        elide: Text.ElideRight
                                    }

                                    Text {
                                        text: modelData.api_key_suffix ? "***" + String(modelData.api_key_suffix) : ""
                                        color: VfTheme.textMuted
                                        font.family: VfTheme.fontFamily
                                        font.pixelSize: VfTheme.dp(11)
                                    }

                                    Item { Layout.fillWidth: true }
                                }
                            }

                            VfButton {
                                text: (void i18n.revision, i18n.t("clone.use_file", "Use file"))
                                minWidth: VfTheme.dp(104)
                                tone: "primary"
                                onClicked: root.useRequested(String(modelData.file_path || ""))
                            }
                        }
                    }

                    ScrollBar.vertical: ScrollBar {}
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: VfTheme.dp(8)

                Text {
                    Layout.fillWidth: true
                    text: root.currentRow()
                        ? (void i18n.revision, i18n.t("clone.file_added_to_queue", "File '{file_name}' has been added to Upload Queue.")).replace("{file_name}", String(root.currentRow().file_name || ""))
                        : (void i18n.revision, i18n.t("clone.no_videos_found", "No videos found"))
                    color: VfTheme.textSubtle
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(11)
                    visible: root.currentRow() !== null
                }

                VfButton {
                    text: (void i18n.revision, i18n.t("common.use", "Use"))
                    minWidth: VfTheme.dp(96)
                    enabled: root.currentRow() !== null
                    tone: "primary"
                    onClicked: {
                        var row = root.currentRow()
                        if (row)
                            root.useRequested(String(row.file_path || ""))
                    }
                }
            }
        }
    }

    Dialog {
        id: feedbackDialog

        modal: true
        parent: Overlay.overlay
        anchors.centerIn: parent
        width: VfDialogMetrics.width(parent, VfTheme.dp(390), VfTheme.dp(64))
        padding: VfTheme.dp(20)
        title: ""
        header: null
        closePolicy: Popup.CloseOnEscape

        background: Rectangle {
            radius: VfTheme.dp(12)
            color: VfTheme.surface
            border.color: VfTheme.border
        }

        contentItem: ColumnLayout {
            spacing: VfTheme.dp(12)

            Text {
                Layout.fillWidth: true
                text: root.feedbackTitle
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(18)
                font.weight: Font.DemiBold
                wrapMode: Text.WordWrap
            }

            Text {
                Layout.fillWidth: true
                text: root.feedbackMessage
                color: VfTheme.textSubtle
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(12)
                wrapMode: Text.WordWrap
            }

            RowLayout {
                Layout.fillWidth: true

                Item { Layout.fillWidth: true }

                VfButton {
                    text: (void i18n.revision, i18n.t("common.ok", "OK"))
                    minWidth: VfTheme.dp(96)
                    tone: "primary"
                    onClicked: feedbackDialog.close()
                }
            }
        }
    }
}
