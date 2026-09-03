import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../components"
import "../theme"

Dialog {
    id: root
    objectName: "HeaderUpdateDialog"

    property var payload: ({})
    property bool busy: false
    property string currentActionId: ""
    property int actionProgressValue: 0
    property string actionProgressText: ""
    property bool actionProgressIndeterminate: false

    signal actionRequested(string action, string value)

    parent: Overlay.overlay
    modal: true
    closePolicy: root.busy && root.currentActionId === "update_apply"
                 ? Popup.NoAutoClose
                 : (Popup.CloseOnEscape | Popup.CloseOnPressOutside)
    width: VfDialogMetrics.width(parent, VfTheme.dp(700), VfTheme.dp(72))
    height: VfDialogMetrics.height(parent, VfTheme.dp(430), VfTheme.dp(72))
    x: VfDialogMetrics.centerX(parent, width)
    y: VfDialogMetrics.centerY(parent, height)
    padding: 0

    header: VfDialogHeader {
        title: root.headerTitle()
        iconName: root.statusIcon()
        compact: true
        onCloseClicked: root.runAction("close", "")
    }

    function openFromPayload(data) {
        root.payload = data || ({})
        root.open()
    }

    function sections() {
        return root.payload && root.payload.sections ? root.payload.sections : []
    }

    function rawActions() {
        return root.payload && root.payload.actions ? root.payload.actions : []
    }

    function rowValue(label) {
        var items = sections()
        for (var index = 0; index < items.length; index += 1) {
            var section = items[index] || ({})
            var rows = section.rows || []
            for (var rowIndex = 0; rowIndex < rows.length; rowIndex += 1) {
                var row = rows[rowIndex] || ({})
                if (String(row.label || "") === label)
                    return String(row.value || "").trim()
            }
        }
        return ""
    }

    function cleanValue(value, fallback) {
        var text = String(value || "").trim()
        if (text.length <= 0 || text === "-")
            return arguments.length > 1 ? String(fallback || "") : "-"
        return text
    }

    function mode() {
        return String(root.payload.mode || "")
    }

    function updateAvailable() {
        return root.rowValue("Update available").toLowerCase() === "yes"
    }

    function hasPendingUpdate() {
        if (root.rowValue("Pending update").toLowerCase() === "yes")
            return true
        var pendingVersion = root.cleanValue(root.rowValue("Pending version"), "")
        var pendingStatus = root.cleanValue(root.rowValue("Pending status"), "")
        return pendingVersion.length > 0 || (pendingStatus.length > 0 && pendingStatus !== "none")
    }

    function currentVersion() {
        return root.cleanValue(root.rowValue("Current version"), root.cleanValue(root.rowValue("Current build"), "-"))
    }

    function latestVersion() {
        return root.cleanValue(root.rowValue("Latest version"), "-")
    }

    function fileName() {
        return root.cleanValue(root.rowValue("File"), "")
    }

    function changelog() {
        return root.cleanValue(root.rowValue("Changelog"), "")
    }

    function headerTitle() {
        if (root.busy && root.currentActionId === "update_download")
            return (void i18n.revision, i18n.t("header_update_dialog.downloading_update", "Đang tải cập nhật"))
        if (root.busy)
            return (void i18n.revision, i18n.t("header_update_dialog.checking_update", "Đang kiểm tra cập nhật"))
        if (root.mode() === "update_download")
            return (void i18n.revision, i18n.t("header_update_dialog.update_downloaded", "Cập nhật đã tải"))
        if (root.mode() === "update_apply")
            return (void i18n.revision, i18n.t("header_update_dialog.installing_update", "Đang cài đặt cập nhật"))
        if (root.mode() === "update_result" && root.updateAvailable())
            return (void i18n.revision, i18n.t("header_update_dialog.new_update_available", "Có bản cập nhật mới"))
        if (root.mode() === "update_result")
            return (void i18n.revision, i18n.t("header_update_dialog.already_latest", "Đã ở bản mới nhất"))
        return (void i18n.revision, i18n.t("header_update_dialog.app_update", "Cập nhật ứng dụng"))
    }

    function headline() {
        if (root.busy)
            return root.actionProgressText.length > 0 ? root.actionProgressText : (void i18n.revision, i18n.t("header_update_dialog.working", "Đang làm việc..."))
        if (root.mode() === "update_download")
            return (void i18n.revision, i18n.t("header_update_dialog.package_ready", "Gói cập nhật đã sẵn sàng"))
        if (root.mode() === "update_apply")
            return (void i18n.revision, i18n.t("header_update_dialog.installer_started", "Trình cài đặt đã được khởi động"))
        if (root.updateAvailable())
            return (void i18n.revision, i18n.t("header_update_dialog.found_new_version", "Tìm thấy phiên bản mới ")) + root.latestVersion()
        if (root.mode() === "update_result")
            return (void i18n.revision, i18n.t("header_update_dialog.no_update_available", "Không có bản cập nhật mới"))
        if (root.hasPendingUpdate())
            return (void i18n.revision, i18n.t("header_update_dialog.pending_package", "Có gói cập nhật đã tải trước đó"))
        return (void i18n.revision, i18n.t("header_update_dialog.check_for_update", "Bấm kiểm tra để tìm phiên bản mới"))
    }

    function description() {
        if (root.busy && root.currentActionId === "update_download")
            return (void i18n.revision, i18n.t("header_update_dialog.downloading_package_desc", "Ứng dụng đang tải gói cập nhật. Bạn có thể tiếp tục theo dõi tiến trình tại đây."))
        if (root.busy)
            return (void i18n.revision, i18n.t("header_update_dialog.checking_server_desc", "Đang hỏi server phiên bản mới nhất cho bản build hiện tại."))
        if (root.mode() === "update_download")
            return (void i18n.revision, i18n.t("header_update_dialog.install_now_desc", "Bạn có thể cài đặt ngay hoặc đóng dialog và cài sau từ nút cập nhật."))
        if (root.mode() === "update_apply")
            return (void i18n.revision, i18n.t("header_update_dialog.close_to_complete_desc", "Ứng dụng có thể đóng và mở lại để hoàn tất cập nhật."))
        if (root.updateAvailable())
            return (void i18n.revision, i18n.t("header_update_dialog.download_before_install", "Đang dùng ")) + root.currentVersion() + (void i18n.revision, i18n.t("header_update_dialog.download_before_install_suffix", ". Hãy tải gói cập nhật trước khi cài đặt."))
        if (root.mode() === "update_result")
            return (void i18n.revision, i18n.t("header_update_dialog.already_running_latest_prefix", "Máy đang chạy ")) + root.currentVersion() + (void i18n.revision, i18n.t("header_update_dialog.already_running_latest_middle", ". Server báo latest là ")) + root.latestVersion() + (void i18n.revision, i18n.t("header_update_dialog.already_running_latest_suffix", ", nên không cần tải gì thêm."))
        return (void i18n.revision, i18n.t("header_update_dialog.check_description", "Kiểm tra cập nhật chỉ so sánh phiên bản và chỉ tải khi có bản mới hợp lệ."))
    }

    function statusIcon() {
        if (root.mode() === "update_result" && !root.updateAvailable() && !root.busy)
            return "check-mark-button"
        if (root.updateAvailable() || root.mode() === "update_download")
            return "down-arrow"
        return "clockwise-arrows"
    }

    function accentColor() {
        if (root.mode() === "update_result" && !root.updateAvailable() && !root.busy)
            return "#10B981"
        if (root.updateAvailable() || root.mode() === "update_download")
            return VfTheme.primary
        return "#7C3AED"
    }

    function accentFill() {
        if (root.mode() === "update_result" && !root.updateAvailable() && !root.busy)
            return VfTheme.greenFill
        if (root.updateAvailable() || root.mode() === "update_download")
            return VfTheme.blueFill
        return VfTheme.violetFill
    }

    function accentBorder() {
        if (root.mode() === "update_result" && !root.updateAvailable() && !root.busy)
            return VfTheme.greenBorderSoft
        if (root.updateAvailable() || root.mode() === "update_download")
            return VfTheme.blueBorderSoft
        return VfTheme.violetBorderSoft
    }

    function canApplyNow() {
        // fsmState is authoritative when present; row heuristics cover payloads
        // from services that have not been migrated yet.
        if (String(root.payload.fsmState || "") === "READY_TO_APPLY")
            return true
        return root.hasPendingUpdate()
    }

    function filteredActions() {
        // Spec §3.2 State Action Matrix — the dialog renders buttons strictly
        // from service-provided actions plus these hard gates:
        if (root.busy && root.currentActionId === "update_download") {
            return [{
                label: (void i18n.revision, i18n.t("header_update_dialog.cancel_download", "Hủy tải")),
                action: "update_cancel",
                value: "",
                tone: "danger"
            }]
        }
        var out = []
        var list = root.rawActions()
        for (var i = 0; i < list.length; i += 1) {
            var action = list[i] || ({})
            var actionId = String(action.action || "")
            if (actionId === "update_download" && !root.updateAvailable())
                continue
            // Defense-in-depth for gap #1: header_service now omits
            // update_apply unless a verified package is on disk, and the shell
            // additionally refuses to draw it without pending state.
            if (actionId === "update_apply" && !root.canApplyNow())
                continue
            out.push(action)
        }
        if (out.length <= 0)
            out.push({ label: (void i18n.revision, i18n.t("common.close", "Đóng")), action: "close", value: "", tone: "neutral" })
        return out
    }

    function runAction(action, value) {
        var actionText = String(action || "")
        var valueText = String(value || "")
        if (actionText === "close") {
            root.close()
            return
        }
        if (actionText === "update_check"
                || actionText === "update_download"
                || actionText === "update_apply") {
            if (typeof headerController !== "undefined" && headerController.executeAction) {
                headerController.executeAction(actionText, valueText)
            } else {
                root.actionRequested(actionText, valueText)
            }
            return
        }
        if (actionText === "update_cancel") {
            // Cancel keeps the .part on disk; the next download resumes.
            if (typeof headerController !== "undefined" && headerController.cancelCurrentAction) {
                headerController.cancelCurrentAction()
            } else {
                root.actionRequested(actionText, valueText)
            }
            return
        }
        root.actionRequested(actionText, valueText)
    }

    background: Rectangle {
        radius: VfTheme.dp(16)
        color: VfTheme.surface
        border.color: VfTheme.borderStrong
        border.width: 1
    }

    contentItem: ColumnLayout {
        spacing: 0

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: VfTheme.dp(18)
            spacing: VfTheme.dp(14)

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: VfTheme.dp(132)
                radius: VfTheme.dp(14)
                color: root.accentFill()
                border.color: root.accentBorder()
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: VfTheme.dp(16)
                    spacing: VfTheme.dp(14)

                    Rectangle {
                        Layout.preferredWidth: VfTheme.dp(54)
                        Layout.preferredHeight: VfTheme.dp(54)
                        radius: VfTheme.dp(16)
                        color: root.accentColor()

                        VfAppIcon {
                            anchors.centerIn: parent
                            name: root.statusIcon()
                            size: VfTheme.dp(25)
                            framed: false
                            color: "#FFFFFF"
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: VfTheme.dp(5)

                        Text {
                            Layout.fillWidth: true
                            text: root.headline()
                            color: VfTheme.text
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.dp(21)
                            font.weight: VfTheme.weightTitle
                            elide: Text.ElideRight
                        }

                        Text {
                            Layout.fillWidth: true
                            text: root.description()
                            color: VfTheme.textMuted
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.fontControl
                            wrapMode: Text.WordWrap
                            maximumLineCount: 2
                            elide: Text.ElideRight
                        }
                    }
                }
            }

            GridLayout {
                Layout.fillWidth: true
                columns: root.width >= VfTheme.dp(620) ? 3 : 1
                columnSpacing: VfTheme.dp(10)
                rowSpacing: VfTheme.dp(10)

                VersionTile {
                    label: (void i18n.revision, i18n.t("header_update_dialog.current_version_label", "Đang dùng"))
                    value: root.currentVersion()
                    iconName: "notebook"
                }

                VersionTile {
                    label: (void i18n.revision, i18n.t("header_update_dialog.latest_from_server_label", "Latest từ server"))
                    value: root.latestVersion()
                    iconName: "clockwise-arrows"
                }

                VersionTile {
                    label: root.mode() === "update_download" ? (void i18n.revision, i18n.t("header_update_dialog.downloaded_package_label", "Gói tải về")) : (void i18n.revision, i18n.t("header_update_dialog.status_label", "Trạng thái"))
                    value: root.updateAvailable() ? (void i18n.revision, i18n.t("header_update_dialog.has_new_version", "Có bản mới")) : (root.mode() === "update_result" ? (void i18n.revision, i18n.t("header_update_dialog.no_update_needed", "Không cần cập nhật")) : root.cleanValue(root.rowValue("Pending status"), (void i18n.revision, i18n.t("header_update_dialog.ready_status", "Sẵn sàng"))))
                    iconName: root.updateAvailable() ? "down-arrow" : "check-mark-button"
                }
            }

            Rectangle {
                Layout.fillWidth: true
                visible: root.busy || root.actionProgressValue > 0
                radius: VfTheme.dp(12)
                color: VfTheme.surfaceSoft
                border.color: VfTheme.border
                implicitHeight: progressColumn.implicitHeight + VfTheme.dp(20)

                ColumnLayout {
                    id: progressColumn
                    anchors.fill: parent
                    anchors.margins: VfTheme.dp(10)
                    spacing: VfTheme.dp(7)

                    ProgressBar {
                        Layout.fillWidth: true
                        from: 0
                        to: 100
                        indeterminate: root.actionProgressIndeterminate && root.busy
                        value: root.actionProgressValue
                    }

                    Text {
                        Layout.fillWidth: true
                        text: root.actionProgressIndeterminate ? (void i18n.revision, i18n.t("header_update_dialog.processing", "Đang xử lý...")) : root.actionProgressValue + "%"
                        color: VfTheme.textMuted
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.fontSmall
                        horizontalAlignment: Text.AlignRight
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                visible: root.updateAvailable() && root.changelog().length > 0
                radius: VfTheme.dp(12)
                color: VfTheme.surfaceSoft
                border.color: VfTheme.border
                clip: true

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: VfTheme.dp(12)
                    spacing: VfTheme.dp(6)

                    Text {
                        Layout.fillWidth: true
                        text: (void i18n.revision, i18n.t("header_update_dialog.release_notes", "Ghi chú phiên bản"))
                        color: VfTheme.text
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.fontControl
                        font.weight: VfTheme.weightStrong
                    }

                    Text {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        text: root.changelog()
                        color: VfTheme.textMuted
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.fontSmall
                        wrapMode: Text.WordWrap
                        elide: Text.ElideRight
                        maximumLineCount: 4
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: VfTheme.border
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: VfTheme.dp(58)
            color: VfTheme.surfaceSoft

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: VfTheme.dp(14)
                anchors.rightMargin: VfTheme.dp(14)
                spacing: VfTheme.dp(8)

                Text {
                    Layout.fillWidth: true
                    text: root.fileName().length > 0 && root.updateAvailable() ? root.fileName() : ""
                    color: VfTheme.textMuted
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.fontSmall
                    elide: Text.ElideMiddle
                }

                Repeater {
                    model: root.filteredActions()

                    delegate: VfButton {
                        property var actionData: modelData

                        text: String(actionData.label || "")
                        tone: String(actionData.tone || "neutral")
                        actionId: "header.update.footer"
                        enabled: !root.busy
                                 || String(actionData.action || "") === "close"
                                 || String(actionData.action || "") === "update_cancel"
                        onClicked: root.runAction(actionData.action, actionData.value)
                    }
                }
            }
        }
    }

    component VersionTile: Rectangle {
        id: tileRoot
        property string label: ""
        property string value: ""
        property string iconName: "notebook"

        Layout.fillWidth: true
        Layout.preferredHeight: VfTheme.dp(72)
        radius: VfTheme.dp(12)
        color: VfTheme.surfaceSoft
        border.color: VfTheme.border
        border.width: 1

        RowLayout {
            anchors.fill: parent
            anchors.margins: VfTheme.dp(12)
            spacing: VfTheme.dp(10)

            VfAppIcon {
                Layout.preferredWidth: VfTheme.dp(24)
                Layout.preferredHeight: VfTheme.dp(24)
                name: tileRoot.iconName
                size: VfTheme.dp(20)
                framed: false
                color: root.accentColor()
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: VfTheme.dp(2)

                Text {
                    Layout.fillWidth: true
                    text: tileRoot.label
                    color: VfTheme.textMuted
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.fontSmall
                    font.weight: VfTheme.weightStrong
                    elide: Text.ElideRight
                }

                Text {
                    Layout.fillWidth: true
                    text: tileRoot.value
                    color: VfTheme.text
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(15)
                    font.weight: VfTheme.weightTitle
                    elide: Text.ElideRight
                }
            }
        }
    }
}
