pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "."

ApplicationWindow {
    id: window
    objectName: "veoflowBootstrapWindow"
    width: 1120
    height: 680
    minimumWidth: 980
    minimumHeight: 620
    visible: true
    title: "VeoFlow OS · Chuẩn bị ứng dụng"
    color: Theme.base

    property bool revealKey: false
    readonly property bool licenseKeyValid: keyInput.text.trim().length >= 10
    // qmllint disable unqualified
    readonly property var appearanceBridge: typeof appearance === "undefined" ? null : appearance
    readonly property var bridge: typeof bootstrapBridge === "undefined" ? null : bootstrapBridge
    // qmllint enable unqualified

    Binding {
        target: Theme
        property: "mode"
        value: window.appearanceBridge ? window.appearanceBridge.mode : "dark"
        when: window.appearanceBridge !== null
    }

    Component.onCompleted: window.bridge.start()

    RowLayout {
        id: workspace
        objectName: "bootstrapWorkspace"
        anchors.centerIn: parent
        width: Math.min(window.width - Theme.space7 * 2, 1320)
        height: Math.min(window.height - Theme.space7 * 2, 720)
        spacing: Theme.space4

        Panel {
            objectName: "bootstrapLicensePanel"
            Layout.fillHeight: true
            Layout.preferredWidth: Math.min(390, workspace.width * 0.35)
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Theme.space6
                spacing: Theme.space3

                RowLayout {
                    spacing: 11
                    Item {
                        Layout.preferredWidth: 38; Layout.preferredHeight: 38
                        UiIcon {
                            anchors.centerIn: parent
                            name: "brand/veoflow-mark"
                            iconSize: 32
                            preserveColors: true
                        }
                    }
                    ColumnLayout { spacing: 0
                        Text { text: "VEOFLOW OS"; color: Theme.text; font.pixelSize: 15; font.weight: Font.Bold }
                        Text { text: "KHỞI ĐỘNG AN TOÀN"; color: Theme.accent; font.pixelSize: 11; font.weight: Font.Bold; font.letterSpacing: 0.7 }
                    }
                }

                Item { Layout.preferredHeight: 6 }
                Text { text: "KÍCH HOẠT THIẾT BỊ"; color: Theme.textFaint; font.pixelSize: 11; font.weight: Font.Bold; font.letterSpacing: 0.8 }
                Text { text: "Bắt đầu với VeoFlow OS"; color: Theme.text; font.pixelSize: 18; font.weight: Font.Bold }
                Text {
                    Layout.fillWidth: true
                    text: "Nhập mã bản quyền đã được cấp. Ứng dụng sẽ tự kiểm tra và ghi nhớ thiết bị này."
                    color: Theme.textMuted; font.pixelSize: 11; wrapMode: Text.Wrap; lineHeight: 1.2
                }

                FieldLabel { text: "MÃ THIẾT BỊ" }
                Rectangle {
                    objectName: "bootstrapDeviceSurface"
                    Layout.fillWidth: true; Layout.preferredHeight: 42
                    radius: Theme.radiusSmall; color: Theme.elevated
                    border.width: 1; border.color: Theme.borderSoft
                    RowLayout {
                        anchors.fill: parent; anchors.leftMargin: 11; anchors.rightMargin: 7; spacing: 7
                        Text { Layout.fillWidth: true; text: window.bridge.deviceId || "Đang nhận diện…"; color: Theme.textMuted; font.pixelSize: 11; font.family: "Consolas"; elide: Text.ElideMiddle; verticalAlignment: Text.AlignVCenter }
                        AppButton {
                            id: copyDeviceButton
                            objectName: "bootstrapCopyDeviceButton"
                            Layout.preferredWidth: 94
                            Layout.preferredHeight: 30
                            text: "Sao chép"
                            leadingIcon: "ui/copy"
                            iconSize: 14
                            subtle: true
                            onClicked: window.bridge.copyDeviceId()
                        }
                    }
                }

                FieldLabel { text: "MÃ BẢN QUYỀN" }
                Rectangle {
                    objectName: "bootstrapLicenseSurface"
                    Layout.fillWidth: true; Layout.preferredHeight: 44
                    radius: Theme.radiusSmall; color: Theme.elevated
                    border.width: 1; border.color: keyInput.activeFocus ? Theme.accent : Theme.borderSoft
                    RowLayout {
                        anchors.fill: parent; anchors.leftMargin: 11; anchors.rightMargin: 8; spacing: 6
                        TextField {
                            id: keyInput
                            objectName: "bootstrapLicenseKeyField"
                            Layout.fillWidth: true
                            enabled: !window.bridge.busy && !window.bridge.licenseAllowed
                            echoMode: window.revealKey ? TextInput.Normal : TextInput.Password
                            placeholderText: "VFOS-XXXX-XXXX-XXXX"
                            placeholderTextColor: Theme.textFaint
                            color: Theme.text
                            font.pixelSize: 11; font.family: "Consolas"
                            background: Item {}
                            onAccepted: {
                                if (window.licenseKeyValid) window.bridge.activate(text.trim())
                            }
                        }
                        Button {
                            id: revealButton
                            implicitWidth: 30; implicitHeight: 30
                            enabled: keyInput.enabled
                            onClicked: window.revealKey = !window.revealKey
                            contentItem: Text { text: window.revealKey ? "Ẩn" : "Hiện"; color: Theme.textFaint; font.pixelSize: 11; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                            background: Rectangle { radius: 6; color: revealButton.hovered ? Theme.hover : "transparent" }
                        }
                    }
                }

                Text {
                    Layout.fillWidth: true
                    text: window.bridge.message
                    color: window.bridge.error ? Theme.danger : window.bridge.licenseAllowed ? Theme.success : Theme.textMuted
                    font.pixelSize: 11; wrapMode: Text.Wrap; lineHeight: 1.2
                }
                AppButton {
                    objectName: "bootstrapActivateButton"
                    Layout.fillWidth: true
                    text: window.bridge.busy ? "Đang xử lý…" : "Xác minh & tiếp tục"
                    primary: true
                    enabled: !window.bridge.busy
                        && !window.bridge.licenseAllowed
                        && window.licenseKeyValid
                    visualEnabled: enabled
                    availabilityReason: window.licenseKeyValid
                        ? ""
                        : "Nhập mã bản quyền hợp lệ gồm ít nhất 10 ký tự"
                    leadingIcon: "ui/lock"
                    onClicked: window.bridge.activate(keyInput.text.trim())
                }
                AppButton {
                    objectName: "bootstrapReplaceLicenseButton"
                    Layout.fillWidth: true
                    text: "Nhập mã bản quyền khác"
                    visible: window.bridge.licenseConfigured && !window.bridge.licenseAllowed
                    enabled: !window.bridge.busy
                    onClicked: {
                        keyInput.clear()
                        window.bridge.deactivate()
                    }
                }
                Item { Layout.fillHeight: true }
                AppButton {
                    objectName: "bootstrapRetryButton"
                    Layout.fillWidth: true
                    text: "Thử lại bước lỗi"
                    visible: Boolean(window.bridge.error)
                    enabled: !window.bridge.busy
                    onClicked: window.bridge.retry()
                }
            }
        }

        Panel {
            objectName: "bootstrapProgressPanel"
            Layout.fillWidth: true
            Layout.fillHeight: true
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 24
                spacing: Theme.space4

                RowLayout {
                    Layout.fillWidth: true
                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.minimumWidth: 0
                        spacing: 2
                        Text { text: window.bridge.error ? "Cần xử lý trước khi tiếp tục" : "Chuẩn bị VeoFlow OS"; color: Theme.text; font.pixelSize: 20; font.weight: Font.Bold }
                        Text {
                            Layout.fillWidth: true
                            text: "Ứng dụng tự kiểm tra những thành phần cần thiết · v" + window.bridge.appVersion
                            color: Theme.textFaint
                            font.pixelSize: 11
                            elide: Text.ElideRight
                        }
                    }
                    AppButton {
                        objectName: "bootstrapThemeToggle"
                        Layout.preferredWidth: 40
                        Layout.preferredHeight: 34
                        leadingIcon: Theme.isDark ? "ui/sun" : "ui/moon"
                        text: ""
                        subtle: true
                        Accessible.name: Theme.isDark
                            ? "Chuyển sang giao diện sáng" : "Chuyển sang giao diện tối"
                        onClicked: {
                            if (window.appearanceBridge) window.appearanceBridge.toggleTheme()
                            else Theme.mode = Theme.isDark ? "light" : "dark"
                        }
                    }
                    Rectangle {
                        Layout.preferredWidth: 112; Layout.preferredHeight: 30; radius: 15
                        color: window.bridge.error ? Theme.dangerSoft : window.bridge.overallProgress === 100 ? Theme.successSoft : Theme.accentSoft
                        RowLayout { anchors.centerIn: parent; spacing: 6
                            Rectangle { Layout.preferredWidth: 7; Layout.preferredHeight: 7; radius: 4; color: window.bridge.error ? Theme.danger : window.bridge.overallProgress === 100 ? Theme.success : Theme.accent }
                            Text { text: window.bridge.error ? "Có lỗi" : window.bridge.overallProgress === 100 ? "Sẵn sàng" : "Đang chạy"; color: Theme.textMuted; font.pixelSize: 11; font.weight: Font.DemiBold }
                        }
                    }
                }

                ProgressBar {
                    id: bootstrapProgress
                    Layout.fillWidth: true
                    from: 0; to: 100; value: window.bridge.overallProgress
                    background: Rectangle { implicitHeight: 7; radius: 4; color: Theme.elevated }
                    contentItem: Item { implicitHeight: 7
                        Rectangle { width: parent.width * bootstrapProgress.visualPosition; height: parent.height; radius: 4; color: window.bridge.error ? Theme.danger : Theme.accent }
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4
                    Repeater {
                        model: window.bridge.stages
                        delegate: StageRow {
                            required property var modelData
                            Layout.fillWidth: true
                            stage: modelData
                        }
                    }
                }

                Item { Layout.fillHeight: true }
                Rectangle {
                    objectName: "bootstrapProgressLog"
                    Layout.fillWidth: true; Layout.preferredHeight: 86
                    radius: Theme.radiusMedium; color: Theme.sidebar
                    border.width: 1; border.color: Theme.borderSoft
                    ColumnLayout {
                        anchors.fill: parent; anchors.margins: 12; spacing: 5
                        Text { text: "CHI TIẾT ĐANG THỰC HIỆN"; color: Theme.textFaint; font.pixelSize: 11; font.weight: Font.Bold }
                        ScrollView {
                            Layout.fillWidth: true; Layout.fillHeight: true
                            clip: true
                            TextArea {
                                text: window.bridge.progressLog
                                readOnly: true
                                selectByMouse: true
                                color: window.bridge.error ? Theme.danger : Theme.textMuted
                                font.pixelSize: 11
                                wrapMode: TextEdit.Wrap
                                background: Item {}
                            }
                        }
                    }
                }
            }
        }
    }

    component FieldLabel: Text { color: Theme.textFaint; font.pixelSize: 11; font.weight: Font.Bold }

    component StageRow: Rectangle {
        id: stageRow
        property var stage
        objectName: "bootstrapStageRow_" + String(stage.key || "unknown")
        implicitHeight: 58
        radius: Theme.radiusMedium
        color: stage.state === "running" ? Theme.accentSoft : "transparent"
        RowLayout {
            anchors.fill: parent; anchors.leftMargin: 12; anchors.rightMargin: 10; spacing: 12
            Rectangle {
                Layout.preferredWidth: 24; Layout.preferredHeight: 24; radius: 12
                color: stageRow.stage.state === "ok"
                    ? Theme.successSoft
                    : stageRow.stage.state === "warn"
                    ? Theme.warningSoft
                    : stageRow.stage.state === "error"
                    ? Theme.dangerSoft
                    : stageRow.stage.state === "running"
                    ? Theme.accentSoft
                    : Theme.elevated
                UiIcon {
                    objectName: "bootstrapStageIcon_" + String(stageRow.stage.key || "unknown")
                    anchors.centerIn: parent
                    name: stageRow.stage.state === "ok"
                        ? "semantic/check-circle"
                        : stageRow.stage.state === "running"
                        ? "ui/refresh-cw"
                        : stageRow.stage.state === "warn" || stageRow.stage.state === "error"
                        ? "semantic/alert-triangle"
                        : "semantic/info"
                    tone: stageRow.stage.state === "ok"
                        ? Theme.success
                        : stageRow.stage.state === "warn"
                        ? Theme.warning
                        : stageRow.stage.state === "error"
                        ? Theme.danger
                        : stageRow.stage.state === "running"
                        ? Theme.accent
                        : Theme.textFaint
                    iconSize: 14
                }
            }
            ColumnLayout { Layout.fillWidth: true; spacing: 2
                Text { text: stageRow.stage.name; color: Theme.text; font.pixelSize: 11; font.weight: Font.DemiBold }
                Text {
                    objectName: "bootstrapStageDetail_" + String(stageRow.stage.key || "unknown")
                    Layout.fillWidth: true
                    text: stageRow.stage.detail
                    color: Theme.textFaint
                    font.pixelSize: 11
                    elide: Text.ElideRight
                }
            }
            Text { text: stageRow.stage.state === "ok" ? "OK" : stageRow.stage.state === "running" ? stageRow.stage.progress + "%" : stageRow.stage.state === "warn" ? "Cảnh báo" : "Chờ"; color: stageRow.stage.state === "ok" ? Theme.success : stageRow.stage.state === "running" ? Theme.accent : Theme.textFaint; font.pixelSize: 11; font.weight: Font.DemiBold }
        }
    }
}
