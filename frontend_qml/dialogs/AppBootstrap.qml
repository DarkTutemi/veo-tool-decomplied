import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../components"
import "../theme"

Item {
    id: root

    // ── Properties (keep all) ───────────────────────────────────────────────
    property bool bootstrapVisible: true
    property string title: "VeoFlow"
    property string message: "Waiting for license..."
    property string detail: "Complete the steps below to start"
    property int progress: 0
    property string statusTitle: "Waiting for license..."
    property string statusSubtitle: "Complete the steps below to start"
    property string deviceId: ""
    property string licenseKey: ""
    property string licenseHint: "Enter your license key"
    property bool licenseBusy: false
    property bool licenseCheckPending: false
    property bool licenseVerified: false
    property string bootstrapError: ""
    property bool showUpdateAction: false
    property string progressLog: ""
    property var stages: []
    property string systemInfo: ""
    property string appVersion: ""

    // ── Signals (keep all) ──────────────────────────────────────────────────
    signal licenseKeyEdited(string text)
    signal verifyRequested()
    signal copyDeviceRequested()
    signal exitRequested()
    signal updateRequested()
    signal clearLicenseRequested()

    // ── Visibility / fade ───────────────────────────────────────────────────
    visible: root.bootstrapVisible
    opacity: root.visible ? 1 : 0
    Behavior on opacity {
        NumberAnimation { duration: 280; easing.type: Easing.OutCubic }
    }

    // ── The window IS the box (full-bleed, soft rounded corners) ────────────
    // The bootstrap window is sized to the splash (App.qml splashWidth/Height)
    // and is transparent, so this rounded surface fills it and its corners
    // round softly (the 4 corners outside the radius are transparent, not hard
    // square edges). There is NO inner card and NO backdrop band — this is the
    // single box. A 1px border traces the soft outline; the vertical divider
    // splits the two halves inside.
    Rectangle {
        id: card
        anchors.fill: parent
        color: "#111827"
        radius: 16
        border.color: "#1F2937"
        border.width: 1

        RowLayout {
            anchors.fill: parent
            anchors.margins: 1   // sit inside the 1px window border
            spacing: 0

            // ──────────────────────────────────────────────────────────────
            // LEFT HALF (logo + device + license + verify + exit)
            // ──────────────────────────────────────────────────────────────
            Item {
                Layout.preferredWidth: 360
                Layout.fillHeight: true

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 28
                    spacing: 16

                    // Logo (panel itself is slate-900 → logo white text readable)
                    Image {
                        Layout.alignment: Qt.AlignHCenter
                        Layout.preferredWidth: 260
                        Layout.preferredHeight: 64
                        Layout.topMargin: 8
                        source: Qt.resolvedUrl("../../resources/brand/veoflow-logo-transparent.png")
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                        asynchronous: false
                        cache: true
                        mipmap: true
                        sourceSize.width: 520
                        sourceSize.height: 128

                        SequentialAnimation on scale {
                            loops: Animation.Infinite
                            running: root.bootstrapVisible
                            NumberAnimation { from: 1.0; to: 1.025; duration: 2400; easing.type: Easing.InOutSine }
                            NumberAnimation { from: 1.025; to: 1.0; duration: 2400; easing.type: Easing.InOutSine }
                        }
                    }

                    // Version
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: root.appVersion.length > 0 ? "v" + root.appVersion : ""
                        color: "#94A3B8"
                        font.family: VfTheme.fontFamily
                        font.pixelSize: 10
                        visible: text.length > 0
                    }

                    // Reseller info box (hidden — appController has no reseller property yet)
                    // When headerController.snapshot().reseller is forwarded to appController,
                    // bind: visible: (root.resellerName || "").length > 0
                    // For now always hidden.
                    Item { visible: false; width: 0; height: 0 }

                    // Divider
                    Rectangle { Layout.fillWidth: true; height: 1; color: "#1F2937" }

                    // DEVICE section
                    Column {
                        Layout.fillWidth: true
                        spacing: 6

                        Text {
                            text: "DEVICE"
                            color: "#64748B"
                            font.family: VfTheme.fontFamily
                            font.pixelSize: 10
                            font.weight: Font.Bold
                            font.letterSpacing: 1
                        }

                        Row {
                            width: parent.width
                            spacing: 6

                            Text {
                                text: "Machine ID:"
                                color: "#94A3B8"
                                font.family: VfTheme.fontFamily
                                font.pixelSize: 11
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Text {
                                text: root.deviceId.length > 14
                                    ? root.deviceId.substring(0, 14) + "…"
                                    : root.deviceId
                                color: "#F1F5F9"
                                font.family: "Consolas"
                                font.pixelSize: 11
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Rectangle {
                                width: 44
                                height: 18
                                radius: 4
                                color: copyMouse.containsMouse ? "#E0E7FF" : "transparent"
                                anchors.verticalCenter: parent.verticalCenter

                                Behavior on color { ColorAnimation { duration: 100 } }

                                Text {
                                    anchors.centerIn: parent
                                    text: "Copy"
                                    color: "#6366F1"
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: 10
                                    font.weight: Font.DemiBold
                                }

                                MouseArea {
                                    id: copyMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: root.copyDeviceRequested()
                                }
                            }
                        }

                        Text {
                            width: parent.width
                            text: root.systemInfo || ""
                            color: "#94A3B8"
                            font.family: VfTheme.fontFamily
                            font.pixelSize: 10
                            visible: text.length > 0
                            elide: Text.ElideRight
                        }
                    }

                    // Divider
                    Rectangle { Layout.fillWidth: true; height: 1; color: "#1F2937" }

                    // LICENSE section
                    Column {
                        Layout.fillWidth: true
                        spacing: 6

                        RowLayout {
                            width: parent.width
                            spacing: 6

                            Text {
                                text: "LICENSE"
                                color: "#64748B"
                                font.family: VfTheme.fontFamily
                                font.pixelSize: 10
                                font.weight: Font.Bold
                                font.letterSpacing: 1
                            }

                            Item { Layout.fillWidth: true }

                            // ✕ — clear a REJECTED license (verify failed / 403 /
                            // expired) so a different key can be entered. Also wipes
                            // the cached key so the next boot won't auto-verify the
                            // bad one again. Only shown on a verify error.
                            Rectangle {
                                id: clearLicenseX
                                visible: root.bootstrapError.length > 0
                                implicitWidth: 18
                                implicitHeight: 18
                                radius: 9
                                color: clearXMouse.containsMouse ? "#7F1D1D" : "#374151"
                                Behavior on color { ColorAnimation { duration: 120 } }

                                Text {
                                    anchors.centerIn: parent
                                    text: "✕"
                                    color: "#F1F5F9"
                                    font.pixelSize: 10
                                    font.weight: Font.Bold
                                }

                                MouseArea {
                                    id: clearXMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: root.clearLicenseRequested()
                                    ToolTip.visible: containsMouse
                                    ToolTip.text: (void i18n.revision, i18n.t("app_bootstrap.clear_license_hint", "Xoá license, nhập key khác"))
                                }
                            }
                        }

                        TextField {
                            id: licenseInput
                            width: parent.width
                            text: root.licenseKey
                            placeholderText: "XXXX-XXXX-XXXX-XXXX"
                            enabled: !root.licenseBusy && !root.licenseCheckPending && !root.licenseVerified
                            font.family: "Consolas"
                            font.pixelSize: 12
                            selectByMouse: true
                            color: "#F1F5F9"
                            placeholderTextColor: "#64748B"
                            leftPadding: 10
                            rightPadding: 10
                            topPadding: 8
                            bottomPadding: 8

                            background: Rectangle {
                                color: "#1F2937"
                                border.color: licenseInput.activeFocus ? "#6366F1" : "#374151"
                                border.width: licenseInput.activeFocus ? 2 : 1
                                radius: 6
                                Behavior on border.color { ColorAnimation { duration: 150 } }
                            }

                            onTextChanged: {
                                if (text !== root.licenseKey)
                                    root.licenseKeyEdited(text)
                            }
                            onAccepted: {
                                if (text.length >= 10 && !root.licenseBusy && !root.licenseCheckPending && !root.licenseVerified)
                                    root.verifyRequested()
                            }
                        }

                        // Hint text
                        Text {
                            width: parent.width
                            visible: root.licenseHint.length > 0
                            text: root.licenseHint
                            color: {
                                var h = root.licenseHint.toLowerCase()
                                if (h.indexOf("invalid") >= 0 || h.indexOf("error") >= 0 ||
                                    h.indexOf("fail") >= 0 || h.indexOf("expired") >= 0)
                                    return "#DC2626"
                                if (h.indexOf("verified") >= 0 || h.indexOf("ok") >= 0 ||
                                    h.indexOf("success") >= 0 || h.indexOf("active") >= 0)
                                    return "#16A34A"
                                return "#64748B"
                            }
                            font.family: VfTheme.fontFamily
                            font.pixelSize: 10
                            wrapMode: Text.WordWrap
                        }

                        // Verify button
                        Rectangle {
                            id: verifyBtn
                            width: parent.width
                            height: 36
                            radius: 6
                            property bool checking: root.licenseBusy || root.licenseCheckPending
                            property bool btnEnabled: licenseInput.text.length >= 10 && !checking && !root.licenseVerified
                            color: !btnEnabled ? "#374151" : (verifyMouse.containsMouse ? "#4F46E5" : "#6366F1")

                            Behavior on color { ColorAnimation { duration: 150 } }

                            Text {
                                anchors.centerIn: parent
                                text: verifyBtn.checking ? (void i18n.revision, i18n.t("app_bootstrap.verify_checking", "Đang xác thực...")) : (void i18n.revision, i18n.t("app_bootstrap.verify_license_button", "Xác thực License"))
                                color: verifyBtn.btnEnabled ? "#FFFFFF" : "#94A3B8"
                                font.family: VfTheme.fontFamily
                                font.pixelSize: 12
                                font.weight: Font.DemiBold
                            }

                            MouseArea {
                                id: verifyMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: verifyBtn.btnEnabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                                enabled: verifyBtn.btnEnabled
                                onClicked: root.verifyRequested()
                            }
                        }

                    }

                    // Spacer
                    Item { Layout.fillHeight: true }

                    // Exit button
                    Rectangle {
                        Layout.fillWidth: true
                        height: 32
                        radius: 6
                        color: exitMouse.containsMouse ? "#FEE2E2" : "transparent"
                        border.color: exitMouse.containsMouse ? "#FECACA" : "#374151"
                        border.width: 1

                        Behavior on color { ColorAnimation { duration: 120 } }

                        Text {
                            anchors.centerIn: parent
                            text: (void i18n.revision, i18n.t("app_bootstrap.exit_button", "Thoát"))
                            color: exitMouse.containsMouse ? "#DC2626" : "#94A3B8"
                            font.family: VfTheme.fontFamily
                            font.pixelSize: 12
                            font.weight: Font.DemiBold
                        }

                        MouseArea {
                            id: exitMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.exitRequested()
                        }
                    }
                }
            }

            // ──────────────────────────────────────────────────────────────
            // VERTICAL DIVIDER (subtle line, single-box separator)
            // ──────────────────────────────────────────────────────────────
            Rectangle {
                Layout.preferredWidth: 1
                Layout.fillHeight: true
                Layout.topMargin: 28
                Layout.bottomMargin: 28
                color: "#1F2937"
            }

            // ──────────────────────────────────────────────────────────────
            // RIGHT HALF (status + stages + progress)
            // ──────────────────────────────────────────────────────────────
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 28
                    spacing: 14

                    // Status title
                    Text {
                        text: root.licenseBusy
                            ? (void i18n.revision, i18n.t("app_bootstrap.license_verifying", "Đang xác thực license..."))
                            : (root.statusTitle.length > 0 ? root.statusTitle : (void i18n.revision, i18n.t("app_bootstrap.bootstrapping", "Đang khởi động...")))
                        color: "#F1F5F9"
                        font.family: VfTheme.fontFamily
                        font.pixelSize: 18
                        font.weight: Font.Bold
                    }

                    Text {
                        Layout.fillWidth: true
                        text: root.statusSubtitle
                        color: "#64748B"
                        font.family: VfTheme.fontFamily
                        font.pixelSize: 12
                        visible: text.length > 0
                        wrapMode: Text.WordWrap
                    }

                    // Stages list (no nested bg — just spacing)
                    Item {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 220
                        clip: true

                        ColumnLayout {
                            anchors.fill: parent
                            spacing: 2

                            Repeater {
                                model: root.stages

                                delegate: Rectangle {
                                    Layout.fillWidth: true
                                    implicitHeight: 44
                                    radius: 6
                                    color: stageMouse.containsMouse ? "#1F2937" : "transparent"

                                    readonly property string stageState: String((modelData || {}).state || "pending")
                                    readonly property color stateColor: {
                                        switch (stageState) {
                                        case "ok":      return "#16A34A"
                                        case "running": return "#3B82F6"
                                        case "warn":    return "#D97706"
                                        case "error":   return "#DC2626"
                                        case "skip":    return "#94A3B8"
                                        default:        return "#CBD5E1"
                                        }
                                    }
                                    readonly property string stateLabel: {
                                        switch (stageState) {
                                        case "ok":      return "OK"
                                        case "running": return "Running"
                                        case "warn":    return "Warn"
                                        case "error":   return "Error"
                                        case "skip":    return "Skip"
                                        default:        return "Pending"
                                        }
                                    }

                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.leftMargin: 10
                                        anchors.rightMargin: 10
                                        spacing: 10

                                        // Status dot
                                        Rectangle {
                                            width: 10
                                            height: 10
                                            radius: 5
                                            color: parent.parent.stateColor

                                            SequentialAnimation on opacity {
                                                running: parent.parent.stageState === "running"
                                                loops: Animation.Infinite
                                                NumberAnimation { from: 1.0; to: 0.3; duration: 600 }
                                                NumberAnimation { from: 0.3; to: 1.0; duration: 600 }
                                            }
                                        }

                                        // Name + detail
                                        Column {
                                            Layout.fillWidth: true
                                            spacing: 1

                                            Text {
                                                text: String((modelData || {}).name || "")
                                                color: "#F1F5F9"
                                                font.family: VfTheme.fontFamily
                                                font.pixelSize: 13
                                                font.weight: Font.DemiBold
                                            }
                                            Text {
                                                text: String((modelData || {}).detail || "")
                                                color: "#94A3B8"
                                                font.family: VfTheme.fontFamily
                                                font.pixelSize: 11
                                                visible: text.length > 0
                                                elide: Text.ElideRight
                                                width: parent.width
                                            }
                                        }

                                        // State badge
                                        Rectangle {
                                            width: badgeText.implicitWidth + 10
                                            height: 18
                                            radius: 9
                                            color: Qt.rgba(
                                                parent.parent.stateColor.r,
                                                parent.parent.stateColor.g,
                                                parent.parent.stateColor.b,
                                                0.12
                                            )

                                            Text {
                                                id: badgeText
                                                anchors.centerIn: parent
                                                text: parent.parent.parent.stateLabel
                                                color: parent.parent.parent.stateColor
                                                font.family: VfTheme.fontFamily
                                                font.pixelSize: 10
                                                font.weight: Font.DemiBold
                                            }
                                        }
                                    }

                                    MouseArea {
                                        id: stageMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                    }
                                }
                            }

                            // Fill remaining space in stages box
                            Item { Layout.fillHeight: true }
                        }
                    }

                    // Progress bar
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 6
                        radius: 3
                        color: "#E0E7FF"
                        clip: true

                        Rectangle {
                            width: parent.width * Math.max(0, Math.min(100, root.progress)) / 100
                            height: parent.height
                            radius: 3
                            gradient: Gradient {
                                orientation: Gradient.Horizontal
                                GradientStop { position: 0.0; color: "#6366F1" }
                                GradientStop { position: 1.0; color: "#8B5CF6" }
                            }
                            Behavior on width { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
                        }
                    }

                    // Progress percent
                    Text {
                        Layout.alignment: Qt.AlignRight
                        text: root.progress + "%"
                        color: "#94A3B8"
                        font.family: VfTheme.fontFamily
                        font.pixelSize: 10
                    }

                    // Activity log — fills the void below progress so the right
                    // half matches the dense left half. Uses divider + section
                    // header style (same as DEVICE/LICENSE), no nested box.
                    Rectangle { Layout.fillWidth: true; Layout.topMargin: 4; height: 1; color: "#1F2937" }

                    Text {
                        text: "ACTIVITY"
                        color: "#64748B"
                        font.family: VfTheme.fontFamily
                        font.pixelSize: 10
                        font.weight: Font.Bold
                        font.letterSpacing: 1
                    }

                    Flickable {
                        id: activityFlick
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        contentHeight: activityLog.implicitHeight
                        clip: true
                        boundsBehavior: Flickable.StopAtBounds
                        // Auto-stick to newest line as the log grows.
                        onContentHeightChanged: contentY = Math.max(0, contentHeight - height)

                        Text {
                            id: activityLog
                            width: activityFlick.width
                            text: root.progressLog.length > 0
                                ? root.progressLog
                                : "Waiting for activity…"
                            color: "#94A3B8"
                            font.family: "Consolas"
                            font.pixelSize: 11
                            lineHeight: 1.3
                            wrapMode: Text.WordWrap
                        }
                    }

                    // Error box
                    Rectangle {
                        visible: root.bootstrapError.length > 0
                        Layout.fillWidth: true
                        implicitHeight: visible ? (errorRow.implicitHeight + 16) : 0
                        radius: 6
                        color: "#FEF2F2"
                        border.color: "#FECACA"

                        RowLayout {
                            id: errorRow
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 8

                            Text {
                                Layout.fillWidth: true
                                text: root.bootstrapError
                                color: "#991B1B"
                                font.family: VfTheme.fontFamily
                                font.pixelSize: 11
                                wrapMode: Text.WordWrap
                            }

                            // Update action button (when showUpdateAction)
                            Rectangle {
                                visible: root.showUpdateAction
                                width: 64
                                height: 26
                                radius: 6
                                color: updateMouse.containsMouse ? "#4F46E5" : "#6366F1"
                                Behavior on color { ColorAnimation { duration: 120 } }

                                Text {
                                    anchors.centerIn: parent
                                    text: "Update"
                                    color: "#FFFFFF"
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: 11
                                    font.weight: Font.DemiBold
                                }

                                MouseArea {
                                    id: updateMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: root.updateRequested()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
