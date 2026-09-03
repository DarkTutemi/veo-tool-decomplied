import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../theme"
import "MediaSourceResolver.js" as MediaSourceResolver

Rectangle {
    id: root

    property var media: ({})
    property bool selected: false
    property int cardWidth: 168
    property int cardHeight: 216
    property bool loadImage: true
    // Active library filter tab. When it's a concrete type, the per-card type
    // dropdown is locked (view-only) — you can only re-type from the "All" tab.
    property string filterType: ""
    property bool managementMode: true
    readonly property bool typeLocked: !root.managementMode || ["character", "object", "setting", "background", "product"].indexOf(root.filterType) >= 0
    readonly property string resolvedImageSource: root.loadImage ? root.imageSource(root.media) : ""
    property var typeOptions: [
        { label: (void i18n.revision, i18n.t("qml.media_library.type_unset", "Not set")), value: "" },
        { label: (void i18n.revision, i18n.t("qml.media_library.type_character", "Character")), value: "character" },
        { label: (void i18n.revision, i18n.t("qml.media_library.type_object", "Object")), value: "object" },
        { label: (void i18n.revision, i18n.t("qml.media_library.type_setting", "Setting")), value: "setting" },
        { label: (void i18n.revision, i18n.t("qml.media_library.type_background", "Background")), value: "background" },
        { label: (void i18n.revision, i18n.t("qml.media_library.type_product", "Product")), value: "product" }
    ]

    signal clicked(var media)
    signal doubleClicked(var media)
    signal editRequested(var media)
    signal renameRequested(var media)
    signal previewRequested(var media)
    signal openRequested(var media)
    signal removeRequested(var media)
    signal typeChanged(var media, string assetType)

    function thumbSource(item) {
        return MediaSourceResolver.imageSource(item || ({}))
    }

    function dataImageMime(raw, item) {
        return MediaSourceResolver.dataImageMime(raw, item || ({}))
    }

    function dataImageUrl(raw, item) {
        return MediaSourceResolver.dataImageUrl(raw, item || ({}))
    }

    function fileUrl(value) {
        return MediaSourceResolver.localFileUrl(value)
    }

    function imageSource(item) {
        return MediaSourceResolver.imageSource(item || ({}))
    }

    function mediaId() {
        return String(root.media.id || root.media.media_id || "")
    }

    function aiMeta() {
        return root.media.ai_metadata || ({})
    }

    function assetType() {
        var meta = root.aiMeta()
        return String(root.media.asset_type || meta.asset_type || "")
    }

    function typeIndex(value) {
        var needle = String(value || "")
        var options = root.typeOptions || []
        for (var i = 0; i < options.length; i++) {
            if (String(options[i].value) === needle)
                return i
        }
        return 0
    }

    function typeColor(value) {
        var key = String(value || "")
        if (key === "character")
            return "#8B5CF6"
        if (key === "object")
            return "#F59E0B"
        if (key === "setting")
            return "#10B981"
        if (key === "background")
            return "#0EA5E9"
        if (key === "product")
            return "#EF4444"
        return VfTheme.textSubtle
    }

    function typeBgColor(value) {
        var key = String(value || "")
        if (key === "character")
            return VfTheme.violetFill
        if (key === "object")
            return VfTheme.amberFill
        if (key === "setting")
            return VfTheme.greenFill
        if (key === "background")
            return VfTheme.cyanFill
        if (key === "product")
            return VfTheme.redFill
        return VfTheme.surfaceSoft
    }

    function typeIconName(value) {
        var key = String(value || "")
        if (key === "character")
            return "busts-in-silhouette"
        if (key === "object")
            return "package"
        if (key === "setting")
            return "gear"
        if (key === "background")
            return "framed-picture"
        if (key === "product")
            return "shopping-bags"
        return "empty-box"
    }

    function uploadCount() {
        if (root.media.active_uploaded_count !== undefined)
            return Number(root.media.active_uploaded_count || 0)
        var ids = root.media.veo3_media_ids || ({})
        var count = 0
        for (var key in ids) {
            if (ids[key])
                count += 1
        }
        if (String(root.media.veo3_media_id || "").length > 0)
            count += 1
        return count
    }

    function isAnalyzed() {
        return Boolean(root.aiMeta().analyzed || root.media.analyzed)
    }

    function boundVoice() {
        var direct = root.media.bound_voice || root.media.flow_voice || root.media.flowVoice || null
        if (direct && typeof direct === "object" && Object.keys(direct).length > 0)
            return direct
        var meta = root.aiMeta()
        var structure = (meta && typeof meta.structure === "object") ? meta.structure : ({})
        var fv = structure.flow_voice || structure.flowVoice || null
        if (fv && typeof fv === "object" && Object.keys(fv).length > 0)
            return fv
        if (Boolean(root.media.has_bound_voice))
            return { name: String(root.media.bound_voice_label || "Voice") }
        return null
    }

    function hasBoundVoice() {
        return Boolean(root.media.has_bound_voice) || root.boundVoice() !== null
    }

    function boundVoiceLabel() {
        if (String(root.media.bound_voice_label || "").length > 0)
            return String(root.media.bound_voice_label)
        var fv = root.boundVoice() || {}
        return String(fv.name || fv.base_voice || fv.baseVoice || fv.speaker || "Voice")
    }

    function isUploaded() {
        if (root.media.uploaded !== undefined)
            return Boolean(root.media.uploaded)
        return root.uploadCount() > 0
    }

    function policyViolated() {
        return Boolean(root.media.policy_violated)
    }

    function analyzeBadgeText() {
        return root.isAnalyzed()
            ? (void i18n.revision, i18n.t("media_library.status_analyzed", "Analyzed"))
            : (void i18n.revision, i18n.t("media_library.status_not_analyzed", "Not analyzed"))
    }

    function uploadBadgeText() {
        if (root.policyViolated())
            return (void i18n.revision, i18n.t("media_library.status_policy_violated", "Policy"))
        var state = String(root.media.upload_state || "")
        var active = Number(root.media.active_uploaded_count || 0)
        var required = Number(root.media.required_account_count || 0)
        if (state === "no_accounts")
            return (void i18n.revision, i18n.t("media_library.status_no_account", "No account"))
        if (state === "partial")
            return (void i18n.revision, i18n.t("media_library.status_upload_partial", "Upload {count}")).replace("{count}", active + "/" + required)
        if (state === "stale")
            return (void i18n.revision, i18n.t("media_library.status_stale_upload", "Stale cache"))
        if (state === "uploaded" || root.isUploaded())
            return (void i18n.revision, i18n.t("media_library.status_uploaded", "Uploaded"))
        return (void i18n.revision, i18n.t("media_library.status_not_uploaded", "Not uploaded"))
    }

    function uploadBadgeBg() {
        if (root.policyViolated())
            return "#DC2626"
        var state = String(root.media.upload_state || "")
        if (state === "uploaded")
            return "#2563EB"
        if (state === "partial")
            return "#D97706"
        if (state === "stale")
            return VfTheme.textSubtle
        return VfTheme.textSubtle
    }

    implicitWidth: root.cardWidth
    implicitHeight: root.cardHeight
    radius: VfTheme.dp(8)
    color: mouse.containsMouse ? VfTheme.surfaceSoft : VfTheme.surface
    border.color: root.selected ? VfTheme.primary : VfTheme.border
    border.width: root.selected ? 2 : 1
    clip: true

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked(root.media)
        onDoubleClicked: root.doubleClicked(root.media)
        // Pass wheel events up to the parent ScrollView so it can scroll
        onWheel: wheel => { wheel.accepted = false }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: VfTheme.dp(5)
        spacing: VfTheme.dp(3)

        Rectangle {
            id: thumbnailFrame
            Layout.preferredWidth: root.cardWidth - 10
            Layout.preferredHeight: root.hasBoundVoice() ? VfTheme.dp(104) : VfTheme.dp(118)
            Layout.alignment: Qt.AlignHCenter
            radius: VfTheme.dp(6)
            color: VfTheme.surfaceSoft
            clip: true

            Image {
                id: thumbImg
                anchors.fill: parent
                source: root.resolvedImageSource
                fillMode: Image.PreserveAspectFit
                asynchronous: true
                sourceSize.width: 260
                sourceSize.height: 200
                visible: source.toString().length > 0 && status !== Image.Error
            }

            // Placeholder when no image source
            Text {
                anchors.centerIn: parent
                visible: root.loadImage && root.resolvedImageSource.length === 0
                text: (void i18n.revision, i18n.t("qml.media_library.no_image", "No image"))
                color: VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontSmall
                font.weight: VfTheme.weightStrong
            }

            // Placeholder when image source exists but file is missing/broken
            Rectangle {
                anchors.fill: parent
                visible: root.loadImage && root.resolvedImageSource.length > 0 && thumbImg.status === Image.Error
                color: VfTheme.surfaceSoft
                radius: VfTheme.dp(6)

                Column {
                    anchors.centerIn: parent
                    spacing: VfTheme.dp(4)

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "?"
                        color: VfTheme.borderStrong
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.dp(28)
                        font.weight: Font.Bold
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: (void i18n.revision, i18n.t("qml.media_library.file_missing", "File missing"))
                        color: VfTheme.textSubtle
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.dp(10)
                    }
                }
            }

            Row {
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.topMargin: VfTheme.dp(3)
                anchors.rightMargin: VfTheme.dp(3)
                spacing: VfTheme.dp(3)

                OverlayBadgeButton {
                    iconName: "magnifying-glass"
                    tooltip: "Preview large image"
                    bg: Qt.rgba(59 / 255, 130 / 255, 246 / 255, 0.90)
                    hoverBg: Qt.rgba(37 / 255, 99 / 255, 235 / 255, 1.00)
                    onClicked: root.previewRequested(root.media)
                }

                OverlayBadgeButton {
                    iconName: "memo"
                    tooltip: "Rename"
                    bg: Qt.rgba(16 / 255, 185 / 255, 129 / 255, 0.90)
                    hoverBg: Qt.rgba(5 / 255, 150 / 255, 105 / 255, 1.00)
                    visible: root.managementMode
                    onClicked: root.renameRequested(root.media)
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: root.managementMode ? VfTheme.dp(16) : 0
            visible: root.managementMode
            spacing: VfTheme.dp(3)

            StatusBadge {
                Layout.fillWidth: true
                text: root.analyzeBadgeText()
                bg: root.isAnalyzed() ? "#8B5CF6" : VfTheme.textSubtle
            }

            StatusBadge {
                Layout.fillWidth: true
                text: root.uploadBadgeText()
                bg: root.uploadBadgeBg()
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: root.hasBoundVoice() ? VfTheme.dp(17) : 0
            visible: root.hasBoundVoice()
            radius: VfTheme.dp(5)
            color: VfTheme.violetFill
            border.color: VfTheme.violetBorderSoft
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: VfTheme.dp(6)
                anchors.rightMargin: VfTheme.dp(6)
                spacing: VfTheme.dp(4)

                VfAppIcon {
                    Layout.preferredWidth: VfTheme.dp(11)
                    Layout.preferredHeight: VfTheme.dp(11)
                    name: "studio-microphone"
                    size: VfTheme.dp(11)
                    framed: false
                    color: "#7C3AED"
                }

                Text {
                    Layout.fillWidth: true
                    text: (void i18n.revision, i18n.t("media_library.voice_bound_short", "Voice")) + ": " + root.boundVoiceLabel()
                    color: "#6D28D9"
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(9)
                    font.weight: Font.DemiBold
                    elide: Text.ElideRight
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }

        Text {
            Layout.fillWidth: true
            Layout.preferredHeight: VfTheme.dp(20)
            text: String(root.media.name || root.media.title || root.media.file_name || root.media.id || (void i18n.revision, i18n.t("common.untitled", "Untitled")))
            color: VfTheme.text
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.dp(12)
            font.weight: VfTheme.weightTitle
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            maximumLineCount: 1
            elide: Text.ElideRight
        }

        Item {
            id: typeDropdown

            property string currentValue: ""

            Layout.fillWidth: true
            Layout.preferredHeight: root.managementMode ? VfTheme.dp(25) : 0
            visible: root.managementMode
            opacity: root.typeLocked ? 0.75 : 1.0

            Component.onCompleted: currentValue = root.assetType()

            Connections {
                target: root
                function onMediaChanged() { typeDropdown.currentValue = root.assetType() }
            }

            Rectangle {
                id: triggerRect
                anchors.fill: parent
                radius: VfTheme.dp(4)
                color: VfTheme.surface
                border.color: root.typeColor(typeDropdown.currentValue)
                border.width: 1

                RowLayout {
                    anchors {
                        fill: parent
                        leftMargin: VfTheme.dp(5)
                        rightMargin: VfTheme.dp(20)
                    }
                    spacing: VfTheme.dp(4)

                    TypeIconPill {
                        Layout.alignment: Qt.AlignVCenter
                        name: root.typeIconName(typeDropdown.currentValue)
                        accent: root.typeColor(typeDropdown.currentValue)
                        fill: root.typeBgColor(typeDropdown.currentValue)
                    }

                    Text {
                        Layout.fillWidth: true
                        text: {
                            var idx = root.typeIndex(typeDropdown.currentValue)
                            var opts = root.typeOptions
                            return (opts && idx >= 0 && idx < opts.length) ? String(opts[idx].label || "") : ""
                        }
                        color: root.typeColor(typeDropdown.currentValue)
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.fontSmall
                        font.weight: VfTheme.weightTitle
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                    }
                }

                VfAppIcon {
                    anchors {
                        right: parent.right
                        rightMargin: VfTheme.dp(5)
                        verticalCenter: parent.verticalCenter
                    }
                    name: "chevron-down"
                    size: VfTheme.dp(11)
                    color: root.typeColor(typeDropdown.currentValue)
                }

                MouseArea {
                    anchors.fill: parent
                    enabled: root.managementMode && !root.typeLocked
                    onClicked: dropPopup.opened ? dropPopup.close() : dropPopup.open()
                }
            }

            Popup {
                id: dropPopup
                parent: Overlay.overlay
                x: 0
                y: 0
                onAboutToShow: {
                    var pos = triggerRect.mapToItem(Overlay.overlay, 0, 0)
                    if (!pos) return
                    dropPopup.x = pos.x
                    var popH = dropPopup.implicitHeight
                    var overlayH = Overlay.overlay ? Overlay.overlay.height : 0
                    var belowY = pos.y + triggerRect.height + 4
                    var aboveY = pos.y - popH - 4
                    dropPopup.y = (overlayH > 0 && belowY + popH > overlayH)
                        ? Math.max(VfTheme.dp(4), aboveY)
                        : belowY
                }
                z: 10000
                width: typeDropdown.width
                padding: VfTheme.dp(4)
                modal: false
                focus: true
                closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
                implicitHeight: contentItem ? (contentItem.implicitHeight + topPadding + bottomPadding) : 0

                background: Rectangle {
                    color: VfTheme.surface
                    border.color: VfTheme.border
                    border.width: 1
                    radius: VfTheme.dp(6)
                }

                contentItem: Column {
                    spacing: VfTheme.dp(2)

                    Repeater {
                        model: root.typeOptions

                        delegate: Rectangle {
                            width: parent ? parent.width : 0
                            height: VfTheme.dp(24)
                            color: optMouse.containsMouse || typeDropdown.currentValue === String(modelData.value || "")
                                ? root.typeBgColor(modelData.value)
                                : "transparent"
                            radius: VfTheme.dp(4)

                            RowLayout {
                                anchors {
                                    fill: parent
                                    leftMargin: VfTheme.dp(6)
                                    rightMargin: VfTheme.dp(6)
                                }
                                spacing: VfTheme.dp(5)

                                TypeIconPill {
                                    Layout.alignment: Qt.AlignVCenter
                                    name: root.typeIconName(String(modelData.value || ""))
                                    accent: root.typeColor(String(modelData.value || ""))
                                    fill: root.typeBgColor(String(modelData.value || ""))
                                }

                                Text {
                                    Layout.fillWidth: true
                                    text: String(modelData.label || "")
                                    color: root.typeColor(String(modelData.value || ""))
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.fontSmall
                                    font.weight: VfTheme.weightTitle
                                    verticalAlignment: Text.AlignVCenter
                                    elide: Text.ElideRight
                                }
                            }

                            MouseArea {
                                id: optMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: {
                                    var val = String(modelData.value || "")
                                    typeDropdown.currentValue = val
                                    root.media.asset_type = val
                                    if (root.media.ai_metadata)
                                        root.media.ai_metadata.asset_type = val
                                    root.typeChanged(root.media, val)
                                    dropPopup.close()
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    component StatusBadge: Rectangle {
        id: badge

        property string text: ""
        property color bg: VfTheme.textSubtle

        implicitHeight: VfTheme.dp(16)
        radius: VfTheme.dp(4)
        color: badge.bg

        Text {
            anchors.centerIn: parent
            width: parent.width - 6
            text: badge.text
            color: "#FFFFFF"
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.dp(9)
            font.weight: VfTheme.weightTitle
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            maximumLineCount: 1
            elide: Text.ElideRight
        }
    }

    component TypeIconPill: Rectangle {
        id: typeIcon

        property string name: ""
        property color accent: VfTheme.textSubtle
        property color fill: VfTheme.surfaceSoft

        Layout.preferredWidth: VfTheme.dp(16)
        Layout.preferredHeight: VfTheme.dp(16)
        radius: VfTheme.dp(4)
        color: typeIcon.fill

        VfAppIcon {
            anchors.centerIn: parent
            name: typeIcon.name
            size: VfTheme.dp(11)
            color: typeIcon.accent
        }
    }

    component OverlayBadgeButton: Rectangle {
        id: overlayButton

        property string text: ""
        property string iconName: ""
        property string tooltip: ""
        property color bg: "#3B82F6"
        property color hoverBg: "#2563EB"

        signal clicked()

        width: VfTheme.dp(24)
        height: VfTheme.dp(24)
        radius: VfTheme.dp(12)
        color: overlayMouse.containsMouse ? overlayButton.hoverBg : overlayButton.bg

        VfAppIcon {
            anchors.centerIn: parent
            visible: overlayButton.iconName.length > 0
            name: overlayButton.iconName
            size: VfTheme.dp(13)
            color: "#FFFFFF"
        }

        Text {
            anchors.centerIn: parent
            visible: overlayButton.iconName.length === 0
            text: overlayButton.text
            color: "#FFFFFF"
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.dp(12)
            font.weight: VfTheme.weightTitle
        }

        MouseArea {
            id: overlayMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: overlayButton.clicked()
        }

        ToolTip.visible: overlayMouse.containsMouse && overlayButton.tooltip.length > 0
        ToolTip.text: overlayButton.tooltip
        ToolTip.delay: 450
    }
}
