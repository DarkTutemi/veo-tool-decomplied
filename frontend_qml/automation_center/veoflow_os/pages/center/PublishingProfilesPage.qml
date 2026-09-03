pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../.."
import "CenterFormat.js" as Fmt

Item {
    id: root
    objectName: "centerPublishingProfilesPage"

    required property var plane

    property int selectedIndex: 0
    property int modelRevision: 0
    property string query: ""
    property string platformFilter: ""
    property string statusFilter: ""
    readonly property bool compactLayout: width < 1450
    readonly property var profileModel: root.plane.profileModel
    readonly property var selectedProfile: root.profileAt(root.selectedIndex)
    readonly property var selectedLastAttempt: root.lastAttemptForProfile(
        root.selectedProfile.profileId)
    readonly property int totalProfiles: Number((root.plane.profilePage || {}).total
        || (root.profileModel ? root.profileModel.count : 0))

    function profileAt(index) {
        const revision = root.modelRevision
        if (!root.profileModel || index < 0 || index >= Number(root.profileModel.count || 0))
            return ({})
        return root.profileModel.get(index) || ({})
    }

    function matches(row) {
        if (root.platformFilter && String(row.platform || "").toLowerCase() !== root.platformFilter)
            return false
        if (root.statusFilter && String(row.authState || row.status || "").toLowerCase() !== root.statusFilter)
            return false
        if (!root.query)
            return true
        const haystack = (String(row.label || "") + " " + String(row.profileId || "")
            + " " + String(row.accountHandle || "") + " " + String(row.channelId || "")).toLowerCase()
        return haystack.indexOf(root.query) >= 0
    }

    function profileCount(kind) {
        const revision = root.modelRevision
        let count = 0
        if (!root.profileModel)
            return count
        for (let index = 0; index < Number(root.profileModel.count || 0); ++index) {
            const row = root.profileModel.get(index) || ({})
            if (kind === "verified" && String(row.authState || "") === "verified")
                count++
            else if (kind === "login" && String(row.authState || "") !== "verified")
                count++
            else if (kind === "busy" && Boolean(row.busy))
                count++
        }
        return count
    }

    function lastAttemptForProfile(profileId) {
        const revision = root.modelRevision
        const expected = String(profileId || "")
        const model = root.plane.publishAttemptModel
        let best = ({})
        if (!model || !expected)
            return best
        for (let index = 0; index < Number(model.count || 0); ++index) {
            const row = model.get(index) || ({})
            if (String(row.profileId || "") !== expected)
                continue
            if (!best.updatedAt || String(row.updatedAt || "") > String(best.updatedAt || ""))
                best = row
        }
        return best
    }

    function requestPage() {
        root.plane.callTool("browser.inventory.snapshot", {
            "query": root.query,
            "platform": root.platformFilter,
            "auth_state": root.statusFilter,
            "limit": 20,
            "offset": 0
        })
    }

    function profileAction(name) {
        const profileId = String(root.selectedProfile.profileId || "")
        if (!profileId)
            return
        root.plane.callTool(name, {"profile_id": profileId})
    }

    function healthOk(row, key) {
        switch (key) {
        case "runtime": return ["closed", "ready", "user_open"].indexOf(String(row.status || "")) >= 0
        case "identity": return String(row.authState || "") === "verified"
        case "binding": return String(row.channelBindingId || "").length > 0
        case "profile": return String(row.browserKey || "").length > 0
        default: return false
        }
    }

    Connections {
        target: root.profileModel
        function onModelReset() { root.modelRevision++ }
        function onDataChanged() { root.modelRevision++ }
        function onCountChanged() {
            root.modelRevision++
            if (root.selectedIndex >= Number(root.profileModel.count || 0))
                root.selectedIndex = Math.max(0, Number(root.profileModel.count || 0) - 1)
        }
    }

    Connections {
        target: root.plane.publishAttemptModel
        function onModelReset() { root.modelRevision++ }
        function onDataChanged() { root.modelRevision++ }
        function onCountChanged() { root.modelRevision++ }
    }

    component SectionTitle: Text {
        color: CenterTokens.text
        font.family: CenterTokens.fontFamily
        font.pixelSize: CenterTokens.sectionTitle
        font.weight: Font.DemiBold
    }

    component MetaText: Text {
        color: CenterTokens.muted
        font.family: CenterTokens.fontFamily
        font.pixelSize: CenterTokens.metadata + 1
        elide: Text.ElideRight
    }

    component HeaderCell: Text {
        color: CenterTokens.muted
        font.family: CenterTokens.fontFamily
        font.pixelSize: CenterTokens.metadata + 1
        font.weight: Font.DemiBold
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.leftMargin: CenterTokens.pageGutter
        anchors.rightMargin: CenterTokens.pageGutter
        anchors.topMargin: 14
        anchors.bottomMargin: 0
        spacing: 10

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 58
            spacing: 10
            ColumnLayout {
                Layout.minimumWidth: 0
                Layout.preferredWidth: root.compactLayout ? 280 : 430
                spacing: 3
                Text {
                    text: qsTr("Hồ sơ đăng")
                    color: CenterTokens.text
                    font.family: CenterTokens.fontFamily
                    font.pixelSize: CenterTokens.pageTitle
                    font.weight: Font.Bold
                }
                Text {
                    Layout.fillWidth: true
                    text: qsTr("Quản lý hồ sơ mạng xã hội, browser identity và trạng thái đăng nhập.")
                    color: CenterTokens.muted
                    font.family: CenterTokens.fontFamily
                    font.pixelSize: CenterTokens.body
                    elide: Text.ElideRight
                }
            }
            Item { Layout.fillWidth: true }
            Button {
                id: browserMode
                Layout.preferredWidth: 98
                Layout.preferredHeight: CenterTokens.controlHeight
                checked: true
                checkable: true
                text: qsTr("Browser")
                contentItem: RowLayout {
                    UiIcon {
                        name: "device/runtime"
                        tone: CenterTokens.primary
                        iconSize: 15
                        Layout.preferredWidth: 15
                        Layout.preferredHeight: 15
                    }
                    Text {
                        text: browserMode.text
                        color: CenterTokens.primary
                        font.family: CenterTokens.fontFamily
                        font.pixelSize: CenterTokens.body
                        font.weight: Font.DemiBold
                    }
                }
                background: Rectangle {
                    radius: CenterTokens.radiusSmall
                    color: CenterTokens.primarySoft
                    border.width: 1
                    border.color: CenterTokens.primary
                }
            }
            Button {
                Layout.preferredWidth: 166
                Layout.preferredHeight: CenterTokens.controlHeight
                enabled: false
                contentItem: RowLayout {
                    UiIcon {
                        name: "semantic/smartphone"
                        tone: CenterTokens.faint
                        iconSize: 15
                        Layout.preferredWidth: 15
                        Layout.preferredHeight: 15
                    }
                    Text {
                        text: qsTr("Android")
                        color: CenterTokens.faint
                        font.family: CenterTokens.fontFamily
                        font.pixelSize: CenterTokens.body
                    }
                    CenterStatusBadge { text: qsTr("Chưa kết nối"); status: "warning" }
                }
                background: Rectangle {
                    radius: CenterTokens.radiusSmall
                    color: CenterTokens.panelSoft
                    border.width: 1
                    border.color: CenterTokens.border
                }
                visible: !root.compactLayout
            }
            Item { Layout.preferredWidth: 25; visible: !root.compactLayout }
            CenterSearchField {
                Layout.preferredWidth: root.compactLayout ? 175 : 210
                placeholderText: qsTr("Tìm hồ sơ, kênh...")
                onQueryCommitted: query => {
                    root.query = query.toLowerCase()
                    root.requestPage()
                }
            }
            AppComboBox {
                objectName: "publishingProfilePlatformFilter"
                Layout.preferredWidth: root.compactLayout ? 130 : 145
                Layout.preferredHeight: CenterTokens.controlHeight
                model: [qsTr("Tất cả nền tảng"), "YouTube", "TikTok", "Facebook"]
                onActivated: {
                    root.platformFilter = currentIndex === 0 ? "" : String(currentText).toLowerCase()
                    root.requestPage()
                }
            }
            AppComboBox {
                objectName: "publishingProfileStatusFilter"
                Layout.preferredWidth: 145
                Layout.preferredHeight: CenterTokens.controlHeight
                model: [qsTr("Tất cả trạng thái"), qsTr("Đã xác minh"), qsTr("Chưa xác minh")]
                onActivated: {
                    root.statusFilter = currentIndex === 1 ? "verified"
                        : currentIndex === 2 ? "unverified" : ""
                    root.requestPage()
                }
                visible: !root.compactLayout
            }
            Item { Layout.preferredWidth: 8; visible: !root.compactLayout }
            AppButton {
                text: qsTr("Nhập hàng loạt")
                leadingIcon: "ui/upload-cloud"
                onClicked: bulkDialog.open()
                visible: !root.compactLayout
            }
            AppButton {
                text: qsTr("Thêm hồ sơ")
                leadingIcon: "ui/plus"
                primary: true
                onClicked: createDialog.open()
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: CenterTokens.gap

            CenterPanel {
                Layout.minimumWidth: 0
                Layout.fillWidth: true
                Layout.fillHeight: true
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: CenterTokens.panelPadding
                    spacing: 8
                    RowLayout {
                        Layout.fillWidth: true
                        SectionTitle { text: qsTr("Danh sách hồ sơ") }
                        MetaText { text: String(root.totalProfiles) + qsTr(" hồ sơ") }
                        Item { Layout.fillWidth: true }
                        CenterStatusBadge {
                            text: qsTr("Trang hiện tại: ") + String(root.profileModel ? root.profileModel.count : 0)
                            status: "info"
                        }
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 6
                        MetaText { text: String(root.totalProfiles) + qsTr(" hồ sơ") }
                        MetaText { text: "•" }
                        MetaText {
                            text: String(root.profileCount("verified")) + qsTr(" sẵn sàng")
                            color: CenterTokens.success
                        }
                        MetaText { text: "•" }
                        MetaText {
                            text: String(root.profileCount("login")) + qsTr(" cần đăng nhập")
                            color: CenterTokens.warning
                        }
                        MetaText { text: "•" }
                        MetaText {
                            text: String(root.profileCount("busy")) + qsTr(" đang bận")
                            color: CenterTokens.primary
                        }
                        Item { Layout.fillWidth: true }
                    }
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 39
                        color: CenterTokens.primary
                        radius: CenterTokens.radiusSmall
                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 10
                            spacing: 8
                            Text {
                                text: qsTr("Đã chọn 1")
                                color: "white"
                                font.family: CenterTokens.fontFamily
                                font.pixelSize: CenterTokens.body
                                font.weight: Font.DemiBold
                            }
                            Item { Layout.fillWidth: true }
                            AppButton {
                                Layout.preferredHeight: 30
                                text: qsTr("Mở browser")
                                leadingIcon: "ui/external-link"
                                subtle: true
                                iconTone: "white"
                                textTone: "white"
                                leftPadding: 8
                                rightPadding: 8
                                enabled: Boolean(root.selectedProfile.profileId)
                                onClicked: root.profileAction("browser.profile.launch")
                            }
                            AppButton {
                                Layout.preferredHeight: 30
                                text: qsTr("Kiểm tra đăng nhập")
                                leadingIcon: "semantic/shield-check"
                                subtle: true
                                iconTone: "white"
                                textTone: "white"
                                leftPadding: 8
                                rightPadding: 8
                                enabled: Boolean(root.selectedProfile.profileId)
                                onClicked: root.profileAction("browser.profile.scan")
                            }
                            AppButton {
                                Layout.preferredHeight: 30
                                text: qsTr("Preflight")
                                leadingIcon: "ui/play"
                                subtle: true
                                iconTone: "white"
                                textTone: "white"
                                leftPadding: 8
                                rightPadding: 8
                                enabled: Boolean(root.selectedProfile.profileId)
                                onClicked: root.profileAction("browser.profile.scan")
                            }
                            AppButton {
                                Layout.preferredHeight: 30
                                text: qsTr("Đóng browser")
                                leadingIcon: "ui/close"
                                subtle: true
                                iconTone: "white"
                                textTone: "white"
                                leftPadding: 8
                                rightPadding: 8
                                enabled: String(root.selectedProfile.status || "") === "user_open"
                                onClicked: root.profileAction("browser.profile.close")
                            }
                        }
                    }
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 34
                        color: CenterTokens.panelSoft
                        border.width: 1
                        border.color: CenterTokens.border
                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            spacing: 9
                            Rectangle {
                                Layout.preferredWidth: 18
                                Layout.preferredHeight: 18
                                radius: 3
                                color: CenterTokens.panel
                                border.width: 1
                                border.color: CenterTokens.borderStrong
                                Accessible.ignored: true
                            }
                            HeaderCell { Layout.fillWidth: true; text: qsTr("Hồ sơ") }
                            HeaderCell { Layout.minimumWidth: 105; Layout.preferredWidth: 105; Layout.maximumWidth: 105; text: qsTr("Nền tảng") }
                            HeaderCell { Layout.minimumWidth: 150; Layout.preferredWidth: 150; Layout.maximumWidth: 150; text: qsTr("Kênh liên kết") }
                            HeaderCell { Layout.minimumWidth: 130; Layout.preferredWidth: 130; Layout.maximumWidth: 130; text: qsTr("Browser") }
                            HeaderCell { Layout.minimumWidth: 125; Layout.preferredWidth: 125; Layout.maximumWidth: 125; text: qsTr("Đăng nhập") }
                            HeaderCell { Layout.minimumWidth: 100; Layout.preferredWidth: 100; Layout.maximumWidth: 100; text: qsTr("Đang dùng"); visible: !root.compactLayout }
                            HeaderCell { Layout.minimumWidth: 105; Layout.preferredWidth: 105; Layout.maximumWidth: 105; text: qsTr("Lần kiểm tra"); visible: !root.compactLayout }
                            Item { Layout.minimumWidth: 22; Layout.preferredWidth: 22; Layout.maximumWidth: 22 }
                        }
                    }
                    ListView {
                        id: profileList
                        objectName: "publishingProfileList"
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        model: root.profileModel
                        clip: true
                        reuseItems: true
                        boundsBehavior: Flickable.StopAtBounds
                        delegate: Item {
                            id: profileItem
                            required property int index
                            required property var modelData
                            readonly property bool rowMatches: root.matches(modelData)
                            width: ListView.view.width
                            height: rowMatches ? 46 : 0
                            visible: rowMatches
                            Rectangle {
                                anchors.fill: parent
                                color: root.selectedIndex === profileItem.index
                                    ? CenterTokens.primarySoft : CenterTokens.panel
                                border.width: 1
                                border.color: root.selectedIndex === profileItem.index
                                    ? Qt.rgba(CenterTokens.primary.r, CenterTokens.primary.g, CenterTokens.primary.b, 0.45)
                                    : CenterTokens.border
                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 10
                                    anchors.rightMargin: 10
                                    spacing: 9
                                    Rectangle {
                                        Layout.preferredWidth: 18
                                        Layout.preferredHeight: 18
                                        radius: 3
                                        color: root.selectedIndex === profileItem.index
                                            ? CenterTokens.primary : CenterTokens.panel
                                        border.width: 1
                                        border.color: root.selectedIndex === profileItem.index
                                            ? CenterTokens.primary : CenterTokens.borderStrong
                                        UiIcon {
                                            anchors.centerIn: parent
                                            visible: root.selectedIndex === profileItem.index
                                            name: "ui/check"
                                            tone: "white"
                                            iconSize: 12
                                        }
                                        Accessible.ignored: true
                                    }
                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 0
                                        Text {
                                            Layout.fillWidth: true
                                            text: String(profileItem.modelData.label || qsTr("Hồ sơ"))
                                            color: CenterTokens.text
                                            font.family: CenterTokens.fontFamily
                                            font.pixelSize: CenterTokens.body
                                            font.weight: Font.DemiBold
                                            elide: Text.ElideRight
                                        }
                                        MetaText { Layout.fillWidth: true; text: String(profileItem.modelData.profileId || "—") }
                                    }
                                    RowLayout {
                                        Layout.minimumWidth: 105
                                        Layout.preferredWidth: 105
                                        Layout.maximumWidth: 105
                                        PlatformIcon {
                                            platform: String(profileItem.modelData.platform || "generic")
                                            iconSize: 15
                                            Layout.preferredWidth: 15
                                            Layout.preferredHeight: 15
                                        }
                                        MetaText { Layout.fillWidth: true; text: Fmt.platformLabel(profileItem.modelData.platform) }
                                    }
                                    MetaText { Layout.minimumWidth: 150; Layout.preferredWidth: 150; Layout.maximumWidth: 150; text: String(profileItem.modelData.accountHandle || profileItem.modelData.channelId || "—") }
                                    MetaText { Layout.minimumWidth: 130; Layout.preferredWidth: 130; Layout.maximumWidth: 130; text: String(profileItem.modelData.browserKey || "—") }
                                    CenterStatusBadge {
                                        Layout.minimumWidth: 125
                                        Layout.preferredWidth: 125
                                        Layout.maximumWidth: 125
                                        text: Fmt.statusLabel(profileItem.modelData.authState,
                                            profileItem.modelData.statusLabel)
                                        status: Fmt.statusKind(profileItem.modelData.authState)
                                        iconName: profileItem.modelData.authState === "verified"
                                            ? "semantic/check-circle" : "semantic/alert-triangle"
                                    }
                                    CenterStatusBadge {
                                        Layout.minimumWidth: 100
                                        Layout.preferredWidth: 100
                                        Layout.maximumWidth: 100
                                        text: Boolean(profileItem.modelData.busy) ? qsTr("Đang dùng") : qsTr("Không có")
                                        status: Boolean(profileItem.modelData.busy) ? "info" : "neutral"
                                        visible: !root.compactLayout
                                    }
                                    MetaText {
                                        Layout.minimumWidth: 105
                                        Layout.preferredWidth: 105
                                        Layout.maximumWidth: 105
                                        text: Fmt.timeLabel(profileItem.modelData.authVerifiedAt || profileItem.modelData.updatedAt)
                                        visible: !root.compactLayout
                                    }
                                    AppButton {
                                        Layout.minimumWidth: 22
                                        Layout.preferredWidth: 22
                                        Layout.maximumWidth: 22
                                        text: ""
                                        leadingIcon: "ui/more-horizontal"
                                        subtle: true
                                        leftPadding: 3
                                        rightPadding: 3
                                    }
                                }
                                TapHandler { onTapped: root.selectedIndex = profileItem.index }
                            }
                        }
                        Text {
                            anchors.centerIn: parent
                            visible: profileList.count === 0
                            text: qsTr("Chưa có hồ sơ đăng trong trang hiện tại.")
                            color: CenterTokens.faint
                            font.family: CenterTokens.fontFamily
                            font.pixelSize: CenterTokens.body
                        }
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        MetaText {
                            Layout.fillWidth: true
                            text: qsTr("Hiển thị ") + String(root.profileModel ? root.profileModel.count : 0)
                                + qsTr(" / ") + String(root.totalProfiles) + qsTr(" hồ sơ")
                        }
                        AppButton { text: qsTr("Trước"); subtle: true; enabled: false }
                        CenterStatusBadge { text: "1"; status: "info" }
                        AppButton {
                            text: qsTr("Sau")
                            subtle: true
                            enabled: Boolean((root.plane.profilePage || {}).hasMore)
                            onClicked: root.plane.callTool("browser.inventory.snapshot", {
                                "query": root.query,
                                "platform": root.platformFilter,
                                "auth_state": root.statusFilter,
                                "limit": 20,
                                "offset": 20
                            })
                        }
                    }
                }
            }

            CenterPanel {
                objectName: "publishingProfileInspector"
                Layout.minimumWidth: 0
                Layout.preferredWidth: root.compactLayout
                    ? Math.max(330, root.width * 0.28)
                    : Math.max(390, root.width * 0.35)
                Layout.fillHeight: true
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: root.compactLayout ? 10 : CenterTokens.panelPadding
                    spacing: root.compactLayout ? 6 : 10
                    SectionTitle { text: qsTr("Chi tiết hồ sơ") }
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10
                        PlatformIcon {
                            platform: String(root.selectedProfile.platform || "generic")
                            iconSize: 28
                            Layout.preferredWidth: 28
                            Layout.preferredHeight: 28
                        }
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 1
                            Text {
                                Layout.fillWidth: true
                                text: String(root.selectedProfile.label || qsTr("Chọn một hồ sơ"))
                                color: CenterTokens.text
                                font.family: CenterTokens.fontFamily
                                font.pixelSize: CenterTokens.sectionTitle + 1
                                font.weight: Font.DemiBold
                                elide: Text.ElideRight
                            }
                            CenterStatusBadge {
                                text: Fmt.statusLabel(root.selectedProfile.authState,
                                    root.selectedProfile.statusLabel)
                                status: Fmt.statusKind(root.selectedProfile.authState)
                                iconName: root.selectedProfile.authState === "verified"
                                    ? "semantic/check-circle" : "semantic/alert-triangle"
                            }
                        }
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12
                        GridLayout {
                            Layout.fillWidth: true
                            columns: 2
                            columnSpacing: 12
                            rowSpacing: 6
                            MetaText { text: qsTr("ID hồ sơ") }
                            MetaText { text: String(root.selectedProfile.profileId || "—"); color: CenterTokens.text }
                            MetaText { text: qsTr("Nền tảng") }
                            MetaText { text: Fmt.platformLabel(root.selectedProfile.platform); color: CenterTokens.text }
                            MetaText { text: qsTr("Kênh") }
                            MetaText { text: String(root.selectedProfile.accountHandle || root.selectedProfile.channelId || "—"); color: CenterTokens.text }
                            MetaText { text: qsTr("Kênh liên kết") }
                            MetaText {
                                text: String(root.selectedProfile.channelBindingId || "—")
                                    + (root.selectedProfile.channelBindingVersion
                                        ? " v" + String(root.selectedProfile.channelBindingVersion) : "")
                                color: CenterTokens.text
                            }
                            MetaText { text: qsTr("Browser profile") }
                            MetaText { text: String(root.selectedProfile.browserKey || "—"); color: CenterTokens.text }
                            MetaText { text: qsTr("Proxy identity") }
                            MetaText { text: String(root.selectedProfile.proxyIdentity || "—"); color: CenterTokens.text }
                            MetaText { text: qsTr("Timezone") }
                            MetaText { text: String(root.selectedProfile.timezoneName || "—"); color: CenterTokens.text }
                        }
                        Rectangle {
                            Layout.preferredWidth: 1
                            Layout.fillHeight: true
                            color: CenterTokens.border
                            visible: !root.compactLayout
                        }
                        GridLayout {
                            Layout.preferredWidth: 235
                            columns: 2
                            columnSpacing: 10
                            rowSpacing: 8
                            MetaText { text: qsTr("Đăng nhập") }
                            MetaText {
                                text: Fmt.statusLabel(root.selectedProfile.authState,
                                    root.selectedProfile.statusLabel)
                                color: root.selectedProfile.authState === "verified"
                                    ? CenterTokens.success : CenterTokens.warning
                            }
                            MetaText { text: qsTr("Thực hiện tại") }
                            MetaText {
                                text: Boolean(root.selectedProfile.busy)
                                    ? qsTr("Đang có work order") : qsTr("Không có")
                                color: CenterTokens.text
                            }
                            MetaText { text: qsTr("Lần xuất bản cuối") }
                            MetaText {
                                text: root.selectedLastAttempt.attemptId
                                    ? Fmt.statusLabel(root.selectedLastAttempt.status,
                                        root.selectedLastAttempt.statusLabel) + " · "
                                        + Fmt.timeLabel(root.selectedLastAttempt.completedAt
                                            || root.selectedLastAttempt.updatedAt)
                                    : qsTr("Chưa có")
                                color: root.selectedLastAttempt.status === "succeeded"
                                    ? CenterTokens.success : CenterTokens.text
                            }
                            visible: !root.compactLayout
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10
                        CenterPanel {
                            Layout.fillWidth: true
                            Layout.preferredWidth: root.compactLayout ? 1 : 239
                            Layout.preferredHeight: root.compactLayout ? 130 : 142
                            elevated: true
                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 10
                                spacing: 7
                                SectionTitle { text: qsTr("Kiểm tra sức khỏe") }
                                Repeater {
                                    model: [
                                        {"key": "runtime", "label": qsTr("Browser runtime")},
                                        {"key": "identity", "label": qsTr("Identity match")},
                                        {"key": "binding", "label": qsTr("Channel binding")},
                                        {"key": "profile", "label": qsTr("Profile directory")}
                                    ]
                                    delegate: RowLayout {
                                        id: healthRow
                                        required property var modelData
                                        Layout.fillWidth: true
                                        UiIcon {
                                            name: root.healthOk(root.selectedProfile, healthRow.modelData.key)
                                                ? "semantic/check-circle" : "semantic/alert-triangle"
                                            tone: root.healthOk(root.selectedProfile, healthRow.modelData.key)
                                                ? CenterTokens.success : CenterTokens.warning
                                            iconSize: 13
                                            Layout.preferredWidth: 13
                                            Layout.preferredHeight: 13
                                        }
                                        MetaText { Layout.fillWidth: true; text: String(healthRow.modelData.label) }
                                        MetaText {
                                            text: root.healthOk(root.selectedProfile, healthRow.modelData.key)
                                                ? qsTr("Sẵn sàng") : qsTr("Cần kiểm tra")
                                            color: root.healthOk(root.selectedProfile, healthRow.modelData.key)
                                                ? CenterTokens.success : CenterTokens.warning
                                        }
                                    }
                                }
                            }
                        }
                        CenterPanel {
                            Layout.fillWidth: true
                            Layout.preferredWidth: root.compactLayout ? 1 : 310
                            Layout.preferredHeight: root.compactLayout ? 130 : 142
                            elevated: true
                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: root.compactLayout ? 8 : 10
                                spacing: 8
                                SectionTitle { text: qsTr("Thao tác") }
                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 3
                                    AppButton {
                                        Layout.fillWidth: true
                                        Layout.minimumWidth: 0
                                        text: root.compactLayout ? qsTr("Mở") : qsTr("Mở đăng nhập")
                                        leadingIcon: root.compactLayout ? "" : "ui/external-link"
                                        iconSize: 12
                                        leftPadding: 4
                                        rightPadding: 4
                                        font.pixelSize: CenterTokens.metadata + 1
                                        enabled: Boolean(root.selectedProfile.profileId)
                                        onClicked: root.profileAction("browser.profile.launch")
                                    }
                                    AppButton {
                                        Layout.fillWidth: true
                                        Layout.minimumWidth: 0
                                        text: root.compactLayout ? qsTr("Quét") : qsTr("Kiểm tra lại")
                                        leadingIcon: root.compactLayout ? "" : "ui/refresh-cw"
                                        iconSize: 12
                                        leftPadding: 4
                                        rightPadding: 4
                                        font.pixelSize: CenterTokens.metadata + 1
                                        enabled: Boolean(root.selectedProfile.profileId)
                                        onClicked: root.profileAction("browser.profile.scan")
                                    }
                                    AppButton {
                                        Layout.fillWidth: true
                                        Layout.minimumWidth: 0
                                        text: root.compactLayout ? qsTr("Đóng") : qsTr("Đóng browser")
                                        leadingIcon: root.compactLayout ? "" : "ui/close"
                                        iconSize: 12
                                        leftPadding: 4
                                        rightPadding: 4
                                        font.pixelSize: CenterTokens.metadata + 1
                                        enabled: String(root.selectedProfile.status || "") === "user_open"
                                        onClicked: root.profileAction("browser.profile.close")
                                    }
                                }
                                AppButton {
                                    Layout.fillWidth: true
                                    text: qsTr("Chạy preflight")
                                    leadingIcon: "semantic/shield-check"
                                    primary: true
                                    enabled: Boolean(root.selectedProfile.profileId)
                                    onClicked: root.profileAction("browser.profile.scan")
                                }
                            }
                        }
                    }

                    Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: CenterTokens.border }
                    SectionTitle { text: qsTr("Lịch sử thao tác gần nhất") }
                    Repeater {
                        model: [
                            {"label": qsTr("Xác minh đăng nhập"), "value": Fmt.timeLabel(root.selectedProfile.authVerifiedAt)},
                            {"label": qsTr("Cập nhật hồ sơ"), "value": Fmt.timeLabel(root.selectedProfile.updatedAt)},
                            {"label": qsTr("Xuất bản gần nhất"), "value": root.selectedLastAttempt.attemptId
                                ? Fmt.statusLabel(root.selectedLastAttempt.status,
                                    root.selectedLastAttempt.statusLabel) + " · "
                                    + Fmt.timeLabel(root.selectedLastAttempt.completedAt
                                        || root.selectedLastAttempt.updatedAt)
                                : qsTr("Chưa có")},
                            {"label": qsTr("Lỗi gần nhất"), "value": String(root.selectedProfile.lastError || qsTr("Không có"))}
                        ]
                        delegate: RowLayout {
                            id: auditRow
                            required property var modelData
                            Layout.fillWidth: true
                            UiIcon {
                                name: "ui/history"
                                tone: CenterTokens.muted
                                iconSize: 13
                                Layout.preferredWidth: 13
                                Layout.preferredHeight: 13
                            }
                            MetaText { Layout.fillWidth: true; text: String(auditRow.modelData.label) }
                            MetaText {
                                Layout.preferredWidth: root.compactLayout ? 125 : 210
                                text: String(auditRow.modelData.value)
                            }
                        }
                    }
                    Item { Layout.fillHeight: true }
                    Text {
                        Layout.fillWidth: true
                        text: qsTr("Không hiển thị cookie, token, proxy credential hoặc secret browser trong UI này.")
                        color: CenterTokens.faint
                        font.family: CenterTokens.fontFamily
                        font.pixelSize: CenterTokens.metadata
                        wrapMode: Text.Wrap
                    }
                }
            }
        }
    }

    Dialog {
        id: createDialog
        modal: true
        anchors.centerIn: Overlay.overlay
        title: qsTr("Thêm hồ sơ đăng")
        width: 440
        standardButtons: Dialog.Cancel | Dialog.Ok
        onAccepted: root.plane.callTool("browser.profile.create", {
            "platform": String(createPlatform.currentValue || "youtube"),
            "label": createLabel.text.trim()
        })
        contentItem: ColumnLayout {
            spacing: 10
            AppComboBox {
                id: createPlatform
                objectName: "publishingProfileCreatePlatform"
                Layout.fillWidth: true
                model: [
                    {"text": "YouTube", "value": "youtube"},
                    {"text": "TikTok", "value": "tiktok"},
                    {"text": "Facebook", "value": "facebook"}
                ]
                textRole: "text"
                valueRole: "value"
            }
            TextField {
                id: createLabel
                Layout.fillWidth: true
                placeholderText: qsTr("Tên hiển thị của hồ sơ")
                selectByMouse: true
            }
        }
    }

    Dialog {
        id: bulkDialog
        modal: true
        anchors.centerIn: Overlay.overlay
        title: qsTr("Nhập hồ sơ hàng loạt")
        width: Math.min(660, root.width - 80)
        standardButtons: Dialog.Cancel | Dialog.Ok
        onAccepted: root.plane.callTool("browser.import.preview", {
            "format": "json_lines",
            "content": bulkInput.text
        })
        contentItem: ColumnLayout {
            spacing: 9
            TextArea {
                id: bulkInput
                Layout.fillWidth: true
                Layout.preferredHeight: 220
                placeholderText: qsTr("Mỗi dòng là một object hồ sơ hợp lệ theo schema import…")
                selectByMouse: true
                wrapMode: TextEdit.NoWrap
            }
            Text {
                Layout.fillWidth: true
                text: qsTr("Bước này chỉ preview và freeze import. Thực thi là bước xác nhận riêng để tránh tạo nhầm số lượng lớn.")
                color: CenterTokens.muted
                font.family: CenterTokens.fontFamily
                font.pixelSize: CenterTokens.metadata + 1
                wrapMode: Text.Wrap
            }
        }
    }
}
