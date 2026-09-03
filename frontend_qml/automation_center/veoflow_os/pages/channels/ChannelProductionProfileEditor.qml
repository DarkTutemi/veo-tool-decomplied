pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../.."
import "../../foundation" as Foundation
import "../automation" as Automation

ScrollView {
    id: root
    objectName: "channelProductionProfileEditor"
    clip: true
    contentWidth: availableWidth

    property var profile: ({})
    property var channelProfileModel: null
    property var controlPlaneBridge: null
    property bool canWrite: false
    property int commandRevision: 0
    property int modelRevision: 0
    property bool draftDirty: false
    property string feedbackMessage: ""
    property bool feedbackOk: false

    readonly property string socialProfileId: String(
        (root.profile || {}).profileId || "")
    readonly property string platform: String(
        ((root.profile || {}).platformSummary || {}).primary || "")
    readonly property string channelId: String(
        ((root.profile || {}).channelSummary || {}).channelId || "")
    readonly property bool verified: String(
        (root.profile || {}).authState || "") === "verified"
    readonly property bool actionBusy: Boolean(
        root.controlPlaneBridge && root.controlPlaneBridge.actionBusy)
    readonly property var currentProfile: {
        const revision = root.modelRevision
        return root.profileForSocialProfile(root.socialProfileId)
    }
    readonly property bool hasProfile: String(
        root.currentProfile.channelProfileId || "").length > 0
    readonly property bool canSave: root.canWrite && root.verified
        && root.socialProfileId.length > 0 && root.channelId.length > 0
        && !root.actionBusy

    Accessible.name: "Cấu hình sản xuất theo kênh"
    Accessible.role: Accessible.Pane

    function map(value) {
        return value === null || value === undefined ? ({}) : value
    }

    function profileForSocialProfile(profileId) {
        if (!root.channelProfileModel || !profileId)
            return ({})
        const wantedProfileId = String(profileId || "")
        const wantedConfigId = String((root.profile || {}).channelProfileId || "")
        for (let index = 0; index < Number(root.channelProfileModel.count || 0); ++index) {
            const row = root.channelProfileModel.get(index) || ({})
            if ((wantedConfigId && String(row.channelProfileId || "") === wantedConfigId)
                    || String(row.socialProfileId || "") === wantedProfileId)
                return row
        }
        return ({})
    }

    function joinLines(value) {
        const items = value || []
        const output = []
        for (let index = 0; index < items.length; ++index) {
            const clean = String(items[index] || "").trim()
            if (clean && output.indexOf(clean) < 0)
                output.push(clean)
        }
        return output.join("\n")
    }

    function splitLines(value) {
        const raw = String(value || "").split(/[\n,;]+/)
        const output = []
        for (let index = 0; index < raw.length; ++index) {
            const clean = String(raw[index] || "").trim()
            if (clean && output.indexOf(clean) < 0)
                output.push(clean)
        }
        return output
    }

    function sourceForCategory(category) {
        const policy = root.map(root.currentProfile.assetPolicy)
        const scopes = root.map(policy.scopes)
        const scope = root.map(scopes[String(category || "")])
        const direct = String(scope.source || scope.source_policy
            || policy[String(category || "")] || "ai").toLowerCase()
        return ["ai", "hybrid", "library_only", "disabled"].indexOf(direct) >= 0
            ? direct : "ai"
    }

    function selectComboValue(combo, value) {
        const wanted = String(value || "")
        combo.currentIndex = 0
        for (let index = 0; index < combo.count; ++index) {
            const row = combo.model && combo.model.get
                ? combo.model.get(index) : combo.model[index]
            if (String((row || {}).value || "") === wanted) {
                combo.currentIndex = index
                return
            }
        }
    }

    function syncForm(force) {
        if (root.draftDirty && force !== true)
            return
        const row = root.currentProfile || ({})
        const brand = root.map(row.brand)
        const entities = root.map(row.entities)
        const delivery = root.map(row.deliveryDefaults)
        labelInput.text = String(row.label
            || (root.profile || {}).label
            || ((root.profile || {}).channelSummary || {}).displayName
            || "")
        languageInput.text = String(brand.language || "")
        audienceInput.text = String(brand.audience || "")
        positioningInput.text = String(brand.positioning || "")
        pillarsInput.text = root.joinLines(brand.content_pillars || [])
        charactersInput.text = root.joinLines(entities.character_ids || [])
        voiceInput.text = String(entities.voice_id || "")
        styleInput.text = String(entities.style_id || "")
        root.selectComboValue(characterPolicy, root.sourceForCategory("characters"))
        root.selectComboValue(objectPolicy, root.sourceForCategory("objects"))
        root.selectComboValue(backgroundPolicy, root.sourceForCategory("backgrounds"))
        root.selectComboValue(captionMode, String(delivery.caption_mode || "publish_kit"))
        timezoneInput.text = String(delivery.timezone
            || (root.controlPlaneBridge ? root.controlPlaneBridge.localTimezone : "")
            || "UTC")
        intervalInput.value = Math.max(1, Math.min(43200,
            Number(delivery.interval_minutes || 1440)))
        root.draftDirty = false
    }

    function policyScope(source) {
        const normalized = String(source || "ai")
        return {
            "source": normalized,
            "missing": (normalized === "library_only" || normalized === "disabled")
                ? "omit" : "generate",
            "rewrite": normalized === "library_only"
                ? "fit_assets" : "replace_matching"
        }
    }

    function buildAssetPolicy() {
        const characters = String(characterPolicy.currentValue || "ai")
        const objects = String(objectPolicy.currentValue || "ai")
        const backgrounds = String(backgroundPolicy.currentValue || "ai")
        const states = {
            "characters": characters,
            "objects": objects,
            "backgrounds": backgrounds
        }
        const categories = []
        let activeCount = 0
        let lockedCount = 0
        const order = ["characters", "objects", "backgrounds"]
        for (let index = 0; index < order.length; ++index) {
            const source = states[order[index]]
            if (source === "hybrid" || source === "library_only") {
                categories.push(order[index])
                ++activeCount
            }
            if (source === "library_only")
                ++lockedCount
        }
        return {
            "mode": "matrix",
            "categories": categories,
            "scopes": {
                "characters": root.policyScope(characters),
                "objects": root.policyScope(objects),
                "backgrounds": root.policyScope(backgrounds)
            },
            "mapping": "source_role_binding_exact_ids",
            "strictness": activeCount > 0 && lockedCount === activeCount
                ? "hard_lock" : "soft_guide"
        }
    }

    function formPayload() {
        return {
            "social_profile_id": root.socialProfileId,
            "channel_profile_id": String(root.currentProfile.channelProfileId || ""),
            "platform": root.platform,
            "channel_id": root.channelId,
            "label": labelInput.text.trim(),
            "brand": {
                "language": languageInput.text.trim(),
                "audience": audienceInput.text.trim(),
                "positioning": positioningInput.text.trim(),
                "content_pillars": root.splitLines(pillarsInput.text)
            },
            "entities": {
                "character_ids": root.splitLines(charactersInput.text),
                "voice_id": voiceInput.text.trim(),
                "style_id": styleInput.text.trim()
            },
            "asset_policy": root.buildAssetPolicy(),
            "delivery_defaults": {
                "caption_mode": String(captionMode.currentValue || "publish_kit"),
                "timezone": timezoneInput.text.trim() || "UTC",
                "interval_minutes": intervalInput.value
            }
        }
    }

    function submit(captureFeatureConfigs) {
        if (!root.controlPlaneBridge || !root.canSave)
            return
        root.feedbackMessage = ""
        const payload = root.formPayload()
        if (captureFeatureConfigs) {
            root.controlPlaneBridge.callTool("tool1.channel_profile.capture", {
                "social_profile_id": root.socialProfileId,
                "overrides": payload
            })
        } else {
            root.controlPlaneBridge.callTool("tool1.channel_profile.save", payload)
        }
    }

    onSocialProfileIdChanged: {
        root.draftDirty = false
        root.feedbackMessage = ""
        Qt.callLater(function() { root.syncForm(true) })
    }

    Component.onCompleted: Qt.callLater(function() { root.syncForm(true) })

    Connections {
        target: root.channelProfileModel
        function onModelReset() {
            root.modelRevision += 1
            Qt.callLater(function() { root.syncForm(false) })
        }
        function onCountChanged() {
            root.modelRevision += 1
            Qt.callLater(function() { root.syncForm(false) })
        }
    }

    Connections {
        target: root.controlPlaneBridge
        function onActionFinished(toolName, ok, data, message) {
            const name = String(toolName || "")
            if (name !== "tool1.channel_profile.save"
                    && name !== "tool1.channel_profile.capture")
                return
            root.feedbackOk = Boolean(ok)
            root.feedbackMessage = ok
                ? "Đã lưu một revision bất biến cho kênh này."
                : String(message || "Không thể lưu cấu hình sản xuất của kênh.")
            if (ok) {
                root.draftDirty = false
                Qt.callLater(function() { root.syncForm(true) })
            }
        }
    }

    component FieldLabel: Text {
        required property string label
        Layout.fillWidth: true
        text: label
        color: Theme.textMuted
        font.pixelSize: Theme.fontMetadata
        font.weight: Font.DemiBold
    }

    component DraftTextArea: TextArea {
        id: field
        Layout.fillWidth: true
        Layout.preferredHeight: 62
        wrapMode: TextArea.Wrap
        color: field.enabled ? Theme.text : Theme.textFaint
        placeholderTextColor: Theme.textFaint
        selectionColor: Theme.accent
        selectedTextColor: "white"
        font.pixelSize: Theme.fontMetadata
        activeFocusOnTab: true
        selectByMouse: true
        background: Rectangle {
            radius: Theme.radiusSmall
            color: Theme.elevated
            border.width: 1
            border.color: field.activeFocus ? Theme.accent : Theme.borderSoft
        }
    }

    ListModel {
        id: policyOptions
        ListElement { label: "AI tự tạo"; value: "ai" }
        ListElement { label: "Thư viện + AI"; value: "hybrid" }
        ListElement { label: "Chỉ thư viện"; value: "library_only" }
        ListElement { label: "Tắt"; value: "disabled" }
    }

    ListModel {
        id: captionOptions
        ListElement { label: "PublishKit"; value: "publish_kit" }
        ListElement { label: "Nhập thủ công"; value: "manual" }
    }

    ColumnLayout {
        width: root.availableWidth
        spacing: 10
        leftPadding: 12
        rightPadding: 12
        topPadding: 12
        bottomPadding: 18

        RowLayout {
            Layout.fillWidth: true
            spacing: 8
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2
                Text {
                    Layout.fillWidth: true
                    text: "Cấu hình sản xuất"
                    color: Theme.text
                    font.pixelSize: Theme.fontSection
                    font.weight: Font.Bold
                    elide: Text.ElideRight
                }
                Text {
                    Layout.fillWidth: true
                    text: root.hasProfile
                        ? "Revision " + String(root.currentProfile.version || 0)
                            + " · " + String(root.currentProfile.configHash || "").slice(0, 12)
                        : "Chưa có revision cho kênh này"
                    color: root.hasProfile ? Theme.textFaint : Theme.warning
                    font.pixelSize: Theme.fontMetadata
                    elide: Text.ElideMiddle
                }
            }
            Foundation.StatusPill {
                text: root.verified ? "Đã xác minh" : "Chưa xác minh"
                tone: root.verified ? Theme.success : Theme.warning
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            radius: Theme.radiusSmall
            color: Theme.elevated
            border.width: 1
            border.color: Theme.borderSoft
            RowLayout {
                anchors.fill: parent
                anchors.margins: 9
                spacing: 8
                PlatformIcon {
                    platform: root.platform
                    iconSize: 22
                    Layout.preferredWidth: 24
                    Layout.preferredHeight: 24
                }
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 1
                    Text {
                        Layout.fillWidth: true
                        text: String(((root.profile || {}).channelSummary || {}).displayName
                            || (root.profile || {}).label || "Kênh chưa xác định")
                        color: Theme.text
                        font.pixelSize: Theme.fontBody
                        font.weight: Font.DemiBold
                        elide: Text.ElideRight
                    }
                    Text {
                        Layout.fillWidth: true
                        text: root.channelId || "Cần xác minh danh tính kênh"
                        color: Theme.textFaint
                        font.pixelSize: Theme.fontMetadata
                        elide: Text.ElideMiddle
                    }
                }
            }
        }

        Text {
            visible: !root.verified
            Layout.fillWidth: true
            text: "Hãy đăng nhập và xác minh tài khoản trước khi tạo cấu hình. Backend sẽ không cho gán nhầm kênh."
            color: Theme.warning
            font.pixelSize: Theme.fontMetadata
            wrapMode: Text.Wrap
        }

        FieldLabel { label: "Tên cấu hình" }
        Automation.WorkflowTextField {
            id: labelInput
            objectName: "channelProductionLabelInput"
            Layout.fillWidth: true
            placeholderText: "Ví dụ: English Daily"
            enabled: root.canWrite && !root.actionBusy
            onTextEdited: root.draftDirty = true
        }

        FieldLabel { label: "Ngôn ngữ nội dung" }
        Automation.WorkflowTextField {
            id: languageInput
            objectName: "channelProductionLanguageInput"
            Layout.fillWidth: true
            placeholderText: "vi, en, th..."
            enabled: root.canWrite && !root.actionBusy
            onTextEdited: root.draftDirty = true
        }

        FieldLabel { label: "Đối tượng khán giả" }
        DraftTextArea {
            id: audienceInput
            objectName: "channelProductionAudienceInput"
            placeholderText: "Kênh phục vụ ai, trình độ và nhu cầu nào?"
            enabled: root.canWrite && !root.actionBusy
            onTextChanged: if (activeFocus) root.draftDirty = true
        }

        FieldLabel { label: "Định vị kênh" }
        DraftTextArea {
            id: positioningInput
            objectName: "channelProductionPositioningInput"
            placeholderText: "Góc tiếp cận, lời hứa nội dung, khác biệt chính"
            enabled: root.canWrite && !root.actionBusy
            onTextChanged: if (activeFocus) root.draftDirty = true
        }

        FieldLabel { label: "Trụ cột nội dung · mỗi dòng một mục" }
        DraftTextArea {
            id: pillarsInput
            objectName: "channelProductionPillarsInput"
            placeholderText: "Kiến thức\nCase study\nTin ngắn"
            enabled: root.canWrite && !root.actionBusy
            onTextChanged: if (activeFocus) root.draftDirty = true
        }

        Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Theme.borderSoft }

        Text {
            Layout.fillWidth: true
            text: "NHÂN VẬT · VOICE · STYLE"
            color: Theme.textFaint
            font.pixelSize: Theme.fontMetadata
            font.weight: Font.Bold
            font.letterSpacing: 0.5
        }
        FieldLabel { label: "ID nhân vật · mỗi dòng một ID thư viện" }
        DraftTextArea {
            id: charactersInput
            objectName: "channelProductionCharactersInput"
            placeholderText: "character-host-01\ncharacter-guest-01"
            enabled: root.canWrite && !root.actionBusy
            onTextChanged: if (activeFocus) root.draftDirty = true
        }
        FieldLabel { label: "Voice ID mặc định" }
        Automation.WorkflowTextField {
            id: voiceInput
            objectName: "channelProductionVoiceInput"
            Layout.fillWidth: true
            placeholderText: "voice-en-host"
            enabled: root.canWrite && !root.actionBusy
            onTextEdited: root.draftDirty = true
        }
        FieldLabel { label: "Style ID mặc định" }
        Automation.WorkflowTextField {
            id: styleInput
            objectName: "channelProductionStyleInput"
            Layout.fillWidth: true
            placeholderText: "style-documentary-clean"
            enabled: root.canWrite && !root.actionBusy
            onTextEdited: root.draftDirty = true
        }

        Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Theme.borderSoft }

        Text {
            Layout.fillWidth: true
            text: "NGUỒN ASSET CHO MỌI WORKFLOW"
            color: Theme.textFaint
            font.pixelSize: Theme.fontMetadata
            font.weight: Font.Bold
            font.letterSpacing: 0.5
        }
        FieldLabel { label: "Nhân vật" }
        Automation.WorkflowComboBox {
            id: characterPolicy
            objectName: "channelProductionCharacterPolicy"
            Layout.fillWidth: true
            model: policyOptions
            textRole: "label"
            valueRole: "value"
            enabled: root.canWrite && !root.actionBusy
            onActivated: root.draftDirty = true
        }
        FieldLabel { label: "Đồ vật" }
        Automation.WorkflowComboBox {
            id: objectPolicy
            objectName: "channelProductionObjectPolicy"
            Layout.fillWidth: true
            model: policyOptions
            textRole: "label"
            valueRole: "value"
            enabled: root.canWrite && !root.actionBusy
            onActivated: root.draftDirty = true
        }
        FieldLabel { label: "Bối cảnh" }
        Automation.WorkflowComboBox {
            id: backgroundPolicy
            objectName: "channelProductionBackgroundPolicy"
            Layout.fillWidth: true
            model: policyOptions
            textRole: "label"
            valueRole: "value"
            enabled: root.canWrite && !root.actionBusy
            onActivated: root.draftDirty = true
        }

        Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Theme.borderSoft }

        Text {
            Layout.fillWidth: true
            text: "MẶC ĐỊNH XUẤT BẢN"
            color: Theme.textFaint
            font.pixelSize: Theme.fontMetadata
            font.weight: Font.Bold
            font.letterSpacing: 0.5
        }
        FieldLabel { label: "Caption" }
        Automation.WorkflowComboBox {
            id: captionMode
            objectName: "channelProductionCaptionMode"
            Layout.fillWidth: true
            model: captionOptions
            textRole: "label"
            valueRole: "value"
            enabled: root.canWrite && !root.actionBusy
            onActivated: root.draftDirty = true
        }
        FieldLabel { label: "Múi giờ IANA" }
        Automation.WorkflowTextField {
            id: timezoneInput
            objectName: "channelProductionTimezoneInput"
            Layout.fillWidth: true
            placeholderText: "Asia/Bangkok"
            enabled: root.canWrite && !root.actionBusy
            onTextEdited: root.draftDirty = true
        }
        FieldLabel { label: "Khoảng cách đăng · phút" }
        Automation.WorkflowSpinBox {
            id: intervalInput
            objectName: "channelProductionIntervalInput"
            Layout.fillWidth: true
            from: 1
            to: 43200
            value: 1440
            enabled: root.canWrite && !root.actionBusy
            onValueModified: root.draftDirty = true
        }

        Rectangle {
            visible: root.feedbackMessage.length > 0
            Layout.fillWidth: true
            Layout.preferredHeight: feedbackText.implicitHeight + 16
            radius: Theme.radiusSmall
            color: Qt.rgba(
                (root.feedbackOk ? Theme.success : Theme.danger).r,
                (root.feedbackOk ? Theme.success : Theme.danger).g,
                (root.feedbackOk ? Theme.success : Theme.danger).b, 0.10)
            Text {
                id: feedbackText
                anchors.fill: parent
                anchors.margins: 8
                text: root.feedbackMessage
                color: root.feedbackOk ? Theme.success : Theme.danger
                font.pixelSize: Theme.fontMetadata
                wrapMode: Text.Wrap
            }
        }

        AppButton {
            objectName: "channelProductionSaveButton"
            Layout.fillWidth: true
            text: root.hasProfile ? "Lưu revision mới" : "Tạo cấu hình kênh"
            leadingIcon: "ui/save"
            primary: true
            enabled: root.canSave && (root.draftDirty || !root.hasProfile)
            Accessible.description: !root.verified
                ? "Cần xác minh tài khoản trước"
                : "Lưu brand, entity, asset policy và mặc định xuất bản"
            onClicked: root.submit(false)
        }
        AppButton {
            objectName: "channelProductionCaptureButton"
            Layout.fillWidth: true
            text: "Chụp lại cấu hình 5 feature"
            leadingIcon: "ui/refresh-cw"
            enabled: root.canSave
            Accessible.description: "Đọc cấu hình hiện tại của Master, Clone, Audio, Affiliate và TimeMachine rồi tạo revision mới"
            onClicked: root.submit(true)
        }
        Text {
            Layout.fillWidth: true
            text: "Assignment mới sẽ đóng băng đúng revision/hash này. Assignment cũ không bị thay đổi."
            color: Theme.textFaint
            font.pixelSize: Theme.fontMetadata
            wrapMode: Text.Wrap
            horizontalAlignment: Text.AlignHCenter
        }
    }
}
