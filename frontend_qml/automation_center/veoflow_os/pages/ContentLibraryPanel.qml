pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ".."

Item {
    id: root
    property int selectedIndex: -1
    readonly property var selectedContent: selectedIndex >= 0
        ? controlPlane.contentModel.get(selectedIndex) : ({})

    function compactId(value) {
        const text = String(value || "")
        return text.length > 18 ? text.slice(0, 10) + "…" + text.slice(-5) : text
    }

    Dialog {
        id: createContentDialog
        anchors.centerIn: parent
        modal: true
        width: 520
        title: "Tạo nội dung mới"
        standardButtons: Dialog.Save | Dialog.Cancel
        onAccepted: controlPlane.callTool("content.create", {
            "channel_id": contentChannel.currentIndex >= 0 ? contentChannel.currentValue : "",
            "title": contentTitle.text.trim(),
            "idea": contentIdea.text.trim(),
            "description": contentDescription.text.trim(),
            "status": "idea",
            "source_type": sourceType.currentValue,
            "aspect_ratio": aspectRatio.currentValue,
            "inputs": {"created_by": "native_operator"}
        })
        contentItem: ColumnLayout {
            spacing: 10
            TextField { id: contentTitle; Layout.fillWidth: true; placeholderText: "Tiêu đề nội dung" }
            TextArea { id: contentIdea; Layout.fillWidth: true; Layout.preferredHeight: 72; placeholderText: "Ý tưởng / brief ngắn"; wrapMode: TextEdit.Wrap }
            TextArea { id: contentDescription; Layout.fillWidth: true; Layout.preferredHeight: 72; placeholderText: "Mô tả phát hành"; wrapMode: TextEdit.Wrap }
            RowLayout {
                Layout.fillWidth: true
                ComboBox { id: contentChannel; Layout.fillWidth: true; model: controlPlane.channelModel; textRole: "displayName"; valueRole: "channelId"; displayText: currentIndex >= 0 ? controlPlane.channelModel.get(currentIndex).displayName : "Chưa gán kênh" }
                ComboBox { id: aspectRatio; Layout.preferredWidth: 120; model: [{text: "9:16", value: "9:16"}, {text: "16:9", value: "16:9"}, {text: "4:3", value: "4:3"}]; textRole: "text"; valueRole: "value" }
            }
            ComboBox { id: sourceType; Layout.fillWidth: true; model: [{text: "Ý tưởng thủ công", value: "idea"}, {text: "AI idea", value: "ai_idea"}, {text: "Video link", value: "video_link"}, {text: "Master", value: "master"}]; textRole: "text"; valueRole: "value" }
        }
        background: Rectangle { radius: Theme.radiusLarge; color: Theme.panel; border.width: 1; border.color: Theme.border }
    }

    Connections {
        target: controlPlane.contentModel
        function onCountChanged() {
            if (controlPlane.contentModel.count === 0) root.selectedIndex = -1
            else if (root.selectedIndex < 0 || root.selectedIndex >= controlPlane.contentModel.count)
                root.selectedIndex = 0
        }
    }
    Component.onCompleted: {
        if (controlPlane.contentModel.count > 0) selectedIndex = 0
        controlPlane.refreshDashboard()
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 10

        Panel {
            Layout.fillWidth: true
            Layout.preferredHeight: 86
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 20
                anchors.rightMargin: 16
                ColumnLayout {
                    spacing: 2
                    Text { text: "THƯ VIỆN SẢN XUẤT"; color: Theme.accent; font.pixelSize: 11; font.weight: Font.Bold; font.letterSpacing: 1.1 }
                    Text { text: "Nội dung"; color: Theme.text; font.pixelSize: 22; font.weight: Font.Bold }
                    Text { text: "Ý tưởng, brief, video đã sản xuất và gói sẵn sàng phát hành"; color: Theme.textFaint; font.pixelSize: 11 }
                }
                Item { Layout.fillWidth: true }
                CountCard { label: "Tổng nội dung"; value: controlPlane.contentModel.count; tone: Theme.accent }
                CountCard { label: "Asset"; value: controlPlane.assetModel.count; tone: Theme.info }
                CountCard { label: "Chờ duyệt"; value: (controlPlane.dashboard.approvals || []).length; tone: Theme.warning }
                AppButton { text: "+  Tạo nội dung"; primary: true; onClicked: createContentDialog.open() }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 10

            Panel {
                Layout.fillWidth: true
                Layout.fillHeight: true
                ColumnLayout {
                    anchors.fill: parent
                    spacing: 0
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 58
                        Layout.leftMargin: 16
                        Layout.rightMargin: 14
                        spacing: 8
                        Text { text: "Luồng nội dung"; color: Theme.text; font.pixelSize: 15; font.weight: Font.Bold }
                        Item { Layout.fillWidth: true }
                        Text { text: controlPlane.contentModel.count + " mục từ Content Warehouse"; color: Theme.textFaint; font.pixelSize: 11 }
                        AppButton { text: "Làm mới"; onClicked: controlPlane.refreshDashboard() }
                    }
                    Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Theme.borderSoft }
                    ContentHeader { Layout.fillWidth: true }
                    ListView {
                        id: contentList
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        reuseItems: true
                        boundsBehavior: Flickable.StopAtBounds
                        model: controlPlane.contentModel
                        delegate: ContentRow {
                            width: contentList.width
                            selected: root.selectedIndex === index
                            onClicked: root.selectedIndex = index
                        }
                        ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }
                        Text {
                            anchors.centerIn: parent
                            visible: contentList.count === 0
                            text: "Chưa có nội dung trong Control Plane"
                            color: Theme.textFaint
                            font.pixelSize: 12
                        }
                    }
                    Rectangle {
                        Layout.fillWidth: true; Layout.preferredHeight: 40
                        color: Theme.base; border.width: 1; border.color: Theme.borderSoft
                        RowLayout {
                            anchors.fill: parent; anchors.leftMargin: 14; anchors.rightMargin: 14
                            Text { text: controlPlane.contentModel.count + " mục"; color: Theme.textFaint; font.pixelSize: 11 }
                            Item { Layout.fillWidth: true }
                            Text { text: "content.list  ·  nguồn dữ liệu thật"; color: Theme.textFaint; font.pixelSize: 11 }
                        }
                    }
                }
            }

            Panel {
                Layout.fillHeight: true
                Layout.preferredWidth: 390
                Layout.minimumWidth: 360
                Layout.maximumWidth: 420
                ColumnLayout {
                    anchors.fill: parent
                    spacing: 0
                    RowLayout {
                        Layout.fillWidth: true; Layout.preferredHeight: 56
                        Layout.leftMargin: 16; Layout.rightMargin: 14
                        Text { text: "Chi tiết nội dung"; color: Theme.text; font.pixelSize: 15; font.weight: Font.Bold }
                        Item { Layout.fillWidth: true }
                        AppButton { text: "Mở Studio"; onClicked: controlPlane.navigateTo(1) }
                    }
                    Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Theme.borderSoft }
                    ScrollView {
                        Layout.fillWidth: true; Layout.fillHeight: true
                        contentWidth: availableWidth; clip: true
                        ColumnLayout {
                            width: parent.width
                            spacing: 0
                            ColumnLayout {
                                Layout.fillWidth: true
                                Layout.margins: 18
                                spacing: 7
                                StatusBadge { status: root.selectedContent.status || "unknown" }
                                Text {
                                    Layout.fillWidth: true
                                    text: root.selectedContent.title || "Chọn một nội dung"
                                    color: Theme.text; font.pixelSize: 17; font.weight: Font.Bold
                                    wrapMode: Text.Wrap; lineHeight: 1.14
                                }
                                Text { Layout.fillWidth: true; text: root.selectedContent.hook || "Chưa có hook"; color: Theme.textMuted; font.pixelSize: 11; wrapMode: Text.Wrap; lineHeight: 1.2 }
                            }
                            SectionLabel { text: "THUỘC TÍNH" }
                            DetailLine { label: "Trụ cột"; value: root.selectedContent.pillar || "—" }
                            DetailLine { label: "Định dạng"; value: root.selectedContent.formatName || "—" }
                            DetailLine { label: "Ngôn ngữ"; value: root.selectedContent.language || "—" }
                            DetailLine { label: "Kịch bản"; value: (root.selectedContent.scriptCount || 0) + " cảnh" }
                            DetailLine { label: "Tags"; value: String(root.selectedContent.tagCount || 0) }
                            DetailLine { label: "Kênh"; value: root.compactId(root.selectedContent.channelId) }
                            DetailLine { label: "Lịch dự kiến"; value: root.selectedContent.scheduledAt || "Chưa lên lịch" }
                            SectionLabel { text: "MÔ TẢ PHÁT HÀNH" }
                            Text {
                                Layout.fillWidth: true
                                Layout.leftMargin: 16; Layout.rightMargin: 16; Layout.topMargin: 12
                                text: root.selectedContent.description || "Chưa có mô tả"
                                color: Theme.textMuted; font.pixelSize: 11; wrapMode: Text.Wrap; lineHeight: 1.25
                            }
                            Item { Layout.preferredHeight: 14 }
                        }
                    }
                }
            }
        }
    }

    component CountCard: Rectangle {
        id: countCard
        property string label
        property int value
        property color tone
        Layout.preferredWidth: 112; Layout.preferredHeight: 48
        radius: Theme.radiusMedium; color: Theme.elevated
        border.width: 1; border.color: Theme.borderSoft
        ColumnLayout {
            anchors.centerIn: parent; spacing: 0
            Text { text: String(countCard.value); color: countCard.tone; font.pixelSize: 16; font.weight: Font.Bold; Layout.alignment: Qt.AlignHCenter }
            Text { text: countCard.label; color: Theme.textFaint; font.pixelSize: 11; Layout.alignment: Qt.AlignHCenter }
        }
    }

    component ContentHeader: Rectangle {
        implicitHeight: 34; color: Theme.base
        RowLayout {
            anchors.fill: parent; anchors.leftMargin: 16; anchors.rightMargin: 14; spacing: 10
            HeaderLabel { text: "NỘI DUNG"; Layout.fillWidth: true }
            HeaderLabel { text: "TRỤ CỘT"; Layout.preferredWidth: 115 }
            HeaderLabel { text: "ĐỊNH DẠNG"; Layout.preferredWidth: 100 }
            HeaderLabel { text: "NGÔN NGỮ"; Layout.preferredWidth: 78 }
            HeaderLabel { text: "TRẠNG THÁI"; Layout.preferredWidth: 112 }
        }
    }
    component HeaderLabel: Text { color: Theme.textFaint; font.pixelSize: 11; font.weight: Font.Bold }

    component ContentRow: Rectangle {
        id: contentRow
        required property int index
        required property string title
        required property string status
        required property string pillar
        required property string formatName
        required property string language
        required property int scriptCount
        property bool selected: false
        signal clicked()
        implicitHeight: 64
        color: selected ? Theme.accentSoft : (contentMouse.containsMouse ? Theme.hover : "transparent")
        border.width: 1; border.color: selected ? Theme.accent : Theme.borderSoft
        RowLayout {
            anchors.fill: parent; anchors.leftMargin: 16; anchors.rightMargin: 14; spacing: 10
            ColumnLayout {
                Layout.fillWidth: true; spacing: 2
                Text { Layout.fillWidth: true; text: contentRow.title; color: Theme.text; font.pixelSize: 12; font.weight: Font.DemiBold; elide: Text.ElideRight }
                Text { text: contentRow.scriptCount + " cảnh trong kịch bản"; color: Theme.textFaint; font.pixelSize: 11 }
            }
            Text { text: contentRow.pillar; color: Theme.textMuted; font.pixelSize: 11; Layout.preferredWidth: 115; elide: Text.ElideRight }
            Text { text: contentRow.formatName; color: Theme.textMuted; font.pixelSize: 11; Layout.preferredWidth: 100; font.capitalization: Font.Capitalize }
            Text { text: contentRow.language.toUpperCase(); color: Theme.textMuted; font.pixelSize: 11; Layout.preferredWidth: 78 }
            StatusBadge { status: contentRow.status; Layout.preferredWidth: 112 }
        }
        MouseArea { id: contentMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: contentRow.clicked() }
    }

    component StatusBadge: Rectangle {
        id: statusBadge
        property string status
        implicitWidth: 104; implicitHeight: 24; radius: 12
        color: status === "produced" ? Theme.successSoft : status === "brief_ready" ? Theme.accentSoft : Theme.elevated
        Text {
            anchors.centerIn: parent
            text: statusBadge.status === "brief_ready" ? "Brief sẵn sàng" : statusBadge.status === "produced" ? "Đã sản xuất" : statusBadge.status
            color: statusBadge.status === "produced" ? Theme.success : Theme.textMuted
            font.pixelSize: 11; font.weight: Font.DemiBold
        }
    }

    component SectionLabel: Rectangle {
        property alias text: sectionText.text
        Layout.fillWidth: true; Layout.preferredHeight: 38
        color: Theme.base
        Text { id: sectionText; anchors.left: parent.left; anchors.leftMargin: 16; anchors.verticalCenter: parent.verticalCenter; color: Theme.textFaint; font.pixelSize: 11; font.weight: Font.Bold; font.letterSpacing: 0.6 }
    }

    component DetailLine: RowLayout {
        id: detailLine
        property string label
        property string value
        Layout.fillWidth: true; Layout.leftMargin: 16; Layout.rightMargin: 16
        implicitHeight: 30; spacing: 8
        Text { text: detailLine.label; color: Theme.textFaint; font.pixelSize: 11 }
        Item { Layout.fillWidth: true }
        Text { text: detailLine.value; color: Theme.textMuted; font.pixelSize: 11; font.weight: Font.DemiBold; elide: Text.ElideRight; Layout.maximumWidth: 235 }
    }
}
