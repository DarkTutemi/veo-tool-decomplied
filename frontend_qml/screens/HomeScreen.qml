pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import "../components"
import "../theme"

Item {
    id: screen

    property bool wide: width >= 1180
    property bool veryWide: width >= 1560
    property int pageMargin: veryWide ? VfTheme.dp(16) : VfTheme.dp(12)
    property int gap: VfTheme.dp(12)
    property int tutorialPage: 0

    function hasHomeController() { return typeof homeController !== "undefined" && !!homeController }

    // ── Safe reads across async-loaded controllers ──────────────────────────
    function svs(key, dflt) {
        if (!screen.hasHomeController()) return dflt
        var s = homeController.summary
        var v = s ? s[key] : undefined
        return (v === undefined || v === null || v === "") ? dflt : String(v)
    }
    function hdr(prop, dflt) {
        if (typeof headerController === "undefined" || !headerController) return dflt
        var v = headerController[prop]
        return (v === undefined || v === null || String(v) === "") ? dflt : String(v)
    }
    function afterColon(s) {
        s = String(s || "")
        var i = s.indexOf(":")
        return i >= 0 ? s.substring(i + 1).trim() : s
    }
    function tokenUsageText() {
        if (typeof statusController === "undefined" || !statusController) return "—"
        var s = statusController.tokenSummary
        if (!s) return "—"
        var t = (Number(s.total_input_tokens) || 0) + (Number(s.total_output_tokens) || 0)
        return t > 0 ? t.toLocaleString(Qt.locale("en_US")) : "—"
    }
    function hostOf(url) {
        return String(url || "").replace(/^https?:\/\//, "").split("/")[0]
    }
    function socialIcon(item) {
        var u = String(item && item.url || "").toLowerCase()
        var base = "../../resources/home/illustrations/"
        if (u.indexOf("youtube") >= 0) return base + "social-youtube.svg"
        if (u.indexOf("zalo") >= 0) return base + "social-zalo.svg"
        if (u.indexOf("facebook") >= 0) return base + "social-facebook.svg"
        return base + "social-link.svg"
    }
    function accentFor(route) {
        route = String(route || "")
        if (route === "clone") return VfTheme.redBorder
        if (route === "transcript") return VfTheme.cyan
        if (route === "research") return VfTheme.violet
        if (route === "voice") return VfTheme.amber
        if (route === "batch") return VfTheme.greenBorder
        return VfTheme.primary
    }
    function tutorialVideos() {
        if (!screen.hasHomeController()) return []
        var rows = homeController.tutorials || []
        var videos = []
        for (var i = 0; i < rows.length; i++) {
            if (String((rows[i] && rows[i].url) || "").length > 0)
                videos.push(rows[i])
        }
        return videos
    }

    Rectangle { anchors.fill: parent; color: VfTheme.appBackground }

    Connections {
        target: screen.hasHomeController() ? homeController : null
        function onNavigationRequested(route) { appController.setRoute(route) }
        function onExternalOpenRequested(url) { nativeShell.openExternal(url) }
        function onContentChanged() { screen.tutorialPage = 0 }
    }

    readonly property bool homeVisible: screen.hasHomeController()
        && typeof appController !== "undefined" && !!appController
        && appController.route === "home"
    onHomeVisibleChanged: {
        if (!screen.hasHomeController()) return
        if (screen.homeVisible) homeController.onShown()
        else homeController.onHidden()
    }
    Component.onCompleted: if (screen.homeVisible) homeController.onShown()
    Component.onDestruction: if (screen.hasHomeController()) homeController.onHidden()

    // Single-screen layout — NO vertical scroll. Top notice strip · main 2-col ·
    // 3 banners pinned to the bottom, all sized to fit one viewport.
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: screen.pageMargin
        spacing: screen.gap

        // ── TOP STRIP: system notices, scrolling horizontally (replaces hero) ──
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: VfTheme.dp(46)
            radius: VfTheme.radiusPanel
            color: VfTheme.surface
            border.color: VfTheme.borderBox
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: VfTheme.dp(16); anchors.rightMargin: VfTheme.dp(12)
                spacing: VfTheme.dp(12)

                Rectangle {
                    Layout.alignment: Qt.AlignVCenter
                    Layout.preferredWidth: VfTheme.dp(30); Layout.preferredHeight: VfTheme.dp(30)
                    radius: VfTheme.dp(8); color: VfTheme.primary
                    Text { anchors.centerIn: parent; text: "V"; color: "white"; font.weight: Font.Black; font.pixelSize: VfTheme.dp(15) }
                }
                Text { Layout.alignment: Qt.AlignVCenter; verticalAlignment: Text.AlignVCenter; text: "Thông báo"; font.pixelSize: VfTheme.dp(13); font.weight: Font.Bold; color: VfTheme.text }
                Rectangle { Layout.alignment: Qt.AlignVCenter; Layout.preferredWidth: 1; Layout.preferredHeight: VfTheme.dp(22); color: VfTheme.border }

                Flickable {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    contentWidth: notiRow.width
                    contentHeight: height
                    boundsBehavior: Flickable.StopAtBounds
                    flickableDirection: Flickable.HorizontalFlick

                    Row {
                        id: notiRow
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: VfTheme.dp(10)

                        Repeater {
                            // perf-lint: disable=R2 — announcement feed, low-frequency content.
                            model: screen.hasHomeController() ? homeController.announcements : []
                            NotiChip {}
                        }
                    }
                }
            }
        }

        // ── MAIN ───────────────────────────────────────────────────────────
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: screen.gap

            // LEFT COLUMN — stats+spend · social · zalo QR
            ColumnLayout {
                Layout.fillWidth: false
                Layout.preferredWidth: VfTheme.dp(360)
                Layout.minimumWidth: VfTheme.dp(330)
                Layout.maximumWidth: VfTheme.dp(380)
                Layout.fillHeight: true
                spacing: screen.gap

                // STATS + SPEND (all the numbers live here now)
                VfPanel {
                    Layout.fillWidth: true
                    title: "Chi Tiêu & Sử Dụng"

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: VfTheme.dp(5)

                        StatRow { k: "Video đã tạo"; v: screen.svs("totalVideos", "0"); accent: VfTheme.primary }
                        StatRow { k: "Đã hoàn thành"; v: screen.svs("completedVideos", "0"); accent: VfTheme.greenBorder }
                        StatRow { k: "Tài khoản"; v: screen.svs("activeAccounts", "0"); accent: VfTheme.cyan }
                        StatRow { k: "Gói"; v: screen.svs("licenseType", "—"); accent: VfTheme.violet }

                        Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: VfTheme.border }

                        StatRow { k: "Gemini (trả phí)"; v: screen.afterColon(screen.hdr("creditsText", "—")); accent: VfTheme.amber }
                        StatRow { k: "Free usage"; v: screen.afterColon(screen.hdr("consumedText", "—")); accent: VfTheme.greenBorder }
                        StatRow { k: "Token đã dùng"; v: screen.tokenUsageText(); accent: VfTheme.cyan }
                    }
                }

                // SOCIAL CHANNELS (real brand logos)
                VfPanel {
                    Layout.fillWidth: true
                    title: "Kênh Hỗ Trợ & Cộng Đồng"

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: VfTheme.dp(8)

                        Repeater {
                            // perf-lint: disable=R2 — social list ≤6, content-driven, low-frequency.
                            model: screen.hasHomeController() ? homeController.socialLinks : []
                            SocialCard {}
                        }
                    }
                }

                // ZALO QR — fills the remaining left-column height so its bottom
                // lines up with the video column (QR block centered).
                VfPanel {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    title: "Kết Nối Zalo"

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: VfTheme.dp(8)

                        Item { Layout.fillHeight: true }
                        Text {
                            Layout.fillWidth: true
                            text: "Quét mã để nhắn tin / vào nhóm cộng đồng"
                            font.pixelSize: VfTheme.dp(11); color: VfTheme.textMuted
                            wrapMode: Text.WordWrap
                        }
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: VfTheme.dp(12)
                            QrItem { qrLabel: "Zalo cá nhân"; qrSource: "../../resources/home/qr/zalo-contact.png" }
                            QrItem { qrLabel: "Zalo nhóm"; qrSource: "../../resources/home/qr/zalo-group.png" }
                        }
                        Item { Layout.fillHeight: true }
                    }
                }
            }

            // RIGHT COLUMN — quick actions · academy
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignTop
                spacing: screen.gap

                VfPanel {
                    Layout.fillWidth: true
                    title: "Bắt Đầu Nhanh"

                    Flow {
                        Layout.fillWidth: true
                        spacing: VfTheme.dp(10)

                        Repeater {
                            model: [
                                { route: "master", label: "Master Prompt" },
                                { route: "clone", label: "Clone Video" },
                                { route: "transcript", label: "Audio → Video" },
                                { route: "research", label: "Research Labs" },
                                { route: "voice", label: "Voice Studio" },
                                { route: "batch", label: "Tạo Hình Ảnh" }
                            ]
                            QuickAction {}
                        }
                    }
                }

                // ACADEMY — YouTube-style responsive grid. Only real videos are
                // rendered; no bordered cards and no artificial filler slots.
                ColumnLayout {
                    id: academySection
                    Layout.fillWidth: true
                    Layout.fillHeight: false
                    Layout.alignment: Qt.AlignTop
                    visible: screen.tutorialVideos().length > 0
                    spacing: VfTheme.dp(10)

                    property var videos: screen.tutorialVideos()
                    property int minCardWidth: VfTheme.dp(270)
                    property int columnGap: VfTheme.dp(16)
                    property int rowGap: VfTheme.dp(22)
                    property int columnCount: Math.max(
                        2,
                        Math.min(4, Math.floor(
                            (width + columnGap) / (minCardWidth + columnGap)
                        ))
                    )
                    property int cardWidth: Math.max(
                        minCardWidth,
                        Math.floor(
                            (width - (columnCount - 1) * columnGap) / columnCount
                        )
                    )
                    property int cardHeight: Math.round(cardWidth * 9 / 16) + VfTheme.dp(58)
                    property int pageSize: columnCount * 2
                    property int pageCount: Math.max(1, Math.ceil(videos.length / pageSize))
                    property int pageStart: Math.min(screen.tutorialPage, pageCount - 1) * pageSize
                    property var pageRows: videos.slice(pageStart, pageStart + pageSize)

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: false
                        spacing: VfTheme.dp(8)

                        Text {
                            text: "Học Viện VeoFlow"
                            color: VfTheme.text
                            font.pixelSize: VfTheme.dp(15)
                            font.weight: Font.Bold
                        }

                        Text {
                            text: String(academySection.videos.length) + " video"
                            color: VfTheme.textMuted
                            font.pixelSize: VfTheme.dp(11)
                        }

                        Item { Layout.fillWidth: true }

                        Text {
                            visible: academySection.pageCount > 1
                            text: String(screen.tutorialPage + 1) + " / " + String(academySection.pageCount)
                            color: VfTheme.textMuted
                            font.pixelSize: VfTheme.dp(11)
                            font.weight: Font.DemiBold
                        }

                        Rectangle {
                            visible: academySection.pageCount > 1
                            Layout.preferredWidth: VfTheme.dp(30)
                            Layout.preferredHeight: VfTheme.dp(30)
                            radius: width / 2
                            color: academyPrevious.containsMouse ? VfTheme.surfaceSoft : "transparent"
                            opacity: screen.tutorialPage > 0 ? 1 : 0.35

                            Text {
                                anchors.centerIn: parent
                                text: "‹"
                                color: VfTheme.text
                                font.pixelSize: VfTheme.dp(20)
                            }

                            MouseArea {
                                id: academyPrevious
                                anchors.fill: parent
                                enabled: screen.tutorialPage > 0
                                hoverEnabled: true
                                cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                                onClicked: screen.tutorialPage--
                            }
                        }

                        Rectangle {
                            visible: academySection.pageCount > 1
                            Layout.preferredWidth: VfTheme.dp(30)
                            Layout.preferredHeight: VfTheme.dp(30)
                            radius: width / 2
                            color: academyNext.containsMouse ? VfTheme.surfaceSoft : "transparent"
                            opacity: screen.tutorialPage + 1 < academySection.pageCount ? 1 : 0.35

                            Text {
                                anchors.centerIn: parent
                                text: "›"
                                color: VfTheme.text
                                font.pixelSize: VfTheme.dp(20)
                            }

                            MouseArea {
                                id: academyNext
                                anchors.fill: parent
                                enabled: screen.tutorialPage + 1 < academySection.pageCount
                                hoverEnabled: true
                                cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                                onClicked: screen.tutorialPage++
                            }
                        }
                    }

                    Grid {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignTop
                        columns: academySection.columnCount
                        columnSpacing: academySection.columnGap
                        rowSpacing: academySection.rowGap

                        Repeater {
                            // perf-lint: disable=R2 — server list changes at most once/minute.
                            model: academySection.pageRows
                            VideoCard {
                                width: academySection.cardWidth
                                height: academySection.cardHeight
                            }
                        }
                    }

                    onPageCountChanged: {
                        if (screen.tutorialPage >= pageCount)
                            screen.tutorialPage = Math.max(0, pageCount - 1)
                    }
                }

                Item {
                    Layout.fillHeight: true
                    Layout.minimumHeight: 0
                }
            }
        }

        // ── BANNERS — 3 fixed info cards, pinned bottom (no links) ─────────
        RowLayout {
            Layout.fillWidth: true
            spacing: screen.gap

            FixedBanner {
                accent: "#0068FF"
                bTitle: "Shop Account"
                bDesc: "Mua & thuê tài khoản AI chính hãng — liên hệ Zalo để được tư vấn giá tốt nhất"
                bImage: "../../resources/home/illustrations/zalo-icon.png"
            }
            FixedBanner {
                accent: VfTheme.amber
                bTitle: "Affiliate Tool"
                bDesc: "Chia sẻ công cụ tới bạn bè, nhận hoa hồng lên tới 30% mỗi đơn thành công"
                bIcon: "sparkles"
            }
            FixedBanner {
                accent: VfTheme.violet
                bTitle: "Reseller — Đại lý"
                bDesc: "Nhập sỉ tài khoản, hoa hồng đại lý tối đa 50% — hỗ trợ vận hành toàn diện"
                bIcon: "users-round"
            }
        }
    }

    // ═══════════════════════════════════════════════════════════════════════
    // Inline delegate components
    // ═══════════════════════════════════════════════════════════════════════

    component NotiChip : Rectangle {
        required property var modelData
        implicitWidth: chipRow.implicitWidth + VfTheme.dp(20)
        implicitHeight: VfTheme.dp(30)
        radius: VfTheme.dp(15)
        color: VfTheme.surfaceSoft
        border.color: VfTheme.borderBox
        border.width: 1
        Row {
            id: chipRow
            anchors.centerIn: parent
            spacing: VfTheme.dp(7)
            Rectangle {
                width: VfTheme.dp(7); height: VfTheme.dp(7); radius: VfTheme.dp(4)
                anchors.verticalCenter: parent.verticalCenter
                color: modelData.color || VfTheme.primary
            }
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: modelData.text || ""
                font.pixelSize: VfTheme.dp(12); font.weight: Font.DemiBold; color: VfTheme.text
            }
        }
    }

    component StatRow : RowLayout {
        property string k: ""
        property string v: ""
        property color accent: VfTheme.primary
        Layout.fillWidth: true
        spacing: VfTheme.dp(8)
        Text { text: k; font.pixelSize: VfTheme.dp(12); color: VfTheme.textMuted }
        Item { Layout.fillWidth: true }
        Text { text: v; font.pixelSize: VfTheme.dp(13); font.weight: Font.Bold; color: VfTheme.text }
    }

    component SocialCard : Rectangle {
        id: sCard
        required property var modelData

        Layout.fillWidth: true
        Layout.preferredHeight: VfTheme.dp(50)
        radius: VfTheme.dp(8)
        color: VfTheme.surface
        border.color: sMouse.containsMouse ? (sCard.modelData.color || VfTheme.primary) : VfTheme.borderBox
        border.width: 1

        Behavior on border.color { ColorAnimation { duration: 150 } }

        RowLayout {
            anchors.fill: parent; anchors.margins: VfTheme.dp(9); spacing: VfTheme.dp(11)
            Image {
                Layout.preferredWidth: VfTheme.dp(36); Layout.preferredHeight: VfTheme.dp(36)
                source: screen.socialIcon(sCard.modelData)
                sourceSize.width: VfTheme.dp(72); sourceSize.height: VfTheme.dp(72)
                fillMode: Image.PreserveAspectFit; smooth: true; mipmap: true
            }
            ColumnLayout {
                Layout.fillWidth: true; spacing: 0
                Text { Layout.fillWidth: true; text: sCard.modelData.name || ""; font.weight: Font.Bold; font.pixelSize: VfTheme.dp(13); color: VfTheme.text; elide: Text.ElideRight }
                Text { Layout.fillWidth: true; text: screen.hostOf(sCard.modelData.url); font.pixelSize: VfTheme.dp(11); color: VfTheme.textMuted; elide: Text.ElideRight }
            }
            Text { text: "›"; font.pixelSize: VfTheme.dp(18); color: sMouse.containsMouse ? VfTheme.text : VfTheme.textSubtle }
        }
        MouseArea {
            id: sMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
            onClicked: if (screen.hasHomeController()) homeController.openUrl(sCard.modelData.url)
        }
    }

    component QrItem : ColumnLayout {
        property string qrLabel: ""
        property string qrSource: ""
        Layout.fillWidth: true
        spacing: VfTheme.dp(6)
        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: VfTheme.dp(150)
            Layout.preferredHeight: VfTheme.dp(150)
            radius: VfTheme.dp(8)
            color: "white"
            border.color: VfTheme.borderBox
            border.width: 1
            Image {
                anchors.fill: parent
                anchors.margins: VfTheme.dp(9)
                source: qrSource
                sourceSize.width: VfTheme.dp(320); sourceSize.height: VfTheme.dp(320)
                fillMode: Image.PreserveAspectFit; smooth: true; mipmap: true
            }
        }
        Text { Layout.alignment: Qt.AlignHCenter; text: qrLabel; horizontalAlignment: Text.AlignHCenter; font.pixelSize: VfTheme.dp(11); font.weight: Font.DemiBold; color: VfTheme.textMuted }
    }

    component QuickAction : Rectangle {
        id: qa
        required property var modelData

        implicitWidth: qaRow.implicitWidth + VfTheme.dp(22)
        implicitHeight: VfTheme.dp(40)
        radius: VfTheme.radiusControl
        color: qaMouse.containsMouse ? VfTheme.surfaceSoft : VfTheme.surface
        border.color: qaMouse.containsMouse ? VfTheme.primary : VfTheme.borderBox
        border.width: 1

        Behavior on border.color { ColorAnimation { duration: 150 } }

        RowLayout {
            id: qaRow
            anchors.centerIn: parent
            spacing: VfTheme.dp(8)
            VfAppIcon { route: qa.modelData.route || ""; size: VfTheme.dp(18); framed: false }
            Text { text: qa.modelData.label || ""; font.pixelSize: VfTheme.dp(12); font.weight: Font.DemiBold; color: VfTheme.text }
        }
        MouseArea {
            id: qaMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
            onClicked: if (typeof appController !== "undefined" && appController) appController.setRoute(qa.modelData.route || "")
        }
    }

    component VideoCard : Item {
        id: vCard
        required property var modelData

        readonly property bool hasVideo: String(vCard.modelData.url || "").length > 0

        ColumnLayout {
            anchors.fill: parent
            spacing: VfTheme.dp(8)

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: Math.round(vCard.width * 9 / 16)
                radius: VfTheme.dp(10)
                color: "#0F172A"
                clip: true

                VfAppIcon {
                    anchors.centerIn: parent
                    route: vCard.modelData.route || ""
                    size: VfTheme.dp(40)
                    framed: false
                    color: "#64748B"
                    visible: thumbImg.status !== Image.Ready
                }

                Image {
                    id: thumbImg
                    anchors.fill: parent
                    source: vCard.modelData.thumbnail || ""
                    asynchronous: true
                    cache: true
                    smooth: true
                    mipmap: true
                    fillMode: Image.PreserveAspectCrop
                    sourceSize.width: Math.round(vCard.width * 1.5)
                    visible: status === Image.Ready
                }

                Rectangle {
                    anchors.right: parent.right; anchors.bottom: parent.bottom
                    anchors.margins: VfTheme.dp(8)
                    visible: String(vCard.modelData.duration || "").length > 0
                    radius: VfTheme.dp(5); color: "#CC0F172A"
                    width: durText.implicitWidth + VfTheme.dp(12); height: durText.implicitHeight + VfTheme.dp(6)
                    Text { id: durText; anchors.centerIn: parent; text: vCard.modelData.duration || ""; color: "white"; font.pixelSize: VfTheme.dp(11); font.weight: Font.Bold }
                }

                Rectangle {
                    anchors.fill: parent
                    color: vMouse.containsMouse ? "#12000000" : "transparent"
                    Behavior on color { ColorAnimation { duration: 120 } }
                }
            }

            Text {
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: vCard.modelData.title || ""
                color: VfTheme.text
                font.pixelSize: VfTheme.dp(13)
                font.weight: Font.DemiBold
                wrapMode: Text.WordWrap
                maximumLineCount: 2
                elide: Text.ElideRight
                lineHeight: 1.25
            }
        }

        MouseArea {
            id: vMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: vCard.hasVideo ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: if (vCard.hasVideo && screen.hasHomeController()) homeController.openUrl(vCard.modelData.url)
        }
    }

    // Fixed bottom banners — professional info cards (icon badge, no link).
    component FixedBanner : Rectangle {
        property color accent: VfTheme.primary
        property string bTitle: ""
        property string bDesc: ""
        property string bIcon: ""     // lucide name → white icon on accent badge
        property string bImage: ""    // image path (e.g. Zalo logo) → on white badge

        Layout.fillWidth: true
        Layout.preferredHeight: VfTheme.dp(86)
        radius: VfTheme.radiusPanel
        color: VfTheme.surface
        border.color: VfTheme.borderBox
        border.width: 1
        clip: true

        RowLayout {
            anchors.fill: parent
            anchors.margins: VfTheme.dp(14)
            spacing: VfTheme.dp(13)

            Rectangle {
                Layout.alignment: Qt.AlignVCenter
                Layout.preferredWidth: VfTheme.dp(46); Layout.preferredHeight: VfTheme.dp(46)
                radius: VfTheme.dp(12)
                color: bImage.length > 0 ? "white" : accent
                border.color: bImage.length > 0 ? VfTheme.borderBox : "transparent"
                border.width: bImage.length > 0 ? 1 : 0
                VfIcon {
                    anchors.centerIn: parent
                    visible: bIcon.length > 0
                    name: bIcon; variant: "light"; size: VfTheme.dp(22)
                }
                Image {
                    anchors.centerIn: parent
                    visible: bImage.length > 0
                    source: bImage
                    width: VfTheme.dp(30); height: VfTheme.dp(30)
                    sourceSize.width: VfTheme.dp(60); sourceSize.height: VfTheme.dp(60)
                    fillMode: Image.PreserveAspectFit; smooth: true; mipmap: true
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                spacing: VfTheme.dp(3)
                Text { Layout.fillWidth: true; text: bTitle; font.pixelSize: VfTheme.dp(15); font.weight: Font.Bold; color: VfTheme.text; elide: Text.ElideRight }
                Text {
                    Layout.fillWidth: true; text: bDesc
                    font.pixelSize: VfTheme.dp(12); color: VfTheme.textMuted
                    wrapMode: Text.WordWrap; maximumLineCount: 2; elide: Text.ElideRight; lineHeight: 1.25
                }
            }
        }
    }
}
