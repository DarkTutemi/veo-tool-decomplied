pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import "../.."
import "../../foundation" as Foundation

Item {
    id: root
    objectName: "settingEditor_" + String((definition || {}).key || "unknown")
    property var definition: ({})
    property var sourceValue: ""
    property var editorValue: ""
    property bool editable: false
    property bool compact: false
    readonly property var editorDescriptor: root.memberMap(definition, "editor")
    readonly property var effectDescriptor: root.memberMap(editorDescriptor, "effect")
    readonly property bool effectConnected: effectDescriptor.connected === true
    readonly property string editReason: root.editable ? ""
        : String(root.editorDescriptor.reason_code
            || "Không có quyền sửa cài đặt hoặc đang áp dụng thay đổi")
    readonly property bool secretConfigured: Boolean((definition || {}).configured)
    readonly property string accessibleDescription: {
        const item = root.definition || ({})
        const type = String(item.value_type || "unknown")
        if (String(item.sensitivity || "") === "secret" || type === "secret")
            return root.secretConfigured ? "Giá trị bí mật đã được cấu hình" : "Giá trị bí mật chưa được cấu hình"
        return "Kiểu " + type + ", phạm vi " + String(item.scope || "không rõ")
            + (root.effectConnected ? "" : ". Chưa kết nối hiệu lực vận hành")
    }
    signal valueEdited(string key, var value)
    signal browseRequested(string key)
    implicitHeight: root.compact ? 62 : 68
    Accessible.name: String((definition || {}).title || (definition || {}).key || "Cài đặt")
    Accessible.description: accessibleDescription
    Accessible.role: Accessible.Client

    onSourceValueChanged: editorValue = sourceValue
    Component.onCompleted: editorValue = sourceValue

    function memberMap(owner, key) {
        if (owner === null || owner === undefined || typeof owner !== "object")
            return ({})
        const value = owner[key]
        return value !== null && value !== undefined && typeof value === "object"
            ? value : ({})
    }

    function actionAvailable(action) {
        return action !== null && action !== undefined
            && typeof action === "object" && action.available === true
    }

    function actionReason(action, fallback) {
        if (root.actionAvailable(action))
            return ""
        const reason = action !== null && action !== undefined
            && typeof action === "object" ? String(action.reason_code || "") : ""
        return reason.length > 0 ? reason : String(fallback || "Hành động không khả dụng")
    }

    function commitEditorValue() {
        root.valueEdited(String((root.definition || {}).key || ""), root.editorValue)
        return true
    }

    RowLayout {
        anchors.fill: parent
        spacing: 14
        visible: !root.compact

        ColumnLayout {
            Layout.fillWidth: true
            Layout.minimumWidth: 210
            spacing: 3
            Text {
                Layout.fillWidth: true
                text: String((root.definition || {}).title || (root.definition || {}).key || "Không có tên")
                color: Theme.text
                font.pixelSize: 12
                font.weight: Font.DemiBold
                elide: Text.ElideRight
            }
            RowLayout {
                spacing: 6
                Text {
                    text: String((root.definition || {}).key || "—")
                    color: Theme.textFaint
                    font.pixelSize: 11
                    elide: Text.ElideMiddle
                    Layout.maximumWidth: 260
                }
                Foundation.StatusPill {
                    visible: Boolean((root.definition || {}).requires_restart)
                    text: "Cần khởi động lại"
                    tone: Theme.warning
                    showDot: false
                    implicitHeight: 20
                }
                Foundation.StatusPill {
                    visible: String((root.definition || {}).sensitivity || "") === "secret"
                    text: root.secretConfigured ? "Đã cấu hình" : "Chưa cấu hình"
                    tone: root.secretConfigured ? Theme.success : Theme.warning
                    showDot: true
                    implicitHeight: 20
                }
            }
        }

        Loader {
            id: editorLoader
            active: !root.compact
            Layout.preferredWidth: 260
            Layout.preferredHeight: 38
            sourceComponent: {
                const type = String((root.definition || {}).value_type || "")
                if (type === "boolean") return booleanEditor
                if (type === "enum") return enumEditor
                if (type === "integer") return integerEditor
                if (type === "secret") return secretEditor
                return textEditor
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 3
        visible: root.compact
        RowLayout {
            Layout.fillWidth: true
            spacing: 6
            Text {
                Layout.fillWidth: true
                text: String((root.definition || {}).title
                    || (root.definition || {}).key || "Không có tên")
                color: Theme.text
                font.pixelSize: 11
                font.weight: Font.DemiBold
                elide: Text.ElideRight
            }
            Foundation.StatusPill {
                visible: Boolean((root.definition || {}).requires_restart)
                text: "Restart"
                tone: Theme.warning
                showDot: false
                implicitHeight: 18
            }
        }
        Loader {
            active: root.compact
            Layout.fillWidth: true
            Layout.preferredHeight: 34
            sourceComponent: {
                const type = String((root.definition || {}).value_type || "")
                if (type === "boolean") return booleanEditor
                if (type === "enum") return enumEditor
                if (type === "integer") return integerEditor
                if (type === "secret") return secretEditor
                return textEditor
            }
        }
    }

    Component {
        id: booleanEditor
        SettingsSwitch {
            id: booleanControl
            objectName: root.objectName + "_boolean"
            activeFocusOnTab: true
            enabled: root.editable
            availabilityReason: root.editReason
            checked: Boolean(root.editorValue)
            text: checked ? "Bật" : "Tắt"
            Accessible.name: String((root.definition || {}).title || "Tùy chọn") + ": " + text
            onToggled: {
                root.editorValue = checked
                root.commitEditorValue()
            }
        }
    }

    Component {
        id: enumEditor
        SettingsComboBox {
            id: enumControl
            objectName: root.objectName + "_enum"
            activeFocusOnTab: true
            enabled: root.editable
            availabilityReason: root.editReason
            model: root.editorDescriptor.options || []
            function indexForValue(value) {
                for (let index = 0; index < model.length; index++) {
                    if (String(enumControl.optionValue(model[index])) === String(value))
                        return index
                }
                return model.length > 0 ? 0 : -1
            }
            Component.onCompleted: currentIndex = indexForValue(root.editorValue)
            Connections {
                target: root
                function onEditorValueChanged() {
                    enumControl.currentIndex = enumControl.indexForValue(root.editorValue)
                }
            }
            Accessible.name: String((root.definition || {}).title || "Lựa chọn")
            onOptionSelected: function(index, option) {
                root.editorValue = enumControl.optionValue(option)
                root.commitEditorValue()
            }
        }
    }

    Component {
        id: integerEditor
        SettingsSpinBox {
            id: integerControl
            objectName: root.objectName + "_integer"
            activeFocusOnTab: true
            enabled: root.editable
            availabilityReason: root.editReason
            from: {
                const minimum = root.editorDescriptor.minimum
                return minimum === undefined || minimum === null ? -2147483647 : Number(minimum)
            }
            to: {
                const maximum = root.editorDescriptor.maximum
                return maximum === undefined || maximum === null ? 2147483647 : Number(maximum)
            }
            value: Number(root.editorValue || 0)
            editable: true
            Accessible.name: String((root.definition || {}).title || "Số nguyên")
            onValueModified: {
                root.editorValue = value
                root.commitEditorValue()
            }
        }
    }

    Component {
        id: secretEditor
        SettingsTextField {
            id: secretControl
            availabilityReason: root.editReason
            objectName: root.objectName + "_secret"
            activeFocusOnTab: true
            enabled: root.editable
            echoMode: TextInput.Password
            text: String(root.editorValue || "")
            placeholderText: root.secretConfigured ? "Nhập giá trị mới để thay thế" : "Nhập giá trị bí mật"
            Accessible.name: String((root.definition || {}).title || "Giá trị bí mật")
            Accessible.description: enabled ? root.accessibleDescription
                : availabilityReason
            onEditingFinished: {
                root.editorValue = text
                root.commitEditorValue()
            }
        }
    }

    Component {
        id: textEditor
        RowLayout {
            spacing: 6
            SettingsTextField {
                id: textControl
                availabilityReason: root.editReason
                objectName: root.objectName + "_text"
                Layout.fillWidth: true
                activeFocusOnTab: true
                enabled: root.editable
                text: String(root.editorValue === undefined || root.editorValue === null ? "" : root.editorValue)
                Accessible.name: String((root.definition || {}).title || "Giá trị")
                Accessible.description: availabilityReason
                onEditingFinished: {
                    root.editorValue = text
                    root.commitEditorValue()
                }
            }
            AppButton {
                objectName: root.objectName + "_browse"
                readonly property var browseAction: root.memberMap(
                    root.editorDescriptor, "browse_action")
                visible: String(browseAction.kind || "") === "local_path_picker"
                enabled: root.editable && visible && root.actionAvailable(browseAction)
                availabilityReason: enabled ? "" : (!root.editable
                    ? root.editReason
                    : visible ? root.actionReason(browseAction,
                        "Không thể mở trình chọn đường dẫn")
                    : "Backend không cung cấp hành động sửa đường dẫn")
                text: "Sửa…"
                activeFocusOnTab: true
                Accessible.name: "Sửa " + String((root.definition || {}).title || "đường dẫn")
                onClicked: root.browseRequested(String((root.definition || {}).key || ""))
            }
        }
    }
}
