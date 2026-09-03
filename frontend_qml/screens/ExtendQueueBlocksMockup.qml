pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../components"
import "../theme"

Rectangle {
    id: root

    objectName: "extendQueueBlocksMockup"
    implicitWidth: 1920
    implicitHeight: 1080
    color: VfTheme.appBackground

    property var sampleJobs: [
        {
            id: "extend-root-ready",
            row_id: "extend-root-ready",
            title: "01 · Cận cảnh lá dừa",
            prompt: "Cận cảnh lá dừa tươi dưới giọt nước, ánh sáng sớm.",
            feature: "text_video",
            tab_source: "extend_panel",
            status: "complete",
            progress: 100,
            job_progress: 100,
            progress_message: "Cảnh ROOT đã hoàn thành.",
            aspect_ratio: "16:9",
            model: "Veo 3.1 · Lite",
            thumbnail_url: "data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 320 180'><defs><linearGradient id='g' x1='0' y1='0' x2='1' y2='1'><stop stop-color='%230B3D2E'/><stop offset='1' stop-color='%234CAF50'/></linearGradient></defs><rect width='320' height='180' fill='url(%23g)'/><path d='M-20 150 Q95 15 335 70' stroke='%23A7F3D0' stroke-width='24' fill='none'/><path d='M20 175 Q130 45 330 92' stroke='%2322C55E' stroke-width='12' fill='none'/><circle cx='178' cy='72' r='12' fill='%23E0F2FE' fill-opacity='.85'/><polygon points='144,66 144,114 184,90' fill='white' fill-opacity='.9'/></svg>",
            assets: [
                {
                    id: "root-ref-1",
                    media_id: "root-ref-1",
                    name: "Ảnh ROOT",
                    thumbnail_url: "data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 80 80'><rect width='80' height='80' fill='%23166534'/><path d='M-5 65 Q30 5 90 25' stroke='%2386EFAC' stroke-width='12' fill='none'/></svg>"
                }
            ],
            can_edit: true,
            can_retry: true,
            can_delete: true
        },
        {
            id: "extend-scene-running",
            row_id: "extend-scene-running",
            title: "02 · Bàn tay đan lá dừa",
            prompt: "Bàn tay khéo léo đan lá dừa, ánh sáng ban ngày.",
            feature: "extend_video",
            tab_source: "extend_panel",
            status: "generating",
            progress: 42,
            job_progress: 42,
            progress_message: "Đang render cảnh nối tiếp 1.1...",
            aspect_ratio: "16:9",
            model: "Veo 3.1 · Fast 8s",
            thumbnail_url: "data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 320 180'><defs><linearGradient id='g2' x1='0' y1='0' x2='1' y2='1'><stop stop-color='%2392400E'/><stop offset='.55' stop-color='%23D6A46B'/><stop offset='1' stop-color='%2314532D'/></linearGradient></defs><rect width='320' height='180' fill='url(%23g2)'/><ellipse cx='128' cy='74' rx='54' ry='28' fill='%23F1C8A4'/><ellipse cx='205' cy='108' rx='60' ry='26' fill='%23E7B98E'/><path d='M25 145 L300 42' stroke='%2355A868' stroke-width='18'/><polygon points='144,66 144,114 184,90' fill='white' fill-opacity='.9'/></svg>",
            assets: [
                {
                    id: "previous-output",
                    media_id: "previous-output",
                    name: "Output cảnh 1",
                    thumbnail_url: "data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 80 80'><rect width='80' height='80' fill='%23166534'/><path d='M-5 65 Q30 5 90 25' stroke='%2386EFAC' stroke-width='12' fill='none'/></svg>"
                }
            ],
            can_edit: true,
            can_retry: true,
            can_delete: true
        },
        {
            id: "extend-scene-waiting",
            row_id: "extend-scene-waiting",
            title: "03 · Lắp ráp khung siêu xe",
            prompt: "Các mảnh lá dừa được lắp ghép thành khung siêu xe.",
            feature: "extend_video",
            tab_source: "extend_panel",
            status: "queued",
            progress: 0,
            job_progress: 0,
            progress_message: "Chờ đầu ra của cảnh trước.",
            aspect_ratio: "16:9",
            model: "Veo 3.1 · Fast 8s",
            thumbnail_placeholder: "CHỜ CẢNH TRƯỚC",
            assets: [
                {
                    id: "queued-input",
                    media_id: "queued-input",
                    name: "Đầu vào kế tiếp"
                }
            ],
            can_edit: true,
            can_retry: false,
            can_delete: true
        }
    ]

    ListModel {
        id: queueModel

        ListElement {
            sequence: "1"
            kind: "ROOT"
            summary: "Cận cảnh lá dừa tươi với giọt nước, ánh sáng sớm, độ chi tiết cao."
            duration: "8s"
            mode: "T2V"
            modelName: "Veo 3.1 · Lite"
            statusLabel: "Hoàn thành"
            statusTone: "complete"
            progress: 100
            dependency: "media đầu ra → đầu vào cảnh kế"
        }
        ListElement {
            sequence: "1.1"
            kind: "EXTEND"
            summary: "Bàn tay khéo léo đan lá dừa; chuyển động liền mạch từ cảnh ROOT."
            duration: "8s"
            mode: "EXTEND"
            modelName: "Veo 3.1 · Fast"
            statusLabel: "Đang chạy 42%"
            statusTone: "running"
            progress: 42
            dependency: ""
        }
        ListElement {
            sequence: "1.2"
            kind: "EXTEND"
            summary: "Các mảnh lá dừa được lắp ghép thành khung siêu xe, ánh sáng tự nhiên."
            duration: "8s"
            mode: "EXTEND"
            modelName: "Veo 3.1 · Fast"
            statusLabel: "Chờ đầu ra cảnh trước"
            statusTone: "blocked"
            progress: 0
            dependency: ""
        }
        ListElement {
            sequence: "1.3"
            kind: "EXTEND"
            summary: "Thân xe hoàn thiện từ lá dừa, các chi tiết uốn cong mượt mà."
            duration: "8s"
            mode: "EXTEND"
            modelName: "Veo 3.1 · Fast"
            statusLabel: "Đang chờ"
            statusTone: "waiting"
            progress: 0
            dependency: ""
        }
        ListElement {
            sequence: "1.4"
            kind: "EXTEND"
            summary: "Siêu xe lá dừa hoàn chỉnh di chuyển trên đường quê, ánh sáng chiều."
            duration: "8s"
            mode: "EXTEND"
            modelName: "Veo 3.1 · Fast"
            statusLabel: "Đang chờ"
            statusTone: "waiting"
            progress: 0
            dependency: ""
        }
    }

    component NavItem: Rectangle {
        id: navItem

        property string label: ""
        property bool selected: false

        implicitHeight: VfTheme.dp(34)
        implicitWidth: navLabel.implicitWidth + VfTheme.dp(28)
        radius: VfTheme.dp(8)
        color: selected ? VfTheme.cyanFill : "transparent"

        Text {
            id: navLabel
            anchors.centerIn: parent
            text: navItem.label
            color: navItem.selected ? VfTheme.text : VfTheme.textMuted
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.dp(10)
            font.weight: navItem.selected ? VfTheme.weightStrong : VfTheme.weightControl
        }
    }

    component ConfigField: Rectangle {
        id: configField

        property string label: ""
        property string value: ""
        property color accent: VfTheme.primary

        radius: VfTheme.dp(8)
        color: VfTheme.surface
        border.color: VfTheme.borderBox
        Layout.fillWidth: true
        Layout.preferredHeight: VfTheme.dp(52)

        ColumnLayout {
            anchors.fill: parent
            anchors.leftMargin: VfTheme.dp(10)
            anchors.rightMargin: VfTheme.dp(10)
            anchors.topMargin: VfTheme.dp(6)
            anchors.bottomMargin: VfTheme.dp(6)
            spacing: VfTheme.dp(2)

            RowLayout {
                Layout.fillWidth: true
                spacing: VfTheme.dp(5)

                Rectangle {
                    Layout.preferredWidth: VfTheme.dp(3)
                    Layout.preferredHeight: VfTheme.dp(11)
                    radius: width / 2
                    color: configField.accent
                }

                Text {
                    Layout.fillWidth: true
                    text: configField.label
                    color: VfTheme.textMuted
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(9)
                    font.weight: VfTheme.weightStrong
                    elide: Text.ElideRight
                }
            }

            Text {
                Layout.fillWidth: true
                text: configField.value
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(10)
                font.weight: VfTheme.weightControl
                elide: Text.ElideRight
            }
        }
    }

    component SmallChip: Rectangle {
        id: chip

        property string label: ""
        property string tone: "neutral"
        property bool selected: false

        readonly property color toneColor: {
            if (tone === "success")
                return VfTheme.greenBorder
            if (tone === "primary")
                return VfTheme.primary
            if (tone === "warning")
                return VfTheme.amberBorder
            return VfTheme.borderStrong
        }

        implicitHeight: VfTheme.dp(28)
        implicitWidth: Math.max(VfTheme.dp(54), chipText.implicitWidth + VfTheme.dp(20))
        radius: VfTheme.dp(7)
        color: selected
            ? (tone === "success" ? VfTheme.greenFill : VfTheme.blueFill)
            : VfTheme.surface
        border.color: selected ? toneColor : VfTheme.borderBox

        Text {
            id: chipText
            anchors.centerIn: parent
            text: chip.label
            color: chip.selected
                ? (chip.tone === "success" ? VfTheme.greenText : VfTheme.blueText)
                : VfTheme.textMuted
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.dp(10)
            font.weight: VfTheme.weightStrong
        }
    }

    component AssetSlot: Rectangle {
        id: assetSlot

        implicitHeight: VfTheme.dp(50)
        radius: VfTheme.dp(8)
        color: VfTheme.surfaceSoft
        border.color: VfTheme.blueBorderSoft
        border.width: 1

        Row {
            anchors.centerIn: parent
            spacing: VfTheme.dp(6)

            Text {
                text: "+"
                color: VfTheme.primary
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(17)
                font.weight: Font.Medium
            }

            Text {
                text: "Thêm ảnh/video"
                color: VfTheme.textSubtle
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(9)
            }
        }
    }

    component QueueRow: Item {
        id: queueRow

        required property int index
        required property string sequence
        required property string kind
        required property string summary
        required property string duration
        required property string mode
        required property string modelName
        required property string statusLabel
        required property string statusTone
        required property int progress
        required property string dependency

        readonly property color accent: statusTone === "complete"
            ? VfTheme.greenBorder
            : statusTone === "running"
                ? VfTheme.primary
                : statusTone === "blocked"
                    ? VfTheme.amberBorder
                    : VfTheme.borderStrong
        readonly property color tint: statusTone === "complete"
            ? VfTheme.greenFill
            : statusTone === "running"
                ? VfTheme.blueFill
                : statusTone === "blocked"
                    ? VfTheme.amberFill
                    : VfTheme.surfaceSoft

        width: ListView.view ? ListView.view.width : VfTheme.dp(760)
        height: dependency.length > 0 ? VfTheme.dp(116) : VfTheme.dp(94)

        Rectangle {
            x: VfTheme.dp(13)
            y: VfTheme.dp(22)
            width: VfTheme.dp(2)
            height: queueRow.height - VfTheme.dp(4)
            visible: queueRow.index < 4
            color: queueRow.statusTone === "complete" ? VfTheme.primary : VfTheme.borderStrong
        }

        Rectangle {
            x: VfTheme.dp(6)
            y: VfTheme.dp(15)
            width: VfTheme.dp(16)
            height: width
            radius: width / 2
            color: queueRow.accent
            border.width: VfTheme.dp(3)
            border.color: queueRow.tint
        }

        Rectangle {
            anchors.left: parent.left
            anchors.leftMargin: VfTheme.dp(34)
            anchors.right: parent.right
            anchors.top: parent.top
            height: VfTheme.dp(78)
            radius: VfTheme.dp(10)
            color: queueRow.statusTone === "running" ? VfTheme.blueFill : VfTheme.surface
            border.color: queueRow.statusTone === "running" ? VfTheme.blueBorder : VfTheme.borderBox

            RowLayout {
                anchors.fill: parent
                anchors.margins: VfTheme.dp(10)
                spacing: VfTheme.dp(10)

                Rectangle {
                    Layout.preferredWidth: VfTheme.dp(92)
                    Layout.preferredHeight: VfTheme.dp(32)
                    radius: VfTheme.dp(8)
                    color: queueRow.kind === "ROOT" ? VfTheme.greenFill : VfTheme.blueFill
                    border.color: queueRow.kind === "ROOT" ? VfTheme.greenBorderSoft : VfTheme.blueBorderSoft

                    Text {
                        anchors.centerIn: parent
                        text: queueRow.sequence + " · " + queueRow.kind
                        color: queueRow.kind === "ROOT" ? VfTheme.greenText : VfTheme.blueText
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.dp(10)
                        font.weight: VfTheme.weightStrong
                    }
                }

                Text {
                    Layout.fillWidth: true
                    Layout.minimumWidth: 0
                    text: queueRow.summary
                    color: VfTheme.text
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(10)
                    wrapMode: Text.WordWrap
                    maximumLineCount: 2
                    elide: Text.ElideRight
                }

                SmallChip { label: queueRow.duration }
                SmallChip { label: queueRow.mode }

                ColumnLayout {
                    Layout.preferredWidth: VfTheme.dp(112)
                    spacing: VfTheme.dp(5)

                    Rectangle {
                        Layout.alignment: Qt.AlignRight
                        Layout.preferredHeight: VfTheme.dp(24)
                        Layout.preferredWidth: VfTheme.dp(112)
                        radius: VfTheme.dp(7)
                        color: queueRow.tint
                        border.color: queueRow.accent

                        Text {
                            id: statusText
                            anchors.centerIn: parent
                            text: queueRow.statusLabel
                            color: queueRow.statusTone === "complete"
                                ? VfTheme.greenText
                                : queueRow.statusTone === "running"
                                    ? VfTheme.blueText
                                    : queueRow.statusTone === "blocked"
                                        ? VfTheme.amberText
                                        : VfTheme.textMuted
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.dp(9)
                            font.weight: VfTheme.weightStrong
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: VfTheme.dp(5)
                        radius: height / 2
                        color: VfTheme.border
                        visible: queueRow.progress > 0

                        Rectangle {
                            width: parent.width * Math.max(0, Math.min(100, queueRow.progress)) / 100
                            height: parent.height
                            radius: height / 2
                            color: queueRow.accent
                        }
                    }
                }

            }
        }

        Row {
            visible: queueRow.dependency.length > 0
            anchors.horizontalCenter: parent.horizontalCenter
            y: VfTheme.dp(84)
            spacing: VfTheme.dp(6)

            Text {
                text: "↓"
                color: VfTheme.primary
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(14)
                font.weight: Font.Bold
            }

            Rectangle {
                height: VfTheme.dp(24)
                width: dependencyText.implicitWidth + VfTheme.dp(18)
                radius: VfTheme.dp(7)
                color: VfTheme.surfaceSoft
                border.color: VfTheme.border

                Text {
                    id: dependencyText
                    anchors.centerIn: parent
                    text: queueRow.dependency
                    color: VfTheme.textMuted
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(9)
                }
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: VfTheme.dp(54)
            color: VfTheme.surface
            border.color: VfTheme.border

            RowLayout { // perf-lint: disable=R5
                anchors.fill: parent
                anchors.leftMargin: VfTheme.dp(18)
                anchors.rightMargin: VfTheme.dp(18)
                spacing: VfTheme.dp(12)

                Text {
                    text: "VF"
                    color: VfTheme.primary
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(24)
                    font.weight: Font.Black
                    font.italic: true
                }

                Text {
                    text: "VeoFlow"
                    color: "#0EA5E9"
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(18)
                    font.weight: Font.Bold
                }

                Column {
                    Layout.leftMargin: VfTheme.dp(8)
                    spacing: 0

                    Text {
                        text: "Đối tác xác minh"
                        color: VfTheme.greenText
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.dp(8)
                        font.weight: Font.Bold
                    }
                    Text {
                        text: "VeoFlow Support"
                        color: VfTheme.text
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.dp(9)
                        font.weight: Font.DemiBold
                    }
                }

                Item { Layout.fillWidth: true }

                SmallChip { label: "Vietnamese"; selected: true }
                SmallChip { label: "Trợ giúp"; selected: true }
                SmallChip { label: "Quản lí media" }
                SmallChip { label: "License Active"; tone: "success"; selected: true }
                SmallChip { label: "PAID GEMINI: 206,683 VND"; selected: true }
                SmallChip { label: "FREE USAGE: 1,505,457 VND"; tone: "success"; selected: true }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: VfTheme.dp(40)
            color: "#EDF4FC"
            border.color: VfTheme.border

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: VfTheme.dp(12)
                anchors.rightMargin: VfTheme.dp(12)
                spacing: VfTheme.dp(2)

                NavItem { label: "TRANG CHỦ" }
                NavItem { label: "MASTER PROMPT" }
                NavItem { label: "CLONE VIDEO" }
                NavItem { label: "AUDIO TO VIDEO" }
                NavItem { label: "AFFILIATE" }
                NavItem { label: "RESEARCH LABS" }
                NavItem { label: "VOICE STUDIO" }
                NavItem { label: "AUTO FLOW" }
                NavItem { label: "KÉO DÀI CẢNH"; selected: true }
                NavItem { label: "TIME MACHINE" }
                NavItem { label: "TẠO HÌNH ẢNH" }
                NavItem { label: "TÀI KHOẢN & CÀI ĐẶT" }
                NavItem { label: "LỊCH SỬ TẠO" }
                Item { Layout.fillWidth: true }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: VfTheme.dp(70)
            color: VfTheme.surface
            border.color: VfTheme.border

            RowLayout {
                anchors.fill: parent
                anchors.margins: VfTheme.dp(9)
                spacing: VfTheme.dp(8)

                ConfigField { label: "Tỷ lệ"; value: "16:9"; accent: VfTheme.cyan }
                ConfigField { label: "Chất lượng"; value: "1080p FHD"; accent: VfTheme.amber }
                ConfigField { label: "MODEL ROOT"; value: "Veo 3.1 · Lite 8s"; accent: VfTheme.violet }
                ConfigField { label: "Thư mục lưu"; value: "H:/FLOW"; accent: VfTheme.cyan }
                ConfigField { label: "Style"; value: "Realistic"; accent: VfTheme.violet }
                ConfigField { label: "Thị trường"; value: "Global (Generic)"; accent: VfTheme.greenBorder }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: VfTheme.dp(56)
            color: VfTheme.surfaceSoft
            border.color: VfTheme.border

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: VfTheme.dp(12)
                anchors.rightMargin: VfTheme.dp(12)
                spacing: VfTheme.dp(8)

                VfButton {
                    compact: true
                    text: "Xem trước"
                    actionId: "work_panel.extend_preview"
                }
                VfButton {
                    compact: true
                    text: "Render"
                    actionId: "work_panel.extend_render_video"
                }
                VfButton {
                    compact: true
                    text: "Rules"
                    actionId: "work_panel.extend_rules"
                }
                VfButton {
                    compact: true
                    text: "AUTO Ghép Video"
                    tone: "success"
                    actionId: "work_panel.extend_auto_merge_toggle"
                    minWidth: VfTheme.dp(148)
                }

                Item { Layout.fillWidth: true }

                Rectangle {
                    Layout.preferredHeight: VfTheme.dp(30)
                    Layout.preferredWidth: queueStateText.implicitWidth + VfTheme.dp(30)
                    radius: VfTheme.dp(8)
                    color: VfTheme.greenFill
                    border.color: VfTheme.greenBorderSoft

                    Row {
                        anchors.centerIn: parent
                        spacing: VfTheme.dp(7)

                        Rectangle {
                            anchors.verticalCenter: parent.verticalCenter
                            width: VfTheme.dp(7)
                            height: width
                            radius: width / 2
                            color: VfTheme.greenBorder
                        }
                        Text {
                            id: queueStateText
                            text: "Queue đang chạy cuốn chiếu"
                            color: VfTheme.greenText
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.dp(10)
                            font.weight: VfTheme.weightStrong
                        }
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: VfTheme.dp(10)
            spacing: VfTheme.dp(10)

            Rectangle {
                Layout.preferredWidth: VfTheme.dp(570)
                Layout.fillHeight: true
                radius: VfTheme.dp(12)
                color: VfTheme.surface
                border.color: VfTheme.borderBox

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: VfTheme.dp(14)
                    spacing: VfTheme.dp(10)

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: VfTheme.dp(9)

                        Rectangle {
                            Layout.preferredWidth: VfTheme.dp(28)
                            Layout.preferredHeight: VfTheme.dp(28)
                            radius: VfTheme.dp(8)
                            color: VfTheme.blueFill
                            border.color: VfTheme.blueBorderSoft

                            Text {
                                anchors.centerIn: parent
                                text: "1"
                                color: VfTheme.blueText
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.dp(12)
                                font.weight: Font.Bold
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.minimumWidth: 0
                            spacing: 1

                            Text {
                                text: "Chuẩn bị ý tưởng"
                                color: VfTheme.text
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.dp(14)
                                font.weight: VfTheme.weightTitle
                            }
                            Text {
                                text: "Mô tả điều bạn muốn; AI chuẩn bị chuỗi ROOT → EXTEND."
                                color: VfTheme.textMuted
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.dp(10)
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: VfTheme.dp(154)
                        radius: VfTheme.dp(10)
                        color: VfTheme.surface
                        border.color: VfTheme.blueBorderSoft
                        border.width: 1

                        TextArea {
                            anchors.fill: parent
                            anchors.margins: VfTheme.dp(9)
                            text: "Handmade lá dừa thành siêu xe. Mở đầu bằng cận cảnh giọt nước trên lá, sau đó đan và lắp ghép cuốn chiếu cho tới khi chiếc xe hoàn thiện."
                            placeholderText: "Nhập ý tưởng, kịch bản hoặc yêu cầu..."
                            color: VfTheme.text
                            placeholderTextColor: VfTheme.textSubtle
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.dp(11)
                            wrapMode: TextEdit.Wrap
                            background: Item {}
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: VfTheme.dp(6)

                        SmallChip { label: "T2V"; tone: "primary"; selected: true }
                        SmallChip { label: "I2V" }
                        SmallChip { label: "R2V" }
                        Item { Layout.fillWidth: true }
                        Text {
                            text: "AI tự viết cảnh ROOT từ ý tưởng"
                            color: VfTheme.textSubtle
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.dp(9)
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: VfTheme.dp(9)

                        Text {
                            text: "Model Extend"
                            color: VfTheme.textMuted
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.dp(10)
                            font.weight: VfTheme.weightControl
                        }

                        ComboBox {
                            Layout.fillWidth: true
                            Layout.preferredHeight: VfTheme.dp(34)
                            model: ["Veo 3.1 · Fast 8s — 10cr", "Veo 3.1 · Quality 8s — 20cr"]
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.dp(10)
                        }
                    }

                    Text {
                        Layout.fillWidth: true
                        text: "Tham chiếu (tùy chọn)"
                        color: VfTheme.textMuted
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.dp(10)
                        font.weight: VfTheme.weightControl
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: VfTheme.dp(7)

                        AssetSlot { Layout.fillWidth: true }
                        AssetSlot { Layout.fillWidth: true }
                        AssetSlot { Layout.fillWidth: true }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: VfTheme.dp(42)
                        radius: VfTheme.dp(9)
                        color: VfTheme.surfaceSoft
                        border.color: VfTheme.border

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: VfTheme.dp(12)
                            anchors.rightMargin: VfTheme.dp(12)
                            spacing: VfTheme.dp(8)

                            VfAppIcon {
                                name: "gear"
                                size: VfTheme.dp(16)
                                color: VfTheme.primary
                            }
                            Text {
                                Layout.fillWidth: true
                                text: "Quy tắc & tùy chỉnh"
                                color: VfTheme.text
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.dp(10)
                                font.weight: VfTheme.weightControl
                            }
                            Text {
                                text: "⌄"
                                color: VfTheme.textMuted
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.dp(15)
                            }
                        }
                    }

                    VfButton {
                        Layout.fillWidth: true
                        text: "Tạo kế hoạch & Chạy"
                        tone: "primary"
                        actionId: "work_panel.extend_one_click"
                        minWidth: VfTheme.dp(220)
                    }

                    Text {
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        text: "AI tự tạo ROOT→EXTEND, đưa vào queue và chạy cuốn chiếu"
                        color: VfTheme.textSubtle
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.dp(9)
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.minimumHeight: VfTheme.dp(150)
                        radius: VfTheme.dp(10)
                        color: VfTheme.surfaceSoft
                        border.color: VfTheme.border

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: VfTheme.dp(14)
                            spacing: VfTheme.dp(9)

                            RowLayout {
                                Layout.fillWidth: true

                                Text {
                                    text: "Kế hoạch đã chuẩn bị"
                                    color: VfTheme.text
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.dp(12)
                                    font.weight: VfTheme.weightStrong
                                }
                                Item { Layout.fillWidth: true }
                                SmallChip { label: "Sẵn sàng"; tone: "success"; selected: true }
                            }

                            Text {
                                text: "1 ROOT  ·  5 EXTEND  ·  48 giây"
                                color: VfTheme.text
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.dp(12)
                                font.weight: VfTheme.weightStrong
                            }

                            Text {
                                Layout.fillWidth: true
                                text: "AI đã tạo mạch cảnh liên tục, giữ chủ thể và vật liệu lá dừa xuyên suốt. Queue sẽ lấy output của cảnh trước làm input cho cảnh kế tiếp."
                                color: VfTheme.textMuted
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.dp(10)
                                wrapMode: Text.WordWrap
                                lineHeight: 1.25
                            }

                            Text {
                                text: "Xem prompt chi tiết"
                                color: VfTheme.primary
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.dp(10)
                                font.weight: VfTheme.weightStrong
                            }

                            Item { Layout.fillHeight: true }
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: VfTheme.dp(12)
                color: VfTheme.surface
                border.color: VfTheme.borderBox

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: VfTheme.dp(14)
                    spacing: VfTheme.dp(10)

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: VfTheme.dp(8)

                        Rectangle {
                            Layout.preferredWidth: VfTheme.dp(28)
                            Layout.preferredHeight: VfTheme.dp(28)
                            radius: VfTheme.dp(8)
                            color: VfTheme.blueFill
                            border.color: VfTheme.blueBorderSoft

                            Text {
                                anchors.centerIn: parent
                                text: "2"
                                color: VfTheme.blueText
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.dp(12)
                                font.weight: Font.Bold
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 1

                            Text {
                                text: "Queue cuốn chiếu"
                                color: VfTheme.text
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.dp(14)
                                font.weight: VfTheme.weightTitle
                            }
                            Text {
                                text: "Mỗi cảnh hoàn tất sẽ tự kích hoạt cảnh kế tiếp."
                                color: VfTheme.textMuted
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.dp(10)
                            }
                        }

                        SmallChip { label: "Đang chạy tự động"; tone: "success"; selected: true }

                        VfButton {
                            compact: true
                            text: "Tạm dừng sau cảnh"
                            actionId: "work_panel.pause_queue"
                            minWidth: VfTheme.dp(146)
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: VfTheme.dp(10)

                        Text {
                            text: "2/6 cảnh  ·  33%"
                            color: VfTheme.text
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.dp(11)
                            font.weight: VfTheme.weightStrong
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: VfTheme.dp(7)
                            radius: height / 2
                            color: VfTheme.border

                            Rectangle {
                                width: parent.width * 0.33
                                height: parent.height
                                radius: height / 2
                                gradient: Gradient {
                                    orientation: Gradient.Horizontal
                                    GradientStop { position: 0; color: VfTheme.primary }
                                    GradientStop { position: 1; color: VfTheme.cyan }
                                }
                            }
                        }

                        Text {
                            text: "Tự ghép  ✓"
                            color: VfTheme.greenText
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.dp(10)
                            font.weight: VfTheme.weightStrong
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: VfTheme.dp(10)
                        color: VfTheme.surfaceSoft
                        border.color: VfTheme.border

                        ListView {
                            id: queueList
                            anchors.fill: parent
                            anchors.margins: VfTheme.dp(10)
                            clip: true
                            reuseItems: true
                            cacheBuffer: Math.min(height, VfTheme.dp(520))
                            model: queueModel
                            spacing: 0

                            delegate: QueueRow {}

                            footer: Text {
                                width: parent ? parent.width : 0
                                height: VfTheme.dp(34)
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                text: "Queue chỉ nhận cảnh kế tiếp khi output của cảnh hiện tại đã sẵn sàng."
                                color: VfTheme.textSubtle
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.dp(9)
                            }
                        }
                    }
                }
            }

            Rectangle {
                Layout.preferredWidth: VfTheme.jobRailWidth
                Layout.fillHeight: true
                radius: VfTheme.dp(12)
                color: VfTheme.surface
                border.color: VfTheme.borderBox

                JobPanelWidget {
                    anchors.fill: parent
                    anchors.margins: VfTheme.dp(4)
                    rows: root.sampleJobs
                    stats: ({
                        total: root.sampleJobs.length,
                        queued: 1,
                        generating: 1,
                        completed: 1,
                        failed: 0
                    })
                    route: "extend"
                    autoPageSize: false
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: VfTheme.dp(28)
            color: VfTheme.surface
            border.color: VfTheme.border

            RowLayout { // perf-lint: disable=R5
                anchors.fill: parent
                anchors.leftMargin: VfTheme.dp(10)
                anchors.rightMargin: VfTheme.dp(10)
                spacing: VfTheme.dp(10)

                Rectangle {
                    Layout.preferredWidth: VfTheme.dp(7)
                    Layout.preferredHeight: VfTheme.dp(7)
                    radius: width / 2
                    color: VfTheme.greenBorder
                }
                Text {
                    text: "Ready"
                    color: VfTheme.textMuted
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(9)
                }
                Item { Layout.fillWidth: true }
                SmallChip { label: "Hoàn thành 1"; tone: "success"; selected: true }
                SmallChip { label: "Tokens" }
                SmallChip { label: "Monitor" }
                SmallChip { label: "Lỗi: 0" }
                SmallChip { label: "Log" }
            }
        }
    }
}
