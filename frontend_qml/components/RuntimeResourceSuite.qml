import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../theme"

Rectangle {
    id: root

    property bool compact: false
    signal repairRequested(string resourceId)

    readonly property var health: accountSettingsController ? (accountSettingsController.resourceHealth || ({})) : ({})
    readonly property bool busy: Boolean(health.checking) || String(health.repairingId || "").length > 0
    readonly property string overall: String(health.overall || "unchecked")
    readonly property color bannerFill: overall === "ready" ? VfTheme.greenFill
        : (overall === "error" ? VfTheme.redFill
        : (overall === "warning" || overall === "checking" ? VfTheme.amberFill : VfTheme.blueFill))
    readonly property color bannerText: overall === "ready" ? VfTheme.greenText
        : (overall === "error" ? VfTheme.redText
        : (overall === "warning" || overall === "checking" ? VfTheme.amberText : VfTheme.blueText))
    readonly property color headerFill: overall === "ready" ? "#059669"
        : (overall === "error" ? "#DC2626"
        : (overall === "warning" || overall === "checking" ? "#D97706" : VfTheme.primary))

    property bool extrasOpen: false

    Connections {
        target: accountSettingsController
        function onResourceHealthChanged() {
            if (Number(root.health.optionalBroken || 0) > 0)
                root.extrasOpen = true
        }
    }

    radius: VfTheme.radiusControl
    color: VfTheme.surface
    border.color: VfTheme.borderBox
    clip: true
    implicitHeight: suiteCol.implicitHeight

    function toneFill(tone) {
        if (tone === "green") return VfTheme.greenFill
        if (tone === "red") return VfTheme.redFill
        if (tone === "amber") return VfTheme.amberFill
        if (tone === "blue") return VfTheme.blueFill
        return VfTheme.surfaceSoft
    }
    function toneText(tone) {
        if (tone === "green") return VfTheme.greenText
        if (tone === "red") return VfTheme.redText
        if (tone === "amber") return VfTheme.amberText
        if (tone === "blue") return VfTheme.blueText
        return VfTheme.textMuted
    }
    function toneBorder(tone) {
        if (tone === "green") return VfTheme.greenBorderSoft
        if (tone === "red") return VfTheme.redBorderSoft
        if (tone === "amber") return VfTheme.amberBorderSoft
        if (tone === "blue") return VfTheme.blueBorderSoft
        return VfTheme.borderSoft
    }
    function toneDot(tone) {
        if (tone === "green") return "#22C55E"
        if (tone === "red") return "#EF4444"
        if (tone === "amber") return "#F59E0B"
        if (tone === "blue") return VfTheme.primary
        return VfTheme.textSubtle
    }
    function runRowAction(row) {
        var kind = String((row && row.action) || "")
        var rid = String((row && row.id) || "")
        if (!rid.length)
            return
        if (kind === "open" || rid === "storage") {
            accountSettingsController.openResourceFolder(rid)
            return
        }
        root.repairRequested(rid)
    }

    ColumnLayout {
        id: suiteCol
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 0

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: VfTheme.dp(38)
            color: root.headerFill

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: VfTheme.dp(14)
                anchors.rightMargin: VfTheme.dp(14)
                spacing: VfTheme.dp(8)

                Text {
                    Layout.fillWidth: true
                    text: (void i18n.revision, i18n.t("settings.resources_title", "Tài nguyên hệ thống"))
                    color: "#FFFFFF"
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.fontSection
                    font.weight: VfTheme.weightTitle
                    elide: Text.ElideRight
                }
                Text {
                    text: String(root.health.countText || "")
                    color: "#FFFFFF"
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.fontSmall
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.margins: VfTheme.dp(14)
            spacing: VfTheme.dp(12)

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: bannerRow.implicitHeight + VfTheme.dp(20)
                radius: VfTheme.radiusControl
                color: root.bannerFill
                border.color: root.toneBorder(root.overall === "ready" ? "green"
                    : (root.overall === "error" ? "red"
                    : (root.overall === "unchecked" ? "blue" : "amber")))

                RowLayout {
                    id: bannerRow
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: VfTheme.dp(12)
                    anchors.rightMargin: VfTheme.dp(12)
                    spacing: VfTheme.dp(12)

                    Rectangle {
                        Layout.preferredWidth: VfTheme.dp(36)
                        Layout.preferredHeight: VfTheme.dp(36)
                        radius: VfTheme.dp(10)
                        color: VfTheme.surface
                        VfAppIcon {
                            anchors.centerIn: parent
                            name: root.overall === "ready" ? "check-mark-button"
                                : (root.overall === "error" ? "red-triangle"
                                : (root.busy ? "clockwise-arrows" : "magnifying-glass"))
                            size: VfTheme.dp(18)
                            color: root.bannerText
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: VfTheme.dp(2)
                        Text {
                            Layout.fillWidth: true
                            text: String(root.health.headline || (void i18n.revision, i18n.t("settings.resources_unchecked_headline", "Chưa kiểm tra")))
                            color: root.bannerText
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.fontSection
                            font.weight: VfTheme.weightTitle
                            elide: Text.ElideRight
                        }
                        Text {
                            Layout.fillWidth: true
                            text: String(root.health.message || "")
                            color: VfTheme.text
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.fontControl
                            wrapMode: Text.WordWrap
                        }
                    }

                    VfButton {
                        text: root.busy
                            ? (void i18n.revision, i18n.t("common.working", "Working..."))
                            : (void i18n.revision, i18n.t("settings.resources_check_all", "Kiểm tra tất cả"))
                        tone: "primary"
                        compact: true
                        minWidth: VfTheme.dp(128)
                        enabled: !root.busy
                        actionId: "home.refresh"
                        onClicked: accountSettingsController.checkAllResources()
                    }
                    VfButton {
                        text: (void i18n.revision, i18n.t("settings.resources_open_folder", "Thư mục"))
                        compact: true
                        minWidth: VfTheme.dp(88)
                        enabled: !root.busy
                        actionId: "master.queue.open_folder"
                        onClicked: accountSettingsController.openResourceFolder("storage")
                    }
                }
            }

            ProgressBar {
                Layout.fillWidth: true
                visible: root.busy
                from: 0
                to: 100
                value: Number(root.health.progress || 0)
                indeterminate: value <= 0
            }

            GridLayout {
                Layout.fillWidth: true
                columns: root.compact ? 1 : 3
                columnSpacing: VfTheme.dp(10)
                rowSpacing: VfTheme.dp(10)

                Repeater {
                    model: accountSettingsController ? accountSettingsController.resourceFeaturedModel : 0
                    delegate: Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: VfTheme.dp(128)
                        radius: VfTheme.radiusControl
                        color: VfTheme.surface
                        border.width: 1
                        border.color: root.toneBorder(String(modelData.tone || "neutral"))

                        Rectangle {
                            width: VfTheme.dp(4)
                            height: parent.height
                            color: root.toneDot(String(modelData.tone || "neutral"))
                            radius: VfTheme.dp(2)
                        }

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.leftMargin: VfTheme.dp(16)
                            anchors.rightMargin: VfTheme.dp(12)
                            anchors.topMargin: VfTheme.dp(12)
                            anchors.bottomMargin: VfTheme.dp(12)
                            spacing: VfTheme.dp(8)

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: VfTheme.dp(10)

                                Rectangle {
                                    Layout.preferredWidth: VfTheme.dp(40)
                                    Layout.preferredHeight: VfTheme.dp(40)
                                    radius: VfTheme.dp(10)
                                    color: root.toneFill(String(modelData.tone || "neutral"))
                                    VfAppIcon {
                                        anchors.centerIn: parent
                                        name: String(modelData.icon || "gear")
                                        size: VfTheme.dp(20)
                                        color: root.toneText(String(modelData.tone || "neutral"))
                                    }
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 1
                                    Text {
                                        Layout.fillWidth: true
                                        text: String(modelData.shortTitle || modelData.title || "")
                                        color: VfTheme.text
                                        font.family: VfTheme.fontFamily
                                        font.pixelSize: VfTheme.fontSection
                                        font.weight: VfTheme.weightTitle
                                        elide: Text.ElideRight
                                    }
                                    Text {
                                        text: String(modelData.statusLabel || "")
                                        color: root.toneText(String(modelData.tone || "neutral"))
                                        font.family: VfTheme.fontFamily
                                        font.pixelSize: VfTheme.fontSmall
                                        font.weight: VfTheme.weightStrong
                                    }
                                }
                            }

                            Text {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                text: String(modelData.detail || modelData.purpose || "")
                                color: VfTheme.textMuted
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.fontControl
                                wrapMode: Text.WordWrap
                                maximumLineCount: 2
                                elide: Text.ElideRight
                                verticalAlignment: Text.AlignTop
                            }

                            VfButton {
                                visible: String(modelData.action || "") === "install" || String(modelData.action || "") === "repair"
                                    || String(modelData.action || "") === "restart"
                                    || (String(modelData.action || "") === "open" && String(modelData.status || "") !== "ready")
                                Layout.alignment: Qt.AlignLeft
                                compact: true
                                minWidth: VfTheme.dp(92)
                                enabled: !root.busy && !Boolean(modelData.busy)
                                tone: modelData.action === "repair" ? "danger" : (modelData.action === "install" || modelData.action === "restart" ? "primary" : "neutral")
                                text: String(modelData.actionLabel || "")
                                onClicked: root.runRowAction(modelData)
                            }
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: extrasHeader.height + (root.extrasOpen ? extrasList.implicitHeight + VfTheme.dp(8) : 0)
                radius: VfTheme.radiusControl
                color: VfTheme.surfaceSoft
                border.color: Number(root.health.optionalBroken || 0) > 0 ? VfTheme.amberBorderSoft : VfTheme.borderSoft
                clip: true

                ColumnLayout {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    spacing: 0

                    Item {
                        id: extrasHeader
                        Layout.fillWidth: true
                        height: VfTheme.dp(42)

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: VfTheme.dp(12)
                            anchors.rightMargin: VfTheme.dp(12)
                            spacing: VfTheme.dp(8)

                            VfAppIcon {
                                name: root.extrasOpen ? "chevron-down" : "chevron-right"
                                size: VfTheme.dp(14)
                                color: VfTheme.textMuted
                            }
                            Text {
                                Layout.fillWidth: true
                                text: (void i18n.revision, i18n.t("settings.resources_extras", "Gói tuỳ chọn"))
                                color: VfTheme.text
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.fontControl
                                font.weight: VfTheme.weightStrong
                            }
                            Text {
                                text: String(root.health.extrasLabel || "")
                                color: Number(root.health.optionalBroken || 0) > 0 ? VfTheme.amberText : VfTheme.textMuted
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.fontSmall
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.extrasOpen = !root.extrasOpen
                        }
                    }

                    ColumnLayout {
                        id: extrasList
                        Layout.fillWidth: true
                        visible: root.extrasOpen
                        spacing: 0

                        Repeater {
                            model: accountSettingsController ? accountSettingsController.resourceExtraModel : 0
                            delegate: Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: VfTheme.dp(48)
                                color: "transparent"

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: VfTheme.dp(12)
                                    anchors.rightMargin: VfTheme.dp(10)
                                    spacing: VfTheme.dp(10)

                                    Rectangle {
                                        Layout.preferredWidth: VfTheme.dp(28)
                                        Layout.preferredHeight: VfTheme.dp(28)
                                        radius: VfTheme.dp(8)
                                        color: root.toneFill(String(modelData.tone || "neutral"))
                                        VfAppIcon {
                                            anchors.centerIn: parent
                                            name: String(modelData.icon || "gear")
                                            size: VfTheme.dp(14)
                                            color: root.toneText(String(modelData.tone || "neutral"))
                                        }
                                    }
                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 0
                                        Text {
                                            Layout.fillWidth: true
                                            text: String(modelData.shortTitle || modelData.title || "")
                                            color: VfTheme.text
                                            font.family: VfTheme.fontFamily
                                            font.pixelSize: VfTheme.fontControl
                                            font.weight: VfTheme.weightStrong
                                            elide: Text.ElideRight
                                        }
                                        Text {
                                            Layout.fillWidth: true
                                            text: String(modelData.detail || modelData.purpose || "")
                                            color: VfTheme.textMuted
                                            font.family: VfTheme.fontFamily
                                            font.pixelSize: VfTheme.fontTiny
                                            elide: Text.ElideRight
                                        }
                                    }
                                    Text {
                                        text: String(modelData.statusLabel || "")
                                        color: root.toneText(String(modelData.tone || "neutral"))
                                        font.family: VfTheme.fontFamily
                                        font.pixelSize: VfTheme.fontTiny
                                        font.weight: VfTheme.weightStrong
                                    }
                                    VfButton {
                                        visible: String(modelData.action || "none") !== "none"
                                        compact: true
                                        minWidth: VfTheme.dp(80)
                                        enabled: !root.busy && !Boolean(modelData.busy)
                                        tone: modelData.action === "repair" ? "danger" : "primary"
                                        text: String(modelData.actionLabel || "")
                                        onClicked: root.runRowAction(modelData)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
