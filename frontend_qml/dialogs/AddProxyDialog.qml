import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../components"
import "../theme"

Dialog {
    id: dialog

    signal acceptedText(string text, string rotateUrl)

    property string statusText: ""
    property bool checking: false

    function resetForm() {
        proxyInput.text = ""
        rotateUrlInput.text = ""
        statusText = ""
        checking = false
        resultsModel.clear()
    }

    function cleanLeadingIcon(value) {
        var text = String(value || "").trim()
        text = text.replace(/^[\uD800-\uDBFF][\uDC00-\uDFFF]️?\s*/, "")
        text = text.replace(/^[☀-➿]️?\s*/, "")
        text = text.replace(/^[⬀-⯿]️?\s*/, "")
        return text.trim()
    }

    function acceptDialog() {
        if (dialog.checking)
            return
        const txt = proxyInput.text.trim()
        if (txt.length === 0) {
            dialog.statusText = "Dán ít nhất 1 proxy (ip:port hoặc ip:port:user:pass)."
            return
        }
        resultsModel.clear()
        dialog.checking = true
        dialog.statusText = "Đang kiểm tra proxy với Flow..."
        dialog.acceptedText(txt, rotateUrlInput.text.trim())
    }

    function applyAcceptResult(result) {
        var response = result || ({})
        if (response.pending) {
            dialog.checking = true
            dialog.statusText = String(response.message || "Đang kiểm tra...")
            return
        }

        dialog.checking = false
        resultsModel.clear()
        const rows = response.results || []
        for (let i = 0; i < rows.length; i++) {
            const r = rows[i] || ({})
            resultsModel.append({
                keyText: String(r.key || ""),
                statusKind: String(r.status || ""),
                typeText: String(r.type || ""),
                rowMessage: String(r.message || "")
            })
        }
        dialog.statusText = String(response.message || "")

        const added = Number(response.added || 0)
        const blocked = (response.google_blocked || []).length
        const deadN = (response.dead || []).length
        const invalidN = (response.invalid || []).length
        // Tất cả LIVE, không rác → dọn ô nhập cho lượt sau.
        if (added > 0 && blocked === 0 && deadN === 0 && invalidN === 0)
            proxyInput.text = ""
    }

    parent: Overlay.overlay
    title: dialog.cleanLeadingIcon((void i18n.revision, i18n.t("settings.add_proxy_title", "Thêm Proxy")))
    header: null
    modal: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    width: VfDialogMetrics.width(parent, 629, 48)
    height: VfDialogMetrics.height(parent, 693, 48)
    x: VfDialogMetrics.centerX(parent, width)
    y: VfDialogMetrics.centerY(parent, height)
    padding: 0
    standardButtons: Dialog.NoButton

    onOpened: dialog.resetForm()

    background: Rectangle {
        color: VfTheme.surface
        radius: VfTheme.radiusPanel
        border.color: VfTheme.borderStrong
        border.width: 1
    }

    ListModel { id: resultsModel }

    contentItem: ColumnLayout {
        anchors.fill: parent
        anchors.margins: VfTheme.dp(14)
        spacing: VfTheme.dp(12)

        Text {
            Layout.fillWidth: true
            text: "Dán proxy — mỗi dòng 1 cái. Mọi loại (HTTP/SOCKS5): ip:port hoặc ip:port:user:pass.\nChỉ proxy LIVE (vào được Flow) mới được import; proxy chết / bị Google chặn IP sẽ bị loại."
            color: VfTheme.textSubtle
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.dp(12)
            wrapMode: Text.WordWrap
        }

        GroupFrame {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: VfTheme.dp(120)
            title: "Danh sách proxy"

            Rectangle {
                anchors.fill: parent
                anchors.leftMargin: VfTheme.dp(12)
                anchors.rightMargin: VfTheme.dp(12)
                anchors.topMargin: VfTheme.dp(26)
                anchors.bottomMargin: VfTheme.dp(12)
                color: VfTheme.surface
                border.color: VfTheme.borderBox
                border.width: 1
                radius: VfTheme.radiusControl

                ScrollView {
                    id: proxyScroll
                    anchors.fill: parent
                    anchors.margins: VfTheme.dp(8)
                    clip: true

                    TextArea {
                        id: proxyInput
                        width: proxyScroll.availableWidth
                        wrapMode: TextEdit.NoWrap
                        enabled: !dialog.checking
                        placeholderText: "Ví dụ:\n192.168.1.1:8000\n10.0.1.3:1080:myuser:mypass"
                        color: VfTheme.text
                        placeholderTextColor: VfTheme.textSubtle
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.fontControl
                        background: null
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: VfTheme.dp(34)
            spacing: VfTheme.dp(8)

            Text {
                text: (void i18n.revision, i18n.t("settings.rotate_url_label", "Link xoay IP:"))
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontControl
            }

            TextField {
                id: rotateUrlInput
                Layout.fillWidth: true
                Layout.preferredHeight: VfTheme.dp(34)
                enabled: !dialog.checking
                placeholderText: "https://api.provider.com/change-ip/... (tùy chọn)"
                selectByMouse: true
                color: VfTheme.text
                placeholderTextColor: VfTheme.textSubtle
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontControl
                background: Rectangle {
                    color: VfTheme.surface
                    border.color: VfTheme.borderBox
                    border.width: 1
                    radius: VfTheme.radiusControl
                }
            }
        }

        GroupFrame {
            Layout.fillWidth: true
            Layout.preferredHeight: Math.min(resultsModel.count * VfTheme.dp(26) + VfTheme.dp(34), VfTheme.dp(230))
            visible: resultsModel.count > 0
            title: "Kết quả kiểm tra"

            VfListView {
                anchors.fill: parent
                anchors.leftMargin: VfTheme.dp(10)
                anchors.rightMargin: VfTheme.dp(10)
                anchors.topMargin: VfTheme.dp(26)
                anchors.bottomMargin: VfTheme.dp(10)
                model: resultsModel
                spacing: VfTheme.dp(2)

                delegate: Item {
                    id: row
                    required property string keyText
                    required property string statusKind
                    required property string typeText
                    required property string rowMessage

                    width: ListView.view ? ListView.view.width : 0
                    height: VfTheme.dp(24)

                    readonly property color kindColor: statusKind === "live"
                        ? VfTheme.greenBorder
                        : (statusKind === "invalid" ? VfTheme.textSubtle : VfTheme.redBorder)
                    readonly property string kindIcon: statusKind === "live"
                        ? "✓"
                        : (statusKind === "google_blocked" ? "⛔"
                        : (statusKind === "dead" ? "✗" : "•"))

                    RowLayout {
                        anchors.fill: parent
                        spacing: VfTheme.dp(8)

                        Text {
                            text: row.kindIcon
                            color: row.kindColor
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.fontControl
                            Layout.preferredWidth: VfTheme.dp(16)
                        }

                        Text {
                            text: row.keyText + (row.typeText.length > 0 ? "  [" + row.typeText + "]" : "")
                            color: VfTheme.text
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.fontTiny
                            elide: Text.ElideRight
                            Layout.preferredWidth: VfTheme.dp(200)
                        }

                        Text {
                            text: row.rowMessage
                            color: row.kindColor
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.fontTiny
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }
                    }
                }
            }
        }

        Text {
            Layout.fillWidth: true
            visible: dialog.statusText.length > 0
            text: dialog.statusText
            color: dialog.checking ? VfTheme.amber : VfTheme.textMuted
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.fontTiny
            wrapMode: Text.WordWrap
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: VfTheme.dp(44)
            spacing: VfTheme.dp(8)

            BusyIndicator {
                running: dialog.checking
                visible: dialog.checking
                implicitWidth: VfTheme.dp(24)
                implicitHeight: VfTheme.dp(24)
            }

            Item { Layout.fillWidth: true }

            VfButton {
                text: "Kiểm tra & Import"
                tone: "primary"
                enabled: !dialog.checking
                minWidth: VfTheme.dp(150)
                implicitHeight: VfTheme.dp(44)
                onClicked: dialog.acceptDialog()
            }

            VfButton {
                text: "Đóng"
                enabled: !dialog.checking
                minWidth: VfTheme.dp(80)
                implicitHeight: VfTheme.dp(44)
                onClicked: dialog.close()
            }
        }
    }

    component GroupFrame: Rectangle {
        id: group
        property string title: ""
        default property alias content: body.data

        radius: VfTheme.dp(6)
        color: VfTheme.surface
        border.color: VfTheme.border
        border.width: 1
        clip: false

        Rectangle {
            x: 22
            y: -2
            width: titleText.implicitWidth + 12
            height: VfTheme.dp(24)
            color: VfTheme.surface

            Text {
                id: titleText
                anchors.centerIn: parent
                text: dialog.cleanLeadingIcon(group.title)
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(20)
                font.weight: VfTheme.weightTitle
                elide: Text.ElideRight
            }
        }

        Item {
            id: body
            anchors.fill: parent
        }
    }
}
