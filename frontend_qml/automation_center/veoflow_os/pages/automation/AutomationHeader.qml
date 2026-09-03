pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../.."

Rectangle {
    id: root
    objectName: "automationHeader"
    property var headerData: ({})
    property var createAction: ({})
    property var batchAction: ({})
    property var sections: ({})
    property string activeTab: "workflow"
    property string bannerMessage: ""
    property bool showFreshness: false
    property string freshnessText: "Một phần nguồn dữ liệu chưa sẵn sàng"
    signal tabRequested(string tabKey)
    signal createRequested()
    signal batchRequested()

    radius: 0
    color: Theme.panel
    border.width: 1
    border.color: Theme.borderSoft
    Accessible.name: "Trung tâm điều khiển tự động hóa"
    Accessible.role: Accessible.Pane

    function metricValue(name) {
        const value = root.headerData[name]
        return value === undefined || value === null ? "—" : String(value)
    }

    readonly property var successRate: root.headerData.success_rate || ({})
    readonly property var allTabs: [
        {"key": "workflow", "label": "Workflow"},
        {"key": "batch", "label": "Batch Browser"},
        {"key": "runs", "label": "Lượt chạy"},
        {"key": "policies", "label": "Chính sách"},
        {"key": "templates", "label": "Mẫu có sẵn"}
    ]
    readonly property var tabs: {
        const result = []
        for (let index = 0; index < root.allTabs.length; ++index) {
            const item = root.allTabs[index]
            const sectionKey = item.key === "batch" ? "batch_browser" : item.key
            const descriptor = root.sections[sectionKey] || ({})
            if (Object.keys(descriptor).length > 0
                    && String(descriptor.state || "available") !== "unavailable")
                result.push(item)
        }
        return result
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.leftMargin: 16
        anchors.rightMargin: 16
        anchors.topMargin: 8
        anchors.bottomMargin: 8
        spacing: 6

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 82
            spacing: 12

            ColumnLayout {
                Layout.minimumWidth: 390
                Layout.preferredWidth: 420
                Layout.maximumWidth: 480
                Layout.fillHeight: true
                spacing: 1

                Text {
                    text: "AUTOMATION CONTROL"
                    color: Theme.accent
                    font.pixelSize: 11
                    font.weight: Font.DemiBold
                    font.letterSpacing: 0.8
                }
                Text {
                    objectName: "automationHeaderPurposeTitle"
                    text: "Tự động hóa công việc"
                    color: Theme.text
                    font.pixelSize: Theme.fontPageTitle
                    font.weight: Font.Bold
                }
                Text {
                    objectName: "automationHeaderPurposeText"
                    Layout.fillWidth: true
                    text: "Khi có sự kiện, VeoFlow chạy chuỗi bước đã kiểm duyệt và dừng ở bước cần duyệt."
                    color: Theme.textMuted
                    font.pixelSize: 11
                    elide: Text.ElideRight
                    Accessible.name: text
                }
                Rectangle {
                    id: freshnessBadge
                    objectName: "automationHeaderFreshnessBadge"
                    visible: root.showFreshness || root.bannerMessage.length > 0
                    Layout.preferredHeight: visible ? 22 : 0
                    Layout.preferredWidth: visible
                        ? Math.min(420, freshnessContent.implicitWidth + 18) : 0
                    Layout.maximumWidth: 420
                    radius: 11
                    color: Qt.rgba(Theme.warning.r, Theme.warning.g, Theme.warning.b, 0.12)
                    border.width: 1
                    border.color: Qt.rgba(Theme.warning.r, Theme.warning.g, Theme.warning.b, 0.55)
                    Accessible.name: freshnessLabel.text
                    Accessible.role: Accessible.StaticText

                    Row {
                        id: freshnessContent
                        anchors.centerIn: parent
                        spacing: 6
                        UiIcon {
                            name: "semantic/alert-triangle"
                            tone: Theme.warning
                            iconSize: 13
                        }
                        Text {
                            id: freshnessLabel
                            width: Math.min(360, implicitWidth)
                            text: root.bannerMessage.length > 0
                                ? root.bannerMessage : root.freshnessText
                            color: Theme.warning
                            font.pixelSize: 11
                            elide: Text.ElideRight
                        }
                    }
                }
            }

            Item { Layout.fillWidth: true }

            RowLayout {
                Layout.preferredHeight: 68
                spacing: 8
                AutomationMetricCell {
                    metricKey: "enabled"
                    Layout.minimumWidth: 168
                    Layout.preferredWidth: 168
                    Layout.maximumWidth: 168
                    Layout.minimumHeight: 68
                    Layout.preferredHeight: 68
                    Layout.maximumHeight: 68
                    value: root.metricValue("enabled")
                    label: "đang bật"
                    delta: root.metricValue("workflow_total") + " workflow"
                    iconName: "ui/play"
                    tone: Theme.success
                }
                AutomationMetricCell {
                    metricKey: "running"
                    Layout.minimumWidth: 168
                    Layout.preferredWidth: 168
                    Layout.maximumWidth: 168
                    Layout.minimumHeight: 68
                    Layout.preferredHeight: 68
                    Layout.maximumHeight: 68
                    value: root.metricValue("running")
                    label: "đang chạy"
                    delta: "Theo snapshot"
                    iconName: "semantic/workflow"
                    tone: Theme.accent
                }
                AutomationMetricCell {
                    id: successMetric
                    objectName: "automationSuccessMetric"
                    metricKey: "success"
                    Layout.minimumWidth: 168
                    Layout.preferredWidth: 168
                    Layout.maximumWidth: 168
                    Layout.minimumHeight: 68
                    Layout.preferredHeight: 68
                    Layout.maximumHeight: 68
                    value: root.successRate.available
                        ? String(root.successRate.value) + "%" : "—"
                    label: "thành công"
                    delta: root.successRate.available
                        ? String(root.successRate.sample_size || 0) + " mẫu / "
                            + String(root.successRate.window_hours || 0) + "h"
                        : "Chưa đủ mẫu / "
                            + String(root.successRate.window_hours || 0) + "h"
                    iconName: "semantic/check-circle"
                    tone: root.successRate.available ? Theme.success : Theme.textFaint
                }
                AutomationMetricCell {
                    metricKey: "attention"
                    Layout.minimumWidth: 168
                    Layout.preferredWidth: 168
                    Layout.maximumWidth: 168
                    Layout.minimumHeight: 68
                    Layout.preferredHeight: 68
                    Layout.maximumHeight: 68
                    value: root.metricValue("attention")
                    label: "cần xử lý"
                    delta: "Theo policy"
                    iconName: "semantic/alert-triangle"
                    tone: Theme.warning
                }
            }

            RowLayout {
                spacing: 8
                AppButton {
                    objectName: "automationCreateWorkflowButton"
                    Layout.minimumWidth: 136
                    Layout.preferredWidth: 136
                    Layout.maximumWidth: 136
                    Layout.minimumHeight: 38
                    Layout.preferredHeight: 38
                    Layout.maximumHeight: 38
                    text: "Tạo workflow"
                    leadingIcon: "ui/plus"
                    primary: true
                    enabled: Boolean(root.createAction.available)
                    activeFocusOnTab: true
                    Accessible.name: enabled
                        ? "Tạo workflow từ catalog server"
                        : "Tạo workflow không khả dụng"
                    Accessible.description: String(root.createAction.reason_code || "")
                    ToolTip.visible: hovered
                    ToolTip.text: enabled
                        ? "Tạo definition mới ở trạng thái tắt"
                        : String(root.createAction.reason_code || "Không khả dụng")
                    onClicked: root.createRequested()
                }
                AppButton {
                    objectName: "automationBatchButton"
                    Layout.minimumWidth: 136
                    Layout.preferredWidth: 136
                    Layout.maximumWidth: 136
                    Layout.minimumHeight: 38
                    Layout.preferredHeight: 38
                    Layout.maximumHeight: 38
                    text: "Chạy batch"
                    trailingIcon: "ui/chevron-right"
                    enabled: Boolean(root.batchAction.available)
                        && Boolean((root.batchAction.deep_link || {}).route)
                    availabilityReason: enabled ? ""
                        : String(root.batchAction.reason_code
                            || "Server chưa cấp không gian Batch Browser")
                    onClicked: root.batchRequested()
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
            Layout.preferredHeight: 44
            spacing: 8

            Rectangle {
                Layout.preferredWidth: 520
                Layout.preferredHeight: 40
                radius: Theme.radiusMedium
                color: Theme.elevated
                border.width: 1
                border.color: Theme.borderSoft

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 3
                    spacing: 3
                    Repeater {
                        model: root.tabs
                        delegate: Button {
                            id: tabButton
                            required property var modelData
                            objectName: "automationTab_" + String(tabButton.modelData.key)
                            text: modelData.label
                            flat: true
                            activeFocusOnTab: true
                            Layout.minimumWidth: 100
                            Layout.preferredWidth: 100
                            Layout.maximumWidth: 100
                            Layout.fillHeight: true
                            leftPadding: 8
                            rightPadding: 8
                            font.pixelSize: 11
                            font.weight: root.activeTab === modelData.key
                                ? Font.DemiBold : Font.Normal
                            Accessible.name: "Mở " + text
                            contentItem: Text {
                                text: tabButton.text
                                color: root.activeTab === tabButton.modelData.key
                                    ? Theme.accent : Theme.textMuted
                                font: tabButton.font
                                elide: Text.ElideRight
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            background: Rectangle {
                                radius: Theme.radiusSmall
                                color: root.activeTab === tabButton.modelData.key
                                    ? Qt.rgba(Theme.accent.r, Theme.accent.g,
                                        Theme.accent.b, 0.13)
                                    : tabButton.hovered ? Theme.hover : "transparent"
                                border.width: root.activeTab === tabButton.modelData.key ? 1 : 0
                                border.color: Theme.accent
                            }
                            onClicked: root.tabRequested(modelData.key)
                        }
                    }
                }
            }

            Item { Layout.fillWidth: true }
            Text {
                text: "CÁCH VẬN HÀNH"
                color: Theme.textFaint
                font.pixelSize: 11
                font.weight: Font.DemiBold
            }
            AutomationFlowStep {
                objectName: "automationHowTrigger"
                Layout.preferredWidth: 184
                title: "Kích hoạt"
                detail: "Lịch · sự kiện · thủ công"
                stepNumber: 1
                iconName: "ui/play"
                tone: Theme.accent
            }
            UiIcon { name: "ui/chevron-right"; tone: Theme.textFaint; iconSize: 14 }
            AutomationFlowStep {
                objectName: "automationHowExecute"
                Layout.preferredWidth: 184
                title: "Thực thi"
                detail: "Browser · Studio · AI"
                stepNumber: 2
                iconName: "semantic/workflow"
                tone: Theme.success
            }
            UiIcon { name: "ui/chevron-right"; tone: Theme.textFaint; iconSize: 14 }
            AutomationFlowStep {
                objectName: "automationHowControl"
                Layout.preferredWidth: 184
                title: "Kiểm soát"
                detail: "Phê duyệt · retry · audit"
                stepNumber: 3
                iconName: "device/approval"
                tone: Theme.warning
            }
        }
    }
}
