pragma Singleton
import QtQuick
import "."

QtObject {
    readonly property color canvas: Theme.isDark ? "#0B111E" : "#F7F9FC"
    readonly property color panel: Theme.isDark ? "#121A28" : "#FFFFFF"
    readonly property color panelSoft: Theme.isDark ? "#182334" : "#F8FAFD"
    readonly property color border: Theme.isDark ? "#2A3950" : "#DDE5EF"
    readonly property color borderStrong: Theme.isDark ? "#3A4A62" : "#CAD5E2"
    readonly property color text: Theme.isDark ? "#EDF2FA" : "#13213A"
    readonly property color muted: Theme.isDark ? "#A9B6C9" : "#5B6B82"
    readonly property color faint: Theme.isDark ? "#7F8DA3" : "#8795A8"
    readonly property color primary: "#0F6BFF"
    readonly property color primaryHover: "#0759DB"
    readonly property color primarySoft: Theme.isDark ? "#14294B" : "#EEF5FF"
    readonly property color success: Theme.isDark ? "#47D18C" : "#079455"
    readonly property color successSoft: Theme.isDark ? "#142D25" : "#ECFDF3"
    readonly property color warning: Theme.isDark ? "#FDB44B" : "#F79009"
    readonly property color warningSoft: Theme.isDark ? "#332715" : "#FFF8EB"
    readonly property color danger: Theme.isDark ? "#FF7B7F" : "#E5484D"
    readonly property color dangerSoft: Theme.isDark ? "#351C22" : "#FFF1F2"
    readonly property color violet: Theme.isDark ? "#A78BFA" : "#7C3AED"
    readonly property color violetSoft: Theme.isDark ? "#241D3B" : "#F5F3FF"

    readonly property string fontFamily: "Segoe UI"
    readonly property int pageTitle: 21
    readonly property int sectionTitle: 14
    readonly property int body: 12
    readonly property int metadata: 10
    readonly property int navLabel: 12
    readonly property int navHeight: 56
    readonly property int pageHeaderHeight: 70
    readonly property int statusHeight: 50
    readonly property int pageGutter: 36
    readonly property int panelPadding: 14
    readonly property int gap: 12
    readonly property int controlHeight: 36
    readonly property int compactControlHeight: 31
    readonly property int rowHeight: 46
    readonly property int radius: 8
    readonly property int radiusSmall: 6
}
