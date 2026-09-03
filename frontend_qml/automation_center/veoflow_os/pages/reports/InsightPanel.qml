pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../.."
import "../../foundation" as Foundation

Panel {
    id: root
    objectName: "reportInsightPanel"
    clip: true

    property var scope: ({})
    property var insights: ({})
    property var coverage: ({})
    property bool planBusy: false
    property string resultMessage: ""
    readonly property var insightItems: root.insights.items || []
    readonly property var primaryInsight: root.resolvePrimaryInsight()
    readonly property var primaryActions: root.primaryInsight.actions || ({})
    readonly property var planAction: root.primaryActions.create_plan || ({})
    readonly property var coverageAction:
        root.primaryActions.coverage_details || ({})
    readonly property string availabilityReason: String(
        root.insights.reason || "INSIGHT_RECORDS_UNAVAILABLE")
    readonly property string displayReason: String(
        root.insights.reason_label || "Chưa có khuyến nghị đủ bằng chứng cho phạm vi này")
    readonly property var operatorGuidance: root.primaryInsight.operator_guidance || ({})
    readonly property bool available: root.insights.available === true
        && Boolean(root.primaryInsight.id)

    signal planRequested(var action)
    signal deepLinkRequested(var link)

    Accessible.name: "Phân tích AI. " + (root.available
        ? String(root.insightItems.length) + " insight có evidence"
        : "Không khả dụng: " + root.availabilityReason)
    Accessible.role: Accessible.Pane

    function resolvePrimaryInsight() {
        const wanted = String(root.insights.primary_insight_id || "")
        for (let index = 0; index < root.insightItems.length; index++) {
            const item = root.insightItems[index] || ({})
            if (!wanted || String(item.id || "") === wanted) return item
        }
        return ({})
    }

    function openPlanDialog() {
        if (!root.available || root.planAction.available !== true) return false
        planDialog.open()
        return true
    }

    function openCoverageDialog() {
        if (!root.available || root.coverageAction.available !== true) return false
        coverageDialog.open()
        return true
    }

    function finishPlanCommand(ok, message, data) {
        root.resultMessage = ok
            ? "Đã tạo kế hoạch nháp " + String(((data || {}).plan || {}).id || "—")
                + " · v" + String(((data || {}).plan || {}).version || "—")
                + " · " + String(((data || {}).plan || {}).state || "draft")
            : String(message || "Server từ chối tạo kế hoạch từ insight.")
        if (ok) planDialog.close()
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 13
        spacing: 9

        RowLayout {
            Layout.fillWidth: true
            Text {
                objectName: "reportInsightSectionTitle"
                Layout.fillWidth: true
                text: String(root.insights.section_title || "VIỆC NÊN LÀM TIẾP THEO")
                color: Theme.accent
                font.pixelSize: Theme.fontSection
                font.weight: Font.Bold
                font.letterSpacing: 0.8
            }
            Foundation.StatusPill {
                text: root.available ? "Có bằng chứng" : "Chưa có đề xuất"
                tone: root.available ? Theme.success : Theme.warning
            }
        }

        Text {
            Layout.fillWidth: true
            text: root.available
                ? "Khuyến nghị được khóa với snapshot và bằng chứng nguồn"
                : "Chỉ đề xuất khi dữ liệu vượt qua kiểm tra nguồn và phạm vi"
            color: Theme.textFaint
            font.pixelSize: Theme.fontMetadata
            elide: Text.ElideRight
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: Theme.radiusMedium
            color: Theme.elevated
            border.width: 1
            border.color: root.available ? Theme.borderSoft : Theme.warning

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 8

                Text {
                    objectName: "reportInsightTitle"
                    Layout.fillWidth: true
                    text: root.available
                        ? String(root.operatorGuidance.headline
                            || root.primaryInsight.title || "Cơ hội cần xem xét")
                        : "Chưa có việc cần ưu tiên từ dữ liệu"
                    color: root.available ? Theme.text : Theme.warning
                    font.pixelSize: Theme.fontBody
                    font.weight: Font.Bold
                    wrapMode: Text.Wrap
                }
                Text {
                    objectName: "reportInsightSummary"
                    Layout.fillWidth: true
                    text: root.available
                        ? String(root.operatorGuidance.impact
                            || root.primaryInsight.summary || "—")
                        : root.displayReason
                    color: Theme.textMuted
                    font.pixelSize: Theme.fontMetadata
                    wrapMode: Text.Wrap
                }
                Text {
                    visible: root.available
                    Layout.fillWidth: true
                    text: "Bước tiếp theo · " + String(root.operatorGuidance.next_step
                        || root.primaryInsight.recommendation || "")
                    color: Theme.accent
                    font.pixelSize: Theme.fontMetadata
                    font.weight: Font.DemiBold
                    wrapMode: Text.Wrap
                }

                Flow {
                    id: evidenceFlow
                    visible: root.available
                    Layout.fillWidth: true
                    Layout.minimumHeight: childrenRect.height
                    Layout.preferredHeight: childrenRect.height
                    spacing: 5
                    Repeater {
                        model: root.primaryInsight.evidence || []
                        delegate: AppButton {
                            id: evidenceButton
                            required property int index
                            required property var modelData
                            objectName: "reportInsightEvidence_" + String(evidenceButton.index)
                            width: Math.max(
                                0, (evidenceFlow.width - evidenceFlow.spacing) / 2)
                            height: 36
                            leftPadding: 8
                            rightPadding: 8
                            font.pixelSize: Theme.fontMetadata
                            iconSize: 14
                            text: String(evidenceButton.modelData.label
                                || "Bằng chứng " + String(evidenceButton.index + 1))
                            leadingIcon: "device/evidence"
                            subtle: true
                            Accessible.name: String(
                                evidenceButton.modelData.kind || "evidence")
                                + " " + text
                            enabled: evidenceButton.modelData.available === true
                                && Boolean((evidenceButton.modelData.deep_link || {}).route)
                            availabilityReason: enabled ? "" : String(
                                evidenceButton.modelData.reason_code
                                    || "Evidence không có route được server cấp"
                            )
                            onClicked: root.deepLinkRequested(
                                evidenceButton.modelData.deep_link || ({}))
                        }
                    }
                }

                Item { Layout.fillHeight: true }

                Rectangle {
                    id: coverageSummary
                    objectName: "reportInsightCoverageSummary"
                    readonly property bool labelTruncated: coverageSummaryLabel.truncated
                    readonly property bool detailTruncated: coverageSummaryDetail.truncated
                    Layout.fillWidth: true
                    Layout.preferredHeight: 52
                    radius: Theme.radiusSmall
                    color: Qt.rgba(Theme.warning.r, Theme.warning.g, Theme.warning.b, 0.1)
                    border.width: 1
                    border.color: Theme.warning
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 8
                        UiIcon {
                            name: "semantic/info"
                            tone: Theme.warning
                            iconSize: 16
                        }
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 1
                            Text {
                                id: coverageSummaryLabel
                                text: "Độ tin cậy dữ liệu"
                                color: Theme.warning
                                font.pixelSize: Theme.fontMetadata
                                font.weight: Font.Bold
                            }
                            Text {
                                id: coverageSummaryDetail
                                Layout.fillWidth: true
                                text: String(root.coverage.valid_facts ?? "—") + " / "
                                    + String(root.coverage.total_facts ?? "—")
                                    + " số liệu hợp lệ"
                                color: Theme.textMuted
                                font.pixelSize: Theme.fontMetadata
                                elide: Text.ElideRight
                            }
                        }
                    }
                }
            }
        }

        AppButton {
            objectName: "reportInsightCreatePlanButton"
            visible: root.available && Boolean(root.planAction.capability)
            Layout.fillWidth: true
            text: root.planBusy ? "Đang tạo kế hoạch…"
                : String(root.planAction.label || "Tạo kế hoạch từ insight")
            leadingIcon: String(root.planAction.icon_key || "")
            primary: true
            enabled: visible && root.planAction.available === true && !root.planBusy
                && String(root.planAction.capability || "")
                    === "reports.insight.plan.create"
            availabilityReason: enabled ? "" : (root.planBusy
                ? "Đang chờ kết quả tạo kế hoạch"
                : String(root.planAction.reason_code || "Insight plan không khả dụng"))
            onClicked: root.openPlanDialog()
        }
        AppButton {
            objectName: "reportInsightCoverageDetails"
            visible: root.available
            Layout.fillWidth: true
            text: String(root.coverageAction.label || "Chi tiết coverage")
            leadingIcon: String(root.coverageAction.icon_key || "")
            enabled: visible && root.coverageAction.available === true
                && String(root.coverageAction.kind || "") === "disclosure"
            availabilityReason: enabled ? "" : String(
                root.coverageAction.reason_code || "Coverage detail không khả dụng"
            )
            onClicked: root.openCoverageDialog()
        }
        Text {
            objectName: "reportInsightResultMessage"
            visible: root.resultMessage.length > 0
            Layout.fillWidth: true
            text: root.resultMessage
            color: Theme.textMuted
            font.pixelSize: Theme.fontMetadata
            wrapMode: Text.Wrap
        }
    }

    ReportDialog {
        id: coverageDialog
        objectName: "reportInsightCoverageDialog"
        parent: root
        x: Math.max(0, (root.width - width) / 2)
        y: Math.max(0, (root.height - height) / 2)
        width: Math.min(480, root.width - 24)
        height: Math.min(360, root.height - 24)
        title: "Evidence và coverage insight"
        contentItem: ColumnLayout {
            spacing: 8
            Text {
                Layout.fillWidth: true
                text: "Insight " + String(root.primaryInsight.id || "—")
                    + " · v" + String(root.primaryInsight.version || "—")
                color: Theme.text
                font.pixelSize: Theme.fontBody
                font.weight: Font.DemiBold
                wrapMode: Text.Wrap
            }
            Text {
                Layout.fillWidth: true
                text: "Snapshot hash: "
                    + String((root.primaryInsight.report_snapshot || {}).data_hash || "—")
                color: Theme.textMuted
                font.pixelSize: Theme.fontMetadata
                wrapMode: Text.WrapAnywhere
            }
            Text {
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: String((root.primaryInsight.evidence || []).length)
                    + " evidence refs · "
                    + String(root.coverage.valid_facts ?? "—") + " / "
                    + String(root.coverage.total_facts ?? "—") + " facts"
                color: Theme.textMuted
                font.pixelSize: Theme.fontMetadata
                wrapMode: Text.Wrap
            }
            RowLayout {
                Layout.fillWidth: true
                Item { Layout.fillWidth: true }
                AppButton {
                    objectName: "reportInsightCoverageCloseButton"
                    text: "Đóng"
                    onClicked: coverageDialog.close()
                }
            }
        }
    }

    ReportDialog {
        id: planDialog
        objectName: "reportInsightPlanDialog"
        parent: root
        x: Math.max(0, (root.width - width) / 2)
        y: Math.max(0, (root.height - height) / 2)
        width: Math.min(500, root.width - 24)
        height: Math.min(390, root.height - 24)
        title: "Tạo kế hoạch nháp từ insight"
        closePolicy: Popup.NoAutoClose
        contentItem: ColumnLayout {
            spacing: 10
            Text {
                Layout.fillWidth: true
                text: String(root.primaryInsight.title || "Insight")
                color: Theme.text
                font.pixelSize: Theme.fontBody
                font.weight: Font.DemiBold
                wrapMode: Text.Wrap
            }
            Text {
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: String(root.primaryInsight.recommendation || "—")
                    + "\n\nServer chỉ tạo Agent plan ở trạng thái draft; không dispatch, publish hoặc tạo external effect."
                color: Theme.textMuted
                font.pixelSize: Theme.fontMetadata
                wrapMode: Text.Wrap
            }
            Text {
                visible: root.resultMessage.length > 0
                Layout.fillWidth: true
                text: root.resultMessage
                color: Theme.warning
                font.pixelSize: Theme.fontMetadata
                wrapMode: Text.Wrap
            }
            RowLayout {
                Layout.fillWidth: true
                Item { Layout.fillWidth: true }
                AppButton {
                    objectName: "reportInsightPlanCancelButton"
                    text: "Hủy"
                    enabled: !root.planBusy
                    availabilityReason: enabled ? "" : "Đang chờ kết quả từ server"
                    onClicked: planDialog.close()
                }
                AppButton {
                    objectName: "reportInsightPlanSubmitButton"
                    text: root.planBusy ? "Đang tạo…" : "Tạo bản nháp"
                    primary: true
                    enabled: root.planAction.available === true && !root.planBusy
                    availabilityReason: enabled ? "" : (root.planBusy
                        ? "Đang chờ kết quả từ server"
                        : String(root.planAction.reason_code || "Action không khả dụng"))
                    onClicked: root.planRequested(root.planAction)
                }
            }
        }
    }
}
