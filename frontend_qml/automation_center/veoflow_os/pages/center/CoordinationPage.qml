pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../.."
import "CenterFormat.js" as Fmt

Item {
    id: root
    objectName: "centerCoordinationPage"

    required property var plane
    signal openWorkflowRequested(string workflow)
    signal navigateRequested(string route)

    property int selectedContentIndex: 2
    property string feedbackMessage: ""
    readonly property var project: root.plane.selectedCopilotProject || ({})
    readonly property var strategy: root.plane.copilotStrategy || ({})
    readonly property int revision: Number(root.plane.copilotRevision || 0)
    readonly property int approvedRevision: Number(root.project.approvedRevision || 0)
    readonly property bool revisionApproved: root.revision > 0
        && root.approvedRevision >= root.revision
    readonly property int contentCount: root.plane.copilotContentModel
        ? Number(root.plane.copilotContentModel.count || 0) : 0
    readonly property int sourceCount: root.plane.copilotSourceModel
        ? Number(root.plane.copilotSourceModel.count || 0) : 0
    readonly property bool allPrepared: root.everyContent("assignmentPrepared")
    readonly property bool allAssignable: root.everyContent("canAssign")
    readonly property var channelProfile: root.project.channelProfile || ({})
    readonly property var channelBrand: root.channelProfile.brand || ({})
    readonly property var channelEntities: root.channelProfile.entities || ({})
    readonly property string conversationState: String(root.project.conversationState || "unbound")
    readonly property bool conversationBlocked: root.conversationState === "needs_attention"
        || root.conversationState === "account_drift"

    Timer {
        id: saveFeedbackTimer
        interval: 1600
        onTriggered: root.feedbackMessage = ""
    }

    function everyContent(key) {
        if (!root.plane.copilotContentModel || root.contentCount <= 0)
            return false
        for (let index = 0; index < root.contentCount; ++index) {
            const row = root.plane.copilotContentModel.get(index) || ({})
            if (!Boolean(row[key]))
                return false
        }
        return true
    }

    function sourceCategory(row) {
        const workflow = String(row.workflow || "").toLowerCase()
        const inputMode = String(row.inputMode || "").toLowerCase()
        if (workflow === "affiliate" || inputMode === "prepared_product")
            return "product"
        if (workflow === "transcript" || inputMode.indexOf("audio") >= 0)
            return "audio"
        if (workflow === "clone" || inputMode.indexOf("video") >= 0)
            return "video"
        return "idea"
    }

    function sourceCategoryCount(category) {
        const model = root.plane.copilotSourceModel
        if (!model)
            return 0
        let count = 0
        for (let index = 0; index < Number(model.count || 0); ++index) {
            if (root.sourceCategory(model.get(index) || ({})) === category)
                count += 1
        }
        return count
    }

    function sourceIcon(row) {
        switch (root.sourceCategory(row)) {
        case "product": return "ui/shopping-bag"
        case "audio": return "ui/volume-2"
        case "video": return "semantic/video"
        default: return "semantic/lightbulb"
        }
    }

    function sourceTitle(sourceId) {
        const target = String(sourceId || "")
        const model = root.plane.copilotSourceModel
        if (!target || !model)
            return qsTr("Brief AI")
        for (let index = 0; index < Number(model.count || 0); ++index) {
            const row = model.get(index) || ({})
            if (String(row.sourceId || "") === target)
                return String(row.title || row.content || qsTr("Nguồn tham khảo"))
        }
        return target
    }

    function usedSourceCount() {
        const model = root.plane.copilotContentModel
        if (!model)
            return 0
        const seen = ({})
        let count = 0
        for (let index = 0; index < Number(model.count || 0); ++index) {
            const sourceId = String((model.get(index) || ({})).sourceId || "")
            if (sourceId && !seen[sourceId]) {
                seen[sourceId] = true
                count += 1
            }
        }
        return count
    }

    function resourceLabel(value) {
        const parts = String(value || "").split("-").filter(part => part.length > 0)
        if (parts.length === 0)
            return qsTr("Mặc định")
        const visible = parts.slice(Math.max(0, parts.length - 2)).join(" ")
        return visible.charAt(0).toUpperCase() + visible.slice(1)
    }

    function scheduledLabel(position) {
        const start = new Date(String(root.project.scheduleStartUtc || ""))
        if (isNaN(start.getTime()))
            return qsTr("Chưa xếp")
        const minutes = Math.max(1, Number(root.project.intervalMinutes || 1440))
        start.setTime(start.getTime() + Number(position || 0) * minutes * 60000)
        const labels = [qsTr("CN"), qsTr("Thứ 2"), qsTr("Thứ 3"), qsTr("Thứ 4"),
            qsTr("Thứ 5"), qsTr("Thứ 6"), qsTr("Thứ 7")]
        return labels[start.getUTCDay()] + ", " + String(start.getUTCDate())
            + "/" + String(start.getUTCMonth() + 1)
    }

    function workflowAdapterCount() {
        const configs = root.channelProfile.workflow_configs || ({})
        let count = 0
        for (const key in configs) {
            if (Boolean((configs[key] || ({})).enabled))
                count += 1
        }
        return count
    }

    function publishingProfileVerified() {
        const model = root.plane.profileModel
        const profileId = String(root.project.profileId || "")
        if (!model || !profileId)
            return false
        for (let index = 0; index < Number(model.count || 0); ++index) {
            const row = model.get(index) || ({})
            if (String(row.profileId || "") === profileId)
                return String(row.authState || "") === "verified"
        }
        return false
    }

    function acknowledgeSavedDraft() {
        root.feedbackMessage = qsTr("Đã lưu")
        saveFeedbackTimer.restart()
    }

    function selectProject(projectId) {
        root.plane.callTool("tool1.copilot.project.select", {
            "project_id": String(projectId || "")
        })
    }

    function sendMessage() {
        const message = composer.text.trim()
        const projectId = String(root.project.projectId || "")
        if (!message || !projectId || root.conversationBlocked || root.plane.actionBusy)
            return
        messageList.followTail = true
        root.plane.callTool("tool1.copilot.message.send", {
            "project_id": projectId,
            "message": message
        })
        composer.clear()
    }

    function conversationStateLabel() {
        switch (root.conversationState) {
        case "active": return qsTr("Đang nối đúng hội thoại")
        case "bound": return qsTr("Đã khóa account")
        case "needs_attention": return qsTr("Cần kết nối lại")
        case "account_drift": return qsTr("Account đã thay đổi")
        default: return qsTr("Chưa khóa account")
        }
    }

    function conversationStateTone() {
        switch (root.conversationState) {
        case "active": return "success"
        case "bound": return "info"
        case "needs_attention": return "warning"
        case "account_drift": return "danger"
        default: return "neutral"
        }
    }

    function conversationStateIcon() {
        switch (root.conversationState) {
        case "active": return "semantic/check-circle"
        case "needs_attention": return "semantic/alert-triangle"
        case "account_drift": return "semantic/alert-circle"
        default: return "ui/sparkles"
        }
    }

    function reconnectConversation() {
        const projectId = String(root.project.projectId || "")
        if (!projectId || root.plane.actionBusy)
            return
        root.plane.callTool("tool1.copilot.conversation.resume", {
            "project_id": projectId
        })
    }

    function requestNewConversation() {
        const projectId = String(root.project.projectId || "")
        if (!projectId || root.plane.actionBusy)
            return
        resetConversationDialog.projectId = projectId
        resetConversationDialog.open()
    }

    function approvePlan() {
        const projectId = String(root.project.projectId || "")
        if (!projectId || root.revision <= 0)
            return
        root.plane.callTool("tool1.copilot.plan.approve", {
            "project_id": projectId,
            "revision": root.revision
        })
    }

    function assignmentAction() {
        const projectId = String(root.project.projectId || "")
        if (!projectId || !root.revisionApproved)
            return
        if (!root.allPrepared) {
            root.plane.callTool("tool1.copilot.assignments.prepare", {
                "project_id": projectId
            })
            return
        }
        root.plane.callTool("tool1.copilot.items.assign_all", {
            "project_id": projectId
        })
    }

    component SectionLabel: Text {
        color: CenterTokens.text
        font.family: CenterTokens.fontFamily
        font.pixelSize: CenterTokens.sectionTitle
        font.weight: Font.DemiBold
    }

    component MetaText: Text {
        color: CenterTokens.muted
        font.family: CenterTokens.fontFamily
        font.pixelSize: CenterTokens.metadata + 1
        elide: Text.ElideRight
    }

    component SourceMetric: Rectangle {
        id: metric
        required property string label
        required property string iconName
        required property int value
        Layout.fillWidth: true
        implicitHeight: 48
        radius: CenterTokens.radiusSmall
        color: CenterTokens.panelSoft
        border.width: 1
        border.color: CenterTokens.border
        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 10
            anchors.rightMargin: 10
            spacing: 8
            UiIcon {
                name: metric.iconName
                tone: CenterTokens.primary
                iconSize: 16
                Layout.preferredWidth: 16
                Layout.preferredHeight: 16
            }
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0
                Text {
                    text: metric.label
                    color: CenterTokens.muted
                    font.family: CenterTokens.fontFamily
                    font.pixelSize: CenterTokens.metadata
                }
                Text {
                    text: String(metric.value)
                    color: CenterTokens.text
                    font.family: CenterTokens.fontFamily
                    font.pixelSize: CenterTokens.body
                    font.weight: Font.DemiBold
                }
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.leftMargin: CenterTokens.pageGutter
        anchors.rightMargin: CenterTokens.pageGutter
        anchors.topMargin: 14
        anchors.bottomMargin: 12
        spacing: 10

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 58
            spacing: 20

            ColumnLayout {
                spacing: 3
                Text {
                    text: qsTr("Trợ lý điều phối")
                    color: CenterTokens.text
                    font.family: CenterTokens.fontFamily
                    font.pixelSize: CenterTokens.pageTitle
                    font.weight: Font.Bold
                }
                Text {
                    text: qsTr("Trao đổi với AI, duyệt kế hoạch và giao việc cho các tab sản xuất đã có.")
                    color: CenterTokens.muted
                    font.family: CenterTokens.fontFamily
                    font.pixelSize: CenterTokens.body
                }
            }

            Item { Layout.fillWidth: true }

            Button {
                id: projectButton
                objectName: "coordinationProjectPicker"
                Layout.preferredWidth: 255
                Layout.preferredHeight: CenterTokens.controlHeight
                text: String(root.project.title || qsTr("Chọn kế hoạch kênh"))
                onClicked: projectMenu.open()
                contentItem: RowLayout {
                    spacing: 8
                    PlatformIcon {
                        platform: String(root.project.platform || "generic")
                        iconSize: 16
                        Layout.preferredWidth: 16
                        Layout.preferredHeight: 16
                    }
                    Text {
                        Layout.fillWidth: true
                        text: projectButton.text
                        color: CenterTokens.text
                        font.family: CenterTokens.fontFamily
                        font.pixelSize: CenterTokens.body
                        font.weight: Font.DemiBold
                        elide: Text.ElideRight
                    }
                    UiIcon {
                        name: "ui/chevron-down"
                        tone: CenterTokens.muted
                        iconSize: 14
                        Layout.preferredWidth: 14
                        Layout.preferredHeight: 14
                    }
                }
                background: Rectangle {
                    radius: CenterTokens.radiusSmall
                    color: CenterTokens.panel
                    border.width: 1
                    border.color: projectButton.hovered ? CenterTokens.primary : CenterTokens.border
                }
                Menu {
                    id: projectMenu
                    y: projectButton.height + 4
                    width: projectButton.width
                    Instantiator {
                        model: root.plane.copilotProjectModel
                        delegate: MenuItem {
                            required property var modelData
                            text: String(modelData.title || modelData.projectId || qsTr("Kế hoạch"))
                            onTriggered: root.selectProject(modelData.projectId)
                        }
                        onObjectAdded: function(index, object) { projectMenu.insertItem(index, object) }
                        onObjectRemoved: function(index, object) { projectMenu.removeItem(object) }
                    }
                }
            }

            CenterStatusBadge {
                Layout.preferredWidth: 128
                text: qsTr("Bản nháp v") + String(Math.max(1, root.revision))
                status: root.revisionApproved ? "success" : "info"
                iconName: root.revisionApproved ? "semantic/check-circle" : "ui/file-text"
            }
            AppButton {
                objectName: "coordinationSaveDraftButton"
                Layout.preferredWidth: 112
                text: root.feedbackMessage.length > 0 ? root.feedbackMessage : qsTr("Lưu nháp")
                leadingIcon: root.feedbackMessage.length > 0 ? "semantic/check-circle" : "ui/save"
                onClicked: root.acknowledgeSavedDraft()
            }
            AppButton {
                objectName: "coordinationApproveButton"
                Layout.preferredWidth: 154
                text: root.revisionApproved ? qsTr("Đã duyệt") : qsTr("Duyệt kế hoạch")
                leadingIcon: root.revisionApproved ? "semantic/check-circle" : "ui/check"
                primary: !root.revisionApproved
                enabled: !root.revisionApproved && root.revision > 0 && !root.plane.actionBusy
                onClicked: root.approvePlan()
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: CenterTokens.gap

            CenterPanel {
                id: conversationPanel
                objectName: "coordinationConversationPanel"
                Layout.preferredWidth: Math.max(350, root.width * 0.29)
                Layout.fillHeight: true

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: CenterTokens.panelPadding
                    spacing: 7

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        SectionLabel { text: qsTr("Trao đổi với account LLM") }
                        Item { Layout.fillWidth: true }
                        AppButton {
                            objectName: "coordinationNewConversationButton"
                            Layout.preferredHeight: 27
                            text: qsTr("Chat mới")
                            leadingIcon: "ui/plus"
                            iconSize: 13
                            subtle: true
                            enabled: String(root.project.projectId || "").length > 0
                                && !root.plane.actionBusy
                            onClicked: root.requestNewConversation()
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 55
                        radius: CenterTokens.radiusSmall
                        color: CenterTokens.panelSoft
                        border.width: 1
                        border.color: root.conversationBlocked
                            ? (root.conversationState === "account_drift"
                                ? CenterTokens.danger : CenterTokens.warning)
                            : CenterTokens.border

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            spacing: 8
                            UiIcon {
                                name: "ui/sparkles"
                                tone: CenterTokens.primary
                                iconSize: 17
                                Layout.preferredWidth: 17
                                Layout.preferredHeight: 17
                            }
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 1
                                Text {
                                    Layout.fillWidth: true
                                    text: String(root.project.llmAccountEmail
                                        || root.project.llmAccountName
                                        || qsTr("Sẽ dùng account LLM đang chọn trong Tool 1"))
                                    color: CenterTokens.text
                                    font.family: CenterTokens.fontFamily
                                    font.pixelSize: CenterTokens.metadata + 1
                                    font.weight: Font.DemiBold
                                    elide: Text.ElideRight
                                }
                                MetaText {
                                    Layout.fillWidth: true
                                    text: String(root.project.llmModel || qsTr("Gemini account chat"))
                                        + (Number(root.project.conversationTurnCount || 0) > 0
                                            ? qsTr(" · %1 lượt").arg(Number(root.project.conversationTurnCount || 0))
                                            : "")
                                }
                            }
                            CenterStatusBadge {
                                text: root.conversationStateLabel()
                                status: root.conversationStateTone()
                                iconName: root.conversationStateIcon()
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        visible: root.conversationBlocked
                        spacing: 8
                        Text {
                            Layout.fillWidth: true
                            text: String(root.project.conversationErrorMessage
                                || (root.conversationState === "account_drift"
                                    ? qsTr("Project đang khóa với account khác. Hãy tạo chat mới để đổi account.")
                                    : qsTr("Phiên chat cần được xác minh lại trên browser.")))
                            color: root.conversationState === "account_drift"
                                ? CenterTokens.danger : CenterTokens.warning
                            font.family: CenterTokens.fontFamily
                            font.pixelSize: CenterTokens.metadata + 1
                            wrapMode: Text.Wrap
                        }
                        AppButton {
                            objectName: "coordinationReconnectConversationButton"
                            visible: root.conversationState === "needs_attention"
                            Layout.preferredHeight: 27
                            text: qsTr("Kết nối lại")
                            leadingIcon: "ui/refresh-cw"
                            iconSize: 13
                            subtle: true
                            enabled: !root.plane.actionBusy
                            onClicked: root.reconnectConversation()
                        }
                    }

                    ListView {
                        id: messageList
                        objectName: "coordinationMessageList"
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.minimumHeight: 118
                        model: root.plane.copilotMessageModel
                        spacing: 8
                        clip: true
                        reuseItems: true
                        boundsBehavior: Flickable.StopAtBounds
                        property bool followTail: true
                        onCountChanged: {
                            followTail = true
                            Qt.callLater(function() { messageList.positionViewAtEnd() })
                        }
                        onContentHeightChanged: {
                            if (followTail)
                                Qt.callLater(function() { messageList.positionViewAtEnd() })
                        }
                        onMovementStarted: followTail = false
                        onMovementEnded: followTail = atYEnd
                        delegate: Item {
                            id: messageDelegate
                            required property var modelData
                            width: ListView.view.width
                            height: messageBubble.implicitHeight
                            readonly property string messageRole: String(modelData.role || "")
                            readonly property bool userMessage: messageRole === "user"
                            readonly property bool systemMessage: messageRole === "system"
                            readonly property string messageStatus: String(modelData.status || "completed")

                            Rectangle {
                                id: messageBubble
                                implicitHeight: messageContent.implicitHeight + 20
                                width: messageDelegate.width * (messageDelegate.systemMessage
                                    ? 0.94 : (messageDelegate.userMessage ? 0.85 : 0.88))
                                x: messageDelegate.systemMessage
                                    ? Math.max(0, (messageDelegate.width - width) / 2)
                                    : (messageDelegate.userMessage
                                        ? Math.max(0, messageDelegate.width - width - 30) : 0)
                                radius: 7
                                color: messageDelegate.systemMessage ? "transparent"
                                    : (messageDelegate.userMessage ? CenterTokens.primarySoft : CenterTokens.panelSoft)
                                border.width: 1
                                border.color: messageDelegate.systemMessage ? CenterTokens.border
                                    : (messageDelegate.userMessage
                                    ? Qt.rgba(CenterTokens.primary.r, CenterTokens.primary.g, CenterTokens.primary.b, 0.30)
                                    : (messageDelegate.messageStatus === "failed"
                                        ? CenterTokens.danger : CenterTokens.border))

                                ColumnLayout {
                                    id: messageContent
                                    anchors.fill: parent
                                    anchors.margins: 10
                                    spacing: 6

                                    RowLayout {
                                        Layout.fillWidth: true
                                        spacing: 6
                                        UiIcon {
                                            visible: !messageDelegate.userMessage
                                            name: messageDelegate.systemMessage ? "semantic/info" : "ui/sparkles"
                                            tone: messageDelegate.systemMessage ? CenterTokens.muted : CenterTokens.primary
                                            iconSize: 13
                                            Layout.preferredWidth: visible ? 13 : 0
                                            Layout.preferredHeight: 13
                                        }
                                        Text {
                                            text: messageDelegate.userMessage ? qsTr("Bạn")
                                                : (messageDelegate.systemMessage ? qsTr("Nhật ký hệ thống")
                                                    : String(root.project.llmAccountName || qsTr("Account LLM")))
                                            color: CenterTokens.text
                                            font.family: CenterTokens.fontFamily
                                            font.pixelSize: CenterTokens.metadata + 1
                                            font.weight: Font.DemiBold
                                        }
                                        MetaText {
                                            text: Fmt.timeLabel(messageDelegate.modelData.createdAt).slice(-5)
                                        }
                                        Item { Layout.fillWidth: true }
                                        MetaText {
                                            visible: !messageDelegate.userMessage
                                                && !messageDelegate.systemMessage
                                                && messageDelegate.messageStatus !== "completed"
                                            text: messageDelegate.messageStatus === "failed"
                                                ? qsTr("Lượt chat lỗi") : qsTr("Đang trả lời…")
                                            color: messageDelegate.messageStatus === "failed"
                                                ? CenterTokens.danger : CenterTokens.primary
                                        }
                                    }
                                    Text {
                                        id: messageText
                                        Layout.fillWidth: true
                                        text: String(messageDelegate.modelData.content
                                            || (messageDelegate.messageStatus === "pending"
                                                || messageDelegate.messageStatus === "streaming"
                                                ? qsTr("Đang chờ phản hồi từ account LLM…") : ""))
                                        color: CenterTokens.text
                                        font.family: CenterTokens.fontFamily
                                        font.pixelSize: CenterTokens.body
                                        wrapMode: Text.Wrap
                                    }
                                    CenterStatusBadge {
                                        visible: !messageDelegate.userMessage
                                            && !messageDelegate.systemMessage
                                            && String(messageDelegate.modelData.actionState || "none") !== "none"
                                        text: String(messageDelegate.modelData.actionState || "") === "validated"
                                            ? qsTr("Đề xuất đã kiểm định · chờ duyệt")
                                            : qsTr("Đề xuất hành động đã bị chặn")
                                        status: String(messageDelegate.modelData.actionState || "") === "validated"
                                            ? "success" : "danger"
                                        iconName: String(messageDelegate.modelData.actionState || "") === "validated"
                                            ? "semantic/check-circle" : "semantic/alert-circle"
                                    }
                                    Text {
                                        visible: (messageDelegate.messageStatus === "failed"
                                                || String(messageDelegate.modelData.actionState || "none") === "invalid")
                                            && String(messageDelegate.modelData.errorMessage || "").length > 0
                                        Layout.fillWidth: true
                                        text: String(messageDelegate.modelData.errorMessage || "")
                                        color: CenterTokens.danger
                                        font.family: CenterTokens.fontFamily
                                        font.pixelSize: CenterTokens.metadata + 1
                                        wrapMode: Text.Wrap
                                    }
                                }
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            visible: messageList.count === 0
                            text: qsTr("Bắt đầu bằng mục tiêu kênh, đối tượng và tần suất đăng.")
                            width: parent.width - 36
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.Wrap
                            color: CenterTokens.faint
                            font.family: CenterTokens.fontFamily
                            font.pixelSize: CenterTokens.body
                        }
                    }

                    Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: CenterTokens.border }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 5
                        MetaText {
                            text: qsTr("Nguồn tham khảo")
                            color: CenterTokens.text
                            font.weight: Font.DemiBold
                        }
                        MetaText {
                            Layout.fillWidth: true
                            text: qsTr("(%1 ý tưởng, %2 link video, %3 audio, %4 sản phẩm)")
                                .arg(root.sourceCategoryCount("idea"))
                                .arg(root.sourceCategoryCount("video"))
                                .arg(root.sourceCategoryCount("audio"))
                                .arg(root.sourceCategoryCount("product"))
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 7
                        SourceMetric {
                            label: qsTr("Ý tưởng")
                            iconName: "semantic/lightbulb"
                            value: root.sourceCategoryCount("idea")
                        }
                        SourceMetric {
                            label: qsTr("Video link")
                            iconName: "ui/link"
                            value: root.sourceCategoryCount("video")
                        }
                        SourceMetric {
                            label: qsTr("Audio")
                            iconName: "ui/volume-2"
                            value: root.sourceCategoryCount("audio")
                        }
                        SourceMetric {
                            label: qsTr("Sản phẩm")
                            iconName: "ui/shopping-bag"
                            value: root.sourceCategoryCount("product")
                        }
                    }

                    ListView {
                        id: sourceList
                        objectName: "coordinationSourceList"
                        Layout.fillWidth: true
                        Layout.preferredHeight: Math.min(100, contentHeight)
                        model: root.plane.copilotSourceModel
                        spacing: 3
                        clip: true
                        reuseItems: true
                        delegate: RowLayout {
                            id: sourceRow
                            required property var modelData
                            width: ListView.view.width
                            height: 25
                            spacing: 7
                            UiIcon {
                                name: root.sourceIcon(sourceRow.modelData)
                                tone: CenterTokens.primary
                                iconSize: 13
                                Layout.preferredWidth: 13
                                Layout.preferredHeight: 13
                            }
                            Text {
                                Layout.fillWidth: true
                                text: String(sourceRow.modelData.inputModeLabel || qsTr("Nguồn")) + ": "
                                    + String(sourceRow.modelData.title || sourceRow.modelData.content || qsTr("Nguồn tham khảo"))
                                color: CenterTokens.muted
                                font.family: CenterTokens.fontFamily
                                font.pixelSize: CenterTokens.metadata + 1
                                elide: Text.ElideRight
                            }
                            MetaText {
                                text: Fmt.timeLabel(sourceRow.modelData.createdAt).slice(-5)
                            }
                        }
                    }

                    Text {
                        Layout.fillWidth: true
                        visible: root.sourceCount > 0
                        text: qsTr("Xem tất cả nguồn →")
                        color: CenterTokens.primary
                        font.family: CenterTokens.fontFamily
                        font.pixelSize: CenterTokens.metadata + 1
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 40
                        radius: CenterTokens.radiusSmall
                        color: CenterTokens.panelSoft
                        border.width: 1
                        border.color: composer.activeFocus ? CenterTokens.primary : CenterTokens.border
                        TextArea {
                            id: composer
                            objectName: "coordinationChatComposer"
                            anchors.fill: parent
                            anchors.margins: 6
                            placeholderText: root.conversationBlocked
                                ? qsTr("Xử lý trạng thái account trước khi gửi lượt chat mới…")
                                : qsTr("Yêu cầu LLM sửa kế hoạch, viết kịch bản hoặc phân tích hướng nội dung…")
                            placeholderTextColor: CenterTokens.faint
                            color: CenterTokens.text
                            font.family: CenterTokens.fontFamily
                            font.pixelSize: CenterTokens.body
                            wrapMode: TextEdit.Wrap
                            selectByMouse: true
                            enabled: !root.conversationBlocked
                                && String(root.project.projectId || "").length > 0
                            background: Item {}
                            Keys.onPressed: function(event) {
                                if ((event.modifiers & Qt.ControlModifier) && event.key === Qt.Key_Return) {
                                    root.sendMessage()
                                    event.accepted = true
                                }
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        AppButton {
                            Layout.preferredHeight: 32
                            text: qsTr("Đính kèm nguồn")
                            leadingIcon: "ui/paperclip"
                            subtle: true
                            onClicked: sourceDialog.open()
                        }
                        Item { Layout.fillWidth: true }
                        AppButton {
                            objectName: "coordinationSendButton"
                            Layout.preferredHeight: 32
                            text: qsTr("Gửi")
                            leadingIcon: "ui/send"
                            primary: true
                            enabled: composer.text.trim().length > 0
                                && String(root.project.projectId || "").length > 0
                                && !root.conversationBlocked
                                && !root.plane.actionBusy
                            onClicked: root.sendMessage()
                        }
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: CenterTokens.gap

                CenterPanel {
                    id: planPanel
                    objectName: "coordinationPlanPanel"
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.minimumHeight: 330

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: CenterTokens.panelPadding
                        spacing: 8

                        RowLayout {
                            Layout.fillWidth: true
                            SectionLabel {
                                Layout.fillWidth: true
                                text: qsTr("Kế hoạch nội dung · Bản nháp v") + String(Math.max(1, root.revision))
                            }
                            MetaText {
                                text: String(root.contentCount) + qsTr(" nội dung")
                            }
                        }

                        Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: CenterTokens.border }

                        RowLayout {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 24
                            Layout.leftMargin: 9
                            Layout.rightMargin: 8
                            spacing: 8
                            MetaText {
                                Layout.minimumWidth: 22
                                Layout.preferredWidth: 22
                                Layout.maximumWidth: 22
                                text: "#"
                            }
                            MetaText { Layout.fillWidth: true; text: qsTr("Nội dung") }
                            MetaText { Layout.minimumWidth: 120; Layout.preferredWidth: 120; Layout.maximumWidth: 120; text: qsTr("Mục tiêu") }
                            MetaText { Layout.minimumWidth: 150; Layout.preferredWidth: 150; Layout.maximumWidth: 150; text: qsTr("Workflow") }
                            MetaText { Layout.minimumWidth: 180; Layout.preferredWidth: 180; Layout.maximumWidth: 180; text: qsTr("Kênh mục tiêu") }
                            MetaText { Layout.minimumWidth: 130; Layout.preferredWidth: 130; Layout.maximumWidth: 130; text: qsTr("Ngày đăng") }
                            MetaText { Layout.minimumWidth: 120; Layout.preferredWidth: 120; Layout.maximumWidth: 120; text: qsTr("Trạng thái") }
                            Item { Layout.minimumWidth: 26; Layout.preferredWidth: 26; Layout.maximumWidth: 26 }
                        }

                        ListView {
                            id: contentPlanList
                            objectName: "coordinationContentPlanList"
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            model: root.plane.copilotContentModel
                            spacing: 3
                            clip: true
                            reuseItems: true
                            boundsBehavior: Flickable.StopAtBounds
                            delegate: Rectangle {
                                id: contentRow
                                required property int index
                                required property var modelData
                                width: ListView.view.width
                                height: root.selectedContentIndex === index ? 118 : 46
                                radius: 5
                                color: root.selectedContentIndex === index
                                    ? CenterTokens.primarySoft : CenterTokens.panel
                                border.width: 1
                                border.color: root.selectedContentIndex === index
                                    ? Qt.rgba(CenterTokens.primary.r, CenterTokens.primary.g, CenterTokens.primary.b, 0.38)
                                    : CenterTokens.border

                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 9
                                    anchors.rightMargin: 8
                                    anchors.topMargin: 5
                                    anchors.bottomMargin: 5
                                    spacing: 4
                                    RowLayout {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 34
                                        spacing: 8
                                        Text {
                                            Layout.minimumWidth: 22
                                            Layout.preferredWidth: 22
                                            Layout.maximumWidth: 22
                                            text: String(contentRow.index + 1)
                                            color: CenterTokens.muted
                                            font.family: CenterTokens.fontFamily
                                            font.pixelSize: CenterTokens.body
                                        }
                                        ColumnLayout {
                                            Layout.fillWidth: true
                                            spacing: 1
                                            Text {
                                                Layout.fillWidth: true
                                                text: String(contentRow.modelData.title || qsTr("Nội dung chưa đặt tên"))
                                                color: CenterTokens.text
                                                font.family: CenterTokens.fontFamily
                                                font.pixelSize: CenterTokens.body
                                                font.weight: Font.DemiBold
                                                elide: Text.ElideRight
                                            }
                                            MetaText {
                                                Layout.fillWidth: true
                                                text: String(contentRow.modelData.angle || contentRow.modelData.rationale || "")
                                                visible: text.length > 0
                                            }
                                        }
                                        MetaText {
                                            Layout.minimumWidth: 120
                                            Layout.preferredWidth: 120
                                            Layout.maximumWidth: 120
                                            text: String(contentRow.modelData.rationale
                                                || contentRow.modelData.angle || qsTr("Theo chiến lược kênh"))
                                        }
                                        CenterStatusBadge {
                                            Layout.minimumWidth: 150
                                            Layout.preferredWidth: 150
                                            Layout.maximumWidth: 150
                                            text: Fmt.workflowLabel(contentRow.modelData.workflow)
                                            status: Fmt.workflowTone(contentRow.modelData.workflow)
                                            iconName: ""
                                        }
                                        RowLayout {
                                            Layout.minimumWidth: 180
                                            Layout.preferredWidth: 180
                                            Layout.maximumWidth: 180
                                            spacing: 6
                                            PlatformIcon {
                                                platform: String(root.project.platform || "generic")
                                                iconSize: 14
                                                Layout.preferredWidth: 14
                                                Layout.preferredHeight: 14
                                            }
                                            Text {
                                                Layout.fillWidth: true
                                                text: String(root.project.channelId || root.project.title || qsTr("Chưa gán kênh"))
                                                color: CenterTokens.muted
                                                font.family: CenterTokens.fontFamily
                                                font.pixelSize: CenterTokens.metadata + 1
                                                elide: Text.ElideRight
                                            }
                                        }
                                        RowLayout {
                                            Layout.minimumWidth: 130
                                            Layout.preferredWidth: 130
                                            Layout.maximumWidth: 130
                                            spacing: 6
                                            UiIcon {
                                                name: "ui/calendar"
                                                tone: CenterTokens.muted
                                                iconSize: 13
                                                Layout.preferredWidth: 13
                                                Layout.preferredHeight: 13
                                            }
                                            MetaText {
                                                Layout.fillWidth: true
                                                text: root.scheduledLabel(contentRow.modelData.position)
                                            }
                                        }
                                        CenterStatusBadge {
                                            Layout.minimumWidth: 120
                                            Layout.preferredWidth: 120
                                            Layout.maximumWidth: 120
                                            text: String(contentRow.modelData.statusLabel
                                                || Fmt.statusLabel(contentRow.modelData.status))
                                            status: contentRow.modelData.canAssign ? "success"
                                                : Fmt.statusKind(contentRow.modelData.status)
                                            iconName: contentRow.modelData.canAssign
                                                ? "semantic/check-circle" : ""
                                        }
                                        AppButton {
                                            Layout.minimumWidth: 26
                                            Layout.preferredWidth: 26
                                            Layout.maximumWidth: 26
                                            Layout.preferredHeight: 28
                                            text: ""
                                            leadingIcon: "ui/more-horizontal"
                                            subtle: true
                                            leftPadding: 5
                                            rightPadding: 5
                                            onClicked: root.selectedContentIndex = contentRow.index
                                        }
                                    }

                                    RowLayout {
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        visible: root.selectedContentIndex === contentRow.index
                                        spacing: 12

                                        ColumnLayout {
                                            Layout.preferredWidth: 230
                                            Layout.fillHeight: true
                                            spacing: 4
                                            MetaText {
                                                text: qsTr("Nguồn sử dụng")
                                                color: CenterTokens.text
                                                font.weight: Font.DemiBold
                                            }
                                            Rectangle {
                                                Layout.fillWidth: true
                                                Layout.preferredHeight: 38
                                                radius: CenterTokens.radiusSmall
                                                color: CenterTokens.panel
                                                border.width: 1
                                                border.color: CenterTokens.border
                                                RowLayout {
                                                    anchors.fill: parent
                                                    anchors.leftMargin: 9
                                                    anchors.rightMargin: 7
                                                    spacing: 7
                                                    UiIcon {
                                                        name: root.sourceIcon(contentRow.modelData)
                                                        tone: CenterTokens.primary
                                                        iconSize: 15
                                                        Layout.preferredWidth: 15
                                                        Layout.preferredHeight: 15
                                                    }
                                                    MetaText {
                                                        Layout.fillWidth: true
                                                        text: root.sourceTitle(contentRow.modelData.sourceId)
                                                        color: CenterTokens.text
                                                    }
                                                }
                                            }
                                        }

                                        Rectangle {
                                            Layout.preferredWidth: 1
                                            Layout.fillHeight: true
                                            color: CenterTokens.border
                                        }

                                        ColumnLayout {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            spacing: 4
                                            MetaText {
                                                text: qsTr("Prompt chính · tóm tắt")
                                                color: CenterTokens.text
                                                font.weight: Font.DemiBold
                                            }
                                            MetaText {
                                                Layout.fillWidth: true
                                                text: String(contentRow.modelData.content || contentRow.modelData.angle || "—")
                                                wrapMode: Text.Wrap
                                                maximumLineCount: 2
                                                elide: Text.ElideRight
                                            }
                                        }

                                        Rectangle {
                                            Layout.preferredWidth: 1
                                            Layout.fillHeight: true
                                            color: CenterTokens.border
                                        }

                                        ColumnLayout {
                                            Layout.preferredWidth: 330
                                            Layout.fillHeight: true
                                            spacing: 4
                                            MetaText {
                                                text: qsTr("Cấu hình nhanh")
                                                color: CenterTokens.text
                                                font.weight: Font.DemiBold
                                            }
                                            RowLayout {
                                                Layout.fillWidth: true
                                                spacing: 6
                                                CenterStatusBadge {
                                                    Layout.preferredWidth: 102
                                                    text: qsTr("Giọng: ") + root.resourceLabel(root.channelEntities.voice_id)
                                                    status: "info"
                                                }
                                                CenterStatusBadge {
                                                    Layout.preferredWidth: 102
                                                    text: qsTr("Nhân vật: ") + root.resourceLabel((root.channelEntities.character_ids || [])[0])
                                                    status: "neutral"
                                                }
                                                CenterStatusBadge {
                                                    Layout.preferredWidth: 102
                                                    text: qsTr("Style: ") + root.resourceLabel(root.channelEntities.style_id)
                                                    status: "neutral"
                                                }
                                                Item { Layout.fillWidth: true }
                                            }
                                            AppButton {
                                                Layout.preferredHeight: 28
                                                text: qsTr("Mở trong ") + Fmt.workflowLabel(contentRow.modelData.workflow)
                                                leadingIcon: "ui/external-link"
                                                subtle: true
                                                enabled: ["master", "clone", "transcript", "affiliate", "timemachine"]
                                                    .indexOf(String(contentRow.modelData.workflow || "")) >= 0
                                                onClicked: root.openWorkflowRequested(
                                                    String(contentRow.modelData.workflow || ""))
                                            }
                                        }
                                    }
                                }

                                TapHandler { onTapped: root.selectedContentIndex = contentRow.index }
                            }

                            Text {
                                anchors.centerIn: parent
                                visible: contentPlanList.count === 0
                                text: qsTr("Chưa có kế hoạch. Hãy mô tả mục tiêu kênh ở khung AI.")
                                color: CenterTokens.faint
                                font.family: CenterTokens.fontFamily
                                font.pixelSize: CenterTokens.body
                            }
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.minimumHeight: 164
                    Layout.preferredHeight: 164
                    Layout.maximumHeight: 164
                    spacing: CenterTokens.gap

                    CenterPanel {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: CenterTokens.panelPadding
                            spacing: 7
                            SectionLabel { text: qsTr("Ràng buộc kênh") }
                            GridLayout {
                                Layout.fillWidth: true
                                columns: 4
                                columnSpacing: 14
                                rowSpacing: 6
                                MetaText { text: qsTr("Ngôn ngữ") }
                                MetaText { text: String(root.strategy.language || root.channelBrand.language || qsTr("Chưa cấu hình")); color: CenterTokens.text }
                                MetaText { text: qsTr("Phong cách") }
                                MetaText { text: String(root.channelEntities.style_id || root.strategy.voice || qsTr("Chưa cấu hình")); color: CenterTokens.text }
                                MetaText { text: qsTr("Giọng đọc") }
                                MetaText { text: String(root.channelEntities.voice_id || qsTr("Chưa cấu hình")); color: CenterTokens.text }
                                MetaText { text: qsTr("Tần suất") }
                                MetaText { text: String(root.strategy.cadence || root.project.intervalMinutes || qsTr("Theo kế hoạch")); color: CenterTokens.text }
                                MetaText { text: qsTr("Nhân vật") }
                                MetaText { text: String((root.channelEntities.character_ids || [])[0] || qsTr("Tắt")); color: CenterTokens.text }
                                MetaText { text: qsTr("Kênh mục tiêu") }
                                MetaText { text: String(root.project.channelId || root.project.title || qsTr("Chưa gán")); color: CenterTokens.text }
                            }
                            Item { Layout.fillHeight: true }
                            AppButton {
                                Layout.fillWidth: true
                                text: qsTr("Chỉnh cấu hình kênh")
                                leadingIcon: "ui/settings"
                                subtle: true
                                onClicked: root.navigateRequested("channels")
                            }
                        }
                    }

                    CenterPanel {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: CenterTokens.panelPadding
                            spacing: 7
                            SectionLabel { text: qsTr("Kiểm tra trước khi giao") }
                            GridLayout {
                                Layout.fillWidth: true
                                columns: 2
                                columnSpacing: 12
                                rowSpacing: 5
                                CenterStatusBadge {
                                    text: String(root.workflowAdapterCount()) + qsTr(" workflow có adapter")
                                    status: root.workflowAdapterCount() > 0 ? "success" : "warning"
                                    iconName: root.workflowAdapterCount() > 0 ? "semantic/check-circle" : "semantic/alert-triangle"
                                }
                                CenterStatusBadge {
                                    text: root.publishingProfileVerified() ? qsTr("Browser verified") : qsTr("Browser cần xác minh")
                                    status: root.publishingProfileVerified() ? "success" : "warning"
                                    iconName: root.publishingProfileVerified() ? "semantic/check-circle" : "semantic/alert-triangle"
                                }
                                CenterStatusBadge {
                                    text: String(root.usedSourceCount()) + qsTr(" nguồn hợp lệ")
                                    status: root.usedSourceCount() > 0 ? "success" : "warning"
                                    iconName: root.usedSourceCount() > 0 ? "semantic/check-circle" : "semantic/alert-triangle"
                                }
                                CenterStatusBadge {
                                    text: String(root.plane.attentionModel ? root.plane.attentionModel.count : 0) + qsTr(" cảnh báo")
                                    status: root.plane.attentionModel && root.plane.attentionModel.count > 0 ? "warning" : "success"
                                    iconName: root.plane.attentionModel && root.plane.attentionModel.count > 0
                                        ? "semantic/alert-triangle" : "semantic/check-circle"
                                }
                                CenterStatusBadge {
                                    Layout.columnSpan: 2
                                    text: root.sourceCategoryCount("product") > 0
                                        ? qsTr("Affiliate đã có sản phẩm") : qsTr("Affiliate cần chuẩn bị sản phẩm")
                                    status: root.sourceCategoryCount("product") > 0 ? "success" : "warning"
                                    iconName: root.sourceCategoryCount("product") > 0
                                        ? "semantic/check-circle" : "semantic/alert-triangle"
                                }
                            }
                            Item { Layout.fillHeight: true }
                            AppButton {
                                objectName: "coordinationAssignmentButton"
                                Layout.fillWidth: true
                                text: root.allPrepared
                                    ? qsTr("Tạo ") + String(root.contentCount) + qsTr(" Assignment")
                                    : qsTr("Chuẩn bị ") + String(root.contentCount) + qsTr(" Assignment")
                                leadingIcon: root.allPrepared ? "ui/send" : "ui/file-text"
                                primary: true
                                enabled: root.revisionApproved && root.contentCount > 0
                                    && (root.allPrepared || root.allAssignable)
                                    && !root.plane.actionBusy
                                onClicked: root.assignmentAction()
                            }
                        }
                    }
                }
            }
        }
    }

    Dialog {
        id: resetConversationDialog
        objectName: "coordinationResetConversationDialog"
        property string projectId: ""
        modal: true
        anchors.centerIn: Overlay.overlay
        width: Math.min(460, root.width - 80)
        title: qsTr("Bắt đầu cuộc trò chuyện mới?")
        standardButtons: Dialog.Cancel | Dialog.Ok
        onAccepted: {
            if (projectId.length > 0) {
                root.plane.callTool("tool1.copilot.conversation.reset", {
                    "project_id": projectId
                })
            }
            projectId = ""
        }
        onRejected: projectId = ""
        contentItem: Text {
            width: parent ? parent.width : implicitWidth
            text: qsTr("Tool 1 sẽ xác minh account LLM đang chọn và tạo conversation id mới. Lịch sử audit và kế hoạch hiện tại vẫn được giữ; ngữ cảnh chat cũ không được gửi lại cho model.")
            color: CenterTokens.text
            font.family: CenterTokens.fontFamily
            font.pixelSize: CenterTokens.body
            wrapMode: Text.Wrap
        }
    }

    Dialog {
        id: sourceDialog
        objectName: "coordinationSourceImportDialog"
        modal: true
        anchors.centerIn: Overlay.overlay
        width: Math.min(620, root.width - 80)
        title: qsTr("Nạp nguồn hàng loạt")
        standardButtons: Dialog.Cancel | Dialog.Ok
        onAccepted: {
            const lines = sourceInput.text.split(/\r?\n/).map(value => value.trim())
                .filter(value => value.length > 0)
            const rows = []
            for (let index = 0; index < lines.length; ++index) {
                rows.push({
                    "workflow": String(sourceWorkflow.currentValue || "clone"),
                    "input_mode": String(sourceMode.currentValue || "video_url"),
                    "title": qsTr("Nguồn ") + String(index + 1),
                    "content": lines[index]
                })
            }
            if (rows.length > 0) {
                root.plane.callTool("tool1.copilot.sources.import", {
                    "project_id": String(root.project.projectId || ""),
                    "sources": rows
                })
            }
            sourceInput.clear()
        }
        contentItem: ColumnLayout {
            spacing: 10
            RowLayout {
                Layout.fillWidth: true
                AppComboBox {
                    id: sourceWorkflow
                    objectName: "coordinationSourceWorkflow"
                    Layout.fillWidth: true
                    model: [
                        {"text": qsTr("Clone video"), "value": "clone"},
                        {"text": qsTr("Audio-to-Video"), "value": "transcript"},
                        {"text": qsTr("Master Prompt"), "value": "master"},
                        {"text": qsTr("Affiliate prepared product"), "value": "affiliate"}
                    ]
                    textRole: "text"
                    valueRole: "value"
                }
                AppComboBox {
                    id: sourceMode
                    objectName: "coordinationSourceMode"
                    Layout.fillWidth: true
                    model: [
                        {"text": qsTr("URL video"), "value": "video_url"},
                        {"text": qsTr("Đường dẫn file"), "value": "local_file"},
                        {"text": qsTr("Văn bản / kịch bản"), "value": "text"},
                        {"text": qsTr("ID sản phẩm đã chuẩn bị"), "value": "prepared_product"}
                    ]
                    textRole: "text"
                    valueRole: "value"
                }
            }
            TextArea {
                id: sourceInput
                Layout.fillWidth: true
                Layout.preferredHeight: 180
                placeholderText: qsTr("Mỗi dòng là một URL, đường dẫn, kịch bản hoặc ID sản phẩm…")
                wrapMode: TextEdit.Wrap
                selectByMouse: true
            }
            Text {
                Layout.fillWidth: true
                text: qsTr("Nguồn chỉ được đưa vào kế hoạch sau khi backend kiểm tra đúng input mode.")
                color: CenterTokens.muted
                font.family: CenterTokens.fontFamily
                font.pixelSize: CenterTokens.metadata + 1
                wrapMode: Text.Wrap
            }
        }
    }
}
