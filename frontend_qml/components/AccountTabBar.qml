import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../dialogs"
import "../theme"

Item {
    id: root

    property var accounts: []
    property var sessions: []
    property int currentIndex: -1
    property int maxSlots: 5
    property string selectedEmail: ""
    property int pendingCloseIndex: -1

    signal addSessionRequested()
    signal accountSelected(string email)
    signal tabAboutToChange(int oldIndex)
    signal tabChanged(int tabIndex, var sessionState)
    signal tabClosed(int tabIndex)
    signal tabAdded(var account)

    Layout.fillWidth: true
    implicitHeight: VfTheme.dp(32)
    visible: true

    function accountKey(account) {
        if (!account)
            return ""
        if (account.id !== undefined && account.id !== null)
            return String(account.id)
        if (account.email !== undefined && account.email !== null && String(account.email).length > 0)
            return String(account.email)
        return String(account.name || "")
    }

    function countSessionsForAccount(key) {
        var count = 0
        for (var i = 0; i < root.sessions.length; i++) {
            if (String(root.sessions[i].account_key || "") === String(key))
                count += 1
        }
        return count
    }

    function isLiveAccount(account) {
        if (!account)
            return false
        var status = String(account.status || "").toLowerCase()
        return status.length === 0 || status === "live"
    }

    function availableAccounts() {
        var rows = []
        for (var i = 0; i < root.accounts.length; i++) {
            var account = root.accounts[i]
            var key = root.accountKey(account)
            if (!root.isLiveAccount(account))
                continue
            if (root.countSessionsForAccount(key) >= root.maxSlots)
                continue
            rows.push(account)
        }
        return rows
    }

    function handleAddRequest() {
        var available = root.availableAccounts()
        if (available.length > 0) {
            accountPickerDialog.openFor(available, root.selectedEmail)
            return
        }
        root.addSessionRequested()
    }

    function tabTitle(session) {
        var name = String((session && session.account_name) || "Account")
        var slot = Number((session && session.slot_number) || 1)
        return "\u25cf " + name + " (" + slot + "/" + root.maxSlots + ")"
    }

    function buildSession(account, slotNumber) {
        var name = String((account && (account.name || account.email)) || "Account")
        var email = String((account && (account.email || account.name)) || "")
        var key = root.accountKey(account)
        return {
            account_id: account && account.id !== undefined ? account.id : key,
            account_key: key,
            account_name: name,
            account_email: email,
            slot_number: slotNumber,
            cards_data: [],
            config_settings: {},
            extend_chains: {},
            current_mode: "extend_mixing",
            aspect_ratio: "VIDEO_ASPECT_RATIO_LANDSCAPE",
            project_id: "",
            session_id: "",
            locked_worker_id: "",
            generation_count: 0,
            output_folder: "",
            media_generation_ids: [],
            clips: [],
            concat_inputs: [],
            job_ids: [],
            session_key: "unified_extend:" + email + ":" + Date.now() + ":" + Math.floor(Math.random() * 1000000),
            is_submitting: false,
            auto_concat: true,
            upscale_enabled: false,
            master_prompt_state: {}
        }
    }

    function reindexedSessions(rows) {
        var counters = {}
        var nextRows = []
        for (var i = 0; i < rows.length; i++) {
            var source = rows[i]
            var key = String(source.account_key || "")
            counters[key] = (counters[key] || 0) + 1
            var copy = {}
            for (var prop in source)
                copy[prop] = source[prop]
            copy.slot_number = counters[key]
            nextRows.push(copy)
        }
        return nextRows
    }

    function addSession(account) {
        var key = root.accountKey(account)
        var slot = root.countSessionsForAccount(key) + 1
        if (slot > root.maxSlots)
            return -1

        var session = root.buildSession(account, slot)
        var nextRows = root.sessions.slice()
        nextRows.push(session)
        root.sessions = nextRows
        root.selectSession(nextRows.length - 1)
        root.tabAdded(account || {})
        return nextRows.length - 1
    }

    function add_session(account) {
        return root.addSession(account)
    }

    function selectSession(index) {
        if (index < 0 || index >= root.sessions.length)
            return
        if (root.currentIndex === index)
            return

        var oldIndex = root.currentIndex
        if (oldIndex >= 0)
            root.tabAboutToChange(oldIndex)

        root.currentIndex = index
        var session = root.sessions[index]
        root.selectedEmail = String(session.account_email || "")
        root.accountSelected(root.selectedEmail)
        root.tabChanged(index, session)
    }

    function closeTab(index) {
        if (index < 0 || index >= root.sessions.length)
            return

        var rows = root.sessions.slice()
        rows.splice(index, 1)
        root.sessions = root.reindexedSessions(rows)
        root.tabClosed(index)

        if (root.sessions.length === 0) {
            root.currentIndex = -1
            root.selectedEmail = ""
            return
        }

        var nextIndex = Math.min(index, root.sessions.length - 1)
        root.currentIndex = -1
        root.selectSession(nextIndex)
    }

    function requestCloseTab(index) {
        if (index < 0 || index >= root.sessions.length)
            return
        root.pendingCloseIndex = index
        closeConfirmDialog.open()
    }

    function hasSessions() {
        return root.sessions.length > 0
    }

    function getSessionCount() {
        return root.sessions.length
    }

    function getCurrentSession() {
        if (root.currentIndex < 0 || root.currentIndex >= root.sessions.length)
            return null
        return root.sessions[root.currentIndex]
    }

    function incrementGenerationCount(mediaGenerationId) {
        if (root.currentIndex < 0 || root.currentIndex >= root.sessions.length)
            return 0

        var rows = root.sessions.slice()
        var session = {}
        var current = rows[root.currentIndex] || ({})
        for (var prop in current)
            session[prop] = current[prop]

        session.generation_count = Number(session.generation_count || 0) + 1
        var generationIds = (session.media_generation_ids || []).slice()
        if (String(mediaGenerationId || "").length > 0)
            generationIds.push(String(mediaGenerationId))
        session.media_generation_ids = generationIds

        rows[root.currentIndex] = session
        root.sessions = rows
        return Number(session.generation_count || 0)
    }

    function increment_generation_count(mediaGenerationId) {
        return root.incrementGenerationCount(mediaGenerationId)
    }

    function getGenerationCount() {
        var session = root.getCurrentSession()
        return session ? Number(session.generation_count || 0) : 0
    }

    RowLayout {
        anchors.fill: parent
        spacing: VfTheme.dp(6)

        Rectangle {
            Layout.preferredWidth: VfTheme.dp(30)
            Layout.preferredHeight: VfTheme.dp(30)
            radius: VfTheme.dp(15)
            color: addMouse.containsMouse ? VfTheme.blueFill : VfTheme.surface
            border.color: addMouse.containsMouse ? "#60A5FA" : VfTheme.blueBorderSoft
            border.width: 1

            Text {
                anchors.centerIn: parent
                text: "+"
                color: addMouse.containsMouse ? VfTheme.primaryPressed : VfTheme.primary
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(18)
                font.weight: Font.Black
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
            }

            MouseArea {
                id: addMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.handleAddRequest()
            }
        }

        Flickable {
            id: tabScroller
            Layout.fillWidth: true
            Layout.preferredHeight: VfTheme.dp(32)
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            contentWidth: tabRow.implicitWidth
            contentHeight: height
            flickableDirection: Flickable.HorizontalFlick

            Row {
                id: tabRow
                height: parent.height
                spacing: VfTheme.dp(6)

                Repeater {
                    model: root.sessions

                    Rectangle {
                        id: tabRect
                        width: Math.min(230, Math.max(130, tabText.implicitWidth + closeBox.width + 34))
                        height: VfTheme.dp(30)
                        radius: VfTheme.dp(8)
                        color: root.currentIndex === index ? VfTheme.blueFill : (tabMouse.containsMouse ? VfTheme.blueFill : VfTheme.surfaceSoft)
                        border.color: root.currentIndex === index ? VfTheme.blueBorderSoft : (tabMouse.containsMouse ? VfTheme.blueBorderSoft : VfTheme.border)
                        border.width: 1

                        MouseArea {
                            id: tabMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.selectSession(index)
                        }

                        RowLayout {
                            z: 1
                            anchors.fill: parent
                            anchors.leftMargin: VfTheme.dp(10)
                            anchors.rightMargin: VfTheme.dp(6)
                            spacing: VfTheme.dp(6)

                            Text {
                                id: tabText
                                Layout.fillWidth: true
                                text: root.tabTitle(modelData)
                                color: root.currentIndex === index ? VfTheme.primaryPressed : VfTheme.text
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.fontSmall
                                font.weight: VfTheme.weightStrong
                                elide: Text.ElideRight
                                maximumLineCount: 1
                                verticalAlignment: Text.AlignVCenter
                            }

                            Rectangle {
                                id: closeBox
                                Layout.preferredWidth: VfTheme.dp(18)
                                Layout.preferredHeight: VfTheme.dp(18)
                                radius: VfTheme.dp(9)
                                color: closeMouse.containsMouse ? VfTheme.redFill : "transparent"

                                Text {
                                    anchors.centerIn: parent
                                    text: "\u00d7"
                                    color: closeMouse.containsMouse ? "#DC2626" : VfTheme.textMuted
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.dp(13)
                                    font.weight: VfTheme.weightStrong
                                }

                                MouseArea {
                                    id: closeMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: root.requestCloseTab(index)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Dialog {
        id: closeConfirmDialog
        parent: Overlay.overlay
        modal: true
        anchors.centerIn: parent
        width: VfDialogMetrics.width(parent, VfTheme.dp(420), VfTheme.dp(48))
        padding: VfTheme.dp(20)
        title: ""
        standardButtons: Dialog.NoButton

        background: Rectangle {
            radius: VfTheme.dp(8)
            color: VfTheme.surface
            border.color: VfTheme.borderStrong
        }

        contentItem: ColumnLayout {
            spacing: VfTheme.dp(16)

            Text {
                Layout.fillWidth: true
                text: (void i18n.revision, i18n.t("account_tab.close_session_title", "Close Session"))
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(18)
                font.weight: VfTheme.weightTitle
                wrapMode: Text.WordWrap
            }

            Text {
                Layout.fillWidth: true
                text: {
                    var session = root.pendingCloseIndex >= 0 && root.pendingCloseIndex < root.sessions.length
                        ? root.sessions[root.pendingCloseIndex]
                        : null
                    var name = session ? String(session.account_name || "") : ""
                    return (void i18n.revision, i18n.t("account_tab.close_session_confirm", "Close session for {account_name}?")).replace("{account_name}", name)
                }
                color: VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontControl
                wrapMode: Text.WordWrap
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: VfTheme.dp(10)

                Item { Layout.fillWidth: true }

                VfButton {
                    text: (void i18n.revision, i18n.t("common.cancel", "Cancel"))
                    minWidth: VfTheme.dp(110)
                    onClicked: {
                        root.pendingCloseIndex = -1
                        closeConfirmDialog.close()
                    }
                }

                VfButton {
                    text: (void i18n.revision, i18n.t("common.confirm", "Confirm"))
                    tone: "primary"
                    minWidth: VfTheme.dp(120)
                    onClicked: {
                        var index = root.pendingCloseIndex
                        root.pendingCloseIndex = -1
                        closeConfirmDialog.close()
                        root.closeTab(index)
                    }
                }
            }
        }
    }

    AccountPickerDialog {
        id: accountPickerDialog
        onAccountSelected: account => {
            root.addSession(account || ({}))
        }
    }
}
