import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ".."

Dialog {
    id: root
    objectName: "confirmDialog"
    property string message: ""
    property string confirmText: "Xác nhận"
    property bool destructive: false
    property bool confirmEnabled: true
    modal: true
    focus: true
    width: 440
    padding: 16
    standardButtons: Dialog.NoButton
    closePolicy: Popup.CloseOnEscape

    Shortcut {
        sequence: "Return"
        enabled: root.visible && root.confirmEnabled
        context: Qt.WindowShortcut
        onActivated: root.accept()
    }
    Shortcut {
        sequence: "Enter"
        enabled: root.visible && root.confirmEnabled
        context: Qt.WindowShortcut
        onActivated: root.accept()
    }

    header: Rectangle {
        objectName: root.objectName + "_header"
        implicitHeight: 54
        color: Theme.panel
        Accessible.name: root.title
        Accessible.role: Accessible.Heading
        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 16
            anchors.rightMargin: 16
            spacing: 10
            UiIcon {
                visible: root.destructive
                name: "semantic/alert-triangle"
                tone: Theme.danger
                iconSize: 18
            }
            Text {
                Layout.fillWidth: true
                text: root.title
                color: Theme.text
                font.pixelSize: 16
                font.weight: Font.DemiBold
                elide: Text.ElideRight
            }
        }
        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: 1
            color: Theme.borderSoft
        }
    }

    contentItem: Text {
        objectName: "confirmDialogContent"
        width: 380
        text: root.message
        color: Theme.textMuted
        font.pixelSize: 13
        wrapMode: Text.Wrap
        Accessible.name: root.title + ". " + root.message
        Accessible.role: Accessible.StaticText
    }

    footer: Rectangle {
        objectName: root.objectName + "_footer"
        implicitHeight: 60
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
                objectName: "confirmDialogCancelButton"
                text: "Hủy"
                Accessible.name: text
                onClicked: root.reject()
            }
            AppButton {
                objectName: "confirmDialogConfirmButton"
                text: root.confirmText
                leadingIcon: root.destructive ? "semantic/alert-triangle" : ""
                iconTone: root.destructive ? Theme.danger : "white"
                primary: true
                enabled: root.confirmEnabled
                availabilityReason: enabled ? "" : "Chưa đủ dữ liệu hợp lệ"
                Accessible.name: text
                onClicked: root.accept()
            }
        }
    }

    background: Rectangle {
        objectName: root.objectName + "_background"
        radius: Theme.radiusLarge
        color: Theme.panel
        border.width: 1
        border.color: root.destructive ? Theme.danger : Theme.border
        Accessible.name: root.title
        Accessible.role: Accessible.Dialog
    }
}
