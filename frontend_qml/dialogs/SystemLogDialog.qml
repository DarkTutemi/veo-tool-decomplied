import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../components"
import "../theme"

Dialog {
    id: root
    parent: Overlay.overlay

    property var entries: []
    property string logText: ""
    property bool paused: false
    property string filterText: ""
    property string sourceFilter: "all"
    property string actionMessage: ""
    property bool actionError: false
    property int totalCount: 0
    // User is selecting text → do not clobber selection with auto-refresh stick-to-end.
    property bool userSelecting: false
    // Stick to bottom unless user scrolled up (while paused or while selecting).
    property bool stickToEnd: true

    signal refreshRequested(string filterText, string sourceFilter)
    signal clearRequested()
    signal copyRequested()
    signal exportRequested()
    signal closeRequested()

    modal: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    width: VfDialogMetrics.width(parent, VfTheme.dp(1200), VfTheme.dp(48))
    height: VfDialogMetrics.height(parent, VfTheme.dp(800), VfTheme.dp(48))
    x: VfDialogMetrics.centerX(parent, width)
    y: VfDialogMetrics.centerY(parent, height)
    padding: 0
    standardButtons: Dialog.NoButton

    header: VfDialogHeader {
        title: (void i18n.revision, i18n.t("system_log.title", "System Log"))
        iconName: "memo"
        compact: true
        onCloseClicked: root.close()
    }

    background: Rectangle {
        color: "#111827"
        radius: VfTheme.radiusPanel
        border.color: VfTheme.borderStrong
        border.width: 1
    }

    onOpened: {
        root.actionMessage = ""
        root.actionError = false
        root.paused = false
        root.userSelecting = false
        root.stickToEnd = true
        searchInput.text = ""
        root.filterText = ""
        root.sourceFilter = "all"
        root.refreshRequested(root.filterText, root.sourceFilter)
        // Don't steal focus from the log area forever — allow select immediately.
        logArea.forceActiveFocus()
    }

    Timer {
        interval: 1200
        running: root.visible && !root.paused
        repeat: true
        onTriggered: {
            // While dragging a selection, skip refresh so selection is not wiped.
            if (root.userSelecting || (logArea.selectedText && logArea.selectedText.length > 0))
                return
            root.refreshRequested(root.filterText, root.sourceFilter)
        }
    }

    Timer {
        id: scrollEndTimer
        interval: 30
        repeat: false
        onTriggered: root.scrollToEnd()
    }

    function lineText(entry) {
        var timestamp = String(entry.timestamp || "")
        var source = String(entry.source || "")
        var message = String(entry.message || "")
        var prefix = timestamp.length > 0 ? "[" + timestamp + "] " : ""
        if (source.length > 0)
            prefix += source + "  "
        return prefix + message
    }

    function buildLogText(list) {
        var entries = list || []
        var lines = []
        for (var i = 0; i < entries.length; i++)
            lines.push(root.lineText(entries[i]))
        return lines.join("\n")
    }

    function scrollToEnd() {
        // Vertical tail only. Do NOT set cursorPosition=length: that also scrolls
        // horizontally to the end of a long last line (view jumps fully to the right).
        if (!root.stickToEnd || root.userSelecting)
            return
        try {
            // Caret at start of last line (column 0) — never at EOL of a long line.
            var t = logArea.text || ""
            var lastNl = t.lastIndexOf("\n")
            var lineStart = lastNl < 0 ? 0 : lastNl + 1
            logArea.cursorPosition = lineStart

            var flick = logScroll.contentItem
            if (flick && flick.contentHeight !== undefined) {
                flick.contentY = Math.max(0, flick.contentHeight - flick.height)
                // Always pin left edge after any cursor/layout pass.
                if (flick.contentX !== undefined)
                    flick.contentX = 0
            }
        } catch (e) {
        }
    }

    function applyActionResult(result) {
        var response = result || ({})
        root.actionMessage = String(response.message || response.error || "")
        root.actionError = !Boolean(response.ok)
    }

    function applyRefreshResult(result) {
        var response = result || ({})
        var nextEntries = response.entries || []
        root.entries = nextEntries
        root.totalCount = Number(response.total || 0)
        var nextText = root.buildLogText(nextEntries)
        // Avoid resetting TextArea (and selection) when content is unchanged.
        if (nextText !== root.logText) {
            var hadSelection = logArea.selectedText && logArea.selectedText.length > 0
            if (hadSelection) {
                // Keep previous text while user is selecting; next clean refresh will catch up.
                return
            }
            root.logText = nextText
            if (!root.paused && root.stickToEnd)
                scrollEndTimer.restart()
        } else if (!root.paused && root.stickToEnd) {
            scrollEndTimer.restart()
        }
    }

    contentItem: ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // Toolbar
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: VfTheme.dp(44)
            color: "#1F2937"

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: VfTheme.dp(12)
                anchors.rightMargin: VfTheme.dp(12)
                spacing: VfTheme.dp(8)

                TextField {
                    id: searchInput
                    Layout.fillWidth: true
                    Layout.preferredHeight: VfTheme.dp(30)
                    placeholderText: (void i18n.revision, i18n.t("system_log.search_hint", "Filter log..."))
                    font.family: "Consolas"
                    font.pixelSize: VfTheme.dp(12)
                    color: "#E5E7EB"
                    placeholderTextColor: "#6B7280"
                    background: Rectangle {
                        radius: VfTheme.dp(6)
                        color: "#374151"
                        border.color: searchInput.activeFocus ? "#6366F1" : "#4B5563"
                    }
                    onTextChanged: {
                        root.filterText = text
                        root.refreshRequested(root.filterText, root.sourceFilter)
                    }
                }

                NoScrollComboBox {
                    id: sourceCombo
                    Layout.preferredWidth: VfTheme.dp(100)
                    Layout.preferredHeight: VfTheme.dp(30)
                    model: ["All", "stdout", "stderr"]
                    onCurrentTextChanged: {
                        root.sourceFilter = currentText.toLowerCase()
                        root.refreshRequested(root.filterText, root.sourceFilter)
                    }
                }

                Rectangle { width: 1; Layout.fillHeight: true; Layout.topMargin: 8; Layout.bottomMargin: 8; color: "#374151" }

                VfButton {
                    text: root.paused
                        ? (void i18n.revision, i18n.t("common.resume", "▶ Resume"))
                        : (void i18n.revision, i18n.t("common.pause", "⏸ Pause"))
                    onClicked: {
                        root.paused = !root.paused
                        if (!root.paused) {
                            root.stickToEnd = true
                            root.refreshRequested(root.filterText, root.sourceFilter)
                            scrollEndTimer.restart()
                        }
                    }
                }
            }
        }

        // Log view — single TextArea so drag-select + Ctrl+C work across lines.
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#0B1220"
            clip: true

            ScrollView {
                id: logScroll
                anchors.fill: parent
                anchors.margins: VfTheme.dp(4)
                clip: true
                // Keep focus/selection in TextArea; wheel still scrolls.
                contentWidth: availableWidth

                TextArea {
                    id: logArea
                    width: logScroll.availableWidth
                    text: root.logText
                    readOnly: true
                    wrapMode: TextEdit.NoWrap
                    selectByMouse: true
                    persistentSelection: true
                    color: "#D1D5DB"
                    selectedTextColor: "#FFFFFF"
                    selectionColor: "#4F46E5"
                    font.family: "Consolas"
                    font.pixelSize: VfTheme.dp(11)
                    background: null

                    // Track selection so auto-refresh does not wipe drag-select / Ctrl+C.
                    onSelectedTextChanged: {
                        root.userSelecting = selectedText && selectedText.length > 0
                        if (root.userSelecting) {
                            // Pause live tail while selecting so text does not jump.
                            root.paused = true
                            root.stickToEnd = false
                        }
                    }
                }

                // Detect manual scroll away from bottom → pause auto-tail (do not cover TextArea).
                Connections {
                    target: logScroll.contentItem
                    function onContentYChanged() {
                        var flick = logScroll.contentItem
                        if (!flick || flick.contentHeight === undefined || flick.height <= 0)
                            return
                        var atEnd = (flick.contentY + flick.height) >= (flick.contentHeight - 32)
                        if (!atEnd && root.stickToEnd && !root.userSelecting) {
                            root.stickToEnd = false
                            root.paused = true
                        } else if (atEnd && !root.userSelecting) {
                            root.stickToEnd = true
                        }
                    }
                }
            }
        }

        // Footer action bar
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: VfTheme.dp(48)
            color: "#1F2937"

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                height: 1
                color: "#374151"
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: VfTheme.dp(12)
                anchors.rightMargin: VfTheme.dp(12)
                spacing: VfTheme.dp(8)

                Text {
                    text: (void i18n.revision, i18n.t("system_log.showing_count",
                        "Showing %1 / %2").arg(root.entries.length).arg(root.totalCount))
                    color: "#6B7280"
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(11)
                }

                Text {
                    visible: root.paused
                    text: "PAUSED"
                    color: "#FBBF24"
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(11)
                    font.weight: Font.Bold
                }

                Text {
                    visible: root.actionMessage.length > 0
                    text: root.actionMessage
                    color: root.actionError ? "#FCA5A5" : "#86EFAC"
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(11)
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }

                Item { Layout.fillWidth: true }

                VfButton {
                    text: (void i18n.revision, i18n.t("common.refresh", "Refresh"))
                    onClicked: {
                        root.stickToEnd = true
                        root.refreshRequested(root.filterText, root.sourceFilter)
                    }
                }

                VfButton {
                    text: (void i18n.revision, i18n.t("system_log.copy_all", "Copy All"))
                    onClicked: root.copyRequested()
                }

                VfButton {
                    text: (void i18n.revision, i18n.t("system_log.export_file", "Export File"))
                    onClicked: root.exportRequested()
                }

                VfButton {
                    text: (void i18n.revision, i18n.t("common.clear", "Clear"))
                    tone: "danger"
                    onClicked: root.clearRequested()
                }

                VfButton {
                    text: (void i18n.revision, i18n.t("common.close", "Close"))
                    onClicked: root.close()
                }
            }
        }
    }
}
