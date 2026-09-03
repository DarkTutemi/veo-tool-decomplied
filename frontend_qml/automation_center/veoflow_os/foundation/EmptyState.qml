import QtQuick
import QtQuick.Layouts
import ".."

Item {
    id: root
    objectName: "emptyState"
    property string title: "Chưa có dữ liệu"
    property string description: "Dữ liệu sẽ xuất hiện tại đây khi sẵn sàng."
    property string iconName: "semantic/info"
    property string eyebrow: "SẴN SÀNG BẮT ĐẦU"
    property var guidance: []
    property string actionText: ""
    property string actionIconName: "ui/plus"
    property bool actionEnabled: true
    property string actionReason: ""
    property string secondaryActionText: ""
    property string secondaryActionIconName: "ui/refresh-cw"
    property bool secondaryActionEnabled: true
    property string secondaryActionReason: ""
    signal actionTriggered()
    signal secondaryActionTriggered()
    implicitWidth: 720
    implicitHeight: 360
    Accessible.name: title + ". " + description
    Accessible.role: Accessible.Client

    Rectangle {
        id: panel
        objectName: "emptyStatePanel"
        anchors.centerIn: parent
        width: Math.min(Math.max(0, root.width - 32), 760)
        height: Math.min(Math.max(0, root.height - 32), root.guidance.length > 0 ? 360 : 276)
        radius: Theme.radiusLarge
        color: Theme.panel
        border.width: 1
        border.color: Theme.borderSoft

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Theme.space6
            spacing: Theme.space3

            Rectangle {
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 56
                Layout.preferredHeight: 56
                radius: 18
                color: Theme.accentSoft
                border.width: 1
                border.color: Theme.accent

                UiIcon {
                    id: stateIcon
                    objectName: "emptyStateIcon"
                    anchors.centerIn: parent
                    name: root.iconName
                    tone: Theme.accent
                    iconSize: 27
                }
            }

            Text {
                visible: root.eyebrow.length > 0
                Layout.fillWidth: true
                text: root.eyebrow
                color: Theme.accent
                font.pixelSize: Theme.fontMetadata
                font.weight: Font.DemiBold
                font.letterSpacing: 0.8
                horizontalAlignment: Text.AlignHCenter
            }
            Text {
                Layout.fillWidth: true
                text: root.title
                color: Theme.text
                font.pixelSize: 20
                font.weight: Font.DemiBold
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.Wrap
            }
            Text {
                Layout.fillWidth: true
                text: root.description
                color: Theme.textMuted
                font.pixelSize: Theme.fontBody
                lineHeight: 1.35
                wrapMode: Text.Wrap
                horizontalAlignment: Text.AlignHCenter
            }

            RowLayout {
                objectName: "emptyStateGuideRow"
                property int guideCount: guideRepeater.count
                visible: root.guidance.length > 0
                Layout.fillWidth: true
                Layout.preferredHeight: visible ? 82 : 0
                spacing: Theme.space2

                Repeater {
                    id: guideRepeater
                    model: root.guidance.slice(0, 3)
                    delegate: Rectangle {
                        id: guideCard
                        required property var modelData
                        required property int index
                        objectName: "emptyStateGuide_" + String(guideCard.index)
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: Theme.radiusMedium
                        color: Theme.elevated
                        border.width: 1
                        border.color: Theme.borderSoft
                        Accessible.role: Accessible.StaticText
                        Accessible.name: String(guideCard.modelData.title || "")
                            + ". " + String(guideCard.modelData.description || "")

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: Theme.space3
                            spacing: Theme.space2

                            Rectangle {
                                Layout.preferredWidth: 26
                                Layout.preferredHeight: 26
                                radius: 13
                                color: Theme.accentSoft
                                Text {
                                    anchors.centerIn: parent
                                    text: String(guideCard.index + 1)
                                    color: Theme.accent
                                    font.pixelSize: Theme.fontMetadata
                                    font.weight: Font.Bold
                                }
                            }
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2
                                Text {
                                    Layout.fillWidth: true
                                    text: String(guideCard.modelData.title || "")
                                    color: Theme.text
                                    font.pixelSize: Theme.fontBody
                                    font.weight: Font.DemiBold
                                    elide: Text.ElideRight
                                }
                                Text {
                                    Layout.fillWidth: true
                                    text: String(guideCard.modelData.description || "")
                                    color: Theme.textFaint
                                    font.pixelSize: Theme.fontMetadata
                                    maximumLineCount: 2
                                    elide: Text.ElideRight
                                    wrapMode: Text.Wrap
                                }
                            }
                        }
                    }
                }
            }

            RowLayout {
                visible: root.actionText.length > 0 || root.secondaryActionText.length > 0
                Layout.alignment: Qt.AlignHCenter
                spacing: Theme.space2

                AppButton {
                    objectName: "emptyStateActionButton"
                    visible: root.actionText.length > 0
                    Layout.minimumWidth: 156
                    text: root.actionText
                    leadingIcon: root.actionIconName
                    primary: true
                    enabled: root.actionEnabled
                    availabilityReason: root.actionReason
                    onClicked: root.actionTriggered()
                }
                AppButton {
                    objectName: "emptyStateSecondaryActionButton"
                    visible: root.secondaryActionText.length > 0
                    Layout.minimumWidth: 132
                    text: root.secondaryActionText
                    leadingIcon: root.secondaryActionIconName
                    enabled: root.secondaryActionEnabled
                    availabilityReason: root.secondaryActionReason
                    onClicked: root.secondaryActionTriggered()
                }
            }

            Text {
                visible: (root.actionText.length > 0 && !root.actionEnabled
                    && root.actionReason.length > 0)
                    || (root.secondaryActionText.length > 0
                        && !root.secondaryActionEnabled
                        && root.secondaryActionReason.length > 0)
                Layout.fillWidth: true
                text: !root.actionEnabled && root.actionReason.length > 0
                    ? root.actionReason : root.secondaryActionReason
                color: Theme.warning
                font.pixelSize: Theme.fontMetadata
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.Wrap
            }
        }
    }
}
