pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Layouts
import "../.."

Panel {
    id: root
    objectName: "tool1WorkflowPanel"
    clip: true
    Accessible.name: "Chạy workflow trực tiếp trong Tool 1"
    Accessible.role: Accessible.Pane

    property var controlPlaneBridge: null
    property var workflows: []
    property string selectedWorkflowKey: ""
    property string selectedMode: ""
    property string selectedDeliveryMode: "none"
    property int profileRevision: 0
    property string lastAppliedDraftHash: ""
    signal runRequested(var payload)

    readonly property var deliveryItems: [
        {"label": "Chỉ sản xuất, chưa đăng", "value": "none"},
        {"label": "Đăng ngay sau sản xuất", "value": "after_production"},
        {"label": "Đăng theo lịch", "value": "scheduled"}
    ]
    readonly property var languageItems: [
        {"label": "Theo cài đặt tab", "value": ""},
        {"label": "Tiếng Việt", "value": "vi"},
        {"label": "English", "value": "en"}
    ]
    readonly property var profileItems: {
        const revision = root.profileRevision
        const model = root.controlPlaneBridge
            ? root.controlPlaneBridge.profileModel : null
        const result = [{"label": "Chọn hồ sơ đăng", "value": ""}]
        const count = model ? Number(model.count || 0) : 0
        for (let index = 0; index < count; index++) {
            const row = model.get(index) || ({})
            const handle = String(row.accountHandle || "")
            result.push({
                "label": root.platformLabel(row.platform) + " · "
                    + String(row.label || row.profileId || "Hồ sơ")
                    + (handle ? " · " + handle : "")
                    + (String(row.authState || "") === "verified"
                        ? " · đã xác minh" : " · chưa xác minh"),
                "value": String(row.profileId || ""),
                "profile": row
            })
        }
        return result
    }
    readonly property string deliveryMode: root.selectedDeliveryMode
    readonly property bool publishEnabled: root.deliveryMode !== "none"
    readonly property var selectedProfile: {
        const index = Math.max(0, profileInput.currentIndex)
        return root.map((root.profileItems[index] || {}).profile)
    }
    readonly property bool publishReady: !root.publishEnabled || (
        String(root.selectedProfile.profileId || "").length > 0
        && String(root.selectedProfile.authState || "") === "verified"
        && ["closed", "ready"].indexOf(
            String(root.selectedProfile.status || "")) >= 0)
    readonly property string scheduledAtUtc: {
        if (root.deliveryMode !== "scheduled") return ""
        const raw = scheduleInput.text.trim().replace(" ", "T")
        const parsed = new Date(raw)
        return isNaN(parsed.getTime()) ? "" : parsed.toISOString()
    }
    readonly property bool scheduleReady: root.deliveryMode !== "scheduled"
        || (root.scheduledAtUtc.length > 0
            && new Date(root.scheduledAtUtc).getTime() > Date.now())

    readonly property var selectedCapability: root.capabilityFor(
        root.selectedWorkflowKey)
    readonly property bool selectedAllowed: String(
        root.selectedCapability.local_entitlement || "").toLowerCase() === "allowed"
    readonly property var modeItems: root.modeOptions(root.selectedCapability)
    readonly property bool fileInputMode: {
        const mode = root.effectiveMode()
        return mode === "local_video" || mode === "audio_file"
    }
    readonly property var execution: root.map(
        root.controlPlaneBridge ? root.controlPlaneBridge.execution : null)
    readonly property bool runActive: Boolean(
        root.controlPlaneBridge && root.controlPlaneBridge.runActive)
    readonly property bool canSubmit: Boolean(
        root.controlPlaneBridge && root.controlPlaneBridge.canSubmit)
    readonly property bool actionBusy: Boolean(
        root.controlPlaneBridge && root.controlPlaneBridge.actionBusy)
    readonly property string currentContent: root.fileInputMode
        ? fileInput.text.trim() : textInput.text.trim()
    readonly property bool runEnabled: root.selectedAllowed
        && root.canSubmit
        && !root.actionBusy
        && root.currentContent.length > 0
        && root.publishReady
        && root.scheduleReady

    function map(value) {
        return value === null || value === undefined ? ({}) : value
    }

    function platformLabel(value) {
        const platform = String(value || "").toLowerCase()
        if (platform === "youtube") return "YouTube"
        if (platform === "facebook") return "Facebook"
        if (platform === "tiktok") return "TikTok"
        return platform.length ? platform : "Nền tảng"
    }

    function list(value) {
        return value && value.length !== undefined ? value : []
    }

    function capabilityFor(workflowKey) {
        const key = String(workflowKey || "").toLowerCase()
        const items = root.list(root.workflows)
        for (let index = 0; index < items.length; ++index) {
            const item = root.map(items[index])
            if (String(item.workflow || "").toLowerCase() === key)
                return item
        }
        return ({})
    }

    function workflowLabel(workflowKey) {
        const key = String(workflowKey || "").toLowerCase()
        const labels = {
            "master": "Master Prompt",
            "clone": "Clone Video",
            "transcript": "Audio to Video",
            "affiliate": "Affiliate",
            "timemachine": "Time Machine"
        }
        return String(labels[key] || workflowKey || "Workflow")
    }

    function modeLabel(modeKey) {
        const key = String(modeKey || "").toLowerCase()
        const labels = {
            "idea": "Ý tưởng",
            "script": "Kịch bản",
            "local_video": "Video cục bộ",
            "audio_file": "Tệp âm thanh",
            "text": "Văn bản",
            "prepared_product": "Sản phẩm đã chuẩn bị",
            "idea_with_images": "Ý tưởng kèm ảnh"
        }
        return String(labels[key] || modeKey || "Đầu vào")
    }

    function modeOptions(capability) {
        const modes = root.list(root.map(capability).input_modes)
        const result = []
        for (let index = 0; index < modes.length; ++index) {
            const value = String(modes[index] || "").toLowerCase()
            if (value)
                result.push({"label": root.modeLabel(value), "value": value})
        }
        return result
    }

    function workflowInputSummary(workflowKey) {
        const modes = root.modeOptions(root.capabilityFor(workflowKey))
        const labels = []
        for (let index = 0; index < modes.length; ++index)
            labels.push(String(modes[index].label || ""))
        return labels.length > 0 ? labels.join(" hoặc ") : "Chưa có đầu vào"
    }

    function workflowIcon(workflowKey) {
        const key = String(workflowKey || "").toLowerCase()
        if (key === "clone") return "semantic/video"
        if (key === "transcript") return "ui/mic"
        if (key === "affiliate") return "ui/archive"
        if (key === "timemachine") return "ui/restore"
        return "semantic/workflow"
    }

    function effectiveMode() {
        const requested = String(root.selectedMode || "").toLowerCase()
        for (let index = 0; index < root.modeItems.length; ++index) {
            if (String(root.modeItems[index].value || "") === requested)
                return requested
        }
        return root.modeItems.length > 0
            ? String(root.modeItems[0].value || "") : ""
    }

    function modeIndex() {
        const active = root.effectiveMode()
        for (let index = 0; index < root.modeItems.length; ++index) {
            if (String(root.modeItems[index].value || "") === active)
                return index
        }
        return -1
    }

    function clearInput() {
        textInput.clear()
        fileInput.clear()
    }

    function ensureDefaultSchedule() {
        if (scheduleInput.text.trim())
            return
        const target = new Date(Date.now() + 60 * 60 * 1000)
        target.setSeconds(0, 0)
        const two = function(value) { return String(value).padStart(2, "0") }
        scheduleInput.text = String(target.getFullYear()) + "-"
            + two(target.getMonth() + 1) + "-" + two(target.getDate())
            + " " + two(target.getHours()) + ":" + two(target.getMinutes())
    }

    function selectDeliveryMode(mode) {
        const normalized = String(mode || "none")
        root.selectedDeliveryMode = normalized
        if (normalized === "scheduled")
            root.ensureDefaultSchedule()
    }

    function resetForm() {
        titleInput.clear()
        root.selectedMode = ""
        root.clearInput()
        aiBriefInput.clear()
        instructionInput.clear()
        captionInput.clear()
        scheduleInput.clear()
        languageInput.currentIndex = 0
        profileInput.currentIndex = 0
        root.selectedDeliveryMode = "none"
        root.lastAppliedDraftHash = ""
    }

    function selectWorkflow(workflowKey) {
        const key = String(workflowKey || "").toLowerCase()
        if (!key || key === root.selectedWorkflowKey)
            return
        root.selectedWorkflowKey = key
        root.selectedMode = ""
        titleInput.clear()
        root.clearInput()
    }

    function ensureSelection() {
        if (root.capabilityFor(root.selectedWorkflowKey).workflow)
            return
        const preferred = root.capabilityFor("master")
        const items = root.list(root.workflows)
        const nextKey = preferred.workflow
            ? "master"
            : (items.length > 0 ? String(root.map(items[0]).workflow || "") : "")
        if (nextKey)
            root.selectWorkflow(nextKey)
    }

    function readinessMessage(capability) {
        const item = root.map(capability)
        const entitlement = String(item.local_entitlement || "").toLowerCase()
        if (entitlement === "allowed")
            return "Runtime nội bộ đã sẵn sàng."
        return String(item.readiness_message || item.readiness_code
            || "Workflow này chưa có runtime nội bộ an toàn.")
    }

    function executionMessage() {
        if (root.runActive) {
            const owner = root.workflowLabel(root.execution.owner_workflow)
            const state = String(root.execution.owner_state || "đang chạy")
            return "Đang chạy " + owner + " · " + state
        }
        if (root.canSubmit)
            return "Sẵn sàng nhận một workflow mới."
        const reason = String(root.execution.reason || "")
        if (reason === "state_unknown" || reason === "submission_state_unknown")
            return "Đang xác minh trạng thái thực thi cục bộ."
        if (reason === "submission_pending")
            return "Đang gửi workflow vào Tool 1."
        return reason || "Chưa thể nhận workflow mới."
    }

    function inputPlaceholder() {
        const workflow = root.selectedWorkflowKey
        const mode = root.effectiveMode()
        if (workflow === "master" && mode === "script")
            return "Dán kịch bản hoàn chỉnh để Master xử lý"
        if (workflow === "master")
            return "Nhập một ý tưởng video"
        if (workflow === "transcript")
            return "Dán transcript hoặc nội dung lời thoại"
        if (workflow === "timemachine")
            return "Nhập ý tưởng Time Machine"
        if (workflow === "affiliate")
            return "Nhập ID sản phẩm đã chuẩn bị"
        return "Nhập nội dung đầu vào"
    }

    function runBlocker() {
        if (!root.selectedCapability.workflow)
            return "Chưa tải được capability cục bộ."
        if (!root.selectedAllowed)
            return root.readinessMessage(root.selectedCapability)
        if (!root.canSubmit)
            return root.executionMessage()
        if (!root.currentContent.length)
            return "Nhập nội dung đầu vào trước khi chạy."
        if (!root.publishReady) {
            if (!String(root.selectedProfile.profileId || ""))
                return "Chọn hồ sơ đăng trước khi bật tự đăng."
            if (String(root.selectedProfile.authState || "") !== "verified")
                return "Hồ sơ đăng chưa được xác minh tài khoản và kênh."
            return "Đóng browser đăng nhập trước khi giao bước đăng tự động."
        }
        if (!root.scheduleReady)
            return "Lịch đăng phải hợp lệ, nằm trong tương lai."
        return ""
    }

    function productionDraftStillMatches(draft, title) {
        if (!String(draft.draftHash || ""))
            return false
        return String(draft.status || "") === "draft"
            && String(draft.title || "") === title
            && String(draft.workflow || "") === root.selectedWorkflowKey
            && String(draft.inputMode || "") === root.effectiveMode()
            && String(draft.content || "") === root.currentContent
            && String(draft.plannerBrief || "") === aiBriefInput.text.trim()
    }

    function draftStillMatches(draft, title) {
        if (!root.productionDraftStillMatches(draft, title))
            return false
        const draftPublishes = Boolean(draft.publishEnabled)
        return draftPublishes === root.publishEnabled
            && (!draftPublishes || (
                root.deliveryMode === "after_production"
                && String(draft.platform || "").toLowerCase()
                    === String(root.selectedProfile.platform || "").toLowerCase()
                && String(draft.profileId || "")
                    === String(root.selectedProfile.profileId || "")
                && String(draft.caption || "") === captionInput.text.trim()
            ))
    }

    function assignmentDefinition() {
        const draft = root.map(root.controlPlaneBridge
            ? root.controlPlaneBridge.planDraft : null)
        const profileId = root.publishEnabled
            ? String(root.selectedProfile.profileId || "") : ""
        const title = titleInput.text.trim()
            || root.workflowLabel(root.selectedWorkflowKey) + " automation"
        const reviewedProductionDraft = root.productionDraftStillMatches(draft, title)
        const reviewedAiDraft = root.draftStillMatches(draft, title)
        return {
            "version": 2,
            "title": title,
            "source": reviewedAiDraft ? "aistudio"
                : (reviewedProductionDraft ? "aistudio_reviewed" : "manual"),
            "production_control": {
                "workflow": root.selectedWorkflowKey,
                "input_mode": root.effectiveMode(),
                "content": root.currentContent,
                "options": {},
                "config": {},
                "intent": {
                    "instructions": instructionInput.text.trim(),
                    "language": String(languageInput.currentValue || "")
                },
                "prompt_control": {
                    "brief": aiBriefInput.text.trim(),
                    "instructions": instructionInput.text.trim(),
                    "language": String(languageInput.currentValue || ""),
                    "planner_contract_hash": reviewedProductionDraft
                        ? String(draft.plannerContractHash || "") : "",
                    "draft_hash": reviewedProductionDraft
                        ? String(draft.draftHash || "") : ""
                }
            },
            "delivery": {
                "enabled": root.publishEnabled,
                "mode": root.deliveryMode,
                "platform": root.publishEnabled
                    ? String(root.selectedProfile.platform || "") : "",
                "channel_id": root.publishEnabled
                    ? String(root.selectedProfile.channelId || profileId) : "",
                "profile_id": profileId,
                "caption_mode": captionInput.text.trim() ? "manual" : "publish_kit",
                "caption": captionInput.text.trim(),
                "scheduled_at_utc": root.scheduledAtUtc,
                "timezone": root.deliveryMode === "scheduled"
                    ? String(root.controlPlaneBridge.localTimezone || "UTC") : "UTC"
            }
        }
    }

    function submitSelected() {
        if (!root.runEnabled)
            return
        root.runRequested({"definition": root.assignmentDefinition()})
    }

    function requestAiDraft() {
        if (!root.controlPlaneBridge || !aiBriefInput.text.trim()) return
        root.controlPlaneBridge.callTool("tool1.assignment.draft", {
            "brief": aiBriefInput.text.trim(),
            "auto_publish": root.publishEnabled,
            "profile_id": root.publishEnabled
                ? String(root.selectedProfile.profileId || "") : ""
        })
    }

    function applyPlanDraft() {
        const draft = root.map(root.controlPlaneBridge
            ? root.controlPlaneBridge.planDraft : null)
        const draftHash = String(draft.draftHash || "")
        if (String(draft.status || "") !== "draft" || !draftHash) {
            root.lastAppliedDraftHash = ""
            return
        }
        if (draftHash === root.lastAppliedDraftHash)
            return
        const workflow = String(draft.workflow || "")
        if (workflow) root.selectWorkflow(workflow)
        root.selectedMode = String(draft.inputMode || "")
        titleInput.text = String(draft.title || "")
        if (root.fileInputMode)
            fileInput.text = String(draft.content || "")
        else
            textInput.text = String(draft.content || "")
        captionInput.text = String(draft.caption || "")
        const profileId = String(draft.profileId || "")
        if (profileId) {
            for (let index = 0; index < root.profileItems.length; index++) {
                if (String(root.profileItems[index].value || "") === profileId) {
                    profileInput.currentIndex = index
                    break
                }
            }
        }
        root.lastAppliedDraftHash = draftHash
    }

    onWorkflowsChanged: root.ensureSelection()
    Component.onCompleted: root.ensureSelection()

    Connections {
        target: root.controlPlaneBridge
        function onAssignmentChanged() {
            root.profileRevision++
            root.applyPlanDraft()
        }
    }

    component FormTextArea: TextArea {
        id: control
        wrapMode: TextEdit.Wrap
        activeFocusOnTab: true
        selectByMouse: true
        color: control.enabled ? Theme.text : Theme.textFaint
        placeholderTextColor: Theme.textFaint
        selectionColor: Theme.accent
        selectedTextColor: "white"
        font.pixelSize: Theme.fontBody
        leftPadding: 12
        rightPadding: 12
        topPadding: 10
        bottomPadding: 10
        background: Rectangle {
            radius: Theme.radiusSmall
            color: Theme.elevated
            border.width: 1
            border.color: control.activeFocus ? Theme.accent : Theme.borderSoft
        }
    }

    FileDialog {
        id: sourceDialog
        title: root.effectiveMode() === "audio_file"
            ? "Chọn tệp âm thanh" : "Chọn video nguồn"
        fileMode: FileDialog.OpenFile
        nameFilters: root.effectiveMode() === "audio_file"
            ? ["Âm thanh (*.m4a *.mp3 *.ogg *.wav)"]
            : ["Video (*.3gpp *.avi *.flv *.mkv *.mov *.mp4 *.mpeg *.mpg *.webm *.wmv)"]
        onAccepted: {
            if (root.controlPlaneBridge)
                fileInput.text = root.controlPlaneBridge.localPath(selectedFile)
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 56
            Layout.minimumHeight: 48
            Layout.leftMargin: Theme.space5
            Layout.rightMargin: Theme.space5

            Text {
                Layout.fillWidth: true
                text: "Chạy trực tiếp trong Tool 1"
                color: Theme.text
                font.pixelSize: Theme.fontSection
                font.weight: Font.DemiBold
                verticalAlignment: Text.AlignVCenter
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: Theme.borderSoft
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: 390
            Layout.margins: Theme.space4
            spacing: Theme.space4

            ColumnLayout {
                Layout.preferredWidth: 265
                Layout.minimumWidth: 220
                Layout.fillHeight: true
                spacing: Theme.space2

                Repeater {
                    objectName: "tool1WorkflowChoices"
                    model: root.workflows

                    delegate: Button {
                        id: workflowButton
                        required property var modelData
                        readonly property string workflowKey: String(
                            workflowButton.modelData.workflow || "").toLowerCase()
                        readonly property bool locallyAllowed: String(
                            workflowButton.modelData.local_entitlement || "").toLowerCase()
                            === "allowed"
                        readonly property bool selected: root.selectedWorkflowKey
                            === workflowButton.workflowKey

                        objectName: "tool1WorkflowChoice_" + workflowButton.workflowKey
                        Layout.fillWidth: true
                        Layout.preferredHeight: 60
                        leftPadding: Theme.space3
                        rightPadding: Theme.space3
                        hoverEnabled: true
                        activeFocusOnTab: true
                        Accessible.role: Accessible.Button
                        Accessible.name: root.workflowLabel(workflowButton.workflowKey)
                        Accessible.description: root.readinessMessage(workflowButton.modelData)

                        contentItem: RowLayout {
                            spacing: Theme.space3
                            UiIcon {
                                name: root.workflowIcon(workflowButton.workflowKey)
                                tone: workflowButton.selected
                                    ? Theme.accent : Theme.textMuted
                                iconSize: 20
                                Layout.preferredWidth: 20
                                Layout.preferredHeight: 20
                            }
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2
                                Text {
                                    Layout.fillWidth: true
                                    text: root.workflowLabel(workflowButton.workflowKey)
                                    color: Theme.text
                                    font.pixelSize: Theme.fontBody
                                    font.weight: Font.DemiBold
                                    elide: Text.ElideRight
                                }
                                Text {
                                    Layout.fillWidth: true
                                    text: root.workflowInputSummary(workflowButton.workflowKey)
                                    color: workflowButton.locallyAllowed
                                        ? Theme.textMuted : Theme.warning
                                    font.pixelSize: Theme.fontMetadata
                                    elide: Text.ElideRight
                                }
                            }
                            UiIcon {
                                visible: !workflowButton.locallyAllowed
                                name: "semantic/alert-circle"
                                tone: Theme.warning
                                iconSize: 15
                                Layout.preferredWidth: visible ? 15 : 0
                                Layout.preferredHeight: 15
                            }
                        }

                        background: Rectangle {
                            radius: Theme.radiusSmall
                            color: workflowButton.selected ? Theme.accentSoft
                                : (workflowButton.hovered ? Theme.hover : Theme.panel)
                            border.width: 1
                            border.color: workflowButton.selected
                                ? Theme.accent : Theme.borderSoft
                            Rectangle {
                                visible: workflowButton.selected
                                width: 3
                                height: parent.height - 12
                                anchors.left: parent.left
                                anchors.leftMargin: 1
                                anchors.verticalCenter: parent.verticalCenter
                                radius: 2
                                color: Theme.accent
                            }
                        }
                        onClicked: root.selectWorkflow(workflowButton.workflowKey)
                    }
                }

                Text {
                    visible: root.list(root.workflows).length === 0
                    Layout.fillWidth: true
                    text: "Đang đọc capability cục bộ…"
                    color: Theme.textFaint
                    font.pixelSize: Theme.fontBody
                    wrapMode: Text.Wrap
                }

                Item { Layout.fillHeight: true }

                Text {
                    Layout.fillWidth: true
                    text: root.executionMessage()
                    color: root.runActive ? Theme.warning : Theme.textMuted
                    font.pixelSize: Theme.fontMetadata
                    wrapMode: Text.Wrap
                    Accessible.name: text
                }
            }

            Rectangle {
                Layout.preferredWidth: 1
                Layout.fillHeight: true
                color: Theme.borderSoft
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumWidth: 360
                Layout.preferredWidth: 580
                spacing: Theme.space2

                Text {
                    Layout.fillWidth: true
                    text: "Nội dung công việc"
                    color: Theme.text
                    font.pixelSize: Theme.fontBody
                    font.weight: Font.DemiBold
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 5
                    Text {
                        text: "Tên công việc"
                        color: Theme.textMuted
                        font.pixelSize: Theme.fontMetadata
                    }
                    WorkflowTextField {
                        id: titleInput
                        objectName: "tool1WorkflowTitle"
                        Layout.fillWidth: true
                        placeholderText: "Nhập tên công việc"
                        enabled: root.selectedAllowed && !root.actionBusy
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 5
                    Text {
                        text: "Chế độ nhập"
                        color: Theme.textMuted
                        font.pixelSize: Theme.fontMetadata
                    }
                    Rectangle {
                        objectName: "tool1WorkflowMode"
                        Layout.fillWidth: true
                        Layout.preferredHeight: 40
                        radius: Theme.radiusSmall
                        color: Theme.panel
                        border.width: 1
                        border.color: Theme.borderSoft
                        Accessible.name: "Chế độ nhập"
                        Accessible.role: Accessible.Pane

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 3
                            spacing: 3
                            Repeater {
                                model: root.modeItems
                                delegate: AppButton {
                                    id: modeButton
                                    required property var modelData
                                    readonly property string modeKey: String(
                                        modeButton.modelData.value || "")
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    text: String(modeButton.modelData.label || "")
                                    primary: root.effectiveMode() === modeButton.modeKey
                                    subtle: !primary
                                    enabled: root.selectedAllowed && !root.actionBusy
                                    availabilityReason: root.selectedAllowed
                                        ? "" : root.readinessMessage(root.selectedCapability)
                                    onClicked: {
                                        root.selectedMode = modeButton.modeKey
                                        root.clearInput()
                                    }
                                }
                            }
                        }
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 5

                    Text {
                        text: root.fileInputMode
                            ? "Tệp nguồn" : "Ý tưởng hoặc nội dung kịch bản"
                        color: Theme.textMuted
                        font.pixelSize: Theme.fontMetadata
                    }

                    RowLayout {
                        visible: root.fileInputMode
                        Layout.fillWidth: true
                        Layout.preferredHeight: visible ? Theme.controlHeight : 0
                        spacing: Theme.space2

                        WorkflowTextField {
                            id: fileInput
                            objectName: "tool1WorkflowFileInput"
                            Layout.fillWidth: true
                            placeholderText: root.effectiveMode() === "audio_file"
                                ? "Chọn tệp âm thanh cục bộ" : "Chọn video cục bộ"
                            enabled: root.selectedAllowed && !root.actionBusy
                        }
                        AppButton {
                            objectName: "tool1WorkflowBrowseButton"
                            text: "Chọn tệp"
                            leadingIcon: "ui/folder"
                            enabled: root.selectedAllowed && !root.actionBusy
                            availabilityReason: enabled ? ""
                                : root.readinessMessage(root.selectedCapability)
                            onClicked: sourceDialog.open()
                        }
                    }

                    FormTextArea {
                        id: textInput
                        objectName: "tool1WorkflowTextInput"
                        visible: !root.fileInputMode
                        Layout.fillWidth: true
                        Layout.preferredHeight: visible ? 96 : 0
                        placeholderText: root.inputPlaceholder()
                        enabled: root.selectedAllowed && !root.actionBusy
                        Accessible.name: "Nội dung đầu vào workflow"
                        Accessible.description: root.runBlocker()
                    }
                }

                Panel {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.minimumHeight: 120
                    Layout.preferredHeight: 138
                    color: Theme.elevated

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: Theme.space3
                        spacing: 5

                        Text {
                            text: "AI Studio · tạo bản nháp"
                            color: Theme.text
                            font.pixelSize: Theme.fontMetadata
                            font.weight: Font.DemiBold
                        }
                        RowLayout {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            spacing: Theme.space2
                            ColumnLayout {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                spacing: 4
                                Text {
                                    text: "Mô tả mục tiêu"
                                    color: Theme.textMuted
                                    font.pixelSize: Theme.fontMetadata
                                }
                                FormTextArea {
                                    id: aiBriefInput
                                    objectName: "tool1AiBrief"
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    placeholderText: "Mô tả mục tiêu để AI Studio đề xuất đầu vào"
                                    enabled: !root.actionBusy
                                    Accessible.name: "Mô tả mục tiêu cho AI Studio"
                                }
                            }
                            AppButton {
                                objectName: "tool1AiDraftButton"
                                Layout.alignment: Qt.AlignBottom
                                text: "Lên nháp"
                                leadingIcon: "semantic/workflow"
                                enabled: aiBriefInput.text.trim().length > 0
                                    && !root.actionBusy
                                onClicked: root.requestAiDraft()
                            }
                        }
                        Text {
                            Layout.fillWidth: true
                            text: "AI Studio chỉ đề xuất đầu vào cho một công việc; bạn kiểm tra trước khi giao."
                            color: Theme.textFaint
                            font.pixelSize: Theme.fontMetadata
                            elide: Text.ElideRight
                        }
                    }
                }

            }

            Rectangle {
                Layout.preferredWidth: 1
                Layout.fillHeight: true
                color: Theme.borderSoft
            }

            ColumnLayout {
                Layout.preferredWidth: 500
                Layout.minimumWidth: 360
                Layout.maximumWidth: 540
                Layout.fillHeight: true
                spacing: Theme.space2

                Text {
                    Layout.fillWidth: true
                    text: "AI & đăng"
                    color: Theme.text
                    font.pixelSize: Theme.fontBody
                    font.weight: Font.DemiBold
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 5
                    Text {
                        text: "Chỉ dẫn sản xuất"
                        color: Theme.textMuted
                        font.pixelSize: Theme.fontMetadata
                    }
                    FormTextArea {
                        id: instructionInput
                        objectName: "tool1PromptInstructions"
                        Layout.fillWidth: true
                        Layout.preferredHeight: 74
                        placeholderText: "Phong cách, tông giọng, bố cục, điều cần tránh…"
                        enabled: !root.actionBusy
                        Accessible.name: "Chỉ dẫn sản xuất"
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 5
                    Text {
                        text: "Ngôn ngữ"
                        color: Theme.textMuted
                        font.pixelSize: Theme.fontMetadata
                    }
                    WorkflowComboBox {
                        id: languageInput
                        objectName: "tool1PromptLanguage"
                        Layout.fillWidth: true
                        model: root.languageItems
                        textRole: "label"
                        valueRole: "value"
                        enabled: !root.actionBusy
                    }
                }

                ColumnLayout {
                    objectName: "tool1DeliveryMode"
                    Layout.fillWidth: true
                    spacing: 3
                    Accessible.name: "Cách giao"
                    Accessible.role: Accessible.Pane

                    Text {
                        text: "Cách giao"
                        color: Theme.textMuted
                        font.pixelSize: Theme.fontMetadata
                    }
                    ButtonGroup { id: deliveryGroup }
                    Repeater {
                        model: root.deliveryItems
                        delegate: RadioButton {
                            id: deliveryButton
                            required property var modelData
                            readonly property string deliveryValue: String(
                                deliveryButton.modelData.value || "none")
                            Layout.fillWidth: true
                            Layout.preferredHeight: 24
                            text: String(deliveryButton.modelData.label || "")
                            checked: root.deliveryMode === deliveryButton.deliveryValue
                            enabled: !root.actionBusy
                            font.pixelSize: Theme.fontMetadata
                            leftPadding: 0
                            spacing: 7
                            ButtonGroup.group: deliveryGroup
                            Accessible.name: text

                            indicator: Rectangle {
                                x: 0
                                anchors.verticalCenter: parent.verticalCenter
                                implicitWidth: 15
                                implicitHeight: 15
                                radius: 8
                                color: Theme.panel
                                border.width: 1
                                border.color: deliveryButton.checked
                                    ? Theme.accent : Theme.border
                                Rectangle {
                                    visible: deliveryButton.checked
                                    anchors.centerIn: parent
                                    width: 7
                                    height: 7
                                    radius: 4
                                    color: Theme.accent
                                }
                            }
                            contentItem: Text {
                                leftPadding: deliveryButton.indicator.width
                                    + deliveryButton.spacing
                                text: deliveryButton.text
                                color: deliveryButton.enabled
                                    ? Theme.text : Theme.textFaint
                                font: deliveryButton.font
                                verticalAlignment: Text.AlignVCenter
                                elide: Text.ElideRight
                            }
                            onClicked: root.selectDeliveryMode(deliveryButton.deliveryValue)
                        }
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 5
                    Text {
                        Layout.fillWidth: true
                        text: root.publishEnabled
                            ? "Hồ sơ và kênh đăng"
                            : "Hồ sơ đăng sẽ được chọn khi bật đăng"
                        color: Theme.textMuted
                        font.pixelSize: Theme.fontMetadata
                        elide: Text.ElideRight
                    }
                    WorkflowComboBox {
                        id: profileInput
                        objectName: "tool1DeliveryProfile"
                        Layout.fillWidth: true
                        model: root.profileItems
                        textRole: "label"
                        valueRole: "value"
                        leadingPlatform: root.publishEnabled
                            ? String(root.selectedProfile.platform || "") : ""
                        enabled: root.publishEnabled && !root.actionBusy
                        availabilityReason: root.publishEnabled
                            ? root.runBlocker() : "Bật đăng để chọn hồ sơ"
                    }
                }

                ColumnLayout {
                    visible: root.deliveryMode === "scheduled"
                    Layout.fillWidth: true
                    spacing: 5
                    Text {
                        text: "Lịch đăng · " + String(root.controlPlaneBridge
                            ? root.controlPlaneBridge.localTimezone || "UTC" : "UTC")
                        color: Theme.textMuted
                        font.pixelSize: Theme.fontMetadata
                    }
                    WorkflowTextField {
                        id: scheduleInput
                        objectName: "tool1DeliverySchedule"
                        Layout.fillWidth: true
                        placeholderText: "YYYY-MM-DD HH:mm"
                        enabled: !root.actionBusy
                        availabilityReason: root.scheduleReady
                            ? "" : "Chọn thời điểm hợp lệ trong tương lai"
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 5
                    Text {
                        text: root.publishEnabled
                            ? "Chú thích đăng (để trống để dùng publish kit)"
                            : "Chú thích đăng (tùy chọn)"
                        color: Theme.textMuted
                        font.pixelSize: Theme.fontMetadata
                    }
                    FormTextArea {
                        id: captionInput
                        objectName: "tool1DeliveryCaption"
                        Layout.fillWidth: true
                        Layout.fillHeight: root.publishEnabled
                        Layout.preferredHeight: root.publishEnabled ? 64 : Theme.controlHeight
                        placeholderText: root.publishEnabled
                            ? "Tiêu đề hoặc caption theo nền tảng"
                            : "Bật đăng để nhập chú thích"
                        enabled: root.publishEnabled && !root.actionBusy
                        Accessible.name: "Chú thích đăng theo nền tảng"
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: Theme.borderSoft
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 56
            Layout.minimumHeight: 52
            Layout.leftMargin: Theme.space5
            Layout.rightMargin: Theme.space5
            spacing: Theme.space2

            Text {
                Layout.fillWidth: true
                readonly property string actionText: root.controlPlaneBridge
                    ? String(root.controlPlaneBridge.actionMessage || "") : ""
                text: actionText || "Mỗi lần tạo 1 công việc · Đầu ra được kiểm tra trước bước đăng"
                color: actionText ? Theme.accent
                    : (root.runEnabled ? Theme.textMuted : Theme.textFaint)
                font.pixelSize: Theme.fontMetadata
                elide: Text.ElideRight
                Accessible.name: text
                Accessible.description: root.runBlocker()
            }
            AppButton {
                objectName: "tool1WorkflowResetButton"
                text: "Đặt lại"
                enabled: !root.actionBusy
                onClicked: root.resetForm()
            }
            AppButton {
                objectName: "tool1WorkflowRunButton"
                text: root.actionBusy ? "Đang giao…" : "Giao việc"
                leadingIcon: "ui/play"
                primary: true
                enabled: root.runEnabled
                availabilityReason: root.runBlocker()
                onClicked: root.submitSelected()
            }
        }
    }
}
