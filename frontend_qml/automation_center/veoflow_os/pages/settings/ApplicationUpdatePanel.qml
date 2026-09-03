pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import "../.."
import "../../foundation" as Foundation

Panel {
    id: root
    objectName: "applicationUpdatePanel"
    property var release: ({})
    property var controlPlaneBridge: null
    property int commandRevision: 0
    readonly property var actions: (release || {}).actions || ({})
    readonly property var configureAction: actions.configure || ({})
    readonly property var certificateAction: actions.certificate || ({})
    readonly property var rollbackAction: actions.rollback || ({})
    readonly property var historyAction: actions.history || ({})
    readonly property var checkAction: actions.check || ({})
    readonly property bool updateBusy: {
        const revision = root.commandRevision
        return root.controlPlaneBridge.commandStore.isBusy("settings.update.check", "global", "global")
    }
    Accessible.name: "Cập nhật ứng dụng"
    Accessible.role: Accessible.Pane
    implicitHeight: 184
    signal actionRequested(var action)
    signal deepLinkRequested(var deepLink)

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

    function checkUpdate() {
        if (!root.actionAvailable(root.checkAction)) return false
        root.actionRequested(root.checkAction)
        return true
    }

    function valueText(key) {
        const value = (root.release || {})[key]
        return value === undefined || value === null || String(value).length === 0 ? "Không khả dụng" : String(value)
    }

    function timeText(value) {
        const raw = String(value || "")
        if (!raw) return "Không khả dụng"
        const parsed = new Date(raw)
        return isNaN(parsed.getTime()) ? raw
            : Qt.formatDateTime(parsed, "dd/MM/yyyy HH:mm")
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 5
        RowLayout {
            Layout.fillWidth: true
            Text { text: "Cập nhật ứng dụng"; color: Theme.text; font.pixelSize: Theme.fontSection; font.weight: Font.Bold }
            Item { Layout.fillWidth: true }
            Foundation.StatusPill {
                text: String((root.release.state_descriptor || {}).label || "Không rõ")
                tone: {
                    const tone = String((root.release.state_descriptor || {}).tone_key || "warning")
                    if (tone === "success") return Theme.success
                    if (tone === "danger") return Theme.danger
                    if (tone === "info") return Theme.info
                    return Theme.warning
                }
            }
        }

        GridLayout {
            Layout.fillWidth: true
            columns: 4
            columnSpacing: 8
            rowSpacing: 2
            Text { text: "Phiên bản hiện tại"; color: Theme.textFaint; font.pixelSize: 11 }
            Text { text: root.valueText("current_version"); color: text === "Không khả dụng" ? Theme.warning : Theme.textMuted; font.pixelSize: 11; font.weight: Font.DemiBold }
            Text { text: "Chính sách"; color: Theme.textFaint; font.pixelSize: 11 }
            Text { text: root.valueText("policy"); color: text === "Không khả dụng" ? Theme.warning : Theme.textMuted; font.pixelSize: 11 }
            Text { text: "Chữ ký installer"; color: Theme.textFaint; font.pixelSize: 11 }
            Text { text: root.valueText("signature_status"); color: text === "Không khả dụng" ? Theme.warning : Theme.textMuted; font.pixelSize: 11 }
            Text { text: "Điểm rollback"; color: Theme.textFaint; font.pixelSize: 11 }
            Text { text: root.valueText("rollback_version"); color: text === "Không khả dụng" ? Theme.warning : Theme.textMuted; font.pixelSize: 11 }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 3
            RowLayout {
                Layout.fillWidth: true
                spacing: 5
                AppButton {
                    objectName: "configureUpdateButton"
                    text: String(root.configureAction.label || "Cấu hình")
                    activeFocusOnTab: true
                    enabled: root.actionAvailable(root.configureAction)
                    availabilityReason: enabled ? "" : root.actionReason(
                        root.configureAction, "Không thể cấu hình cập nhật")
                    Accessible.name: text
                    Accessible.description: availabilityReason
                    onClicked: root.deepLinkRequested(root.configureAction.deep_link || ({}))
                }
                AppButton {
                    objectName: "viewCertificateButton"
                    text: String(root.certificateAction.label || "Xem chứng chỉ")
                    activeFocusOnTab: true
                    visible: String(root.certificateAction.capability || "").length > 0
                    enabled: root.actionAvailable(root.certificateAction)
                    availabilityReason: enabled ? "" : root.actionReason(
                        root.certificateAction, "Không thể xem chứng chỉ")
                    Accessible.name: text
                    Accessible.description: availabilityReason
                    onClicked: root.actionRequested(root.certificateAction)
                }
                AppButton {
                    objectName: "rollbackUpdateButton"
                    text: String(root.rollbackAction.label || "Khôi phục")
                    activeFocusOnTab: true
                    visible: String(root.rollbackAction.capability || "").length > 0
                    enabled: root.actionAvailable(root.rollbackAction)
                    availabilityReason: enabled ? "" : root.actionReason(
                        root.rollbackAction, "Không có điểm khôi phục hợp lệ")
                    Accessible.name: text
                    Accessible.description: availabilityReason
                    onClicked: root.actionRequested(root.rollbackAction)
                }
                Item { Layout.fillWidth: true }
            }
            RowLayout {
                Layout.fillWidth: true
                spacing: 5
                AppButton {
                    objectName: "viewUpdateHistoryButton"
                    text: String(root.historyAction.label || "Lịch sử cập nhật")
                    activeFocusOnTab: true
                    visible: root.actionAvailable(root.historyAction)
                    enabled: visible
                    availabilityReason: enabled ? "" : root.actionReason(
                        root.historyAction, "Lịch sử cập nhật chưa khả dụng")
                    Accessible.name: text
                    Accessible.description: availabilityReason
                    onClicked: root.deepLinkRequested(root.historyAction.deep_link || ({}))
                }
                Item { Layout.fillWidth: true }
                AppButton {
                    id: updateButton
                    objectName: "checkAppUpdateButton"
                    text: root.updateBusy ? "Đang kiểm tra…"
                        : String(root.checkAction.label || "Kiểm tra cập nhật")
                    primary: true; activeFocusOnTab: true
                    enabled: root.actionAvailable(root.checkAction) && !root.updateBusy
                    availabilityReason: enabled ? "" : (root.updateBusy
                        ? "Đang kiểm tra cập nhật"
                        : root.actionReason(root.checkAction,
                            "Không thể kiểm tra cập nhật"))
                    Accessible.name: text
                    Accessible.description: enabled
                        ? "Yêu cầu backend kiểm tra bản phát hành đã ký"
                        : availabilityReason
                    onClicked: root.checkUpdate()
                }
            }
        }
        Text {
            objectName: "applicationUpdateLastCheckedText"
            Layout.fillWidth: true
            text: "Lần kiểm tra: " + root.timeText(root.release.last_checked_at)
            color: root.valueText("last_checked_at") === "Không khả dụng" ? Theme.warning : Theme.textFaint
            font.pixelSize: 11
        }
    }
}
