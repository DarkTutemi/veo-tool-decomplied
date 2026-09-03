import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../components"
import "../theme"

Dialog {
    id: root

    property var row: ({})
    property var scriptData: null
    property string scriptMode: "normal"
    property string validationMessage: ""
    property string feedbackTitle: ""
    property string feedbackMessage: ""
    property int currentTab: 0
    property string currentTabKey: root.tabKeyAt(root.currentTab)

    signal editRequested(var row)
    signal retryRequested(var row)
    signal openFolderRequested(var row)
    signal recreateRequested(var row, string aspectRatio)
    signal regenScenesRequested(var row, var sceneIds)
    signal fixPolicyRequested(var row)
    signal editSceneRequested(var row, var sceneItem)
    signal editScriptRequested(var row, var scriptData, string scriptMode)

    parent: Overlay.overlay
    modal: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    width: VfDialogMetrics.width(parent, VfTheme.dp(960), VfTheme.dp(48))
    height: VfDialogMetrics.height(parent, VfTheme.dp(720), VfTheme.dp(48))
    x: VfDialogMetrics.centerX(parent, width)
    y: VfDialogMetrics.centerY(parent, height)
    padding: 0

    header: VfDialogHeader {
        title: (void i18n.revision, i18n.t("master_prompt.job_preview_title", "Preview - {name}"))
            .replace("{name}", String((root.row && (root.row.name || root.row.title || root.row.job_id || root.row.id)) || ""))
        subtitle: root.valueOf("job_status", "status", "status_label")
        iconName: "framed-picture"
        onCloseClicked: root.close()
    }

    function openFor(rowData) {
        root.row = rowData || ({})
        root.currentTab = 0
        root.validationMessage = ""
        editScenePopup.close()
        recreatePopup.close()
        regenScenesPopup.close()
        root.open()
    }

    function valueOf() {
        for (var i = 0; i < arguments.length; i++) {
            var key = arguments[i]
            var value = root.row ? root.row[key] : ""
            if (value !== undefined && value !== null && String(value).length > 0)
                return String(value)
        }
        return "-"
    }

    function promptText() {
        if (root.row && root.row.job_prompt)
            return String(root.row.job_prompt || "")
        if (root.row && root.row.prompts && root.row.prompts.length > 0)
            return String(root.row.prompts[0].prompt || root.row.prompts[0].text || root.row.prompts[0].idea || "")
        return String(root.row.prompt || root.row.idea || root.row.text || "")
    }

    function metadataText() {
        if (!root.row)
            return ""
        var meta = root.row.job_meta || {}
        if (root.scriptData && root.row.result_data)
            meta = Object.assign({}, meta)
        if (Object.keys(meta).length === 0)
            return ""
        try {
            return JSON.stringify(meta, null, 2)
        } catch (error) {
            return String(meta || "")
        }
    }

    function configText() {
        if (!root.row)
            return ""
        var config = root.row.config || ((root.row.job_meta || {}).config) || {}
        if (!config)
            return ""
        var lines = []
        var templateName = String(config.template_name || config.template || "")
        var styleName = String(config.style || config.style_id || config.camera_id || "")
        var duration = String(config.duration || "")
        var language = String(config.voice_language || config.language || "")
        var aspect = String(config.aspect_ratio || root.row.aspect_ratio || "")
        var idea = String(config.idea || "")
        if (templateName.length > 0)
            lines.push("Template: " + templateName)
        if (styleName.length > 0)
            lines.push("Style: " + styleName)
        if (duration.length > 0)
            lines.push("Duration: " + duration + "s")
        if (language.length > 0)
            lines.push("Language: " + language)
        if (aspect.length > 0)
            lines.push("Aspect Ratio: " + aspect)
        if (idea.length > 0) {
            lines.push("")
            lines.push("Idea: " + idea)
        }
        return lines.join("\n")
    }

    function errorText() {
        var error = root.valueOf("job_error_message", "error_message")
        return error === "-" ? "" : error
    }

    function hasResultData() {
        return !!(root.row && root.row.result_data)
    }

    function dispatcherBreakdown() {
        if (!root.row || !root.row.dispatcher_breakdown || root.row.dispatcher_breakdown.length === undefined)
            return []
        return root.row.dispatcher_breakdown
    }

    function dispatcherSummary() {
        if (!root.row || !root.row.dispatcher_summary)
            return ({})
        return root.row.dispatcher_summary
    }

    function dispatcherBreakdownSummaryText() {
        var summary = root.dispatcherSummary()
        if (!summary)
            return ""
        var parts = []
        var completed = Number(summary.completed || 0)
        var running = Number(summary.running || 0)
        var queued = Number(summary.queued || 0)
        var failed = Number(summary.failed || 0)
        var cancelled = Number(summary.cancelled || 0)
        if (completed > 0)
            parts.push(String(completed) + " complete")
        if (running > 0)
            parts.push(String(running) + " running")
        if (queued > 0)
            parts.push(String(queued) + " queued")
        if (failed > 0)
            parts.push(String(failed) + " failed")
        if (cancelled > 0)
            parts.push(String(cancelled) + " cancelled")
        return parts.join(" • ")
    }

    function visibleTabs() {
        var tabs = [{ key: "info", label: (void i18n.revision, i18n.t("master_prompt.section_info", "Info")) }]
        if (root.promptText().length > 0)
            tabs.push({ key: "prompt", label: (void i18n.revision, i18n.t("master_prompt.section_prompt", "Prompt")) })
        if (root.dispatcherBreakdown().length > 0)
            tabs.push({ key: "dispatcher", label: (void i18n.revision, i18n.t("master_prompt.section_dispatcher", "Dispatcher")) })
        if (root.scriptDisplayText().length > 0)
            tabs.push({ key: "script", label: (void i18n.revision, i18n.t("master_prompt.section_script", "Script Data")) })
        if (root.metadataText().length > 0)
            tabs.push({ key: "metadata", label: (void i18n.revision, i18n.t("master_prompt.section_metadata", "Metadata")) })
        return tabs
    }

    function tabKeyAt(index) {
        var tabs = root.visibleTabs()
        if (index >= 0 && index < tabs.length)
            return tabs[index].key
        return "info"
    }

    function sceneCountText() {
        var direct = root.row ? root.row.scene_count : undefined
        if (direct !== undefined && direct !== null && String(direct).length > 0 && String(direct) !== "0")
            return String(direct)
        var breakdown = root.dispatcherBreakdown().length
        if (breakdown > 0)
            return String(breakdown)
        var scenes = root.sceneItems().length
        return scenes > 0 ? String(scenes) : "-"
    }

    function videoCountText() {
        var direct = root.row ? root.row.video_count : undefined
        if (direct !== undefined && direct !== null && String(direct).length > 0 && String(direct) !== "0")
            return String(direct)
        var summary = root.dispatcherSummary()
        var completed = Number((summary && summary.completed) || 0)
        return completed > 0 ? String(completed) : "-"
    }

    function progressText() {
        var direct = root.valueOf("job_progress", "progress")
        if (direct !== "-" && direct !== "0")
            return direct.indexOf("%") >= 0 ? direct : (direct + "%")
        var summary = root.dispatcherSummary()
        if (summary) {
            var total = Number(summary.completed || 0) + Number(summary.running || 0)
                + Number(summary.queued || 0) + Number(summary.failed || 0)
                + Number(summary.cancelled || 0)
            var done = Number(summary.completed || 0)
            if (total > 0)
                return String(Math.round(done / total * 100)) + "%"
        }
        return direct === "-" ? "-" : (direct + "%")
    }

    function dispatcherBreakdownText() {
        var rows = root.dispatcherBreakdown()
        if (!rows || rows.length === 0)
            return ""
        var lines = []
        for (var i = 0; i < rows.length; i++) {
            var item = rows[i] || {}
            var sceneId = String(item.scene_id || "")
            var label = sceneId.length > 0 ? sceneId : ("Scene " + String(i + 1))
            var status = String(item.status || (void i18n.revision, i18n.t("common.pending", "Pending")))
            var progress = Number(item.progress || 0)
            var line = label + " - " + status + " (" + String(progress) + "%)"
            var jobId = String(item.job_id || "")
            if (jobId.length > 0)
                line += " - " + jobId
            lines.push(line)
            var errorMessage = String(item.error_message || "")
            if (errorMessage.length > 0)
                lines.push("  Error: " + errorMessage)
        }
        return lines.join("\n")
    }

    function isMultiAssetJob() {
        if (!root.row)
            return false
        var resultData = root.row.result_data || {}
        var multiAssetInfo = resultData.multi_asset_info || {}
        return !!multiAssetInfo.enabled
    }

    function recreateMessageText() {
        if (root.isMultiAssetJob()) {
            return (void i18n.revision, i18n.t("master_prompt.regen_multi_asset_message", "Regenerate {title} as a multi-asset video?"))
                .replace("{title}", String(root.valueOf("name", "title")))
        }
        return (void i18n.revision, i18n.t("master_prompt.regen_normal_message", "Regenerate {title} with a new aspect ratio?"))
            .replace("{title}", String(root.valueOf("name", "title")))
    }

    function recreateActionLabel(aspectRatio) {
        if (root.isMultiAssetJob())
            return aspectRatio === "9:16" ? "Multi-Asset (9:16)" : "Multi-Asset (16:9)"
        return aspectRatio === "9:16"
            ? (void i18n.revision, i18n.t("master_prompt.portrait_video_btn", "Portrait Video"))
            : (void i18n.revision, i18n.t("master_prompt.text_to_video_btn", "Text-to-Video"))
    }

    function sceneItems() {
        if (!root.row || !root.row.result_data || !root.row.result_data.scenes)
            return []
        var scenes = root.row.result_data.scenes || []
        var items = []
        for (var i = 0; i < scenes.length; i++) {
            var scene = scenes[i] || {}
            var sceneId = String(scene.scene_id || scene.id || "")
            if (!sceneId.length)
                continue
            items.push({
                scene_id: sceneId,
                description: String(scene.description || scene.veo3_prompt || "")
            })
        }
        return items
    }

    function editableSceneItems() {
        var items = []
        var descriptions = {}
        var scenes = root.sceneItems()
        for (var i = 0; i < scenes.length; i++) {
            var scene = scenes[i] || {}
            descriptions[String(scene.scene_id || "")] = String(scene.description || "")
        }
        var breakdown = root.dispatcherBreakdown()
        for (var j = 0; j < breakdown.length; j++) {
            var entry = breakdown[j] || {}
            var jobId = String(entry.job_id || "")
            if (jobId.length === 0)
                continue
            var sceneId = String(entry.scene_id || "")
            var status = String(entry.status || "")
            items.push({
                job_id: jobId,
                scene_id: sceneId,
                scene_index: Number(entry.scene_index || -1),
                status: status,
                description: descriptions[sceneId] || "",
            })
        }
        return items
    }

    function policyFailedCharacters() {
        if (!root.row)
            return []
        if (root.row.policy_failed_characters && root.row.policy_failed_characters.length !== undefined)
            return root.row.policy_failed_characters
        var resultData = root.row.result_data || {}
        if (resultData.policy_failed_characters && resultData.policy_failed_characters.length !== undefined)
            return resultData.policy_failed_characters
        var meta = root.row.job_meta || {}
        if (meta.policy_failed_characters && meta.policy_failed_characters.length !== undefined)
            return meta.policy_failed_characters
        if (meta.result && meta.result.policy_failed_characters && meta.result.policy_failed_characters.length !== undefined)
            return meta.result.policy_failed_characters
        return []
    }

    function scriptDisplayText() {
        if (!root.scriptData || typeof root.scriptData !== "object")
            return ""
        var filtered = filterBase64ForDisplay(root.scriptData)
        try {
            return JSON.stringify(filtered, null, 2)
        } catch (err) {
            return String(root.scriptData || "")
        }
    }

    function filterBase64ForDisplay(value) {
        if (value === null || value === undefined)
            return value
        if (Array.isArray(value)) {
            var filteredList = []
            for (var listIndex = 0; listIndex < value.length; ++listIndex)
                filteredList.push(filterBase64ForDisplay(value[listIndex]))
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
                filtered[key] = "[BASE64_IMAGE_DATA]"
            else if (key === "thumbnail_base64" && typeof item === "string" && item.length > 100)
                filtered[key] = "[THUMBNAIL_DATA]"
            else
                filtered[key] = filterBase64ForDisplay(item)
        }
        return filtered
    }

    function showFeedback(title, message) {
        root.feedbackTitle = String(title || (void i18n.revision, i18n.t("common.notice", "Notice")))
        root.feedbackMessage = String(message || "")
        feedbackDialog.open()
    }

    function applyRecreateResult(result) {
        var payload = result || ({})
        if (!payload.ok) {
            var message = String(payload.message || payload.error || payload.code || (void i18n.revision, i18n.t("common.request_failed", "Request failed.")))
            root.validationMessage = message
            root.showFeedback(
                (void i18n.revision, i18n.t("master.recreate_failed_title", "Recreate unavailable")),
                message
            )
            return false
        }
        root.validationMessage = ""
        recreatePopup.close()
        root.showFeedback(
            (void i18n.revision, i18n.t("master.recreate_success_title", "Recreate requested")),
            String(payload.message || (void i18n.revision, i18n.t("master.recreate_success_message", "The recreate request was accepted.")))
        )
        return true
    }

    function applyRetryResult(result) {
        var payload = result || ({})
        if (!payload.ok) {
            var message = String(payload.message || payload.error || payload.code || (void i18n.revision, i18n.t("common.request_failed", "Request failed.")))
            root.validationMessage = message
            root.showFeedback(
                (void i18n.revision, i18n.t("master.retry_failed_title", "Retry unavailable")),
                message
            )
            return false
        }
        root.validationMessage = ""
        root.showFeedback(
            (void i18n.revision, i18n.t("master.retry_success_title", "Retry queued")),
            String(payload.message || (void i18n.revision, i18n.t("master.retry_success_message", "The retry request was accepted.")))
        )
        return true
    }

    function applyRegenScenesResult(result) {
        var payload = result || ({})
        if (!payload.ok) {
            var message = String(payload.message || payload.error || payload.code || (void i18n.revision, i18n.t("common.request_failed", "Request failed.")))
            root.validationMessage = message
            root.showFeedback(
                (void i18n.revision, i18n.t("master.regen_scenes_failed_title", "Regen scenes unavailable")),
                message
            )
            return false
        }
        root.validationMessage = ""
        regenScenesPopup.close()
        root.showFeedback(
            (void i18n.revision, i18n.t("master.regen_scenes_success_title", "Regen scenes requested")),
            String(payload.message || (void i18n.revision, i18n.t("master.regen_scenes_success_message", "The scene regeneration request was accepted.")))
        )
        return true
    }

    background: Rectangle {
        radius: VfTheme.dp(10)
        color: VfTheme.surface
        border.color: VfTheme.borderStrong
    }

    // -- Shared feedback sub-dialog ----------------------------------------
    Dialog {
        id: feedbackDialog
        parent: Overlay.overlay
        modal: true
        anchors.centerIn: parent
        width: VfDialogMetrics.width(parent, VfTheme.dp(420), VfTheme.dp(64))
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

    // -- Main content -------------------------------------------------------
    contentItem: ColumnLayout {
        spacing: 0

        // Action toolbar
        RowLayout {
            Layout.fillWidth: true
            Layout.topMargin: VfTheme.dp(8)
            Layout.bottomMargin: VfTheme.dp(4)
            Layout.leftMargin: VfTheme.dp(14)
            Layout.rightMargin: VfTheme.dp(14)
            spacing: VfTheme.dp(6)

            Item { Layout.fillWidth: true }

            VfButton {
                compact: true
                text: (void i18n.revision, i18n.t("common.edit", "Edit"))
                tone: "primary"
                onClicked: {
                    root.editRequested(root.row)
                    root.close()
                }
            }

            VfButton {
                compact: true
                visible: root.valueOf("output_folder", "folder", "result_folder") !== "-"
                text: (void i18n.revision, i18n.t("master.open_folder_button", "Folder"))
                iconName: "open-folder"
                onClicked: root.openFolderRequested(root.row)
            }

            VfButton {
                compact: true
                text: (void i18n.revision, i18n.t("master.retry_button", "Retry"))
                onClicked: root.retryRequested(root.row)
            }

            VfButton {
                compact: true
                visible: root.hasResultData()
                text: (void i18n.revision, i18n.t("master.regenerate_button", "Recreate"))
                onClicked: recreatePopup.open()
            }

            VfButton {
                compact: true
                visible: root.sceneItems().length > 0
                text: (void i18n.revision, i18n.t("master_prompt.regen_scene_btn", "Regen Scenes"))
                onClicked: regenScenesPopup.open()
            }

            VfButton {
                compact: true
                visible: root.editableSceneItems().length > 0
                text: (void i18n.revision, i18n.t("master.edit_scene_prompt_button", "Edit Scene"))
                onClicked: editScenePopup.open()
            }

            VfButton {
                compact: true
                visible: root.policyFailedCharacters().length > 0
                text: (void i18n.revision, i18n.t("chargen_policy.title", "Fix CharGen"))
                onClicked: {
                    root.close()
                    root.fixPolicyRequested(root.row)
                }
            }

            VfButton {
                compact: true
                visible: root.scriptData !== null
                text: (void i18n.revision, i18n.t("master.edit_script_button", "Edit Script"))
                onClicked: {
                    root.close()
                    root.editScriptRequested(root.row, root.scriptData, root.scriptMode)
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.leftMargin: VfTheme.dp(14)
            Layout.rightMargin: VfTheme.dp(14)
            implicitHeight: 1
            color: VfTheme.border
        }

        // Tab strip
        Flow {
            id: tabStrip
            Layout.fillWidth: true
            Layout.leftMargin: VfTheme.dp(14)
            Layout.rightMargin: VfTheme.dp(14)
            Layout.topMargin: VfTheme.dp(8)
            Layout.bottomMargin: VfTheme.dp(2)
            spacing: VfTheme.dp(6)

            Repeater {
                model: root.visibleTabs()
                delegate: Rectangle {
                    id: tabBtn
                    property bool active: root.currentTab === index
                    implicitHeight: VfTheme.dp(34)
                    implicitWidth: Math.max(VfTheme.dp(104), tabBtnLabel.implicitWidth + VfTheme.dp(26))
                    radius: VfTheme.dp(8)
                    color: tabBtn.active ? VfTheme.surface : VfTheme.surfaceSoft
                    border.width: 1
                    border.color: tabBtn.active ? VfTheme.primary : VfTheme.borderBox

                    Text {
                        id: tabBtnLabel
                        anchors.centerIn: parent
                        text: modelData.label
                        color: tabBtn.active ? VfTheme.text : VfTheme.textMuted
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.dp(13)
                        font.weight: tabBtn.active ? VfTheme.weightStrong : VfTheme.weightControl
                        elide: Text.ElideRight
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.currentTab = index
                    }
                }
            }
        }

        // Tab content
        Item {
            id: tabContent
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.leftMargin: VfTheme.dp(14)
            Layout.rightMargin: VfTheme.dp(14)
            Layout.topMargin: VfTheme.dp(8)
            Layout.bottomMargin: VfTheme.dp(6)

            // ===== Info pane =====
            Flickable {
                id: infoFlick
                anchors.fill: parent
                visible: root.currentTabKey === "info"
                contentWidth: width
                contentHeight: infoColumn.implicitHeight
                clip: true
                boundsBehavior: Flickable.StopAtBounds
                flickableDirection: Flickable.VerticalFlick

                ScrollBar.vertical: ScrollBar {
                    policy: ScrollBar.AsNeeded
                    width: VfTheme.dp(6)
                }

                ColumnLayout {
                    id: infoColumn
                    width: infoFlick.width - VfTheme.dp(10)
                    spacing: VfTheme.dp(10)

                // -- Error banner ------------------------------------------
                Rectangle {
                    Layout.fillWidth: true
                    visible: root.errorText().length > 0
                    implicitHeight: errorCol.implicitHeight + VfTheme.dp(16)
                    radius: VfTheme.radiusControl
                    color: VfTheme.redFill
                    border.color: VfTheme.redBorderSoft

                    ColumnLayout {
                        id: errorCol
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.margins: VfTheme.dp(8)
                        spacing: VfTheme.dp(2)

                        Text {
                            Layout.fillWidth: true
                            text: "Error"
                            color: VfTheme.redText
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.dp(11)
                            font.weight: Font.Bold
                        }

                        Text {
                            Layout.fillWidth: true
                            text: root.errorText()
                            color: VfTheme.redText
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.dp(11)
                            wrapMode: Text.WordWrap
                        }
                    }
                }

                // -- Info grid ---------------------------------------------
                Text {
                    Layout.fillWidth: true
                    text: (void i18n.revision, i18n.t("master_prompt.section_info", "Info"))
                    color: VfTheme.text
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(12)
                    font.weight: Font.Bold
                }

                GridLayout {
                    Layout.fillWidth: true
                    columns: 4
                    columnSpacing: VfTheme.dp(6)
                    rowSpacing: VfTheme.dp(6)

                    Repeater {
                        model: [
                            { label: "ID", value: root.valueOf("job_id", "linked_job_id", "id", "row_id", "batch_id") },
                            { label: "Name", value: root.valueOf("name", "title") },
                            { label: "Status", value: root.valueOf("job_status", "status", "status_label") },
                            { label: "Progress", value: root.progressText() },
                            { label: "Scenes", value: root.sceneCountText() },
                            { label: "Videos", value: root.videoCountText() },
                            { label: "Created", value: root.valueOf("job_created_at", "created_at") },
                            { label: "Aspect", value: root.valueOf("aspect", "aspect_ratio") },
                            { label: "Duration", value: root.valueOf("duration") },
                            { label: "Language", value: root.valueOf("language") },
                            { label: "Folder", value: root.valueOf("output_folder", "folder", "result_folder") }
                        ]

                        delegate: Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredWidth: VfTheme.dp(190)
                            implicitHeight: VfTheme.dp(42)
                            radius: VfTheme.radiusControl
                            color: VfTheme.surfaceSoft
                            border.color: VfTheme.borderBox

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: VfTheme.dp(6)
                                spacing: 1

                                Text {
                                    Layout.fillWidth: true
                                    text: modelData.label
                                    color: VfTheme.textMuted
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.fontTiny
                                    font.weight: Font.Bold
                                    elide: Text.ElideRight
                                }

                                Text {
                                    Layout.fillWidth: true
                                    text: modelData.value
                                    color: VfTheme.text
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.fontSmall
                                    elide: Text.ElideRight
                                }
                            }
                        }
                    }
                }

                // -- Configuration -----------------------------------------
                Rectangle {
                    Layout.fillWidth: true
                    visible: root.configText().length > 0
                    implicitHeight: configCol.implicitHeight + VfTheme.dp(16)
                    radius: VfTheme.radiusControl
                    color: VfTheme.surface
                    border.color: VfTheme.borderBox

                    ColumnLayout {
                        id: configCol
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.margins: VfTheme.dp(8)
                        spacing: VfTheme.dp(4)

                        Text {
                            Layout.fillWidth: true
                            text: (void i18n.revision, i18n.t("master_prompt.section_config", "Configuration"))
                            color: VfTheme.text
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.dp(12)
                            font.weight: Font.Bold
                        }

                        Text {
                            Layout.fillWidth: true
                            text: root.configText()
                            color: VfTheme.textMuted
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.dp(12)
                            wrapMode: Text.WordWrap
                        }
                    }
                }

                    Item { Layout.preferredHeight: VfTheme.dp(4) }
                }
            }

            // ===== Prompt pane =====
            Rectangle {
                anchors.fill: parent
                visible: root.currentTabKey === "prompt"
                radius: VfTheme.radiusControl
                color: VfTheme.surface
                border.color: VfTheme.borderBox
                clip: true

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: VfTheme.dp(8)
                    spacing: VfTheme.dp(4)

                    Text {
                        Layout.fillWidth: true
                        text: (void i18n.revision, i18n.t("master_prompt.section_prompt", "Prompt"))
                            color: VfTheme.text
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.dp(12)
                            font.weight: Font.Bold
                        }

                        ScrollView {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true
                            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                            TextArea {
                                id: promptArea
                                text: root.promptText()
                                readOnly: true
                                wrapMode: TextEdit.Wrap
                                color: VfTheme.text
                                selectedTextColor: "#FFFFFF"
                                selectionColor: VfTheme.primary
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.dp(12)
                                selectByMouse: true
                                background: Item {}
                            }
                        }
                    }
                }

            // ===== Dispatcher pane =====
            Rectangle {
                anchors.fill: parent
                visible: root.currentTabKey === "dispatcher"
                radius: VfTheme.radiusControl
                color: VfTheme.surface
                border.color: VfTheme.borderBox
                clip: true

                ColumnLayout {
                    id: dispatchCol
                    anchors.fill: parent
                    anchors.margins: VfTheme.dp(8)
                    spacing: VfTheme.dp(4)

                        Text {
                            Layout.fillWidth: true
                            text: (void i18n.revision, i18n.t("master_prompt.section_dispatcher", "Dispatcher Breakdown"))
                            color: VfTheme.text
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.dp(12)
                            font.weight: Font.Bold
                        }

                        Text {
                            Layout.fillWidth: true
                            visible: root.dispatcherBreakdownSummaryText().length > 0
                            text: root.dispatcherBreakdownSummaryText()
                            color: VfTheme.textMuted
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.dp(11)
                            wrapMode: Text.WordWrap
                        }

                        ScrollView {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true
                            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                            TextArea {
                                text: root.dispatcherBreakdownText()
                                readOnly: true
                                wrapMode: TextEdit.Wrap
                                color: VfTheme.text
                                selectedTextColor: "#FFFFFF"
                                selectionColor: VfTheme.primary
                                font.family: "Consolas"
                                font.pixelSize: VfTheme.dp(11)
                                selectByMouse: true
                                background: Item {}
                            }
                        }
                    }
                }

            // ===== Script pane =====
            Rectangle {
                anchors.fill: parent
                visible: root.currentTabKey === "script"
                radius: VfTheme.radiusControl
                color: VfTheme.surface
                border.color: VfTheme.cyanBorderSoft
                clip: true

                    ColumnLayout {
                        id: scriptCol
                        anchors.fill: parent
                        anchors.margins: VfTheme.dp(8)
                        spacing: VfTheme.dp(4)

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: VfTheme.dp(6)

                            Text {
                                Layout.fillWidth: true
                                text: (void i18n.revision, i18n.t("master_prompt.section_script", "Script Data"))
                                    + " (" + String(root.scriptMode || "normal").toUpperCase() + ")"
                                color: VfTheme.blueText
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.dp(12)
                                font.weight: Font.Bold
                            }
                        }

                        ScrollView {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true
                            contentHeight: scriptArea.implicitHeight

                            TextArea {
                                id: scriptArea
                                text: root.scriptDisplayText()
                                readOnly: true
                                wrapMode: TextEdit.NoWrap
                                color: VfTheme.textMuted
                                selectedTextColor: "#FFFFFF"
                                selectionColor: "#3B82F6"
                                font.family: "Consolas"
                                font.pixelSize: VfTheme.dp(11)
                                selectByMouse: true
                                background: Item {}
                            }
                        }
                    }
                }

            // ===== Metadata pane =====
            Rectangle {
                anchors.fill: parent
                visible: root.currentTabKey === "metadata"
                radius: VfTheme.radiusControl
                color: VfTheme.surface
                border.color: VfTheme.borderBox
                clip: true

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: VfTheme.dp(8)
                        spacing: VfTheme.dp(4)

                        Text {
                            Layout.fillWidth: true
                            text: (void i18n.revision, i18n.t("master_prompt.section_metadata", "Metadata"))
                            color: VfTheme.text
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.dp(12)
                            font.weight: Font.Bold
                        }

                        ScrollView {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true
                            contentHeight: metaArea.implicitHeight

                            TextArea {
                                id: metaArea
                                text: root.metadataText()
                                readOnly: true
                                wrapMode: TextEdit.NoWrap
                                color: VfTheme.text
                                selectedTextColor: "#FFFFFF"
                                selectionColor: VfTheme.primary
                                font.family: "Consolas"
                                font.pixelSize: VfTheme.dp(11)
                                selectByMouse: true
                                background: Item {}
                            }
                        }
                    }
                }

        }

        // -- Validation footer -------------------------------------------------
        Text {
            Layout.fillWidth: true
            Layout.leftMargin: VfTheme.dp(14)
            Layout.rightMargin: VfTheme.dp(14)
            Layout.bottomMargin: VfTheme.dp(8)
            visible: root.validationMessage.length > 0
            text: root.validationMessage
            color: VfTheme.redText
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.dp(11)
            wrapMode: Text.WordWrap
        }
    }

    // -- Sub-popups (recreate / edit scene / regen scenes) -------------------
    Popup {
        id: recreatePopup
        modal: true
        focus: true
        width: VfTheme.dp(320)
        height: VfTheme.dp(176)
        anchors.centerIn: Overlay.overlay
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        background: Rectangle {
            radius: VfTheme.dp(10)
            color: VfTheme.surface
            border.color: VfTheme.borderStrong
        }

        contentItem: ColumnLayout {
            anchors.fill: parent
            anchors.margins: VfTheme.dp(14)
            spacing: VfTheme.dp(10)

            Text {
                Layout.fillWidth: true
                text: (void i18n.revision, i18n.t("master_prompt.regen_video_title", "Regenerate Video"))
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(16)
                font.weight: Font.Bold
            }

            Text {
                Layout.fillWidth: true
                text: root.recreateMessageText()
                color: VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(12)
                wrapMode: Text.WordWrap
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: VfTheme.dp(8)

                VfButton {
                    text: (void i18n.revision, i18n.t("master_prompt.cancel_btn", "Cancel"))
                    onClicked: recreatePopup.close()
                }

                VfButton {
                    text: root.recreateActionLabel("16:9")
                    tone: "primary"
                    onClicked: root.recreateRequested(root.row, "16:9")
                }

                VfButton {
                    text: root.recreateActionLabel("9:16")
                    onClicked: root.recreateRequested(root.row, "9:16")
                }

                Item { Layout.fillWidth: true }
            }
        }
    }

    Popup {
        id: editScenePopup
        modal: true
        focus: true
        width: Math.min(560, root.width - 40)
        height: Math.min(420, root.height - 40)
        anchors.centerIn: Overlay.overlay
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        background: Rectangle {
            radius: VfTheme.dp(10)
            color: VfTheme.surface
            border.color: VfTheme.borderStrong
        }

        contentItem: ColumnLayout {
            anchors.fill: parent
            anchors.margins: VfTheme.dp(14)
            spacing: VfTheme.dp(10)

            Text {
                Layout.fillWidth: true
                text: (void i18n.revision, i18n.t("master.edit_scene_prompt_title", "Select a scene to edit"))
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(16)
                font.weight: Font.Bold
            }

            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                contentWidth: availableWidth
                contentHeight: editSceneCol.implicitHeight
                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                ColumnLayout {
                    id: editSceneCol
                    width: parent.availableWidth
                    spacing: VfTheme.dp(8)

                    Repeater {
                        model: root.editableSceneItems()

                        delegate: Rectangle {
                            Layout.fillWidth: true
                            radius: VfTheme.dp(8)
                            color: VfTheme.surfaceSoft
                            border.color: VfTheme.borderBox

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: VfTheme.dp(10)
                                spacing: VfTheme.dp(10)

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: VfTheme.dp(2)

                                    Text {
                                        Layout.fillWidth: true
                                        text: String(modelData.scene_id || "")
                                            + " • "
                                            + String(modelData.status || (void i18n.revision, i18n.t("common.pending", "Pending")))
                                        color: VfTheme.text
                                        font.family: VfTheme.fontFamily
                                        font.pixelSize: VfTheme.dp(12)
                                        font.weight: Font.Bold
                                        elide: Text.ElideRight
                                    }

                                    Text {
                                        Layout.fillWidth: true
                                        text: String(modelData.description || "").slice(0, 120)
                                        color: VfTheme.textMuted
                                        font.family: VfTheme.fontFamily
                                        font.pixelSize: VfTheme.dp(11)
                                        wrapMode: Text.WordWrap
                                        visible: text.length > 0
                                    }
                                }

                                VfButton {
                                    text: (void i18n.revision, i18n.t("common.edit", "Edit"))
                                    tone: "primary"
                                    onClicked: {
                                        editScenePopup.close()
                                        root.close()
                                        root.editSceneRequested(root.row, modelData)
                                    }
                                }
                            }
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Item { Layout.fillWidth: true }

                VfButton {
                    text: (void i18n.revision, i18n.t("common.close", "Close"))
                    onClicked: editScenePopup.close()
                }
            }
        }
    }

    Popup {
        id: regenScenesPopup
        modal: true
        focus: true
        width: Math.min(520, root.width - 40)
        height: Math.min(420, root.height - 40)
        anchors.centerIn: Overlay.overlay
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        background: Rectangle {
            radius: VfTheme.dp(10)
            color: VfTheme.surface
            border.color: VfTheme.borderStrong
        }

        contentItem: ColumnLayout {
            anchors.fill: parent
            anchors.margins: VfTheme.dp(14)
            spacing: VfTheme.dp(10)

            Text {
                Layout.fillWidth: true
                text: (void i18n.revision, i18n.t("master_prompt.regen_scenes_dialog_title", "Select scenes to regenerate"))
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(16)
                font.weight: Font.Bold
            }

            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                contentWidth: availableWidth
                contentHeight: regenScenesCol.implicitHeight
                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                ColumnLayout {
                    id: regenScenesCol
                    width: parent.availableWidth
                    spacing: VfTheme.dp(6)

                    Repeater {
                        id: regenRepeater
                        model: root.sceneItems()

                        delegate: CheckBox {
                            id: sceneCheck
                            Layout.fillWidth: true
                            checked: false
                            property string sceneId: String(modelData.scene_id || "")
                            text: sceneId + " - " + String(modelData.description || "").slice(0, 90)
                            font.family: VfTheme.fontFamily
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: VfTheme.dp(8)

                Item { Layout.fillWidth: true }

                VfButton {
                    text: (void i18n.revision, i18n.t("common.close", "Close"))
                    onClicked: regenScenesPopup.close()
                }

                VfButton {
                    text: (void i18n.revision, i18n.t("master.confirm_button", "Confirm"))
                    tone: "primary"
                    onClicked: {
                        var selected = []
                        for (var i = 0; i < regenRepeater.count; i++) {
                            var item = regenRepeater.itemAt(i)
                            if (item && item.checked && item.sceneId.length > 0)
                                selected.push(item.sceneId)
                        }
                        if (selected.length === 0) {
                            root.showFeedback(
                                (void i18n.revision, i18n.t("common.warning", "Warning")),
                                (void i18n.revision, i18n.t("master_prompt_tab.error_select_scene", "Select at least one scene."))
                            )
                            return
                        }
                        root.regenScenesRequested(root.row, selected)
                    }
                }
            }
        }
    }
}
