pragma Singleton
import QtQuick

QtObject {
    property string mode: "dark"
    readonly property bool isDark: mode === "dark"

    readonly property color base: isDark ? "#0B0E13" : "#F4F7FB"
    readonly property color sidebar: isDark ? "#0D1015" : "#FFFFFF"
    readonly property color panel: isDark ? "#12161D" : "#FFFFFF"
    readonly property color elevated: isDark ? "#181D26" : "#EDF2F7"
    readonly property color hover: isDark ? "#202632" : "#E4EAF2"
    readonly property color border: isDark ? "#303846" : "#C7D0DC"
    readonly property color borderSoft: isDark ? "#242B35" : "#DCE3EC"
    readonly property color text: isDark ? "#F4F6FA" : "#18202B"
    readonly property color textMuted: isDark ? "#B5BDC9" : "#526071"
    readonly property color textFaint: isDark ? "#737D8D" : "#778496"
    readonly property color accent: isDark ? "#7B82F6" : "#5C63E6"
    readonly property color accentSoft: isDark ? "#242844" : "#E8E9FF"
    readonly property color success: isDark ? "#52C792" : "#16845B"
    readonly property color warning: isDark ? "#E9AC59" : "#B56B14"
    readonly property color danger: isDark ? "#ED707A" : "#C73B4B"
    readonly property color info: isDark ? "#62A5ED" : "#2B6FC4"

    readonly property color successSoft: isDark ? "#1F332B" : "#DDF4E9"
    readonly property color warningSoft: isDark ? "#342B20" : "#FFF0D8"
    readonly property color dangerSoft: isDark ? "#352124" : "#FCE5E8"
    readonly property color overlay: isDark ? "#B3000000" : "#660B1320"

    readonly property int radiusSmall: 7
    readonly property int radiusMedium: 10
    readonly property int radiusLarge: 14

    // Native 1080p density contract. Pages use these semantic values instead
    // of shrinking business text to fit a fixture screenshot.
    readonly property int fontPageTitle: 27
    readonly property int fontSection: 17
    readonly property int fontBody: 13
    readonly property int fontMetadata: 11
    readonly property int fontKpi: 24
    readonly property int headerHeight: 66
    readonly property int sidebarWidth: 218
    readonly property int sidebarCollapsedWidth: 64
    readonly property int pageGutter: 22
    readonly property int panelPadding: 16
    readonly property int controlHeight: 36
    readonly property int tableRowHeight: 50
    readonly property int inspectorWidth: 384

    readonly property int space1: 4
    readonly property int space2: 8
    readonly property int space3: 12
    readonly property int space4: 16
    readonly property int space5: 20
    readonly property int space6: 24
    readonly property int space7: 32
}
