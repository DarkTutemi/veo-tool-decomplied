import QtQuick
import QtQuick.Controls
import "../theme"
import "AppIconRegistry.js" as AppIconRegistry

// Card frame v2 — header NHUỘM MÀU accent (đọc được cả light/dark) + badge số khu
// (①②③④) + hàng action ngay trên header. API cũ (title/accent/iconName + default
// content) GIỮ NGUYÊN; title/badge rỗng → không vẽ header (StepQueue tự vẽ toolbar).
Rectangle {
    id: section

    property string title: ""
    property color accent: VfTheme.primary
    // Nền header: truyền VfTheme.violetFill/cyanFill… (token theo theme). Mặc định
    // transparent → tự pha accent 7% (vẫn thấy màu trên nền trắng).
    property color accentFill: "transparent"
    property string iconName: ""   // SVG icon (khi không có badge)
    property string badgeText: ""  // "①"… → ô badge màu thay icon
    // Nhiệm vụ của khu — hover header (hoặc dấu ⓘ) hiện tooltip giải thích.
    property string hint: ""
    default property alias content: sectionContent.data
    property alias headerActions: headerActionsRow.data

    readonly property bool hasHeader: title.length > 0 || badgeText.length > 0
    readonly property int headerH: hasHeader ? VfTheme.dp(38) : 0
    readonly property color _stripColor: String(accentFill) === "#00000000"
        ? Qt.alpha(section.accent, 0.07) : accentFill

    radius: VfTheme.dp(8)
    color: VfTheme.surface
    border.color: VfTheme.borderBox
    clip: true

    // ── Header strip nhuộm màu (bo góc trên, vuông góc dưới) ──
    Rectangle {
        id: strip
        visible: section.hasHeader
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 1
        height: section.headerH
        radius: VfTheme.dp(7)
        color: section._stripColor
        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: VfTheme.dp(8)
            color: parent.color
        }
    }
    Rectangle {
        visible: section.hasHeader
        anchors.left: parent.left
        anchors.right: parent.right
        y: section.headerH
        height: 1
        color: Qt.alpha(section.accent, 0.30)
    }

    // ── Badge số khu (①…) ──
    Rectangle {
        visible: section.badgeText.length > 0
        anchors.left: parent.left
        anchors.leftMargin: VfTheme.dp(9)
        anchors.verticalCenter: strip.verticalCenter
        width: VfTheme.dp(23)
        height: VfTheme.dp(23)
        radius: VfTheme.dp(6)
        color: Qt.alpha(section.accent, 0.16)
        border.color: section.accent
        border.width: 1
        Text {
            anchors.centerIn: parent
            text: section.badgeText
            color: section.accent
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.fontSmall
            font.weight: Font.Bold
        }
    }

    // ── Icon (khi không badge): trong header thì canh giữa, không header thì như cũ ──
    VfAppIcon {
        visible: section.iconName.length > 0 && section.badgeText.length === 0
        anchors.left: parent.left
        anchors.leftMargin: VfTheme.dp(11)
        y: section.hasHeader ? (section.headerH - VfTheme.dp(18)) / 2 : VfTheme.dp(13)
        name: section.iconName
        size: VfTheme.dp(18)
        framed: false
        color: section.accent
    }
    // Gạch accent legacy (không icon, không badge, không header strip)
    Rectangle {
        visible: section.iconName.length === 0 && section.badgeText.length === 0 && !section.hasHeader
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.leftMargin: VfTheme.dp(10)
        anchors.topMargin: VfTheme.dp(10)
        width: VfTheme.dp(3)
        height: VfTheme.dp(34)
        radius: VfTheme.dp(2)
        color: section.accent
    }

    Text {
        id: titleText
        visible: section.title.length > 0
        anchors.left: parent.left
        anchors.leftMargin: section.badgeText.length > 0
            ? VfTheme.dp(38)
            : (section.iconName.length > 0 ? VfTheme.dp(36) : VfTheme.dp(24))
        anchors.verticalCenter: strip.verticalCenter
        text: AppIconRegistry.stripGlyph(String(section.title || ""))
        color: VfTheme.text
        font.family: VfTheme.fontFamily
        font.pixelSize: VfTheme.fontControl
        font.weight: VfTheme.weightTitle
        elide: Text.ElideRight
        maximumLineCount: 1
        // Không đè lên ⓘ + actions.
        width: Math.min(implicitWidth,
                        headerActionsRow.x - x - (hintMark.visible ? VfTheme.dp(26) : VfTheme.dp(8)))
    }

    // ⓘ nhiệm vụ khu — hover hiện tooltip (đặt ngay sau title cho dễ thấy).
    Text {
        id: hintMark
        visible: section.hint.length > 0 && section.hasHeader
        anchors.left: titleText.right
        anchors.leftMargin: VfTheme.dp(6)
        anchors.verticalCenter: strip.verticalCenter
        text: "ⓘ"
        color: section.accent
        font.family: VfTheme.fontFamily
        font.pixelSize: VfTheme.fontControl
        MouseArea {
            id: hintMouse
            anchors.fill: parent
            anchors.margins: -VfTheme.dp(4)
            hoverEnabled: true
            acceptedButtons: Qt.NoButton
        }
        ToolTip.visible: hintMouse.containsMouse
        ToolTip.text: section.hint
        ToolTip.delay: 250
    }

    // ── Actions NGAY TRÊN HEADER (nút/pill của khu) ──
    Row {
        id: headerActionsRow
        anchors.right: parent.right
        anchors.rightMargin: VfTheme.dp(9)
        anchors.verticalCenter: strip.verticalCenter
        spacing: VfTheme.dp(6)
    }

    Item {
        id: sectionContent
        anchors.fill: parent
    }
}
