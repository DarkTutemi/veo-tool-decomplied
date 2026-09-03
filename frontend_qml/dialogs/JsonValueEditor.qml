import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../components"
import "../theme"

Dialog {
    id: root

    property string keyName: ""
    property var value: ({})
    property var editedValue: ({})
    property string valueType: "object"
    property string jsonText: "{}"
    property var options: ({})
    property var validator: null
    property bool readOnly: false
    property string hostSurface: ""
    property string hostAction: "json_value_editor.save"
    property string statusText: ""
    property string errorText: ""

    signal saveRequested(string jsonText)
    signal valueSaveRequested(var payload)
    signal saved(var payload)
    signal blocked(var payload)

    title: root.keyName.length > 0 ? "Edit JSON value: " + root.keyName : "JSON Editor"
    header: Label {
        text: root.title
        visible: text.length > 0
        color: VfTheme.text
        font.family: VfTheme.fontFamily
        font.pixelSize: VfTheme.dp(16)
        font.weight: Font.DemiBold
        leftPadding: VfTheme.dp(16)
        rightPadding: VfTheme.dp(16)
        topPadding: VfTheme.dp(14)
        bottomPadding: VfTheme.dp(4)
    }
    parent: Overlay.overlay
    modal: true
    width: VfDialogMetrics.width(parent, 720, 48)
    height: VfDialogMetrics.height(parent, 560, 48)
    x: VfDialogMetrics.centerX(parent, width)
    y: VfDialogMetrics.centerY(parent, height)
    padding: VfTheme.dp(16)
    standardButtons: Dialog.NoButton
    onOpened: syncEditors()

    background: Rectangle {
        radius: VfTheme.dp(12)
        color: VfTheme.surface
        border.color: VfTheme.borderStrong
    }

    contentItem: ColumnLayout {
        spacing: VfTheme.dp(10)

        RowLayout {
            Layout.fillWidth: true
            spacing: VfTheme.dp(8)

            Label {
                Layout.preferredWidth: VfTheme.dp(78)
                text: "Key"
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontBody
            }

            TextField {
                id: keyInput
                Layout.fillWidth: true
                text: root.keyName
                readOnly: root.readOnly
                placeholderText: "JSON key/path"
                font.family: VfTheme.fontFamily
                background: Rectangle {
                    radius: VfTheme.radiusControl
                    color: root.readOnly ? VfTheme.surfaceSoft : VfTheme.surface
                    border.color: keyInput.activeFocus ? VfTheme.primary : VfTheme.borderBox
                }
            }

            Label {
                text: "Type"
                color: VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontSmall
            }

            NoScrollComboBox {
                id: typeCombo
                Layout.preferredWidth: VfTheme.dp(128)
                actionId: "json_value_editor.value_type"
                enabled: !root.readOnly
                model: ["string", "int", "float", "bool", "object", "array", "null"]
                currentIndex: root.typeIndex(root.valueType)
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontBody
                onActivated: {
                    root.valueType = String(currentText)
                    root.seedEditorForType()
                }

                background: Rectangle {
                    radius: VfTheme.radiusControl
                    color: typeCombo.enabled ? VfTheme.surface : VfTheme.surfaceSoft
                    border.color: typeCombo.activeFocus ? VfTheme.primary : VfTheme.borderBox
                }
            }
        }

        Label {
            Layout.fillWidth: true
            text: root.contractText()
            color: VfTheme.textMuted
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.fontSmall
            wrapMode: Text.WordWrap
        }

        StackLayout {
            id: editorStack
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: root.editorIndex(root.valueType)

            TextArea {
                id: stringInput
                readOnly: root.readOnly
                wrapMode: TextArea.Wrap
                selectByMouse: true
                color: VfTheme.text
                placeholderTextColor: VfTheme.textSubtle
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontBody
                background: Rectangle {
                    radius: VfTheme.radiusControl
                    color: root.readOnly ? VfTheme.surfaceSoft : VfTheme.surface
                    border.color: stringInput.activeFocus ? VfTheme.primary : VfTheme.borderBox
                }
            }

            TextField {
                id: numberInput
                readOnly: root.readOnly
                placeholderText: root.valueType === "int" ? "Integer value" : "Number value"
                font.family: "Consolas"
                font.pixelSize: VfTheme.dp(13)
                background: Rectangle {
                    radius: VfTheme.radiusControl
                    color: root.readOnly ? VfTheme.surfaceSoft : VfTheme.surface
                    border.color: numberInput.activeFocus ? VfTheme.primary : VfTheme.borderBox
                }
            }

            CheckBox {
                id: boolInput
                enabled: !root.readOnly
                text: checked ? "true" : "false"
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontBody
            }

            TextArea {
                id: jsonInput
                readOnly: root.readOnly || root.valueType === "null"
                wrapMode: TextArea.Wrap
                selectByMouse: true
                color: VfTheme.text
                placeholderTextColor: VfTheme.textSubtle
                font.family: "Consolas"
                font.pixelSize: VfTheme.dp(12)
                background: Rectangle {
                    radius: VfTheme.radiusControl
                    color: jsonInput.readOnly ? VfTheme.surfaceSoft : VfTheme.surface
                    border.color: jsonInput.activeFocus ? VfTheme.primary : VfTheme.borderBox
                }
            }
        }

        Label {
            Layout.fillWidth: true
            visible: root.errorText.length > 0 || root.statusText.length > 0
            text: root.errorText.length > 0 ? root.errorText : root.statusText
            color: root.errorText.length > 0 ? VfTheme.redBorder : VfTheme.textMuted
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.fontSmall
            wrapMode: Text.WordWrap
        }

        RowLayout {
            Layout.fillWidth: true
            Item { Layout.fillWidth: true }
            VfButton {
                text: "Cancel"
                minWidth: VfTheme.dp(96)
                onClicked: root.close()
            }

            VfButton {
                text: "Save"
                tone: "primary"
                minWidth: VfTheme.dp(96)
                enabled: !root.readOnly
                onClicked: root.save()
            }
        }
    }

    function detectType(input) {
        if (input === null)
            return "null"
        if (Array.isArray(input))
            return "array"
        if (typeof input === "boolean")
            return "bool"
        if (typeof input === "number")
            return Math.round(input) === input ? "int" : "float"
        if (typeof input === "string")
            return "string"
        return "object"
    }

    function typeIndex(typeName) {
        var names = ["string", "int", "float", "bool", "object", "array", "null"]
        for (var i = 0; i < names.length; i++) {
            if (names[i] === String(typeName || ""))
                return i
        }
        return 4
    }

    function editorIndex(typeName) {
        var clean = String(typeName || "")
        if (clean === "string")
            return 0
        if (clean === "int" || clean === "float")
            return 1
        if (clean === "bool")
            return 2
        return 3
    }

    function prettyJson(input) {
        try {
            var text = JSON.stringify(input, null, 2)
            return text === undefined ? "" : text
        } catch (error) {
            return String(input === undefined ? "" : input)
        }
    }

    function contractText() {
        return "Contract: openFor(key, value, options) -> valueSaveRequested({ key, value, value_type, json_text, host_surface, valid })."
    }

    function openFor(key, inputValue, editOptions) {
        root.options = editOptions || ({})
        root.keyName = String(key || "")
        root.value = inputValue
        root.editedValue = inputValue
        root.valueType = String(root.options.valueType || root.options.type || root.detectType(inputValue))
        root.readOnly = Boolean(root.options.readOnly)
        root.validator = root.options.validator || null
        root.hostSurface = String(root.options.hostSurface || root.options.surface || "")
        root.hostAction = String(root.options.hostAction || root.options.action || "json_value_editor.save")
        root.errorText = ""
        root.statusText = ""
        root.open()
    }

    function openForPayload(payload) {
        var data = payload || ({})
        var key = String(data.key || data.key_path || data.name || "")
        var inputValue = data.value
        var editOptions = data.options || ({})
        editOptions.valueType = data.value_type || data.type || editOptions.valueType
        editOptions.hostSurface = data.host_surface || data.hostSurface || editOptions.hostSurface
        editOptions.hostAction = data.action || editOptions.hostAction
        editOptions.readOnly = data.read_only || editOptions.readOnly
        root.openFor(key, inputValue, editOptions)
    }

    function openJson(inputText, editOptions) {
        var parsed = ({})
        try {
            parsed = JSON.parse(String(inputText || "{}"))
        } catch (error) {
            parsed = String(inputText || "")
        }
        root.openFor((editOptions || ({})).key || "json", parsed, editOptions || ({}))
    }

    function syncEditors() {
        keyInput.text = root.keyName
        typeCombo.currentIndex = root.typeIndex(root.valueType)
        if (root.valueType === "string") {
            stringInput.text = String(root.editedValue === undefined || root.editedValue === null ? "" : root.editedValue)
        } else if (root.valueType === "int" || root.valueType === "float") {
            numberInput.text = String(root.editedValue === undefined || root.editedValue === null ? 0 : root.editedValue)
        } else if (root.valueType === "bool") {
            boolInput.checked = Boolean(root.editedValue)
        } else if (root.valueType === "null") {
            jsonInput.text = "null"
        } else {
            jsonInput.text = root.prettyJson(root.editedValue)
        }
    }

    function seedEditorForType() {
        if (root.valueType === "string") {
            stringInput.text = String(root.editedValue === undefined || root.editedValue === null ? "" : root.editedValue)
        } else if (root.valueType === "int" || root.valueType === "float") {
            numberInput.text = root.valueType === "int" ? "0" : "0.0"
        } else if (root.valueType === "bool") {
            boolInput.checked = Boolean(root.editedValue)
        } else if (root.valueType === "array") {
            jsonInput.text = Array.isArray(root.editedValue) ? root.prettyJson(root.editedValue) : "[]"
        } else if (root.valueType === "null") {
            jsonInput.text = "null"
        } else {
            var currentType = root.detectType(root.editedValue)
            jsonInput.text = currentType === "object" ? root.prettyJson(root.editedValue) : "{}"
        }
    }

    function parseValue() {
        if (root.valueType === "string")
            return { ok: true, value: String(stringInput.text || "") }

        if (root.valueType === "int") {
            var intValue = parseInt(String(numberInput.text || ""), 10)
            if (!isFinite(intValue))
                return { ok: false, error: "Integer value is invalid." }
            return { ok: true, value: intValue }
        }

        if (root.valueType === "float") {
            var floatValue = Number(String(numberInput.text || ""))
            if (!isFinite(floatValue))
                return { ok: false, error: "Number value is invalid." }
            return { ok: true, value: floatValue }
        }

        if (root.valueType === "bool")
            return { ok: true, value: Boolean(boolInput.checked) }

        if (root.valueType === "null")
            return { ok: true, value: null }

        try {
            var parsed = JSON.parse(String(jsonInput.text || ""))
            if (root.valueType === "array" && !Array.isArray(parsed))
                return { ok: false, error: "Value must be a JSON array." }
            if (root.valueType === "object" && (parsed === null || Array.isArray(parsed) || typeof parsed !== "object"))
                return { ok: false, error: "Value must be a JSON object." }
            return { ok: true, value: parsed }
        } catch (error) {
            return { ok: false, error: String(error) }
        }
    }

    function payloadFor(parsedValue) {
        var text = root.prettyJson(parsedValue)
        return {
            key: String(keyInput.text || "").trim(),
            key_path: String(keyInput.text || "").trim(),
            value: parsedValue,
            value_type: root.valueType,
            json_text: text,
            host_surface: root.hostSurface,
            action: root.hostAction,
            valid: true
        }
    }

    function save() {
        root.errorText = ""
        if (root.readOnly) {
            root.applyBlocker(
                "json_value_editor_read_only",
                root.hostAction,
                "This JSON value is read-only for the current host."
            )
            return
        }
        var parsed = root.parseValue()
        if (!parsed.ok) {
            root.errorText = parsed.error
            return
        }

        var payload = root.payloadFor(parsed.value)
        if (typeof root.validator === "function") {
            var validation = root.validator(payload)
            if (validation !== true) {
                root.errorText = String(validation || "Value did not pass validation.")
                return
            }
        }

        root.keyName = payload.key
        root.editedValue = payload.value
        root.jsonText = payload.json_text
        root.saveRequested(payload.json_text)
        root.valueSaveRequested(payload)
        root.saved(payload)
        root.accept()
    }

    function structuredBlocker(code, action, message) {
        return {
            ok: false,
            blocked: true,
            code: code,
            error: code,
            action: action,
            message: message,
            key: String(keyInput.text || root.keyName || ""),
            host_surface: root.hostSurface,
            blocker: {
                code: code,
                action: action,
                message: message,
                host_surface: root.hostSurface,
                requires: ["writable host component contract"]
            }
        }
    }

    function applyBlocker(code, action, message) {
        var payload = root.structuredBlocker(code, action, message)
        root.errorText = message
        root.blocked(payload)
        return payload
    }
}
