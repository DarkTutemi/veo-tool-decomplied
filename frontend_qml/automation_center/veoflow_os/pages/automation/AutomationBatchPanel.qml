pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import "../.."
import "../../foundation" as Foundation

Rectangle {
    id: root
    objectName: "automationBatchPanel"
    property var section: ({})
    property var controlPlaneBridge
    property int commandRevision: 0
    signal deepLinkRequested(var link)
    signal actionRequested(string capability, var input, string batchId)

    radius: Theme.radiusLarge
    color: Theme.panel
    border.width: 1
    border.color: Theme.borderSoft
    clip: true
    Accessible.name: "Batch Browser từ projection server"
    Accessible.role: Accessible.Pane

    readonly property var items: root.section.items || []
    readonly property var workspaceAction:
        (root.section.actions || {}).open_workspace || ({})

    function stateTone(state) {
        const value = String(state || "")
        if (value === "succeeded" || value === "completed") return Theme.success
        if (value === "failed" || value === "cancelled") return Theme.danger
        if (value === "running" || value === "queued") return Theme.accent
        if (value === "waiting_approval" || value === "partial") return Theme.warning
        return Theme.textFaint
    }

    Connections {
        target: root.controlPlaneBridge ? root.controlPlaneBridge.commandStore : null
        function onChanged(capability, entityType, entityId) {
            root.commandRevision++
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 58
            Layout.leftMargin: 16
            Layout.rightMargin: 12
            spacing: 10
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2
                Text { text: "Batch Browser"; color: Theme.text; font.pixelSize: Theme.fontSection; font.weight: Font.DemiBold }
                Text { text: String(root.section.total || root.items.length) + " batch được server chiếu"; color: Theme.textFaint; font.pixelSize: 11 }
            }
            AppButton {
                objectName: "automationBatchWorkspaceButton"
                text: "Mở không gian batch"
                trailingIcon: "ui/chevron-right"
                enabled: Boolean(root.workspaceAction.available)
                    && Boolean((root.workspaceAction.deep_link || {}).route)
                availabilityReason: enabled ? ""
                    : String(root.workspaceAction.reason_code
                        || "Server không cấp deep link không gian batch")
                onClicked: root.deepLinkRequested(root.workspaceAction.deep_link)
            }
        }
        Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Theme.borderSoft }

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 34
            Layout.leftMargin: 16
            Layout.rightMargin: 16
            spacing: 10
            Text { Layout.fillWidth: true; text: "Thao tác"; color: Theme.textFaint; font.pixelSize: 11; font.weight: Font.DemiBold }
            Text { Layout.preferredWidth: 112; text: "Trạng thái"; color: Theme.textFaint; font.pixelSize: 11; font.weight: Font.DemiBold }
            Text { Layout.preferredWidth: 90; text: "Tiến độ"; color: Theme.textFaint; font.pixelSize: 11; font.weight: Font.DemiBold }
            Text { Layout.preferredWidth: 130; text: "Khởi tạo"; color: Theme.textFaint; font.pixelSize: 11; font.weight: Font.DemiBold }
            Item { Layout.preferredWidth: 236 }
        }

        ListView {
            id: batchList
            objectName: "automationBatchList"
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.leftMargin: 8
            Layout.rightMargin: 8
            Layout.bottomMargin: 8
            spacing: 4
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            model: root.items

            delegate: Rectangle {
                id: batchRow
                required property var modelData
                required property int index
                readonly property string batchId: String(batchRow.modelData.id || "")
                readonly property var deepLink: batchRow.modelData.deep_link || ({})
                readonly property var actions: batchRow.modelData.actions || ({})
                readonly property var cancelAction: batchRow.actions.cancel || ({})
                readonly property var retryAction: batchRow.actions.retry_failed || ({})
                readonly property bool cancelBusy: {
                    const revision = root.commandRevision
                    return root.controlPlaneBridge && root.controlPlaneBridge.commandStore.isBusy(
                        String(batchRow.cancelAction.capability || "browser.batch.cancel"),
                        "browser_batch", batchRow.batchId)
                }
                readonly property bool retryBusy: {
                    const revision = root.commandRevision
                    return root.controlPlaneBridge && root.controlPlaneBridge.commandStore.isBusy(
                        String(batchRow.retryAction.capability || "browser.batch.retry_failed"),
                        "browser_batch", batchRow.batchId)
                }
                objectName: "automationBatchRow_" + batchId
                width: batchList.width
                height: 62
                radius: Theme.radiusSmall
                color: rowHover.hovered ? Theme.hover : Theme.elevated
                border.width: 1
                border.color: Theme.borderSoft
                activeFocusOnTab: Boolean(batchRow.deepLink.route)
                Accessible.name: "Batch " + batchId
                Accessible.role: Accessible.ListItem
                Accessible.description: activeFocusOnTab
                    ? "Enter hoặc Space để mở không gian batch"
                    : "Batch chưa có deep link được server cấp quyền"
                Keys.onReturnPressed: function(event) {
                    root.deepLinkRequested(batchRow.deepLink)
                    event.accepted = true
                }
                Keys.onEnterPressed: function(event) {
                    root.deepLinkRequested(batchRow.deepLink)
                    event.accepted = true
                }
                Keys.onSpacePressed: function(event) {
                    root.deepLinkRequested(batchRow.deepLink)
                    event.accepted = true
                }

                HoverHandler { id: rowHover }
                TapHandler {
                    enabled: Boolean(batchRow.deepLink.route)
                    onTapped: root.deepLinkRequested(batchRow.deepLink)
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 10
                    spacing: 10
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        Text { Layout.fillWidth: true; text: String(batchRow.modelData.operation || "Batch"); color: Theme.text; font.pixelSize: 12; font.weight: Font.DemiBold; elide: Text.ElideRight }
                        Text { Layout.fillWidth: true; text: batchRow.batchId + " · " + String(batchRow.modelData.risk_level || "—"); color: Theme.textFaint; font.pixelSize: 11; elide: Text.ElideRight }
                        Text {
                            Layout.fillWidth: true
                            visible: Object.keys(batchRow.modelData.last_error || ({})).length > 0
                            text: String((batchRow.modelData.last_error || {}).message
                                || (batchRow.modelData.last_error || {}).code || "")
                            color: Theme.danger
                            font.pixelSize: 11
                            elide: Text.ElideRight
                        }
                    }
                    Foundation.StatusPill {
                        Layout.preferredWidth: 112
                        text: String(batchRow.modelData.state || "—")
                        tone: root.stateTone(batchRow.modelData.state)
                    }
                    Text {
                        Layout.preferredWidth: 90
                        text: String(batchRow.modelData.succeeded || 0) + "/" + String(batchRow.modelData.total || 0)
                        color: Theme.textMuted
                        font.pixelSize: 11
                    }
                    Text {
                        Layout.preferredWidth: 130
                        text: String(batchRow.modelData.created_at || "—").replace("T", " ").slice(0, 16)
                        color: Theme.textMuted
                        font.pixelSize: 11
                        elide: Text.ElideRight
                    }
                    RowLayout {
                        Layout.preferredWidth: 236
                        spacing: 6
                        AppButton {
                            objectName: "automationBatchRetry_" + batchRow.batchId
                            Layout.fillWidth: true
                            text: "Thử lỗi"
                            implicitHeight: 32
                            visible: Object.keys(batchRow.retryAction).length > 0
                            enabled: Boolean(batchRow.retryAction.available) && !batchRow.retryBusy
                            availabilityReason: enabled ? "" : String(batchRow.retryAction.reason_code || "Server không cho phép thử lại")
                            onClicked: root.actionRequested(
                                String(batchRow.retryAction.capability || ""),
                                batchRow.retryAction.input || ({"batch_id": batchRow.batchId}),
                                batchRow.batchId)
                        }
                        AppButton {
                            objectName: "automationBatchCancel_" + batchRow.batchId
                            Layout.fillWidth: true
                            text: "Hủy"
                            implicitHeight: 32
                            visible: Object.keys(batchRow.cancelAction).length > 0
                            enabled: Boolean(batchRow.cancelAction.available) && !batchRow.cancelBusy
                            availabilityReason: enabled ? "" : String(batchRow.cancelAction.reason_code || "Server không cho phép hủy")
                            onClicked: root.actionRequested(
                                String(batchRow.cancelAction.capability || ""),
                                batchRow.cancelAction.input || ({"batch_id": batchRow.batchId}),
                                batchRow.batchId)
                        }
                    }
                }
            }
        }

        Text {
            visible: root.items.length === 0
            Layout.alignment: Qt.AlignHCenter
            Layout.bottomMargin: 24
            text: "Không có batch trong workspace hiện tại"
            color: Theme.textFaint
            font.pixelSize: 12
        }
    }
}
