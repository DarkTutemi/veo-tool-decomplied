pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import "../.."
import "../../foundation" as Foundation

Rectangle {
    id: root
    objectName: "automationTemplatesPanel"
    property var section: ({})
    signal instantiateRequested(var item)

    radius: Theme.radiusLarge
    color: Theme.panel
    border.width: 1
    border.color: Theme.borderSoft
    clip: true
    Accessible.name: "Catalog template workflow từ server"
    Accessible.role: Accessible.Pane

    readonly property var items: root.section.items || []

    ColumnLayout {
        anchors.fill: parent
        spacing: 0
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 62
            Layout.leftMargin: 16
            Layout.rightMargin: 16
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2
                Text { text: "Template workflow"; color: Theme.text; font.pixelSize: Theme.fontSection; font.weight: Font.DemiBold }
                Text { text: String(root.section.total || root.items.length) + " template định nghĩa bởi server"; color: Theme.textFaint; font.pixelSize: 11 }
            }
            Foundation.StatusPill { text: "Server catalog"; tone: Theme.success }
        }
        Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Theme.borderSoft }

        GridView {
            id: templateGrid
            objectName: "automationTemplateGrid"
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: 12
            cellWidth: Math.max(330, width / Math.max(1, Math.floor(width / 330)))
            cellHeight: 220
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            model: root.items
            delegate: Item {
                id: templateCell
                required property var modelData
                readonly property string templateKey: String(templateCell.modelData.template_key || "")
                readonly property var instantiateAction:
                    (templateCell.modelData.actions || {}).instantiate || ({})
                width: templateGrid.cellWidth
                height: templateGrid.cellHeight
                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 5
                    radius: Theme.radiusMedium
                    color: Theme.elevated
                    border.width: 1
                    border.color: Theme.borderSoft
                    Accessible.name: "Template " + templateCell.templateKey
                    Accessible.role: Accessible.Grouping
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 14
                        spacing: 8
                        RowLayout {
                            Layout.fillWidth: true
                            Rectangle {
                                Layout.preferredWidth: 36
                                Layout.preferredHeight: 36
                                radius: 9
                                color: Theme.accentSoft
                                UiIcon { anchors.centerIn: parent; name: "semantic/workflow"; tone: Theme.accent; iconSize: 20 }
                            }
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2
                                Text { Layout.fillWidth: true; text: String(templateCell.modelData.name || templateCell.templateKey || "Template"); color: Theme.text; font.pixelSize: 13; font.weight: Font.DemiBold; elide: Text.ElideRight }
                                Text { Layout.fillWidth: true; text: templateCell.templateKey + " · v" + String(templateCell.modelData.version || "—"); color: Theme.textFaint; font.pixelSize: 11; elide: Text.ElideRight }
                            }
                            Foundation.StatusPill { text: String(templateCell.modelData.category || "—"); tone: Theme.accent }
                        }
                        Text { Layout.fillWidth: true; Layout.preferredHeight: 44; text: String(templateCell.modelData.description || ""); color: Theme.textMuted; font.pixelSize: 11; wrapMode: Text.Wrap; elide: Text.ElideRight; maximumLineCount: 2 }
                        Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Theme.borderSoft }
                        RowLayout {
                            Layout.fillWidth: true
                            Text { text: String(((templateCell.modelData.definition || {}).steps || []).length) + " bước"; color: Theme.textMuted; font.pixelSize: 11 }
                            Text { text: "·"; color: Theme.textFaint; font.pixelSize: 11 }
                            Text { text: String(((templateCell.modelData.definition || {}).triggers || []).length) + " trigger"; color: Theme.textMuted; font.pixelSize: 11 }
                            Item { Layout.fillWidth: true }
                            Text { text: String(templateCell.modelData.source || "server_catalog"); color: Theme.success; font.pixelSize: 11 }
                        }
                        Item { Layout.fillHeight: true }
                        AppButton {
                            objectName: "automationTemplateInstantiate_" + templateCell.templateKey
                            Layout.fillWidth: true
                            text: "Dùng template"
                            primary: true
                            enabled: Boolean(templateCell.instantiateAction.available)
                            availabilityReason: enabled ? "" : String(templateCell.instantiateAction.reason_code || "Server không cho phép tạo từ template")
                            onClicked: root.instantiateRequested(templateCell.modelData)
                        }
                    }
                }
            }
        }

        Text {
            visible: root.items.length === 0
            Layout.alignment: Qt.AlignHCenter
            Layout.bottomMargin: 24
            text: "Catalog server chưa có template khả dụng"
            color: Theme.textFaint
            font.pixelSize: 12
        }
    }
}
