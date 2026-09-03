import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../theme"

// App-owned replacement for Qt 6.11's style-native TextEditingContextMenu.
// Popup.Item keeps it inside the QML scene instead of creating a Windows menu
// window, so typography, DPI, colors and rounded geometry match VeoFlow.
Menu {
    id: menu

    required property var editor
    readonly property int translationRevision: typeof i18n !== "undefined" && i18n
        ? i18n.revision : 0

    function tr(key, fallback) {
        void menu.translationRevision
        if (typeof i18n !== "undefined" && i18n && i18n.t)
            return i18n.t(key, fallback)
        return fallback
    }

    function boolProperty(name) {
        return Boolean(menu.editor && typeof menu.editor[name] !== "undefined" && menu.editor[name])
    }

    function hasSelection() {
        return Boolean(menu.editor)
            && Number(menu.editor.selectionStart) !== Number(menu.editor.selectionEnd)
    }

    function textLength() {
        if (!menu.editor || typeof menu.editor.length === "undefined")
            return 0
        return Number(menu.editor.length || 0)
    }

    function removeSelection() {
        if (!menu.editor || !menu.hasSelection() || menu.boolProperty("readOnly"))
            return
        menu.editor.remove(menu.editor.selectionStart, menu.editor.selectionEnd)
    }

    popupType: Popup.Item
    width: VfTheme.dp(224)
    padding: VfTheme.dp(6)
    topPadding: VfTheme.dp(6)
    bottomPadding: VfTheme.dp(6)
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    background: Rectangle {
        radius: VfTheme.dp(10)
        color: VfTheme.surface
        border.width: 1
        border.color: VfTheme.borderStrong
    }

    EditItem {
        text: menu.tr("common.undo", "Undo")
        iconName: "counterclockwise-arrows-button"
        shortcutText: "Ctrl+Z"
        enabled: menu.boolProperty("canUndo")
        onTriggered: menu.editor.undo()
    }

    EditItem {
        text: menu.tr("common.redo", "Redo")
        iconName: "clockwise-arrows"
        shortcutText: "Ctrl+Y"
        enabled: menu.boolProperty("canRedo")
        onTriggered: menu.editor.redo()
    }

    EditSeparator {}

    EditItem {
        text: menu.tr("common.cut", "Cut")
        iconName: "scissors"
        shortcutText: "Ctrl+X"
        enabled: menu.boolProperty("canCut")
        onTriggered: menu.editor.cut()
    }

    EditItem {
        text: menu.tr("common.copy", "Copy")
        iconName: "clipboard"
        shortcutText: "Ctrl+C"
        enabled: menu.boolProperty("canCopy")
        onTriggered: menu.editor.copy()
    }

    EditItem {
        text: menu.tr("common.paste", "Paste")
        iconName: "inbox-tray"
        shortcutText: "Ctrl+V"
        enabled: menu.boolProperty("canPaste") && !menu.boolProperty("readOnly")
        onTriggered: menu.editor.paste()
    }

    EditItem {
        text: menu.tr("common.delete", "Delete")
        iconName: "cross-mark"
        shortcutText: "Del"
        enabled: menu.hasSelection() && !menu.boolProperty("readOnly")
        onTriggered: menu.removeSelection()
    }

    EditSeparator {}

    EditItem {
        text: menu.tr("common.select_all", "Select All")
        iconName: "check-box-with-check"
        shortcutText: "Ctrl+A"
        enabled: menu.textLength() > 0
        onTriggered: menu.editor.selectAll()
    }

    component EditItem: MenuItem {
        id: item

        property string iconName: ""
        property string shortcutText: ""

        implicitWidth: menu.width - menu.leftPadding - menu.rightPadding
        implicitHeight: VfTheme.dp(38)
        leftPadding: VfTheme.dp(9)
        rightPadding: VfTheme.dp(9)
        topPadding: 0
        bottomPadding: 0

        contentItem: RowLayout {
            spacing: VfTheme.dp(9)

            VfAppIcon {
                Layout.preferredWidth: VfTheme.dp(17)
                Layout.preferredHeight: VfTheme.dp(17)
                name: item.iconName
                size: VfTheme.dp(17)
                color: item.enabled ? VfTheme.textMuted : VfTheme.textSubtle
            }

            Text {
                Layout.fillWidth: true
                text: item.text
                color: item.enabled ? VfTheme.text : VfTheme.textSubtle
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(12)
                font.weight: item.highlighted ? VfTheme.weightStrong : VfTheme.weightControl
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }

            Text {
                text: item.shortcutText
                color: VfTheme.textSubtle
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(10)
                verticalAlignment: Text.AlignVCenter
            }
        }

        background: Rectangle {
            radius: VfTheme.dp(7)
            color: item.highlighted && item.enabled ? VfTheme.surfaceSoft : "transparent"
            border.width: item.highlighted && item.enabled ? 1 : 0
            border.color: VfTheme.borderSoft
        }
    }

    component EditSeparator: MenuSeparator {
        implicitHeight: VfTheme.dp(9)
        contentItem: Rectangle {
            implicitHeight: 1
            color: VfTheme.border
        }
    }
}
