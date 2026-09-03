import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import "../theme"

Rectangle {
    id: root

    property string licenseStatus: (void i18n.revision, i18n.t("qml.header.license", "License"))
    property string browserHealthText: ""
    property string browserHealthTooltip: browserHealthText
    property string browserHealthTone: "neutral"
    property string creditsText: (void i18n.revision, i18n.t("qml.header.credits", "Credits"))
    property string creditsTooltip: creditsText
    property string consumedText: ""
    property string consumedTooltip: consumedText
    property bool updateBusy: false
    property string updateActionText: ""
    property bool automationCenterVisible: false
    readonly property int headerButtonWidth: root.width >= 1760 ? VfTheme.dp(108) : VfTheme.dp(100)
    readonly property real logoAspectRatio: 2123 / 492
    readonly property int headerLogoHeight: root.width >= 1500 ? VfTheme.dp(32) : VfTheme.dp(29)
    readonly property bool showResellerBlock: root.width >= 1040 && root.hasVerifiedReseller()
    // Single source for the logo block's minimum width — used BOTH by the logo
    // block itself and by actionsReservedWidth below. These two used to be
    // independent constants (dp(318) vs a dp(548) reserve that only left dp(266)
    // for the logo) and the mismatch starved the RowLayout: it overflowed to the
    // right and pushed the min/max/close caption buttons past the window edge on
    // 1040–1300px-wide screens with the reseller block visible.
    readonly property real logoBlockMinWidth: showResellerBlock ? VfTheme.dp(318) : VfTheme.dp(136)
    // Everything the actions Flickable must leave room for: logo minimum,
    // language combo, caption buttons, RowLayout margins dp(14+6) and the 4
    // inter-item spacings 4×dp(8). The Flickable is the ONLY squeeze absorber
    // (it scrolls), so its max width must never claim space from these.
    readonly property real actionsReservedWidth: logoBlockMinWidth
        + (root.width >= 1450 ? VfTheme.dp(118) : VfTheme.dp(92))
        + windowControls.implicitWidth
        + VfTheme.dp(52)

    signal mediaLibraryRequested()
    signal automationCenterRequested()
    signal styleManagerRequested()
    signal updateRequested()
    signal aboutRequested()
    signal guideRequested()
    signal autoGuideRequested()
    signal welcomeRequested()
    signal guideDialogPicked(string dialogId)

    // Guide-pick: Media Library / Manage Styles pulse and, when clicked, launch a
    // walkthrough INSIDE their dialog instead of the normal action.
    property bool guidePickActive: false
    property var guideDialogs: []

    function guideHas(id) {
        return root.guidePickActive && root.guideDialogs.indexOf(String(id || "")) >= 0
    }

    function licenseButtonTone() {
        var value = String(root.licenseStatus || "").toLowerCase()
        if (value.indexOf("active") >= 0 || value.indexOf("yearly") >= 0 || value.indexOf("monthly") >= 0 || value.indexOf("lifetime") >= 0)
            return "green"
        if (value.indexOf("expired") >= 0 || value.indexOf("invalid") >= 0 || value.indexOf("not verified") >= 0)
            return "danger"
        return "indigo"
    }

    // Nút license trong header = CỰC GỌN. Chi tiết đầy đủ (tier/expiry/features)
    // vẫn nằm trong tooltip + dialog About, nên nút chỉ cần báo trạng thái.
    function licenseButtonLabel() {
        var t = root.licenseButtonTone()
        if (t === "green") return "License Active"
        if (t === "danger") return "License Inactive"
        return "License"
    }

    function updateButtonText() {
        var action = String(root.updateActionText || "")
        if (!root.updateBusy)
            return (void i18n.revision, i18n.t("qml.header.update", "Update"))
        if (action === "update_download")
            return (void i18n.revision, i18n.t("qml.header.update_downloading", "Downloading"))
        if (action === "update_apply")
            return (void i18n.revision, i18n.t("qml.header.update_installing", "Installing"))
        return (void i18n.revision, i18n.t("qml.header.update_checking", "Checking"))
    }

    function reseller() {
        if (typeof headerController === "undefined" || !headerController || !headerController.summary)
            return ({})
        return headerController.summary.reseller || ({})
    }

    function hasVerifiedReseller() {
        var r = root.reseller()
        return Boolean(r && r.verified && (
            String(r.name || "").length
            || String(r.phone || "").length
            || String(r.zalo || "").length
            || String(r.website || "").length
            || String(r.contact_url || "").length
        ))
    }

    function resellerName() {
        var r = root.reseller()
        return String(r.name || r.display_name || "")
    }

    function resellerContactText() {
        var r = root.reseller()
        if (!r || !r.verified)
            return ""
        var parts = []
        if (String(r.phone || "").length)
            parts.push(r.phone)
        if (String(r.zalo || "").length)
            parts.push("Zalo: " + r.zalo)
        return parts.join(" · ")
    }

    function resellerWebText() {
        var r = root.reseller()
        if (!r || !r.verified)
            return ""
        if (String(r.website || "").length)
            return String(r.website)
        if (String(r.contact_url || "").length)
            return String(r.contact_url)
        if (String(r.email || "").length)
            return String(r.email)
        return ""
    }

    function resellerTooltip() {
        if (!root.hasVerifiedReseller())
            return ""
        var lines = [(void i18n.revision, i18n.t("header.verified_partner", "Đối tác xác minh"))]
        if (root.resellerName().length)
            lines.push(root.resellerName())
        if (root.resellerContactText().length)
            lines.push(root.resellerContactText())
        if (root.resellerWebText().length)
            lines.push(root.resellerWebText())
        return lines.join("\n")
    }

    component HeaderStatusBadge: Rectangle {
        id: badge

        property string text: ""
        property string tone: "neutral"
        property string tooltip: text
        property string iconName: ""
        property bool clickable: false
        property bool allowFullText: false
        property int minimumBadgeWidth: VfTheme.dp(108)
        property int maximumBadgeWidth: VfTheme.dp(220)
        signal clicked

        readonly property color badgeTextColor: {
            if (badge.tone === "green")
                return VfTheme.greenText
            if (badge.tone === "amber")
                return VfTheme.amberText
            if (badge.tone === "indigo")
                return VfTheme.indigoText
            if (badge.tone === "danger")
                return VfTheme.redText
            return VfTheme.textMuted
        }

        readonly property color badgeFillColor: {
            if (badge.tone === "green")
                return VfTheme.greenFill
            if (badge.tone === "amber")
                return VfTheme.amberFill
            if (badge.tone === "indigo")
                return VfTheme.violetFill
            if (badge.tone === "danger")
                return VfTheme.redFill
            return VfTheme.surface
        }

        readonly property color badgeBorderColor: {
            if (badge.tone === "green")
                return VfTheme.greenBorderSoft
            if (badge.tone === "amber")
                return VfTheme.amberBorderSoft
            if (badge.tone === "indigo")
                return VfTheme.indigoBorderSoft
            if (badge.tone === "danger")
                return VfTheme.redBorderSoft
            return VfTheme.borderBox
        }

        readonly property int naturalBadgeWidth: Math.ceil(
            VfTheme.dp(18)
            + badgeText.implicitWidth
            + (badgeIcon.visible ? VfTheme.headerIconSize + VfTheme.dp(6) : 0)
        )

        implicitWidth: allowFullText
            ? Math.max(minimumBadgeWidth, naturalBadgeWidth)
            : Math.min(maximumBadgeWidth, Math.max(minimumBadgeWidth, naturalBadgeWidth))
        implicitHeight: VfTheme.toolbarButtonHeight
        radius: VfTheme.radiusControl
        color: badgeFillColor
        border.width: 1
        border.color: badgeBorderColor

        Row {
            id: badgeContent
            anchors.centerIn: parent
            spacing: badgeIcon.visible ? 6 : 0

            VfAppIcon {
                id: badgeIcon
                name: badge.iconName
                size: VfTheme.headerIconSize
                framed: false
                color: badge.badgeTextColor
                visible: badge.iconName.length > 0
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                id: badgeText

                width: badge.allowFullText
                    ? implicitWidth
                    : Math.max(0, badge.width - VfTheme.dp(18) - (badgeIcon.visible ? VfTheme.headerIconSize + VfTheme.dp(6) : 0))
                text: badge.text
                color: badge.badgeTextColor
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontControl
                font.weight: VfTheme.weightStrong
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                maximumLineCount: 1
                elide: badge.allowFullText ? Text.ElideNone : Text.ElideRight
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        ToolTip.visible: badgeMouse.containsMouse && badge.tooltip.length > 0
        ToolTip.text: badge.tooltip
        ToolTip.delay: 450

        MouseArea {
            id: badgeMouse
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: badge.clickable ? Qt.LeftButton : Qt.NoButton
            cursorShape: badge.clickable ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: badge.clicked()
        }
    }

    component HeaderActionGroup: Rectangle {
        id: actionGroup

        default property alias content: actionGroupRow.data
        property color fillColor: VfTheme.surface
        property color strokeColor: VfTheme.borderBox

        implicitWidth: actionGroupRow.implicitWidth + 10
        implicitHeight: VfTheme.toolbarButtonHeight + 6
        radius: VfTheme.radiusControl
        color: fillColor
        border.width: 1
        border.color: strokeColor

        Row {
            id: actionGroupRow
            anchors.centerIn: parent
            spacing: VfTheme.dp(4)
            height: VfTheme.toolbarButtonHeight
        }
    }

    // Pulsing border used to flag a header button as guidable in guide-pick mode
    // (mirrors the tab-strip pulse). Overlay child of the target button.
    component GuidePulse: Rectangle {
        id: pulse
        property bool active: false
        anchors.fill: parent
        z: 5
        radius: VfTheme.radiusControl
        color: "transparent"
        border.width: 2
        border.color: VfTheme.primary
        visible: pulse.active
        SequentialAnimation on opacity {
            running: pulse.active && VfTheme.motion
            loops: Animation.Infinite
            NumberAnimation { from: 1.0; to: 0.3; duration: 620; easing.type: Easing.InOutQuad }
            NumberAnimation { from: 0.3; to: 1.0; duration: 620; easing.type: Easing.InOutQuad }
        }
    }

    // Themed row for the "Trợ giúp" dropdown: app-icon (SVG) + label, with a soft
    // highlight — so the menu reads as a proper dropdown, not the raw default.
    component HelpMenuItem: MenuItem {
        id: helpItem
        property string glyph: ""
        implicitHeight: VfTheme.dp(36)
        leftPadding: VfTheme.dp(12)
        rightPadding: VfTheme.dp(18)

        contentItem: Row {
            spacing: VfTheme.dp(10)
            VfAppIcon {
                name: helpItem.glyph
                size: VfTheme.dp(17)
                framed: false
                anchors.verticalCenter: parent.verticalCenter
            }
            Text {
                text: helpItem.text
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontControl
                font.weight: VfTheme.weightControl
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        background: Rectangle {
            radius: VfTheme.dp(7)
            color: helpItem.highlighted ? VfTheme.blueFill : "transparent"
        }
    }

    Layout.fillWidth: true
    Layout.preferredHeight: VfTheme.dp(54)
    color: VfTheme.canvas
    border.color: "transparent"

    // Bottom border separator — visible frame line
    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 1
        color: VfTheme.border
        z: 2
    }

    // === LAYER 0: Native drag handle (behind all controls) ===
    MouseArea {
        anchors.fill: parent
        z: 0
        acceptedButtons: Qt.LeftButton
        cursorShape: Qt.ArrowCursor

        property point pressPos
        property bool dragging: false

        onPressed: function(mouse) {
            pressPos = Qt.point(mouse.x, mouse.y)
            dragging = false
        }
        onPositionChanged: function(mouse) {
            if (!dragging && (Math.abs(mouse.x - pressPos.x) > 3 || Math.abs(mouse.y - pressPos.y) > 3)) {
                dragging = true
                if (window.visibility === Window.Maximized)
                    window.showNormal()
                if (typeof window.startSystemMove === "function")
                    window.startSystemMove()
            }
        }
        onDoubleClicked: {
            if (window.visibility === Window.Maximized)
                window.showNormal()
            else
                window.showMaximized()
        }
    }

    // === LAYER 1: Main header content (foreground) ===
    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: VfTheme.dp(14)
        anchors.rightMargin: VfTheme.dp(6)
        spacing: VfTheme.dp(8)
        z: 1

        RowLayout {
            Layout.preferredWidth: root.showResellerBlock
                ? (root.width >= 1500 ? VfTheme.dp(430) : VfTheme.dp(370))
                : (root.width >= 1500 ? VfTheme.dp(168) : VfTheme.dp(148))
            Layout.minimumWidth: root.logoBlockMinWidth
            Layout.alignment: Qt.AlignVCenter
            spacing: VfTheme.dp(10)

            Image {
                Layout.preferredWidth: Math.round(root.headerLogoHeight * root.logoAspectRatio)
                Layout.preferredHeight: root.headerLogoHeight
                Layout.maximumWidth: root.width >= 1500 ? VfTheme.dp(150) : VfTheme.dp(136)
                source: Qt.resolvedUrl("../../resources/brand/veoflow-logo-imagine-veo-blue-header.png")
                fillMode: Image.PreserveAspectFit
                horizontalAlignment: Image.AlignLeft
                verticalAlignment: Image.AlignVCenter
                smooth: true
                asynchronous: true
                sourceSize.width: 380
                sourceSize.height: 84
            }

            ColumnLayout {
                visible: root.showResellerBlock
                Layout.fillWidth: true
                Layout.minimumWidth: 0
                Layout.alignment: Qt.AlignVCenter
                spacing: 0

                Text {
                    text: (void i18n.revision, i18n.t("header.verified_partner", "Đối tác xác minh"))
                    color: VfTheme.greenText
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(8)
                    font.weight: Font.Bold
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                    ToolTip.visible: resellerHover.hovered
                    ToolTip.text: root.resellerTooltip()
                }

                Text {
                    text: root.resellerName()
                    color: VfTheme.text
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(10)
                    font.weight: Font.DemiBold
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                    ToolTip.visible: resellerHover.hovered
                    ToolTip.text: root.resellerTooltip()
                }

                Text {
                    text: {
                        var contact = root.resellerContactText()
                        var web = root.resellerWebText()
                        if (contact.length && web.length)
                            return contact + " · " + web
                        return contact || web
                    }
                    visible: text.length > 0
                    color: VfTheme.textMuted
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(8)
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                    ToolTip.visible: resellerHover.hovered
                    ToolTip.text: root.resellerTooltip()
                }
            }

            HoverHandler {
                id: resellerHover
                enabled: root.showResellerBlock
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.minimumWidth: 0
            visible: root.width >= 980
        }

        ComboBox {
            id: languageCombo

            Layout.preferredWidth: root.width >= 1450 ? VfTheme.dp(118) : VfTheme.dp(92)
            Layout.preferredHeight: VfTheme.dp(32)
            model: [
                { label: "English", locale: "en" },
                { label: "Vietnamese", locale: "vi" }
            ]
            textRole: "label"
            valueRole: "locale"
            currentIndex: i18n.locale === "vi" ? 1 : 0
            visible: root.width >= 980
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.fontControl

            onActivated: {
                i18n.setLocale(languageCombo.currentValue)
                if (typeof headerController !== "undefined" && headerController.refresh)
                    headerController.refresh()
            }

            contentItem: Text {
                leftPadding: VfTheme.dp(9)
                rightPadding: VfTheme.dp(18)
                text: languageCombo.displayText
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontControl
                font.weight: VfTheme.weightControl
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }

            background: Rectangle {
                radius: VfTheme.dp(7)
                color: VfTheme.surface
                border.color: languageCombo.activeFocus ? VfTheme.primary : VfTheme.borderStrong
            }

            indicator: Text {
                x: languageCombo.width - width - 8
                anchors.verticalCenter: parent.verticalCenter
                text: "v"
                color: VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(10)
                font.weight: VfTheme.weightStrong
            }

            delegate: ItemDelegate {
                width: languageCombo.width
                height: VfTheme.dp(28)

                contentItem: Text {
                    text: modelData.label
                    color: VfTheme.text
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(11)
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }
            }

            popup: Popup {
                // Defensive pin (no-op on the Basic style, default is already
                // Popup.Item) — see VfSelectField.qml for the full story.
                popupType: Popup.Item
                y: languageCombo.height + 4
                width: languageCombo.width
                padding: 4
                background: Rectangle {
                    color: VfTheme.surface
                    border.color: VfTheme.border
                    border.width: 1
                    radius: 6
                }
                contentItem: ListView { // perf-lint: disable=R1  static 2-item language dropdown
                    clip: true
                    implicitHeight: contentHeight
                    model: languageCombo.delegateModel
                    currentIndex: languageCombo.highlightedIndex
                }
            }

            Connections {
                target: i18n
                function onLocaleChanged() {
                    languageCombo.currentIndex = i18n.locale === "vi" ? 1 : 0
                }
            }
        }

        Flickable {
            id: headerActionsFlickable

            Layout.fillWidth: false
            Layout.minimumWidth: 0
            // Width budget comes from actionsReservedWidth (see root) — NOT a hand
            // constant. The dp(340) floor is safe: with the reserve it only binds
            // below the 980px visibility cutoff, so it can no longer force overflow.
            Layout.preferredWidth: Math.min(headerActions.implicitWidth, Math.max(VfTheme.dp(340), root.width - root.actionsReservedWidth))
            Layout.maximumWidth: Math.max(VfTheme.dp(340), root.width - root.actionsReservedWidth)
            Layout.preferredHeight: VfTheme.dp(40)
            visible: root.width >= 980
            contentWidth: headerActions.implicitWidth
            contentHeight: height
            boundsBehavior: Flickable.StopAtBounds
            clip: true
            flickableDirection: Flickable.HorizontalFlick
            interactive: contentWidth > width

            Row {   // perf-lint: disable=R5  bounded: lives in a horizontal-scroll Flickable
                id: headerActions
                x: Math.max(0, headerActionsFlickable.width - implicitWidth)
                y: Math.round((headerActionsFlickable.height - implicitHeight) / 2)
                spacing: VfTheme.dp(2)

                // Independent borderless buttons on one invisible row — no group
                // boxes. Each sizes to its content; the row scrolls in the
                // Flickable when space is tight (ordered, responsive).

                // Consolidated "Help" menu — folds Guide / Wiki / YouTube / About
                // into one entry so the header stays uncrowded.
                HeaderToolButton {
                    actionId: "header.help"
                    tone: "indigo"
                    iconName: "light-bulb"
                    text: (void i18n.revision, i18n.t("qml.header.help", "Trợ giúp"))
                    tooltip: (void i18n.revision, i18n.t("qml.header.help_tooltip", "Hướng dẫn · Wiki · YouTube · Giới thiệu"))
                    onClicked: helpMenu.popup()
                }

                HeaderToolButton {
                    actionId: "header.automation_center"
                    visible: root.automationCenterVisible
                    tone: "blue"
                    text: (void i18n.revision, i18n.t("qml.header.automation_center", "Automation Center"))
                    tooltip: (void i18n.revision, i18n.t("qml.header.automation_center_tooltip", "Mở tab Automation Center"))
                    onClicked: root.automationCenterRequested()
                }

                HeaderToolButton {
                    actionId: "header.media_library"
                    text: (void i18n.revision, i18n.t("qml.header.media_library", "Media Library"))
                    tooltip: (void i18n.revision, i18n.t("qml.header.media_library_tooltip", "Open media manager"))
                    onClicked: {
                        if (root.guideHas("media_library"))
                            root.guideDialogPicked("media_library")
                        else
                            root.mediaLibraryRequested()
                    }
                    GuidePulse { active: root.guideHas("media_library") }
                }

                HeaderToolButton {
                    actionId: "header.style_manager"
                    text: (void i18n.revision, i18n.t("qml.header.manage_styles", "Manage Styles"))
                    tooltip: (void i18n.revision, i18n.t("qml.header.manage_styles_tooltip", "Open style manager"))
                    onClicked: {
                        if (root.guideHas("style_manager"))
                            root.guideDialogPicked("style_manager")
                        else
                            root.styleManagerRequested()
                    }
                    GuidePulse { active: root.guideHas("style_manager") }
                }

                HeaderToolButton {
                    actionId: "header.update"
                    tone: root.updateBusy ? "blue" : "neutral"
                    text: root.updateButtonText()
                    enabled: !root.updateBusy
                    tooltip: root.updateBusy
                        ? (void i18n.revision, i18n.t("qml.header.update_busy", "Update is running"))
                        : (void i18n.revision, i18n.t("qml.header.update_tooltip", "Check for updates"))
                    onClicked: root.updateRequested()
                }

                HeaderToolButton {
                    actionId: "header.license"
                    text: root.licenseButtonLabel()
                    tone: root.licenseButtonTone()
                    tooltip: root.licenseStatus
                    onClicked: headerController.openDialog("about")
                }

                HeaderToolButton {
                    iconName: (typeof appController !== "undefined" && appController.darkMode) ? "sun" : "crescent-moon"
                    text: ""
                    tone: "neutral"
                    anchors.verticalCenter: parent.verticalCenter
                    tooltip: (typeof appController !== "undefined" && appController.darkMode)
                        ? (void i18n.revision, i18n.t("qml.header.light_mode", "Chế độ sáng"))
                        : (void i18n.revision, i18n.t("qml.header.dark_mode", "Chế độ tối"))
                    onClicked: {
                        if (typeof appController !== "undefined")
                            appController.setDarkMode(!appController.darkMode)
                    }
                }

            }
        }

        // Native caption buttons (min / max / close) — pinned OUTSIDE the
        // scrolling action row so they are NEVER clipped when the tool buttons
        // overflow (that was the min/max/X cut-off). Always visible.
        Row {
            id: windowControls
            spacing: 0
            Layout.alignment: Qt.AlignVCenter
            // Guard only: a non-fill Row is never compressed by the layout (verified
            // empirically) — the real clipping was the layout OVERFLOWING because the
            // Flickable's width formula under-reserved space (fixed via
            // actionsReservedWidth on root). This pin just keeps the buttons
            // uncompressible if someone later makes this row fill-able.
            Layout.minimumWidth: implicitWidth

            // Minimize
            Rectangle {
                id: minBtn
                width: VfTheme.dp(46)
                height: VfTheme.dp(32)
                color: minMouse.containsMouse ? VfTheme.surfaceSoft : "transparent"
                Behavior on color { ColorAnimation { duration: 120 } }

                // Drawn shape, NOT a font glyph — frameless caption buttons must not
                // depend on a symbol glyph being present in the packaged build's font
                // fallback (that is why "□"/"✕" vanished in the shipped exe while "—" survived).
                Rectangle {
                    anchors.centerIn: parent
                    width: VfTheme.dp(11)
                    height: Math.max(1, VfTheme.dp(1))
                    radius: height / 2
                    color: minMouse.containsMouse ? VfTheme.text : VfTheme.textMuted
                    Behavior on color { ColorAnimation { duration: 120 } }
                }

                MouseArea {
                    id: minMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: window.showMinimized()
                }
            }

            // Maximize / Restore
            Rectangle {
                id: maxBtn
                width: VfTheme.dp(46)
                height: VfTheme.dp(32)
                color: maxMouse.containsMouse ? VfTheme.surfaceSoft : "transparent"
                Behavior on color { ColorAnimation { duration: 120 } }

                // Square outline (drawn, font-independent). When maximized, a second
                // offset square hints "restore".
                Item {
                    anchors.centerIn: parent
                    width: VfTheme.dp(11)
                    height: VfTheme.dp(11)
                    readonly property color glyph: maxMouse.containsMouse ? VfTheme.text : VfTheme.textMuted
                    readonly property bool maxed: window.visibility === Window.Maximized

                    Rectangle {   // back square — only in restore state
                        visible: parent.maxed
                        width: VfTheme.dp(8)
                        height: VfTheme.dp(8)
                        x: parent.width - width
                        y: 0
                        color: "transparent"
                        border.width: Math.max(1, VfTheme.dp(1))
                        border.color: parent.glyph
                    }
                    Rectangle {   // front square
                        width: VfTheme.dp(8)
                        height: VfTheme.dp(8)
                        x: parent.maxed ? 0 : (parent.width - width) / 2
                        y: parent.maxed ? parent.height - height : (parent.height - height) / 2
                        color: parent.maxed ? VfTheme.surface : "transparent"
                        border.width: Math.max(1, VfTheme.dp(1))
                        border.color: parent.glyph
                    }
                }

                MouseArea {
                    id: maxMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: window.visibility === Window.Maximized ? window.showNormal() : window.showMaximized()
                }
            }

            // Close
            Rectangle {
                id: closeBtn
                width: VfTheme.dp(46)
                height: VfTheme.dp(32)
                color: closeMouse.containsMouse ? "#E81123" : "transparent"
                Behavior on color { ColorAnimation { duration: 120 } }

                // X drawn as two crossed bars (font-independent).
                Item {
                    anchors.centerIn: parent
                    width: VfTheme.dp(11)
                    height: VfTheme.dp(11)
                    Rectangle {
                        anchors.centerIn: parent
                        width: VfTheme.dp(14)
                        height: Math.max(1, VfTheme.dp(1))
                        radius: height / 2
                        rotation: 45
                        color: closeMouse.containsMouse ? "#FFFFFF" : VfTheme.textMuted
                        Behavior on color { ColorAnimation { duration: 120 } }
                    }
                    Rectangle {
                        anchors.centerIn: parent
                        width: VfTheme.dp(14)
                        height: Math.max(1, VfTheme.dp(1))
                        radius: height / 2
                        rotation: -45
                        color: closeMouse.containsMouse ? "#FFFFFF" : VfTheme.textMuted
                        Behavior on color { ColorAnimation { duration: 120 } }
                    }
                }

                MouseArea {
                    id: closeMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: window.close()
                }
            }
        }

    }

    // "Trợ giúp" dropdown — folds the docs/help entries. Popped from the header
    // "?" button. Styled to match the app surface (rounded, bordered, soft
    // highlight) instead of the raw default menu chrome.
    Menu {
        id: helpMenu
        implicitWidth: VfTheme.dp(236)
        padding: VfTheme.dp(6)
        overlap: 0

        background: Rectangle {
            implicitWidth: VfTheme.dp(236)
            color: VfTheme.surface
            border.color: VfTheme.border
            border.width: 1
            radius: VfTheme.dp(10)
        }

        HelpMenuItem {
            text: (void i18n.revision, i18n.t("qml.header.guide_auto", "Hướng dẫn đầy đủ (tự động)"))
            glyph: "rocket"
            onTriggered: root.autoGuideRequested()
        }
        HelpMenuItem {
            text: (void i18n.revision, i18n.t("qml.header.guide_pick", "Hướng dẫn từng tab"))
            glyph: "magic-wand"
            onTriggered: root.guideRequested()
        }
        HelpMenuItem {
            text: (void i18n.revision, i18n.t("qml.header.guide_welcome", "Xem lại lời chào"))
            glyph: "light-bulb"
            onTriggered: root.welcomeRequested()
        }
        MenuSeparator {
            padding: VfTheme.dp(6)
            contentItem: Rectangle { implicitHeight: 1; color: VfTheme.border }
        }
        HelpMenuItem {
            text: "Wiki"
            glyph: "notebook"
            onTriggered: { if (typeof nativeShell !== "undefined") nativeShell.openExternal("https://veoflow.dev/docs") }
        }
        HelpMenuItem {
            text: "YouTube"
            glyph: "movie-camera"
            onTriggered: { if (typeof nativeShell !== "undefined") nativeShell.openExternal("https://www.youtube.com/@veoflowdotdev") }
        }
        MenuSeparator {
            padding: VfTheme.dp(6)
            contentItem: Rectangle { implicitHeight: 1; color: VfTheme.border }
        }
        HelpMenuItem {
            text: (void i18n.revision, i18n.t("qml.header.about", "Giới thiệu"))
            glyph: "star"
            onTriggered: root.aboutRequested()
        }
    }

}
