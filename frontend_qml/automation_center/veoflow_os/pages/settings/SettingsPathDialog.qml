pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../.."

SettingsDialog {
    id: root

    objectName: "settingsPathDialog"
    title: "Cập nhật đường dẫn"
    width: Math.min(620, (parent ? parent.width : 680) - 32)
    height: 224
    x: parent ? Math.max(16, (parent.width - width) / 2) : 0
    y: parent ? Math.max(16, (parent.height - height) / 2) : 0
    property string settingKey: ""
    property string pathValue: ""
    signal pathAccepted(string settingKey, string pathValue)

    function openFor(key, value) {
        root.settingKey = String(key || "")
        root.pathValue = String(value || "")
        pathField.text = root.pathValue
        root.open()
        Qt.callLater(function() { pathField.forceActiveFocus() })
        return true
    }

    contentItem: ColumnLayout {
        spacing: 8
        Text {
            Layout.fillWidth: true
            text: "Nhập đường dẫn tuyệt đối. Backend sẽ kiểm tra phạm vi và quyền truy cập khi áp dụng."
            color: Theme.textMuted
            font.pixelSize: 11
            wrapMode: Text.Wrap
        }
        TextField {
            id: pathField
            objectName: "settingsPathValue"
            Layout.fillWidth: true
            implicitHeight: 38
            activeFocusOnTab: true
            color: Theme.text
            placeholderText: "D:/VeoFlow/Downloads"
            placeholderTextColor: Theme.textFaint
            Accessible.name: "Đường dẫn cho " + root.settingKey
            background: Rectangle {
                radius: Theme.radiusSmall
                color: Theme.elevated
                border.width: pathField.activeFocus ? 2 : 1
                border.color: pathField.activeFocus ? Theme.accent : Theme.border
            }
            onAccepted: acceptButton.clicked()
        }
        Text {
            objectName: "settingsPathValidationText"
            Layout.fillWidth: true
            text: pathField.text.trim().length > 0
                ? "Giá trị sẽ chỉ được lưu sau khi nhấn Áp dụng ở màn hình Cài đặt."
                : "Đường dẫn không được để trống."
            color: pathField.text.trim().length > 0 ? Theme.textFaint : Theme.warning
            font.pixelSize: 11
            wrapMode: Text.Wrap
        }
    }

    footer: Rectangle {
        objectName: "settingsPathDialog_footer"
        implicitHeight: 56
        color: Theme.panel
        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 16
            anchors.rightMargin: 16
            spacing: 8
            Item { Layout.fillWidth: true }
            AppButton {
                objectName: "settingsPathCancelButton"
                text: "Hủy"
                activeFocusOnTab: true
                Accessible.name: text
                onClicked: root.close()
            }
            AppButton {
                id: acceptButton
                objectName: "settingsPathAcceptButton"
                text: "Dùng đường dẫn"
                primary: true
                activeFocusOnTab: true
                enabled: pathField.text.trim().length > 0
                Accessible.name: text
                Accessible.description: enabled ? "" : "Đường dẫn không được để trống"
                onClicked: {
                    if (!enabled)
                        return
                    root.pathAccepted(root.settingKey, pathField.text.trim())
                    root.close()
                }
            }
        }
    }
}
