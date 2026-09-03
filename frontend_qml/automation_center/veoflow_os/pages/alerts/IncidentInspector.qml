pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../.."
import "../../foundation" as Foundation

Panel {
    id: root
    objectName: "incidentInspector"
    clip: true

    property var inspector: ({})
    property var incident: ({})
    property var occurrences: []
    property var resolution: null
    property bool detailAvailable: false
    property bool canWrite: false
    property bool canResolve: false
    property var controlPlaneBridge: null
    property int commandRevision: 0
    property int selectedTab: 0

    signal actionRequested(var action)

    readonly property string incidentId: String((root.incident || {}).id || "")
    readonly property var actions: (root.inspector || {}).actions || ({})
    readonly property var tabs: (root.inspector || {}).tabs || []
    readonly property var relatedItems: (root.inspector || {}).related || []
    readonly property var causeData: (root.inspector || {}).cause || null
    readonly property var recommendedItems: (root.inspector || {}).recommended || []
    readonly property var evidenceItems: (root.inspector || {}).evidence || []
    readonly property var operatorGuidance: (root.incident || {}).operator_guidance || ({})
    readonly property string sourceDisplay:
        String((root.incident.source_descriptor || {}).label || "Không khả dụng")
    readonly property var commandStore: root.controlPlaneBridge
        ? root.controlPlaneBridge.commandStore : null
    readonly property string firstSeenDisplay:
        root.dateTimeLabel(root.incident.first_seen_at)
    readonly property string lastSeenDisplay:
        root.dateTimeLabel(root.incident.last_seen_at)

    Accessible.name: root.incidentId.length > 0
        ? "Chi tiết sự cố " + root.incidentId
        : "Chi tiết sự cố, chưa chọn bản ghi"
    Accessible.role: Accessible.Pane

    function exact(value) {
        return value === undefined || value === null || String(value).length === 0
            ? "Không khả dụng" : String(value)
    }

    function actionFor(key) {
        return root.actions[String(key || "")] || ({})
    }

    function tabFor(key) {
        const identity = String(key || "")
        for (let index = 0; index < root.tabs.length; index++) {
            const candidate = root.tabs[index] || ({})
            if (String(candidate.key || "") === identity) return candidate
        }
        return ({})
    }

    function toneFor(key) {
        const value = String(key || "")
        if (value === "danger") return Theme.danger
        if (value === "warning") return Theme.warning
        if (value === "success") return Theme.success
        if (value === "info") return Theme.info
        if (value === "accent") return Theme.accent
        return Theme.textFaint
    }

    function commandBusy(action) {
        const revision = root.commandRevision
        const descriptor = action || ({})
        const capability = String(descriptor.capability || "")
        return root.commandStore && capability.length > 0 && root.incidentId.length > 0
            ? root.commandStore.isBusy(capability, "incident", root.incidentId)
            : false
    }

    function primaryGuidanceAction() {
        const key = String(root.operatorGuidance.primary_action_key || "")
        return key.length > 0 ? root.actionFor(key) : ({})
    }

    function actionPermissionAllowed(key) {
        const name = String(key || "")
        if (name === "resolve") return root.canResolve
        if (name === "claim" || name === "severity_change") return root.canWrite
        return true
    }

    function actionReason(action) {
        const descriptor = action || ({})
        if (root.commandBusy(descriptor)) return "Lệnh đang được server xử lý"
        return String(descriptor.reason_code || "")
    }

    function dispatchAction(action) {
        const descriptor = action || ({})
        if (String(descriptor.kind || "") === "clipboard") {
            clipboardBuffer.text = String((descriptor.input || {}).text || "")
            clipboardBuffer.selectAll()
            clipboardBuffer.copy()
            return true
        }
        root.actionRequested(descriptor)
        return true
    }

    function dateTimeLabel(value) {
        const date = new Date(String(value || ""))
        if (isNaN(date.getTime())) return "Không khả dụng"
        return Qt.formatDateTime(date, "dd/MM/yyyy HH:mm:ss")
    }

    function slaLabel(sla) {
        const policy = sla || ({})
        if (!policy.deadline_at) return "SLA không khả dụng"
        if (policy.breached)
            return "Quá hạn " + Math.abs(Number(policy.remaining_seconds || 0)) + " giây"
        if (policy.remaining_seconds === undefined || policy.remaining_seconds === null)
            return "Hạn " + String(policy.deadline_at)
        return "Còn " + String(policy.remaining_seconds) + " giây"
    }

    TextEdit {
        id: clipboardBuffer
        visible: false
        Accessible.ignored: true
    }

    ColumnLayout {
        objectName: "incidentInspectorContent"
        anchors.fill: parent
        anchors.margins: 14
        spacing: 9
        visible: root.detailAvailable

        RowLayout {
            Layout.fillWidth: true
            spacing: 8
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2
                Text {
                    Layout.fillWidth: true
                    text: root.detailAvailable
                        ? String(root.incident.title || "Sự cố không có tiêu đề")
                        : "Chi tiết chưa khả dụng"
                    color: Theme.text
                    font.pixelSize: Theme.fontSection
                    font.weight: Font.Bold
                    elide: Text.ElideRight
                }
                Text {
                    Layout.fillWidth: true
                    text: root.detailAvailable
                        ? String((root.incident.source_descriptor || {}).label || "Không khả dụng")
                            + " · " + root.exact(root.incident.code)
                        : String(root.inspector.reason_code || "INCIDENT_NOT_SELECTED")
                    color: root.detailAvailable ? Theme.textFaint : Theme.warning
                    font.pixelSize: Theme.fontMetadata
                    elide: Text.ElideRight
                }
            }
            Foundation.IconButton {
                readonly property var descriptor: root.actionFor("copy_id")
                objectName: "incidentCopyId"
                iconName: String(descriptor.icon_key || "")
                text: iconName.length > 0 ? "" : "ID"
                accessibleName: String(descriptor.label || "Sao chép incident ID")
                activeFocusOnTab: true
                enabled: Boolean(descriptor.available) && !root.commandBusy(descriptor)
                Accessible.description: root.actionReason(descriptor)
                onClicked: root.dispatchAction(descriptor)
            }
            Foundation.IconButton {
                readonly property var descriptor: root.actionFor("close")
                objectName: "incidentInspectorClose"
                iconName: String(descriptor.icon_key || "")
                text: ""
                accessibleName: String(descriptor.label || "Đóng chi tiết sự cố")
                activeFocusOnTab: true
                enabled: Boolean(descriptor.available)
                Accessible.description: String(descriptor.reason_code || "")
                onClicked: root.dispatchAction(descriptor)
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 6
            Foundation.StatusPill {
                readonly property var descriptor: root.incident.severity_descriptor || ({})
                text: String(descriptor.label || "Không khả dụng")
                tone: root.toneFor(descriptor.tone_key)
            }
            Foundation.StatusPill {
                readonly property var descriptor: root.incident.status_descriptor || ({})
                text: String(descriptor.label || "Không khả dụng")
                tone: root.toneFor(descriptor.tone_key)
            }
            Foundation.StatusPill {
                text: root.slaLabel(root.incident.sla)
                tone: root.toneFor((root.incident.sla_descriptor || {}).tone_key)
                showDot: false
            }
            Item { Layout.fillWidth: true }
            Text {
                id: inspectorAuditId
                objectName: "incidentInspectorAuditId"
                visible: false
                text: root.incidentId.length > 0 ? "#" + root.incidentId : "—"
                color: Theme.textFaint
                font.pixelSize: Theme.fontMetadata
                elide: Text.ElideMiddle
            }
        }

        GridLayout {
            Layout.fillWidth: true
            columns: 3
            columnSpacing: 12
            rowSpacing: 5
            DetailValue { label: "Đối tượng"; value: String((root.incident.entity_display || {}).label || "Không khả dụng") }
            DetailValue { label: "Owner"; value: String((root.incident.owner_display || {}).label || "Chưa nhận") }
            DetailValue { label: "Lần đầu"; value: root.firstSeenDisplay }
            DetailValue { label: "Gần nhất"; value: root.lastSeenDisplay }
            DetailValue { label: "Số lần"; value: root.exact(root.incident.occurrence_count) }
            DetailValue { label: "Episode"; value: root.exact(root.incident.episode) }
        }

        Text {
            Layout.fillWidth: true
            text: root.exact(root.incident.summary)
            color: root.detailAvailable ? Theme.textMuted : Theme.warning
            font.pixelSize: Theme.fontMetadata
            wrapMode: Text.Wrap
            maximumLineCount: 2
            elide: Text.ElideRight
        }

        Rectangle {
            id: operatorDecision
            objectName: "incidentOperatorDecision"
            property string headline: String(root.operatorGuidance.headline
                || "Cần đối soát bằng chứng")
            property string impact: String(root.operatorGuidance.impact
                || root.incident.summary || "Chưa xác định ảnh hưởng")
            property string nextStep: String(root.operatorGuidance.next_step
                || "Mở dòng thời gian và bằng chứng trước khi xử lý tiếp.")
            readonly property color decisionTone: root.toneFor(
                root.operatorGuidance.tone_key)
            Layout.fillWidth: true
            Layout.preferredHeight: 92
            radius: Theme.radiusMedium
            color: Qt.rgba(decisionTone.r, decisionTone.g, decisionTone.b, 0.10)
            border.width: 1
            border.color: Qt.rgba(decisionTone.r, decisionTone.g, decisionTone.b, 0.48)
            Accessible.name: headline + ". Ảnh hưởng: " + impact
                + ". Việc tiếp theo: " + nextStep
            Accessible.role: Accessible.StaticText
            RowLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 9
                UiIcon {
                    name: String(root.operatorGuidance.icon_key || "semantic/alert-circle")
                    tone: operatorDecision.decisionTone
                    iconSize: 20
                    Layout.preferredWidth: 22
                }
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    Text {
                        text: "VIỆC CẦN LÀM"
                        color: operatorDecision.decisionTone
                        font.pixelSize: Theme.fontMetadata
                        font.weight: Font.Bold
                    }
                    Text {
                        Layout.fillWidth: true
                        text: operatorDecision.headline + " · " + operatorDecision.impact
                        color: Theme.text
                        font.pixelSize: Theme.fontBody
                        font.weight: Font.Bold
                        elide: Text.ElideRight
                    }
                    Text {
                        Layout.fillWidth: true
                        text: operatorDecision.nextStep
                        color: Theme.textMuted
                        font.pixelSize: Theme.fontMetadata
                        elide: Text.ElideRight
                    }
                }
                AppButton {
                    id: operatorDecisionPrimary
                    objectName: "incidentOperatorDecisionPrimary"
                    readonly property string actionKey: String(
                        root.operatorGuidance.primary_action_key || "")
                    readonly property var descriptor: root.primaryGuidanceAction()
                    visible: Boolean(descriptor.available)
                    enabled: visible && root.actionPermissionAllowed(actionKey)
                        && !root.commandBusy(descriptor)
                    primary: true
                    text: root.commandBusy(descriptor)
                        ? "Đang xử lý…" : String(descriptor.label || "Thực hiện")
                    leadingIcon: String(descriptor.icon_key || "")
                    availabilityReason: root.actionPermissionAllowed(actionKey)
                        ? root.actionReason(descriptor)
                        : "Workspace permission hiện tại không cho phép hành động"
                    onClicked: root.dispatchAction(descriptor)
                }
            }
        }

        GridLayout {
            Layout.fillWidth: true
            columns: 3
            columnSpacing: 6
            rowSpacing: 6
            InspectorAction {
                keyName: "claim"
                objectName: "incidentClaimButton"
                visible: String(root.operatorGuidance.primary_action_key || "") !== "claim"
            }
            InspectorAction { keyName: "severity_change"; objectName: "incidentSeverityButton" }
            InspectorAction {
                keyName: "safe_retry"
                objectName: "incidentSafeRetryButton"
                visible: Boolean(descriptor.available)
            }
            InspectorAction { keyName: "open_affected"; objectName: "incidentOpenAffectedButton" }
            InspectorAction { keyName: "resolve"; objectName: "incidentResolveButton"; primary: true }
            InspectorAction {
                keyName: "request_approval"
                objectName: "incidentRequestApprovalButton"
                visible: Boolean(descriptor.available)
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 4
            InspectorTab { keyName: "timeline"; objectName: "incidentTabTimeline"; tabIndex: 0 }
            InspectorTab { keyName: "related"; objectName: "incidentTabRelated"; tabIndex: 1 }
            InspectorTab { keyName: "cause"; objectName: "incidentTabCause"; tabIndex: 2 }
            InspectorTab { keyName: "recommended"; objectName: "incidentTabRecommended"; tabIndex: 3 }
            InspectorTab { keyName: "evidence"; objectName: "incidentTabEvidence"; tabIndex: 4 }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            ScrollView {
                id: timelineScroll
                anchors.fill: parent
                visible: root.selectedTab === 0
                clip: true
                contentWidth: availableWidth
                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                ColumnLayout {
                    width: timelineScroll.availableWidth
                    spacing: 7
                    Repeater {
                        model: root.occurrences
                        delegate: Rectangle {
                            id: occurrenceRow
                            required property int index
                            required property var modelData
                            readonly property var severity:
                                occurrenceRow.modelData.severity_descriptor || ({})
                            readonly property var source:
                                occurrenceRow.modelData.source_descriptor || ({})
                            objectName: "incidentOccurrence_" + String(
                                occurrenceRow.modelData.id || occurrenceRow.index)
                            Layout.fillWidth: true
                            Layout.preferredHeight: 64
                            radius: Theme.radiusSmall
                            color: Theme.elevated
                            border.width: 1
                            border.color: Theme.borderSoft
                            Accessible.role: Accessible.ListItem
                            Accessible.name: String(occurrenceRow.modelData.summary || "Occurrence")
                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 8
                                spacing: 2
                                RowLayout {
                                    Layout.fillWidth: true
                                    Text { Layout.fillWidth: true; text: String(occurrenceRow.modelData.summary || "Không có mô tả"); color: Theme.text; font.pixelSize: Theme.fontMetadata; font.weight: Font.DemiBold; elide: Text.ElideRight }
                                    Foundation.StatusPill { text: String(occurrenceRow.severity.label || "—"); tone: root.toneFor(occurrenceRow.severity.tone_key) }
                                    Text { text: root.dateTimeLabel(occurrenceRow.modelData.occurred_at); color: Theme.textFaint; font.pixelSize: Theme.fontMetadata }
                                }
                                Text { Layout.fillWidth: true; text: String(occurrenceRow.source.label || "Không khả dụng") + " · " + root.exact(occurrenceRow.modelData.code) + " · " + root.exact(occurrenceRow.modelData.correlation_id); color: Theme.textMuted; font.pixelSize: Theme.fontMetadata; elide: Text.ElideMiddle }
                            }
                        }
                    }
                    EmptyText { visible: root.occurrences.length === 0; text: "Không có occurrence được server projection." }
                }
            }

            ScrollView {
                id: relatedScroll
                anchors.fill: parent
                visible: root.selectedTab === 1
                clip: true
                contentWidth: availableWidth
                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                ColumnLayout {
                    width: relatedScroll.availableWidth
                    spacing: 7
                    Repeater {
                        model: root.relatedItems
                        delegate: AppButton {
                            id: relatedLink
                            required property int index
                            required property var modelData
                            readonly property var refData: relatedLink.modelData.ref || ({})
                            objectName: "incidentRelatedLink_" + String(refData.type || "unknown")
                                + "_" + String(refData.id || relatedLink.index)
                            Layout.fillWidth: true
                            text: String(relatedLink.modelData.label || "Đối tượng liên quan")
                            leadingIcon: String(relatedLink.modelData.icon_key || "")
                            activeFocusOnTab: true
                            enabled: Boolean(relatedLink.modelData.available)
                                && Boolean((relatedLink.modelData.deep_link || {}).route)
                            availabilityReason: enabled ? "" : String(
                                relatedLink.modelData.reason_code
                                    || "INCIDENT_ENTITY_REF_ROUTE_UNAVAILABLE"
                            )
                            onClicked: root.dispatchAction({
                                "available": true,
                                "kind": "navigation",
                                "deep_link": relatedLink.modelData.deep_link
                            })
                        }
                    }
                    EmptyText { visible: root.relatedItems.length === 0; text: "Không có đối tượng liên quan được server cấp quyền." }
                }
            }

            ScrollView {
                id: causeScroll
                anchors.fill: parent
                visible: root.selectedTab === 2
                clip: true
                contentWidth: availableWidth
                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                Rectangle {
                    objectName: "incidentCauseCard"
                    width: causeScroll.availableWidth
                    height: Math.max(140, causeColumn.implicitHeight + 24)
                    radius: Theme.radiusMedium
                    color: Theme.elevated
                    border.width: 1
                    border.color: Theme.borderSoft
                    Accessible.role: Accessible.StaticText
                    Accessible.name: root.causeData
                        ? String(root.causeData.summary || "Nguyên nhân sự cố")
                        : "Nguyên nhân không khả dụng"
                    ColumnLayout {
                        id: causeColumn
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 7
                        RowLayout {
                            Layout.fillWidth: true
                            UiIcon { name: String(((root.causeData || {}).source || {}).icon_key || ""); tone: Theme.textMuted; iconSize: 18 }
                            Text { Layout.fillWidth: true; text: String(((root.causeData || {}).source || {}).label || "Nguồn không khả dụng"); color: Theme.text; font.pixelSize: Theme.fontBody; font.weight: Font.Bold }
                            Text { text: root.exact((root.causeData || {}).code); color: Theme.warning; font.pixelSize: Theme.fontMetadata }
                        }
                        Text { Layout.fillWidth: true; text: root.exact((root.causeData || {}).summary); color: Theme.textMuted; font.pixelSize: Theme.fontMetadata; wrapMode: Text.Wrap }
                        Text {
                            objectName: "incidentCauseRuleText"
                            Layout.fillWidth: true
                            text: "Rule: " + root.exact((((root.causeData || {}).rule || {}).key))
                            color: Theme.textFaint
                            font.pixelSize: Theme.fontMetadata
                            elide: Text.ElideMiddle
                        }
                    }
                }
            }

            ScrollView {
                id: recommendedScroll
                anchors.fill: parent
                visible: root.selectedTab === 3
                clip: true
                contentWidth: availableWidth
                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                ColumnLayout {
                    width: recommendedScroll.availableWidth
                    spacing: 7
                    Repeater {
                        model: root.recommendedItems
                        delegate: AppButton {
                            id: recommendedButton
                            required property int index
                            required property var modelData
                            objectName: "incidentRecommended_" + String(
                                recommendedButton.modelData.capability || recommendedButton.index)
                            Layout.fillWidth: true
                            text: String(recommendedButton.modelData.label || "Hành động đề xuất")
                            leadingIcon: String(recommendedButton.modelData.icon_key || "")
                            activeFocusOnTab: true
                            enabled: Boolean(recommendedButton.modelData.available)
                                && (String(recommendedButton.modelData.kind || "")
                                    !== "navigation"
                                    || Boolean((recommendedButton.modelData.deep_link || {}).route))
                            availabilityReason: enabled ? "" : String(
                                recommendedButton.modelData.reason_code
                                    || "INCIDENT_ACTION_ROUTE_UNAVAILABLE"
                            )
                            onClicked: root.dispatchAction(recommendedButton.modelData)
                        }
                    }
                    EmptyText { visible: root.recommendedItems.length === 0; text: "Không có hành động khuyến nghị khả dụng." }
                }
            }

            ScrollView {
                id: evidenceScroll
                anchors.fill: parent
                visible: root.selectedTab === 4
                clip: true
                contentWidth: availableWidth
                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                ColumnLayout {
                    width: evidenceScroll.availableWidth
                    spacing: 7
                    Repeater {
                        model: root.evidenceItems
                        delegate: AppButton {
                            id: evidenceButton
                            required property int index
                            required property var modelData
                            readonly property var refData: evidenceButton.modelData.ref || ({})
                            objectName: "incidentEvidence_" + String(refData.type || "unknown")
                                + "_" + String(refData.id || evidenceButton.index)
                            Layout.fillWidth: true
                            text: String(evidenceButton.modelData.label || "Evidence")
                            leadingIcon: String(evidenceButton.modelData.icon_key || "")
                            activeFocusOnTab: true
                            visible: Boolean(evidenceButton.modelData.available)
                                && Boolean((evidenceButton.modelData.deep_link || {}).route)
                            enabled: visible
                            availabilityReason: String(evidenceButton.modelData.reason_code || "")
                            onClicked: root.dispatchAction({
                                "available": true,
                                "kind": "navigation",
                                "deep_link": evidenceButton.modelData.deep_link
                            })
                        }
                    }
                    EmptyText { visible: root.evidenceItems.length === 0; text: "Không có evidence được server cấp quyền." }
                }
            }
        }
    }

    ColumnLayout {
        objectName: "incidentInspectorEmptyState"
        anchors.centerIn: parent
        width: Math.min(340, Math.max(180, parent.width - 48))
        spacing: 8
        visible: !root.detailAvailable
        Accessible.role: Accessible.StaticText
        Accessible.name: "Chưa chọn sự cố"

        UiIcon {
            Layout.alignment: Qt.AlignHCenter
            name: "semantic/info"
            tone: Theme.textFaint
            iconSize: 28
        }
        Text {
            Layout.fillWidth: true
            text: "Chưa chọn sự cố"
            color: Theme.text
            font.pixelSize: Theme.fontSection
            font.weight: Font.DemiBold
            horizontalAlignment: Text.AlignHCenter
        }
        Text {
            Layout.fillWidth: true
            text: "Chọn một hàng trong hộp thư để xem chi tiết và hành động khả dụng."
            color: Theme.textFaint
            font.pixelSize: Theme.fontMetadata
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
        }
    }

    component DetailValue: ColumnLayout {
        id: detail
        required property string label
        required property string value
        Layout.fillWidth: true
        spacing: 1
        Text { text: detail.label; color: Theme.textFaint; font.pixelSize: Theme.fontMetadata }
        Text { Layout.fillWidth: true; text: detail.value; color: detail.value === "Không khả dụng" ? Theme.warning : Theme.textMuted; font.pixelSize: Theme.fontMetadata; font.weight: Font.DemiBold; elide: Text.ElideMiddle }
    }

    component InspectorAction: AppButton {
        id: actionButton
        required property string keyName
        readonly property var descriptor: root.actionFor(actionButton.keyName)
        readonly property bool routeReady:
            String(actionButton.descriptor.kind || "") !== "navigation"
            || Boolean((actionButton.descriptor.deep_link || {}).route)
        readonly property bool permissionAllowed:
            root.actionPermissionAllowed(actionButton.keyName)
        Layout.fillWidth: true
        Layout.minimumWidth: 0
        text: root.commandBusy(descriptor)
            ? "Đang xử lý…" : String(descriptor.label || "Không khả dụng")
        leadingIcon: String(descriptor.icon_key || "")
        activeFocusOnTab: true
        enabled: root.detailAvailable && actionButton.permissionAllowed
            && Boolean(descriptor.available)
            && actionButton.routeReady
            && !root.commandBusy(descriptor)
        availabilityReason: !actionButton.permissionAllowed
            ? "Workspace permission hiện tại không cho phép hành động"
            : !actionButton.routeReady ? "INCIDENT_ACTION_ROUTE_UNAVAILABLE"
            : root.actionReason(descriptor)
        onClicked: root.dispatchAction(descriptor)
    }

    component InspectorTab: AppButton {
        id: tab
        required property string keyName
        required property int tabIndex
        readonly property var descriptor: root.tabFor(tab.keyName)
        Layout.fillWidth: true
        Layout.preferredWidth: 1
        Layout.minimumWidth: 0
        implicitHeight: 32
        leftPadding: 4
        rightPadding: 4
        font.pixelSize: Theme.fontMetadata
        text: String(descriptor.label || tab.keyName)
        leadingIcon: String(descriptor.icon_key || "")
        primary: root.selectedTab === tab.tabIndex
        visible: Boolean(descriptor.available)
        enabled: visible
        activeFocusOnTab: true
        availabilityReason: String(descriptor.reason_code || "")
        onClicked: root.selectedTab = tab.tabIndex
    }

    component EmptyText: Text {
        Layout.fillWidth: true
        color: Theme.warning
        font.pixelSize: Theme.fontMetadata
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.Wrap
    }
}
