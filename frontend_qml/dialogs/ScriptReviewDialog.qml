import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../components"
import "../theme"

Dialog {
    id: root

    property string scriptText: ""
    property string mode: "normal"
    property var originalScriptData: null
    property string validationMessage: ""
    property string feedbackTitle: ""
    property string feedbackMessage: ""

    signal approveRequested(string scriptText, var scriptData)
    signal scriptApproved(var scriptData)

    title: (void i18n.revision, i18n.t("script_review.window_title", "Review Script ({mode})")).replace("{mode}", String(root.mode || "normal").toUpperCase())
    header: null
    modal: true
    parent: Overlay.overlay
    width: VfDialogMetrics.width(parent, VfTheme.dp(1500), VfTheme.dp(48))
    height: VfDialogMetrics.height(parent, VfTheme.dp(1000), VfTheme.dp(48))
    x: VfDialogMetrics.centerX(parent, width)
    y: VfDialogMetrics.centerY(parent, height)
    padding: 0

    onOpened: {
        root.validationMessage = ""
        try {
            editor.text = root.displayScriptText()
        } catch (err) {
            root.feedbackTitle = (void i18n.revision, i18n.t("common.error", "Error"))
            root.feedbackMessage = (void i18n.revision, i18n.t("script_review.load_error", "Could not load review data: {error}"))
                .replace("{error}", String(err))
            feedbackDialog.open()
            editor.text = root.scriptText
        }
    }

    function modeIcon() {
        if (root.mode === "multi_asset")
            return "artist-palette"
        if (root.mode === "script_splitting")
            return "scissors"
        return "memo"
    }

    function modeDescription() {
        if (root.mode === "multi_asset")
            return (void i18n.revision, i18n.t("script_review.mode_multi_asset", "Multi-asset script review"))
        if (root.mode === "script_splitting")
            return (void i18n.revision, i18n.t("script_review.mode_script_splitting", "Script splitting review"))
        return (void i18n.revision, i18n.t("script_review.mode_normal", "Kịch bản đầy đủ"))
    }

    function fieldsInfo() {
        if (root.mode === "multi_asset")
            return "metadata, scenes"
        if (root.mode === "script_splitting")
            return "scenes, asset_library (minimal)"
        return "asset_library, metadata, scenes"
    }

    function looksLikeHiddenPayload(value) {
        var text = String(value || "")
        return text.indexOf("[BASE64_IMAGE_DATA") === 0 || text.indexOf("[THUMBNAIL_DATA") === 0
    }

    function filterBase64ForDisplay(value) {
        if (value === null || value === undefined)
            return value
        if (Array.isArray(value)) {
            var filteredList = []
            for (var listIndex = 0; listIndex < value.length; ++listIndex)
                filteredList.push(root.filterBase64ForDisplay(value[listIndex]))
            return filteredList
        }
        if (typeof value !== "object")
            return value
        var filtered = {}
        var keys = Object.keys(value)
        for (var i = 0; i < keys.length; ++i) {
            var key = keys[i]
            var item = value[key]
            if (key === "base64" && typeof item === "string" && item.length > 100)
                filtered[key] = "[BASE64_IMAGE_DATA - hidden for display]"
            else if (key === "thumbnail_base64" && typeof item === "string" && item.length > 100)
                filtered[key] = "[THUMBNAIL_DATA - hidden for display]"
            else
                filtered[key] = root.filterBase64ForDisplay(item)
        }
        return filtered
    }

    function displayScriptText() {
        if (root.originalScriptData && typeof root.originalScriptData === "object") {
            var filtered = root.filterBase64ForDisplay(root.originalScriptData)
            return JSON.stringify(filtered, null, 2)
        }
        return String(root.scriptText || "")
    }

    function restoreHiddenPayload(edited, original) {
        if (!original || typeof original !== "object")
            return edited
        if (Array.isArray(edited)) {
            var restoredList = []
            for (var listIndex = 0; listIndex < edited.length; ++listIndex) {
                var originalItem = Array.isArray(original) && listIndex < original.length ? original[listIndex] : null
                restoredList.push(root.restoreHiddenPayload(edited[listIndex], originalItem))
            }
            return restoredList
        }
        if (!edited || typeof edited !== "object")
            return edited
        var restored = {}
        var editedKeys = Object.keys(edited)
        for (var i = 0; i < editedKeys.length; ++i) {
            var key = editedKeys[i]
            var value = edited[key]
            var originalValue = original && typeof original === "object" ? original[key] : null
            if ((key === "base64" || key === "thumbnail_base64") && root.looksLikeHiddenPayload(value) && typeof originalValue === "string" && originalValue.length > 0)
                restored[key] = originalValue
            else
                restored[key] = root.restoreHiddenPayload(value, originalValue)
        }
        return restored
    }

    function prettyJson(text) {
        var parsed = JSON.parse(text)
        return JSON.stringify(parsed, null, 2)
    }

    function formatEditor() {
        try {
            editor.text = prettyJson(editor.text)
            root.validationMessage = (void i18n.revision, i18n.t("script_review.formatted", "JSON formatted."))
        } catch (err) {
            root.feedbackTitle = (void i18n.revision, i18n.t("script_review.invalid_json_title", "Invalid JSON"))
            root.feedbackMessage = (void i18n.revision, i18n.t("script_review.syntax_error", "Syntax error")).replace("{line}", String(err.lineNumber || "")).replace("{col}", String(err.columnNumber || "")).replace("{msg}", String(err.message || err))
            feedbackDialog.open()
            root.validationMessage = root.feedbackMessage
        }
    }

    function sceneHasAction(scene) {
        if (!scene || typeof scene !== "object")
            return false
        var beats = scene.script || []
        if (beats && beats.length) {
            for (var i = 0; i < beats.length; ++i) {
                var beat = beats[i]
                if (beat && typeof beat === "object" && String(beat.action || "").trim().length > 0)
                    return true
            }
        }
        var fallback = String(scene.visual || scene.veo3_prompt || scene.visual_description || "")
        return fallback.trim().length > 0
    }

    function validateScriptData(data) {
        if (root.mode === "normal") {
            if (!data.asset_library) {
                root.feedbackTitle = (void i18n.revision, i18n.t("script_review.validation_error_title", "Validation error"))
                root.feedbackMessage = (void i18n.revision, i18n.t("script_review.need_asset_library", "asset_library is required."))
                return false
            }
            if (!data.metadata) {
                root.feedbackTitle = (void i18n.revision, i18n.t("script_review.validation_error_title", "Validation error"))
                root.feedbackMessage = (void i18n.revision, i18n.t("script_review.need_metadata", "metadata is required."))
                return false
            }
        } else if (root.mode === "multi_asset") {
            if (!data.metadata) {
                root.feedbackTitle = (void i18n.revision, i18n.t("script_review.validation_error_title", "Validation error"))
                root.feedbackMessage = (void i18n.revision, i18n.t("script_review.need_metadata", "metadata is required."))
                return false
            }
        }

        var scenes = data.scenes || []
        if (!scenes.length) {
            root.feedbackTitle = (void i18n.revision, i18n.t("script_review.validation_error_title", "Validation error"))
            root.feedbackMessage = (void i18n.revision, i18n.t("script_review.need_at_least_one_scene", "At least one scene is required."))
            return false
        }

        for (var i = 0; i < scenes.length; ++i) {
            if (!scenes[i] || typeof scenes[i] !== "object") {
                root.feedbackTitle = (void i18n.revision, i18n.t("script_review.validation_error_title", "Validation error"))
                root.feedbackMessage = (void i18n.revision, i18n.t("script_review.invalid_scene", "Scene {index} is invalid.")).replace("{index}", String(i + 1))
                return false
            }
            if (!root.sceneHasAction(scenes[i])) {
                root.feedbackTitle = (void i18n.revision, i18n.t("script_review.validation_error_title", "Validation error"))
                root.feedbackMessage = (void i18n.revision, i18n.t("script_review.missing_action", "Scene {index} is missing action content.")).replace("{index}", String(i + 1))
                return false
            }
        }
        return true
    }

    function applyReview() {
        var text = String(editor.text || "")
        if (!text.trim()) {
            root.feedbackTitle = (void i18n.revision, i18n.t("common.warning", "Warning"))
            root.feedbackMessage = (void i18n.revision, i18n.t("script_review.empty_json", "The editor is empty."))
            feedbackDialog.open()
            root.validationMessage = root.feedbackMessage
            return
        }
        try {
            var parsed = JSON.parse(text)
            var restored = root.restoreHiddenPayload(parsed, root.originalScriptData)
            if (!root.validateScriptData(restored)) {
                feedbackDialog.open()
                root.validationMessage = root.feedbackMessage
                return
            }
            root.scriptApproved(restored)
            text = JSON.stringify(restored, null, 2)
            editor.text = text
        } catch (err) {
            root.feedbackTitle = (void i18n.revision, i18n.t("script_review.invalid_json_title", "Invalid JSON"))
            root.feedbackMessage = (void i18n.revision, i18n.t("script_review.parse_error", "Could not parse JSON")).replace("{line}", String(err.lineNumber || "")).replace("{col}", String(err.columnNumber || "")).replace("{msg}", String(err.message || err))
            feedbackDialog.open()
            root.validationMessage = root.feedbackMessage
            return
        }
        root.approveRequested(text, restored)
    }

    function applyApproveResult(result) {
        var payload = result && typeof result === "object" ? result : ({})
        if (!payload.ok) {
            root.feedbackTitle = (void i18n.revision, i18n.t("common.warning", "Warning"))
            root.feedbackMessage = String(
                payload.message
                || payload.error
                || (void i18n.revision, i18n.t("script_review.save_failed", "Could not save the reviewed script."))
            )
            root.validationMessage = root.feedbackMessage
            feedbackDialog.open()
            return false
        }
        root.validationMessage = (void i18n.revision, i18n.t("script_review.saved", "Reviewed script saved."))
        root.accept()
        return true
    }

    background: Rectangle {
        color: VfTheme.surface
        radius: VfTheme.radiusPanel
        border.color: VfTheme.borderStrong
        border.width: 1
    }

    Dialog {
        id: feedbackDialog
        parent: Overlay.overlay
        modal: true
        anchors.centerIn: parent
        width: VfDialogMetrics.width(parent, VfTheme.dp(460), VfTheme.dp(64))
        padding: VfTheme.dp(20)
        title: ""
        standardButtons: Dialog.NoButton

        background: Rectangle {
            radius: VfTheme.dp(8)
            color: VfTheme.surface
            border.color: VfTheme.border
        }

        contentItem: ColumnLayout {
            spacing: VfTheme.dp(14)

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
                color: VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontControl
                wrapMode: Text.WordWrap
            }

            RowLayout {
                Layout.fillWidth: true
                Item { Layout.fillWidth: true }
                VfButton {
                    text: (void i18n.revision, i18n.t("common.ok", "OK"))
                    tone: "primary"
                    minWidth: VfTheme.dp(96)
                    onClicked: feedbackDialog.close()
                }
            }
        }
    }

    contentItem: ColumnLayout {
        spacing: VfTheme.dp(15)

        Rectangle {
            Layout.fillWidth: true
            Layout.leftMargin: 20
            Layout.rightMargin: 20
            Layout.topMargin: 20
            implicitHeight: VfTheme.dp(56)
            radius: VfTheme.dp(6)
            gradient: Gradient {
                GradientStop { position: 0; color: "#0EA5E9" }
                GradientStop { position: 1; color: "#0284C7" }
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: VfTheme.dp(16)
                anchors.rightMargin: VfTheme.dp(16)
                spacing: VfTheme.dp(6)

                VfAppIcon {
                    name: root.modeIcon()
                    size: VfTheme.dp(16)
                    framed: false
                    color: "#FFFFFF"
                    visible: name.length > 0
                }

                Text {
                    Layout.fillWidth: true
                    text: (void i18n.revision, i18n.t("script_review.header_title_no_icon", "Script Review - {mode}"))
                        .replace("{mode}", String(root.mode || "normal").toUpperCase())
                    color: "#FFFFFF"
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(16)
                    font.weight: Font.DemiBold
                    elide: Text.ElideRight
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.leftMargin: 20
            Layout.rightMargin: 20
            implicitHeight: VfTheme.dp(38)
            radius: VfTheme.dp(4)
            color: VfTheme.blueFill
            border.color: VfTheme.cyanBorderSoft

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: VfTheme.dp(10)
                anchors.rightMargin: VfTheme.dp(10)
                spacing: VfTheme.dp(8)

                Rectangle {
                    Layout.preferredWidth: VfTheme.dp(3)
                    Layout.fillHeight: true
                    color: "#0EA5E9"
                }

                Text {
                    text: root.modeDescription()
                    color: VfTheme.blueText
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(12)
                    font.weight: Font.DemiBold
                    elide: Text.ElideRight
                }

                Text {
                    text: "•"
                    color: VfTheme.textSubtle
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(12)
                }

                Text {
                    Layout.fillWidth: true
                    text: (void i18n.revision, i18n.t("script_review.fields_label", "Fields: {fields}"))
                        .replace("{fields}", root.fieldsInfo())
                    color: VfTheme.textSubtle
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(11)
                    elide: Text.ElideRight
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.leftMargin: 20
            Layout.rightMargin: 20
            radius: VfTheme.dp(6)
            color: editor.activeFocus ? VfTheme.surface : VfTheme.surfaceSoft
            border.color: editor.activeFocus ? "#3B82F6" : VfTheme.border
            border.width: 2
            clip: true

            ScrollView {
                id: editorScroll
                anchors.fill: parent
                anchors.margins: VfTheme.dp(10)
                contentHeight: editor.implicitHeight
                clip: true

                TextArea {
                    id: editor
                    width: editorScroll.availableWidth
                    placeholderText: (void i18n.revision, i18n.t("script_review.placeholder", "Review or edit the generated script JSON here."))
                    wrapMode: TextArea.NoWrap
                    selectByMouse: true
                    color: VfTheme.textMuted
                    placeholderTextColor: VfTheme.textSubtle
                    selectedTextColor: "#FFFFFF"
                    selectionColor: "#3B82F6"
                    font.family: "Consolas"
                    font.pixelSize: VfTheme.dp(11)
                    background: Item {}
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.leftMargin: 20
            Layout.rightMargin: 20
            implicitHeight: VfTheme.dp(58)
            color: VfTheme.surface
            border.color: VfTheme.border
            border.width: 0

            RowLayout {
                anchors.fill: parent
                spacing: VfTheme.dp(12)

                VfButton {
                    text: (void i18n.revision, i18n.t("script_review.format_btn", "Format JSON"))
                    minWidth: VfTheme.dp(120)
                    onClicked: root.formatEditor()
                }

                Text {
                    Layout.fillWidth: true
                    text: root.validationMessage
                    color: root.validationMessage.indexOf("Invalid") >= 0 ? "#DC2626" : VfTheme.textSubtle
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(11)
                    elide: Text.ElideRight
                }

                VfButton {
                    text: (void i18n.revision, i18n.t("script_review.cancel_btn", "Cancel"))
                    minWidth: VfTheme.dp(110)
                    onClicked: root.reject()
                }

                VfButton {
                    text: (void i18n.revision, i18n.t("script_review.apply_btn", "Apply && Save"))
                    tone: "success"
                    minWidth: VfTheme.dp(110)
                    onClicked: root.applyReview()
                }
            }
        }
    }
}
