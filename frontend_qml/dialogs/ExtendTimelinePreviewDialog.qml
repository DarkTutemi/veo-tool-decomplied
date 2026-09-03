import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../components"
import "../theme"

Dialog {
    id: root

    property string sessionKey: ""
    property string outputFolder: ""
    property var items: []
    property int selectedIndex: items.length > 0 ? 0 : -1

    signal openFolderRequested(string folder)
    signal openClipRequested(string path)
    signal playClipRequested(string path)

    modal: true
    parent: Overlay.overlay
    width: VfDialogMetrics.width(parent, VfTheme.dp(1280), VfTheme.dp(40))
    height: VfDialogMetrics.height(parent, VfTheme.dp(860), VfTheme.dp(40))
    x: VfDialogMetrics.centerX(parent, width)
    y: VfDialogMetrics.centerY(parent, height)
    padding: 0
    readonly property string dialogTitle: (void i18n.revision, i18n.t("extend.preview_title", "Preview Timeline"))
    title: ""
    header: null
    standardButtons: Dialog.NoButton

    function openFor(payload) {
        var data = payload || ({})
        root.sessionKey = String(data.session_key || "")
        root.outputFolder = String(data.output_folder || "")
        root.items = data.items || []
        root.selectedIndex = root.items.length > 0 ? 0 : -1
        root.open()
    }

    background: Rectangle {
        radius: VfTheme.dp(14)
        color: VfTheme.surface
        border.width: 1
        border.color: VfTheme.border
    }

    contentItem: ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: VfTheme.dp(58)
            color: VfTheme.surfaceSoft
            border.color: VfTheme.border
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.margins: VfTheme.dp(14)
                spacing: VfTheme.dp(10)

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: VfTheme.dp(2)

                    Text {
                        Layout.fillWidth: true
                        text: root.dialogTitle
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.dp(17)
                        font.weight: Font.DemiBold
                        color: VfTheme.text
                        elide: Text.ElideRight
                    }

                    Text {
                        Layout.fillWidth: true
                        text: root.outputFolder.length > 0 ? root.outputFolder : (void i18n.revision, i18n.t("extend.no_videos_preview", "No rendered videos available for preview."))
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.dp(11)
                        color: VfTheme.textSubtle
                        elide: Text.ElideMiddle
                    }
                }

                VfButton {
                    text: (void i18n.revision, i18n.t("common.close", "Close"))
                    minWidth: VfTheme.dp(84)
                    onClicked: root.close()
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: 16
            spacing: VfTheme.dp(10)

            RowLayout {
                Layout.fillWidth: true
                spacing: VfTheme.dp(8)

                VfStatusPill { label: (void i18n.revision, i18n.t("extend.preview_session_label", "Session")); value: root.sessionKey.length > 0 ? root.sessionKey : "-"; tone: "blue" }
                VfStatusPill { label: (void i18n.revision, i18n.t("extend.preview_clips_label", "Clips")); value: String(root.items.length); tone: root.items.length > 0 ? "green" : "red" }
                Item { Layout.fillWidth: true }

                VfButton {
                    text: (void i18n.revision, i18n.t("common.open_folder", "Open Folder"))
                    minWidth: VfTheme.dp(110)
                    enabled: root.outputFolder.length > 0
                    onClicked: root.openFolderRequested(root.outputFolder)
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: VfTheme.dp(12)
                color: VfTheme.surfaceSoft
                border.color: VfTheme.border

                StackLayout {
                    anchors.fill: parent
                    anchors.margins: VfTheme.dp(12)
                    currentIndex: root.items.length > 0 ? 1 : 0

                    Item {
                        Text {
                            anchors.centerIn: parent
                            text: (void i18n.revision, i18n.t("extend.no_videos_preview", "No rendered videos available for preview."))
                            color: VfTheme.textSubtle
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.dp(13)
                            wrapMode: Text.WordWrap
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }

                    ListView {
                        id: previewList
                        clip: true
                        spacing: VfTheme.dp(10)
                        model: root.items
                        reuseItems: true

                        delegate: VideoPreviewCard {
                            width: previewList.width
                            preview: modelData
                            title: String(modelData.title || modelData.name || "")
                            path: String(modelData.path || "")
                            status: String(modelData.errors && modelData.errors.length > 0 ? modelData.errors[0].message || modelData.errors[0].code : "")
                            index: Number(modelData.index || index)
                            total: Number(modelData.total || root.items.length)
                            selected: root.selectedIndex === index
                            onOpenRequested: root.selectedIndex = index
                            onPreviewRequested: root.selectedIndex = index
                            onOpenPathRequested: pathValue => root.openClipRequested(pathValue)
                            onPlayRequested: pathValue => root.playClipRequested(pathValue)
                        }
                    }
                }
            }
        }
    }
}
