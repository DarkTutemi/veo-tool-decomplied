pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../.."
import "../../foundation" as Foundation

ScrollView {
    id: root
    objectName: "licenseCenterPanel"
    clip: true
    contentWidth: availableWidth

    property var license: ({})
    property var controlPlaneBridge: null
    property int commandRevision: 0
    property string licenseKeyDraft: ""
    readonly property var actions: license.actions || ({})
    readonly property var activateAction: actions.activate || ({})
    readonly property var verifyAction: actions.verify || ({})
    readonly property var deactivateAction: actions.deactivate || ({})
    readonly property var descriptor: license.state_descriptor || ({})
    readonly property bool verifyBusy: root.busy("license.verify")
    readonly property bool activateBusy: root.busy("license.activate")
    readonly property bool deactivateBusy: root.busy("license.deactivate")

    signal actionRequested(var action, var extra)

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

    function busy(capability) {
        const revision = root.commandRevision
        if (!root.controlPlaneBridge || !root.controlPlaneBridge.commandStore)
            return false
        return root.controlPlaneBridge.commandStore.isBusy(
            String(capability || ""), "global", "global")
    }

    function tone() {
        const key = String(root.descriptor.tone_key || "warning")
        if (key === "success") return Theme.success
        if (key === "danger") return Theme.danger
        if (key === "info") return Theme.info
        return Theme.warning
    }

    function activate() {
        const key = root.licenseKeyDraft.trim()
        if (!root.actionAvailable(root.activateAction) || key.length === 0)
            return false
        root.actionRequested(root.activateAction, {"license_key": key})
        return true
    }

    function verify() {
        if (!root.actionAvailable(root.verifyAction)) return false
        root.actionRequested(root.verifyAction, ({}))
        return true
    }

    function requestDeactivate() {
        if (!root.actionAvailable(root.deactivateAction)) return false
        deactivateDialog.open()
        return true
    }

    SettingsDialog {
        id: deactivateDialog
        objectName: "licenseDeactivateDialog"
        title: "Gỡ license khỏi máy này?"
        width: Math.min(520, (parent ? parent.width : 560) - 32)
        height: 250
        x: parent ? Math.max(16, (parent.width - width) / 2) : 0
        y: parent ? Math.max(16, (parent.height - height) / 2) : 0
        contentItem: ColumnLayout {
            spacing: 10
            Text {
                Layout.fillWidth: true
                text: "Quyền sử dụng và token runtime trên máy sẽ bị thu hồi cục bộ. Dữ liệu vận hành không bị xóa."
                color: Theme.textMuted
                font.pixelSize: 12
                wrapMode: Text.Wrap
            }
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 48
                radius: Theme.radiusSmall
                color: Theme.warningSoft
                border.width: 1
                border.color: Theme.warning
                Text {
                    anchors.fill: parent
                    anchors.margins: 10
                    text: "Sau khi gỡ, các capability yêu cầu license sẽ fail-closed."
                    color: Theme.warning
                    font.pixelSize: 11
                    wrapMode: Text.Wrap
                }
            }
        }
        footer: Rectangle {
            implicitHeight: 58
            color: Theme.panel
            RowLayout {
                anchors.fill: parent
                anchors.margins: 10
                Item { Layout.fillWidth: true }
                AppButton {
                    objectName: "licenseDeactivateCancelButton"
                    text: "Giữ license"
                    onClicked: deactivateDialog.close()
                }
                AppButton {
                    objectName: "licenseDeactivateConfirmButton"
                    text: "Gỡ license"
                    primary: true
                    onClicked: {
                        deactivateDialog.close()
                        root.actionRequested(root.deactivateAction, ({}))
                    }
                }
            }
        }
    }

    ColumnLayout {
        width: root.availableWidth
        spacing: 12

        Panel {
            Layout.fillWidth: true
            Layout.preferredHeight: 154
            Accessible.name: "Trạng thái bản quyền " + String(root.license.status_label || "Chưa xác định")
            Accessible.role: Accessible.Pane
            RowLayout {
                anchors.fill: parent
                anchors.margins: 18
                spacing: 18
                Rectangle {
                    Layout.preferredWidth: 54
                    Layout.preferredHeight: 54
                    radius: 16
                    color: Qt.rgba(root.tone().r, root.tone().g, root.tone().b, 0.16)
                    UiIcon {
                        objectName: "licenseStatusIcon"
                        anchors.centerIn: parent
                        name: String(root.descriptor.icon_key || "ui/lock")
                        iconSize: 26
                        tone: root.tone()
                    }
                }
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 5
                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            Layout.fillWidth: true
                            text: "Trung tâm bản quyền"
                            color: Theme.text
                            font.pixelSize: 19
                            font.weight: Font.Bold
                        }
                        Foundation.StatusPill {
                            text: String(root.license.status_label || root.descriptor.label || "Chưa xác định")
                            tone: root.tone()
                            showDot: true
                        }
                    }
                    Text {
                        Layout.fillWidth: true
                        text: String(root.license.summary || "Backend chưa cung cấp trạng thái license.")
                        color: Theme.textMuted
                        font.pixelSize: 12
                        wrapMode: Text.Wrap
                    }
                    RowLayout {
                        spacing: 18
                        Text {
                            text: "Sản phẩm  " + String(root.license.product_code || "—")
                            color: Theme.textFaint; font.pixelSize: 11
                        }
                        Text {
                            text: "Gói  " + String(root.license.license_type || "Chưa có")
                            color: Theme.textFaint; font.pixelSize: 11
                        }
                        Text {
                            text: "Khóa  " + String(root.license.masked_key || "Chưa nhập")
                            color: Theme.textFaint; font.pixelSize: 11
                        }
                    }
                }
            }
            Rectangle {
                z: -1
                anchors.fill: parent
                anchors.margins: 1
                radius: Theme.radiusMedium - 1
                color: Qt.rgba(root.tone().r, root.tone().g, root.tone().b,
                    Theme.isDark ? 0.08 : 0.05)
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 12
            Panel {
                Layout.fillWidth: true
                Layout.preferredWidth: 3
                Layout.preferredHeight: 260
                Accessible.name: "Kích hoạt và xác minh license"
                Accessible.role: Accessible.Pane
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 10
                    Text { text: "Kích hoạt & xác minh"; color: Theme.text; font.pixelSize: Theme.fontSection; font.weight: Font.Bold }
                    Text {
                        Layout.fillWidth: true
                        text: "Nhập license key do VeoFlow cấp. Key chỉ được gửi tới capability license.activate và không được lưu trong QML."
                        color: Theme.textMuted; font.pixelSize: 11; wrapMode: Text.Wrap
                    }
                    SettingsTextField {
                        id: licenseKeyField
                        objectName: "licenseKeyField"
                        Layout.fillWidth: true
                        placeholderText: "VFOS-XXXX-XXXX-XXXX"
                        echoMode: revealButton.checked ? TextInput.Normal : TextInput.Password
                        activeFocusOnTab: true
                        Accessible.name: "Mã bản quyền"
                        Accessible.description: "License key chỉ được gửi tới capability license.activate"
                        Accessible.role: Accessible.EditableText
                        onTextChanged: root.licenseKeyDraft = text
                        Keys.onReturnPressed: root.activate()
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        Button {
                            id: revealButton
                            objectName: "licenseKeyRevealButton"
                            checkable: true
                            text: checked ? "Ẩn key" : "Hiện key"
                            activeFocusOnTab: true
                            Accessible.name: text
                            background: Rectangle {
                                radius: Theme.radiusSmall
                                color: revealButton.hovered ? Theme.hover : Theme.elevated
                                border.width: 1
                                border.color: Theme.border
                            }
                            contentItem: Text {
                                text: revealButton.text
                                color: Theme.textMuted
                                font.pixelSize: 11
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                        Item { Layout.fillWidth: true }
                        AppButton {
                            objectName: "licenseVerifyButton"
                            text: root.verifyBusy ? "Đang xác minh…"
                                : String(root.verifyAction.label || "Xác minh")
                            leadingIcon: "ui/refresh-cw"
                            enabled: root.actionAvailable(root.verifyAction) && !root.verifyBusy
                            availabilityReason: enabled ? "" : (root.verifyBusy
                                ? "Đang xác minh license"
                                : root.actionReason(root.verifyAction, "Không thể xác minh license"))
                            onClicked: root.verify()
                        }
                        AppButton {
                            objectName: "licenseActivateButton"
                            text: root.activateBusy ? "Đang kích hoạt…"
                                : String(root.activateAction.label || "Kích hoạt")
                            leadingIcon: "ui/lock"
                            primary: true
                            enabled: root.actionAvailable(root.activateAction)
                                && root.licenseKeyDraft.trim().length > 0 && !root.activateBusy
                            availabilityReason: enabled ? "" : (root.activateBusy
                                ? "Đang kích hoạt license"
                                : root.licenseKeyDraft.trim().length === 0
                                ? "Hãy nhập license key"
                                : root.actionReason(root.activateAction, "Không thể kích hoạt license"))
                            onClicked: root.activate()
                        }
                    }
                    Item { Layout.fillHeight: true }
                }
            }

            Panel {
                Layout.fillWidth: true
                Layout.preferredWidth: 2
                Layout.preferredHeight: 260
                Accessible.name: "Định danh bản cài đặt"
                Accessible.role: Accessible.Pane
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 9
                    Text { text: "Định danh thiết bị"; color: Theme.text; font.pixelSize: Theme.fontSection; font.weight: Font.Bold }
                    Text { text: "Installation ID"; color: Theme.textFaint; font.pixelSize: 11 }
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 48
                        radius: Theme.radiusSmall
                        color: Theme.elevated
                        border.width: 1
                        border.color: Theme.borderSoft
                        Text {
                            id: deviceIdText
                            objectName: "licenseDeviceIdText"
                            anchors.fill: parent
                            anchors.margins: 12
                            text: String(root.license.device_id || "Không khả dụng")
                            color: root.license.device_id ? Theme.text : Theme.warning
                            font.pixelSize: 12
                            font.family: "Consolas"
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight
                        }
                    }
                    Text {
                        Layout.fillWidth: true
                        text: String((root.license.identity || {}).detail
                            || "Backend chưa cung cấp mô tả định danh.")
                        color: Theme.textMuted
                        font.pixelSize: 11
                        wrapMode: Text.Wrap
                    }
                    Text {
                        Layout.fillWidth: true
                        text: "Không hiển thị MachineGuid, serial CPU, BIOS hoặc ổ đĩa."
                        color: Theme.success
                        font.pixelSize: 11
                        wrapMode: Text.Wrap
                    }
                    Item { Layout.fillHeight: true }
                }
            }
        }

        Panel {
            Layout.fillWidth: true
            Layout.preferredHeight: 130
            Accessible.name: "Vòng đời license"
            Accessible.role: Accessible.Pane
            RowLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 18
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4
                    Text { text: "Xác minh gần nhất"; color: Theme.textFaint; font.pixelSize: 11 }
                    Text { text: String(root.license.last_verified_at || "Chưa xác minh"); color: Theme.text; font.pixelSize: 12; font.weight: Font.DemiBold }
                }
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4
                    Text { text: "Hết hạn"; color: Theme.textFaint; font.pixelSize: 11 }
                    Text { text: String(root.license.expires_at || "Không giới hạn / chưa có"); color: Theme.text; font.pixelSize: 12; font.weight: Font.DemiBold }
                }
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4
                    Text { text: "Capability đã cấp"; color: Theme.textFaint; font.pixelSize: 11 }
                    Text { text: String((root.license.features || []).length) + " feature"; color: Theme.text; font.pixelSize: 12; font.weight: Font.DemiBold }
                }
                AppButton {
                    objectName: "licenseDeactivateButton"
                    text: root.deactivateBusy ? "Đang gỡ…"
                        : String(root.deactivateAction.label || "Gỡ license")
                    leadingIcon: "ui/close"
                    enabled: root.actionAvailable(root.deactivateAction) && !root.deactivateBusy
                    availabilityReason: enabled ? "" : (root.deactivateBusy
                        ? "Đang gỡ license"
                        : root.actionReason(root.deactivateAction, "Không thể gỡ license"))
                    onClicked: root.requestDeactivate()
                }
            }
        }
    }
}
