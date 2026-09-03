pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import "../.."
import "../../foundation" as Foundation

Panel {
    id: root
    objectName: "runtimePathsPanel"
    property var storage: ({})
    readonly property var entries: (storage || {}).entries || []
    signal openRequested(var action)
    Accessible.name: "Đường dẫn runtime và dung lượng lưu trữ"
    Accessible.role: Accessible.Pane
    implicitHeight: 218

    function actionAvailable(action) {
        return action !== null && action !== undefined
            && typeof action === "object" && action.available === true
    }

    function actionReason(action) {
        if (root.actionAvailable(action)) return ""
        const reason = action !== null && action !== undefined
            && typeof action === "object" ? String(action.reason_code || "") : ""
        return reason.length > 0 ? reason : "Đường dẫn không khả dụng"
    }

    function pathValue(key) {
        const value = (root.storage || {})[key]
        return value === undefined || value === null || String(value).length === 0
            ? "Không khả dụng" : String(value)
    }

    function diskText() {
        const used = Number((root.storage || {}).used_bytes)
        const total = Number((root.storage || {}).total_bytes)
        if (!Number.isFinite(used) || !Number.isFinite(total) || total <= 0)
            return "Không có dữ liệu dung lượng"
        return (used / 1024 / 1024 / 1024).toFixed(1) + " GB / "
            + (total / 1024 / 1024 / 1024).toFixed(1) + " GB"
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 7
        Text { text: "Đường dẫn Runtime"; color: Theme.text; font.pixelSize: Theme.fontSection; font.weight: Font.Bold }

        Repeater {
            model: root.entries
            delegate: RowLayout {
                id: pathRow
                required property var modelData
                Layout.fillWidth: true
                Layout.preferredHeight: 38
                spacing: 8
                readonly property var rowAction: pathRow.modelData.action || ({})
                readonly property string buttonName: {
                    const key = String(pathRow.modelData.key || "")
                    if (key === "runtime_path") return "browseRuntimePathButton"
                    if (key === "cache_path") return "browseCachePathButton"
                    if (key === "downloads_path") return "browseDownloadsPathButton"
                    return "browseSettingsPath_" + key
                }
                Text { Layout.preferredWidth: 116; text: String(pathRow.modelData.label || "Đường dẫn"); color: Theme.textFaint; font.pixelSize: 11; wrapMode: Text.Wrap }
                Rectangle {
                    Layout.fillWidth: true; Layout.preferredHeight: 36; radius: Theme.radiusSmall
                    color: Theme.elevated; border.width: 1; border.color: Theme.borderSoft
                    Text {
                        objectName: "runtimePathText_" + String(pathRow.modelData.key || "")
                        anchors.fill: parent
                        anchors.margins: 6
                        verticalAlignment: Text.AlignVCenter
                        text: String(pathRow.modelData.path || "Không khả dụng")
                        color: text === "Không khả dụng" ? Theme.warning : Theme.textMuted
                        font.pixelSize: 11
                        wrapMode: Text.WrapAnywhere
                        maximumLineCount: 2
                    }
                }
                AppButton {
                    objectName: pathRow.buttonName
                    Layout.preferredWidth: 112
                    Layout.minimumWidth: 112
                    implicitHeight: 34
                    text: String(pathRow.rowAction.label || "Mở")
                    leadingIcon: String(pathRow.rowAction.icon_key || "ui/external-link")
                    iconSize: 14
                    enabled: root.actionAvailable(pathRow.rowAction)
                    activeFocusOnTab: true
                    availabilityReason: enabled ? "" : root.actionReason(pathRow.rowAction)
                    Accessible.name: text + " " + String(pathRow.modelData.label || "đường dẫn")
                    Accessible.description: enabled
                        ? "Mở thư mục hiện tại bằng hành động desktop được giới hạn"
                        : availabilityReason
                    onClicked: root.openRequested(pathRow.rowAction)
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Text { text: "Sử dụng đĩa"; color: Theme.textFaint; font.pixelSize: 11 }
            Item { Layout.fillWidth: true }
            Text { text: root.diskText(); color: root.diskText().startsWith("Không") ? Theme.warning : Theme.textMuted; font.pixelSize: 11; font.weight: Font.DemiBold }
        }
        Foundation.ProgressMeter {
            Layout.fillWidth: true
            value: {
                const used = Number((root.storage || {}).used_bytes)
                const total = Number((root.storage || {}).total_bytes)
                return Number.isFinite(used) && Number.isFinite(total) && total > 0 ? used / total : 0
            }
            visible: Number((root.storage || {}).total_bytes) > 0
        }
    }
}
