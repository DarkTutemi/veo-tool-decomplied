pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import "../.."
import "../../foundation" as Foundation

Panel {
    id: root
    objectName: "systemHealthPanel"
    property var healthModel: null
    property var support: ({})
    property var controlPlaneBridge: null
    property int commandRevision: 0
    readonly property var diagnosticsAction: ((support || {}).actions || {}).diagnostics || ({})
    readonly property var exportAction: ((support || {}).actions || {}).export || ({})
    readonly property bool diagnosticsBusy: {
        const revision = root.commandRevision
        return root.controlPlaneBridge.commandStore.isBusy("settings.diagnostics.run", "global", "global")
    }
    readonly property bool supportBusy: {
        const revision = root.commandRevision
        return root.controlPlaneBridge.commandStore.isBusy("settings.support.export", "global", "global")
    }
    Accessible.name: "Tình trạng hệ thống có bằng chứng"
    Accessible.role: Accessible.Pane
    signal actionRequested(var action)

    function actionAvailable(action) {
        return action !== null && action !== undefined
            && typeof action === "object" && action.available === true
    }

    function actionReason(action, fallback) {
        if (root.actionAvailable(action)) return ""
        const reason = action !== null && action !== undefined
            && typeof action === "object" ? String(action.reason_code || "") : ""
        return reason.length > 0 ? reason : String(fallback || "Hành động không khả dụng")
    }

    function runDiagnostics() {
        if (!root.actionAvailable(root.diagnosticsAction))
            return false
        root.actionRequested(root.diagnosticsAction)
        return true
    }

    function exportSupport() {
        if (!root.actionAvailable(root.exportAction))
            return false
        root.actionRequested(root.exportAction)
        return true
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 8

        Text { text: "Tình trạng hệ thống"; color: Theme.text; font.pixelSize: Theme.fontSection; font.weight: Font.Bold }
        Text {
            Layout.fillWidth: true
            visible: !root.healthModel || root.healthModel.count === 0
            text: "Không có bằng chứng sức khỏe hệ thống từ backend"
            color: Theme.warning
            font.pixelSize: 11
            wrapMode: Text.Wrap
        }

        Repeater {
            model: root.healthModel
            delegate: Item {
                id: healthRow
                required property string health_id
                required property string label
                required property string state_value
                required property var summary
                required property var evidence
                required property var observed_at
                required property var icon_key
                required property var state_descriptor
                required property var reason_code
                objectName: "systemHealthRow_" + healthRow.health_id
                Layout.fillWidth: true
                Layout.minimumWidth: 0
                Layout.maximumWidth: Math.max(0, root.width - 28)
                Layout.preferredHeight: 64
                readonly property string stateLabel: String(
                    (healthRow.state_descriptor || {}).label || "Không rõ")
                readonly property color stateTone: {
                    const tone = String((healthRow.state_descriptor || {}).tone_key || "warning")
                    if (tone === "success") return Theme.success
                    if (tone === "danger") return Theme.danger
                    if (tone === "info") return Theme.info
                    return Theme.warning
                }
                Accessible.name: String(healthRow.label || healthRow.health_id || "Thành phần")
                    + ", " + stateLabel + ", " + String(healthRow.summary || "không có mô tả")
                Accessible.description: healthRow.evidence
                    ? "Bằng chứng " + String(healthRow.evidence) + ", quan sát " + String(healthRow.observed_at || "không rõ")
                    : "Chưa có bằng chứng"
                Accessible.role: Accessible.Row

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 2
                    RowLayout {
                        Layout.fillWidth: true
                        UiIcon { name: String(healthRow.icon_key || ""); iconSize: 15; tone: healthRow.stateTone }
                        Text { Layout.fillWidth: true; text: String(healthRow.label || healthRow.health_id || "—"); color: Theme.textMuted; font.pixelSize: 11; font.weight: Font.DemiBold; elide: Text.ElideRight }
                        Foundation.StatusPill { text: healthRow.stateLabel; tone: healthRow.stateTone; showDot: true }
                    }
                    Text {
                        objectName: "systemHealthEvidence_" + healthRow.health_id
                        Layout.fillWidth: true
                        Layout.minimumWidth: 0
                        Layout.maximumWidth: Math.max(0, root.width - 28)
                        text: healthRow.evidence
                            ? String(healthRow.summary || "Có bằng chứng nhưng thiếu mô tả")
                                + " · " + String(healthRow.observed_at || "thời điểm không rõ")
                            : "Chưa có bằng chứng kiểm tra"
                        color: healthRow.evidence ? Theme.textFaint : Theme.warning
                        font.pixelSize: 11
                        wrapMode: Text.Wrap
                        maximumLineCount: 2
                    }
                }
                Rectangle { anchors.left: parent.left; anchors.right: parent.right; anchors.bottom: parent.bottom; height: 1; color: Theme.borderSoft }
            }
        }

        Item { Layout.fillHeight: true }

        AppButton {
            id: diagnosticsButton
            objectName: "runDiagnosticsButton"
            Layout.fillWidth: true
            Layout.minimumWidth: 0
            Layout.maximumWidth: parent.width
            text: root.diagnosticsBusy ? "Đang chẩn đoán…"
                : String(root.diagnosticsAction.label || "Chạy chẩn đoán")
            primary: true
            activeFocusOnTab: true
            enabled: root.actionAvailable(root.diagnosticsAction) && !root.diagnosticsBusy
            availabilityReason: enabled ? "" : (root.diagnosticsBusy
                ? "Đang chạy chẩn đoán"
                : root.actionReason(root.diagnosticsAction,
                    "Không thể chạy chẩn đoán"))
            Accessible.name: text
            Accessible.description: enabled ? "Yêu cầu backend chạy chẩn đoán" : availabilityReason
            onClicked: root.runDiagnostics()
        }
        AppButton {
            id: supportButton
            objectName: "exportSupportButton"
            Layout.fillWidth: true
            Layout.minimumWidth: 0
            Layout.maximumWidth: parent.width
            text: root.supportBusy ? "Đang xuất…"
                : String(root.exportAction.label || "Xuất gói hỗ trợ")
            activeFocusOnTab: true
            enabled: root.actionAvailable(root.exportAction) && !root.supportBusy
            availabilityReason: enabled ? "" : (root.supportBusy
                ? "Đang xuất gói hỗ trợ"
                : root.actionReason(root.exportAction,
                    "Không thể xuất gói hỗ trợ"))
            Accessible.name: text
            Accessible.description: enabled ? "Yêu cầu backend tạo gói hỗ trợ đã che dữ liệu nhạy cảm" : availabilityReason
            onClicked: root.exportSupport()
        }
    }
}
