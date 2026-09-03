import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../.."

Dialog {
    id: control

    property string acceptText: "Lưu"
    property string cancelText: "Hủy"
    property bool acceptEnabled: true
    property bool showDefaultFooter: true

    modal: true
    focus: true
    padding: 12
    standardButtons: Dialog.NoButton
    closePolicy: Popup.CloseOnEscape

    Shortcut {
        sequence: "Return"
        enabled: control.visible && control.showDefaultFooter
            && control.acceptEnabled
        context: Qt.WindowShortcut
        onActivated: control.accept()
    }
    Shortcut {
        sequence: "Enter"
        enabled: control.visible && control.showDefaultFooter
            && control.acceptEnabled
        context: Qt.WindowShortcut
        onActivated: control.accept()
    }

    header: Rectangle {
        objectName: control.objectName + "_header"
        implicitHeight: 54
        color: Theme.panel
        Accessible.name: control.title
        Accessible.role: Accessible.Heading

        Text {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 16
            anchors.rightMargin: 16
            text: control.title
            color: Theme.text
            font.pixelSize: 16
            font.weight: Font.DemiBold
            elide: Text.ElideRight
        }

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: 1
            color: Theme.borderSoft
        }
    }

    footer: Rectangle {
        objectName: control.objectName + "_footer"
        visible: control.showDefaultFooter
        implicitHeight: visible ? 60 : 0
        color: Theme.panel

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            height: 1
            color: Theme.borderSoft
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 12
            spacing: 8

            Item { Layout.fillWidth: true }

            AppButton {
                objectName: control.objectName + "_cancelButton"
                text: control.cancelText
                Accessible.name: control.cancelText
                onClicked: control.reject()
            }

            AppButton {
                objectName: control.objectName + "_acceptButton"
                text: control.acceptText
                primary: true
                enabled: control.acceptEnabled
                availabilityReason: enabled ? "" : "Chưa đủ dữ liệu hợp lệ"
                Accessible.name: control.acceptText
                onClicked: control.accept()
            }
        }
    }

    background: Rectangle {
        radius: Theme.radiusLarge
        color: Theme.panel
        border.width: 1
        border.color: Theme.border
        Accessible.name: control.title
        Accessible.role: Accessible.Dialog
    }
}
